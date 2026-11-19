const {
  appendError, appendLog, appendApolloDebug, beginOtaOperation, getWechatRingAdapter,
  getNetworkSDK, getStatusSnapshot, requireSession, onLogsChanged,
  startOtaDiagnostics, stopOtaDiagnostics, disconnectDevice, connectSelectedDevice,
} = require("../../utils/demo-state");
const { normalizeFirmwareList, readApolloFirmware, chooseChatFirmware } = require("../../utils/firmware-files");
const { prepareApolloTransport, validateApolloPayload } = require("../../utils/apollo-channel");

// 按实际页面状态给出唯一阻塞原因；MTU 在点击后检查，不参与按钮禁用。
function upgradeBlockReason(state) {
  if (state.otaBusy) return "升级正在准备或传输中";
  if (state.fileBusy) return "正在选择、下载或校验固件，请等待完成";
  if (state.readVersionBusy) return "正在重连读取版本，请等待完成";
  if (!state.ready) return "请先选择并通过校验的 Apollo 固件";
  if (!state.connected) return "固件已就绪，请先连接戒指；连接后会保留当前文件";
  return "";
}

// 页面只管理选择、状态和平台调用，协议与确认始终由 SDK 负责。
Page({
  // 固件字节不能放入 data，避免经 setData 序列化。
  preparedFirmware: null,
  // 文件任务令牌使页面销毁后的下载/选择回调失效。
  fileTask: null,
  // 当前 BLE 操作的取消上下文，与普通文件任务独立。
  operation: null,
  unloaded: false,
  unsubscribeStatus: null,

  data: {
    // 来源切换会清除旧选择，避免升级到之前准备的版本。
    source: "network", category: "Z5X", firmwareList: [], selectedIndex: -1, queried: false,
    // 下载、读取、查询状态与 OTA 阶段分别展示。
    fileBusy: false, fileStatus: "请查询历史版本，或从聊天中选择 bin 文件", downloadPercent: 0,
    ready: false, fileName: "", fileSize: 0, bodySize: 0,
    connected: false, statusDeviceText: "未连接", otaBusy: false,
    otaStatus: "尚未升级", otaPercent: 0, resultText: "",
    protocolCompleted: false, readVersionBusy: false, diagnosticPath: "",
    // 可点击状态和原因由统一派生逻辑计算，防止页面只置灰却不说明原因。
    canStartUpgrade: false, upgradeBlockReason: "请先选择并通过校验的 Apollo 固件",
  },

  // 进入页面即记录网络查询上下文，完整诊断不受日志页滚动窗口限制。
  onLoad(options = {}) {
    this.unloaded = false;
    this.update({ source: options.source === "chat" ? "chat" : "network" });
    this.update({ diagnosticPath: startOtaDiagnostics() });
    this.syncConnection();
    this.unsubscribeStatus = onLogsChanged(() => this.syncConnection());
  },

  // 从聊天选择器或日志页返回，不重置正在准备/传输的状态。
  onShow() { this.syncConnection(); },

  // 真正离页才取消；打开日志页只触发 onHide，不影响前台升级。
  onUnload() {
    this.unloaded = true;
    this.fileTask = null;
    this.cancelUpgrade();
    if (this.unsubscribeStatus) this.unsubscribeStatus();
    void stopOtaDiagnostics();
    this.preparedFirmware = null;
  },

  // 忽略卸载后的异步更新，避免旧任务影响新页面。
  update(data) {
    if (this.unloaded) return;
    const reason = upgradeBlockReason({ ...this.data, ...data });
    this.setData({ ...data, canStartUpgrade: !reason, upgradeBlockReason: reason });
  },

  // 仅在连接信息变化时渲染，避免每条协议日志都触发页面刷新。
  syncConnection() {
    const snapshot = getStatusSnapshot();
    const statusDeviceText = snapshot.connected ? snapshot.statusDeviceText : "未连接";
    if (this.data.connected !== snapshot.connected || this.data.statusDeviceText !== statusDeviceText) {
      this.update({ connected: snapshot.connected, statusDeviceText });
      if (this.preparedFirmware) this.logUpgradeReadiness("连接状态变化");
    }
  },

  // 来源切换需丢弃内存中的旧文件。
  onSourceTap(event) {
    if (this.isBusy()) return;
    const source = event.currentTarget.dataset.source;
    if (source !== "network" && source !== "chat") return;
    this.clearPrepared();
    this.update({ source, firmwareList: [], selectedIndex: -1, queried: false, fileStatus: "请选择固件来源" });
  },

  // 分类编辑后清除旧查询结果，默认 Z5X 对应本项目测试固件系列。
  onCategoryInput(event) {
    if (this.isBusy()) return;
    this.clearPrepared();
    this.update({ category: event.detail.value, firmwareList: [], selectedIndex: -1, queried: false });
  },

  // 查询历史列表，不在查询完成时隐式下载第一项。
  async queryFirmwareList() {
    if (this.isBusy()) return;
    const category = this.data.category.trim();
    if (!category) { this.showError(new Error("请输入固件分类，例如 Z5X")); return; }
    this.clearPrepared();
    this.update({ firmwareList: [], selectedIndex: -1, queried: false });
    await this.runFileTask("查询历史版本中", async (task) => {
      const items = normalizeFirmwareList(await getNetworkSDK().getFirmwareVersionList(category));
      if (!this.isCurrent(task)) return;
      this.update({ firmwareList: items, queried: true,
        fileStatus: items.length ? `共 ${items.length} 个版本，请选择要下载的文件` : "该分类暂无历史固件，请检查分类或使用聊天文件" });
      appendLog(`Apollo 固件历史列表 category:${category.toUpperCase()} 数量:${items.length}`);
    });
  },

  // 可滚动选择全部历史项，不能选取缺少文件名或 URL 的条目。
  selectFirmware(event) {
    if (this.isBusy()) return;
    const index = Number(event.currentTarget.dataset.index);
    const item = this.data.firmwareList[index];
    if (!item || !item.selectable) return;
    this.clearPrepared();
    this.update({ selectedIndex: index, fileStatus: `已选择 ${item.fileName}，请先下载` });
  },

  // 只下载用户选中的历史文件，校验成功后等待“开始升级”。
  async downloadSelectedFirmware() {
    if (this.isBusy()) return;
    const item = this.data.firmwareList[this.data.selectedIndex];
    if (!item || !item.selectable) return;
    this.clearPrepared();
    await this.runFileTask("下载所选固件中", async (task) => {
      let loggedPercent = -10;
      const filePath = await getNetworkSDK().downloadFirmware(item.fileUrl, item.fileName, `${wx.env.USER_DATA_PATH}/firmware`, (progress) => {
        if (!this.isCurrent(task)) return;
        const percent = Math.min(100, Math.max(0, Math.round(progress * 100)));
        this.update({ downloadPercent: percent, fileStatus: `下载中 ${percent}%` });
        if (percent >= loggedPercent + 10 || percent === 100) {
          appendLog(`Apollo 固件下载：${item.fileName} ${percent}%`, "debug");
          loggedPercent = percent;
        }
      });
      if (!this.isCurrent(task)) return;
      const prepared = await readApolloFirmware(wx, getWechatRingAdapter(), filePath, item.fileName);
      if (this.isCurrent(task)) this.acceptFirmware(prepared, "历史版本下载");
    });
  },

  // 聊天文件是临时路径，选择后立即读取到内存，取消不弹错误。
  async chooseChatFile() {
    if (this.isBusy()) return;
    this.clearPrepared();
    await this.runFileTask("请选择聊天中的 bin 固件", async (task) => {
      const file = await chooseChatFirmware(wx);
      if (!this.isCurrent(task)) return;
      if (!file) { this.update({ fileStatus: "已取消选择文件" }); return; }
      const prepared = await readApolloFirmware(wx, getWechatRingAdapter(), file.path, file.name);
      if (this.isCurrent(task)) this.acceptFirmware(prepared, "微信聊天文件");
    });
  },

  // 公共文件准备结果，两条来源使用同一份校验和升级逻辑。
  acceptFirmware(prepared, sourceLabel) {
    this.preparedFirmware = prepared;
    this.update({ ready: true, fileName: prepared.fileName, fileSize: prepared.size, bodySize: prepared.bodySize,
      fileStatus: `${sourceLabel}已就绪，请核对设备型号与固件后开始升级` });
    appendLog(`Apollo 固件校验通过 来源:${sourceLabel} 文件:${prepared.fileName} 文件大小:${prepared.size} 正文:${prepared.bodySize}`);
  },

  // 文件、版本和来源变更时不保留之前的完成提示。
  clearPrepared() {
    this.preparedFirmware = null;
    this.update({ ready: false, fileName: "", fileSize: 0, bodySize: 0, downloadPercent: 0,
      protocolCompleted: false, resultText: "", otaPercent: 0, otaStatus: "尚未升级" });
  },

  // 文件任务与 BLE 任务互斥；失败后不启用开始升级按钮。
  async runFileTask(label, work) {
    const task = {};
    this.fileTask = task;
    this.update({ fileBusy: true, fileStatus: label });
    try { await work(task); } catch (error) {
      if (this.isCurrent(task)) {
        this.update({ fileStatus: "固件准备失败，请查看日志后重试" });
        this.showError(error);
      }
    } finally {
      if (this.isCurrent(task)) {
        this.fileTask = null;
        this.update({ fileBusy: false });
        this.syncConnection();
        this.logUpgradeReadiness("文件操作完成");
      }
    }
  },

  // 精确记录按钮判定输入，真机日志可区分连接失效与文件任务未结束。
  logUpgradeReadiness(context) {
    const { ready, connected, fileBusy, otaBusy, readVersionBusy, canStartUpgrade, upgradeBlockReason: reason } = this.data;
    appendLog(`Apollo 开始条件 ${context} 文件就绪:${ready} 已连接:${connected} 文件处理中:${fileBusy} 升级中:${otaBusy} 版本读取中:${readVersionBusy} 可开始:${canStartUpgrade} 原因:${reason || "无"}`, "debug");
  },

  // 判断异步任务是否仍属于当前页面实例。
  isCurrent(task) { return !this.unloaded && this.fileTask === task; },
  // 查询、文件选择、发送和版本读取之间不能交叉修改状态。
  isBusy() { return this.data.fileBusy || this.data.otaBusy || this.data.readVersionBusy; },

  // 只在用户明确点击后准备通道并调用 SDK，页面不自行构建 OTA 报文。
  async startUpgrade() {
    this.syncConnection();
    if (!this.data.canStartUpgrade) { this.logUpgradeReadiness("尝试开始"); return; }
    if (this.isBusy() || !this.preparedFirmware) return;
    const prepared = this.preparedFirmware;
    const operation = { cancelled: false, session: null, release: null, resolveStop: null, stopped: null };
    operation.stopped = new Promise((resolve) => { operation.resolveStop = resolve; });
    try {
      const session = requireSession();
      operation.session = session;
      this.operation = operation;
      operation.release = beginOtaOperation(() => this.cancelUpgrade("应用进入后台，升级已停止"));
      this.update({ otaBusy: true, otaStatus: "准备升级通道", resultText: "", otaPercent: 0, protocolCompleted: false });
      if (typeof wx.setKeepScreenOn === "function") wx.setKeepScreenOn({ keepScreenOn: true,
        fail: () => appendLog("无法保持屏幕常亮，请保持小程序在前台", "warning") });
      // 真机已验证的模式：ATT MTU 至少 240，实际单片写入 237 字节。
      const payloadSize = 237;
      const transport = await this.waitOperation(operation, prepareApolloTransport(wx, getWechatRingAdapter(), session));
      this.assertOperation(operation);
      // 独立 OTA 特征和通知已就绪，按无响应写入模式重新核验实际 MTU。
      const mtu = await this.waitOperation(operation, validateApolloPayload(wx, session, payloadSize));
      this.assertOperation(operation);
      appendLog(`Apollo 通道就绪后读取 ATT_MTU=${mtu} 有效负载=${payloadSize}`, "debug");
      appendLog(`开始 Apollo OTA 文件:${prepared.fileName} 大小:${prepared.size} 有效负载:${payloadSize} 设备:${session.channel.deviceId}`);
      let loggedPercent = -1;
      let lastState = "";
      const result = await session.sdk.startApolloUpgrade(transport, prepared.bytes, {
        payloadSize, timeoutMs: 10000, intervalMs: 10,
        onProgress: (progress) => {
          const percent = Math.floor(progress.percent);
          const labels = { preparing: "准备中", sendingHeader: "发送文件头", sendingData: "传输正文", verifying: "校验固件", resetting: "等待重启确认", completed: "协议传输完成", failed: "升级失败", cancelled: "升级已停止" };
          this.update({ otaStatus: `${labels[progress.state] || progress.state} · ${progress.acknowledgedBytes}/${progress.totalBytes} 字节`, otaPercent: percent });
          if (progress.state !== lastState || percent !== loggedPercent) {
            appendLog(`Apollo ${labels[progress.state]} ${percent}% 确认正文:${progress.acknowledgedBytes}/${progress.totalBytes}`, "debug");
            loggedPercent = percent;
            lastState = progress.state;
          }
        },
        debug: appendApolloDebug,
      });
      this.update({ protocolCompleted: true, resultText: "设备已确认全部传输及重启命令，请等待重启后重连读取版本。" });
      appendLog(`Apollo 协议完成：${JSON.stringify(result)}；重连后可查看当前固件版本`);
    } catch (error) {
      const cancelled = operation.cancelled || (error && error.code === "cancelled");
      this.update({ otaStatus: cancelled ? "升级已停止" : "升级失败", resultText: "请确认设备状态；必要时断连恢复后重新从头升级。" });
      if (cancelled) appendLog("Apollo 升级已停止，设备侧恢复状态需确认", "warning");
      else if (!this.unloaded) this.showError(error);
      else appendError("Apollo 离页后升级结束", error);
    } finally {
      if (operation.release && typeof wx.setKeepScreenOn === "function") wx.setKeepScreenOn({ keepScreenOn: false, fail() {} });
      if (operation.release) operation.release();
      if (this.operation === operation) this.operation = null;
      this.update({ otaBusy: false });
      this.syncConnection();
    }
  },

  // 通道发现等异步操作返回后必须重新验证取消状态及原始连接。
  assertOperation(operation) {
    if (this.unloaded || operation.cancelled) throw new Error("升级已取消");
    if (requireSession() !== operation.session) throw new Error("设备连接已改变，请重新连接并开始升级");
  },

  // 通道准备也可取消并设期限；晚到的平台回调只完成自身，不会触发升级。
  async waitOperation(operation, work) {
    let timer;
    try {
      return await Promise.race([
        work,
        operation.stopped.then(() => { throw new Error("升级已取消"); }),
        new Promise((_resolve, reject) => { timer = setTimeout(() => reject(new Error("升级通道准备超时")), 10000); }),
      ]);
    } finally { clearTimeout(timer); }
  },

  // 可在通道准备和 SDK 传输期间停止；不会将取消宣称为设备回滚。
  cancelUpgrade(reason) {
    const operation = this.operation;
    if (!operation || operation.cancelled) return;
    operation.cancelled = true;
    operation.resolveStop();
    appendLog(typeof reason === "string" ? reason : "已请求停止 Apollo 升级，不再发送后续数据", "warning");
    if (operation.session) operation.session.sdk.stopApolloUpgrade();
    this.update({ otaStatus: typeof reason === "string" ? reason : "正在停止升级" });
  },

  // 用户主动重连并读取真实固件版本，不根据文件名推测升级结果。
  async reconnectReadVersion() {
    if (this.isBusy()) return;
    this.update({ readVersionBusy: true, resultText: "正在重连读取设备版本…" });
    try {
      await disconnectDevice();
      if (this.unloaded) return;
      const session = await connectSelectedDevice();
      if (this.unloaded) return;
      const version = await session.sdk.getFirmwareVersion();
      if (!this.unloaded) this.update({ resultText: `当前设备固件版本：${version.version}。` });
      appendLog(`Apollo 重连后读取固件版本：${version.version}`);
    } catch (error) {
      this.update({ resultText: "重连读取版本失败，请确认设备重启及连接状态后重试。" });
      if (!this.unloaded) this.showError(error);
    }
    finally { this.update({ readVersionBusy: false }); this.syncConnection(); }
  },

  // 日志页可在传输中查看，完整分片另有本地诊断文件。
  openLogs() { wx.navigateTo({ url: "/pages/logs/logs" }); },
  // 从当前页压栈进入设备列表，连接成功返回时保留内存中的固件，不需重新选择。
  openDeviceList() {
    if (this.isBusy()) return;
    wx.navigateTo({ url: "/pages/device-list/device-list" });
  },
  // 统一错误入日志，用户取消文件选择不会走到这里。
  showError(error) {
    const message = appendError("Apollo 操作失败", error);
    if (!this.unloaded) wx.showModal({ title: "Apollo 操作失败", content: message, showCancel: false });
  },
});
