<script setup lang="ts">
import { computed, inject, onUnmounted, reactive } from "vue";
import { APOLLO_DEMO_CONTEXT, ApolloDemoController, createApolloDemoState, upgradeBlockReason, type ApolloDemoContext, type ApolloPanelHandle } from "../utils/apollo-ota";

/** 首页持有连接；面板只协调固件准备和本次升级状态。 */
const props = defineProps<{
  connected: boolean;
  externalBusy: boolean;
  diagnosticPath: string;
}>();
/** SDK 和平台对象保留在 JS 内存中，不经小程序 props/setData 序列化。 */
const context = inject<ApolloDemoContext>(APOLLO_DEMO_CONTEXT);
const api = context?.api;
/** 仅序列化 UI 状态，固件字节由控制器私有持有。 */
const state = reactive(createApolloDemoState());
/** 微信平台接口不存在时保留明确说明，不伪装支持其他端。 */
const controller = context && api ? new ApolloDemoController(state, { ...context, api }) : null;
/** 统一解释开始按钮置灰原因，选好文件但未连接时给出操作提示。 */
const blockReason = computed(() => upgradeBlockReason(state, props.connected, props.externalBusy));
/** 下载与升级期间不能切换来源或覆盖已选择的文件。 */
const busy = computed(() => state.fileBusy || state.otaBusy || state.versionBusy || props.externalBusy);

/** 输入变更交给控制器，使旧列表与已校验文件立即失效。 */
function onCategoryInput(event: { detail: { value: string } }): void {
  controller?.changeQuery(event.detail.value, state.token);
}
/** Token 仅存当前内存，不写入日志或项目配置。 */
function onTokenInput(event: { detail: { value: string } }): void {
  controller?.changeQuery(state.category, event.detail.value);
}
/** 首页隐藏、设备断连时停止 OTA，保留已读取固件以便人工重试。 */
function cancelUpgrade(reason?: string): void { controller?.cancel(reason); }
onUnmounted(() => controller?.dispose());
/** 生命周期公开句柄显式约束，避免父页面依赖组件内部状态。 */
const handle: ApolloPanelHandle = { cancelUpgrade, dispose: () => controller?.dispose() };
defineExpose(handle);
</script>

<template>
  <view class="ota-panel">
    <view class="ota-title">Apollo 固件升级</view>
    <view v-if="!api" class="hint">本示例面向 Uni-app 编译的微信小程序，请在微信真机上运行。</view>
    <template v-else>
      <view class="source-tabs">
        <button :class="{ active: state.source === 'network' }" :disabled="busy" @click="controller?.changeSource('network')">历史版本下载</button>
        <button :class="{ active: state.source === 'chat' }" :disabled="busy" @click="controller?.changeSource('chat')">微信聊天文件</button>
      </view>
      <view v-if="state.source === 'network'">
        <view class="hint">先查询历史版本，再选择和下载指定文件。分类默认 Z5X。</view>
        <input class="field" :value="state.category" :disabled="busy" placeholder="固件分类，例如 Z5X" @input="onCategoryInput" />
        <input class="field" :value="state.token" :disabled="busy" :password="true" placeholder="接口需要授权时填写已有登录 Token" @input="onTokenInput" />
        <button :disabled="busy" @click="controller?.query()">查询固件历史版本</button>
        <view v-if="state.queried && state.rows.length === 0" class="hint">暂无历史固件，请检查分类或使用聊天文件。</view>
        <scroll-view v-if="state.rows.length" scroll-y class="version-list">
          <view v-for="(row, index) in state.rows" :key="index" class="version-row"
            :class="{ selected: state.selectedIndex === index, invalid: !row.selectable }" @click="controller?.select(index)">
            <view>{{ state.selectedIndex === index ? '✓ ' : '' }}{{ row.fileName }}</view>
            <view class="hint">{{ row.reason || row.displayUrl }}</view>
          </view>
        </scroll-view>
        <button :disabled="busy || state.selectedIndex < 0" @click="controller?.download()">下载所选固件</button>
        <progress :percent="state.downloadPercent" show-info stroke-width="5" />
      </view>
      <view v-else>
        <view class="hint">请先将 bin 固件发送到微信聊天；选择取消不会开始升级。</view>
        <button :disabled="busy" @click="controller?.chooseChat()">从微信聊天记录选择 bin 文件</button>
      </view>
      <view class="hint">{{ state.fileStatus }}</view>
      <view v-if="state.ready" class="file-summary">
        <view>{{ state.fileName }}</view>
        <view>文件 {{ state.fileSize }} 字节 · 正文 {{ state.bodySize }} 字节</view>
        <view class="hint">长度校验不代表设备型号或签名匹配，请确认固件适用于当前戒指。</view>
      </view>
      <view class="hint">固定使用已验证的 237 字节负载（ATT MTU ≥ 240）。iOS MTU 由系统与设备协商。</view>
      <button type="primary" :disabled="!!blockReason" @click="controller?.start()">开始 Apollo 固件升级</button>
      <view v-if="blockReason" class="hint">{{ blockReason }}</view>
      <button :disabled="!state.otaBusy" @click="cancelUpgrade()">停止升级</button>
      <progress :percent="state.otaPercent" show-info stroke-width="6" />
      <view>{{ state.otaStatus }}</view>
      <view v-if="state.result" class="result">{{ state.result }}</view>
      <button :disabled="busy || !state.protocolCompleted" @click="controller?.reconnectReadVersion()">重连并读取真实固件版本</button>
      <view class="hint">升级时请保持微信前台运行。停止或断连后设备侧状态需确认，恢复后从头升级。</view>
      <view class="hint">网络请求、发送 Hex 与原始 ACK 见下方日志。完整诊断：{{ diagnosticPath || '暂不可用' }}</view>
    </template>
  </view>
</template>

<style scoped>
.ota-panel { margin: 12px 7px; padding: 16px; border: 1px solid #d1d1d6; border-radius: 8px; background: #fff; font-size: 14px; }
.ota-title { margin-bottom: 12px; font-size: 16px; font-weight: 600; }
.source-tabs { display: flex; gap: 8px; }
.source-tabs button { flex: 1; font-size: 13px; }
.active { color: #007aff; border: 1px solid #007aff; }
.field { margin: 10px 0; padding: 10px; border: 1px solid #d1d1d6; border-radius: 6px; }
.hint { margin: 8px 0; color: #666; font-size: 12px; line-height: 19px; word-break: break-all; }
.version-list { height: 240px; margin: 10px 0; border: 1px solid #eee; }
.version-row { padding: 10px; border-bottom: 1px solid #eee; word-break: break-all; }
.selected { background: #eaf3ff; }
.invalid { opacity: .5; }
.file-summary, .result { margin: 12px 0; padding: 10px; background: #f2f2f7; border-radius: 6px; word-break: break-all; }
button { margin-top: 8px; font-size: 14px; }
progress { margin: 12px 0; }
</style>
