<script setup lang="ts">
import { inject, onUnmounted, reactive } from "vue";
import { NORDIC_DEMO_CONTEXT, type NordicDemoContext } from "../utils/nordic-ota";
import { createNordicDemoState, NordicDemoController } from "../libs/bcl-ring-sdk.js";
import { type ApolloPanelHandle } from "../utils/apollo-ota";

/** 复用首页的真实连接、日志和互斥；本面板只面向微信小程序。 */
const props = defineProps<{ connected: boolean; externalBusy: boolean }>();
const context = inject<NordicDemoContext>(NORDIC_DEMO_CONTEXT);
/** 固件二进制保留在控制器内，不进入 Vue 响应式状态。 */
const state = reactive(createNordicDemoState());
const controller = context?.api ? new NordicDemoController(context.api, state, () => {}, context.log, () => {
  if (props.externalBusy || context.externalBusy()) throw new Error("其他设备操作正在进行，请稍候");
  context.busyChanged(true);
  return () => context.busyChanged(false);
}, () => {
  const session = context.getSession();
  return session ? { deviceId: session.channel.deviceId } : null;
}, context.packetTrace, context.restoreApplication) : null;

/** 将后台来源透传；文件选择可继续，用户按钮和销毁仍明确停止。 */
function cancelUpgrade(reason?: string): void { controller?.cancel(reason === "background" ? "background" : "user"); }
onUnmounted(() => controller?.dispose());
/** 与 Apollo 面板保持相同生命周期接口，供首页统一清理。 */
const handle: ApolloPanelHandle = { cancelUpgrade, dispose: () => controller?.dispose() };
defineExpose(handle);
</script>

<template>
  <view class="panel">
    <view class="title">Nordic 固件升级</view>
    <view v-if="!controller" class="hint">请使用 UniApp 编译的微信小程序，在微信真机运行。</view>
    <template v-else>
      <view class="hint">{{ state.busy ? '正在为当前戒指升级，请保持戒指靠近手机。' : connected ? '升级对象：当前已连接戒指' : state.canRetry ? '已保留本次升级设备，可直接重试。' : '请先在首页连接需要升级的戒指。' }}</view>
      <button :disabled="state.busy || externalBusy" @click="controller.chooseZip()">选择升级文件（ZIP）</button>
      <view>{{ state.fileName || '尚未选择升级文件' }}</view>
      <button type="primary" :disabled="state.busy || externalBusy || !state.ready || (!connected && !state.canRetry)" @click="controller.start()">{{ state.canRetry && !connected ? '重新开始升级' : '开始升级' }}</button>
      <view v-if="!state.ready" class="hint">选择适用于当前戒指的文件，校验通过后即可开始。</view>
      <progress v-if="state.busy || state.percent > 0" :percent="state.percent" show-info />
      <view class="status">{{ state.status }}</view>
      <button v-if="state.canReconnect && !state.busy" :disabled="state.busy || externalBusy" @click="controller.reconnect()">重新连接戒指</button>
      <button v-if="state.busy" @click="cancelUpgrade()">停止升级</button>
      <view class="hint">设备切换和重新连接将自动完成，请保持小程序前台运行。传输完成后自动重连并读取版本，详细记录见下方日志。</view>
    </template>
  </view>
</template>

<style scoped>
.panel { margin: 12px 7px; padding: 16px; border: 1px solid #d1d1d6; border-radius: 8px; background: #fff; font-size: 14px; }
.title { font-size: 16px; font-weight: 600; }
.hint { color: #666; font-size: 12px; line-height: 19px; margin: 10px 0; }
.status { padding: 10px 0; word-break: break-all; }
button { margin: 8px 0; font-size: 14px; }
</style>
