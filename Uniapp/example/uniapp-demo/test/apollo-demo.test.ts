import { afterEach, describe, expect, it, vi } from "vitest";
import { readFileSync } from "node:fs";
import { ApolloDemoController, createApolloDemoState, prepareApolloTransport, upgradeBlockReason, validateApolloMtu } from "../utils/apollo-ota";
import { chooseChatFirmware, createFirmwareNetwork, downloadFirmware, normalizeFirmwareList, OtaDiagnostics, readFirmware, safeLogValue } from "../utils/wechat-platform";
import { APOLLO_OTA_NOTIFY_UUID, APOLLO_OTA_SERVICE_UUID, APOLLO_OTA_WRITE_UUID, createUniAppRingSDK } from "../libs/bcl-ring-sdk.js";

/** 真实协议格式的最小固件，正文长度写入头部偏移 8。 */
function firmware(size = 3): Uint8Array {
  const bytes = new Uint8Array(48 + size);
  new DataView(bytes.buffer).setUint32(8, size, true);
  return bytes;
}
/** 微信/Uni BLE 底层 mock；不替换协议校验、通道匹配或状态控制器。 */
function fixture() {
  let notify: (event: any) => void = () => {};
  const disconnectListeners = new Set<(event: any) => void>();
  const fileSystem = {
    readFile: vi.fn((o) => o.success({ data: firmware().buffer })),
    unlink: vi.fn((o) => o.success({})),
    writeFile: vi.fn((o) => o.success({})),
    appendFile: vi.fn((o) => o.success({})),
  };
  const rows = Array.from({ length: 15 }, (_, i) => ({ fileName: `fw${i}.bin`, fileUrl: `https://example.com/${i}.bin?token=secret` }));
  const api: any = {
    env: { USER_DATA_PATH: "/user" }, getFileSystemManager: () => fileSystem,
    getDeviceInfo: vi.fn(() => ({ platform: "ios" })),
    setBLEMTU: vi.fn((o) => o.success({ mtu: 512 })),
    getBLEMTU: vi.fn((o) => o.success({ mtu: 247 })),
    request: vi.fn((o) => o.success({ statusCode: 200, data: { status: 200, result: rows } })),
    downloadFile: vi.fn((o) => { o.success({ statusCode: 200, tempFilePath: "/tmp/download.bin" }); return {}; }),
    chooseMessageFile: vi.fn((o) => o.success({ tempFiles: [{ name: "chat.bin", path: "/chat/tmp.bin" }] })),
    onBLEConnectionStateChange: vi.fn((listener) => disconnectListeners.add(listener)),
    offBLEConnectionStateChange: vi.fn((listener) => disconnectListeners.delete(listener)),
    setKeepScreenOn: vi.fn(),
  };
  const ble: any = {
    getBLEDeviceServices: vi.fn((o) => o.success({ services: [{ uuid: APOLLO_OTA_SERVICE_UUID }] })),
    getBLEDeviceCharacteristics: vi.fn((o) => o.success({ characteristics: [
      { uuid: APOLLO_OTA_WRITE_UUID, properties: { writeNoResponse: true } },
      { uuid: APOLLO_OTA_NOTIFY_UUID, properties: { notify: true } },
    ] })),
    notifyBLECharacteristicValueChange: vi.fn((o) => o.success()),
    writeBLECharacteristicValue: vi.fn((o) => o.success()),
    onBLECharacteristicValueChange: vi.fn((listener) => { notify = listener; }),
    offBLECharacteristicValueChange: vi.fn(),
  };
  const sdk: any = {
    startApolloUpgrade: vi.fn(async (_transport, _bytes, options) => {
      options.onProgress({ state: "verifying", percent: 100, totalBytes: 3, acknowledgedBytes: 3 });
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: 3 };
    }),
    stopApolloUpgrade: vi.fn(), getFirmwareVersion: vi.fn(async () => ({ version: "7.3.5.5Z5X" })),
  };
  const session: any = { sdk, channel: { deviceId: "ring", serviceId: "0001", writeCharacteristicId: "0010", notifyCharacteristicId: "0011" } };
  let currentSession = session;
  let externalBusy = false;
  const log = vi.fn();
  const packetTrace = vi.fn();
  const busyChanged = vi.fn();
  const reconnect = vi.fn(async () => { currentSession = session; return session; });
  const state = createApolloDemoState();
  const controller = new ApolloDemoController(state, { api, ble, getSession: () => currentSession, reconnect,
    externalBusy: () => externalBusy, log, packetTrace, busyChanged });
  return { api, ble, sdk, session, fileSystem, rows, state, controller, log, packetTrace, busyChanged, reconnect, disconnectListeners,
    disconnect: () => { currentSession = null; controller.cancel("设备断连"); },
    setExternalBusy: (value: boolean) => { externalBusy = value; },
    emitNotify: (event: any) => notify(event) };
}

afterEach(() => vi.useRealTimers());

describe("Uni-app 微信 Apollo 固件来源", () => {
  it("查询完整历史列表后先选再下载，不自动下载首项", async () => {
    const f = fixture();
    await f.controller.query();
    expect(f.state.rows).toHaveLength(15);
    expect(f.state.selectedIndex).toBe(-1);
    expect(f.api.downloadFile).not.toHaveBeenCalled();
    f.controller.select(12);
    await f.controller.download();
    expect(f.api.downloadFile.mock.calls[0][0].url).toBe(f.rows[12].fileUrl);
    expect(f.state).toMatchObject({ ready: true, fileName: "fw12.bin", fileSize: 51, bodySize: 3 });
    expect(f.sdk.startApolloUpgrade).not.toHaveBeenCalled();
    expect(f.fileSystem.unlink).toHaveBeenCalledWith(expect.objectContaining({ filePath: "/tmp/download.bin" }));
  });
  it("来源、分类、Token 和版本变更使旧固件失效", async () => {
    const f = fixture();
    await f.controller.chooseChat();
    f.controller.changeSource("network"); expect(f.state.ready).toBe(false);
    await f.controller.query(); f.controller.select(0); await f.controller.download();
    f.controller.select(1); expect(f.state.ready).toBe(false);
    await f.controller.download();
    f.controller.changeQuery("new", "token");
    expect(f.state).toMatchObject({ ready: false, rows: [], selectedIndex: -1 });
  });
  it("空列表和无效条目不会下载；不把 filePath 当网络地址", async () => {
    const f = fixture();
    f.api.request.mockImplementation((o: any) => o.success({ statusCode: 200, data: { status: 200, result: [] } }));
    await f.controller.query();
    expect(f.state.fileStatus).toContain("暂无");
    const rows = normalizeFirmwareList([{ fileName: "../x.bin", fileUrl: "https://example.com/x.bin" },
      { fileName: "a.bin", filePath: "https://example.com/x.bin" }, { fileName: "a.bin", fileUrl: "http://example.com/x.bin" }]);
    expect(rows.every((r) => !r.selectable)).toBe(true);
    await f.controller.download(); expect(f.api.downloadFile).not.toHaveBeenCalled();
  });
  it("聊天取消不报告失败，且不能升级之前的文件", async () => {
    const f = fixture(); await f.controller.chooseChat();
    f.api.chooseMessageFile.mockImplementation((o: any) => o.fail({ errMsg: "chooseMessageFile:fail cancel" }));
    await f.controller.chooseChat();
    expect(f.state).toMatchObject({ ready: false, fileBusy: false, fileStatus: "已取消选择文件" });
    await f.controller.start(); expect(f.sdk.startApolloUpgrade).not.toHaveBeenCalled();
  });
  it("错误的文件类型、正文长度或文本读取均不可升级", async () => {
    const f = fixture();
    f.api.chooseMessageFile.mockImplementation((o: any) => o.success({ tempFiles: [{ name: "bad.txt", path: "/tmp/a" }] }));
    await f.controller.chooseChat(); expect(f.state.ready).toBe(false);
    f.fileSystem.readFile.mockImplementation((o: any) => o.success({ data: "text" }));
    await expect(readFirmware(f.api, "/tmp/a", "a.bin")).rejects.toThrow("二进制");
    f.fileSystem.readFile.mockImplementation((o: any) => o.success({ data: new Uint8Array(100).buffer }));
    await expect(readFirmware(f.api, "/tmp/a", "a.bin")).rejects.toThrow("长度");
  });
  it("项目提供的真实 Apollo 测试固件能通过相同入口校验", async () => {
    const f = fixture();
    const bytes = readFileSync(new URL("../../../firmware/apollo/BCL603S3L_7.3.5.5Z5X.bin", import.meta.url));
    f.fileSystem.readFile.mockImplementation((o: any) => o.success({ data: Uint8Array.from(bytes).buffer }));
    await f.controller.chooseChat(); expect(f.state).toMatchObject({ fileSize: 406084, bodySize: 406036, ready: true });
  });
  it("HTTP 下载失败清理临时文件并保持开始按钮禁用", async () => {
    const f = fixture(); await f.controller.query(); f.controller.select(0);
    f.api.downloadFile.mockImplementation((o: any) => { o.success({ statusCode: 403, tempFilePath: "/tmp/failed" }); return {}; });
    await f.controller.download();
    expect(f.state.ready).toBe(false); expect(f.state.fileStatus).toContain("403");
    expect(f.fileSystem.unlink.mock.calls[0][0].filePath).toBe("/tmp/failed");
  });
  it("网络/读取失败会显示原始原因并释放互斥锁", async () => {
    const f = fixture();
    f.api.request.mockImplementation((o: any) => o.fail({ errMsg: "request:fail domain" }));
    await f.controller.query(); expect(f.state.fileStatus).toContain("domain");
    f.fileSystem.readFile.mockImplementation((o: any) => o.fail({ errMsg: "readFile:fail missing" }));
    await f.controller.chooseChat(); expect(f.state.fileStatus).toContain("missing");
    expect(f.busyChanged).toHaveBeenLastCalledWith(false);
  });
});

describe("Uni-app Apollo MTU 与原始通道", () => {
  it("iOS 和未知平台不调用 setBLEMTU，读取无响应写 MTU", async () => {
    const f = fixture();
    for (const platform of ["ios", "unknown"]) {
      f.api.getDeviceInfo.mockReturnValue({ platform });
      expect(await validateApolloMtu(f.api, f.session, f.log)).toBe(247);
    }
    expect(f.api.setBLEMTU).not.toHaveBeenCalled();
    expect(f.api.getBLEMTU).toHaveBeenCalledWith(expect.objectContaining({ writeType: "writeNoResponse" }));
  });
  it("Android 协商失败仍可使用真实读取的有效 MTU", async () => {
    const f = fixture(); f.api.getDeviceInfo.mockReturnValue({ platform: "android" });
    f.api.setBLEMTU.mockImplementation((o: any) => o.fail({ errMsg: "failed" }));
    expect(await validateApolloMtu(f.api, f.session, f.log)).toBe(247);
    expect(f.api.setBLEMTU).toHaveBeenCalledWith(expect.objectContaining({ mtu: 512 }));
  });
  it("不得把 Android 请求 512 或旧 session 值伪装为实际 MTU", async () => {
    const f = fixture(); f.api.getDeviceInfo.mockReturnValue({ platform: "android" });
    f.session.mtu = 512;
    for (const value of [23, 239, 0, NaN]) {
      f.api.getBLEMTU.mockImplementation((o: any) => o.success({ mtu: value }));
      await expect(validateApolloMtu(f.api, f.session, f.log)).rejects.toThrow("至少 240");
    }
    delete f.api.getBLEMTU;
    await expect(validateApolloMtu(f.api, f.session, f.log)).rejects.toThrow("真实 MTU");
  });
  it("缺少无响应写能力时拒绝升级", async () => {
    const f = fixture();
    f.ble.getBLEDeviceCharacteristics.mockImplementation((o: any) => o.success({ characteristics: [
      { uuid: APOLLO_OTA_WRITE_UUID, properties: { write: true } }, { uuid: APOLLO_OTA_NOTIFY_UUID, properties: { notify: true } },
    ] }));
    await expect(prepareApolloTransport(f.ble, f.api, f.session)).rejects.toThrow("无响应");
  });
  it("独立通道不过命令队列，仅接收本设备 Apollo 通知并释放监听", async () => {
    const f = fixture(); const transport = await prepareApolloTransport(f.ble, f.api, f.session);
    await transport.write(new Uint8Array([1, 2, 3]));
    expect(f.ble.writeBLECharacteristicValue).toHaveBeenCalledTimes(1);
    expect(f.ble.writeBLECharacteristicValue.mock.calls[0][0]).toMatchObject({ serviceId: APOLLO_OTA_SERVICE_UUID,
      characteristicId: APOLLO_OTA_WRITE_UUID, writeType: "writeNoResponse" });
    const callback = vi.fn(); const stopNotify = transport.onNotification(callback);
    f.emitNotify({ deviceId: "other", serviceId: APOLLO_OTA_SERVICE_UUID, characteristicId: APOLLO_OTA_NOTIFY_UUID, value: new ArrayBuffer(4) });
    expect(callback).not.toHaveBeenCalled();
    f.emitNotify({ deviceId: "ring", serviceId: APOLLO_OTA_SERVICE_UUID.toLowerCase(), characteristicId: APOLLO_OTA_NOTIFY_UUID.toLowerCase(), value: new ArrayBuffer(4) });
    expect(callback).toHaveBeenCalledTimes(1);
    const disconnected = vi.fn(); const stopDisconnect = transport.onDisconnect(disconnected);
    for (const listener of f.disconnectListeners) listener({ deviceId: "other", connected: false });
    expect(disconnected).not.toHaveBeenCalled();
    for (const listener of f.disconnectListeners) listener({ deviceId: "ring", connected: false });
    expect(disconnected).toHaveBeenCalledTimes(1);
    stopDisconnect(); stopNotify(); expect(f.disconnectListeners.size).toBe(0); expect(f.ble.offBLECharacteristicValueChange).toHaveBeenCalled();
  });
});

describe("Uni-app Apollo 任务、取消与结果", () => {
  it("高频 Hex 批量输出、进度限频，正文 100% 仍立即展示", async () => {
    const f = fixture(); await f.controller.chooseChat();
    f.sdk.startApolloUpgrade.mockImplementation(async (_transport, _bytes, options) => {
      for (let i = 0; i < 100; i++) {
        options.debug({ type: "write", state: "sendingData", command: 2, offset: i * 512, hex: "ab".repeat(1000) });
        options.onProgress({ state: "sendingData", percent: i, acknowledgedBytes: i * 512, totalBytes: 51200 });
      }
      options.onProgress({ state: "sendingData", percent: 100, acknowledgedBytes: 51200, totalBytes: 51200 });
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: 51200 };
    });
    await f.controller.start();
    expect(f.state.otaPercent).toBe(100);
    expect(f.packetTrace.mock.calls.length).toBeLessThan(25);
    expect(f.packetTrace.mock.calls.flat().join("\n").match(/Hex:/g)).toHaveLength(100);
    expect(f.log.mock.calls.filter(([line]) => line.includes("传输正文")).length).toBeLessThan(10);
    expect(f.log.mock.calls.flat().join("\n")).toContain("Apollo 传输统计");
  });
  it("失败也输出不足批量阈值的原始 Hex 尾部", async () => {
    const f = fixture(); await f.controller.chooseChat();
    f.sdk.startApolloUpgrade.mockImplementation(async (_transport, _bytes, options) => {
      options.debug({ type: "write", state: "sendingHeader", command: 1, offset: 0, hex: "abcd" });
      throw new Error("test failed");
    });
    await f.controller.start();
    expect(f.state.otaStatus).toBe("升级失败");
    expect(f.packetTrace.mock.calls.flat().join("\n")).toContain("Hex:abcd");
  });
  it("未连接或首页正忙时不能开始，文件保留", async () => {
    const f = fixture(); await f.controller.chooseChat(); f.setExternalBusy(true);
    await f.controller.start(); expect(f.sdk.startApolloUpgrade).not.toHaveBeenCalled();
    f.setExternalBusy(false); f.disconnect();
    expect(upgradeBlockReason(f.state, false, false)).toContain("先连接");
    await f.controller.start(); expect(f.state.ready).toBe(true);
  });
  it("有效连接使用固定 237 字节；仅显示协议完成，重连读取真实版本", async () => {
    const f = fixture(); await f.controller.chooseChat(); await f.controller.start();
    expect(f.sdk.startApolloUpgrade.mock.calls[0][2]).toMatchObject({ payloadSize: 237, intervalMs: 0, timeoutMs: 10000 });
    expect(f.state.protocolCompleted).toBe(true); expect(f.state.result).toContain("可重连查看当前固件版本");
    expect(f.state.result).not.toContain("目标版本");
    expect(f.api.setKeepScreenOn).toHaveBeenLastCalledWith(expect.objectContaining({ keepScreenOn: false }));
    await f.controller.reconnectReadVersion(); expect(f.reconnect).toHaveBeenCalled(); expect(f.state.result).toContain("7.3.5.5Z5X");
  });
  it("真正的 SDK 状态机经过专用 BLE 完成四条命令并输出 Hex", async () => {
    const f = fixture();
    f.session.sdk = createUniAppRingSDK({ uni: f.ble, channel: f.session.channel });
    const commands: number[] = [];
    f.ble.writeBLECharacteristicValue.mockImplementation((o: any) => {
      const bytes = new Uint8Array(o.value); commands.push(bytes[2]); o.success();
      f.emitNotify({ deviceId: "ring", serviceId: APOLLO_OTA_SERVICE_UUID, characteristicId: APOLLO_OTA_NOTIFY_UUID,
        value: new Uint8Array([1, 0, bytes[2], 0]).buffer });
    });
    await f.controller.chooseChat(); await f.controller.start();
    expect(commands).toEqual([1, 2, 3, 4]); expect(f.state.protocolCompleted).toBe(true);
    expect(f.packetTrace.mock.calls.flat().join("\n")).toContain("Hex:");
    expect(f.log.mock.calls.flat().join("\n")).not.toContain("Hex:");
    expect(f.disconnectListeners.size).toBe(0);
    f.session.sdk.close();
  });
  it("准备通道时取消/后台/断连/销毁，晚到回调不会开始 OTA", async () => {
    for (const action of ["cancel", "background", "disconnect", "dispose"]) {
      const f = fixture(); await f.controller.chooseChat();
      let services: any;
      f.ble.getBLEDeviceServices.mockImplementation((o: any) => { services = o; });
      const pending = f.controller.start();
      if (action === "disconnect") f.disconnect();
      else if (action === "dispose") f.controller.dispose();
      else f.controller.cancel(action);
      await pending;
      services.success({ services: [{ uuid: APOLLO_OTA_SERVICE_UUID }] });
      await Promise.resolve(); await Promise.resolve();
      expect(f.sdk.startApolloUpgrade).not.toHaveBeenCalled(); expect(f.sdk.stopApolloUpgrade).toHaveBeenCalled();
      expect(f.api.setKeepScreenOn).toHaveBeenLastCalledWith(expect.objectContaining({ keepScreenOn: false }));
    }
  });
  it("准备超时释放锁，迟到回调不能续传", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseChat();
    f.ble.getBLEDeviceServices.mockImplementation(() => {});
    const pending = f.controller.start(); await vi.advanceTimersByTimeAsync(10001); await pending;
    expect(f.state.otaStatus).toBe("升级失败"); expect(f.state.result).toContain("超时"); expect(f.state.otaBusy).toBe(false);
  });
  it("传输被停止或 SDK 失败，不能显示协议完成", async () => {
    const f = fixture(); await f.controller.chooseChat();
    f.sdk.startApolloUpgrade.mockImplementation(async () => { throw new Error("设备拒绝升级"); });
    await f.controller.start(); expect(f.state.protocolCompleted).toBe(false); expect(f.state.result).toContain("设备拒绝");
    expect(f.busyChanged).toHaveBeenLastCalledWith(false);
  });
  it("真实 SDK 等待 ACK 时停止，清理通知及断连监听", async () => {
    const f = fixture();
    f.session.sdk = createUniAppRingSDK({ uni: f.ble, channel: f.session.channel });
    await f.controller.chooseChat();
    const pending = f.controller.start();
    // 到达真实写入后不回 ACK，模拟用户在传输阶段停止。
    for (let i = 0; i < 30 && f.ble.writeBLECharacteristicValue.mock.calls.length === 0; i++) await Promise.resolve();
    expect(f.ble.writeBLECharacteristicValue).toHaveBeenCalledTimes(1);
    f.controller.cancel(); await pending;
    expect(f.state.otaStatus).toBe("升级已停止"); expect(f.state.protocolCompleted).toBe(false);
    expect(f.disconnectListeners.size).toBe(0); expect(f.ble.offBLECharacteristicValueChange).toHaveBeenCalled();
    f.session.sdk.close();
  });
  it("正文 100% 后 verify/reset 尚未确认时不显示协议成功", async () => {
    const f = fixture(); await f.controller.chooseChat();
    f.sdk.startApolloUpgrade.mockImplementation(async (_transport: any, _bytes: any, options: any) => {
      options.onProgress({ state: "verifying", percent: 100, totalBytes: 3, acknowledgedBytes: 3 });
      expect(f.state.protocolCompleted).toBe(false); expect(f.state.result).toBe("");
      throw new Error("verify ACK 超时");
    });
    await f.controller.start(); expect(f.state.otaPercent).toBe(100);
    expect(f.state.protocolCompleted).toBe(false); expect(f.state.result).toContain("ACK 超时");
  });
  it("文件选择晚于页面销毁返回时不再读取固件", async () => {
    const f = fixture(); let choose: any;
    f.api.chooseMessageFile.mockImplementation((o: any) => { choose = o; });
    const pending = f.controller.chooseChat(); f.controller.dispose();
    choose.success({ tempFiles: [{ name: "a.bin", path: "/late" }] }); await pending;
    expect(f.fileSystem.readFile).not.toHaveBeenCalled(); expect(f.state.ready).toBe(false);
  });
  it("版本读取失败释放状态并展示原因", async () => {
    const f = fixture(); f.reconnect.mockRejectedValue(new Error("设备未重启"));
    await f.controller.reconnectReadVersion(); expect(f.state.result).toContain("设备未重启"); expect(f.state.versionBusy).toBe(false);
  });
});

describe("Uni-app OTA 网络与完整诊断", () => {
  it("不依赖全局 fetch，Token 与签名 URL 不泄露到请求/响应日志", async () => {
    const f = fixture();
    f.api.request.mockImplementation((o: any) => o.success({ statusCode: 200,
      header: { "Set-Cookie": "private-cookie" }, data: JSON.stringify({ status: 200, result: [{ fileName: "a.bin", fileUrl: "https://example.com/a?token=private-query" }], token: "private-response" }) }));
    const sdk = createFirmwareNetwork(f.api, "private-token", f.log);
    await sdk.getFirmwareVersionList("z5x");
    expect(f.api.request.mock.calls[0][0]).toMatchObject({ method: "GET", header: { Authorization: "Bearer private-token", access_token: "private-token" } });
    const logs = f.log.mock.calls.flat().join("\n");
    expect(f.api.request.mock.calls[0][0].url).toContain("category=Z5X");
    expect(logs).toContain("参数已脱敏");
    for (const secret of ["private-token", "private-response", "private-query", "private-cookie"]) expect(logs).not.toContain(secret);
  });
  it("拒绝非 2xx 列表响应，失败原因 URL 参数脱敏", async () => {
    const f = fixture();
    f.api.request.mockImplementation((o: any) => o.success({ statusCode: 401, data: "bad" }));
    await expect(createFirmwareNetwork(f.api, "", f.log).getFirmwareVersionList("z5x")).rejects.toThrow("401");
    f.api.request.mockImplementation((o: any) => o.fail({ errMsg: "failed https://example.com/a?token=secret" }));
    await expect(createFirmwareNetwork(f.api, "", f.log).getFirmwareVersionList("z5x")).rejects.toThrow("参数已脱敏");
    expect(f.log.mock.calls.flat().join("\n")).not.toContain("token=secret");
  });
  it("诊断顺序保留全部日志；写入失败可见且不阻断业务", async () => {
    const f = fixture(); const failure = vi.fn(); const diagnostics = new OtaDiagnostics(f.api, failure);
    for (let i = 0; i < 350; i++) diagnostics.append(`log-${i}`);
    await diagnostics.flush(); expect(f.fileSystem.appendFile).toHaveBeenCalledTimes(350);
    expect(f.fileSystem.appendFile.mock.calls[349][0].data).toBe("log-349\n");
    f.fileSystem.appendFile.mockImplementation((o: any) => o.fail({ errMsg: "disk full" }));
    diagnostics.append("failed"); diagnostics.append("after failure"); await diagnostics.flush();
    expect(failure).toHaveBeenCalledTimes(1); expect(failure.mock.calls[0][0]).toContain("disk full");
    expect(safeLogValue({ authorization: "secret", url: "https://example.com/file?sig=secret" })).not.toContain("secret");
  });
});
