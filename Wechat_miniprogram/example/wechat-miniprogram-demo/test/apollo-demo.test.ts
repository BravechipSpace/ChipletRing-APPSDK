import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import { afterEach, describe, expect, it, vi } from "vitest";
import * as protocol from "../../../packages/protocol-core/src";
import { BleApolloOtaTransport } from "../../../packages/transport/src";
import { getWechatBlePlatform, WechatBlePlatformTransport } from "../../../packages/adapter-wechat/src";

const demo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

// Demo 是微信 CommonJS 脚本，通过隔离上下文注入平台，不改变实际工程模块格式。
function loadScript(relative: string, dependencies: Record<string, unknown> = {}, globals: Record<string, unknown> = {}): any {
  const file = path.resolve(demo, relative);
  const module = { exports: {} };
  vm.runInNewContext(fs.readFileSync(file, "utf8"), {
    module, exports: module.exports, console: { log() {}, warn() {}, error() {} },
    Uint8Array, ArrayBuffer, Error, Promise, Date, setTimeout, clearTimeout,
    require(name: string) {
      if (Object.prototype.hasOwnProperty.call(dependencies, name)) return dependencies[name];
      if (name.startsWith(".")) return loadScript(path.relative(demo, path.resolve(path.dirname(file), `${name}.js`)), dependencies, globals);
      throw new Error(`未配置测试依赖：${name}`);
    },
    ...globals,
  }, { filename: file });
  return module.exports;
}

const files = loadScript("utils/firmware-files.js");

// 合成最小可验证固件；测试依然调用真实纯协议校验器。
function firmware(size = 3): Uint8Array {
  const data = new Uint8Array(48 + size);
  new DataView(data.buffer).setUint32(8, size, true);
  return data;
}

// 页面测试同时调用实际文件工具与独立通道包装器，只替换网络和微信底层 API。
function createPage() {
  let definition: any;
  const rows = Array.from({ length: 12 }, (_, index) => ({
    fileName: `test_${index}.bin`, fileUrl: `https://example.com/${index}.bin?token=secret`, filePath: `/storage/${index}.bin`,
  }));
  const network = {
    getFirmwareVersionList: vi.fn(async () => rows),
    downloadFirmware: vi.fn(async (_url, _name, _folder, progress) => { progress(0.5); progress(1); return "/saved/fw.bin"; }),
  };
  const sdk = {
    startApolloUpgrade: vi.fn(async (_transport, _firmware, options) => {
      options.onProgress({ state: "verifying", percent: 100, acknowledgedBytes: 3, totalBytes: 3 });
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: 3 };
    }),
    stopApolloUpgrade: vi.fn(), getFirmwareVersion: vi.fn(async () => ({ version: "7.3.5.5Z5X" })),
  };
  const session = { channel: { deviceId: "ring" }, currentMtu: 247, sdk };
  const writeFile = vi.fn((options) => options.success());
  const readFile = vi.fn((options) => options.success({ data: firmware().buffer }));
  const wxApi = {
    env: { USER_DATA_PATH: "/user" },
    getFileSystemManager: () => ({ readFile, writeFile }),
    chooseMessageFile: vi.fn((options) => options.success({ tempFiles: [{ name: "chat.bin", path: "/chat/tmp.bin" }] })),
    getBLEDeviceCharacteristics: vi.fn((options) => options.success({ characteristics: [{
      uuid: protocol.APOLLO_OTA_WRITE_UUID, properties: { writeNoResponse: true },
    }] })),
    onBLEConnectionStateChange: vi.fn(), offBLEConnectionStateChange: vi.fn(),
    setKeepScreenOn: vi.fn(), showModal: vi.fn(), navigateTo: vi.fn(),
  };
  const adapter = { ...protocol, BleApolloOtaTransport, WechatBlePlatformTransport,
    prepareWechatRingChannel: vi.fn(async () => ({
      deviceId: "ring", serviceId: protocol.APOLLO_OTA_SERVICE_UUID,
      writeCharacteristicId: protocol.APOLLO_OTA_WRITE_UUID, notifyCharacteristicId: protocol.APOLLO_OTA_NOTIFY_UUID,
    })),
  };
  let connected = true;
  let cancel: (() => void) | null = null;
  const release = vi.fn(() => { cancel = null; });
  const state = {
    appendError: vi.fn((_label, error) => error.message || error.errMsg), appendLog: vi.fn(), appendApolloDebug: vi.fn(),
    beginOtaOperation: vi.fn((callback) => { cancel = callback; return release; }),
    getWechatRingAdapter: () => adapter, getNetworkSDK: () => network,
    getStatusSnapshot: () => ({ connected, statusDeviceText: "BCL测试戒指" }),
    requireSession: vi.fn(() => { if (!connected) throw new Error("SDK 未连接"); return session; }),
    onLogsChanged: vi.fn(() => vi.fn()), startOtaDiagnostics: vi.fn(() => "/user/ota.log"), stopOtaDiagnostics: vi.fn(async () => {}),
    disconnectDevice: vi.fn(async () => {}), connectSelectedDevice: vi.fn(async () => session),
  };
  loadScript("pages/apollo-ota/apollo-ota.js", { "../../utils/demo-state": state }, {
    wx: wxApi, Page(value: any) { definition = value; },
  });
  const page = { ...definition, data: structuredClone(definition.data), setData(values: unknown) { Object.assign(this.data, values); } };
  page.onLoad();
  return { page, network, sdk, session, wxApi, adapter, state, rows, readFile, release,
    disconnect: () => { connected = false; }, connect: () => { connected = true; }, background: () => cancel && cancel() };
}

afterEach(() => vi.useRealTimers());

describe("Apollo 文件与下载", () => {
  it("保留超过 ActionSheet 上限的全部历史项，并标记无效条目", () => {
    const rows = Array.from({ length: 12 }, (_, i) => ({ fileName: `${i}.bin`, fileUrl: "https://example.com/fw.bin?key=secret" }));
    const list = files.normalizeFirmwareList([...rows, { fileName: "../fw.bin", fileUrl: "https://example.com" }, { fileName: "fw.bin", filePath: "https://example.com" }]);
    expect(list).toHaveLength(14);
    expect(list[11].selectable).toBe(true);
    expect(list[0].displayUrl).not.toContain("secret");
    expect(list[12].selectable).toBe(false);
    expect(list[13].selectable).toBe(false);
  });

  it("读取二进制并实际校验，损坏文件与文本返回都拒绝", async () => {
    const wxApi = { getFileSystemManager: () => ({ readFile: (options) => {
      expect(options.encoding).toBeUndefined(); options.success({ data: firmware().buffer });
    } }) };
    await expect(files.readApolloFirmware(wxApi, protocol, "/tmp", "fw.bin")).resolves.toMatchObject({ size: 51, bodySize: 3 });
    for (const data of [new Uint8Array(48).buffer, "text"]) {
      const bad = { getFileSystemManager: () => ({ readFile: (options) => options.success({ data }) }) };
      await expect(files.readApolloFirmware(bad, protocol, "/tmp", "fw.bin")).rejects.toThrow();
    }
  });

  it("聊天取消返回 null，错误文件名拒绝", async () => {
    await expect(files.chooseChatFirmware({ chooseMessageFile: (options) => options.fail({ errMsg: "chooseMessageFile:fail cancel" }) })).resolves.toBeNull();
    await expect(files.chooseChatFirmware({ chooseMessageFile: (options) => options.success({ tempFiles: [{ name: "fw.zip", path: "/tmp" }] }) })).rejects.toThrow("bin");
  });

  // 下载模拟保留 mkdir/save/unlink 的真实执行顺序。
  function downloaderContext(statusCode = 200) {
    const calls: string[] = [];
    const fsMock = {
      mkdir: vi.fn((options) => { calls.push("mkdir"); options.success(); }),
      access: vi.fn((options) => options.success()),
      unlink: vi.fn((options) => { calls.push(`unlink:${options.filePath}`); if (options.success) options.success(); }),
      saveFile: vi.fn((options) => { calls.push("save"); options.success({ savedFilePath: options.filePath }); }),
    };
    const wxApi = { getFileSystemManager: () => fsMock, downloadFile: vi.fn((options) => {
      calls.push("download"); options.success({ statusCode, tempFilePath: "/tmp/download", header: { "x-token": "private", "content-length": 51 } });
      return { onProgressUpdate(callback) { callback({ progress: 100 }); } };
    }) };
    const log = vi.fn();
    const logError = vi.fn();
    return { calls, fsMock, wxApi, log, logError, downloader: files.createWechatFirmwareDownloader(wxApi, log, logError) };
  }

  it("先创建目录，再下载保存；完整响应日志隐藏 URL 签名与 Header Token", async () => {
    const context = downloaderContext();
    await expect(context.downloader.download({ url: "https://example.com/fw.bin?signature=secret", fileName: "fw.bin", destinationPath: "/user/firmware" })).resolves.toBe("/user/firmware/fw.bin");
    expect(context.calls).toEqual(["mkdir", "download", "unlink:/user/firmware/fw.bin", "save", "unlink:/tmp/download"]);
    const logs = JSON.stringify(context.log.mock.calls);
    expect(logs).toContain("Method:GET");
    expect(logs).toContain("Status:200");
    expect(logs).not.toContain("secret");
    expect(logs).not.toContain("private");
  });

  it("HTTP 失败不保存，已存在目录可复用，保存失败清理临时文件", async () => {
    const badHttp = downloaderContext(404);
    await expect(badHttp.downloader.download({ url: "https://example.com/fw.bin", fileName: "fw.bin", destinationPath: "/user" })).rejects.toThrow("404");
    expect(badHttp.fsMock.saveFile).not.toHaveBeenCalled();
    expect(badHttp.calls).toContain("unlink:/tmp/download");
    const badSave = downloaderContext();
    badSave.fsMock.mkdir.mockImplementation((options) => options.fail(new Error("已存在")));
    badSave.fsMock.saveFile.mockImplementation((options) => options.fail(new Error("存储空间不足")));
    await expect(badSave.downloader.download({ url: "https://example.com/fw.bin", fileName: "fw.bin", destinationPath: "/user" })).rejects.toThrow("空间不足");
    expect(badSave.calls).toContain("unlink:/tmp/download");
  });
});

describe("Apollo 页面完整流程", () => {
  it("文件就绪但设备未连接时解释置灰原因，页内连接返回后保留文件并可开始", async () => {
    const { page, disconnect, connect, wxApi, sdk } = createPage();
    disconnect();
    page.onShow();
    await page.chooseChatFile();
    const prepared = page.preparedFirmware;
    expect(page.data.ready).toBe(true);
    expect(page.data.canStartUpgrade).toBe(false);
    expect(page.data.upgradeBlockReason).toContain("请先连接戒指");
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    page.openDeviceList();
    expect(wxApi.navigateTo).toHaveBeenCalledWith({ url: "/pages/device-list/device-list" });
    connect();
    page.onShow();
    expect(page.preparedFirmware).toBe(prepared);
    expect(page.data.canStartUpgrade).toBe(true);
    expect(page.data.upgradeBlockReason).toBe("");
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).toHaveBeenCalled();
  });

  it("所有按钮禁用条件显示明确原因，MTU 23 不会直接置灰按钮", async () => {
    const { page, session } = createPage();
    expect(page.data.upgradeBlockReason).toContain("选择");
    await page.chooseChatFile();
    session.currentMtu = 23;
    page.onShow();
    expect(page.data.canStartUpgrade).toBe(true);
    for (const [flag, reason] of [["fileBusy", "校验固件"], ["otaBusy", "升级正在"], ["readVersionBusy", "读取版本"]]) {
      page.update({ [flag]: true });
      expect(page.data.canStartUpgrade).toBe(false);
      expect(page.data.upgradeBlockReason).toContain(reason);
      page.update({ [flag]: false });
      expect(page.data.canStartUpgrade).toBe(true);
    }
  });

  it("文件读取失败会清除处理中状态并明确提示未就绪，而非静默禁用", async () => {
    const { page, readFile, state } = createPage();
    readFile.mockImplementationOnce((options) => options.fail({ errMsg: "文件不可读" }));
    await page.chooseChatFile();
    expect(page.data.fileBusy).toBe(false);
    expect(page.data.canStartUpgrade).toBe(false);
    expect(page.data.upgradeBlockReason).toContain("选择");
    expect(state.appendLog).toHaveBeenCalledWith(expect.stringContaining("文件就绪:false"), "debug");
  });

  it("先查询/选择，按所选项下载，校验后明确开始；显示协议完成而非版本成功", async () => {
    const { page, network, sdk, rows } = createPage();
    await page.queryFirmwareList();
    expect(network.getFirmwareVersionList).toHaveBeenCalledWith("Z5X");
    expect(network.downloadFirmware).not.toHaveBeenCalled();
    expect(page.data.firmwareList).toHaveLength(12);
    page.selectFirmware({ currentTarget: { dataset: { index: 11 } } });
    await page.downloadSelectedFirmware();
    expect(network.downloadFirmware).toHaveBeenCalledWith(rows[11].fileUrl, rows[11].fileName, "/user/firmware", expect.any(Function));
    expect(page.data.ready).toBe(true);
    expect(page.data.downloadPercent).toBe(100);
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).toHaveBeenCalledWith(expect.any(BleApolloOtaTransport), expect.any(Uint8Array), expect.objectContaining({ payloadSize: 237 }));
    expect(page.data.protocolCompleted).toBe(true);
    expect(page.data.resultText).toContain("重连读取版本");
    expect(page.data.otaBusy).toBe(false);
  });

  it("聊天文件与网络共用核心入口，取消选择不错误提示", async () => {
    const { page, wxApi, sdk } = createPage();
    page.onSourceTap({ currentTarget: { dataset: { source: "chat" } } });
    await page.chooseChatFile();
    expect(wxApi.chooseMessageFile.mock.calls[0][0]).toMatchObject({ count: 1, type: "file", extension: ["bin"] });
    expect(page.data.fileName).toBe("chat.bin");
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).toHaveBeenCalledTimes(1);
    wxApi.chooseMessageFile.mockImplementation((options) => options.fail({ errMsg: "cancel" }));
    await page.chooseChatFile();
    expect(page.data.ready).toBe(false);
    expect(wxApi.showModal).not.toHaveBeenCalled();
  });

  it("切换分类、来源、历史项均使旧固件失效", async () => {
    const { page } = createPage();
    await page.queryFirmwareList();
    page.selectFirmware({ currentTarget: { dataset: { index: 0 } } });
    await page.downloadSelectedFirmware();
    page.selectFirmware({ currentTarget: { dataset: { index: 1 } } });
    expect(page.data.ready).toBe(false);
    await page.downloadSelectedFirmware();
    page.onCategoryInput({ detail: { value: "Z2Y" } });
    expect(page.preparedFirmware).toBeNull();
    expect(page.data.firmwareList).toHaveLength(0);
    await page.chooseChatFile();
    page.onSourceTap({ currentTarget: { dataset: { source: "network" } } });
    expect(page.preparedFirmware).toBeNull();
  });

  it("空列表/查询错误/下载失败均不能启动升级", async () => {
    const { page, network, sdk } = createPage();
    network.getFirmwareVersionList.mockResolvedValueOnce([]);
    await page.queryFirmwareList();
    expect(page.data.fileStatus).toContain("暂无");
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    network.getFirmwareVersionList.mockRejectedValueOnce(new Error("接口错误"));
    await page.queryFirmwareList();
    expect(page.data.fileBusy).toBe(false);
    await page.queryFirmwareList();
    page.selectFirmware({ currentTarget: { dataset: { index: 0 } } });
    network.downloadFirmware.mockRejectedValueOnce(new Error("下载失败"));
    await page.downloadSelectedFirmware();
    expect(page.data.ready).toBe(false);
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });

  it("页面退出后下载完成不会读文件或启动 OTA", async () => {
    const { page, network, sdk, readFile } = createPage();
    let finish!: (path: string) => void;
    network.downloadFirmware.mockImplementationOnce(() => new Promise((resolve) => { finish = resolve; }));
    await page.queryFirmwareList();
    page.selectFirmware({ currentTarget: { dataset: { index: 0 } } });
    const pending = page.downloadSelectedFirmware();
    page.onUnload();
    finish("/saved/late.bin");
    await pending;
    expect(readFile).not.toHaveBeenCalled();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });

  it("通道准备期间取消即释放 UI 和共享锁；晚回调不能刷机", async () => {
    const { page, adapter, sdk, release } = createPage();
    await page.chooseChatFile();
    let finish!: (channel: any) => void;
    adapter.prepareWechatRingChannel.mockImplementationOnce(() => new Promise((resolve) => { finish = resolve; }));
    const pending = page.startUpgrade();
    await vi.waitFor(() => expect(adapter.prepareWechatRingChannel).toHaveBeenCalled());
    page.cancelUpgrade();
    await pending;
    expect(release).toHaveBeenCalledTimes(1);
    expect(page.data.otaBusy).toBe(false);
    finish({ deviceId: "ring", serviceId: protocol.APOLLO_OTA_SERVICE_UUID,
      writeCharacteristicId: protocol.APOLLO_OTA_WRITE_UUID, notifyCharacteristicId: protocol.APOLLO_OTA_NOTIFY_UUID });
    await Promise.resolve();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });

  it("通道发现失败或连接已改变不会发包", async () => {
    const { page, adapter, sdk, disconnect, release } = createPage();
    await page.chooseChatFile();
    adapter.prepareWechatRingChannel.mockRejectedValueOnce(new Error("无 Apollo 服务"));
    await page.startUpgrade();
    expect(release).toHaveBeenCalled();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    disconnect();
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });

  it("缺少无响应能力或 237 模式 MTU 不明时拒绝升级", async () => {
    const { page, session, wxApi, sdk } = createPage();
    await page.chooseChatFile();
    wxApi.getBLEDeviceCharacteristics.mockImplementationOnce((options) => options.success({ characteristics: [] }));
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    session.currentMtu = 23;
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
    session.currentMtu = 247;
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).toHaveBeenCalledWith(expect.anything(), expect.anything(), expect.objectContaining({ payloadSize: 237 }));
  });

  it("独立通道就绪后读取无响应写入 MTU，替换连接早期的 23", async () => {
    const { page, session, wxApi, adapter, sdk } = createPage();
    await page.chooseChatFile();
    session.currentMtu = 23;
    Object.assign(wxApi, { getBLEMTU: vi.fn((options) => {
      expect(adapter.prepareWechatRingChannel).toHaveBeenCalled();
      expect(wxApi.getBLEDeviceCharacteristics).toHaveBeenCalled();
      expect(options.writeType).toBe("writeNoResponse");
      options.success({ mtu: 247 });
    }) });
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).toHaveBeenCalledTimes(1);
  });

  it.each([23, 0, NaN, Infinity])("最新读取的 MTU=%s 不能凭旧的 247 授权大包写入", async (mtu) => {
    const { page, wxApi, sdk } = createPage();
    await page.chooseChatFile();
    Object.assign(wxApi, { getBLEMTU: (options) => options.success({ mtu }) });
    await page.startUpgrade();
    expect(sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });

  it("后台取消会话，日志导航不会取消；SDK 断连错误不显示成功", async () => {
    const { page, sdk, background, wxApi } = createPage();
    await page.chooseChatFile();
    let reject!: (error: Error) => void;
    sdk.startApolloUpgrade.mockImplementationOnce(() => new Promise((_resolve, fail) => { reject = fail; }));
    sdk.stopApolloUpgrade.mockImplementation(() => reject(Object.assign(new Error("已取消"), { code: "cancelled" })));
    const pending = page.startUpgrade();
    await vi.waitFor(() => expect(sdk.startApolloUpgrade).toHaveBeenCalled());
    page.openLogs();
    expect(sdk.stopApolloUpgrade).not.toHaveBeenCalled();
    background();
    await pending;
    expect(sdk.stopApolloUpgrade).toHaveBeenCalled();
    expect(page.data.protocolCompleted).toBe(false);
    expect(wxApi.setKeepScreenOn).toHaveBeenLastCalledWith(expect.objectContaining({ keepScreenOn: false }));
    sdk.startApolloUpgrade.mockRejectedValueOnce(Object.assign(new Error("已断连"), { code: "disconnected" }));
    await page.startUpgrade();
    expect(page.data.protocolCompleted).toBe(false);
    expect(page.data.otaStatus).toBe("升级失败");
  });

  it("重连后读取并展示真实版本，读版本失败不宣称成功", async () => {
    const { page, sdk, state } = createPage();
    await page.reconnectReadVersion();
    expect(state.disconnectDevice).toHaveBeenCalled();
    expect(state.connectSelectedDevice).toHaveBeenCalled();
    expect(page.data.resultText).toContain("7.3.5.5Z5X");
    sdk.getFirmwareVersion.mockRejectedValueOnce(new Error("未重启完成"));
    await page.reconnectReadVersion();
    expect(page.data.readVersionBusy).toBe(false);
    expect(state.appendError).toHaveBeenCalled();
  });
});

describe("微信 Demo 集成", () => {
  // 使用真实共享状态模块验证跨页面互斥、断连及文件日志队列。
  function sharedContext() {
    const app = { globalData: { demoState: null } };
    const listeners = new Set<(event: unknown) => void>();
    const disk: Record<string, string> = {};
    const fsMock = {
      writeFile: vi.fn((options) => { disk[options.filePath] = options.data; options.success(); }),
      appendFile: vi.fn((options) => { disk[options.filePath] += options.data; options.success(); }),
    };
    const wxApi = {
      env: { USER_DATA_PATH: "/user" }, getStorageSync: () => null, setStorageSync: vi.fn(),
      getFileSystemManager: () => fsMock,
      onBLEConnectionStateChange: (callback: (event: unknown) => void) => listeners.add(callback),
      offBLEConnectionStateChange: (callback: (event: unknown) => void) => listeners.delete(callback),
      request: vi.fn((options) => options.success({ statusCode: 200, data: { result: [{ fileUrl: "https://example.com/fw.bin?token=hidden" }] } })),
    };
    const sdk = { close: vi.fn(), getFirmwareVersion: vi.fn(async () => ({ version: "6.2.6.2Z5Z" })) };
    const session = { sdk, channel: { deviceId: "ring" }, disconnect: vi.fn(async () => { sdk.close(); }) };
    const adapter = { connectWechatRingSDK: vi.fn(async () => session), getWechatBlePlatform, createWechatTokenStore: () => ({}),
      BCLRingNetworkSDK: class { options: any; constructor(options: any) { this.options = options; } },
    };
    const state = loadScript("utils/demo-state.js", { "../libs/bcl-ring-sdk": adapter }, { wx: wxApi, getApp: () => app });
    state.setSelectedDevice({ deviceId: "ring", name: "BCL" });
    return { state, listeners, session, sdk, wxApi, fsMock, disk, adapter };
  }

  it.each(["ios", "android", "devtools"])("Demo 按 %s 平台传递协商配置并说明只读策略", async (platform) => {
    const { state, wxApi, adapter } = sharedContext();
    Object.assign(wxApi, { getDeviceInfo: () => ({ platform }) });
    await state.connectSelectedDevice();
    expect(adapter.connectWechatRingSDK).toHaveBeenCalledWith(expect.objectContaining({
      preferredMtu: platform === "android" ? 512 : undefined,
    }));
    const logs = state.getLogSnapshot().logs.map((entry) => entry.message).join("\n");
    if (platform !== "android") {
      expect(logs).toContain("已跳过手动设置");
      expect(logs).not.toContain("MTU协商失败");
    }
    await state.disconnectDevice();
  });

  it("共享 OTA 锁阻止扫描、换设备与手动断连，释放后可继续操作", async () => {
    const { state } = sharedContext();
    await state.connectSelectedDevice();
    const release = state.beginOtaOperation(() => {});
    expect(state.getStatusSnapshot().otaBusy).toBe(true);
    await expect(state.scanDevices()).rejects.toThrow("升级");
    await expect(state.disconnectDevice()).rejects.toThrow("升级");
    await expect(state.connectSelectedDevice()).rejects.toThrow("升级");
    expect(() => state.setSelectedDevice({ deviceId: "other" })).toThrow("升级");
    release();
    expect(state.getStatusSnapshot().isBusy).toBe(false);
    await state.disconnectDevice();
    expect(state.getStatusSnapshot().connected).toBe(false);
  });

  it("真实断连清空共享会话并释放连接资源，主动断连不重复清理", async () => {
    const { state, listeners, session } = sharedContext();
    await state.connectSelectedDevice();
    for (const callback of listeners) callback({ deviceId: "ring", connected: false });
    expect(state.getStatusSnapshot().connected).toBe(false);
    await Promise.resolve();
    expect(session.disconnect).toHaveBeenCalledTimes(1);
    expect(listeners.size).toBe(0);
    await state.connectSelectedDevice();
    await state.disconnectDevice();
    expect(session.disconnect).toHaveBeenCalledTimes(2);
    expect(listeners.size).toBe(0);
  });

  it("完整诊断超出滚动窗口仍保留，并可在离页后排空；文件写入失败不影响操作", async () => {
    const { state, disk, fsMock } = sharedContext();
    state.startOtaDiagnostics();
    state.appendLog("历史查询上下文");
    for (let i = 0; i < 310; i += 1) state.appendLog(`包 ${i}`);
    state.appendApolloDebug({ type: "write", state: "sendingData", command: 2, offset: 0, hex: "abcdef" });
    await state.stopOtaDiagnostics();
    const path = await state.getOtaDiagnosticFile();
    expect(state.getLogSnapshot().logs).toHaveLength(300);
    expect(new Set(state.getLogSnapshot().logs.map((row) => row.id)).size).toBe(300);
    expect(disk[path]).toContain("历史查询上下文");
    expect(disk[path]).toContain("abcdef");
    state.startOtaDiagnostics();
    fsMock.appendFile.mockImplementation((options) => options.fail(new Error("空间不足")));
    state.appendLog("仍可升级");
    await state.getOtaDiagnosticFile();
    expect(state.getLogSnapshot().logs.filter((row) => row.message.includes("诊断文件写入失败"))).toHaveLength(1);
    await state.stopOtaDiagnostics();
  });

  it("网络日志隐藏签名 URL 和敏感 Body/Header，保留响应状态", async () => {
    const { state } = sharedContext();
    const client = state.getNetworkSDK();
    await client.options.fetch("https://example.com/list?token=query-secret", {
      method: "POST", headers: { Authorization: "very-private-authorization" }, body: JSON.stringify({ apiKey: "body-private" }),
    });
    const content = JSON.stringify(state.getLogSnapshot().logs);
    expect(content).not.toContain("query-secret");
    expect(content).not.toContain("body-private");
    expect(content).not.toContain("token=hidden");
    expect(content).not.toContain("very-private-authorization");
    expect(content).toContain("Status:200");
  });

  it("本地 bundle 导出完整 Apollo 接入依赖", () => {
    const bundle = loadScript("libs/bcl-ring-sdk.js");
    expect(bundle.parseApolloFirmware).toBeTypeOf("function");
    expect(bundle.BleApolloOtaTransport).toBeTypeOf("function");
    expect(bundle.APOLLO_OTA_SERVICE_UUID).toBe(protocol.APOLLO_OTA_SERVICE_UUID);
  });

  it("PHY 诊断使用独立类型和文件前缀，不误标为 Apollo", async () => {
    const { state, disk } = sharedContext();
    const file = state.startOtaDiagnostics("PHY");
    expect(file).toMatch(/\/phy-ota-\d+\.log$/);
    state.appendNordicPacketTrace("PHY command Hex:0102");
    await state.stopOtaDiagnostics();
    expect(disk[file]).toContain("PHY 完整诊断文件");
    expect(disk[file]).toContain("PHY command Hex:0102");
  });

  it("Nordic 批量分片直接保留完整诊断，不刷新滚动日志列表", async () => {
    const { state, disk, fsMock } = sharedContext();
    state.startOtaDiagnostics("Nordic");
    const initialCount = state.getLogSnapshot().logs.length;
    const batch = "Nordic packet Hex:010203\nNordic packet Hex:aabbcc";
    state.appendNordicPacketTrace(batch);
    const file = await state.getOtaDiagnosticFile();
    expect(disk[file]).toContain(batch);
    expect(state.getLogSnapshot().logs).toHaveLength(initialCount);
    expect(fsMock.appendFile.mock.calls.filter(([o]) => o.data.includes("Nordic packet Hex:"))).toHaveLength(1);
  });

  it("Nordic 诊断不可用时原始分片回退日志页，不静默丢失Hex", async () => {
    const { state } = sharedContext();
    state.appendNordicPacketTrace("Nordic packet Hex:deadbeef");
    expect(state.getLogSnapshot().logs.some((entry: any) => entry.message.includes("deadbeef"))).toBe(true);
  });

  it("Nordic 持锁恢复按原ID连接并读版本，普通手动连接仍被锁阻止", async () => {
    const { state, adapter } = sharedContext(); const release = state.beginOtaOperation(() => {});
    await expect(state.connectSelectedDevice()).rejects.toThrow("升级");
    await expect(state.restoreNordicApplication({ deviceId: "ring", name: "BCL" }, () => {})).resolves.toEqual({ deviceId: "ring", version: "6.2.6.2Z5Z" });
    expect(adapter.connectWechatRingSDK).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "ring", connectTimeoutMs: 5000 }));
    expect(state.getStatusSnapshot().connected).toBe(true); release();
  });
  it("应用态版本读取失败清理候选会话，不留下已连接假象", async () => {
    const { state, sdk, session, listeners } = sharedContext();
    const release = state.beginOtaOperation(() => {}); sdk.getFirmwareVersion.mockRejectedValueOnce(new Error("版本读取失败"));
    await expect(state.restoreNordicApplication({ deviceId: "ring" }, () => {})).rejects.toThrow("版本读取失败");
    expect(state.getStatusSnapshot().connected).toBe(false); expect(session.disconnect).toHaveBeenCalledOnce(); expect(listeners.size).toBe(0); release();
  });
  it("取消后迟到的普通连接会清理，不能发布到全局会话", async () => {
    const { state, adapter, session } = sharedContext(); const release = state.beginOtaOperation(() => {});
    let ready: any; let cancelled = false;
    adapter.connectWechatRingSDK.mockImplementationOnce(() => new Promise((resolve) => { ready = resolve; }));
    const task = state.restoreNordicApplication({ deviceId: "ring" }, () => { if (cancelled) throw new Error("已取消"); });
    cancelled = true; ready(session);
    await expect(task).rejects.toThrow("已取消");
    expect(state.getStatusSnapshot().connected).toBe(false); expect(session.disconnect).toHaveBeenCalledOnce(); release();
  });

  it("App 后台调用共享取消函数", () => {
    let app: any;
    const cancel = vi.fn();
    loadScript("app.js", { "./utils/demo-state": { getAppState: () => ({ cancelOta: cancel }) } }, { App(value: any) { app = value; } });
    app.onHide();
    expect(cancel).toHaveBeenCalledExactlyOnceWith("background");
  });
});
