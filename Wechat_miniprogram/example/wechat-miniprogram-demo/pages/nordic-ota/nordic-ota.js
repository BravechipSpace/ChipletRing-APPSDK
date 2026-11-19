const { getWechatRingAdapter, appendLog, beginOtaOperation, requireSession, getStatusSnapshot,
  startOtaDiagnostics, stopOtaDiagnostics, onLogsChanged, appendNordicPacketTrace, restoreNordicApplication } = require("../../utils/demo-state");

// Nordic 页面仅绑定 UI；ZIP、扫描、连接由共用 Demo 控制器协调。
Page({
  // 二进制和 SDK 对象不放入 data。
  controller: null,
  // 只刷新真实连接状态；预期模式切换断连不会取消内部升级流程。
  unsubscribeStatus: null,
  data: { busy: false, ready: false, fileName: "", status: "请选择升级文件", percent: 0,
    reconnected: false, firmwareVersion: "", canReconnect: false, protocolCompleted: false, canRetry: false, connected: false, deviceName: "" },
  // 进入页面建立独立操作状态，并复用全局互斥及后台取消入口。
  onLoad() {
    const { createNordicDemoState, NordicDemoController } = getWechatRingAdapter();
    const state = createNordicDemoState();
    startOtaDiagnostics("Nordic");
    this.controller = new NordicDemoController(wx, state, () => this.setData({ ...state }), appendLog, beginOtaOperation, () => {
      const snapshot = getStatusSnapshot();
      return snapshot.connected ? { deviceId: requireSession().channel.deviceId, name: snapshot.connectedDeviceInfo?.name } : null;
    }, appendNordicPacketTrace, restoreNordicApplication);
    this.unsubscribeStatus = onLogsChanged(() => this.syncConnection());
    this.syncConnection();
  },
  // 从设备列表回到当前页时刷新应用态连接提示。
  onShow() { this.syncConnection(); },
  // 日志频繁变化时仅在连接字段改变后 setData。
  syncConnection() {
    const snapshot = getStatusSnapshot();
    const deviceName = snapshot.connectedDeviceInfo?.name || "当前戒指";
    if (this.data.connected !== snapshot.connected || this.data.deviceName !== deviceName) this.setData({ connected: snapshot.connected, deviceName });
  },
  // 离页释放准备任务与协议订阅；写入排空前全局锁仍保留。
  onUnload() { this.unsubscribeStatus?.(); this.controller?.dispose(); this.controller = null; void stopOtaDiagnostics(); },
  // 用户显式选择聊天中的 Nordic ZIP。
  chooseZip() { void this.controller?.chooseZip(); },
  // 一次点击自动完成当前戒指模式切换、升级连接与传输。
  start() { void this.controller?.start(); },
  // 协议完成后只重连应用服务，不重复传输固件。
  reconnect() { void this.controller?.reconnect(); },
  // 取消不代表设备回滚，请按文档检查恢复状态。
  cancel() { this.controller?.cancel(); },
  // 应用态连接和升级后的版本读取仍使用首页 SDK 示例。
  home() { if (!this.data.busy) wx.navigateBack(); },
  // 协议 Hex 和失败原因汇总在日志页。
  logs() { wx.navigateTo({ url: "/pages/logs/logs" }); },
});
