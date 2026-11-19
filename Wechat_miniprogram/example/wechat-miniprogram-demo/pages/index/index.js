const {
  appendError,
  appendLog,
  disconnectDevice,
  getNetworkRegion,
  getStatusSnapshot,
  getNetworkSDK,
  requireSession,
  setNetworkRegion,
  startBatteryCallbacks,
  stopBatteryCallbacks,
} = require("../../utils/demo-state");

// 页面按钮分组，首页只保留功能入口和 SDK 指令，不直接承载设备列表和日志列表。
const commandSections = [
  {
    title: "固件升级 · Apollo / Nordic / PHY",
    items: [
      { id: 341, title: "历史固件下载升级", requiresConnection: false },
      { id: 342, title: "聊天文件升级", requiresConnection: false },
      // Nordic 使用独立 Bootloader 通道和 ZIP 固件。
      // PHY 提供普通升级及失败后的 Boot 恢复独立入口。
      { id: 344, title: "PHY HEX 固件升级 / 恢复", requiresConnection: false },
      { id: 343, title: "Nordic ZIP 固件升级", requiresConnection: false },
    ],
  },
  {
    title: "发现蓝牙设备",
    items: [
      { id: 1, title: "设备列表 / 扫描", requiresConnection: false },
      { id: 2, title: "日志查看", requiresConnection: false },
    ],
  },
  {
    title: "连接蓝牙设备",
    items: [
      { id: 11, title: "连接设备", requiresConnection: false },
      { id: 12, title: "断开连接", requiresConnection: false },
    ],
  },
  {
    title: "时间同步",
    items: [
      { id: 31, title: "同步时间", requiresConnection: true },
      { id: 32, title: "读取时间", requiresConnection: true },
    ],
  },
  {
    title: "版本号获取",
    items: [
      { id: 41, title: "获取硬件版本", requiresConnection: true },
      { id: 42, title: "获取固件版本", requiresConnection: true },
    ],
  },
  {
    title: "电池管理",
    items: [
      { id: 51, title: "获取电量信息", requiresConnection: true },
      { id: 52, title: "获取充电状态", requiresConnection: true },
      { id: 53, title: "开启电池回调", requiresConnection: true },
      { id: 54, title: "停止电池回调", requiresConnection: true },
    ],
  },
  {
    title: "计步",
    items: [
      { id: 55, title: "实时步数", requiresConnection: true },
      { id: 56, title: "清除步数", requiresConnection: true },
    ],
  },
  {
    title: "系统设置",
    items: [
      { id: 91, title: "设置采集周期", requiresConnection: true },
      { id: 92, title: "读取采集周期", requiresConnection: true },
      { id: 93, title: "设置蓝牙名称", requiresConnection: true },
      { id: 94, title: "读取蓝牙名称", requiresConnection: true },
      { id: 95, title: "一键自检", requiresConnection: true },
      { id: 96, title: "恢复出厂设置", requiresConnection: true },
    ],
  },
  {
    title: "戒指内数据",
    items: [
      { id: 101, title: "同步全部历史数据", requiresConnection: true },
      { id: 102, title: "同步未上传历史数据", requiresConnection: true },
      { id: 103, title: "删除全部历史数据", requiresConnection: true },
    ],
  },
  {
    title: "App事件（复合指令）",
    items: [
      { id: 111, title: "绑定指令", requiresConnection: true },
      { id: 112, title: "连接指令", requiresConnection: true },
      { id: 113, title: "刷新指令", requiresConnection: true },
    ],
  },
  {
    title: "GoMore",
    items: [
      { id: 121, title: "查询授权状态", requiresConnection: true },
      { id: 122, title: "下发授权PKey", requiresConnection: true },
      { id: 123, title: "设置个人信息", requiresConnection: true },
      { id: 124, title: "获取个人信息", requiresConnection: true },
      { id: 125, title: "读取睡眠数据", requiresConnection: true },
    ],
  },
  {
    title: "网络接口",
    items: [
      { id: 129, title: "切换国内服务器", requiresConnection: false },
      { id: 130, title: "切换海外服务器", requiresConnection: false },
      { id: 131, title: "获取Token", requiresConnection: false },
      { id: 132, title: "刷新Token", requiresConnection: false },
      { id: 133, title: "上传历史数据", requiresConnection: false },
      { id: 134, title: "上传血压波形", requiresConnection: false },
      { id: 135, title: "上传血糖波形", requiresConnection: false },
      { id: 136, title: "固件更新检查", requiresConnection: false },
      { id: 137, title: "固件版本列表", requiresConnection: false },
      { id: 138, title: "下载固件文件", requiresConnection: false },
      { id: 139, title: "获取时间线", requiresConnection: false },
      { id: 140, title: "最新历史数据", requiresConnection: false },
    ],
  },
  {
    title: "主动测量 - 温度",
    items: [{ id: 61, title: "温度读取", requiresConnection: true }],
  },
  {
    title: "主动测量 - 心率",
    items: [
      { id: 71, title: "开始测量", requiresConnection: true },
      { id: 72, title: "停止测量", requiresConnection: true },
    ],
  },
  {
    title: "主动测量 - 血氧",
    items: [
      { id: 81, title: "开始测量", requiresConnection: true },
      { id: 82, title: "停止测量", requiresConnection: true },
    ],
  },
];

const FLOATING_ENTRY_WIDTH = 154;
const FLOATING_ENTRY_HEIGHT = 56;

function getDefaultFloatingPosition() {
  const info = wx.getSystemInfoSync();
  return {
    x: Math.max(8, info.windowWidth - FLOATING_ENTRY_WIDTH - 10),
    y: 88,
  };
}

function promptText(title, content, placeholderText) {
  return new Promise((resolve) => {
    wx.showModal({
      title,
      content,
      editable: true,
      placeholderText,
      success: (result) => {
        if (!result.confirm) {
          resolve(null);
          return;
        }
        resolve((result.content || "").trim());
      },
      fail: () => resolve(null),
    });
  });
}

function confirmAction(title, content) {
  return new Promise((resolve) => {
    wx.showModal({
      title,
      content,
      confirmText: "确定",
      cancelText: "取消",
      success: (result) => resolve(Boolean(result.confirm)),
      fail: () => resolve(false),
    });
  });
}

function createAppCompositeRequest() {
  return {
    timestampMs: Date.now(),
    timezone: 8,
    filterTimestamp: Math.floor(new Date(2025, 0, 1, 0, 0, 0).getTime() / 1000),
  };
}

Page({
  // 悬浮入口拖动过程中的临时位置。
  floatingTouchContext: null,
  // 拖动结束后短暂屏蔽 tap，避免误触进入日志页。
  suppressFloatingTap: false,
  // 网络配置弹窗 Promise 回调，不放入 data，避免参与页面渲染。
  networkDialogResolver: null,
  // 历史数据上传沿用原生 Demo 思路，优先使用最近一次戒指内数据同步结果。
  networkCachedHistoryData: [],
  // 血压/血糖云端算法需要波形五元组，Demo 会缓存血氧测量期间收到的红光、红外和加速度数据。
  networkCachedWaveData: [],

  data: {
    // 首页功能按钮配置。
    commandSections,
    // 当前连接和执行状态。
    connected: false,
    isScanning: false,
    isConnecting: false,
    isBusy: false,
    statusText: "未连接",
    statusClass: "disconnected",
    statusDeviceText: "点击查看日志",
    // 悬浮入口固定定位坐标。
    floatingX: 0,
    floatingY: 88,
    batteryCallbackListening: false,
    heartRateMeasuring: false,
    heartRateStatusText: "",
    heartRateResultText: "",
    bloodOxygenMeasuring: false,
    bloodOxygenStatusText: "",
    bloodOxygenResultText: "",
    historyDataSyncing: false,
    historyDataStatusText: "",
    historyDataResultText: "",
    appCompositeSyncing: false,
    appCompositeStatusText: "",
    appCompositeResultText: "",
    goMoreSleepReading: false,
    goMoreStatusText: "",
    goMoreResultText: "",
    networkBusy: false,
    networkRegionText: formatNetworkRegion(getNetworkRegion()),
    networkStatusText: "",
    networkResultText: "",
    networkDialogVisible: false,
    networkDialogTitle: "",
    networkDialogDescription: "",
    networkDialogMode: "fields",
    networkDialogFields: [],
    networkHistoryUploadMode: "",
    networkTimelineStartDate: "",
    networkTimelineStartTime: "",
    networkTimelineEndDate: "",
    networkTimelineEndTime: "",
    networkTimelineRangeText: "",
  },

  onLoad() {
    const position = getDefaultFloatingPosition();
    this.setData({
      floatingX: position.x,
      floatingY: position.y,
    });
    this.refreshStatus();
  },

  onShow() {
    this.refreshStatus();
  },

  // 统一处理首页按钮点击。
  async onCommandTap(event) {
    const id = Number(event.currentTarget.dataset.id);
    // OTA 使用共享锁，防止从首页绕过独立升级页发起其他操作。
    if (getStatusSnapshot().otaBusy && id !== 2) return;
    switch (id) {
      case 344:
        wx.navigateTo({ url: "/pages/phy-ota/phy-ota" });
        return;
      case 343:
        wx.navigateTo({ url: "/pages/nordic-ota/nordic-ota" });
        break;
      case 341:
      case 342:
        wx.navigateTo({ url: `/pages/apollo-ota/apollo-ota?source=${id === 342 ? "chat" : "network"}` });
        break;
      case 1:
      case 11:
        this.openDeviceList();
        break;
      case 2:
        this.openLogPage();
        break;
      case 12:
        await this.disconnect();
        break;
      case 31:
        await this.syncTime();
        break;
      case 32:
        await this.getTime();
        break;
      case 41:
        await this.getHardwareVersion();
        break;
      case 42:
        await this.getFirmwareVersion();
        break;
      case 51:
        await this.getBatteryLevel();
        break;
      case 52:
        await this.getChargingState();
        break;
      case 53:
        this.startBatteryCallbacks();
        break;
      case 54:
        this.stopBatteryCallbacks();
        break;
      case 55:
        await this.getStepCount();
        break;
      case 56:
        await this.clearStepCount();
        break;
      case 91:
        await this.setCollectionPeriod();
        break;
      case 92:
        await this.getCollectionPeriod();
        break;
      case 93:
        await this.setBluetoothName();
        break;
      case 94:
        await this.getBluetoothName();
        break;
      case 95:
        await this.oneKeySelfInspection();
        break;
      case 96:
        await this.restoreFactorySettings();
        break;
      case 101:
        await this.syncAllHistoryData();
        break;
      case 102:
        await this.syncUnuploadedHistoryData();
        break;
      case 103:
        await this.deleteAllHistoryData();
        break;
      case 111:
        await this.appCompositeBind();
        break;
      case 112:
        await this.appCompositeConnect();
        break;
      case 113:
        await this.appCompositeRefresh();
        break;
      case 121:
        await this.queryGoMoreAuthStatus();
        break;
      case 122:
        await this.sendGoMorePKey();
        break;
      case 123:
        await this.setGoMorePersonalInformation();
        break;
      case 124:
        await this.getGoMorePersonalInformation();
        break;
      case 125:
        await this.readGoMoreSleepData();
        break;
      case 129:
        this.switchNetworkRegion("domestic");
        break;
      case 130:
        this.switchNetworkRegion("overseas");
        break;
      case 131:
        await this.createNetworkToken();
        break;
      case 132:
        await this.refreshNetworkToken();
        break;
      case 133:
        await this.uploadNetworkHistory();
        break;
      case 134:
        await this.uploadNetworkBloodPressure();
        break;
      case 135:
        await this.uploadNetworkBloodGlucose();
        break;
      case 136:
        await this.checkNetworkFirmwareUpdate();
        break;
      case 137:
        await this.getNetworkFirmwareVersionList();
        break;
      case 138:
        await this.downloadNetworkFirmware();
        break;
      case 139:
        await this.getNetworkTimeline();
        break;
      case 140:
        await this.loadNetworkLatestHistory();
        break;
      case 61:
        await this.measureTemperature();
        break;
      case 71:
        await this.startHeartRate();
        break;
      case 72:
        await this.stopHeartRate();
        break;
      case 81:
        await this.startBloodOxygen();
        break;
      case 82:
        await this.stopBloodOxygen();
        break;
      default:
        break;
    }
  },

  // 进入独立设备列表页，扫描和连接都在该页面处理。
  openDeviceList() {
    wx.navigateTo({ url: "/pages/device-list/device-list" });
  },

  // 点击悬浮入口或日志按钮进入独立日志页。
  openLogPage() {
    if (this.suppressFloatingTap) {
      return;
    }
    wx.navigateTo({ url: "/pages/logs/logs" });
  },

  // 断开当前连接。
  async disconnect() {
    try {
      await disconnectDevice();
      this.refreshStatus();
    } catch (error) {
      this.handleError("断开失败", error);
    }
  },

  // 使用本机当前时间同步到戒指，timezone 按小时偏移传给协议层。
  async syncTime() {
    await this.runSdkCommand("同步时间", async () => {
      const timezone = -new Date().getTimezoneOffset() / 60;
      await requireSession().sdk.syncTime({
        timestampMs: Date.now(),
        timezone,
      });
      return "已发送当前时间";
    });
  },

  // 读取戒指保存的当前时间。
  async getTime() {
    await this.runSdkCommand("读取时间", async () => JSON.stringify(await requireSession().sdk.getTime()));
  },

  // 读取戒指硬件版本号。
  async getHardwareVersion() {
    await this.runSdkCommand("获取硬件版本", async () => {
      return (await requireSession().sdk.getHardwareVersion()).version;
    });
  },

  // 读取戒指固件版本号。
  async getFirmwareVersion() {
    await this.runSdkCommand("获取固件版本", async () => {
      return (await requireSession().sdk.getFirmwareVersion()).version;
    });
  },

  // 读取电量百分比或充电特殊状态。
  async getBatteryLevel() {
    await this.runSdkCommand("获取电量信息", async () => JSON.stringify(await requireSession().sdk.getBatteryLevel()));
  },

  // 读取充电状态枚举。
  async getChargingState() {
    await this.runSdkCommand("获取充电状态", async () => JSON.stringify(await requireSession().sdk.getChargingState()));
  },

  // 开启电量和充电状态主动回调监听。
  startBatteryCallbacks() {
    try {
      startBatteryCallbacks();
      this.refreshStatus();
    } catch (error) {
      this.handleError("开启电池回调失败", error);
    }
  },

  // 停止电量和充电状态主动回调监听。
  stopBatteryCallbacks() {
    try {
      stopBatteryCallbacks();
      this.refreshStatus();
    } catch (error) {
      this.handleError("停止电池回调失败", error);
    }
  },

  // 读取戒指当前实时步数。
  async getStepCount() {
    await this.runSdkCommand("实时步数", async () => {
      const result = await requireSession().sdk.getStepCount();
      const message = `${result.stepCount} 步`;
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // 清除戒指当前实时步数。
  async clearStepCount() {
    await this.runSdkCommand("清除步数", async () => {
      const result = await requireSession().sdk.clearStepCount();
      const message = result.cleared ? "清除步数成功" : "清除步数结果未知";
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // 设置自动采集周期，单位秒；0 表示关闭周期采集。
  async setCollectionPeriod() {
    const value = await promptText("设置采集周期", "请输入采集周期秒数，0 表示关闭，正常值最小 60 秒。", "300");
    if (value === null) {
      return;
    }
    const periodSeconds = Number(value);
    if (!Number.isInteger(periodSeconds) || periodSeconds < 0 || (periodSeconds !== 0 && periodSeconds < 60)) {
      this.showToast("请输入 0 或不少于 60 的整数");
      return;
    }

    await this.runSdkCommand("设置采集周期", async () => {
      const result = await requireSession().sdk.setCollectionPeriod({ periodSeconds });
      if (!result.success) {
        throw new Error(`设置采集周期失败，状态码:${result.status}`);
      }
      wx.showToast({ title: "设置采集周期成功", icon: "none" });
      return `周期:${periodSeconds}秒 状态:${result.status}`;
    });
  },

  // 读取自动采集周期。
  async getCollectionPeriod() {
    await this.runSdkCommand("读取采集周期", async () => {
      const result = await requireSession().sdk.getCollectionPeriod();
      const message = `采集周期:${result.periodSeconds}秒`;
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // 设置蓝牙名称，部分固件设置成功后会主动断开重连。
  async setBluetoothName() {
    const name = await promptText("设置蓝牙名称", "请输入蓝牙名称，UTF-8 字节长度最大 12。设置后部分固件会断开连接并使用新名称广播。", "BCL-Ring");
    if (name === null) {
      return;
    }
    if (!name) {
      this.showToast("蓝牙名称不能为空");
      return;
    }

    appendLog("注意：设置蓝牙名称后，部分固件会在约 1 秒后断开连接并以新名称广播。", "warning");
    await this.runSdkCommand("设置蓝牙名称", async () => {
      const result = await requireSession().sdk.setBluetoothName({ name });
      if (!result.success) {
        throw new Error(`设置蓝牙名称失败，状态码:${result.status}`);
      }
      wx.showToast({ title: "设置蓝牙名称成功", icon: "none" });
      return `名称:${name} 状态:${result.status}`;
    });
  },

  // 读取蓝牙名称。
  async getBluetoothName() {
    await this.runSdkCommand("读取蓝牙名称", async () => {
      const result = await requireSession().sdk.getBluetoothName();
      const message = `蓝牙名称:${result.name}`;
      wx.showToast({ title: message, icon: "none" });
      return `${message} 长度:${result.length}`;
    });
  },

  // 执行一键自检。
  async oneKeySelfInspection() {
    await this.runSdkCommand("一键自检", async () => {
      const result = await requireSession().sdk.oneKeySelfInspection();
      const message = formatSelfInspectionResult(result);
      wx.showToast({ title: result.hasError ? "发现设备故障" : "设备自检正常", icon: "none" });
      return message;
    });
  },

  // 恢复出厂设置会清空设备侧数据，必须二次确认。
  async restoreFactorySettings() {
    const confirmed = await confirmAction("恢复出厂设置", "该操作会恢复出厂设置，并可能清空历史记录、步数等设备数据。确定继续吗？");
    if (!confirmed) {
      return;
    }

    appendLog("注意：即将执行恢复出厂设置，设备侧数据可能被清空。", "warning");
    await this.runSdkCommand("恢复出厂设置", async () => {
      const result = await requireSession().sdk.restoreFactorySettings();
      const message = result.accepted ? "恢复出厂设置指令已执行" : "恢复出厂设置结果未知";
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // 同步戒指内全部历史数据。
  async syncAllHistoryData() {
    await this.syncHistoryData("同步全部历史数据", "all");
  },

  // 同步戒指内未上传历史数据。
  async syncUnuploadedHistoryData() {
    await this.syncHistoryData("同步未上传历史数据", "unuploaded");
  },

  // 历史数据同步是连续响应，进度展示在首页状态条，详情写入日志页。
  async syncHistoryData(label, kind, options = {}) {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return null;
    }
    if (this.data.isBusy || this.data.heartRateMeasuring || this.data.bloodOxygenMeasuring || this.data.historyDataSyncing) {
      return null;
    }

    this.setData({
      isBusy: true,
      historyDataSyncing: true,
      historyDataStatusText: "正在启动...",
      historyDataResultText: "",
    });
    appendLog(`${label}...`);
    wx.showLoading({ title: "同步中", mask: false });
    try {
      const sdk = requireSession().sdk;
      const syncMethod = kind === "all" ? sdk.syncAllHistoryData : sdk.syncUnuploadedHistoryData;
      const result = await syncMethod.call(sdk, {
        timestamp: 0,
        onStatusChanged: (status, event) => {
          appendLog(`${label}状态：${formatHistoryStatus(status, event)}`, "debug");
          this.setData({ historyDataStatusText: formatHistoryStatusText(status, event) });
        },
        onProgress: (totalNumber, sequence, progress, record) => {
          const statusText = `同步中 ${sequence}/${totalNumber} (${progress}%)`;
          appendLog(`${label}进度：${statusText} ${formatHistoryRecordSummary(record)}`, "debug");
          appendLog(`${label}当前数据：${formatHistoryRecordDetail(record, this.getDefaultMac())}`, "debug");
          this.setData({ historyDataStatusText: statusText });
          wx.showLoading({ title: `${progress}%`, mask: false });
        },
        onMalformedRecord: (error, rawHex) => {
          appendLog(`${label}异常记录：${error.message} Hex:${rawHex}`, "warning");
        },
      });
      wx.hideLoading();
      this.networkCachedHistoryData = mapHistoryRecordsForUpload(result.records || [], this.getDefaultMac());
      const message = formatHistorySyncResult(result);
      appendLog(`${label}完成：${message}`);
      this.setData({
        historyDataStatusText: "同步完成",
        historyDataResultText: message,
      });
      if (!options.skipSuccessToast) {
        wx.showToast({ title: message, icon: "none" });
      }
      return result;
    } catch (error) {
      wx.hideLoading();
      this.handleError(`${label}失败`, error);
      return null;
    } finally {
      this.setData({
        isBusy: false,
        historyDataSyncing: false,
      });
      this.refreshStatus();
    }
  },

  // 删除戒指内全部历史数据，必须二次确认。
  async deleteAllHistoryData() {
    const confirmed = await confirmAction("删除历史数据", "该操作会删除戒指内保存的全部历史数据，删除后无法从戒指恢复。确定继续吗？");
    if (!confirmed) {
      return;
    }

    appendLog("注意：即将删除戒指内全部历史数据。", "warning");
    await this.runSdkCommand("删除全部历史数据", async () => {
      const result = await requireSession().sdk.deleteAllHistoryData();
      const message = result.deleted ? "删除戒指内历史数据成功" : "删除戒指内历史数据结果未知";
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // App 绑定复合指令会同步时间并读取设备基础状态，部分固件可能同时清理历史数据。
  async appCompositeBind() {
    const confirmed = await confirmAction("App绑定指令", "绑定指令通常用于首次绑定，原生 SDK 提示设备可能会清理历史数据。确定继续吗？");
    if (!confirmed) {
      return;
    }

    await this.runSdkCommand("App绑定指令", async () => {
      const deviceInfo = await requireSession().sdk.appEventBind({
        request: createAppCompositeRequest(),
      });
      const message = formatAppCompositeDeviceInfo(deviceInfo);
      appendLog(`App绑定设备信息：${message}`, "debug");
      appendLog(`App绑定设备信息详情：${formatAppCompositeDeviceInfoDetail(deviceInfo)}`, "debug");
      wx.showToast({ title: "绑定指令完成", icon: "none" });
      return message;
    });
  },

  // App 连接复合指令会读取设备信息，并接收设备侧历史数据。
  async appCompositeConnect() {
    await this.runAppCompositeSync("App连接指令", "connect");
  },

  // App 刷新复合指令会读取设备信息，并接收设备侧历史数据。
  async appCompositeRefresh() {
    await this.runAppCompositeSync("App刷新指令", "refresh");
  },

  // 复合连接/刷新是设备信息和历史数据的组合流程，状态展示在首页，详情写入日志。
  async runAppCompositeSync(label, kind) {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy || this.data.heartRateMeasuring || this.data.bloodOxygenMeasuring || this.data.historyDataSyncing || this.data.appCompositeSyncing) {
      return;
    }

    this.setData({
      isBusy: true,
      appCompositeSyncing: true,
      appCompositeStatusText: "正在启动...",
      appCompositeResultText: "",
    });
    appendLog(`${label}...`);
    wx.showLoading({ title: "处理中", mask: false });
    try {
      const sdk = requireSession().sdk;
      const runMethod = kind === "connect" ? sdk.appEventConnect : sdk.appEventRefresh;
      const result = await runMethod.call(sdk, {
        request: createAppCompositeRequest(),
        onDeviceInfo: (deviceInfo) => {
          const message = formatAppCompositeDeviceInfo(deviceInfo);
          appendLog(`${label}设备信息：${message}`, "debug");
          appendLog(`${label}设备信息详情：${formatAppCompositeDeviceInfoDetail(deviceInfo)}`, "debug");
          this.setData({ appCompositeStatusText: "已收到设备信息" });
        },
        onStatusChanged: (status, event) => {
          appendLog(`${label}历史数据状态：${formatHistoryStatus(status, event)}`, "debug");
          this.setData({ appCompositeStatusText: formatHistoryStatusText(status, event) });
        },
        onProgress: (totalNumber, sequence, progress, record) => {
          const statusText = `同步中 ${sequence}/${totalNumber} (${progress}%)`;
          appendLog(`${label}历史数据进度：${statusText} ${formatHistoryRecordSummary(record)}`, "debug");
          appendLog(`${label}当前历史数据：${formatHistoryRecordDetail(record, this.getDefaultMac())}`, "debug");
          this.setData({ appCompositeStatusText: statusText });
          wx.showLoading({ title: `${progress}%`, mask: false });
        },
        onMalformedRecord: (error, rawHex) => {
          appendLog(`${label}异常记录：${error.message} Hex:${rawHex}`, "warning");
        },
      });
      wx.hideLoading();
      if (result.records && result.records.length) {
        this.networkCachedHistoryData = mapHistoryRecordsForUpload(result.records, this.getDefaultMac());
      }
      const message = formatAppCompositeResult(result);
      appendLog(`${label}完成：${message}`);
      this.setData({
        appCompositeStatusText: "处理完成",
        appCompositeResultText: message,
      });
      wx.showToast({ title: message, icon: "none" });
    } catch (error) {
      wx.hideLoading();
      this.handleError(`${label}失败`, error);
    } finally {
      this.setData({
        isBusy: false,
        appCompositeSyncing: false,
      });
      this.refreshStatus();
    }
  },

  // 查询戒指本地 GoMore 授权状态。
  async queryGoMoreAuthStatus() {
    await this.runSdkCommand("查询GoMore授权状态", async () => {
      const result = await requireSession().sdk.queryGoMoreAuthStatus();
      const message = formatGoMoreAuthStatus(result);
      wx.showToast({ title: result.isAuthorized ? "GoMore已授权" : "GoMore未授权", icon: "none" });
      return message;
    });
  },

  // 下发 GoMore 授权 PKey，SDK 会按协议固定写入 64 字节。
  async sendGoMorePKey() {
    const pKey = await promptText("下发GoMore PKey", "请输入64字符授权密钥；SDK会按UTF-8固定写入64字节，超长截断，不足补0。", "请输入PKey");
    if (!pKey) {
      return;
    }
    if (pKey.length !== 64) {
      appendLog(`GoMore PKey长度不是64字符，当前长度:${pKey.length}，SDK将按协议截断或补0。`, "warning");
    }
    await this.runSdkCommand("下发GoMore授权PKey", async () => {
      const result = await requireSession().sdk.sendGoMorePKey({ pKey });
      const message = formatGoMoreAuthStatus(result);
      wx.showToast({ title: result.isAuthorized ? "授权成功" : "仍未授权", icon: "none" });
      return message;
    });
  },

  // 设置 GoMore 个人信息，使用 JSON 便于一次输入全部参数。
  async setGoMorePersonalInformation() {
    const content = [
      "请输入JSON，例如：",
      '{"age":30,"gender":1,"height":175,"weight":70,"maxHeartRate":190,"normalHeartRate":60,"maxOxygenUptake":45}',
      "可选字段不填或负数表示无效。",
    ].join("\n");
    const text = await promptText("设置GoMore个人信息", content, '{"age":30,"gender":1,"height":175,"weight":70}');
    if (!text) {
      return;
    }
    let request;
    try {
      request = JSON.parse(text);
    } catch (error) {
      this.showToast("JSON格式错误");
      appendError("GoMore个人信息JSON解析失败", error);
      return;
    }
    await this.runSdkCommand("设置GoMore个人信息", async () => {
      const result = await requireSession().sdk.goMoreSetPersonalInformation(request);
      const message = result.success ? "GoMore个人信息设置成功" : `GoMore个人信息设置失败 status=${result.status}`;
      wx.showToast({ title: message, icon: "none" });
      return message;
    });
  },

  // 获取 GoMore 个人信息。
  async getGoMorePersonalInformation() {
    await this.runSdkCommand("获取GoMore个人信息", async () => {
      const result = await requireSession().sdk.goMoreGetPersonalInformation();
      const message = formatGoMorePersonalInformation(result);
      wx.showToast({ title: "已获取个人信息", icon: "none" });
      return message;
    });
  },

  // 读取戒指中 GoMore 睡眠数据，过程包持续写入日志页。
  async readGoMoreSleepData() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy || this.data.heartRateMeasuring || this.data.bloodOxygenMeasuring || this.data.historyDataSyncing || this.data.appCompositeSyncing || this.data.goMoreSleepReading) {
      return;
    }

    this.setData({
      isBusy: true,
      goMoreSleepReading: true,
      goMoreStatusText: "正在读取睡眠数据...",
      goMoreResultText: "",
    });
    appendLog("读取GoMore睡眠数据...");
    wx.showLoading({ title: "读取中", mask: false });
    try {
      let modelCount = 0;
      const result = await requireSession().sdk.readGoMoreSleepData({
        onPacket: (event) => {
          appendLog(`GoMore睡眠数据包：${formatGoMoreSleepEvent(event)}`, "debug");
          this.setData({ goMoreStatusText: formatGoMoreSleepStatus(event, modelCount) });
        },
        onModel: () => {
          modelCount += 1;
          wx.showLoading({ title: `${modelCount}包`, mask: false });
        },
        onMalformedPacket: (error, rawHex) => {
          appendLog(`GoMore睡眠异常包：${error.message} Hex:${rawHex}`, "warning");
        },
      });
      wx.hideLoading();
      const message = formatGoMoreSleepResult(result.sleepModels);
      appendLog(`读取GoMore睡眠数据完成：${message}`);
      this.setData({
        goMoreStatusText: "读取完成",
        goMoreResultText: message,
      });
      wx.showToast({ title: message, icon: "none" });
    } catch (error) {
      wx.hideLoading();
      this.handleError("读取GoMore睡眠数据失败", error);
    } finally {
      this.setData({
        isBusy: false,
        goMoreSleepReading: false,
      });
      this.refreshStatus();
    }
  },

  // 创建云端 Token，成功后网络 SDK 会保存到小程序本地存储。
  async createNetworkToken() {
    const request = await this.showNetworkFieldDialog({
      title: "获取Token",
      description: "与原生 Demo 一致，分别填写 API Key 和用户标识。",
      fields: [
        { key: "apiKey", label: "API Key", value: "76d07e37bfe341b1a25c76c0e25f457a", placeholder: "请输入API Key" },
        { key: "userIdentifier", label: "用户标识", value: "jiandan@qq.com", placeholder: "请输入用户标识" },
      ],
    });
    if (!request || !request.apiKey || !request.userIdentifier) {
      return;
    }
    await this.runNetworkCommand("获取Token", async () => {
      const token = await getNetworkSDK().createToken(request.apiKey, request.userIdentifier);
      return `Token:${maskToken(token)}`;
    });
  },

  // 刷新当前 Token，原生逻辑为延长服务端有效期，不替换本地 Token。
  async refreshNetworkToken() {
    await this.runNetworkCommand("刷新Token", async () => {
      await getNetworkSDK().refreshToken();
      return "Token刷新成功";
    });
  },

  // 上传历史数据示例，先从戒指同步真实历史数据，再转换为原生模型字段上传。
  async uploadNetworkHistory() {
    const mac = this.getDefaultMac();
    if (!mac) {
      this.showToast("请先连接设备");
      return;
    }
    const mode = await this.showHistoryUploadModeDialog();
    if (!mode) {
      return;
    }
    const syncLabel = mode === "all" ? "上传前同步全部历史数据" : "上传前同步未上传历史数据";
    const result = await this.syncHistoryData(syncLabel, mode, { skipSuccessToast: true });
    if (!result) {
      return;
    }
    if (!this.networkCachedHistoryData.length) {
      this.showToast("无可上传历史数据");
      appendLog("上传历史数据取消：同步完成但没有可上传的历史数据。", "warning");
      return;
    }

    await this.runNetworkCommand("上传历史数据", async () => {
      await getNetworkSDK().uploadHistory(this.networkCachedHistoryData, mac);
      return `上传成功，MAC:${mac} 记录数:${this.networkCachedHistoryData.length}`;
    });
  },

  // 上传血压波形示例，waveData 推荐使用原生一致的五元组数组。
  async uploadNetworkBloodPressure() {
    await this.uploadNetworkWaveData("上传血压波形", "bloodPressure");
  },

  // 上传血糖波形示例，waveData 推荐使用原生一致的五元组数组。
  async uploadNetworkBloodGlucose() {
    await this.uploadNetworkWaveData("上传血糖波形", "bloodGlucose");
  },

  // 固件版本更新检查。
  async checkNetworkFirmwareUpdate() {
    const request = await this.showNetworkFieldDialog({
      title: "固件更新检查",
      description: "填写当前固件版本号，格式参考原生 Demo 示例。",
      fields: [
        { key: "version", label: "固件版本号", value: "7.3.4.2Z5X", placeholder: "示例: 1.1.1.1XZ1L" },
      ],
    });
    if (!request || !request.version) {
      return;
    }
    await this.runNetworkCommand("固件更新检查", async () => {
      const result = await getNetworkSDK().checkFirmwareUpdate(request.version);
      return formatFirmwareUpdateResult(result);
    });
  },

  // 查询固件版本历史列表，category 会自动转大写。
  async getNetworkFirmwareVersionList() {
    const request = await this.showNetworkFieldDialog({
      title: "固件版本列表",
      description: "填写固件分类 category，示例: Z2Y / Z3R / Z3N / Z47。",
      fields: [
        { key: "category", label: "查询参数 category", value: "Z2Y", placeholder: "请输入查询参数" },
      ],
    });
    if (!request || !request.category) {
      return;
    }
    await this.runNetworkCommand("固件版本列表", async () => {
      const result = await getNetworkSDK().getFirmwareVersionList(request.category);
      return `共${result.length}条 ${formatShortJson(result)}`;
    });
  },

  // 下载指定固件文件到小程序本地用户目录。
  async downloadNetworkFirmware() {
    const defaultPath = `${wx.env.USER_DATA_PATH}/firmware`;
    const request = await this.showNetworkFieldDialog({
      title: "下载固件文件",
      description: `与原生 Demo 一致只配置下载地址和文件名，保存目录由 Demo 使用小程序用户目录：${defaultPath}`,
      fields: [
        { key: "url", label: "固件下载地址", value: "", placeholder: "请输入固件下载地址" },
        { key: "fileName", label: "固件文件名", value: "firmware.bin", placeholder: "请输入固件文件名" },
      ],
    });
    if (!request || !request.url || !request.fileName) {
      return;
    }
    await this.runNetworkCommand("下载固件文件", async () => {
      const path = await getNetworkSDK().downloadFirmware(request.url, request.fileName, defaultPath, (progress) => {
        const percent = Math.round(progress * 100);
        this.setData({ networkStatusText: `下载中 ${percent}%` });
        appendLog(`固件下载进度：${percent}%`, "debug");
      });
      return `保存路径:${path}`;
    });
  },

  // 获取用户活动时间线，入参为秒级时间戳。
  async getNetworkTimeline() {
    const request = await this.showNetworkTimelineDialog();
    if (!request) {
      return;
    }
    await this.runNetworkCommand("获取时间线", async () => {
      const result = await getNetworkSDK().getTimeline(Number(request.startTime), Number(request.endTime));
      return `共${result.length}条 ${formatShortJson(result)}`;
    });
  },

  // 获取用户最新一条历史数据。
  async loadNetworkLatestHistory() {
    await this.runNetworkCommand("最新历史数据", async () => {
      const result = await getNetworkSDK().loadUserLatestHistory();
      return result ? formatShortJson(result) : "暂无历史数据";
    });
  },

  // 网络波形上传共用逻辑。
  async uploadNetworkWaveData(label, kind) {
    const mac = this.getDefaultMac();
    if (!mac) {
      this.showToast("请先连接设备");
      return;
    }
    if (!this.networkCachedWaveData.length) {
      this.showToast("暂无波形数据");
      appendLog(`${label}取消：当前没有可上传的波形缓存。`, "warning");
      return;
    }
    await this.runNetworkCommand(label, async () => {
      const sdk = getNetworkSDK();
      if (kind === "bloodPressure") {
        const result = await sdk.uploadBloodPressureData(mac, this.networkCachedWaveData);
        return `高压:${result.systolic} 低压:${result.diastolic}`;
      }
      const glucose = await sdk.uploadBloodGlucoseData(mac, this.networkCachedWaveData);
      return `血糖:${glucose} mmol/L`;
    });
  },

  // 切换网络服务器区域，保持与原生 Demo 的国内/海外入口一致。
  switchNetworkRegion(region) {
    setNetworkRegion(region);
    const regionText = formatNetworkRegion(getNetworkRegion());
    this.setData({
      networkRegionText: regionText,
      networkStatusText: `当前服务器：${regionText}`,
      networkResultText: "",
    });
    appendLog(`网络服务器已切换：${regionText}`);
    wx.showToast({ title: regionText, icon: "none" });
  },

  // 统一包裹网络请求，避免重复的 loading、日志和错误处理。
  async runNetworkCommand(label, command) {
    if (this.data.networkBusy) {
      return;
    }

    this.setData({
      networkBusy: true,
      networkStatusText: `${label}...`,
      networkResultText: "",
    });
    appendLog(`${label}...`);
    wx.showLoading({ title: "请求中", mask: false });
    try {
      const message = await command();
      wx.hideLoading();
      appendLog(`${label}完成：${message}`);
      this.setData({
        networkStatusText: "请求完成",
        networkResultText: message,
      });
      wx.showToast({ title: "请求完成", icon: "none" });
    } catch (error) {
      wx.hideLoading();
      this.handleError(`${label}失败`, error);
      this.setData({
        networkStatusText: "请求失败",
        networkResultText: "",
      });
    } finally {
      this.setData({ networkBusy: false });
    }
  },

  // 优先使用已连接设备 MAC，未连接时返回空字符串让用户自行填写。
  getDefaultMac() {
    const snapshot = getStatusSnapshot();
    return snapshot.connectedDeviceInfo && snapshot.connectedDeviceInfo.mac ? snapshot.connectedDeviceInfo.mac : "";
  },

  // 打开网络字段配置弹窗，替代移动端不便编辑的 JSON 输入。
  showNetworkFieldDialog(options) {
    return new Promise((resolve) => {
      this.networkDialogResolver = resolve;
      this.setData({
        networkDialogVisible: true,
        networkDialogMode: "fields",
        networkDialogTitle: options.title,
        networkDialogDescription: options.description || "",
        networkDialogFields: options.fields || [],
      });
    });
  },

  // 打开时间线查询弹窗，使用日期和时间选择器生成秒级时间戳。
  showNetworkTimelineDialog() {
    const range = createDefaultTimelineRange();
    return new Promise((resolve) => {
      this.networkDialogResolver = resolve;
      this.setData({
        networkDialogVisible: true,
        networkDialogMode: "timeline",
        networkDialogTitle: "获取时间线",
        networkDialogDescription: "选择开始和结束时间，查询用户活动时间线数据。",
        networkTimelineStartDate: range.startDate,
        networkTimelineStartTime: range.startTime,
        networkTimelineEndDate: range.endDate,
        networkTimelineEndTime: range.endTime,
        networkTimelineRangeText: formatTimelineRangeText(range),
      });
    });
  },

  // 打开历史上传范围选择弹窗，用户确认后再执行蓝牙同步。
  showHistoryUploadModeDialog() {
    return new Promise((resolve) => {
      this.networkDialogResolver = resolve;
      this.setData({
        networkDialogVisible: true,
        networkDialogMode: "historyUpload",
        networkDialogTitle: "上传历史数据",
        networkDialogDescription: "请选择上传前需要从戒指同步的数据范围，同步完成后会自动上传到云端。",
        networkHistoryUploadMode: "",
      });
    });
  },

  // 更新普通字段配置项。
  onNetworkDialogInput(event) {
    const key = event.currentTarget.dataset.key;
    const value = event.detail.value;
    const fields = this.data.networkDialogFields.map((field) => (
      field.key === key ? Object.assign({}, field, { value }) : field
    ));
    this.setData({ networkDialogFields: fields });
  },

  // 更新时间线日期或时间选择值。
  onNetworkTimelinePickerChange(event) {
    const field = event.currentTarget.dataset.field;
    const value = event.detail.value;
    this.setData({ [field]: value }, () => {
      this.setData({
        networkTimelineRangeText: formatTimelineRangeText({
          startDate: this.data.networkTimelineStartDate,
          startTime: this.data.networkTimelineStartTime,
          endDate: this.data.networkTimelineEndDate,
          endTime: this.data.networkTimelineEndTime,
        }),
      });
    });
  },

  // 关闭网络配置弹窗，并通知等待中的命令用户已取消。
  closeNetworkDialog() {
    const resolver = this.networkDialogResolver;
    this.networkDialogResolver = null;
    this.setData({ networkDialogVisible: false });
    resolver && resolver(null);
  },

  // 确认网络配置弹窗，把字段值转换为 SDK 方法需要的参数。
  confirmNetworkDialog() {
    const resolver = this.networkDialogResolver;
    this.networkDialogResolver = null;
    if (this.data.networkDialogMode === "historyUpload") {
      const mode = this.data.networkHistoryUploadMode;
      if (!mode) {
        this.showToast("请选择同步范围");
        this.networkDialogResolver = resolver;
        return;
      }
      this.setData({ networkDialogVisible: false });
      resolver && resolver(mode);
      return;
    }
    if (this.data.networkDialogMode === "timeline") {
      const payload = buildTimelinePayload({
        startDate: this.data.networkTimelineStartDate,
        startTime: this.data.networkTimelineStartTime,
        endDate: this.data.networkTimelineEndDate,
        endTime: this.data.networkTimelineEndTime,
      });
      if (!payload) {
        this.showToast("时间范围无效");
        this.networkDialogResolver = resolver;
        return;
      }
      this.setData({ networkDialogVisible: false });
      resolver && resolver(payload);
      return;
    }

    const payload = {};
    this.data.networkDialogFields.forEach((field) => {
      payload[field.key] = String(field.value || "").trim();
    });
    this.setData({ networkDialogVisible: false });
    resolver && resolver(payload);
  },

  // 阻止弹窗蒙层滚动穿透。
  noop() {},

  // 选择上传前要同步的历史数据范围。
  onHistoryUploadModeTap(event) {
    this.setData({ networkHistoryUploadMode: event.currentTarget.dataset.mode });
  },

  // 主动测量温度，测量中状态通过 progress 回调展示。
  async measureTemperature() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy) {
      return;
    }

    this.setData({ isBusy: true });
    appendLog("温度读取...");
    wx.showLoading({ title: "温度测量中", mask: false });
    try {
      const result = await requireSession().sdk.measureTemperature({
        onProgress: (progress) => {
          appendLog(`温度测量中：${formatTemperatureResponse(progress)}`, "debug");
          wx.showLoading({
            title: formatTemperatureLoadingTitle(progress),
            mask: false,
          });
        },
      });
      wx.hideLoading();
      const message = `温度：${formatTemperatureCelsius(result)}`;
      appendLog(`温度读取完成：${formatTemperatureResponse(result)}`);
      wx.showToast({ title: message, icon: "none" });
    } catch (error) {
      wx.hideLoading();
      this.handleError("温度读取失败", error);
    } finally {
      this.setData({ isBusy: false });
      this.refreshStatus();
    }
  },

  // 开始主动测量心率，过程数据通过 SDK 回调进入日志页。
  async startHeartRate() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy || this.data.heartRateMeasuring) {
      return;
    }

    this.setData({
      heartRateMeasuring: true,
      heartRateStatusText: "正在启动...",
      heartRateResultText: "",
    });
    appendLog("开始心率测量...");
    wx.showToast({ title: "心率测量已开始", icon: "none" });
    try {
      const result = await requireSession().sdk.startHeartRate({
        request: {
          collectTime: 30,
          collectFrequency: 50,
          waveformConfig: 1,
          progressConfig: 1,
          intervalConfig: 1,
        },
        onStatusChanged: (status, event) => {
          appendLog(`心率状态变化：${status} ${formatHeartRateResult(event)}`, "debug");
          this.setData({ heartRateStatusText: formatHeartRateStatusText(event) });
        },
        onProgress: (event) => {
          appendLog(`心率测量进度：${formatHeartRateProgress(event)}`, "debug");
          this.setData({ heartRateStatusText: formatHeartRateStatusText(event) });
        },
        onMeasureValue: (event) => {
          appendLog(`心率测量值：${formatHeartRateResult(event)}`, "debug");
          this.setData({ heartRateStatusText: formatHeartRateStatusText(event) });
        },
        onWaveform: (event) => {
          appendLog(`心率波形：${formatHeartRateWaveformSummary(event)}`, "debug");
          appendLog(`心率波形列表：${formatHeartRateWaveformSamples(event)}`, "debug");
        },
        onRRInterval: (event) => {
          appendLog(`心率 RR 间期：${formatHeartRateRRInterval(event)}`, "debug");
        },
      });
      appendLog(`心率测量完成：${formatHeartRateEvent(result)}`);
      this.setData({
        heartRateStatusText: "测量完成",
        heartRateResultText: formatHeartRateResultText(result),
      });
      wx.showToast({ title: formatHeartRateToast(result), icon: "none" });
    } catch (error) {
      if (error && error.status === "stopped") {
        appendLog("心率测量：已停止");
        this.setData({
          heartRateStatusText: "已停止",
          heartRateResultText: "",
        });
        this.showToast("已停止心率测量");
        return;
      }
      this.handleError("心率测量失败", error);
    } finally {
      this.setData({ heartRateMeasuring: false });
      this.refreshStatus();
    }
  },

  // 停止当前心率测量，适合测量时间较长时手动结束。
  async stopHeartRate() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }

    appendLog("停止心率测量...");
    this.setData({ heartRateStatusText: "正在停止..." });
    try {
      await requireSession().sdk.stopHeartRate();
      appendLog("停止心率测量：已发送停止指令");
      this.showToast("已停止心率测量");
    } catch (error) {
      this.handleError("停止心率测量失败", error);
    } finally {
      this.setData({
        isBusy: false,
        heartRateMeasuring: false,
        heartRateStatusText: "已停止",
        heartRateResultText: "",
      });
      this.refreshStatus();
    }
  },

  // 开始主动测量血氧，状态、进度和波形等数据写入日志页。
  async startBloodOxygen() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy || this.data.heartRateMeasuring || this.data.bloodOxygenMeasuring) {
      return;
    }

    this.setData({
      bloodOxygenMeasuring: true,
      bloodOxygenStatusText: "正在启动...",
      bloodOxygenResultText: "",
    });
    appendLog("开始血氧测量...");
    wx.showToast({ title: "血氧测量已开始", icon: "none" });
    try {
      const result = await requireSession().sdk.startBloodOxygen({
        request: {
          collectTime: 30,
          collectFrequency: 50,
          waveformConfig: 1,
          progressConfig: 1,
        },
        onStatusChanged: (status, event) => {
          appendLog(`血氧状态变化：${status} ${formatBloodOxygenResult(event)}`, "debug");
          this.setData({ bloodOxygenStatusText: formatBloodOxygenStatusText(event) });
        },
        onProgress: (event) => {
          appendLog(`血氧测量进度：${formatBloodOxygenProgress(event)}`, "debug");
          this.setData({ bloodOxygenStatusText: formatBloodOxygenStatusText(event) });
        },
        onMeasureValue: (event) => {
          appendLog(`血氧测量值：${formatBloodOxygenResult(event)}`, "debug");
          this.setData({ bloodOxygenStatusText: formatBloodOxygenStatusText(event) });
        },
        onWaveform: (event) => {
          appendLog(`血氧波形：${formatBloodOxygenWaveformSummary(event)}`, "debug");
          appendLog(`血氧波形列表：${formatBloodOxygenWaveformSamples(event)}`, "debug");
          this.networkCachedWaveData = mergeNetworkWaveData(this.networkCachedWaveData, event.samples);
        },
        onPerfusionRate: (event) => {
          appendLog(`血氧灌注率：${formatBloodOxygenPerfusionRate(event)}`, "debug");
        },
        onBloodPressure: (event) => {
          appendLog(`血氧血压：${formatBloodOxygenBloodPressure(event)}`, "debug");
        },
      });
      appendLog(`血氧测量完成：${formatBloodOxygenEvent(result)}`);
      this.setData({
        bloodOxygenStatusText: "测量完成",
        bloodOxygenResultText: formatBloodOxygenResultText(result),
      });
      wx.showToast({ title: formatBloodOxygenToast(result), icon: "none" });
    } catch (error) {
      if (error && error.status === "stopped") {
        appendLog("血氧测量：已停止");
        this.setData({
          bloodOxygenStatusText: "已停止",
          bloodOxygenResultText: "",
        });
        this.showToast("已停止血氧测量");
        return;
      }
      this.handleError("血氧测量失败", error);
    } finally {
      this.setData({ bloodOxygenMeasuring: false });
      this.refreshStatus();
    }
  },

  // 停止当前血氧测量，部分固件可能不支持该停止指令。
  async stopBloodOxygen() {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }

    appendLog("停止血氧测量...");
    appendLog("注意：iOS 原生 SDK 注释提示部分固件可能不支持停止血氧指令，甚至可能导致设备重启。", "debug");
    this.setData({ bloodOxygenStatusText: "正在停止..." });
    try {
      await requireSession().sdk.stopBloodOxygen();
      appendLog("停止血氧测量：已发送停止指令");
      this.showToast("已停止血氧测量");
    } catch (error) {
      this.handleError("停止血氧测量失败", error);
    } finally {
      this.setData({
        isBusy: false,
        bloodOxygenMeasuring: false,
        bloodOxygenStatusText: "已停止",
        bloodOxygenResultText: "",
      });
      this.refreshStatus();
    }
  },

  // 统一包裹 SDK 命令执行，避免多个指令并发写入导致状态混乱。
  async runSdkCommand(label, command) {
    if (!this.data.connected) {
      this.showToast("请先连接设备");
      return;
    }
    if (this.data.isBusy) {
      return;
    }

    this.setData({ isBusy: true });
    appendLog(`${label}...`);
    try {
      appendLog(`${label}：${await command()}`);
    } catch (error) {
      this.handleError(`${label}失败`, error);
    } finally {
      this.setData({ isBusy: false });
      this.refreshStatus();
    }
  },

  // 从共享状态刷新首页悬浮入口和按钮状态。
  refreshStatus() {
    this.setData(getStatusSnapshot());
  },

  // 统一展示错误，便于真机调试时看到具体微信 BLE 错误码。
  handleError(prefix, error) {
    const message = appendError(prefix, error);
    const readableMessage = formatBleErrorMessage(error, message);
    wx.showModal({
      title: prefix,
      content: readableMessage,
      showCancel: false,
    });
  },

  showToast(title) {
    wx.showToast({ title, icon: "none" });
  },

  // 记录悬浮入口拖动起点。
  onFloatingTouchStart(event) {
    const touch = event.touches[0];
    this.floatingTouchContext = {
      startX: touch.clientX,
      startY: touch.clientY,
      originX: this.data.floatingX,
      originY: this.data.floatingY,
      moved: false,
    };
  },

  // 拖动悬浮入口，并限制在可视区域内。
  onFloatingTouchMove(event) {
    if (!this.floatingTouchContext) {
      return;
    }
    const touch = event.touches[0];
    const deltaX = touch.clientX - this.floatingTouchContext.startX;
    const deltaY = touch.clientY - this.floatingTouchContext.startY;
    if (Math.abs(deltaX) > 3 || Math.abs(deltaY) > 3) {
      this.floatingTouchContext.moved = true;
    }
    const bounded = this.getBoundedFloatingPosition(
      this.floatingTouchContext.originX + deltaX,
      this.floatingTouchContext.originY + deltaY,
    );
    this.setData({ floatingX: bounded.x, floatingY: bounded.y });
  },

  // 拖动结束后吸附到左右边缘。
  onFloatingTouchEnd() {
    if (!this.floatingTouchContext) {
      return;
    }
    const moved = this.floatingTouchContext.moved;

    if (!moved) {
      this.floatingTouchContext = null;
      this.openLogPage();
      return;
    }

    const info = wx.getSystemInfoSync();
    const targetX = this.data.floatingX < info.windowWidth / 2 ? 10 : info.windowWidth - FLOATING_ENTRY_WIDTH - 10;
    const bounded = this.getBoundedFloatingPosition(targetX, this.data.floatingY);
    this.setData({ floatingX: bounded.x, floatingY: bounded.y });
    this.floatingTouchContext = null;
    this.suppressFloatingTap = true;
    setTimeout(() => {
      this.suppressFloatingTap = false;
    }, 120);
  },

  // 计算悬浮入口在窗口内的安全坐标。
  getBoundedFloatingPosition(x, y) {
    const info = wx.getSystemInfoSync();
    return {
      x: Math.min(Math.max(8, x), Math.max(8, info.windowWidth - FLOATING_ENTRY_WIDTH - 8)),
      y: Math.min(Math.max(20, y), Math.max(20, info.windowHeight - FLOATING_ENTRY_HEIGHT - 20)),
    };
  },
});

function formatTemperatureLoadingTitle(response) {
  if (typeof response.temperatureCelsius === "number") {
    return `测量中 ${formatTemperatureCelsius(response)}`;
  }
  return "温度测量中";
}

function formatTemperatureCelsius(response) {
  if (typeof response.temperatureCelsius !== "number") {
    return "--℃";
  }
  return `${response.temperatureCelsius.toFixed(2)}℃`;
}

function formatTemperatureResponse(response) {
  const raw = response.temperatureRaw === undefined ? "--" : response.temperatureRaw;
  return `状态:${response.status} 原始值:${raw} 温度:${formatTemperatureCelsius(response)}`;
}

function formatHeartRateStatusText(event) {
  if (event.type === "progress") {
    return `测量中 ${event.progress}%`;
  }
  if (typeof event.progress === "number") {
    return `测量中 ${event.progress}%`;
  }
  if (event.type === "result") {
    const heartRate = event.heartRate === undefined ? "--" : event.heartRate;
    return `状态:${event.status} 心率:${heartRate}`;
  }
  return "心率测量中";
}

function formatHeartRateToast(event) {
  if (event.type === "result" && typeof event.heartRate === "number") {
    return `心率：${event.heartRate}`;
  }
  return "心率测量完成";
}

function formatHeartRateResultText(event) {
  if (event.type !== "result") {
    return formatHeartRateEvent(event);
  }
  const heartRate = event.heartRate === undefined ? "--" : `${event.heartRate} 次/分`;
  const hrv = event.heartRateVariability === undefined ? "--" : event.heartRateVariability;
  const stress = event.stressIndex === undefined ? "--" : event.stressIndex;
  const temperature = typeof event.temperatureCelsius === "number" ? `${event.temperatureCelsius.toFixed(2)}℃` : "--";
  return `心率:${heartRate}  HRV:${hrv}  压力:${stress}  温度:${temperature}`;
}

function formatHeartRateEvent(event) {
  if (event.type === "result") {
    return formatHeartRateResult(event);
  }
  if (event.type === "progress") {
    return formatHeartRateProgress(event);
  }
  if (event.type === "waveform") {
    return `${formatHeartRateWaveformSummary(event)} ${formatHeartRateWaveformSamples(event)}`;
  }
  return formatHeartRateRRInterval(event);
}

function formatHeartRateProgress(event) {
  const progress = typeof event.progress === "number" ? `${event.progress}%` : "--";
  return `进度:${progress}`;
}

function formatHeartRateResult(event) {
  const heartRate = event.heartRate === undefined ? "--" : event.heartRate;
  const hrv = event.heartRateVariability === undefined ? "--" : event.heartRateVariability;
  const stress = event.stressIndex === undefined ? "--" : event.stressIndex;
  const temperature = typeof event.temperatureCelsius === "number" ? `${event.temperatureCelsius.toFixed(2)}℃` : "--";
  const progress = event.progress === undefined ? "--" : `${event.progress}%`;
  return `状态:${event.status} 心率:${heartRate} HRV:${hrv} 压力:${stress} 温度:${temperature} 进度:${progress}`;
}

function formatHeartRateWaveformSummary(event) {
  return `序号:${event.sequence} 数量:${event.count} 实际样本:${event.samples.length}`;
}

function formatHeartRateWaveformSamples(event) {
  if (!event.samples.length) {
    return "[]";
  }
  return event.samples.map((sample, index) => formatHeartRateWaveformSample(sample, index)).join(" | ");
}

function formatHeartRateWaveformSample(sample, index) {
  const prefix = `#${index + 1}`;
  return `${prefix} green:${formatOptionalNumber(sample.green)} x:${sample.x} y:${sample.y} z:${sample.z}`;
}

function formatOptionalNumber(value) {
  return value === undefined ? "--" : value;
}

function formatHeartRateRRInterval(event) {
  const preview = event.intervalsMs.slice(0, 5).join(",");
  return `序号:${event.sequence} 数量:${event.count} 间期:${preview}${event.intervalsMs.length > 5 ? "..." : ""}`;
}

function formatBloodOxygenStatusText(event) {
  if (event.type === "progress") {
    return `测量中 ${event.progress}%`;
  }
  if (event.type === "result") {
    const bloodOxygen = event.bloodOxygen === undefined ? "--" : `${event.bloodOxygen}%`;
    const heartRate = event.heartRate === undefined ? "--" : event.heartRate;
    return `状态:${event.status} 血氧:${bloodOxygen} 心率:${heartRate}`;
  }
  return "血氧测量中";
}

function formatBloodOxygenToast(event) {
  if (event.type === "result" && typeof event.bloodOxygen === "number") {
    return `血氧：${event.bloodOxygen}%`;
  }
  return "血氧测量完成";
}

function formatBloodOxygenResultText(event) {
  if (event.type !== "result") {
    return formatBloodOxygenEvent(event);
  }
  const bloodOxygen = event.bloodOxygen === undefined ? "--" : `${event.bloodOxygen}%`;
  const heartRate = event.heartRate === undefined ? "--" : `${event.heartRate} 次/分`;
  const temperature = typeof event.temperatureCelsius === "number" ? `${event.temperatureCelsius.toFixed(2)}℃` : "--";
  return `血氧:${bloodOxygen}  心率:${heartRate}  温度:${temperature}`;
}

function formatBloodOxygenEvent(event) {
  if (event.type === "result") {
    return formatBloodOxygenResult(event);
  }
  if (event.type === "progress") {
    return formatBloodOxygenProgress(event);
  }
  if (event.type === "waveform") {
    return `${formatBloodOxygenWaveformSummary(event)} ${formatBloodOxygenWaveformSamples(event)}`;
  }
  if (event.type === "perfusion_rate") {
    return formatBloodOxygenPerfusionRate(event);
  }
  return formatBloodOxygenBloodPressure(event);
}

function formatBloodOxygenProgress(event) {
  const progress = typeof event.progress === "number" ? `${event.progress}%` : "--";
  return `进度:${progress}`;
}

function formatBloodOxygenResult(event) {
  const bloodOxygen = event.bloodOxygen === undefined ? "--" : `${event.bloodOxygen}%`;
  const heartRate = event.heartRate === undefined ? "--" : event.heartRate;
  const temperature = typeof event.temperatureCelsius === "number" ? `${event.temperatureCelsius.toFixed(2)}℃` : "--";
  return `状态:${event.status} 血氧:${bloodOxygen} 心率:${heartRate} 温度:${temperature}`;
}

function formatBloodOxygenWaveformSummary(event) {
  return `序号:${event.sequence} 数量:${event.count} 实际样本:${event.samples.length}`;
}

function formatBloodOxygenWaveformSamples(event) {
  if (!event.samples.length) {
    return "[]";
  }
  return event.samples.map((sample, index) => formatBloodOxygenWaveformSample(sample, index)).join(" | ");
}

function formatBloodOxygenWaveformSample(sample, index) {
  const prefix = `#${index + 1}`;
  return `${prefix} red:${sample.red} infrared:${sample.infrared} x:${sample.x} y:${sample.y} z:${sample.z}`;
}

function formatBloodOxygenPerfusionRate(event) {
  return `灌注率:${event.perfusionRate} 保留字段:${event.reserved.join(",")}`;
}

function formatBloodOxygenBloodPressure(event) {
  return `舒张压:${event.diastolicPressure} 收缩压:${event.systolicPressure}`;
}

function mergeNetworkWaveData(existingWaveData, samples) {
  const nextItems = (samples || []).map((sample) => [
    Number(sample.red || 0),
    Number(sample.infrared || 0),
    Number(sample.x || 0),
    Number(sample.y || 0),
    Number(sample.z || 0),
  ]);
  if (!nextItems.length) {
    return existingWaveData;
  }
  return existingWaveData.concat(nextItems).slice(-2000);
}

function formatNetworkRegion(region) {
  return region === "overseas" ? "海外服务器" : "国内服务器";
}

function padNumber(value) {
  return String(value).padStart(2, "0");
}

function formatDateValue(date) {
  return `${date.getFullYear()}-${padNumber(date.getMonth() + 1)}-${padNumber(date.getDate())}`;
}

function formatTimeValue(date) {
  return `${padNumber(date.getHours())}:${padNumber(date.getMinutes())}`;
}

function createDefaultTimelineRange() {
  const end = new Date();
  const start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 6, 0, 0, 0);
  return {
    startDate: formatDateValue(start),
    startTime: formatTimeValue(start),
    endDate: formatDateValue(end),
    endTime: formatTimeValue(end),
  };
}

function buildTimelinePayload(range) {
  const startMs = Date.parse(`${range.startDate}T${range.startTime}:00`);
  const endMs = Date.parse(`${range.endDate}T${range.endTime}:00`);
  if (!Number.isFinite(startMs) || !Number.isFinite(endMs) || endMs < startMs) {
    return null;
  }
  return {
    startTime: Math.floor(startMs / 1000),
    endTime: Math.floor(endMs / 1000),
  };
}

function formatTimelineRangeText(range) {
  const payload = buildTimelinePayload(range);
  if (!payload) {
    return "时间范围无效（结束时间不能早于开始时间）";
  }
  const durationHours = Math.max(0, Math.round((payload.endTime - payload.startTime) / 3600));
  const days = Math.floor(durationHours / 24);
  const hours = durationHours % 24;
  const durationText = days > 0 ? `${days}天${hours}小时` : `${hours}小时`;
  return `查询范围：${range.startDate} ${range.startTime} 至 ${range.endDate} ${range.endTime}，约 ${durationText}`;
}

function formatHistoryStatus(status, event) {
  if (status === "no_data") {
    return "无历史数据";
  }
  if (status === "completed") {
    return `同步完成 ${event.sequence}/${event.totalNumber}`;
  }
  if (status === "error") {
    return event.message || "同步出错";
  }
  return `同步中 ${event.sequence}/${event.totalNumber} (${event.progress}%)`;
}

function formatHistoryStatusText(status, event) {
  if (status === "no_data") {
    return "无历史数据";
  }
  if (status === "completed") {
    return "同步完成";
  }
  if (status === "error") {
    return event.message || "同步失败";
  }
  return `同步中 ${event.progress}%`;
}

function formatHistorySyncResult(result) {
  if (result.status === "no_data") {
    return "无历史数据";
  }
  return `共 ${result.records.length} 条记录`;
}

function formatAppCompositeResult(result) {
  const deviceInfo = result.deviceInfo ? formatAppCompositeDeviceInfo(result.deviceInfo) : "未收到设备信息";
  const finalEvent = result.finalEvent && result.finalEvent.type === "history" ? result.finalEvent.history : null;
  const historyText = finalEvent ? formatHistorySyncResult({
    status: finalEvent.status,
    records: result.records || [],
  }) : `历史数据 ${result.records ? result.records.length : 0} 条`;
  return `${deviceInfo}；${historyText}`;
}

function formatAppCompositeDeviceInfo(deviceInfo) {
  const hidText = deviceInfo.hidSupported ? "HID:支持" : "HID:不支持";
  const fileSystem = boolText(deviceInfo.features && deviceInfo.features.fileSystem);
  return [
    `固件:${deviceInfo.firmwareVersion || "--"}`,
    `硬件:${deviceInfo.hardwareVersion || "--"}`,
    `电量:${formatOptionalNumber(deviceInfo.batteryLevel)}%`,
    `步数:${formatOptionalNumber(deviceInfo.stepCount)}`,
    `采集周期:${formatOptionalNumber(deviceInfo.collectInterval)}s`,
    hidText,
    `文件系统:${fileSystem}`,
  ].join(" ");
}

function formatAppCompositeDeviceInfoDetail(deviceInfo) {
  return [
    formatAppCompositeBaseInfo(deviceInfo),
    formatAppCompositeFeatureInfo(deviceInfo.features || {}),
    formatAppCompositeHidInfo(deviceInfo),
    formatAppCompositeGoMoreInfo(deviceInfo.goMore),
    `尾部Hex:${deviceInfo.extraHex || "无"}`,
  ].join(" | ");
}

function formatAppCompositeBaseInfo(deviceInfo) {
  const selfInspection = Number(deviceInfo.selfInspectionFlag || 0).toString(16).padStart(4, "0").toUpperCase();
  return [
    `固件:${deviceInfo.firmwareVersion || "--"}`,
    `硬件:${deviceInfo.hardwareVersion || "--"}`,
    `电量:${formatOptionalNumber(deviceInfo.batteryLevel)}%`,
    `充电状态:${formatOptionalNumber(deviceInfo.chargingState)}`,
    `采集周期:${formatOptionalNumber(deviceInfo.collectInterval)}s`,
    `步数:${formatOptionalNumber(deviceInfo.stepCount)}`,
    `自检标志:0x${selfInspection}`,
  ].join(" ");
}

function formatAppCompositeFeatureInfo(features) {
  const items = [
    ["心率曲线", features.heartRateCurve],
    ["血氧曲线", features.bloodOxygenCurve],
    ["HRV曲线", features.heartRateVariabilityCurve],
    ["压力曲线", features.stressCurve],
    ["温度曲线", features.temperatureCurve],
    ["女性健康", features.femaleHealth],
    ["震动闹钟", features.vibrationAlarm],
    ["ECG", features.ecg],
    ["麦克风", features.microphone],
    ["运动模式", features.sportMode],
    ["血压测量", features.bloodPressureMeasurement],
    ["血糖测量", features.bloodGlucoseMeasurement],
    ["文件系统", features.fileSystem],
    ["GoMore睡眠", features.goMoreSleepAlgorithm],
    ["血压曲线", features.bloodPressureCurve],
    ["HID服务", features.hidServiceEnabled],
  ];
  return `能力:${items.map(([name, value]) => `${name}:${boolText(value)}`).join(" ")}`;
}

function formatAppCompositeHidInfo(deviceInfo) {
  if (!deviceInfo.hidSupported || !deviceInfo.hid) {
    return "HID:不支持";
  }
  const hid = deviceInfo.hid;
  return [
    "HID:支持",
    `拍照:${boolText(hid.photo)}`,
    `短视频:${boolText(hid.shortVideo)}`,
    `音乐:${boolText(hid.music)}`,
    `PPT:${boolText(hid.ppt)}`,
    `音频上传:${boolText(hid.audioUpload)}`,
    `捏合拍照:${boolText(hid.pinchPhoto)}`,
    `捏合短视频:${boolText(hid.pinchShortVideo)}`,
    `捏合音乐:${boolText(hid.pinchMusic)}`,
    `捏合PPT:${boolText(hid.pinchPpt)}`,
    `打响指拍照:${boolText(hid.snapPhoto)}`,
    `触摸模式:${formatOptionalNumber(hid.touchHidMode)}`,
    `手势模式:${formatOptionalNumber(hid.gestureHidMode)}`,
    `系统类型:${formatOptionalNumber(hid.systemType)}`,
  ].join(" ");
}

function formatAppCompositeGoMoreInfo(goMore) {
  if (!goMore) {
    return "GoMore:无";
  }
  return [
    "GoMore:",
    `年龄:${formatOptionalNumber(goMore.age)}`,
    `性别:${formatGender(goMore.gender)}`,
    `身高:${formatOptionalNumber(goMore.height)}`,
    `体重:${formatOptionalNumber(goMore.weight)}`,
    `最大心率:${formatOptionalNumber(goMore.maxHeartRate)}`,
    `静息心率:${formatOptionalNumber(goMore.restingHeartRate)}`,
    `最大摄氧量:${formatOptionalNumber(goMore.maxOxygenUptake)}`,
    `授权:${formatGoMoreAuth(goMore.authStatus)}`,
  ].join(" ");
}

function boolText(value) {
  if (value === undefined) {
    return "--";
  }
  return value ? "支持" : "不支持";
}

function formatGender(value) {
  if (value === 0) {
    return "女";
  }
  if (value === 1) {
    return "男";
  }
  return formatOptionalNumber(value);
}

function formatGoMoreAuth(value) {
  if (value === 0) {
    return "已授权";
  }
  if (value === 1) {
    return "未授权";
  }
  return formatOptionalNumber(value);
}

function formatGoMoreAuthStatus(result) {
  return [
    `授权:${result.isAuthorized ? "已授权" : "未授权"}`,
    `状态:${formatOptionalNumber(result.authStatus)}`,
    `MCU:${result.mcuIdHexString || "--"}`,
    `原始MCU:${result.rawMcuIdHex || "--"}`,
  ].join(" ");
}

function formatGoMorePersonalInformation(info) {
  return [
    `年龄:${formatOptionalNumber(info.age)}`,
    `性别:${formatGender(info.gender)}`,
    `身高:${formatOptionalNumber(info.height)}cm`,
    `体重:${formatOptionalNumber(info.weight)}kg`,
    `最大心率:${formatOptionalNumber(info.maxHeartRate)}`,
    `常态心率:${formatOptionalNumber(info.normalHeartRate)}`,
    `最大摄氧量:${formatOptionalNumber(info.maxOxygenUptake)}`,
  ].join(" ");
}

function formatGoMoreSleepEvent(event) {
  if (event.type === "overview") {
    return formatGoMoreSleepOverview(event);
  }
  if (event.type === "stages") {
    return formatGoMoreSleepStages(event);
  }
  if (event.type === "no_data") {
    return "无睡眠数据";
  }
  return "传输结束";
}

function formatGoMoreSleepOverview(event) {
  const range = `${formatHistoryTime(event.startTs * 1000)} ~ ${formatHistoryTime(event.endTs * 1000)}`;
  const sleepType = event.sleepType === 1 ? "长睡" : event.sleepType === 2 ? "短睡" : event.sleepType;
  return [
    "总览",
    `时间:${range}`,
    `类型:${sleepType}`,
    `评分:${formatOptionalNumber(event.score)}`,
    `睡眠:${formatOptionalNumber(event.sleepPeriod)}分钟`,
    `总睡眠:${formatOptionalNumber(event.totalSleepTime)}分钟`,
    `深睡:${formatOptionalNumber(event.deepNumMinutes)}分钟`,
    `浅睡:${formatOptionalNumber(event.lightNumMinutes)}分钟`,
    `REM:${formatOptionalNumber(event.remNumMinutes)}分钟`,
    `清醒:${formatOptionalNumber(event.wakeNumMinutes)}分钟`,
    `SRI:${formatOptionalNumber(event.sri)}`,
    `RMSSD:${formatFloat(event.nightlyRmssd)}`,
  ].join(" ");
}

function formatGoMoreSleepStages(event) {
  const preview = event.stages.slice(0, 20).join(",");
  return [
    "分期",
    `包:${event.packNo + 1}/${event.packNum}`,
    `数量:${event.stageNum}`,
    `时间:${formatHistoryTime(event.startTs * 1000)} ~ ${formatHistoryTime(event.endTs * 1000)}`,
    `数据:[${preview}${event.stages.length > 20 ? "..." : ""}]`,
  ].join(" ");
}

function formatGoMoreSleepStatus(event, modelCount) {
  if (event.type === "no_data") {
    return modelCount > 0 ? `已读取 ${modelCount} 包，继续等待结束包` : "无睡眠数据";
  }
  if (event.type === "end") {
    return "传输结束";
  }
  return `已读取 ${modelCount + 1} 包`;
}

function formatGoMoreSleepResult(models) {
  const overviewCount = models.filter((model) => model.type === "overview").length;
  const stagesCount = models.filter((model) => model.type === "stages").length;
  if (models.length === 0) {
    return "无GoMore睡眠数据";
  }
  return `共${models.length}包，总览${overviewCount}包，分期${stagesCount}包`;
}

function formatFloat(value) {
  if (typeof value !== "number") {
    return "--";
  }
  return value.toFixed(1);
}

function maskToken(token) {
  if (!token) {
    return "--";
  }
  if (token.length <= 12) {
    return `${token.slice(0, 3)}***`;
  }
  return `${token.slice(0, 6)}...${token.slice(-4)}`;
}

function formatShortJson(value) {
  try {
    const text = JSON.stringify(value);
    return text.length > 180 ? `${text.slice(0, 180)}...` : text;
  } catch (_) {
    return String(value);
  }
}

function formatFirmwareUpdateResult(result) {
  if (!result.hasNewVersion) {
    return `无新版本：${result.message || "--"}`;
  }
  return [
    "有新版本",
    `版本:${result.version || "--"}`,
    `文件:${result.fileName || "--"}`,
    `地址:${result.downloadUrl || "--"}`,
    `说明:${result.upgradeDescribe || "--"}`,
  ].join(" ");
}

function formatHistoryRecordSummary(record) {
  const time = formatHistoryTime(record.timestampMs);
  const temperature = typeof record.temperatureCelsius === "number" ? `${record.temperatureCelsius.toFixed(2)}℃` : "--";
  const rrCount = record.rrIntervals ? record.rrIntervals.length : 0;
  const extensionCount = record.extensionFields ? record.extensionFields.length : 0;
  return [
    `时间:${time}`,
    `步数:${record.stepCount}`,
    `心率:${formatOptionalNumber(record.heartRate)}`,
    `血氧:${formatOptionalNumber(record.bloodOxygen)}`,
    `HRV:${formatOptionalNumber(record.heartRateVariability)}`,
    `压力:${formatOptionalNumber(record.stressIndex)}`,
    `温度:${temperature}`,
    `RR:${rrCount}`,
    `扩展:${extensionCount}`,
  ].join(" ");
}

function formatBleErrorMessage(error, fallbackMessage) {
  if (error && error.errCode === 10006) {
    return [
      "蓝牙连接已断开，当前写入指令失败。",
      "",
      "处理方式：请返回设备列表页，重新连接戒指后再执行该操作。",
      "",
      fallbackMessage,
    ].join("\n");
  }
  if (error && error.errCode === 10007) {
    return [
      "当前特征值不支持写入操作。",
      "",
      "处理方式：请检查写入特征 UUID 和 writeType 是否与设备服务一致。",
      "",
      fallbackMessage,
    ].join("\n");
  }
  return fallbackMessage;
}

function formatHistoryRecordDetail(record, mac) {
  const uploadRecord = mapHistoryRecordForUpload(record, mac);
  return [
    "",
    `    id:${uploadRecord.id ?? -1}`,
    `    mac:${uploadRecord.mac || "unknown"}`,
    `    totalNumber:${uploadRecord.totalNumber ?? 0}`,
    `    indexNumber:${uploadRecord.indexNumber ?? 0}`,
    `    time:${uploadRecord.time ?? 0}`,
    `    stepCount:${uploadRecord.stepCount ?? 0}`,
    `    stepCountingType:${uploadRecord.stepCountingType ?? 0}`,
    `    heartRate:${uploadRecord.heartRate ?? 0}`,
    `    bloodOxygen:${uploadRecord.bloodOxygen ?? 0}`,
    `    heartRateVariability:${uploadRecord.heartRateVariability ?? 0}`,
    `    stressIndex:${uploadRecord.stressIndex ?? 0}`,
    `    temperature:${formatCelsiusFromRaw(uploadRecord.temperature)}°C`,
    `    exerciseIntensity:${uploadRecord.exerciseIntensity ?? 0}`,
    `    sleepType:${uploadRecord.sleepType ?? 0}`,
    `    measureMarker:${uploadRecord.measurementMarker ?? 0}`,
    `    reserve:${uploadRecord.reserve ?? 0}`,
    `    rrCount:${uploadRecord.rrCount ?? 0}`,
    `    rrBytes:${formatSignedBytesHex(uploadRecord.rrBytes)}`,
    `    measureType:${uploadRecord.measureType ?? 0}`,
    `    stepsPerUnitTime:${uploadRecord.stepsPerUnitTime ?? 0}`,
    `    accumulationFlag:${uploadRecord.accumulationFlag ?? 0}`,
    `    batteryLevel:${uploadRecord.batteryLevel ?? 0}%`,
    `    batteryVoltage:${formatVoltageFromMv(uploadRecord.batteryVoltage)}V`,
    `    notWornReason:${uploadRecord.notWornReason ?? 0}`,
    `    recordCalibrationFlag:${uploadRecord.recordCalibrationFlag ?? 0}`,
    `    ambientLightIntensityFactor:${uploadRecord.ambientLightIntensityFactor ?? 0}%`,
    `    temperatureData:${formatTemperatureDataText(uploadRecord.temperatureData)}`,
    `    stepRateMax:${uploadRecord.stepRateMax ?? 0}步/min`,
    `    stepRateMin:${uploadRecord.stepRateMin ?? 0}步/min`,
    `    breathingRate:${uploadRecord.breathingRate ?? 0}次/分`,
    `    breathingRateConfidence:${uploadRecord.breathingRateConfidence ?? 0}%`,
    `    activityStatus:${uploadRecord.activityStatus ?? 0} (0:久坐 1:走路 2:跑步)`,
    `    totalCalories:${uploadRecord.totalCalories ?? 0}千卡`,
    `    basalMetabolicCalories:${uploadRecord.basalMetabolicCalories ?? 0}千卡`,
    `    exerciseCalories:${uploadRecord.exerciseCalories ?? 0}千卡`,
    `    hardAdt:${uploadRecord.hardAdt ?? 0}`,
    `    highBloodPressure:${uploadRecord.highBloodPressure ?? 0}mmHg`,
    `    lowBloodPressure:${uploadRecord.lowBloodPressure ?? 0}mmHg`,
  ].join("\n");
}

function mapHistoryRecordsForUpload(records, mac) {
  return records.map((record) => mapHistoryRecordForUpload(record, mac));
}

function mapHistoryRecordForUpload(record, mac) {
  const extensions = record.extensions || {};
  return {
    id: null,
    mac: mac || null,
    totalNumber: record.totalNumber,
    indexNumber: record.sequence,
    time: record.timestamp,
    stepCount: record.stepCount,
    stepCountingType: 0,
    heartRate: record.heartRate,
    bloodOxygen: record.bloodOxygen,
    heartRateVariability: record.heartRateVariability,
    stressIndex: record.stressIndex,
    temperature: record.temperatureRaw,
    exerciseIntensity: record.activityIntensity,
    sleepType: record.sleepType,
    measurementMarker: record.piReserved,
    reserve: record.resReserved,
    rrCount: record.arrayCount,
    rrBytes: uint16ValuesToSignedBytes(record.arrayValues || []),
    measureType: extensions.measureType ?? null,
    stepsPerUnitTime: extensions.periodStepCount ?? null,
    accumulationFlag: extensions.runningFlag ?? null,
    batteryLevel: extensions.batteryLevel ?? null,
    batteryVoltage: extensions.batteryVoltageRaw ?? null,
    notWornReason: extensions.notWearingReason ?? null,
    recordCalibrationFlag: extensions.calibrationFlag ?? null,
    ambientLightIntensityFactor: extensions.ambientLight ?? null,
    temperatureData: getHistoryTemperatureData(record),
    stepRateMax: extensions.maxStepFrequency ?? null,
    stepRateMin: extensions.minStepFrequency ?? null,
    breathingRate: extensions.respiratoryRate ?? null,
    breathingRateConfidence: extensions.respiratoryConfidence ?? null,
    activityStatus: extensions.motionState ?? null,
    totalCalories: extensions.totalCalories ?? null,
    basalMetabolicCalories: extensions.basalCalories ?? null,
    exerciseCalories: extensions.activeCalories ?? null,
    hardAdt: extensions.hardAdt ?? null,
    highBloodPressure: extensions.systolicPressure ?? null,
    lowBloodPressure: extensions.diastolicPressure ?? null,
  };
}

function uint16ValuesToSignedBytes(values) {
  const bytes = [];
  values.forEach((value) => {
    bytes.push(toSignedByte(value & 0xff));
    bytes.push(toSignedByte((value >> 8) & 0xff));
  });
  return bytes;
}

function toSignedByte(value) {
  return value > 127 ? value - 256 : value;
}

function formatSignedBytesHex(values) {
  if (!values || !values.length) {
    return "Null";
  }
  return values.map((value) => (value & 0xff).toString(16).padStart(2, "0").toUpperCase()).join("");
}

function getHistoryTemperatureData(record) {
  const temperatureField = (record.extensionFields || []).find((field) => field.type === 0x09);
  if (temperatureField && temperatureField.data && temperatureField.data.length) {
    return `[${parseTemperatureRawValues(temperatureField.data).join(",")}]`;
  }
  if (record.extensions && record.extensions.temperatures && record.extensions.temperatures.length) {
    return `[${record.extensions.temperatures.map((value) => Math.round(value * 100)).join(",")}]`;
  }
  return null;
}

function parseTemperatureRawValues(data) {
  const count = data[0] || 0;
  const values = [];
  for (let index = 0; index < count; index += 1) {
    const offset = 1 + index * 2;
    if (offset + 1 >= data.length) {
      break;
    }
    const raw = data[offset] | (data[offset + 1] << 8);
    values.push(raw >= 0x8000 ? raw - 0x10000 : raw);
  }
  return values;
}

function formatTemperatureDataText(value) {
  if (!value) {
    return "Null";
  }
  const values = Array.isArray(value) ? value : String(value).replace(/^\[|\]$/g, "").split(",").map((item) => Number(item.trim())).filter(Number.isFinite);
  if (!values.length) {
    return "Null";
  }
  return values.map((item) => `${(item / 100).toFixed(2)}°C`).join(", ");
}

function formatCelsiusFromRaw(value) {
  return ((value || 0) / 100).toFixed(2);
}

function formatVoltageFromMv(value) {
  return ((value || 0) / 1000).toFixed(3);
}

function formatHistoryTime(timestampMs) {
  if (!timestampMs) {
    return "--";
  }
  const date = new Date(timestampMs);
  const pad = (value) => String(value).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
}

function formatSelfInspectionResult(result) {
  const errorCodeHex = `0x${result.errorCode.toString(16).padStart(4, "0").toUpperCase()}`;
  if (!result.hasError) {
    return `自检结果:正常 故障码:${errorCodeHex}`;
  }
  const faults = result.faults.map((fault) => fault.description).join("、");
  return `自检结果:发现故障 故障码:${errorCodeHex} 故障项:${faults || "未知故障"}`;
}
