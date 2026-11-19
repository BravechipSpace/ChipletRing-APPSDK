import { BCLRingNetworkSDK, parseApolloFirmware, type UniBleApi } from "../libs/bcl-ring-sdk.js";

/** 微信回调错误；不要直接序列化，可能携带签名 URL。 */
type Failure = { errMsg?: string };
/** 平台回调参数，只声明本示例使用的 API 子集。 */
type Call<T> = { success: (result: T) => void; fail: (error: Failure) => void };
/** 微信文件系统能力，二进制读取不传 encoding。 */
export interface FirmwareFileSystem {
  readFile(options: Call<{ data: ArrayBuffer | string }> & { filePath: string }): void;
  unlink(options: Call<unknown> & { filePath: string }): void;
  writeFile(options: Call<unknown> & { filePath: string; data: string; encoding: "utf8" }): void;
  appendFile(options: Call<unknown> & { filePath: string; data: string; encoding: "utf8" }): void;
}
/** 当前设备连接状态事件，只处理匹配 deviceId 的事件。 */
export type ConnectionEvent = { deviceId: string; connected: boolean };
/** 微信专有 API；与 uni BLE 适配器分开注入，其他编译平台不得假装支持。 */
export interface WechatOtaApi {
  env: { USER_DATA_PATH: string };
  getFileSystemManager(): FirmwareFileSystem;
  chooseMessageFile(options: Call<{ tempFiles: { name: string; path: string }[] }> & { count: number; type: "file"; extension: string[] }): void;
  request(options: Call<{ statusCode: number; data: unknown; header?: unknown }> & {
    url: string; method: string; header: Record<string, string>; data?: unknown; timeout: number;
  }): void;
  downloadFile(options: Call<{ statusCode: number; tempFilePath?: string; header?: unknown }> & { url: string; timeout: number }): {
    onProgressUpdate?(callback: (event: { progress: number }) => void): void;
  };
  getDeviceInfo?(): { platform?: string };
  getSystemInfoSync?(): { platform?: string };
  getBLEMTU?: UniBleApi["getBLEMTU"];
  setBLEMTU?: UniBleApi["setBLEMTU"];
  onBLEConnectionStateChange(callback: (event: ConnectionEvent) => void): void;
  offBLEConnectionStateChange(callback: (event: ConnectionEvent) => void): void;
  setKeepScreenOn?(options: { keepScreenOn: boolean; fail?: (error: Failure) => void }): void;
}
/** 固件校验结果；字节仅保存在控制器私有字段，不进入视图响应式状态。 */
export type PreparedFirmware = { bytes: Uint8Array; fileName: string; size: number; bodySize: number };
/** 历史项保留无效条目与原因，界面可展示全部服务端结果。 */
export type FirmwareRow = { fileName: string; fileUrl: string; selectable: boolean; reason: string; displayUrl: string };

/** 对 URL 隐去查询参数、片段和用户信息，避免泄露临时下载授权。 */
export function safeUrl(value: string): string {
  return value.split("#")[0].replace(/(https?:\/\/)[^/@\s]+@/i, "$1***@").replace(/\?.*$/, "?[参数已脱敏]");
}
/** 日志统一脱敏敏感字段及 URL，完整正文不做截断；界面仅保留滚动窗口。 */
export function safeLogValue(value: unknown): string {
  return JSON.stringify(value, (key, field) => {
    if (/auth|token|password|secret|key|cookie|phone|email|openid/i.test(key)) return "***";
    if (typeof field === "string") return field.replace(/https?:\/\/[^\s"'<>]+/gi, safeUrl);
    return field;
  }) ?? "无";
}
/** 微信错误优先使用 errMsg，再脱敏其中的网络地址。 */
export function errorText(error: unknown): string {
  const message = error instanceof Error ? error.message : (error as Failure)?.errMsg || String(error);
  return message.replace(/https?:\/\/[^\s"'<>]+/gi, safeUrl);
}
/** 保存文件名不允许目录穿越、控制字符或空 bin 文件名。 */
export function isBinFileName(name: unknown): name is string {
  return typeof name === "string" && name.length <= 180 && name !== ".bin"
    && !/[\\/\x00-\x1f]/.test(name) && /\.bin$/i.test(name);
}
/** 仅 fileUrl 可作为下载地址，filePath 不作为后备网络地址。 */
export function normalizeFirmwareList(items: unknown): FirmwareRow[] {
  if (!Array.isArray(items)) throw new Error("固件历史列表格式错误");
  return items.map((item) => {
    const fileName = typeof item?.fileName === "string" ? item.fileName : "";
    const fileUrl = typeof item?.fileUrl === "string" ? item.fileUrl : "";
    const reason = !isBinFileName(fileName) ? "不是有效的 bin 文件"
      : !/^https:\/\/[^\s/?#@]+(?:[/?#]|$)/i.test(fileUrl) ? "缺少有效 HTTPS 下载地址" : "";
    return { fileName: fileName || "未命名文件", fileUrl, selectable: !reason, reason, displayUrl: safeUrl(fileUrl) };
  });
}
/** 读取临时或下载文件到内存，先通过协议校验再允许升级。 */
export async function readFirmware(api: WechatOtaApi, path: string, fileName: string): Promise<PreparedFirmware> {
  if (!isBinFileName(fileName)) throw new Error("请选择 .bin 固件文件");
  const data = await new Promise<ArrayBuffer | string>((resolve, reject) => api.getFileSystemManager().readFile({
    filePath: path, success: (result) => resolve(result.data), fail: reject,
  }));
  if (!(data instanceof ArrayBuffer)) throw new Error("固件读取结果不是二进制数据");
  const bytes = new Uint8Array(data);
  const image = parseApolloFirmware(bytes);
  return { bytes, fileName, size: bytes.length, bodySize: image.bodySize };
}
/** 聊天选择取消是正常操作，返回 null，不触发升级。 */
export function chooseChatFirmware(api: WechatOtaApi): Promise<{ name: string; path: string } | null> {
  if (typeof api.chooseMessageFile !== "function") return Promise.reject(new Error("当前环境不支持微信聊天文件选择"));
  return new Promise((resolve, reject) => api.chooseMessageFile({
    count: 1, type: "file", extension: ["bin"],
    success: ({ tempFiles }) => {
      const file = tempFiles?.[0];
      if (!file?.path || !isBinFileName(file.name)) reject(new Error("未选中有效的 bin 文件"));
      else resolve(file);
    },
    fail: (error) => /cancel/i.test(error.errMsg || "") ? resolve(null) : reject(error),
  }));
}
/** 使用 uni 已建立的连接查询微信平台，不在未知平台主动设置 MTU。 */
export function getPlatform(api: WechatOtaApi): string {
  try { return api.getDeviceInfo?.().platform?.toLowerCase() || api.getSystemInfoSync?.().platform?.toLowerCase() || "unknown"; }
  catch { try { return api.getSystemInfoSync?.().platform?.toLowerCase() || "unknown"; } catch { return "unknown"; } }
}
/** 构造固件列表 SDK 的最小 fetch 桥；微信运行时不依赖全局 fetch。 */
export function createFirmwareNetwork(api: WechatOtaApi, token: string, log: (text: string) => void): BCLRingNetworkSDK {
  // 每次查询使用当前输入的凭据，仅存内存且支持 SDK 的显式清理。
  let currentToken: string | undefined = token.trim() || undefined;
  const fetchBridge = ((url: string, init: RequestInit = {}) => new Promise((resolve, reject) => {
    const method = init.method || "GET";
    const header = init.headers as Record<string, string> || {};
    log(`网络请求 Method:${method} URL:${safeUrl(url)} Header:${safeLogValue(header)} Body:${safeLogValue(init.body)}`);
    api.request({
      url, method, header, data: init.body, timeout: 30000,
      success: (response) => {
        // 字符串 JSON 先解析再记录，防止其中 Token 或签名 URL 绕过脱敏。
        let body = response.data;
        try { if (typeof body === "string") body = JSON.parse(body); } catch { /* 由 SDK 报告无效响应。 */ }
        log(`网络响应 Status:${response.statusCode} Header:${safeLogValue(response.header)} Body:${safeLogValue(body)}`);
        resolve({ ok: response.statusCode >= 200 && response.statusCode < 300, status: response.statusCode, json: async () => body } as Response);
      },
      fail: (error) => { const message = errorText(error); log(`网络请求失败 URL:${safeUrl(url)} 原因:${message}`); reject(new Error(message)); },
    });
  })) as typeof fetch;
  return new BCLRingNetworkSDK({ fetch: fetchBridge, tokenStore: {
    // Token 仅用于本次面板会话，不写入配置文件或日志。
    getToken: () => currentToken, setToken(value) { currentToken = value; },
  } });
}
/** 下载到微信临时目录，HTTP 成功后立即读取，不覆盖永久固件文件。 */
export async function downloadFirmware(api: WechatOtaApi, row: FirmwareRow, log: (text: string) => void,
  onProgress: (percent: number) => void): Promise<PreparedFirmware> {
  if (!row.selectable) throw new Error(row.reason || "无效固件项");
  let path = "";
  try {
    log(`固件下载请求 Method:GET URL:${safeUrl(row.fileUrl)} Header:{} Body:无`);
    const result = await new Promise<{ statusCode: number; tempFilePath?: string; header?: unknown }>((resolve, reject) => {
      const task = api.downloadFile({ url: row.fileUrl, timeout: 120000, success: resolve, fail: reject });
      task?.onProgressUpdate?.(({ progress }) => onProgress(Math.max(0, Math.min(100, Math.round(progress)))));
    });
    path = result.tempFilePath || "";
    log(`固件下载响应 Status:${result.statusCode} Header:${safeLogValue(result.header)} Body:二进制文件`);
    if (result.statusCode < 200 || result.statusCode >= 300 || !path) throw new Error(`固件下载 HTTP 失败或文件为空：${result.statusCode}`);
    return await readFirmware(api, path, row.fileName);
  } catch (error) { log(`固件下载失败 URL:${safeUrl(row.fileUrl)} 原因:${errorText(error)}`); throw new Error(errorText(error)); }
  finally {
    if (path) api.getFileSystemManager().unlink({ filePath: path, success() {}, fail() {} });
  }
}

/** 完整日志排队追加，视图截断不影响诊断文件；写入失败只提示一次。 */
export class OtaDiagnostics {
  /** 可在微信开发者工具文件面板中导出的会话日志路径。 */
  readonly path: string;
  /** 串行追加避免分片日志并发写入时错序。 */
  private queue: Promise<void>;
  /** 一次失败后停止排队写入，避免递归记录诊断错误。 */
  private failed = false;
  constructor(private api: WechatOtaApi, private onFailure: (message: string) => void) {
    this.path = `${api.env.USER_DATA_PATH}/bcl-ota-${Date.now()}-${Math.random().toString(16).slice(2, 8)}.log`;
    this.queue = new Promise<void>((resolve, reject) => api.getFileSystemManager().writeFile({
      filePath: this.path, encoding: "utf8", data: "Uni-app 微信小程序 Apollo / Nordic OTA 诊断\n", success: () => resolve(), fail: reject,
    })).catch((error) => this.fail(error));
  }
  /** 即使页面销毁也完成已经入队的记录，不再修改页面状态。 */
  append(text: string): void {
    this.queue = this.queue.then(async () => {
      if (this.failed) return;
      await new Promise<void>((resolve, reject) => this.api.getFileSystemManager().appendFile({
        filePath: this.path, encoding: "utf8", data: `${text}\n`, success: () => resolve(), fail: reject,
      }));
    }).catch((error) => this.fail(error));
  }
  /** 高频分片诊断不可用时，调用方可回退日志页，避免静默丢失 Hex。 */
  isAvailable(): boolean { return !this.failed; }
  /** 测试或导出前可等待所有已排队日志写入。 */
  flush(): Promise<void> { return this.queue; }
  /** 防止诊断异常递归写日志；失败不打断 OTA。 */
  private fail(error: unknown): void {
    this.failed = true;
    this.onFailure(`完整诊断文件写入失败：${errorText(error)}；当前仅保留界面日志`);
  }
}
