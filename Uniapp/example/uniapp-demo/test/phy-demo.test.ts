import { afterEach, describe, expect, it, vi } from "vitest";
import { PhyDemoController, createPhyDemoState, type PhyDevice } from "../../shared/phy-demo";
import { PHY_OTA_SERVICE_UUID, PHY_OTA_COMMAND_UUID, PHY_OTA_DATA_UUID, PHY_OTA_NOTIFY_UUID } from "../../../packages/protocol-core/src";

/** 使用真实 HEX 解析和真实 SDK，仅将小程序 API 替换为可注入事件。 */
function fixture(initialBoot = false) {
  const hex = ":020000041102E7\n:0100000007F8\n:00000001FF";
  const bytes = new TextEncoder().encode(hex);
  const values = new Set<(e: any) => void>(); const links = new Set<(e: any) => void>(); const found = new Set<(e: any) => void>();
  const storage = new Map<string, unknown>(); const files = new Map<string, Uint8Array>([["/chat.hex16", bytes]]);
  const app: PhyDevice = { deviceId: "app-uuid", name: "Ring", macAddress: "AA:BB:CC:DD:EE:01" };
  const boot: PhyDevice = { deviceId: "boot-uuid", name: "PPLUSOTA", macAddress: "AA:BB:CC:DD:EE:02" };
  let connected: PhyDevice | null = initialBoot ? null : app; let mode = initialBoot ? "boot" : "app";
  let duplicate = false; let remainBoot = false; let remaining = 0;
  const advertisement = (device: PhyDevice, isBoot: boolean): object => ({ ...device,
    // Boot 不是普通厂商数据格式，验证恢复扫描不依赖普通 FF 过滤。
    advertisData: new Uint8Array([0, isBoot ? 0 : 255, ...device.macAddress!.split(":").map((s) => parseInt(s, 16)).reverse()]).buffer });
  const fs = {
    stat: vi.fn((o: any) => files.has(o.path) ? o.success({ stats: { size: files.get(o.path)!.length } }) : o.fail({ errMsg: "file missing" })),
    readFile: vi.fn((o: any) => o.success({ data: files.get(o.filePath)!.slice().buffer })),
    writeFile: vi.fn((o: any) => { files.set(o.filePath, new Uint8Array(o.data)); o.success(); }),
    unlink: vi.fn((o: any) => { files.delete(o.filePath); o.success(); }),
  };
  const notify = (o: any, code: number): void => {
    for (const cb of values) cb({ ...o, characteristicId: PHY_OTA_NOTIFY_UUID, value: new Uint8Array([0, code]).buffer });
  };
  const api: any = {
    env: { USER_DATA_PATH: "/user" }, getFileSystemManager: () => fs, getDeviceInfo: () => ({ platform: "ios" }),
    getStorageSync: (key: string) => storage.get(key), setStorageSync: (key: string, value: unknown) => storage.set(key, structuredClone(value)), removeStorageSync: (key: string) => storage.delete(key),
    chooseMessageFile: vi.fn((o) => o.success({ tempFiles: [{ path: "/chat.hex16", name: "firmware.hex16", size: bytes.length }] })),
    openBluetoothAdapter: vi.fn((o) => o.success()),
    onBluetoothDeviceFound: (cb: any) => found.add(cb), offBluetoothDeviceFound: (cb: any) => found.delete(cb),
    startBluetoothDevicesDiscovery: vi.fn((o) => {
      const device = mode === "app" ? advertisement(app, false) : advertisement(boot, true);
      for (const cb of found) cb({ devices: [device, ...(duplicate ? [{ ...device, deviceId: "collision" }] : [])] }); o.success();
    }),
    stopBluetoothDevicesDiscovery: vi.fn((o) => o.success()),
    onBLECharacteristicValueChange: (cb: any) => values.add(cb), offBLECharacteristicValueChange: (cb: any) => values.delete(cb),
    onBLEConnectionStateChange: (cb: any) => links.add(cb), offBLEConnectionStateChange: (cb: any) => links.delete(cb),
    createBLEConnection: vi.fn((o) => o.success()), closeBLEConnection: vi.fn((o) => o.success()),
    getBLEDeviceServices: vi.fn((o) => o.success({ services: [{ uuid: PHY_OTA_SERVICE_UUID }] })),
    getBLEDeviceCharacteristics: vi.fn((o) => o.success({ characteristics: [
      { uuid: PHY_OTA_COMMAND_UUID, properties: { write: true } }, { uuid: PHY_OTA_DATA_UUID, properties: { writeNoResponse: true } },
      { uuid: PHY_OTA_NOTIFY_UUID, properties: { notify: true } },
    ] })),
    notifyBLECharacteristicValueChange: vi.fn((o) => o.success()),
    getBLEMTU: vi.fn((o) => o.success({ mtu: 240 })), setBLEMTU: vi.fn((o) => o.success()),
    writeBLECharacteristicValue: vi.fn((o) => {
      const b = new Uint8Array(o.value);
      if (o.characteristicId === PHY_OTA_DATA_UUID) { remaining -= b.length; if (!remaining) notify(o, 0x83); }
      else if (b[0] === 1 && b.length === 2) {
        mode = "boot"; connected = null;
        for (const cb of links) cb({ deviceId: app.deviceId, connected: false });
      } else if (b[0] === 1) notify(o, 0x81);
      else if (b[0] === 2) { remaining = new DataView(b.buffer).getUint32(10, true); notify(o, 0x84); }
      else if (b[0] === 4 && !remainBoot) mode = "app";
      o.success();
    }),
  };
  const release = vi.fn(); const acquire = vi.fn(() => release); const log = vi.fn();
  const restore = vi.fn(async (target: PhyDevice, assertActive: () => void) => { assertActive(); connected = target; return { deviceId: target.deviceId, version: "2.8.8.3Z4J" }; });
  const create = () => {
    const state = createPhyDemoState(); const controller = new PhyDemoController(api, state, vi.fn(), log, acquire, () => connected, restore);
    return { state, controller };
  };
  return { ...create(), create, api, storage, files, fs, values, links, found, app, boot, release, restore,
    setDuplicate: () => { duplicate = true; }, setRemainBoot: () => { remainBoot = true; },
    setConnected: (value: PhyDevice | null) => { connected = value; } };
}
/** 仅推进模拟平台扫描/超时，不跳过真实 Promise 协议步骤。 */
async function finish(task: Promise<void>): Promise<void> { await vi.runAllTimersAsync(); await task; }
/** 选择并确认文件，模拟用户在页面的明确操作。 */
async function prepare(f: ReturnType<typeof fixture>): Promise<void> {
  await f.controller.chooseFile(); f.controller.confirm(true);
}
afterEach(() => vi.useRealTimers());

describe("双 Demo PHY 持久恢复和连接协调", () => {
  it("正常升级精确搜索 MAC+1、0083 持久化、重启后读回版本再清除记录", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f); await finish(f.controller.start());
    expect(f.state.reconnected).toBe(true); expect(f.state.protocolCompleted).toBe(true); expect(f.storage.size).toBe(0);
    expect(f.restore).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "app-uuid" }), expect.any(Function));
    expect(f.api.setBLEMTU).not.toHaveBeenCalled(); expect(f.values.size + f.links.size + f.found.size).toBe(0);
    expect(f.api.closeBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "boot-uuid" }));
  });
  it("没有内存记录也能直接选择 Boot 完整重刷，不发送 0102", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true);
    expect(f.api.writeBLECharacteristicValue.mock.calls.some(([o]: any[]) => new Uint8Array(o.value).length === 2)).toBe(false);
  });
  it("传输失败后重开控制器能加载原始固件并从头恢复", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    f.api.getBLEMTU.mockImplementationOnce((o: any) => o.success({ mtu: 23 }));
    await finish(f.controller.start()); expect(f.storage.size).toBe(1); expect(f.state.protocolCompleted).toBe(false);
    const next = f.create(); expect(next.state.hasRecovery).toBe(true); expect(next.state.ready).toBe(false);
    await next.controller.loadRecovery(); next.controller.confirm(true); await finish(next.controller.start());
    expect(next.state.reconnected).toBe(true); expect(f.storage.size).toBe(0);
  });
  it("同名相同 MAC 的不同平台 ID 冲突时停止，不能刷到另一只戒指", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true); f.setDuplicate();
    await finish(f.controller.start()); expect(f.state.status).toContain("多个设备"); expect(f.api.createBLEConnection).not.toHaveBeenCalled();
  });
  it("未确认适配以及 UUID 无 MAC 时不会发送模式切换", async () => {
    const f = fixture(); await f.controller.chooseFile(); await f.controller.start();
    expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled();
    f.setConnected({ deviceId: "uuid" }); f.controller.confirm(true); await f.controller.start();
    expect(f.state.status).toContain("MAC"); expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled();
  });
  it("恢复记录保存失败会在任何设备写入前终止", async () => {
    const f = fixture(); await prepare(f); f.api.setStorageSync = () => { throw new Error("storage full"); };
    await f.controller.start(); expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled(); expect(f.state.status).toContain("storage full");
  });
  it("小 MTU 不按 20 字节偷偷拆包，并保留恢复记录", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    f.api.getBLEMTU.mockImplementation((o: any) => o.success({ mtu: 23 })); await finish(f.controller.start());
    expect(f.state.status).toContain("至少 240"); expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled(); expect(f.state.hasRecovery).toBe(true);
  });
  it("0083 后 04 失败保留协议完成，重新核验只搜设备不重发固件", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    const original = f.api.writeBLECharacteristicValue.getMockImplementation();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      if (new Uint8Array(o.value)[0] === 4) { o.fail({ errMsg: "reset failed" }); return; } original(o);
    });
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(true); expect(f.storage.size).toBe(1);
    const writes = f.api.writeBLECharacteristicValue.mock.calls.length;
    await finish(f.controller.reconnect()); expect(f.api.writeBLECharacteristicValue).toHaveBeenCalledTimes(writes); expect(f.state.status).toContain("仍处于 Boot");
  });
  it("实际读回版本只用于展示，不参与升级完成或恢复记录清理的限制", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.restore.mockResolvedValueOnce({ deviceId: "app-uuid", version: "9.9.9Z3G" });
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true);
    expect(f.state.firmwareVersion).toBe("9.9.9Z3G"); expect(f.state.status).toContain("升级完成"); expect(f.storage.size).toBe(0);
  });
  it("扫描时取消会注销监听，不继续连接或发包", async () => {
    vi.useFakeTimers(); const f = fixture(true); const task = f.controller.scan();
    await vi.advanceTimersByTimeAsync(10); f.controller.cancel("background"); await finish(task);
    expect(f.found.size).toBe(0); expect(f.api.createBLEConnection).not.toHaveBeenCalled(); expect(f.state.busy).toBe(false);
  });
  it("取消后迟到的 Boot 连接必须关闭", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    let complete: any; f.api.createBLEConnection.mockImplementation((o: any) => { complete = o.success; });
    const task = f.controller.start(); await vi.advanceTimersByTimeAsync(5100); f.controller.cancel();
    await vi.advanceTimersByTimeAsync(10); expect(f.state.busy).toBe(true);
    // 真实连接回调未完成前保持全局锁，防止旧连接关闭新任务的同地址连接。
    complete(); await finish(task); expect(f.api.closeBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "boot-uuid" }));
    expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled();
  });
  it("后台不会取消文件选择，但卸载后迟到选择结果失效", async () => {
    const f = fixture(); let selected: any;
    f.api.chooseMessageFile.mockImplementation((o: any) => { selected = o; });
    const task = f.controller.chooseFile(); f.controller.cancel("background"); expect(f.state.busy).toBe(true);
    f.controller.dispose(); selected.success({ tempFiles: [{ path: "/chat.hex16", name: "firmware.hex16", size: 50 }] });
    await task; expect(f.state.ready).toBe(false); expect(f.fs.writeFile).not.toHaveBeenCalled();
  });
  it("恢复文件不存在或改变不会使用旧进度", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    f.api.getBLEMTU.mockImplementation((o: any) => o.success({ mtu: 23 })); await finish(f.controller.start());
    const record = [...f.storage.values()][0] as any; f.files.set(record.path, new Uint8Array([1, 2, 3]));
    const next = f.create(); await next.controller.loadRecovery(); expect(next.state.ready).toBe(false); expect(next.state.status).toContain("已改变");
  });
  it("无需填写目标版本即可完成升级并清除恢复记录", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseFile(); f.controller.confirm(true);
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true); expect(f.state.status).toContain("升级完成");
    expect(f.state.hasRecovery).toBe(false); expect(f.state).not.toHaveProperty("expectedVersion");
    expect(f.state).not.toHaveProperty("versionVerified");
  });
  it("旧恢复记录中的错误目标版本不再参与判断，新记录不保存目标版本", async () => {
    vi.useFakeTimers(); const f = fixture(true); await prepare(f); f.controller.selectDevice(f.boot); f.controller.confirm(true);
    f.api.getBLEMTU.mockImplementationOnce((o: any) => o.success({ mtu: 23 })); await finish(f.controller.start());
    const [key, record] = [...f.storage.entries()][0];
    expect(record).not.toHaveProperty("expectedVersion");
    f.storage.set(key, { ...(record as object), expectedVersion: "legacy-wrong-version" });
    const next = f.create(); expect(next.state.hasRecovery).toBe(true);
    await next.controller.loadRecovery(); next.controller.confirm(true); await finish(next.controller.start());
    expect(next.state.reconnected).toBe(true); expect(next.state.hasRecovery).toBe(false); expect(f.storage.size).toBe(0);
  });
  it("旧应用态恢复超时后重试不能让旧回调重新有效", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    let assertOld!: () => void;
    f.restore.mockImplementationOnce(async (_target, assertActive) => {
      assertOld = assertActive; await new Promise<void>(() => {}); return { deviceId: "app-uuid", version: "2.8.8.3Z4J" };
    });
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(true);
    expect(() => assertOld()).toThrow();
    const task = f.controller.reconnect(); await vi.advanceTimersByTimeAsync(1);
    expect(() => assertOld()).toThrow(); await finish(task); expect(f.state.reconnected).toBe(true);
  });

  it("扫描启动取消后保持锁到真实回调结束，迟到停止不会误伤下一次扫描", async () => {
    vi.useFakeTimers(); const f = fixture(true); let started!: () => void;
    f.api.startBluetoothDevicesDiscovery.mockImplementationOnce((o: any) => { started = o.success; });
    const task = f.controller.scan(); await vi.advanceTimersByTimeAsync(1); f.controller.cancel();
    await vi.advanceTimersByTimeAsync(10); expect(f.state.busy).toBe(true); expect(f.release).not.toHaveBeenCalled();
    started(); await finish(task); expect(f.state.busy).toBe(false); expect(f.release).toHaveBeenCalledOnce();
    await finish(f.controller.scan()); expect(f.state.devices).toHaveLength(1);
  });

  it("应用态只有 FF02/FF03 时仍发送 0102，进入 Boot 后重新校验 FF04", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.api.getBLEDeviceCharacteristics.mockImplementationOnce((o: any) => o.success({ characteristics: [
      { uuid: PHY_OTA_COMMAND_UUID, properties: { write: true } },
      { uuid: PHY_OTA_NOTIFY_UUID, properties: { notify: true } },
    ] }));
    await finish(f.controller.start());
    expect(new Uint8Array(f.api.writeBLECharacteristicValue.mock.calls[0][0].value)).toEqual(new Uint8Array([1, 2]));
    expect(f.state.reconnected).toBe(true);
    expect(f.api.getBLEDeviceCharacteristics.mock.calls.map(([o]: any[]) => o.deviceId)).toEqual(["app-uuid", "boot-uuid"]);
  });
  it("应用态仅有可写 FF02 也可切换，不依赖 Boot 通知通道", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.api.getBLEDeviceCharacteristics.mockImplementationOnce((o: any) => o.success({ characteristics: [
      { uuid: PHY_OTA_COMMAND_UUID, properties: { write: true } },
    ] }));
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true);
  });
  it("应用态缺少可写 FF02 时不会盲目发送切换指令", async () => {
    const f = fixture(); await prepare(f);
    f.api.getBLEDeviceCharacteristics.mockImplementationOnce((o: any) => o.success({ characteristics: [
      { uuid: PHY_OTA_COMMAND_UUID, properties: { writeNoResponse: true } },
    ] }));
    await f.controller.start(); expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled(); expect(f.state.status).toContain("应用态");
  });
  it("Boot 缺少 FF04 时仍拒绝固件传输，不因放宽应用态检查而放行", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => o.success({ characteristics: [
      { uuid: PHY_OTA_COMMAND_UUID, properties: { write: true } },
      { uuid: PHY_OTA_NOTIFY_UUID, properties: { notify: true } },
    ] }));
    await finish(f.controller.start());
    expect(f.api.writeBLECharacteristicValue).toHaveBeenCalledTimes(1);
    expect(new Uint8Array(f.api.writeBLECharacteristicValue.mock.calls[0][0].value)).toEqual(new Uint8Array([1, 2]));
    expect(f.state.status).toContain("Boot OTA"); expect(f.state.protocolCompleted).toBe(false);
    expect(f.state.hasRecovery).toBe(true);
  });

  it("0102 引发真实断连但写回调永远缺失时仍定位 Boot 完成升级并释放锁", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    const original = f.api.writeBLECharacteristicValue.getMockImplementation();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      const b = new Uint8Array(o.value);
      original(b[0] === 1 && b.length === 2 ? { ...o, success: () => {} } : o);
    });
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true);
    expect(f.state.busy).toBe(false); expect(f.release).toHaveBeenCalled(); expect(f.links.size).toBe(0);
  });
  it("0102 断连引起写入失败回调也不阻止按新鲜 Boot 身份继续验证", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    const original = f.api.writeBLECharacteristicValue.getMockImplementation();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      const b = new Uint8Array(o.value);
      original(b[0] === 1 && b.length === 2 ? { ...o, success: () => o.fail({ errMsg: "disconnected" }) } : o);
    });
    await finish(f.controller.start()); expect(f.state.reconnected).toBe(true);
  });
  it("0102 只有写成功、没有目标断连时不能开始 Boot 扫描", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.api.writeBLECharacteristicValue.mockImplementationOnce((o: any) => {
      for (const cb of f.links) cb({ deviceId: "other-device", connected: false }); o.success();
    });
    await finish(f.controller.start()); expect(f.state.status).toContain("真实断连");
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled(); expect(f.state.busy).toBe(false);
  });
  it("04 先断连且没有写回调时保留0083并继续应用态恢复和版本展示", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    const original = f.api.writeBLECharacteristicValue.getMockImplementation();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      const b = new Uint8Array(o.value);
      if (b[0] === 4) {
        original({ ...o, success: () => {} });
        for (const cb of f.links) cb({ deviceId: o.deviceId, connected: false });
      } else original(o);
    });
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(true); expect(f.state.reconnected).toBe(true);
    expect(f.state.busy).toBe(false); expect(f.links.size).toBe(0);
  });
  it("等待0102时取消后，迟到真实断连能解除旧写入排空且不再搜索", async () => {
    vi.useFakeTimers(); const f = fixture(); await prepare(f);
    f.api.writeBLECharacteristicValue.mockImplementationOnce(() => {});
    const task = f.controller.start(); await vi.advanceTimersByTimeAsync(1); f.controller.cancel();
    await vi.advanceTimersByTimeAsync(1); expect(f.state.busy).toBe(true);
    for (const cb of f.links) cb({ deviceId: f.app.deviceId, connected: false });
    await finish(task); expect(f.state.busy).toBe(false); expect(f.links.size).toBe(0);
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
  });

});
