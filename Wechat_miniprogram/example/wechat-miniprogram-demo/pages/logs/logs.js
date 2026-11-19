const {
  clearLogs,
  getAppState,
  getLogSnapshot,
  onLogsChanged,
  getOtaDiagnosticFile,
  appendError,
} = require("../../utils/demo-state");

Page({
  // 取消日志实时订阅的函数。
  unsubscribeLogs: null,

  data: {
    // 页面内结构化日志。
    logs: [],
    // 完整诊断文件独立于滚动窗口，仅在 OTA 结束后允许复制。
    otaDiagnosticPath: "",
    otaBusy: false,
    // 自动滚动开关。
    autoScroll: true,
    // scroll-view 锚点。
    logScrollIntoView: "",
    // 当前连接摘要。
    connected: false,
    logDeviceName: "未连接",
    logDeviceMac: "--:--:--:--:--:--",
    logDeviceRssi: "--",
  },

  onLoad() {
    this.refreshLogs(true);
    this.unsubscribeLogs = onLogsChanged((snapshot) => {
      this.applyLogSnapshot(snapshot, true);
    });
  },

  onShow() {
    this.refreshLogs(true);
  },

  onUnload() {
    if (this.unsubscribeLogs) {
      this.unsubscribeLogs();
      this.unsubscribeLogs = null;
    }
  },

  // 从共享状态刷新日志页。
  refreshLogs(scrollToBottom = false) {
    this.applyLogSnapshot(getLogSnapshot(), scrollToBottom);
  },

  // 应用日志快照，自动滚动开启时定位到最新日志。
  applyLogSnapshot(snapshot, scrollToBottom = false) {
    const latest = snapshot.logs[snapshot.logs.length - 1];
    this.setData({
      ...snapshot,
      logScrollIntoView: scrollToBottom && latest && snapshot.autoScroll ? latest.id : this.data.logScrollIntoView,
    });
  },

  // 切换日志自动滚动开关。
  onAutoScrollChange(event) {
    const state = getAppState();
    state.autoScroll = event.detail.value;
    this.refreshLogs(state.autoScroll);
  },

  // 清空日志并记录清空动作。
  clearLogs() {
    wx.showModal({
      title: "清除日志",
      content: "确定要清除当前页面日志吗？",
      success: (result) => {
        if (!result.confirm) {
          return;
        }
        clearLogs();
        this.refreshLogs(true);
      },
    });
  },

  // 复制全部日志。
  copyAllLogs() {
    const content = this.data.logs.map((entry) => entry.text).join("\n");
    wx.setClipboardData({
      data: content,
      success: () => this.showToast("日志已复制"),
    });
  },

  // 排空诊断队列后复制全部 OTA/下载日志，包含已滚出屏幕的原始分片。
  async copyOtaDiagnostics() {
    if (getAppState().otaBusy) return;
    try {
      const path = await getOtaDiagnosticFile();
      if (!path) throw new Error("当前没有 OTA 诊断文件");
      const content = await new Promise((resolve, reject) => wx.getFileSystemManager().readFile({
        filePath: path, encoding: "utf8", success: (result) => resolve(result.data), fail: reject,
      }));
      wx.setClipboardData({ data: content, success: () => this.showToast("完整OTA日志已复制"),
        fail: (error) => { appendError("复制OTA日志失败", error); this.showToast("复制失败，请在开发者工具提取诊断文件"); } });
    } catch (error) {
      appendError("读取OTA诊断文件失败", error);
      this.showToast("无法读取完整诊断，请查看日志");
    }
  },

  // 点击单行日志时复制该行内容。
  copyLogLine(event) {
    const logId = String(event.currentTarget.dataset.logId || "");
    const entry = this.data.logs.find((item) => item.id === logId);
    if (!entry) {
      return;
    }
    wx.setClipboardData({
      data: entry.text,
      success: () => this.showToast("该行日志已复制"),
    });
  },

  showToast(title) {
    wx.showToast({ title, icon: "none" });
  },
});
