const { getWechatRingAdapter, appendLog, beginOtaOperation, getAppState, getStatusSnapshot,
  startOtaDiagnostics, stopOtaDiagnostics, appendNordicPacketTrace, restorePhyApplication } = require("../../utils/demo-state");

// PHY 页面只绑定界面；正常切换、Boot 恢复和持久记录由共享控制器完成。
Page({
  controller: null,
  data: {},
  // 从设备列表进入时仅带目标标识，不携带固件或自动刷写。
  onLoad(options) {
    const { PhyDemoController, createPhyDemoState } = getWechatRingAdapter();
    const state = createPhyDemoState();
    this.controller = new PhyDemoController(wx, state, () => this.setData({ ...state }), appendLog, beginOtaOperation, () => {
      const snapshot = getStatusSnapshot();
      if (!snapshot.connected) return null;
      const info = snapshot.connectedDeviceInfo;
      return { deviceId: info.deviceId, name: info.name, macAddress: info.mac };
    }, restorePhyApplication, appendNordicPacketTrace);
    const selected = getAppState().devices.find((d) => d.deviceId === options.deviceId);
    if (selected) this.controller.selectDevice(selected);
    this.setData({ ...state }); startOtaDiagnostics("PHY");
  },
  // 离页后停止所有后续 BLE，保留磁盘恢复记录。
  onUnload() { this.controller?.dispose(); this.controller = null; void stopOtaDiagnostics(); },
  // 聊天文件不按后缀直接信任，控制器完整解析 HEX。
  chooseFile() { void this.controller.chooseFile(); },
  // 重新打开时加载原始持久副本，仍需用户再次确认适配。
  loadRecovery() { void this.controller.loadRecovery(); },
  // 扫描始终保留 Boot 恢复入口。
  scan() { void this.controller.scan(); },
  // 用户明确选择目标，不按 RSSI 或同名自动选择。
  select(event) { this.controller.select(event.currentTarget.dataset.id); },
  // 开始前明确确认硬件和固件适配。
  confirm(event) { this.controller.confirm(event.detail.value); },
  // 开始完整重刷，正常入口内部切换 Boot。
  start() { void this.controller.start(); },
  // 只搜索和读版本，不重复传输。
  reconnect() { void this.controller.reconnect(); },
  // 只停止本地任务，不强制退出设备 Boot。
  cancel() { this.controller.cancel(); },
  // 清除标记不操作设备，提示保持明确。
  clearRecovery() { this.controller.clearRecovery(); },
  // 完整原始 Hex 和失败原因保留在统一日志页。
  logs() { wx.navigateTo({ url: "/pages/logs/logs" }); },
});
