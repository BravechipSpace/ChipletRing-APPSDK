<script setup lang="ts">
import { inject, onUnmounted, reactive } from "vue";
import { PHY_DEMO_CONTEXT, type PhyDemoContext, type PhyPanelHandle } from "../utils/phy-ota";
import { PhyDemoController, createPhyDemoState } from "../libs/bcl-ring-sdk.js";

/** 页面只绑定 UI，不编码协议。 */
const props = defineProps<{ externalBusy: boolean }>();
const context = inject<PhyDemoContext>(PHY_DEMO_CONTEXT);
/** 全量固件与 BLE 连接保存在控制器内部。 */
const state = reactive(createPhyDemoState());
const controller = context?.api ? new PhyDemoController(context.api, state, () => {}, context.log, () => {
  if (props.externalBusy || context.externalBusy()) throw new Error("其他设备操作正在进行，请稍候");
  context.busyChanged(true); return () => context.busyChanged(false);
}, context.getConnected, context.restoreApplication, context.packetTrace) : null;
/** 后台与用户停止明确区分，文件选择引起的隐藏不取消文件阶段。 */
function cancelUpgrade(reason?: string): void { controller?.cancel(reason === "background" ? "background" : "user"); }
onUnmounted(() => controller?.dispose());
const handle: PhyPanelHandle = { cancelUpgrade, dispose: () => controller?.dispose(), selectDevice: (device) => controller?.selectDevice(device) };
defineExpose(handle);
</script>

<template>
  <view class="panel">
    <view class="title">PHY 固件升级与 Boot 恢复</view>
    <view v-if="!controller" class="hint">请使用 UniApp 编译的微信小程序，在微信真机运行。</view>
    <template v-else>
      <view class="hint">正常升级先连接戒指；停在 PPLUSOTA 的戒指可直接扫描恢复。恢复从首分区完整重刷，请保持前台运行。</view>
      <button :disabled="state.busy || externalBusy" @click="controller.chooseFile()">选择 HEX16 / HEX 固件</button>
      <button v-if="state.hasRecovery" :disabled="state.busy || externalBusy" @click="controller.loadRecovery()">加载上次升级固件</button>
      <view>{{ state.fileName || '尚未选择文件' }}</view>
      <button :disabled="state.busy || externalBusy" @click="controller.scan()">重新搜索 Boot 恢复设备</button>
      <view v-for="device in state.devices" :key="device.deviceId" class="device" :class="{ selected: state.selectedId === device.deviceId }" @click="controller.select(device.deviceId)">
        <view>{{ device.localName || device.name }} · PHY 恢复模式</view>
        <view>MAC: {{ device.macAddress || '缺失，无法自动关联升级' }}</view>
        <view>{{ device.deviceId }}</view>
      </view>
      <view class="hint"><switch :disabled="state.busy || externalBusy || !state.ready" :checked="state.confirmed" @change="controller.confirm($event.detail.value)" />我已确认固件适用于目标戒指</view>
      <button type="primary" :disabled="state.busy || externalBusy || !state.ready || !state.confirmed" @click="controller.start()">开始升级 / 完整恢复</button>
      <progress :percent="state.percent" show-info />
      <view class="status">{{ state.status }}</view>
      <view v-if="state.firmwareVersion">当前固件版本：{{ state.firmwareVersion }}</view>
      <button v-if="state.hasRecovery" :disabled="state.busy || externalBusy" @click="controller.reconnect()">重新搜索并读取版本（不刷写）</button>
      <button v-if="state.busy" @click="cancelUpgrade()">停止操作</button>
      <button v-if="state.hasRecovery" :disabled="state.busy || externalBusy" @click="controller.clearRecovery()">清除本地标记（设备模式不变）</button>
    </template>
  </view>
</template>

<style scoped>
.panel { margin: 12px 7px; padding: 16px; border: 1px solid #ccc; background: #fff; border-radius: 8px; font-size: 14px; }
.title { font-size: 16px; font-weight: 600; }
.hint { margin: 12px 0; color: #666; line-height: 20px; font-size: 12px; }
.status, .device { margin: 12px 0; word-break: break-all; }
.device { border: 1px solid #ccc; padding: 10px; }
.selected { border-color: #1677ff; background: #eef5ff; }
button { margin: 10px 0; font-size: 14px; }
</style>
