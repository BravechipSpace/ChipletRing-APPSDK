<script setup lang="ts">
import { computed, provide, ref, shallowRef } from "vue";
import { onHide, onUnload } from "@dcloudio/uni-app";
import { NORDIC_DEMO_CONTEXT, type NordicDemoContext } from "../../utils/nordic-ota";
import PhyOtaPanel from "../../components/PhyOtaPanel.vue";
import { PHY_DEMO_CONTEXT, type PhyDemoContext, type PhyPanelHandle } from "../../utils/phy-ota";
import type { PhyDevice } from "../../../shared/phy-demo";
import NordicOtaPanel from "../../components/NordicOtaPanel.vue";
import ApolloOtaPanel from "../../components/ApolloOtaPanel.vue";
import { OtaDiagnostics, errorText, type ConnectionEvent, type WechatOtaApi } from "../../utils/wechat-platform";
import { APOLLO_DEMO_CONTEXT, type ApolloDemoContext, type ApolloPanelHandle } from "../../utils/apollo-ota";
import {
  connectUniAppRingSDK,
  scanUniAppRingDevices,
  type ConnectedUniAppRingSDK,
  type UniBluetoothDevice,
  type UniBleApi,
} from "../../libs/bcl-ring-sdk.js";

type CommandItem = {
  /** 页面按钮唯一标识，用于判断按钮状态。 */
  id: number;
  /** 按钮展示文案。 */
  title: string;
  /** 是否必须连接戒指后才能点击。 */
  requiresConnection: boolean;
  /** 按钮触发的业务动作。 */
  action: () => Promise<void>;
};

type CommandSection = {
  /** 功能分组标题。 */
  title: string;
  /** 当前分组下的按钮列表。 */
  items: CommandItem[];
};

// 已扫描到的候选设备列表。
const devices = ref<UniBluetoothDevice[]>([]);
// 当前选中的 uni-app deviceId，用于发起连接。
const selectedDeviceId = ref("");
// 升级后即使断连事件已清空会话，仍重连最近实际连接的戒指，避免扫描结果改变目标。
const lastConnectedDeviceId = ref("");
// 当前 SDK 连接会话，包含 sdk、channel 和 disconnect 方法。
const session = shallowRef<ConnectedUniAppRingSDK | null>(null);
// 页面内操作日志。
const logs = ref<string[]>([]);
// 扫描、连接和命令执行状态，用于控制按钮禁用。
const isScanning = ref(false);
const isConnecting = ref(false);
const isBusy = ref(false);

// 面板持有文件/OTA/版本读取互斥锁，首页普通指令和设备操作必须等待释放。
const isApolloBusy = ref(false);
// 两种 OTA 共用首页阻塞条件，各自只释放自身持有的锁。
const isNordicBusy = ref(false);
// PHY 模式切换使用独立连接，和其他 OTA 统一互斥。
const isPhyBusy = ref(false);
// 页面生命周期统一停止 PHY；选择目标只转交给面板。
const phyPanel = ref<PhyPanelHandle | null>(null);
// 保存已连接设备真实广播身份，不随设备列表重扫而丢失。
const connectedPhyDevice = shallowRef<PhyDevice | null>(null);
const isOtaBusy = computed(() => isApolloBusy.value || isNordicBusy.value || isPhyBusy.value);
// 面板引用用于后台、断连和页面卸载时停止升级。
const otaPanel = ref<ApolloPanelHandle | null>(null);
// Nordic 使用独立 Bootloader 连接，不因应用态预期断连而自动取消。
const nordicPanel = ref<ApolloPanelHandle | null>(null);
// HBuilderX 部分旧类型将 advertisData 声明为数组；微信运行时实际是 ArrayBuffer，SDK 使用自己的最小 BLE 类型。
const bleApi = uni as unknown as UniBleApi;
// 只在微信编译分支引用 wx，其他端给出明确不支持提示。
let wechatApi: WechatOtaApi | null = null;
// #ifdef MP-WEIXIN
wechatApi = wx;
// #endif
// 保留完整会话诊断，界面最多显示最近 300 条日志。
const diagnostics = wechatApi ? new OtaDiagnostics(wechatApi, (message) => {
  logs.value.unshift(message);
  console.warn(message);
}) : null;
// 卸载后迟到的连接回调只能清理，不能重新持有连接。
let active = true;

// 连接状态由真实事件刷新，重启/意外断连不能留下“已连接”假象。
function onConnectionChanged(event: ConnectionEvent): void {
  if (!event.connected && session.value?.channel.deviceId === event.deviceId) {
    const lost = session.value;
    session.value = null;
    otaPanel.value?.cancelUpgrade("设备连接已断开");
    void lost.disconnect().catch((error) => appendLog(`断连清理：${errorText(error)}`));
    appendLog("设备连接已断开，请确认设备状态后重连");
  }
}
wechatApi?.onBLEConnectionStateChange(onConnectionChanged);
onHide(() => {
  otaPanel.value?.cancelUpgrade("小程序进入后台，升级已停止");
  nordicPanel.value?.cancelUpgrade("background");
  phyPanel.value?.cancelUpgrade("background");
});
onUnload(() => {
  active = false;
  otaPanel.value?.dispose();
  nordicPanel.value?.dispose();
  phyPanel.value?.dispose();
  wechatApi?.offBLEConnectionStateChange(onConnectionChanged);
  const closing = session.value;
  session.value = null;
  void closing?.disconnect().catch((error) => appendLog(`离页断连：${errorText(error)}`));
});

// 通过内存上下文共享会话与回调，组件属性只承载可序列化展示状态。
provide<ApolloDemoContext>(APOLLO_DEMO_CONTEXT, {
  ble: bleApi, api: wechatApi, getSession: () => session.value, reconnect: reconnectDevice,
  externalBusy: () => isBusy.value || isScanning.value || isConnecting.value || isNordicBusy.value || isPhyBusy.value,
  log: appendLog, busyChanged: onOtaBusyChanged,
});

// Nordic 的预期模式切换断连不影响升级控制器，后台与卸载仍统一取消。
provide<NordicDemoContext>(NORDIC_DEMO_CONTEXT, {
  ble: bleApi, api: wechatApi, getSession: () => session.value, reconnect: reconnectDevice,
  externalBusy: () => isBusy.value || isScanning.value || isConnecting.value || isApolloBusy.value || isPhyBusy.value,
  log: appendLog, busyChanged: (busy) => { isNordicBusy.value = busy; },
  // 原始分片保留完整文件诊断，避免每次 BLE 写入都刷新响应式日志列表。
  packetTrace: (text) => { if (diagnostics?.isAvailable()) diagnostics.append(text); else appendLog(text); },
  restoreApplication: restoreNordicApplication,
});

// PHY 保存真实广播 MAC 并按新鲜扫描结果恢复应用态。
provide<PhyDemoContext>(PHY_DEMO_CONTEXT, {
  api: wechatApi, getConnected: () => session.value ? connectedPhyDevice.value : null,
  externalBusy: () => isBusy.value || isScanning.value || isConnecting.value || isApolloBusy.value || isNordicBusy.value,
  busyChanged: (value) => { isPhyBusy.value = value; }, log: appendLog,
  packetTrace: (text) => { if (diagnostics?.isAvailable()) diagnostics.append(text); else appendLog(text); },
  restoreApplication: async (target, assertActive) => {
    const result = await restoreNordicApplication(target, assertActive);
    connectedPhyDevice.value = target; return result;
  },
});

// 是否已经持有可用 SDK 会话。
const connected = computed(() => session.value !== null);
// 当前选中的设备对象，用于状态栏展示。
const selectedDevice = computed(() => devices.value.find((device) => device.deviceId === selectedDeviceId.value));
const statusText = computed(() => {
  if (connected.value) {
    return "已连接";
  }
  if (isConnecting.value) {
    return "连接中...";
  }
  return "未连接";
});
const statusClass = computed(() => {
  if (connected.value) {
    return "connected";
  }
  if (isConnecting.value) {
    return "connecting";
  }
  return "disconnected";
});

// 页面按钮分组，保持与原生 Swift SDKDemo 的基础功能区接近。
const commandSections: CommandSection[] = [
  {
    title: "发现蓝牙设备",
    items: [
      {
        id: 1,
        title: "蓝牙设备搜索",
        requiresConnection: false,
        action: scanDevices,
      },
      {
        id: 2,
        title: "停止蓝牙设备搜索",
        requiresConnection: false,
        action: stopScan,
      },
    ],
  },
  {
    title: "连接蓝牙设备",
    items: [
      {
        id: 11,
        title: "连接选中设备",
        requiresConnection: false,
        action: connectSelectedDevice,
      },
      {
        id: 12,
        title: "断开连接",
        requiresConnection: false,
        action: disconnect,
      },
    ],
  },
  {
    title: "时间同步",
    items: [
      {
        id: 31,
        title: "同步时间",
        requiresConnection: true,
        action: syncTime,
      },
      {
        id: 32,
        title: "读取时间",
        requiresConnection: true,
        action: getTime,
      },
    ],
  },
  {
    title: "版本号获取",
    items: [
      {
        id: 41,
        title: "获取硬件版本",
        requiresConnection: true,
        action: getHardwareVersion,
      },
      {
        id: 42,
        title: "获取固件版本",
        requiresConnection: true,
        action: getFirmwareVersion,
      },
    ],
  },
  {
    title: "电池管理",
    items: [
      {
        id: 51,
        title: "获取电量信息",
        requiresConnection: true,
        action: getBatteryLevel,
      },
      {
        id: 52,
        title: "获取充电状态",
        requiresConnection: true,
        action: getChargingState,
      },
    ],
  },
];

// 扫描设备，并通过名称和自定义条件筛掉明显无效的蓝牙广播。
async function scanDevices(): Promise<void> {
  if (isScanning.value || isOtaBusy.value) {
    return;
  }

  isScanning.value = true;
  appendLog("开始扫描戒指设备");
  try {
    devices.value = await scanUniAppRingDevices({
      uni: bleApi,
      durationMs: 5000,
      includeConnectedDevices: true,
      filterBclManufacturerData: true,
      includePhyBootloader: true,
    });
    appendLog(`扫描完成，找到 ${devices.value.length} 个候选设备`);
    if (devices.value.length > 0 && !connected.value) {
      selectedDeviceId.value = devices.value[0].deviceId;
    }
  } catch (error) {
    appendError("扫描失败", error);
  } finally {
    isScanning.value = false;
  }
}

// 当前扫描流程使用固定 durationMs，到时间后 adapter 会自动停止扫描。
async function stopScan(): Promise<void> {
  appendLog("停止扫描由扫描流程自动完成");
}

// 连接选中设备，并组装 uni-app BLE adapter、写入队列和 SDK core。
async function connectSelectedDevice(): Promise<void> {
  if (isOtaBusy.value || isBusy.value || isScanning.value) return;
  const target = devices.value.find((device) => device.deviceId === selectedDeviceId.value);
  if (target?.mode === "phyBootloader") {
    phyPanel.value?.selectDevice(target); appendLog("已选择 PHY 恢复设备，请在下方 PHY 面板准备固件后恢复"); return;
  }
  await connectDevice();
}

// 连接底层入口也供 OTA 重连核验调用，由面板锁保证互斥。
async function connectDevice(): Promise<void> {
  if (!selectedDeviceId.value) {
    showToast("请先选择设备");
    return;
  }
  if (session.value) {
    appendLog("当前已有连接");
    return;
  }

  isConnecting.value = true;
  appendLog(`连接设备：${selectedDeviceId.value}`);
  try {
    const connectedSession = await connectUniAppRingSDK({
      uni: bleApi,
      deviceId: selectedDeviceId.value,
      connectTimeoutMs: 10000,
      writeType: "writeNoResponse",
      queue: {
        // BLE 单包默认 20 字节，队列负责分包和串行写入。
        payloadSize: 20,
        intervalMs: 10,
        maxRetries: 1,
      },
      command: {
        timeoutMs: 5000,
      },
    });
    if (!active) { await connectedSession.disconnect(); return; }
    session.value = connectedSession;
    connectedPhyDevice.value = devices.value.find((device) => device.deviceId === connectedSession.channel.deviceId) || null;
    lastConnectedDeviceId.value = connectedSession.channel.deviceId;
    appendLog("连接成功，SDK 已就绪；Apollo 会在专用通道就绪后核验 MTU");
  } catch (error) {
    appendError("连接失败", error);
  } finally {
    isConnecting.value = false;
  }
}

// 断开当前连接，同时释放 SDK 内部通知监听。
async function disconnect(): Promise<void> {
  if (isOtaBusy.value || isBusy.value) return;
  await disconnectDevice();
}

// 先清除本地会话，避免旧断连事件误伤随后创建的新会话。
async function disconnectDevice(): Promise<void> {
  if (!session.value) {
    appendLog("当前未连接设备");
    return;
  }

  const closing = session.value;
  session.value = null;
  try {
    await closing.disconnect();
    appendLog("已断开连接");
  } catch (error) {
    appendError("断开失败", error);
  } finally {
    session.value = null;
  }
}

// 用户确认设备重启后主动重连，读取版本仍由面板单独发起。
async function reconnectDevice(): Promise<ConnectedUniAppRingSDK> {
  await disconnectDevice();
  if (!active) throw new Error("页面已离开");
  selectedDeviceId.value = lastConnectedDeviceId.value || selectedDeviceId.value;
  await connectDevice();
  return requireSession();
}

// Nordic 升级结束后按原设备 ID 恢复首页会话；不依赖设备继续广播。
async function restoreNordicApplication(target: { deviceId: string }, assertActive: () => void): Promise<{ deviceId: string; version: string }> {
  assertActive();
  if (!active) throw new Error("页面已离开");
  if (session.value && session.value.channel.deviceId !== target.deviceId) throw new Error("当前已连接其他设备，停止恢复");
  const restored = session.value || await connectUniAppRingSDK({
    uni: bleApi, deviceId: target.deviceId, connectTimeoutMs: 5000, writeType: "writeNoResponse",
    queue: { payloadSize: 20, intervalMs: 10, maxRetries: 1 }, command: { timeoutMs: 5000 },
  });
  try {
    assertActive(); if (!active) throw new Error("页面已离开");
    const version = await restored.sdk.getFirmwareVersion(); assertActive();
    if (!active) throw new Error("页面已离开");
    session.value = restored; selectedDeviceId.value = target.deviceId; lastConnectedDeviceId.value = target.deviceId;
    appendLog(`Nordic 应用态会话恢复完成，固件版本：${version.version}`);
    return { deviceId: target.deviceId, version: version.version };
  } catch (error) {
    if (session.value === restored) session.value = null;
    await restored.disconnect().catch(() => {}); throw error;
  }
}

// 接收面板锁变化，阻止首页普通命令、扫描、换设备及手动断连。
function onOtaBusyChanged(value: boolean): void { isApolloBusy.value = value; }

// 使用本机当前时间同步到戒指，timezone 按小时偏移传给协议层。
async function syncTime(): Promise<void> {
  await runCommand("同步时间", async () => {
    const timezone = -new Date().getTimezoneOffset() / 60;
    await requireSession().sdk.syncTime({
      timestampMs: Date.now(),
      timezone,
    });
    return "已发送当前时间";
  });
}

// 读取戒指保存的当前时间。
async function getTime(): Promise<void> {
  await runCommand("读取时间", async () => JSON.stringify(await requireSession().sdk.getTime()));
}

// 读取戒指固件版本号。
async function getFirmwareVersion(): Promise<void> {
  await runCommand("获取固件版本", async () => (await requireSession().sdk.getFirmwareVersion()).version);
}

// 读取戒指硬件版本号。
async function getHardwareVersion(): Promise<void> {
  await runCommand("获取硬件版本", async () => (await requireSession().sdk.getHardwareVersion()).version);
}

// 读取电量百分比或充电特殊状态。
async function getBatteryLevel(): Promise<void> {
  await runCommand("获取电量信息", async () => JSON.stringify(await requireSession().sdk.getBatteryLevel()));
}

// 读取充电状态枚举。
async function getChargingState(): Promise<void> {
  await runCommand("获取充电状态", async () => JSON.stringify(await requireSession().sdk.getChargingState()));
}

// 统一包裹 SDK 命令执行，避免多个指令并发写入导致状态混乱。
async function runCommand(label: string, command: () => Promise<string>): Promise<void> {
  if (isBusy.value || isOtaBusy.value) {
    return;
  }

  isBusy.value = true;
  appendLog(`${label}...`);
  try {
    appendLog(`${label}：${await command()}`);
  } catch (error) {
    appendError(`${label}失败`, error);
  } finally {
    isBusy.value = false;
  }
}

// 页面按钮点击入口，负责连接前置校验和忙碌状态保护。
async function runCommandItem(item: CommandItem): Promise<void> {
  if (isOtaBusy.value) return;
  if (item.requiresConnection && !connected.value) {
    showToast("请先连接设备");
    return;
  }
  if (item.id === 1 || item.id === 2) {
    await item.action();
    return;
  }
  if (isBusy.value || isConnecting.value) {
    return;
  }
  await item.action();
}

// 设置当前选中的设备。
function selectDevice(deviceId: string): void {
  if (connected.value || isOtaBusy.value || isConnecting.value) return;
  selectedDeviceId.value = deviceId;
}

// 根据当前扫描、连接和命令执行状态控制按钮是否可点击。
function commandDisabled(item: CommandItem): boolean {
  if (isOtaBusy.value || isConnecting.value) return true;
  if (item.id === 1) {
    return isScanning.value;
  }
  if (item.id === 11) {
    return isConnecting.value || connected.value || !selectedDeviceId.value;
  }
  if (item.id === 12) {
    return !connected.value;
  }
  return item.requiresConnection ? !connected.value || isBusy.value : isBusy.value;
}

// 获取当前连接会话；未连接时抛错交给统一错误处理。
function requireSession(): ConnectedUniAppRingSDK {
  if (!session.value) {
    throw new Error("SDK 未连接");
  }
  return session.value;
}

// 追加页面日志。
function appendLog(message: string): void {
  const entry = `${new Date().toLocaleTimeString()} ${message}`;
  logs.value.unshift(entry);
  if (logs.value.length > 300) logs.value.length = 300;
  diagnostics?.append(entry);
  console.log(`[BCLRingUniDemo] ${entry}`);
}

// 统一处理页面错误提示。
function appendError(prefix: string, error: unknown): void {
  const message = errorText(error);
  appendLog(`${prefix}：${message}`);
  showToast(prefix);
}

// 统一非阻塞提示，详细原因保留在日志。
function showToast(title: string): void {
  uni.showToast({ title, icon: "none" });
}
</script>

<template>
  <view class="page">
    <view class="status-panel" :class="statusClass">
      <view class="status-dot" />
      <view class="status-copy">
        <view class="status-title">{{ statusText }}</view>
        <view class="status-subtitle">{{ selectedDevice?.localName || selectedDevice?.name || "点击查看日志" }}</view>
      </view>
      <view class="status-icon">Log</view>
    </view>

    <view class="section">
      <view class="section-title">设备列表</view>
      <view v-if="devices.length === 0" class="empty">暂无设备</view>
      <view
        v-for="device in devices"
        :key="device.deviceId"
        class="device-cell"
        :class="{ selected: selectedDeviceId === device.deviceId }"
        @click="selectDevice(device.deviceId)"
      >
        <view class="device-info">
          <view class="device-name">Name:{{ device.localName || device.name || "Unknown" }}</view>
          <view v-if="device.mode === 'phyBootloader'" class="device-meta">PHY 恢复模式 · 请在下方 PHY 面板恢复</view>
          <view v-if="device.systemConnected" class="device-meta">系统已连接 · 可接入小程序会话</view>
          <view class="device-meta">Mac:{{ device.macAddress || "Unknown" }}</view>
          <view class="device-meta">DeviceId: {{ device.deviceId }}</view>
          <view class="device-meta">RSSI: {{ device.RSSI ?? "Unknown" }}</view>
        </view>
        <button class="connect-button" :disabled="connected || isConnecting || isOtaBusy || isBusy || isScanning" @click.stop="selectDevice(device.deviceId); connectSelectedDevice()">
          {{ device.mode === 'phyBootloader' ? '恢复固件' : 'Connect' }}
        </button>
      </view>
    </view>

    <view v-for="section in commandSections" :key="section.title" class="section">
      <view class="section-title">{{ section.title }}</view>
      <view class="function-grid">
        <button
          v-for="item in section.items"
          :key="item.id"
          class="function-card"
          :disabled="commandDisabled(item)"
          @click="runCommandItem(item)"
        >
          <view v-if="item.requiresConnection" class="link-mark" />
          <text>{{ item.title }}</text>
        </button>
      </view>
    </view>

    <ApolloOtaPanel ref="otaPanel" :connected="connected"
      :external-busy="isBusy || isScanning || isConnecting || isNordicBusy || isPhyBusy" :diagnostic-path="diagnostics?.path || ''" />

    <NordicOtaPanel ref="nordicPanel" :connected="connected"
      :external-busy="isBusy || isScanning || isConnecting || isApolloBusy || isPhyBusy" />

    <PhyOtaPanel ref="phyPanel" :external-busy="isBusy || isScanning || isConnecting || isApolloBusy || isNordicBusy" />

    <view class="section">
      <view class="section-title">Log日志相关（最近 300 条）</view>
      <view v-if="logs.length === 0" class="empty">暂无日志</view>
      <view v-for="(log, index) in logs" :key="index" class="log-row">{{ log }}</view>
    </view>
  </view>
</template>

<style scoped>
.page {
  min-height: 100vh;
  padding: 8px;
  padding-bottom: 24px;
  box-sizing: border-box;
  background: #f2f2f7;
  color: #000;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.status-panel {
  position: sticky;
  top: 8px;
  z-index: 10;
  display: flex;
  align-items: center;
  min-height: 48px;
  margin: 4px 8px 12px;
  padding: 8px 12px;
  box-sizing: border-box;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  background: rgba(0, 0, 0, 0.8);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.22);
}

.status-dot {
  width: 10px;
  height: 10px;
  flex: 0 0 10px;
  border-radius: 50%;
  background: #ff3b30;
}

.status-panel.connecting .status-dot {
  background: #ff9500;
}

.status-panel.connected .status-dot {
  background: #34c759;
}

.status-copy {
  flex: 1;
  min-width: 0;
  margin-left: 8px;
}

.status-title {
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  line-height: 18px;
}

.status-subtitle {
  overflow: hidden;
  color: rgba(255, 255, 255, 0.72);
  font-size: 10px;
  line-height: 14px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-icon {
  margin-left: 8px;
  color: rgba(255, 255, 255, 0.6);
  font-size: 11px;
}

.section {
  margin-bottom: 8px;
}

.section-title {
  height: 40px;
  padding: 0 8px;
  color: #3c3c43;
  font-size: 15px;
  font-weight: 600;
  line-height: 40px;
}

.function-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.function-card {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 76px;
  margin: 0;
  padding: 16px 8px;
  box-sizing: border-box;
  border: 1px solid #d1d1d6;
  border-radius: 8px;
  background: #fff;
  color: #000;
  font-size: 13px;
  font-weight: 500;
  line-height: 18px;
  text-align: center;
  white-space: normal;
}

.function-card::after,
.connect-button::after {
  border: 0;
}

.function-card[disabled] {
  color: #8e8e93;
  background: #fafafa;
}

.link-mark {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 14px;
  height: 14px;
  border: 2px solid #007aff;
  border-radius: 50%;
  box-sizing: border-box;
}

.device-cell,
.log-row,
.empty {
  margin: 0 7px 15px;
  padding: 12px 16px;
  box-sizing: border-box;
  border: 1px solid #000;
  border-radius: 8px;
  background: #fff;
}

.device-cell {
  display: flex;
  align-items: center;
}

.device-cell.selected {
  border-color: #007aff;
  background: rgba(0, 122, 255, 0.08);
}

.device-info {
  flex: 1;
  min-width: 0;
  padding-right: 12px;
}

.device-name {
  overflow: hidden;
  font-size: 16px;
  font-weight: 500;
  line-height: 22px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.device-meta {
  overflow: hidden;
  margin-top: 5px;
  color: #8e8e93;
  font-size: 14px;
  line-height: 20px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.connect-button {
  flex: 0 0 60px;
  width: 60px;
  height: 42px;
  margin: 0;
  padding: 0;
  border: 0;
  background: transparent;
  color: #007aff;
  font-size: 14px;
  line-height: 42px;
}

.connect-button[disabled] {
  color: #8e8e93;
}

.log-row,
.empty {
  border-color: #d1d1d6;
  color: #8e8e93;
  font-size: 13px;
  line-height: 18px;
}

@media (min-width: 768px) {
  .page {
    max-width: 820px;
    margin: 0 auto;
  }
}
</style>
