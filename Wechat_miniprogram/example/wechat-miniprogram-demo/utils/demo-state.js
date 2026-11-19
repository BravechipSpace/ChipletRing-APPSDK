const RECENT_DEVICE_STORAGE_KEY = "bcl_ring_recent_device";
const NETWORK_TOKEN_STORAGE_KEY = "bcl_ring_network_token";
const NETWORK_REGION_STORAGE_KEY = "bcl_ring_network_region";
const MAX_LOG_ENTRIES = 300;
const ANDROID_PREFERRED_MTU = 512;
const { createWechatFirmwareDownloader, safeFirmwareUrl } = require("./firmware-files");

// 诊断文件保留完整 OTA 会话，日志页仍使用有限滚动窗口。
let otaDiagnostic = null;
// 页面离开后也等待最后一轮落盘，供日志页复制完整诊断。
let lastOtaDiagnosticWrite = Promise.resolve();
// 真正连接事件的注销函数，避免重连后旧连接回调污染新会话。
let connectionUnsubscribe = null;

let cachedAdapter = null;
let cachedNetworkSDK = null;
let networkRegion = wx.getStorageSync(NETWORK_REGION_STORAGE_KEY) || "domestic";
let logListeners = [];
// 滚动窗口达到上限后长度不再变化，用单调序号避免同毫秒日志 ID 重复。
let nextLogId = 0;

function getAppState() {
  const app = getApp();
  if (!app.globalData.demoState) {
    app.globalData.demoState = {
      session: null,
      logs: [],
      devices: [],
      selectedDeviceId: "",
      selectedDeviceName: "",
      recentDeviceInfo: wx.getStorageSync(RECENT_DEVICE_STORAGE_KEY) || null,
      connectedDeviceInfo: null,
      scanSummary: "尚未扫描",
      isScanning: false,
      isConnecting: false,
      isBusy: false,
      // 跨页面 OTA 互斥；取消回调接收 background 等来源，由控制器区分文件准备与 BLE 升级。
      otaBusy: false,
      cancelOta: null,
      otaDiagnosticPath: "",
      connected: false,
      autoScroll: true,
      batteryCallbackListening: false,
      batteryUnsubscribeFns: [],
    };
  }
  return app.globalData.demoState;
}

function getWechatRingAdapter() {
  if (cachedAdapter) {
    return cachedAdapter;
  }

  try {
    cachedAdapter = require("../libs/bcl-ring-sdk");
    return cachedAdapter;
  } catch (error) {
    throw new Error(`本地SDK文件加载失败：${formatError(error)}`);
  }
}

// 小程序网络请求适配器，把 wx.request 包装成 fetch 兼容的最小 Response 形态。
function createWechatFetch() {
  return function wechatFetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      const method = options.method || "GET";
      const headers = options.headers || {};
      const body = options.body ? JSON.parse(options.body) : undefined;
      const logUrl = safeFirmwareUrl(url);
      appendLog(`网络请求 Method:${method} URL:${logUrl}`, "debug");
      appendLog(`网络请求 Header:${formatNetworkLogValue(maskNetworkHeaders(headers))}`, "debug");
      appendLog(`网络请求 Body:${formatNetworkLogValue(body)}`, "debug");
      wx.request({
        url,
        method,
        header: headers,
        data: body,
        success: (response) => {
          appendLog(`网络响应 Status:${response.statusCode} URL:${logUrl}`, "debug");
          appendLog(`网络响应 Body:${formatNetworkLogValue(response.data)}`, "debug");
          resolve({
            ok: response.statusCode >= 200 && response.statusCode < 300,
            status: response.statusCode,
            json: async () => parseWechatResponseData(response.data),
          });
        },
        fail: (error) => {
          const message = String(error.errMsg || "请求失败").split(url).join(logUrl)
            .replace(/https?:\/\/[^\s"']+/g, safeFirmwareUrl);
          appendLog(`网络请求失败 Method:${method} URL:${logUrl} 原因:${message}`, "error");
          reject(new Error(message));
        },
      });
    });
  };
}

function maskNetworkHeaders(headers) {
  return Object.keys(headers || {}).reduce((result, key) => {
    const value = headers[key];
    result[key] = /auth|token|key|cookie|secret/i.test(key) ? maskSensitiveText(value) : value;
    return result;
  }, {});
}

function maskSensitiveText(value) {
  if (!value) {
    return value;
  }
  // Header 的具体 Token 对调试下载链路无帮助，避免短值首尾拼接泄露完整内容。
  return "***";
}

function formatNetworkLogValue(value) {
  if (value === undefined) {
    return "无";
  }
  try {
    const text = JSON.stringify(value, (key, field) => {
      if (/auth|token|password|secret|key|cookie/i.test(key)) return "***";
      return typeof field === "string" && /^https?:\/\//i.test(field) ? safeFirmwareUrl(field) : field;
    });
    return text.length > 1200 ? `${text.slice(0, 1200)}...` : text;
  } catch (_) {
    return String(value);
  }
}

function parseWechatResponseData(data) {
  if (typeof data !== "string") {
    return data;
  }
  try {
    return JSON.parse(data);
  } catch (_) {
    return data;
  }
}

// 获取网络 SDK 单例；网络功能不依赖蓝牙连接，区域配置与原生 Demo 的国内/海外切换保持一致。
function getNetworkSDK() {
  if (cachedNetworkSDK) {
    return cachedNetworkSDK;
  }

  const { BCLRingNetworkSDK, createWechatTokenStore } = getWechatRingAdapter();
  cachedNetworkSDK = new BCLRingNetworkSDK({
    region: networkRegion,
    fetch: createWechatFetch(),
    tokenStore: createWechatTokenStore({ wx, storageKey: NETWORK_TOKEN_STORAGE_KEY }),
    downloader: createWechatFirmwareDownloader(wx, appendLog, appendError),
    clientType: "WeChatMP",
  });
  return cachedNetworkSDK;
}

// 切换网络服务器区域后重建 SDK 单例，后续请求会使用新的 baseURL。
function setNetworkRegion(region) {
  networkRegion = region === "overseas" ? "overseas" : "domestic";
  wx.setStorageSync(NETWORK_REGION_STORAGE_KEY, networkRegion);
  cachedNetworkSDK = null;
  return getNetworkSDK();
}

// 返回当前网络服务器区域，供 Demo 首页展示。
function getNetworkRegion() {
  return networkRegion;
}

function formatError(error) {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}

function formatMtuPayloadSize(mtu) {
  return mtu ? `${Math.max(0, mtu - 3)}字节` : "--";
}

function formatErrorDetail(error) {
  if (error instanceof Error) {
    return error.stack || error.message;
  }
  try {
    return JSON.stringify(error);
  } catch (_) {
    return String(error);
  }
}

function normalizeDeviceDisplayInfo(device) {
  if (!device) {
    return null;
  }

  return {
    deviceId: device.deviceId || "",
    name: device.localName || device.name || "Unknown",
    mac: device.macAddress || "",
    rssi: device.RSSI === undefined ? "" : String(device.RSSI),
    manufacturerDataHex: device.manufacturerDataHex || "",
  };
}

function buildDeviceDisplayText(deviceInfo) {
  if (!deviceInfo) {
    return "点击查看日志";
  }

  const parts = [];
  if (deviceInfo.name) {
    parts.push(deviceInfo.name);
  }
  if (deviceInfo.mac) {
    parts.push(deviceInfo.mac);
  }
  if (deviceInfo.rssi) {
    parts.push(`${deviceInfo.rssi}dB`);
  }
  return parts.length > 0 ? parts.join(" • ") : "点击查看日志";
}

function getStatusSnapshot() {
  const state = getAppState();
  const connected = Boolean(state.session);
  state.connected = connected;
  if (!connected) {
    state.connectedDeviceInfo = null;
  }

  const panelInfo = state.connectedDeviceInfo || state.recentDeviceInfo;
  return {
    connected,
    isScanning: state.isScanning,
    isConnecting: state.isConnecting,
    isBusy: state.isBusy || state.otaBusy,
    otaBusy: Boolean(state.otaBusy),
    otaDiagnosticPath: state.otaDiagnosticPath || "",
    recentDeviceInfo: state.recentDeviceInfo,
    connectedDeviceInfo: state.connectedDeviceInfo,
    statusText: connected ? "已连接" : state.isConnecting ? "连接中..." : "未连接",
    statusClass: connected ? "connected" : state.isConnecting ? "connecting" : "disconnected",
    statusDeviceText: connected ? buildDeviceDisplayText(state.connectedDeviceInfo) : "点击查看日志",
    logDeviceName: panelInfo ? panelInfo.name || "Unknown" : "未连接",
    logDeviceMac: panelInfo && panelInfo.mac ? panelInfo.mac : "--:--:--:--:--:--",
    logDeviceRssi: panelInfo && panelInfo.rssi ? `${panelInfo.rssi} dBm` : "--",
    batteryCallbackListening: state.batteryCallbackListening,
  };
}

function getLogSnapshot() {
  const state = getAppState();
  return {
    logs: state.logs,
    autoScroll: state.autoScroll,
    ...getStatusSnapshot(),
  };
}

function appendLog(message, level = "info", detail = "") {
  const state = getAppState();
  const now = new Date();
  const entry = {
    id: `log-${now.getTime()}-${++nextLogId}`,
    time: now.toLocaleTimeString(),
    level,
    message,
    detail,
    text: `${now.toLocaleTimeString()} [${level.toUpperCase()}] ${message}`,
  };

  state.logs = [...state.logs, entry].slice(-MAX_LOG_ENTRIES);
  appendOtaDiagnostic(`${entry.text}${detail ? `\n${detail}` : ""}`);

  if (level === "error") {
    console.error(`[BCLRingDemo] ${message}`, detail);
  } else if (level === "warning") {
    console.warn(`[BCLRingDemo] ${message}`);
  } else {
    console.log(`[BCLRingDemo] ${message}`);
  }

  notifyLogListeners();
  return entry;
}

// 从进入 OTA 页起记录现有上下文和后续网络/蓝牙日志，各页使用独立文件避免异步写入串档。
function startOtaDiagnostics(kind = "Apollo") {
  const state = getAppState();
  if (otaDiagnostic) return state.otaDiagnosticPath;
  const fs = wx.getFileSystemManager();
  // 仅使用已知升级类型生成日志名，兼容原 Apollo 页面调用。
  const label = kind === "Nordic" ? "Nordic" : kind === "PHY" ? "PHY" : "Apollo";
  const path = `${wx.env.USER_DATA_PATH}/${label.toLowerCase()}-ota-${Date.now()}.log`;
  const recorder = { path, queue: Promise.resolve(), failed: false };
  otaDiagnostic = recorder;
  state.otaDiagnosticPath = path;
  recorder.queue = new Promise((resolve, reject) => fs.writeFile({
    filePath: path, data: `${state.logs.map((entry) => `${entry.text}\n${entry.detail || ""}`).join("\n")}\n`,
    encoding: "utf8", success: resolve, fail: reject,
  })).catch(() => diagnosticFailed(recorder));
  appendLog(`${label} 完整诊断文件：${path}`, "debug");
  return path;
}

// 日志按顺序落盘；写入失败仅提示一次，不反复递归写入失败日志。
function appendOtaDiagnostic(line) {
  const recorder = otaDiagnostic;
  if (!recorder || recorder.failed) return;
  recorder.queue = recorder.queue.then(() => {
    if (recorder.failed) return;
    return new Promise((resolve, reject) => wx.getFileSystemManager().appendFile({
      filePath: recorder.path, data: `${line}\n`, encoding: "utf8", success: resolve, fail: reject,
    }));
  }).catch(() => diagnosticFailed(recorder));
}

// 全量记录原始分片，日志页仅展示完整逻辑包和 ACK，避免大量分片淹没状态。
function appendApolloDebug(event) {
  const message = `Apollo ${event.type} 阶段:${event.state} 命令:${event.command || "--"} 偏移:${event.offset} Hex:${event.hex}`;
  if (event.type === "write") appendOtaDiagnostic(message);
  else appendLog(message, event.type === "error" ? "error" : "debug", event.error ? JSON.stringify(event.error) : "");
}

// Nordic 原始数据分片由控制器批量传入，不逐片刷新 UI 或 console；诊断不可用时保留在日志页。
function appendNordicPacketTrace(text) {
  if (!otaDiagnostic || otaDiagnostic.failed) { appendLog(text, "debug"); return; }
  appendOtaDiagnostic(text);
}

// 后续日志不再入文件，但已排队的数据继续写完。
function stopOtaDiagnostics() {
  const recorder = otaDiagnostic;
  otaDiagnostic = null;
  if (recorder) lastOtaDiagnosticWrite = recorder.queue;
  return lastOtaDiagnosticWrite;
}

// 复制前排空已记录的数据，不关闭仍在工作的日志记录器。
async function getOtaDiagnosticFile() {
  await (otaDiagnostic ? otaDiagnostic.queue : lastOtaDiagnosticWrite);
  return getAppState().otaDiagnosticPath;
}

// 标记文件日志不可用，滚动日志页仍然可用。
function diagnosticFailed(recorder) {
  if (recorder.failed) return;
  recorder.failed = true;
  appendLog("OTA 诊断文件写入失败，当前仅保留日志页滚动窗口，请及时导出调试信息", "warning");
}

// 在准备通道到传输结束期间锁定其他设备操作。
function beginOtaOperation(cancel) {
  const state = getAppState();
  if (state.otaBusy || state.isBusy || state.isScanning || state.isConnecting) throw new Error("设备正忙，请先完成其他操作");
  state.otaBusy = true;
  state.cancelOta = cancel;
  notifyLogListeners();
  return () => {
    if (state.cancelOta === cancel) {
      state.otaBusy = false;
      state.cancelOta = null;
      notifyLogListeners();
    }
  };
}

function appendError(prefix, error) {
  const message = formatError(error);
  const detail = formatErrorDetail(error);
  console.error(`[BCLRingDemo] ${prefix}`, error);
  appendLog(`${prefix}：${message}`, "error", detail);
  return message;
}

function clearLogs() {
  const state = getAppState();
  state.logs = [];
  return appendLog("------------所有日志已清除------------", "warning");
}

// 日志页使用该订阅实时刷新，避免只在 onShow 时拿一次快照。
function onLogsChanged(listener) {
  logListeners.push(listener);
  return () => {
    logListeners = logListeners.filter((item) => item !== listener);
  };
}

function notifyLogListeners() {
  for (const listener of logListeners) {
    listener(getLogSnapshot());
  }
}

function formatCommandPart(value) {
  return `0x${value.toString(16).padStart(2, "0")}`;
}

function formatCommandRequest(request) {
  if (request === undefined) {
    return "无";
  }
  try {
    return JSON.stringify(request);
  } catch (_) {
    return String(request);
  }
}

// SDK core 调试回调：统一打印发送参数、发送 hex 和设备原始响应 hex。
function handleCommandDebug(event) {
  if (event.type === "write") {
    appendLog(
      `发送指令 Cmd:${formatCommandPart(event.cmd)} SubCmd:${formatCommandPart(event.subcmd)} FrameId:${formatCommandPart(event.frameId)} 参数:${formatCommandRequest(event.request)} Hex:${event.hex}`,
      "debug",
    );
    return;
  }

  appendLog(`收到响应原始数据 Hex:${event.hex}`, "debug");
}

function formatChargingState(state) {
  if (state === "not_charging") {
    return "未充电";
  }
  if (state === "charging") {
    return "充电中";
  }
  if (state === "full") {
    return "已充满";
  }
  return state || "--";
}

function formatBatteryEvent(event) {
  const level = event.isLevelValid ? `${event.level}%` : `无效(${event.rawValue})`;
  const chargingState = formatChargingState(event.chargingState);
  return `来源:${event.source} 电量:${level} 充电:${chargingState} Hex:${event.rawHex}`;
}

function formatBatteryToast(event) {
  const level = event.isLevelValid ? `${event.level}%` : `无效(${event.rawValue})`;
  return event.chargingState ? `电量${level} ${formatChargingState(event.chargingState)}` : `电量${level}`;
}

// 回调到达时用 toast 给出轻量提示，完整原始数据仍写入日志页。
function showBatteryCallbackToast(title) {
  wx.showToast({
    title,
    icon: "none",
    duration: 1800,
  });
}

// 刷新当前首页数据；回调可能发生在日志页，找不到首页时只更新全局状态。
function refreshIndexPageStatus() {
  const pages = getCurrentPages();
  const indexPage = pages.find((page) => page.route === "pages/index/index");
  if (indexPage && typeof indexPage.setData === "function") {
    indexPage.setData(getStatusSnapshot());
  }
}

function setSelectedDevice(device) {
  if (getAppState().otaBusy) throw new Error("升级期间不能更换设备");
  const state = getAppState();
  state.selectedDeviceId = device ? device.deviceId : "";
  state.selectedDeviceName = device ? device.localName || device.name || "" : "";
}

function getSelectedDevice() {
  const state = getAppState();
  return state.devices.find((device) => device.deviceId === state.selectedDeviceId) || null;
}

async function scanDevices() {
  if (getAppState().otaBusy) throw new Error("升级期间不能扫描设备");
  const state = getAppState();
  if (state.isScanning) {
    return state.devices;
  }

  state.isScanning = true;
  state.devices = [];
  state.scanSummary = "正在扫描...";
  appendLog("开始扫描戒指设备");

  try {
    const { scanWechatRingDevices } = getWechatRingAdapter();
    const seenDeviceIds = new Set();
    const devices = await scanWechatRingDevices({
      wx,
      durationMs: 5000,
      allowDuplicatesKey: true,
      interval: 0,
      powerLevel: "high",
      filterBclManufacturerData: true,
      includePhyBootloader: true,
      includeConnectedDevices: true,
      onDeviceFound: (device) => {
        if (seenDeviceIds.has(device.deviceId)) {
          return;
        }
        seenDeviceIds.add(device.deviceId);
        appendLog(`发现设备：${formatDevice(device)}`, "debug");
      },
    });

    state.devices = devices;
    state.scanSummary = `发现完成：${devices.length} 个候选（含系统已连接 ${devices.filter((item) => item.systemConnected).length} 个）`;
    setSelectedDevice(devices[0] || null);
    appendLog(state.scanSummary);
    if (devices.length === 0) {
      appendLog("未发现符合厂商数据或系统已连接服务条件的设备；已配对不等于正在广播", "warning");
    }
    return devices;
  } catch (error) {
    state.scanSummary = "扫描失败";
    throw error;
  } finally {
    state.isScanning = false;
  }
}

async function connectSelectedDevice() {
  const state = getAppState();
  if (state.otaBusy) throw new Error("升级期间不能手动重新连接设备");
  if (getSelectedDevice()?.mode === "phyBootloader") throw new Error("此设备处于 PHY 恢复模式，请进入 PHY 升级页恢复");
  return connectCurrentRing();
}

// 内部连接入口供普通连接和 OTA 应用态恢复共用；恢复期间仍保持全局设备锁。
async function connectCurrentRing(assertActive = () => {}, connectTimeoutMs = 10000) {
  const state = getAppState();
  assertActive();
  if (!state.selectedDeviceId) {
    throw new Error("请先选择设备");
  }
  if (state.session) {
    appendLog("当前已有连接", "warning");
    return state.session;
  }

  state.isConnecting = true;
  appendLog(`连接设备：${state.selectedDeviceId}`);
  try {
    const { connectWechatRingSDK, getWechatBlePlatform } = getWechatRingAdapter();
    const platform = getWechatBlePlatform(wx);
    const selectedDevice = getSelectedDevice();
    const candidate = await connectWechatRingSDK({
      wx,
      deviceId: state.selectedDeviceId,
      connectTimeoutMs,
      // iOS 由系统管理 MTU，未知平台也不冒险调用 Android 专属接口。
      preferredMtu: platform === "android" ? ANDROID_PREFERRED_MTU : undefined,
      onMtuConfigured: (event) => {
        if (event.error) {
          appendLog(`MTU协商失败：请求MTU=${event.requestedMtu} 当前MTU=${event.currentMtu || "--"} ${formatError(event.error)}`, "warning");
          return;
        }
        appendLog(`MTU协商成功：请求MTU=${event.requestedMtu} 返回MTU=${event.mtu || "--"} 当前MTU=${event.currentMtu || "--"} 实际负载=${formatMtuPayloadSize(event.currentMtu || event.mtu)}`, "debug");
      },
      onMtuChanged: (event) => {
        appendLog(`MTU变化：deviceId=${event.deviceId} 当前MTU=${event.mtu} 实际负载=${formatMtuPayloadSize(event.mtu)}`, "debug");
      },
      writeType: "writeNoResponse",
      queue: {
        payloadSize: 20,
        intervalMs: 10,
        maxRetries: 1,
      },
      command: {
        timeoutMs: 5000,
        debug: handleCommandDebug,
      },
    });

    // 取消后迟到的连接不能重新写入全局会话。
    try { assertActive(); } catch (error) { await candidate.disconnect().catch(() => {}); throw error; }
    state.session = candidate;

    if (platform !== "android") {
      appendLog(`${platform === "ios" ? "iOS" : "未知平台"} 使用系统管理的 MTU，已跳过手动设置；无响应写入当前 MTU=${state.session.currentMtu || "未知"} 实际负载=${formatMtuPayloadSize(state.session.currentMtu)}`, "debug");
    }

    const connectedDeviceInfo = normalizeDeviceDisplayInfo(selectedDevice) || {
      deviceId: state.selectedDeviceId,
      name: state.selectedDeviceName || "Unknown",
      mac: "",
      rssi: "",
      manufacturerDataHex: "",
    };
    state.connected = true;
    state.connectedDeviceInfo = connectedDeviceInfo;
    // 真实断连必须清除共享会话；先让 OTA 专用监听收到断连，再释放 SDK。
    if (connectionUnsubscribe) connectionUnsubscribe();
    const session = state.session;
    const listener = (event) => {
      if (event.deviceId !== session.channel.deviceId || event.connected || state.session !== session) return;
      state.session = null;
      state.connected = false;
      state.connectedDeviceInfo = null;
      if (state.batteryCallbackListening) stopBatteryCallbacks();
      appendLog("设备已断连，请重新连接后读取版本确认状态", "warning");
      Promise.resolve().then(() => session.disconnect()).catch(() => {
        // 设备已经离线时 closeBLEConnection 可能报错，SDK/MTU 监听仍已释放。
      });
      if (connectionUnsubscribe) connectionUnsubscribe();
      connectionUnsubscribe = null;
    };
    if (typeof wx.onBLEConnectionStateChange === "function") {
      wx.onBLEConnectionStateChange(listener);
      connectionUnsubscribe = () => wx.offBLEConnectionStateChange && wx.offBLEConnectionStateChange(listener);
    }
    state.recentDeviceInfo = connectedDeviceInfo;
    wx.setStorageSync(RECENT_DEVICE_STORAGE_KEY, connectedDeviceInfo);
    appendLog("连接成功，SDK 已就绪");
    return state.session;
  } finally {
    state.isConnecting = false;
  }
}

// OTA 专用应用态恢复：按升级前 ID 直连，即使设备不再广播也不依赖扫描列表。
async function restoreNordicApplication(target, assertActive) {
  const state = getAppState();
  if (!state.otaBusy) throw new Error("应用态自动恢复必须持有 OTA 设备锁");
  assertActive();
  if (state.session && state.session.channel.deviceId !== target.deviceId) throw new Error("当前会话已切换其他设备，停止自动重连");
  state.selectedDeviceId = target.deviceId;
  state.selectedDeviceName = target.name || state.recentDeviceInfo?.name || "当前戒指";
  const restored = await connectCurrentRing(assertActive, 5000);
  try {
    assertActive();
    const version = await restored.sdk.getFirmwareVersion(); assertActive();
    return { deviceId: restored.channel.deviceId, version: version.version };
  } catch (error) {
    if (state.session === restored) {
      connectionUnsubscribe?.(); connectionUnsubscribe = null;
      state.session = null; state.connected = false; state.connectedDeviceInfo = null;
    }
    await restored.disconnect().catch(() => {});
    throw error;
  }
}

// PHY 按新鲜应用态广播恢复普通 SDK，身份由共享控制器按 MAC 验证。
async function restorePhyApplication(target, assertActive) {
  const state = getAppState();
  assertActive();
  state.devices = state.devices.filter((item) => item.deviceId !== target.deviceId).concat(target);
  return restoreNordicApplication(target, assertActive);
}

function startBatteryCallbacks() {
  const state = getAppState();
  const session = requireSession();
  if (state.batteryCallbackListening) {
    appendLog("电池回调监听已开启", "warning");
    return;
  }
  if (typeof session.sdk.onBatteryPush !== "function" || typeof session.sdk.onChargingStateChanged !== "function") {
    throw new Error("当前 SDK 构建不支持电池回调监听，请重新构建小程序 SDK 包");
  }

  const unsubscribeBattery = session.sdk.onBatteryPush((event) => {
    showBatteryCallbackToast(formatBatteryToast(event));
    appendLog(`电池回调：${formatBatteryEvent(event)}`, "debug");
    refreshIndexPageStatus();
  });
  const unsubscribeCharging = session.sdk.onChargingStateChanged((chargingState, event) => {
    showBatteryCallbackToast(`充电状态：${formatChargingState(chargingState)}`);
    appendLog(`充电状态回调：${formatChargingState(chargingState)} Hex:${event.rawHex}`, "debug");
    refreshIndexPageStatus();
  });

  state.batteryUnsubscribeFns = [unsubscribeBattery, unsubscribeCharging];
  state.batteryCallbackListening = true;
  appendLog("已开启电池回调监听");
}

function stopBatteryCallbacks() {
  const state = getAppState();
  for (const unsubscribe of state.batteryUnsubscribeFns) {
    unsubscribe();
  }
  state.batteryUnsubscribeFns = [];
  state.batteryCallbackListening = false;
  appendLog("已停止电池回调监听");
}

async function disconnectDevice() {
  const state = getAppState();
  if (state.otaBusy) throw new Error("请先在升级页停止当前操作");
  if (state.batteryCallbackListening) {
    stopBatteryCallbacks();
  }
  if (!state.session) {
    state.connected = false;
    state.connectedDeviceInfo = null;
    return;
  }

  const session = state.session;
  // 主动断开前注销连接监听，避免同一次断连重复执行清理。
  if (connectionUnsubscribe) connectionUnsubscribe();
  connectionUnsubscribe = null;
  try {
    await session.disconnect();
    appendLog("已断开连接");
  } finally {
    if (connectionUnsubscribe) connectionUnsubscribe();
    connectionUnsubscribe = null;
    state.session = null;
    state.connected = false;
    state.connectedDeviceInfo = null;
  }
}

function requireSession() {
  const state = getAppState();
  if (!state.session) {
    throw new Error("SDK 未连接");
  }
  return state.session;
}

function formatDevice(device) {
  const name = device.localName || device.name || "Unknown";
  const rssi = device.RSSI === undefined ? "Unknown" : device.RSSI;
  const mac = device.macAddress || "无MAC";
  const manufacturerData = device.manufacturerDataHex || "无厂商数据";
  return `${name} / RSSI:${rssi} / MAC:${mac} / 厂商数据:${manufacturerData} / ${device.deviceId}`;
}

module.exports = {
  appendApolloDebug,
  beginOtaOperation,
  getWechatRingAdapter,
  getOtaDiagnosticFile,
  startOtaDiagnostics,
  stopOtaDiagnostics,
  appendError,
  appendLog,
  appendNordicPacketTrace,
  restoreNordicApplication,
  restorePhyApplication,
  buildDeviceDisplayText,
  clearLogs,
  connectSelectedDevice,
  disconnectDevice,
  getAppState,
  getLogSnapshot,
  getNetworkSDK,
  getNetworkRegion,
  getSelectedDevice,
  getStatusSnapshot,
  onLogsChanged,
  requireSession,
  scanDevices,
  setSelectedDevice,
  setNetworkRegion,
  startBatteryCallbacks,
  stopBatteryCallbacks,
};
