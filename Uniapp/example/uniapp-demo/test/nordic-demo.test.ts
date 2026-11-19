import { afterEach, describe, expect, it, vi } from "vitest";
import { NordicDemoController, createNordicDemoState } from "../../shared/nordic-demo";
import { NORDIC_DFU_BUTTONLESS_BONDED_UUID, NORDIC_GATT_SERVICE_UUID, NORDIC_SERVICE_CHANGED_UUID, NORDIC_DFU_SERVICE_UUID, NORDIC_DFU_CONTROL_UUID, NORDIC_DFU_PACKET_UUID, NORDIC_DFU_BUTTONLESS_UUID, nordicCrc32 } from "../../../packages/protocol-core/src/index";

/** 平台 mock 保留真实 SDK 执行器，验证两个 Demo 共用的实际协调流程。 */
function fixture(bonded = false, autoReconnect = false) {
  const values = new Set<(e: any) => void>(); const links = new Set<(e: any) => void>(); const found = new Set<(e: any) => void>();
  // 模拟应用态切换后当前会话消失，扫描得到临时名对应的新设备。
  let connected: { deviceId: string; name?: string } | null = { deviceId: "app", name: "我的戒指" };
  let bootName = "";
  // 绑定模式复用原 deviceId，切换后以相同标识暴露新服务。
  let entered = false;
  const image = new Uint8Array([1, 2, 3]); const init = new Uint8Array([9]);
  const buffers: Record<number, number[]> = { 1: [], 2: [] }; let type = 1;
  const fs: any = {
    mkdir: vi.fn((o) => o.success({})), unzip: vi.fn((o) => o.success({})), rmdir: vi.fn((o) => o.success({})),
    stat: vi.fn((o) => o.success({ stats: { size: o.path.endsWith(".dat") ? 1 : 3 } })),
    readFile: vi.fn((o) => o.success({ data: o.encoding ? JSON.stringify({ manifest: { application: { dat_file: "app.dat", bin_file: "app.bin" } } }) : o.filePath.endsWith(".dat") ? init.buffer : image.buffer })),
  };
  const api: any = {
    getDeviceInfo: vi.fn(() => ({ platform: "ios" })),
    getBLEMTU: vi.fn((o) => o.success({ mtu: 247 })),
    setBLEMTU: vi.fn((o) => o.success({ mtu: o.mtu })),
    env: { USER_DATA_PATH: "/user" }, getFileSystemManager: () => fs,
    chooseMessageFile: vi.fn((o) => o.success({ tempFiles: [{ name: "firmware.zip", path: "/chat/fw.zip", size: 200 }] })),
    openBluetoothAdapter: vi.fn((o) => o.success({})),
    onBluetoothDeviceFound: (cb: any) => found.add(cb), offBluetoothDeviceFound: (cb: any) => found.delete(cb),
    startBluetoothDevicesDiscovery: vi.fn((o) => { for (const cb of found) cb({ devices: [{ deviceId: "other", name: "DfuTarg" }, { deviceId: "boot", name: bootName || "DfuTarg", localName: bootName || "DfuTarg" }] }); o.success({}); }),
    stopBluetoothDevicesDiscovery: vi.fn((o) => o.success({})),
    createBLEConnection: vi.fn((o) => o.success({})), closeBLEConnection: vi.fn((o) => o.success({})),
    getBLEDeviceServices: vi.fn((o) => o.success({ services: [{ uuid: NORDIC_DFU_SERVICE_UUID }, ...(bonded ? [{ uuid: NORDIC_GATT_SERVICE_UUID }] : [])] })),
    getBLEDeviceCharacteristics: vi.fn((o) => o.success({ characteristics: o.serviceId === NORDIC_GATT_SERVICE_UUID ? [
      { uuid: NORDIC_SERVICE_CHANGED_UUID, properties: { indicate: true } },
    ] : o.deviceId === "app" && (!bonded || !entered) ? [
      { uuid: bonded ? NORDIC_DFU_BUTTONLESS_BONDED_UUID : NORDIC_DFU_BUTTONLESS_UUID, properties: { write: true, indicate: true } },
    ] : [
      { uuid: NORDIC_DFU_CONTROL_UUID, properties: { write: true, notify: true } },
      { uuid: NORDIC_DFU_PACKET_UUID, properties: { writeNoResponse: true } },
    ] })),
    notifyBLECharacteristicValueChange: vi.fn((o) => o.success({})),
    onBLECharacteristicValueChange: (cb: any) => values.add(cb), offBLECharacteristicValueChange: (cb: any) => values.delete(cb),
    onBLEConnectionStateChange: (cb: any) => links.add(cb), offBLEConnectionStateChange: (cb: any) => links.delete(cb),
    writeBLECharacteristicValue: vi.fn((o) => {
      const data = new Uint8Array(o.value); let words: number[] = [];
      if (o.characteristicId === NORDIC_DFU_PACKET_UUID) { buffers[type].push(...data); o.success({}); return; }
      if (o.characteristicId === NORDIC_DFU_BUTTONLESS_UUID || o.characteristicId === NORDIC_DFU_BUTTONLESS_BONDED_UUID) {
        if (data[0] === 2) bootName = String.fromCharCode(...data.slice(2));
        for (const cb of values) cb({ ...o, value: new Uint8Array([0x20, data[0], 1]).buffer });
        o.success({});
        if (data[0] === 1) {
          entered = true; connected = null;
          for (const cb of links) cb({ deviceId: o.deviceId, connected: false });
        }
        return;
      }
      if (data[0] === 6) { type = data[1]; words = [4096, buffers[type].length, nordicCrc32(new Uint8Array(buffers[type]))]; }
      if (data[0] === 1) type = data[1];
      if (data[0] === 3) words = [buffers[type].length, nordicCrc32(new Uint8Array(buffers[type]))];
      const response = new Uint8Array(3 + 4 * words.length); response.set([0x60, data[0], 1]);
      words.forEach((n, i) => new DataView(response.buffer).setUint32(3 + i * 4, n, true));
      for (const cb of values) cb({ ...o, value: response.buffer }); o.success({});
    }),
  };
  const state = createNordicDemoState(); const release = vi.fn(); const acquire = vi.fn(() => release); const log = vi.fn(); const packetTrace = vi.fn();
  const restoreApplication = vi.fn(async (target: { deviceId: string }, assertActive: () => void) => {
    assertActive(); return { deviceId: target.deviceId, version: "6.2.6.2Z5Z" };
  });
  const controller = new NordicDemoController(api, state, vi.fn(), log, acquire, () => connected, packetTrace, autoReconnect ? restoreApplication : undefined);
  return { setConnected: (value: typeof connected) => { connected = value; }, api, fs, state, controller, release, acquire, values, links, found, log, packetTrace, restoreApplication, buffers };
}
/** 扫描/Flash 等待使用虚拟时钟，协议 Promise 仍执行真实顺序。 */
async function finish(task: Promise<void>): Promise<void> { await vi.runAllTimersAsync(); await task; }
afterEach(() => vi.useRealTimers());

describe("双 Demo Nordic 平台协调", () => {
  it("读取 ZIP 后清理解压目录，失败或取消不保留旧固件", async () => {
    const f = fixture(); await f.controller.chooseZip();
    expect(f.state.ready).toBe(true); expect(f.fs.rmdir).toHaveBeenCalledOnce();
    f.api.chooseMessageFile.mockImplementation((o: any) => o.fail({ errMsg: "chooseMessageFile:fail cancel" }));
    await f.controller.chooseZip(); expect(f.state.ready).toBe(false); expect(f.state.status).toContain("取消选择");
  });
  it("拒绝多镜像 manifest，仍清理临时目录", async () => {
    const f = fixture(); f.fs.readFile.mockImplementation((o: any) => o.success({ data: '{"manifest":{"softdevice":{}}}' }));
    await f.controller.chooseZip(); expect(f.state.ready).toBe(false); expect(f.state.status).toContain("多镜像");
    expect(f.fs.rmdir).toHaveBeenCalledOnce();
  });
  it("卸载后迟到的选文件回调不会解压或改变状态", async () => {
    const f = fixture(); let chosen: any;
    f.api.chooseMessageFile.mockImplementation((o: any) => { chosen = o; });
    const task = f.controller.chooseZip(); f.controller.dispose(); chosen.success({ tempFiles: [{ name: "late.zip", size: 20, path: "/late" }] });
    await task; expect(f.fs.unzip).not.toHaveBeenCalled(); expect(f.state.ready).toBe(false); expect(f.release).toHaveBeenCalledOnce();
  });
  it("一次开始自动改名、切换、扫描、连接并升级当前戒指", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true); expect(f.state.status).toContain("重连后可查看当前固件版本");
    expect(f.state.status).not.toContain("目标版本");
    expect(f.api.createBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "boot" }));
    const commands = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_BUTTONLESS_UUID).map(([o]: any) => [...new Uint8Array(o.value)]);
    expect(commands.map((c: number[]) => c[0])).toEqual([2, 1]);
    expect(commands[0][1]).toBe(commands[0].length - 2);
    expect(f.api.startBluetoothDevicesDiscovery).toHaveBeenCalledWith(expect.objectContaining({ allowDuplicatesKey: true }));
    expect(f.buffers[2]).toEqual([1, 2, 3]); expect(f.values.size + f.links.size + f.found.size).toBe(0);
    expect(f.release).toHaveBeenCalledTimes(2); expect(f.state.canRetry).toBe(false);
  });
  it("已连接 Bootloader 时直接复用连接，不额外扫描或切换", async () => {
    vi.useFakeTimers(); const f = fixture(); f.setConnected({ deviceId: "boot" });
    await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true); expect(f.api.createBLEConnection).not.toHaveBeenCalled();
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled(); expect(f.api.closeBLEConnection).toHaveBeenCalledOnce();
  });
  it("未连接且没有恢复身份时不触碰蓝牙，提示先连接", async () => {
    const f = fixture(); f.setConnected(null); await f.controller.chooseZip(); await f.controller.start();
    expect(f.api.getBLEDeviceServices).not.toHaveBeenCalled(); expect(f.state.status).toContain("先连接");
  });
  it("临时名相同的设备发生冲突时不连接任何候选", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseZip();
    const original = f.api.startBluetoothDevicesDiscovery.getMockImplementation();
    f.api.startBluetoothDevicesDiscovery.mockImplementation((o: any) => {
      original(o);
      const writes = f.api.writeBLECharacteristicValue.mock.calls;
      const nameCmd = writes.find(([w]: any) => w.characteristicId === NORDIC_DFU_BUTTONLESS_UUID && new Uint8Array(w.value)[0] === 2)[0];
      const name = String.fromCharCode(...new Uint8Array(nameCmd.value).slice(2));
      for (const cb of f.found) cb({ devices: [{ deviceId: "conflict", localName: name }] });
    });
    await finish(f.controller.start());
    expect(f.api.createBLEConnection).not.toHaveBeenCalled(); expect(f.state.status).toContain("冲突"); expect(f.state.protocolCompleted).toBe(false);
  });
  it("忽略通用 DfuTarg 和缓存 name，只匹配本次 localName", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseZip();
    f.api.startBluetoothDevicesDiscovery.mockImplementation((o: any) => {
      const w = f.api.writeBLECharacteristicValue.mock.calls.find(([w]: any) => w.characteristicId === NORDIC_DFU_BUTTONLESS_UUID && new Uint8Array(w.value)[0] === 2)[0];
      const expected = String.fromCharCode(...new Uint8Array(w.value).slice(2));
      for (const cb of f.found) cb({ devices: [{ deviceId: "wrong", name: expected, localName: "DfuTarg" }] });
      o.success({});
    });
    await finish(f.controller.start()); expect(f.api.createBLEConnection).not.toHaveBeenCalled();
    expect(f.state.status).toContain("未能重新连接"); expect(f.found.size).toBe(0);
  });
  it("旧版不支持改名且设备为 MAC 时自动定位 MAC+1", async () => {
    vi.useFakeTimers(); const f = fixture(); const address = "AA:BB:CC:DD:EE:10";
    f.setConnected({ deviceId: address }); await f.controller.chooseZip();
    const get = f.api.getBLEDeviceCharacteristics.getMockImplementation();
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => get({ ...o, deviceId: o.deviceId === address ? "app" : "boot" }));
    const write = f.api.writeBLECharacteristicValue.getMockImplementation();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      if (o.characteristicId === NORDIC_DFU_BUTTONLESS_UUID && new Uint8Array(o.value)[0] === 2) {
        for (const cb of f.values) cb({ ...o, value: new Uint8Array([0x20, 2, 2]).buffer }); o.success({});
      } else write(o);
    });
    f.api.startBluetoothDevicesDiscovery.mockImplementation((o: any) => {
      for (const cb of f.found) cb({ devices: [{ deviceId: "AA:BB:CC:DD:EE:11", name: "DfuTarg" }, { deviceId: "other", name: "DfuTarg" }] }); o.success({});
    });
    await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true); expect(f.api.createBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "AA:BB:CC:DD:EE:11" }));
  });
  it("改名明确失败时停止，不发送进入模式指令", async () => {
    const f = fixture(); await f.controller.chooseZip();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      for (const cb of f.values) cb({ ...o, value: new Uint8Array([0x20, 2, 4]).buffer }); o.success({});
    });
    await f.controller.start(); expect(f.state.status).toContain("状态 4");
    expect(f.api.writeBLECharacteristicValue).toHaveBeenCalledOnce(); expect(f.values.size + f.links.size).toBe(0);
  });
  it("旧版不支持改名且为 iOS UUID 时明确失败，不猜测其他设备", async () => {
    const f = fixture(); await f.controller.chooseZip();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      for (const cb of f.values) cb({ ...o, value: new Uint8Array([0x20, 2, 2]).buffer }); o.success({});
    });
    await f.controller.start(); expect(f.state.status).toContain("无法自动定位"); expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
  });
  it("切换期间预期断连后自动继续，扫描取消会释放监听和锁", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseZip();
    f.api.startBluetoothDevicesDiscovery.mockImplementation((o: any) => o.success({}));
    const task = f.controller.start(); await vi.advanceTimersByTimeAsync(1); f.controller.cancel(); await task;
    expect(f.found.size + f.values.size + f.links.size).toBe(0); expect(f.state.busy).toBe(false);
    expect(f.state.canRetry).toBe(true); expect(f.api.stopBluetoothDevicesDiscovery).toHaveBeenCalledOnce();
    // 当前应用态会话已消失，重试仍根据保存的临时名自动恢复。
    const writes = f.api.writeBLECharacteristicValue.mock.calls;
    const nameCmd = writes.find(([w]: any) => w.characteristicId === NORDIC_DFU_BUTTONLESS_UUID && new Uint8Array(w.value)[0] === 2)[0];
    const name = String.fromCharCode(...new Uint8Array(nameCmd.value).slice(2));
    f.api.startBluetoothDevicesDiscovery.mockImplementation((o: any) => {
      for (const cb of f.found) cb({ devices: [{ deviceId: "boot", localName: name }] }); o.success({});
    });
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(true);
    expect(f.api.writeBLECharacteristicValue.mock.calls.filter(([w]: any) => w.characteristicId === NORDIC_DFU_BUTTONLESS_UUID)).toHaveLength(2);
  });
  it("切换后的目标缺少 DFU 特征时关闭连接且不发送固件", async () => {
    vi.useFakeTimers(); const f = fixture(); await f.controller.chooseZip();
    const get = f.api.getBLEDeviceCharacteristics.getMockImplementation();
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => o.deviceId === "app" ? get(o) : o.success({ characteristics: [] }));
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(false); expect(f.state.status).toContain("尚未就绪");
    expect(f.api.writeBLECharacteristicValue.mock.calls.some(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID)).toBe(false);
    expect(f.api.closeBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "boot" }));
  });
});


describe("共享绑定信息的 Nordic 戒指", () => {
  it("04 入口复用同一标识，不发改名命令也不扫描或 MAC+1", async () => {
    vi.useFakeTimers(); const f = fixture(true); await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true);
    expect(f.api.createBLEConnection).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "app" }));
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
    const buttonWrites = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_BUTTONLESS_BONDED_UUID);
    expect(buttonWrites.map(([o]: any) => [...new Uint8Array(o.value)])).toEqual([[1]]);
    expect(f.api.notifyBLECharacteristicValueChange).toHaveBeenCalledWith(expect.objectContaining({ characteristicId: NORDIC_SERVICE_CHANGED_UUID, type: "indication" }));
    expect(f.values.size + f.links.size).toBe(0);
    expect(f.log.mock.calls.flat().join(" ")).toContain("共享绑定信息（8EC90004）");
  });
  it("系统缓存先返回旧应用服务时等待刷新，不向旧特征写入固件", async () => {
    vi.useFakeTimers(); const f = fixture(true); const original = f.api.getBLEDeviceCharacteristics.getMockImplementation();
    let reads = 0;
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => {
      if (o.deviceId === "app" && o.serviceId === NORDIC_DFU_SERVICE_UUID && ++reads >= 2 && reads <= 3) {
        o.success({ characteristics: [{ uuid: NORDIC_DFU_BUTTONLESS_BONDED_UUID, properties: { write: true, indicate: true } }] });
      } else original(o);
    });
    await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true); expect(reads).toBe(4);
    expect(f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_BUTTONLESS_BONDED_UUID)).toHaveLength(1);
  });
  it("缓存持续未刷新时明确失败，不退回临时名或任意广播", async () => {
    vi.useFakeTimers(); const f = fixture(true); const original = f.api.getBLEDeviceCharacteristics.getMockImplementation();
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => o.serviceId === NORDIC_DFU_SERVICE_UUID
      ? o.success({ characteristics: [{ uuid: NORDIC_DFU_BUTTONLESS_BONDED_UUID, properties: { write: true, indicate: true } }] }) : original(o));
    await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(false); expect(f.state.status).toContain("Service Changed");
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
    expect(f.api.writeBLECharacteristicValue.mock.calls.some(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID)).toBe(false);
    expect(f.values.size + f.links.size).toBe(0);
  });
  it("未绑定状态 7 保留原因，不重试非绑定入口", async () => {
    const f = fixture(true); await f.controller.chooseZip();
    f.api.writeBLECharacteristicValue.mockImplementation((o: any) => {
      for (const cb of f.values) cb({ ...o, value: new Uint8Array([0x20, 1, 7]).buffer }); o.success({});
    });
    await f.controller.start(); expect(f.state.status).toContain("状态 7");
    expect(f.api.createBLEConnection).not.toHaveBeenCalled(); expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
    expect(f.values.size + f.links.size).toBe(0);
  });
  it("系统不允许小程序重复订阅 Service Changed 时仍验证实际新服务", async () => {
    vi.useFakeTimers(); const f = fixture(true); const original = f.api.notifyBLECharacteristicValueChange.getMockImplementation();
    f.api.notifyBLECharacteristicValueChange.mockImplementation((o: any) => o.characteristicId === NORDIC_SERVICE_CHANGED_UUID
      ? o.fail({ errMsg: "系统已管理此特征" }) : original(o));
    await f.controller.chooseZip(); await finish(f.controller.start());
    expect(f.state.protocolCompleted).toBe(true); expect(f.values.size + f.links.size).toBe(0);
  });
  it("缓存等待期间取消会停止发现，重试仍直连原绑定设备", async () => {
    vi.useFakeTimers(); const f = fixture(true); const original = f.api.getBLEDeviceCharacteristics.getMockImplementation();
    f.api.getBLEDeviceCharacteristics.mockImplementation((o: any) => o.serviceId === NORDIC_DFU_SERVICE_UUID
      ? o.success({ characteristics: [{ uuid: NORDIC_DFU_BUTTONLESS_BONDED_UUID, properties: { write: true, indicate: true } }] }) : original(o));
    await f.controller.chooseZip(); const task = f.controller.start(); await vi.advanceTimersByTimeAsync(1); f.controller.cancel(); await task;
    expect(f.state.status).toContain("停止"); expect(f.values.size + f.links.size).toBe(0);
    f.api.getBLEDeviceCharacteristics.mockImplementation(original);
    await finish(f.controller.start()); expect(f.state.protocolCompleted).toBe(true);
    expect(f.api.startBluetoothDevicesDiscovery).not.toHaveBeenCalled();
    expect(f.api.createBLEConnection.mock.calls.every(([o]: any) => o.deviceId === "app")).toBe(true);
  });
});

it("聊天文件选择触发后台生命周期时仍能继续校验文件", async () => {
  const f = fixture();
  f.api.chooseMessageFile.mockImplementation((o: any) => {
    // 原生 App.onHide 和 UniApp 页面 onHide 都应带上 background 原因。
    const cancelFromApp = (f.acquire.mock.calls[0] as any)[0];
    cancelFromApp("background");
    o.success({ tempFiles: [{ name: "firmware.zip", path: "/chat/fw.zip", size: 200 }] });
  });
  await f.controller.chooseZip();
  expect(f.state.ready).toBe(true);
  expect(f.state.status).toContain("文件校验通过");
  expect(f.fs.unzip).toHaveBeenCalledOnce();
});

it("文件解压准备阶段后台事件不会取消，但不会触发 BLE 升级", async () => {
  const f = fixture();
  f.fs.unzip.mockImplementation((o: any) => {
    (f.acquire.mock.calls[0] as any)[0]("background"); o.success({});
  });
  await f.controller.chooseZip();
  expect(f.state.ready).toBe(true); expect(f.release).toHaveBeenCalledOnce();
  expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled();
  expect(f.api.getBLEDeviceServices).not.toHaveBeenCalled();
});

it("用户主动停止选择任务时仍废弃迟到文件，并记录用户来源", async () => {
  const f = fixture(); let selected: any;
  f.api.chooseMessageFile.mockImplementation((o: any) => { selected = o; });
  const task = f.controller.chooseZip();
  (f.acquire.mock.calls[0] as any)[0]("background"); f.controller.cancel();
  // 后续后台事件不能覆盖第一次主动停止来源。
  (f.acquire.mock.calls[0] as any)[0]("background");
  selected.success({ tempFiles: [{ name: "fw.zip", path: "/chat/fw.zip", size: 200 }] });
  await task;
  expect(f.state.ready).toBe(false); expect(f.fs.unzip).not.toHaveBeenCalled();
  expect(f.state.status).toContain("用户停止");
  expect(f.log.mock.calls.flat().join(" ")).toContain("来源:user 任务:file");
  expect(f.release).toHaveBeenCalledOnce();
});

it("选择器期间页面销毁仍使迟到回调失效，并记录销毁来源", async () => {
  const f = fixture(); let selected: any;
  f.api.chooseMessageFile.mockImplementation((o: any) => { selected = o; });
  const task = f.controller.chooseZip();
  (f.acquire.mock.calls[0] as any)[0]("background"); f.controller.dispose();
  selected.success({ tempFiles: [{ name: "fw.zip", path: "/chat/fw.zip", size: 200 }] });
  await task;
  expect(f.state.ready).toBe(false); expect(f.fs.unzip).not.toHaveBeenCalled();
  expect(f.log.mock.calls.flat().join(" ")).toContain("来源:disposed 任务:file");
  expect(f.release).toHaveBeenCalledOnce();
});

it("实际升级准备中进入后台仍停止 BLE，文件后台豁免不延续到升级", async () => {
  const f = fixture();
  f.api.chooseMessageFile.mockImplementation((o: any) => {
    (f.acquire.mock.calls[0] as any)[0]("background");
    o.success({ tempFiles: [{ name: "fw.zip", path: "/chat/fw.zip", size: 200 }] });
  });
  await f.controller.chooseZip();
  f.api.getBLEDeviceServices.mockImplementation((o: any) => {
    (f.acquire.mock.calls[1] as any)[0]("background"); o.success({ services: [] });
  });
  await f.controller.start();
  expect(f.state.status).toContain("小程序进入后台");
  expect(f.log.mock.calls.flat().join(" ")).toContain("来源:background 任务:upgrade");
  expect(f.api.writeBLECharacteristicValue).not.toHaveBeenCalled();
  expect(f.release).toHaveBeenCalledTimes(2);
});


/** 非整分片的 DAT/BIN，便于检测 MTU 负载、数据完整性与原始日志。 */
function largeFirmware(f: ReturnType<typeof fixture>, size = 1000): { image: Uint8Array; init: Uint8Array } {
  const image = Uint8Array.from({ length: size }, (_, i) => i % 251);
  const init = new Uint8Array(141).fill(9);
  const original = f.fs.readFile.getMockImplementation();
  f.fs.stat.mockImplementation((o: any) => o.success({ stats: { size: o.path.endsWith(".dat") ? init.length : image.length } }));
  f.fs.readFile.mockImplementation((o: any) => o.encoding ? original(o) : o.success({ data: o.filePath.endsWith(".dat") ? init.buffer : image.buffer }));
  return { image, init };
}

it("升级连接 MTU247 使用244字节，iOS不设置MTU，分片Hex全部批量保留", async () => {
  vi.useFakeTimers(); const f = fixture(); const image = largeFirmware(f);
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.api.getBLEMTU).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({ deviceId: "boot", writeType: "writeNoResponse" }));
  expect(f.api.setBLEMTU).not.toHaveBeenCalled();
  const packets = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID).map(([o]: any) => new Uint8Array(o.value));
  expect(packets.map((p: Uint8Array) => p.length)).toEqual([141, 244, 244, 244, 244, 24]);
  expect(f.buffers[2]).toEqual([...image.image]); expect(f.state.protocolCompleted).toBe(true);
  const trace = f.packetTrace.mock.calls.flat().join("\n");
  expect(trace.match(/Nordic packet Hex:/g)).toHaveLength(packets.length);
  expect(f.packetTrace.mock.calls.length).toBeLessThan(packets.length);
  expect(f.log.mock.calls.flat().join(" ")).toContain("有效负载:244");
  expect(f.log.mock.calls.flat().join(" ")).toContain("数据写入:6");
  expect(f.log.mock.calls.some(([line]) => line.startsWith("Nordic packet Hex:"))).toBe(false);
});

it.each([[23, 20], [185, 180], [512, 244]])("当前升级MTU%s按实际能力选负载%s", async (mtu, size) => {
  vi.useFakeTimers(); const f = fixture(); largeFirmware(f);
  f.api.getBLEMTU.mockImplementation((o: any) => o.success({ mtu }));
  await f.controller.chooseZip(); await finish(f.controller.start());
  const sizes = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID).map(([o]: any) => o.value.byteLength);
  expect(Math.max(...sizes)).toBe(size);
  expect(f.state.protocolCompleted).toBe(true);
});

it("Android协商请求247后仍按实际读取MTU23选择20，不能把请求值当结果", async () => {
  vi.useFakeTimers(); const f = fixture(); largeFirmware(f);
  f.api.getDeviceInfo.mockReturnValue({ platform: "android" });
  f.api.getBLEMTU.mockImplementation((o: any) => o.success({ mtu: 23 }));
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.api.setBLEMTU).toHaveBeenCalledWith(expect.objectContaining({ deviceId: "boot", mtu: 247 }));
  const sizes = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID).map(([o]: any) => o.value.byteLength);
  expect(Math.max(...sizes)).toBe(20);
});

it.each(["missing", "failed", "invalid", "timeout"])("MTU %s时明确记录兼容回退而非假定应用连接MTU", async (mode) => {
  vi.useFakeTimers(); const f = fixture(); largeFirmware(f);
  if (mode === "missing") delete f.api.getBLEMTU;
  else f.api.getBLEMTU.mockImplementation((o: any) => {
    if (mode === "failed") o.fail({ errMsg: "无法读取" });
    if (mode === "invalid") o.success({ mtu: 0 });
  });
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.state.protocolCompleted).toBe(true);
  const sizes = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID).map(([o]: any) => o.value.byteLength);
  expect(Math.max(...sizes)).toBe(20);
  expect(f.log.mock.calls.flat().join(" ")).toContain("回退20字节兼容模式");
});

it("MTU读取期间进入后台停止，不提交数据写入", async () => {
  vi.useFakeTimers(); const f = fixture(); largeFirmware(f);
  f.api.getBLEMTU.mockImplementation(() => {});
  await f.controller.chooseZip(); const pending = f.controller.start();
  await vi.advanceTimersByTimeAsync(301);
  (f.acquire.mock.calls[1] as any)[0]("background"); await pending;
  expect(f.state.status).toContain("小程序进入后台");
  expect(f.api.writeBLECharacteristicValue.mock.calls.some(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID)).toBe(false);
});

it("Android MTU协商挂起时不依赖旧MTU247，迟到协商不会导致发送超长数据", async () => {
  vi.useFakeTimers(); const f = fixture(); largeFirmware(f);
  f.api.getDeviceInfo.mockReturnValue({ platform: "android" }); f.api.setBLEMTU.mockImplementation(() => {});
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.api.getBLEMTU).not.toHaveBeenCalled();
  expect(f.log.mock.calls.flat().join(" ")).toContain("MTU 请求仍在进行");
  const sizes = f.api.writeBLECharacteristicValue.mock.calls.filter(([o]: any) => o.characteristicId === NORDIC_DFU_PACKET_UUID).map(([o]: any) => o.value.byteLength);
  expect(Math.max(...sizes)).toBe(20); expect(f.state.protocolCompleted).toBe(true);
});


it("协议完成后关闭升级连接，再恢复原戒指会话并读取版本，不在finally断开新会话", async () => {
  vi.useFakeTimers(); const f = fixture(true, true);
  f.restoreApplication.mockImplementation(async (target, assertActive) => {
    assertActive();
    expect(f.api.closeBLEConnection).toHaveBeenLastCalledWith(expect.objectContaining({ deviceId: "app" }));
    return { deviceId: target.deviceId, version: "6.2.6.2Z5Z" };
  });
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.state.protocolCompleted).toBe(true); expect(f.state.reconnected).toBe(true);
  expect(f.state.firmwareVersion).toBe("6.2.6.2Z5Z"); expect(f.state.canReconnect).toBe(false);
  expect(f.restoreApplication).toHaveBeenCalledOnce();
  expect(f.api.closeBLEConnection).toHaveBeenCalledTimes(2); // 应用态切换清理与Bootloader清理，新会话不再被关闭。
  expect(f.restoreApplication.mock.invocationCallOrder[0]).toBeGreaterThan(f.api.closeBLEConnection.mock.invocationCallOrder[1]);
});
it("设备重启较慢时有限重连，固定原设备且不重复固件写入", async () => {
  vi.useFakeTimers(); const f = fixture(false, true);
  f.restoreApplication.mockRejectedValueOnce(new Error("设备尚未启动")).mockRejectedValueOnce(new Error("旧服务未刷新"));
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.restoreApplication).toHaveBeenCalledTimes(3);
  expect(f.restoreApplication.mock.calls.every(([target]) => target.deviceId === "app")).toBe(true);
  expect(f.state.reconnected).toBe(true);
  expect(f.buffers[2]).toEqual([1, 2, 3]);
});
it("自动重连失败保留协议完成，重新连接按钮不再刷写", async () => {
  vi.useFakeTimers(); const f = fixture(false, true);
  f.restoreApplication.mockRejectedValue(new Error("设备未就绪"));
  await f.controller.chooseZip(); await finish(f.controller.start());
  expect(f.state.protocolCompleted).toBe(true); expect(f.state.canReconnect).toBe(true); expect(f.state.reconnected).toBe(false);
  expect(f.state.status).toContain("不需要重复升级"); expect(f.restoreApplication).toHaveBeenCalledTimes(4);
  const writes = f.api.writeBLECharacteristicValue.mock.calls.length;
  f.restoreApplication.mockImplementation(async (target, assertActive) => { assertActive(); return { deviceId: target.deviceId, version: "6.2.6.2Z5Z" }; });
  await finish(f.controller.reconnect());
  expect(f.state.reconnected).toBe(true); expect(f.api.writeBLECharacteristicValue).toHaveBeenCalledTimes(writes);
});
it("自动重连等待时后台取消会停止重连，但保留已经成功的协议结果", async () => {
  vi.useFakeTimers(); const f = fixture(true, true);
  await f.controller.chooseZip(); const task = f.controller.start();
  await vi.advanceTimersByTimeAsync(401); (f.acquire.mock.calls[1] as any)[0]("background"); await task;
  expect(f.state.protocolCompleted).toBe(true); expect(f.state.status).toContain("固件传输已完成");
  expect(f.restoreApplication).not.toHaveBeenCalled(); expect(f.state.canReconnect).toBe(true);
});
