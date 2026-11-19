import {
  APOLLO_OTA_SERVICE_UUID, APOLLO_OTA_WRITE_UUID, APOLLO_OTA_NOTIFY_UUID,
  BleApolloOtaTransport, UniBlePlatformTransport, prepareUniAppRingChannel,
  type ConnectedUniAppRingSDK, type UniBleApi, type UniBleCharacteristic, type ApolloOtaState,
} from "../libs/bcl-ring-sdk.js";
import {
  chooseChatFirmware, createFirmwareNetwork, downloadFirmware, errorText, getPlatform,
  normalizeFirmwareList, readFirmware,
  type FirmwareRow, type PreparedFirmware, type WechatOtaApi,
} from "./wechat-platform";
/** 产品接入可复用统一诊断文件，原始 Hex 不必逐片进入响应式日志。 */
export { OtaDiagnostics } from "./wechat-platform";

/** 模板可序列化状态，固件二进制和连接实例不放在这里。 */
export interface ApolloDemoState {
  /** 来源及查询条件变更都会废弃旧固件；Token 不持久化。 */
  source: "network" | "chat";
  category: string;
  token: string;
  /** 完整历史列表与显式选择，-1 表示尚未选择。 */
  rows: FirmwareRow[];
  selectedIndex: number;
  queried: boolean;
  /** 分别标识文件准备、协议传输和重连读版本的互斥任务。 */
  fileBusy: boolean;
  otaBusy: boolean;
  versionBusy: boolean;
  /** 仅经过 SDK 长度校验后置为就绪，不代表型号或签名匹配。 */
  ready: boolean;
  fileName: string;
  fileSize: number;
  bodySize: number;
  /** 下载进度独立于已被设备确认的 OTA 正文进度。 */
  fileStatus: string;
  downloadPercent: number;
  otaPercent: number;
  otaStatus: string;
  /** 协议完成与升级后真实版本核验分开显示。 */
  result: string;
  protocolCompleted: boolean;
}
/** 页面初始化时使用独立状态，避免不同页面共享文件和升级结果。 */
export function createApolloDemoState(): ApolloDemoState {
  return { source: "network", category: "Z5X", token: "", rows: [], selectedIndex: -1, queried: false,
    fileBusy: false, otaBusy: false, versionBusy: false, ready: false, fileName: "", fileSize: 0, bodySize: 0,
    fileStatus: "请查询历史固件或从聊天记录选择 bin 文件", downloadPercent: 0, otaPercent: 0,
    otaStatus: "尚未升级", result: "", protocolCompleted: false };
}
/** 开始按钮必须解释实际阻塞原因；MTU 在点击后按真实连接检查。 */
export function upgradeBlockReason(state: ApolloDemoState, connected: boolean, externalBusy: boolean): string {
  if (state.otaBusy) return "升级正在准备或传输中";
  if (state.fileBusy || state.versionBusy || externalBusy) return "其他操作正在进行，请稍候";
  if (!state.ready) return "请先选择并校验固件";
  if (!connected) return "固件已就绪，请先连接戒指；文件会保留";
  return "";
}
/** 面板依赖由首页注入，协议职责仍位于 SDK。 */
export interface ApolloDemoDependencies {
  ble: UniBleApi;
  api: WechatOtaApi;
  getSession(): ConnectedUniAppRingSDK | null;
  reconnect(): Promise<ConnectedUniAppRingSDK>;
  externalBusy(): boolean;
  log(text: string): void;
  /** 批量协议原始 Hex 通道；未提供时兼容原 Demo 日志。 */
  packetTrace?(text: string): void;
  busyChanged(busy: boolean): void;
}
/** 通过 Vue provide/inject 传递运行时对象，不将 SDK、wx 或函数放入小程序组件属性。 */
export const APOLLO_DEMO_CONTEXT = "bcl-apollo-demo-context";
/** 非微信平台提供空 api，面板仅展示平台说明。 */
export type ApolloDemoContext = Omit<ApolloDemoDependencies, "api"> & { api: WechatOtaApi | null };
/** 父页面可以停止/销毁面板任务，公开句柄不暴露固件和 SDK 内部对象。 */
export interface ApolloPanelHandle {
  cancelUpgrade(reason?: string): void;
  dispose(): void;
}
/** 准备 Apollo 专用通道并核验无响应写能力，不另建连接。 */
export async function prepareApolloTransport(ble: UniBleApi, api: WechatOtaApi, session: ConnectedUniAppRingSDK): Promise<BleApolloOtaTransport> {
  if (typeof api.onBLEConnectionStateChange !== "function" || typeof api.offBLEConnectionStateChange !== "function"
    || typeof ble.offBLECharacteristicValueChange !== "function") throw new Error("当前环境缺少可清理的蓝牙监听接口");
  const channel = await prepareUniAppRingChannel({ uni: ble, deviceId: session.channel.deviceId,
    serviceUuid: APOLLO_OTA_SERVICE_UUID, writeCharacteristicUuid: APOLLO_OTA_WRITE_UUID, notifyCharacteristicUuid: APOLLO_OTA_NOTIFY_UUID });
  const characteristics = await new Promise<UniBleCharacteristic[]>((resolve, reject) => {
    ble.getBLEDeviceCharacteristics({ deviceId: channel.deviceId, serviceId: channel.serviceId,
      success: (result) => resolve(result.characteristics), fail: reject });
  });
  if (!characteristics.find((item) => item.uuid.toLowerCase() === channel.writeCharacteristicId.toLowerCase())?.properties?.writeNoResponse) {
    throw new Error("Apollo 特征不支持无响应写入");
  }
  return new BleApolloOtaTransport(new UniBlePlatformTransport({ uni: ble, writeType: "writeNoResponse" }), {
    ...channel,
    onDisconnect(callback) {
      const listener = (event: { deviceId: string; connected: boolean }): void => {
        if (event.deviceId === channel.deviceId && !event.connected) callback();
      };
      api.onBLEConnectionStateChange(listener);
      return () => api.offBLEConnectionStateChange(listener);
    },
  });
}
/** GATT 就绪后仅 Android 尝试协商，最终必须读取到真实 MTU；不使用请求值冒充结果。 */
export async function validateApolloMtu(api: WechatOtaApi, session: ConnectedUniAppRingSDK, log: (text: string) => void,
  assertActive: () => void = () => {}): Promise<number> {
  const deviceId = session.channel.deviceId;
  const platform = getPlatform(api);
  assertActive();
  if (platform === "android" && typeof api.setBLEMTU === "function") {
    try {
      await new Promise<void>((resolve, reject) => api.setBLEMTU!({ deviceId, mtu: 512, success: () => resolve(), fail: reject }));
    } catch (error) { log(`Android MTU 协商失败，继续读取实际值：${errorText(error)}`); }
  }
  assertActive();
  if (typeof api.getBLEMTU !== "function") throw new Error("当前微信无法读取真实 MTU，请更新微信后重试");
  const mtu = await new Promise<number>((resolve, reject) => api.getBLEMTU!({
    deviceId, writeType: "writeNoResponse", success: (result) => resolve(result.mtu), fail: reject,
  }));
  assertActive();
  log(`Apollo 平台:${platform} ATT_MTU:${mtu} 有效写入负载:237`);
  if (!Number.isInteger(mtu) || mtu < 240) throw new Error(`实际 MTU=${mtu}，Apollo 需要至少 240；${platform === "ios" ? "iOS 由系统协商，请检查固件端 MTU 能力" : "请确认设备连接能力后重试"}`);
  return mtu;
}

/** 当前 BLE 操作及取消信号，覆盖通道准备和 SDK 传输。 */
type Operation = { session: ConnectedUniAppRingSDK; cancelled: boolean; stopped: Promise<void>; stop(): void };
/** 升级阶段的用户文案，100% 正文进度不等于重启验证成功。 */
const phaseLabels: Record<ApolloOtaState, string> = {
  preparing: "准备中", sendingHeader: "发送文件头", sendingData: "传输正文", verifying: "校验固件",
  resetting: "等待重启确认", completed: "协议传输完成", failed: "升级失败", cancelled: "升级已停止",
};

/** Demo 业务控制器：只做平台协调和页面状态，不编码协议或重试 OTA 分片。 */
export class ApolloDemoController {
  /** 固件字节保存在非响应式实例内，来源变化时立即释放。 */
  private prepared: PreparedFirmware | null = null;
  /** 文件任务身份令牌，使销毁后的异步回调失效。 */
  private fileTask: object | null = null;
  /** 当前传输绑定原始会话，并持有准备阶段取消信号。 */
  private operation: Operation | null = null;
  /** 页面销毁后禁止再读版本、启动 OTA 或修改结果。 */
  private disposed = false;
  constructor(readonly state: ApolloDemoState, private deps: ApolloDemoDependencies) {}

  /** 文件、OTA、重连以及首页命令互斥。 */
  isBusy(): boolean { return this.state.fileBusy || this.state.otaBusy || this.state.versionBusy || this.deps.externalBusy(); }
  /** 来源切换先废弃旧固件，避免误刷之前准备的文件。 */
  changeSource(source: "network" | "chat"): void {
    if (this.isBusy()) return;
    this.clearPrepared(); this.state.source = source; this.state.rows = []; this.state.selectedIndex = -1; this.state.queried = false;
  }
  /** 分类或 Token 改变后旧列表与准备结果失效。 */
  changeQuery(category: string, token: string): void {
    if (this.isBusy()) return;
    this.clearPrepared(); Object.assign(this.state, { category, token, rows: [], selectedIndex: -1, queried: false });
  }
  /** 查询完整列表，不默认选择或下载首项。 */
  async query(): Promise<void> {
    if (this.isBusy()) return;
    this.clearPrepared(); Object.assign(this.state, { rows: [], selectedIndex: -1, queried: false });
    await this.runFile("查询历史版本中", async (task) => {
      const category = this.state.category.trim();
      if (!category) throw new Error("请输入固件分类，例如 Z5X");
      const rows = normalizeFirmwareList(await createFirmwareNetwork(this.deps.api, this.state.token, this.deps.log).getFirmwareVersionList(category));
      if (!this.current(task)) return;
      Object.assign(this.state, { rows, queried: true, fileStatus: rows.length ? `共 ${rows.length} 个版本，请选择后下载` : "该分类暂无历史固件" });
    });
  }
  /** 选择只更新状态，下载由用户单独触发。 */
  select(index: number): void {
    if (this.isBusy() || !this.state.rows[index]?.selectable) return;
    this.clearPrepared(); this.state.selectedIndex = index; this.state.fileStatus = "已选择固件，请先下载";
  }
  /** 下载成功即读取并清理临时文件，协议校验通过后等待明确开始。 */
  async download(): Promise<void> {
    if (this.isBusy()) return;
    const row = this.state.rows[this.state.selectedIndex];
    if (!row?.selectable) return;
    this.clearPrepared();
    await this.runFile("下载所选固件中", async (task) => {
      const prepared = await downloadFirmware(this.deps.api, row, this.deps.log, (percent) => {
        if (this.current(task)) this.state.downloadPercent = percent;
      });
      if (this.current(task)) this.accept(prepared, "历史版本下载");
    });
  }
  /** 微信聊天文件选择，用户取消不会保留旧文件或报告 OTA 失败。 */
  async chooseChat(): Promise<void> {
    if (this.isBusy()) return;
    this.clearPrepared();
    await this.runFile("请选择聊天中的 bin 固件", async (task) => {
      const file = await chooseChatFirmware(this.deps.api);
      if (!this.current(task)) return;
      if (!file) { this.state.fileStatus = "已取消选择文件"; return; }
      const prepared = await readFirmware(this.deps.api, file.path, file.name);
      if (this.current(task)) this.accept(prepared, "微信聊天文件");
    });
  }
  /** 明确点击后才发现通道、核验 MTU 并调用 SDK。 */
  async start(): Promise<void> {
    const session = this.deps.getSession();
    const reason = upgradeBlockReason(this.state, !!session, this.deps.externalBusy());
    if (this.disposed || reason || !session || !this.prepared) { if (reason) this.deps.log(reason); return; }
    const prepared = this.prepared;
    let stop!: () => void;
    const stopped = new Promise<void>((resolve) => { stop = resolve; });
    const operation: Operation = { session, cancelled: false, stopped, stop };
    this.operation = operation;
    Object.assign(this.state, { otaBusy: true, otaPercent: 0, otaStatus: "准备 Apollo 升级通道", result: "", protocolCompleted: false });
    this.deps.busyChanged(true);
    this.keepScreenOn(true);
    /** 原始协议日志按约 16KiB 批量提交，所有结束路径均刷出尾部。 */
    let traceBuffer = "";
    const flushTrace = (): void => {
      if (!traceBuffer) return;
      const text = traceBuffer; traceBuffer = "";
      try { (this.deps.packetTrace ?? this.deps.log)(text); }
      catch { this.deps.log(text); }
    };
    try {
      const transport = await this.wait(operation, prepareApolloTransport(this.deps.ble, this.deps.api, session));
      await this.wait(operation, validateApolloMtu(this.deps.api, session, this.deps.log, () => this.assertActive(operation)));
      this.assertActive(operation);
      this.deps.log(`开始 Apollo OTA 文件:${prepared.fileName} 大小:${prepared.size} 正文:${prepared.bodySize} 负载:237 设备:${session.channel.deviceId}`);
      let lastProgress = "";
      let lastPhase = "";
      let lastUiAt = -Infinity;
      /** 统计专用 BLE 写入与总传输耗时，不包含下载和重连。 */
      const startedAt = Date.now();
      let writeCount = 0, writtenBytes = 0, writeMs = 0;
      const measuredTransport = {
        write: async (bytes: Uint8Array): Promise<void> => {
          const start = Date.now(); writeCount++; writtenBytes += bytes.length;
          try { await transport.write(bytes); } finally { writeMs += Date.now() - start; }
        },
        onNotification: (callback: (bytes: Uint8Array) => void) => transport.onNotification(callback),
        onDisconnect: (callback: () => void) => transport.onDisconnect(callback),
      };
      const result = await session.sdk.startApolloUpgrade(measuredTransport, prepared.bytes, {
        payloadSize: 237, intervalMs: 0, timeoutMs: 10000,
        onProgress: (progress) => {
          if (this.disposed || this.operation !== operation) return;
          const now = Date.now();
          const label = `${progress.state}:${Math.floor(progress.percent)}`;
          // 阶段切换和 100% 立即显示，其余最多每 200ms 更新一次，且合并同百分比。
          if (progress.state === lastPhase && (label === lastProgress || (progress.percent < 100 && now - lastUiAt < 200))) return;
          lastPhase = progress.state; lastUiAt = now;
          this.state.otaPercent = Math.floor(progress.percent);
          this.state.otaStatus = `${phaseLabels[progress.state]} · ${progress.acknowledgedBytes}/${progress.totalBytes} 字节`;
          if (label !== lastProgress) { this.deps.log(`Apollo ${this.state.otaStatus} ${this.state.otaPercent}%`); lastProgress = label; }
        },
        debug: (event) => {
          traceBuffer += `[+${Date.now() - startedAt}ms] Apollo ${event.type} 阶段:${event.state} Cmd:${event.command ?? "-"} Offset:${event.offset} Hex:${event.hex}${event.error ? ` 错误:${event.error.code} ${event.error.message}` : ""}\n`;
          if (traceBuffer.length >= 16384 || event.type === "error") flushTrace();
          if (event.type === "error") this.deps.log(`Apollo 协议错误:${event.error?.message ?? event.hex}`);
        },
      });
      const elapsedMs = Math.max(Date.now() - startedAt, 1);
      this.deps.log(`Apollo 传输统计 正文:${prepared.bodySize}字节 分片:${writeCount} 发送:${writtenBytes}字节 间隔:0ms 总耗时:${elapsedMs}ms 写入等待:${writeMs}ms 其他等待(含ACK与调度):${Math.max(0, elapsedMs - writeMs)}ms 平均:${(prepared.bodySize * 1000 / elapsedMs / 1024).toFixed(2)}KiB/s`);
      if (!this.disposed) {
        this.state.protocolCompleted = true;
        this.state.result = "设备已确认传输及重启命令；等待设备重启后可重连查看当前固件版本。";
      }
      this.deps.log(`Apollo 协议完成：${JSON.stringify(result)}；重连后可查看当前固件版本`);
    } catch (error) {
      if (!this.disposed) {
        this.state.otaStatus = operation.cancelled ? "升级已停止" : "升级失败";
        this.state.result = `设备侧状态需确认，必要时断连恢复后从头升级。${operation.cancelled ? "" : errorText(error)}`;
      }
      this.deps.log(`Apollo ${operation.cancelled ? "已停止" : "失败"}：${errorText(error)}`);
    } finally {
      flushTrace();
      this.keepScreenOn(false);
      if (this.operation === operation) this.operation = null;
      if (!this.disposed) this.state.otaBusy = false;
      this.deps.busyChanged(false);
    }
  }
  /** 准备期也可立即取消，晚到回调不能继续调用 SDK；不声称设备回滚。 */
  cancel(reason = "用户请求停止升级"): void {
    const operation = this.operation;
    if (!operation || operation.cancelled) return;
    operation.cancelled = true; operation.stop(); operation.session.sdk.stopApolloUpgrade();
    this.deps.log(`Apollo 停止：${reason}；设备侧恢复状态需确认`);
  }
  /** 重连后从设备读取版本，不根据文件名猜测升级成功。 */
  async reconnectReadVersion(): Promise<void> {
    if (this.disposed || this.isBusy()) return;
    this.state.versionBusy = true; this.deps.busyChanged(true);
    try {
      const session = await this.deps.reconnect();
      if (this.disposed) return;
      const version = await session.sdk.getFirmwareVersion();
      if (!this.disposed && this.deps.getSession() === session) this.state.result = `当前设备固件版本：${version.version}。`;
      this.deps.log(`Apollo 重连读取固件版本：${version.version}`);
    } catch (error) { if (!this.disposed) this.state.result = `重连读取版本失败：${errorText(error)}`; this.deps.log(`Apollo 版本读取失败：${errorText(error)}`); }
    finally { if (!this.disposed) this.state.versionBusy = false; this.deps.busyChanged(false); }
  }
  /** 页面销毁使文件回调失效并停止当前传输。 */
  dispose(): void { this.disposed = true; this.fileTask = null; this.cancel("页面已离开"); this.prepared = null; this.state.token = ""; }
  /** 当前操作只允许使用最初的连接，换设备或取消后必须重新开始。 */
  private assertActive(operation: Operation): void {
    if (this.disposed || operation.cancelled || this.operation !== operation) throw new Error("升级已取消");
    if (this.deps.getSession() !== operation.session) throw new Error("设备连接已改变，请重新连接并升级");
  }
  /** 常亮失败只影响提示，不能阻断 OTA 或阻止释放忙碌锁。 */
  private keepScreenOn(enabled: boolean): void {
    try {
      this.deps.api.setKeepScreenOn?.({ keepScreenOn: enabled,
        fail: (error) => this.deps.log(`屏幕常亮设置失败：${errorText(error)}，请保持前台运行`) });
    } catch (error) { this.deps.log(`屏幕常亮设置失败：${errorText(error)}`); }
  }
  /** 平台准备回调必须有期限，并能被取消信号打断。 */
  private async wait<T>(operation: Operation, work: Promise<T>): Promise<T> {
    let timer: ReturnType<typeof setTimeout> | undefined;
    try {
      const result = await Promise.race([work, operation.stopped.then(() => { throw new Error("升级已取消"); }),
        new Promise<never>((_resolve, reject) => { timer = setTimeout(() => reject(new Error("升级通道准备超时")), 10000); })]);
      this.assertActive(operation); return result;
    } finally { clearTimeout(timer); }
  }
  /** 统一文件状态及忙碌锁，异常不使失败固件变为可升级。 */
  private async runFile(label: string, work: (task: object) => Promise<void>): Promise<void> {
    if (this.disposed) return;
    const task = {}; this.fileTask = task; this.state.fileBusy = true; this.state.fileStatus = label; this.deps.busyChanged(true);
    try { await work(task); }
    catch (error) { if (this.current(task)) this.state.fileStatus = `固件准备失败：${errorText(error)}`; this.deps.log(`Apollo 文件操作失败：${errorText(error)}`); }
    finally {
      if (this.current(task)) { this.fileTask = null; this.state.fileBusy = false; this.deps.busyChanged(false); }
    }
  }
  /** 页面销毁后迟到的选择、下载和读取结果全部丢弃。 */
  private current(task: object): boolean { return !this.disposed && this.fileTask === task; }
  /** 清除旧完成提示与文件，避免来源切换后仍升级旧版本。 */
  private clearPrepared(): void {
    this.prepared = null;
    Object.assign(this.state, { ready: false, fileName: "", fileSize: 0, bodySize: 0, downloadPercent: 0, otaPercent: 0,
      protocolCompleted: false, result: "", otaStatus: "尚未升级", fileStatus: "请准备固件" });
  }
  /** 只有协议长度校验通过的字节可以进入待升级状态。 */
  private accept(prepared: PreparedFirmware, source: string): void {
    this.prepared = prepared;
    Object.assign(this.state, { ready: true, fileName: prepared.fileName, fileSize: prepared.size, bodySize: prepared.bodySize,
      fileStatus: `${source}已就绪，请核对设备型号与文件后开始升级` });
    this.deps.log(`Apollo 校验通过 来源:${source} 文件:${prepared.fileName} 大小:${prepared.size} 正文:${prepared.bodySize}`);
  }
}
