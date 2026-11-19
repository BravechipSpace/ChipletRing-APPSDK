const {
  appendError,
  connectSelectedDevice,
  getAppState,
  getStatusSnapshot,
  scanDevices,
  setSelectedDevice,
} = require("../../utils/demo-state");

Page({
  data: {
    // 当前扫描结果。
    devices: [],
    // 当前选中的设备 ID。
    selectedDeviceId: "",
    // 扫描状态和摘要。
    isScanning: false,
    isConnecting: false,
    connected: false,
    // 共享 OTA 锁禁止其他页面更换当前设备。
    otaBusy: false,
    scanSummary: "尚未扫描",
  },

  onLoad() {
    this.refreshFromState();
  },

  onShow() {
    this.refreshFromState();
  },

  // 从共享状态刷新设备列表页。
  refreshFromState() {
    const state = getAppState();
    this.setData({
      devices: state.devices,
      selectedDeviceId: state.selectedDeviceId,
      scanSummary: state.scanSummary,
      ...getStatusSnapshot(),
    });
  },

  // 进入页面后由用户主动触发扫描。
  async scanDevices() {
    if (this.data.isScanning) {
      return;
    }

    this.refreshFromState();
    try {
      const scanPromise = scanDevices();
      this.refreshFromState();
      await scanPromise;
      this.refreshFromState();
    } catch (error) {
      this.handleError("扫描失败", error);
      this.refreshFromState();
    }
  },

  // 选择设备卡片，后续连接会使用该设备。
  selectDevice(event) {
    if (getStatusSnapshot().otaBusy) { this.showToast("升级期间不能更换设备"); return; }
    const deviceId = String(event.currentTarget.dataset.deviceId || "");
    const state = getAppState();
    const selected = state.devices.find((device) => device.deviceId === deviceId) || null;
    setSelectedDevice(selected);
    this.refreshFromState();
  },

  // 卡片上的 Connect 按钮：先选中设备，再连接。
  async connectDeviceFromCard(event) {
    if (getStatusSnapshot().otaBusy) { this.showToast("请先停止当前升级"); return; }
    this.selectDevice(event);
    await this.connectSelectedDevice();
  },

  // 连接当前选中的设备。
  async connectSelectedDevice() {
    if (!this.data.selectedDeviceId) {
      this.showToast("请先选择设备");
      return;
    }
    // Boot 必须进入恢复页，不能初始化普通 RingSDK。
    const target = getAppState().devices.find((d) => d.deviceId === this.data.selectedDeviceId);
    if (target?.mode === "phyBootloader") {
      wx.navigateTo({ url: `/pages/phy-ota/phy-ota?deviceId=${encodeURIComponent(target.deviceId)}` });
      return;
    }
    if (this.data.connected) {
      this.showToast("当前已有连接");
      return;
    }

    this.refreshFromState();
    try {
      const connectPromise = connectSelectedDevice();
      this.refreshFromState();
      await connectPromise;
      this.refreshFromState();
      wx.navigateBack();
    } catch (error) {
      this.handleError("连接失败", error);
      this.refreshFromState();
    }
  },

  // 统一展示设备页错误。
  handleError(prefix, error) {
    const message = appendError(prefix, error);
    wx.showModal({
      title: prefix,
      content: message,
      showCancel: false,
    });
  },

  showToast(title) {
    wx.showToast({ title, icon: "none" });
  },
});
