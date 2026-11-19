"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);

// examples/wechat-miniprogram-demo/scripts/sdk-bundle-entry.ts
var sdk_bundle_entry_exports = {};
__export(sdk_bundle_entry_exports, {
  APOLLO_OTA_NOTIFY_UUID: () => APOLLO_OTA_NOTIFY_UUID2,
  APOLLO_OTA_SERVICE_UUID: () => APOLLO_OTA_SERVICE_UUID2,
  APOLLO_OTA_WRITE_UUID: () => APOLLO_OTA_WRITE_UUID2,
  BCLHttpClient: () => BCLHttpClient,
  BCLNetworkError: () => BCLNetworkError,
  BCLRingNetworkSDK: () => BCLRingNetworkSDK,
  BleApolloOtaTransport: () => BleApolloOtaTransport,
  BleNordicOtaTransport: () => BleNordicOtaTransport,
  BlePhyOtaTransport: () => BlePhyOtaTransport,
  DEFAULT_RING_NOTIFY_CHARACTERISTIC_UUID: () => DEFAULT_RING_NOTIFY_CHARACTERISTIC_UUID,
  DEFAULT_RING_SERVICE_UUID: () => DEFAULT_RING_SERVICE_UUID,
  DEFAULT_RING_WRITE_CHARACTERISTIC_UUID: () => DEFAULT_RING_WRITE_CHARACTERISTIC_UUID,
  DEFAULT_WECHAT_TOKEN_STORAGE_KEY: () => DEFAULT_WECHAT_TOKEN_STORAGE_KEY,
  MemoryTokenStore: () => MemoryTokenStore,
  NORDIC_DFU_BUTTONLESS_BONDED_UUID: () => NORDIC_DFU_BUTTONLESS_BONDED_UUID,
  NORDIC_DFU_BUTTONLESS_UUID: () => NORDIC_DFU_BUTTONLESS_UUID,
  NORDIC_DFU_CONTROL_UUID: () => NORDIC_DFU_CONTROL_UUID,
  NORDIC_DFU_PACKET_UUID: () => NORDIC_DFU_PACKET_UUID,
  NORDIC_DFU_SERVICE_UUID: () => NORDIC_DFU_SERVICE_UUID,
  NORDIC_GATT_SERVICE_UUID: () => NORDIC_GATT_SERVICE_UUID,
  NORDIC_SERVICE_CHANGED_UUID: () => NORDIC_SERVICE_CHANGED_UUID,
  NordicDemoController: () => NordicDemoController,
  NordicOtaError: () => NordicOtaError2,
  NordicOtaUpdater: () => NordicOtaUpdater2,
  PHY_OTA_COMMAND_UUID: () => PHY_OTA_COMMAND_UUID,
  PHY_OTA_DATA_UUID: () => PHY_OTA_DATA_UUID,
  PHY_OTA_NOTIFY_UUID: () => PHY_OTA_NOTIFY_UUID,
  PHY_OTA_SERVICE_UUID: () => PHY_OTA_SERVICE_UUID,
  PHY_PACKET_SIZE: () => PHY_PACKET_SIZE2,
  PHY_WINDOW_SIZE: () => PHY_WINDOW_SIZE2,
  PhyDemoController: () => PhyDemoController,
  PhyOtaError: () => PhyOtaError2,
  PhyOtaUpdater: () => PhyOtaUpdater2,
  WechatBlePlatformError: () => WechatBlePlatformError,
  WechatBlePlatformTransport: () => WechatBlePlatformTransport,
  clearWechatToken: () => clearWechatToken,
  connectWechatRingSDK: () => connectWechatRingSDK,
  createNordicDemoState: () => createNordicDemoState,
  createPhyDemoState: () => createPhyDemoState,
  createWechatRingSDK: () => createWechatRingSDK,
  createWechatTokenStore: () => createWechatTokenStore,
  decodeNordicButtonlessResponse: () => decodeNordicButtonlessResponse2,
  decodeNordicResponse: () => decodeNordicResponse2,
  decodePhyAck: () => decodePhyAck2,
  encodeNordicBootloaderName: () => encodeNordicBootloaderName2,
  encodeNordicCreate: () => encodeNordicCreate2,
  encodePhySection: () => encodePhySection2,
  formatWaveData: () => formatWaveData,
  getMacAddressFromManufacturerData: () => getMacAddressFromManufacturerData,
  getPhyBootMac: () => getPhyBootMac2,
  getResponseMessage: () => getResponseMessage,
  getResponseStatus: () => getResponseStatus,
  getWechatBlePlatform: () => getWechatBlePlatform,
  gzipBase64: () => gzipBase64,
  invalidParameters: () => invalidParameters,
  isBclManufacturerData: () => isBclManufacturerData,
  isPhyBootAdvertisement: () => isPhyBootAdvertisement2,
  isSuccessResponse: () => isSuccessResponse,
  nordicBootloaderAddress: () => nordicBootloaderAddress,
  nordicCrc32: () => nordicCrc322,
  normalizeScannedDevice: () => normalizeScannedDevice,
  parseApolloFirmware: () => parseApolloFirmware2,
  parseNordicFirmware: () => parseNordicFirmware2,
  parseNordicManifest: () => parseNordicManifest,
  parsePhyFirmware: () => parsePhyFirmware2,
  phyCrc16: () => phyCrc162,
  prepareWechatRingChannel: () => prepareWechatRingChannel,
  resolveNordicPayloadSize: () => resolveNordicPayloadSize,
  scanWechatRingDevices: () => scanWechatRingDevices,
  serverError: () => serverError,
  setWechatToken: () => setWechatToken,
  shiftPhyMac: () => shiftPhyMac2,
  tokenError: () => tokenError,
  validateServerResponse: () => validateServerResponse
});
module.exports = __toCommonJS(sdk_bundle_entry_exports);

// packages/protocol-core/dist/errors.js
var ProtocolError = class extends Error {
  constructor(message) {
    super(message);
    this.name = "ProtocolError";
  }
};

// packages/protocol-core/dist/ota/apollo.js
var APOLLO_OTA_SERVICE_UUID = "00002760-08C2-11E1-9073-0E8AC72E1001";
var APOLLO_OTA_WRITE_UUID = "00002760-08C2-11E1-9073-0E8AC72E0001";
var APOLLO_OTA_NOTIFY_UUID = "00002760-08C2-11E1-9073-0E8AC72E0002";
var APOLLO_HEADER_SIZE = 48;
var APOLLO_BLOCK_SIZE = 512;
function parseApolloFirmware(firmware) {
  if (!(firmware instanceof Uint8Array) || firmware.length <= APOLLO_HEADER_SIZE) {
    throw new ProtocolError("Apollo \u56FA\u4EF6\u5FC5\u987B\u5305\u542B 48 \u5B57\u8282\u5934\u548C\u975E\u7A7A\u6B63\u6587");
  }
  const bodySize = new DataView(firmware.buffer, firmware.byteOffset, firmware.byteLength).getUint32(8, true);
  if (bodySize === 0 || bodySize !== firmware.length - APOLLO_HEADER_SIZE) {
    throw new ProtocolError("Apollo \u56FA\u4EF6\u58F0\u660E\u7684\u6B63\u6587\u957F\u5EA6\u4E0E\u5B9E\u9645\u6587\u4EF6\u4E0D\u4E00\u81F4");
  }
  return { header: firmware.slice(0, APOLLO_HEADER_SIZE), body: firmware.slice(APOLLO_HEADER_SIZE), bodySize };
}
function apolloCrc32(data) {
  let crc = 4294967295;
  for (const byte of data) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = crc >>> 1 ^ (crc & 1 ? 3988292384 : 0);
    }
  }
  return (crc ^ 4294967295) >>> 0;
}
function encodeApolloOtaPacket(command, payload = new Uint8Array()) {
  if (command === 1 && payload.length !== APOLLO_HEADER_SIZE || command === 2 && (payload.length === 0 || payload.length > APOLLO_BLOCK_SIZE) || (command === 3 || command === 4) && payload.length !== 0 || ![1, 2, 3, 4].includes(command)) {
    throw new ProtocolError("Apollo \u547D\u4EE4\u6216\u8D1F\u8F7D\u957F\u5EA6\u65E0\u6548");
  }
  const packet = new Uint8Array(7 + payload.length);
  const view = new DataView(packet.buffer);
  view.setUint16(0, payload.length + 4, true);
  packet[2] = command;
  packet.set(payload, 3);
  view.setUint32(3 + payload.length, apolloCrc32(payload), true);
  return packet;
}
function decodeApolloOtaAck(data) {
  if (data.length !== 4 && data.length !== 8) {
    throw new ProtocolError("Apollo ACK \u957F\u5EA6\u5FC5\u987B\u4E3A 4 \u6216 8 \u5B57\u8282");
  }
  const view = new DataView(data.buffer, data.byteOffset, data.byteLength);
  const command = data[2];
  if (view.getUint16(0, true) !== data.length - 3 || command > 4 || data.length === 8 && command !== 1 && command !== 2) {
    throw new ProtocolError("Apollo ACK \u957F\u5EA6\u5B57\u6BB5\u6216\u547D\u4EE4\u683C\u5F0F\u65E0\u6548");
  }
  return {
    command,
    status: data[3],
    ...data.length === 8 ? { offset: view.getUint32(4, true) } : {}
  };
}

// packages/protocol-core/dist/byte-reader.js
var ByteReader = class {
  constructor(bytes) {
    this.bytes = bytes;
    this.offset = 0;
  }
  /** 当前还未读取的字节数。 */
  get remaining() {
    return this.bytes.byteLength - this.offset;
  }
  /** 读取 1 字节无符号整数。 */
  readUint8() {
    this.ensure(1);
    const value = this.bytes[this.offset];
    this.offset += 1;
    return value;
  }
  /** 读取 1 字节有符号整数。 */
  readInt8() {
    const value = this.readUint8();
    return value > 127 ? value - 256 : value;
  }
  /** 读取 4 字节小端无符号整数。 */
  readUint32Le() {
    this.ensure(4);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8 | this.bytes[this.offset + 2] << 16 | this.bytes[this.offset + 3] * 16777216;
    this.offset += 4;
    return value >>> 0;
  }
  /** 读取 2 字节小端无符号整数。 */
  readUint16Le() {
    this.ensure(2);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8;
    this.offset += 2;
    return value;
  }
  /** 读取 2 字节小端有符号整数。 */
  readInt16Le() {
    this.ensure(2);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8;
    this.offset += 2;
    return value >= 32768 ? value - 65536 : value;
  }
  /** 读取 4 字节小端有符号整数。 */
  readInt32Le() {
    const value = this.readUint32Le();
    return value > 2147483647 ? value - 4294967296 : value;
  }
  /** 读取 8 字节小端无符号整数，并限制在 JavaScript 安全整数范围内。 */
  readUint64Le() {
    this.ensure(8);
    let value = BigInt(0);
    for (let i = 7; i >= 0; i -= 1) {
      value = value << BigInt(8) | BigInt(this.bytes[this.offset + i]);
    }
    this.offset += 8;
    const numberValue = Number(value);
    if (!Number.isSafeInteger(numberValue)) {
      throw new ProtocolError("uint64 value exceeds JavaScript safe integer range.");
    }
    return numberValue;
  }
  /** 读取固定长度 ASCII 字符串。 */
  readAscii(length) {
    this.ensure(length);
    let value = "";
    for (let i = 0; i < length; i += 1) {
      value += String.fromCharCode(this.bytes[this.offset + i]);
    }
    this.offset += length;
    return value;
  }
  ensure(length) {
    if (this.remaining < length) {
      throw new ProtocolError("Packet data is shorter than expected.");
    }
  }
};

// packages/protocol-core/dist/byte-writer.js
var ByteWriter = class {
  constructor() {
    this.bytes = [];
  }
  /** 写入 1 字节无符号整数。 */
  writeUint8(value) {
    assertIntegerInRange(value, 0, 255, "uint8");
    this.bytes.push(value);
    return this;
  }
  /** 写入 1 字节有符号整数。 */
  writeInt8(value) {
    assertIntegerInRange(value, -128, 127, "int8");
    this.bytes.push(value < 0 ? value + 256 : value);
    return this;
  }
  /** 写入 4 字节小端无符号整数。 */
  writeUint32Le(value) {
    assertIntegerInRange(value, 0, 4294967295, "uint32");
    this.bytes.push(value & 255, value >>> 8 & 255, value >>> 16 & 255, Math.floor(value / 16777216) & 255);
    return this;
  }
  /** 写入 8 字节小端无符号整数。 */
  writeUint64Le(value) {
    if (typeof value === "number" && (!Number.isSafeInteger(value) || value < 0)) {
      throw new ProtocolError("uint64 value is out of range.");
    }
    const bigValue = typeof value === "bigint" ? value : BigInt(value);
    if (bigValue < BigInt(0) || bigValue > BigInt("0xffffffffffffffff")) {
      throw new ProtocolError("uint64 value is out of range.");
    }
    for (let i = 0; i < 8; i += 1) {
      this.bytes.push(Number(bigValue >> BigInt(i * 8) & BigInt(255)));
    }
    return this;
  }
  /** 输出已写入的完整字节数组。 */
  toBytes() {
    return new Uint8Array(this.bytes);
  }
};
function assertIntegerInRange(value, min, max, typeName) {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new ProtocolError(`${typeName} value is out of range.`);
  }
}

// packages/protocol-core/dist/packet.js
function createPacket(frameId, cmd, subcmd, data = new Uint8Array()) {
  assertByte(frameId, "frameId");
  assertByte(cmd, "cmd");
  assertByte(subcmd, "subcmd");
  return {
    frameType: 0,
    frameId,
    cmd,
    subcmd,
    data
  };
}
function encodePacket(packet) {
  assertByte(packet.frameType, "frameType");
  assertByte(packet.frameId, "frameId");
  assertByte(packet.cmd, "cmd");
  assertByte(packet.subcmd, "subcmd");
  if (packet.data.byteLength > 240) {
    throw new ProtocolError("Packet data must not exceed 240 bytes.");
  }
  const out = new Uint8Array(4 + packet.data.byteLength);
  out[0] = packet.frameType;
  out[1] = packet.frameId;
  out[2] = packet.cmd;
  out[3] = packet.subcmd;
  out.set(packet.data, 4);
  return out;
}
function decodePacket(bytes) {
  const view = bytes.byteOffset === 0 && bytes.byteLength === bytes.buffer.byteLength ? bytes : bytes.slice();
  if (view.byteLength < 4) {
    throw new ProtocolError("Packet must contain at least 4 header bytes.");
  }
  return {
    frameType: view[0],
    frameId: view[1],
    cmd: view[2],
    subcmd: view[3],
    data: view.slice(4)
  };
}
function assertPacketKind(packet, cmd, subcmd) {
  if (packet.cmd !== cmd || packet.subcmd !== subcmd) {
    throw new ProtocolError(`Unexpected packet kind: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
  }
}
function assertByte(value, name) {
  if (!Number.isInteger(value) || value < 0 || value > 255) {
    throw new ProtocolError(`${name} must be a byte.`);
  }
}

// packages/protocol-core/dist/codec-utils.js
function assertResponsePacket(packet, cmd, subcmd, dataLength) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind(packet, cmd, subcmd);
  if (packet.data.byteLength !== dataLength) {
    throw new ProtocolError(`Unexpected data length: expected ${dataLength}, got ${packet.data.byteLength}.`);
  }
}

// packages/protocol-core/dist/hex.js
function bytesToHex(bytes) {
  let hex = "";
  for (let i = 0; i < bytes.byteLength; i += 1) {
    hex += bytes[i].toString(16).padStart(2, "0");
  }
  return hex;
}

// packages/protocol-core/dist/ring-history-data.js
var CMD_RING_DATA = 54;
var SUBCMD_SYNC_UNUPLOADED = 0;
var SUBCMD_SYNC_ALL = 1;
var SUBCMD_STOP_UPLOAD = 2;
var SUBCMD_DELETE_ALL = 3;
var SUBCMD_NEGATIVE_RESPONSE = 255;
var EMPTY_TIMESTAMP = 0;
var BUSY_TOTAL_NUMBER = 4294967295;
var BASE_RECORD_LENGTH = 17;
var syncUnuploadedHistoryDataCodec = createHistorySyncCodec(SUBCMD_SYNC_UNUPLOADED, "unuploaded");
var syncAllHistoryDataCodec = createHistorySyncCodec(SUBCMD_SYNC_ALL, "all");
var stopHistoryDataUploadCodec = {
  cmd: CMD_RING_DATA,
  subcmd: SUBCMD_STOP_UPLOAD,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertRingDataPacket(packet, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected stop history data upload length: ${packet.data.byteLength}.`);
    }
    return { stopped: true };
  }
};
var deleteAllHistoryDataCodec = {
  cmd: CMD_RING_DATA,
  subcmd: SUBCMD_DELETE_ALL,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    var _a;
    if (packet.cmd === CMD_RING_DATA && packet.subcmd === SUBCMD_NEGATIVE_RESPONSE) {
      throw new ProtocolError(ringDataNegativeMessage((_a = packet.data[0]) !== null && _a !== void 0 ? _a : 255));
    }
    assertRingDataPacket(packet, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected delete history data length: ${packet.data.byteLength}.`);
    }
    return { deleted: true };
  }
};
function isHistorySyncPacket(packet) {
  return packet.cmd === CMD_RING_DATA && (packet.subcmd === SUBCMD_SYNC_UNUPLOADED || packet.subcmd === SUBCMD_SYNC_ALL || packet.subcmd === SUBCMD_NEGATIVE_RESPONSE);
}
function isHistorySyncTerminal(event) {
  return event.status === "completed" || event.status === "no_data" || event.status === "error";
}
function isHistorySyncFailure(event) {
  return event.status === "error";
}
function ringDataNegativeMessage(errorCode) {
  if (errorCode === 0) {
    return "\u8BBE\u5907\u6B63\u5728\u6D4B\u91CF\u4E2D\uFF0C\u6682\u65F6\u65E0\u6CD5\u64CD\u4F5C\u5386\u53F2\u6570\u636E";
  }
  if (errorCode === 1) {
    return "\u8BBE\u5907\u6B63\u5728\u4E0A\u4F20\u5386\u53F2\u8BB0\u5F55";
  }
  if (errorCode === 2) {
    return "\u8BBE\u5907\u6B63\u5728\u5220\u9664\u5386\u53F2\u8BB0\u5F55";
  }
  if (errorCode === 3) {
    return "\u8BBE\u5907\u6587\u4EF6\u7CFB\u7EDF\u635F\u574F";
  }
  return `\u6212\u6307\u5185\u6570\u636E\u64CD\u4F5C\u5931\u8D25\uFF0C\u9519\u8BEF\u7801 ${errorCode}`;
}
function createHistorySyncCodec(subcmd, kind) {
  return {
    cmd: CMD_RING_DATA,
    subcmd,
    encode(request, frameId) {
      var _a;
      return createPacket(frameId, this.cmd, this.subcmd, encodeTimestamp((_a = request === null || request === void 0 ? void 0 : request.timestamp) !== null && _a !== void 0 ? _a : EMPTY_TIMESTAMP));
    },
    decode(packet) {
      if (packet.cmd !== CMD_RING_DATA) {
        throw new ProtocolError(`Unexpected packet kind: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
      }
      if (packet.subcmd === SUBCMD_NEGATIVE_RESPONSE) {
        return decodeNegativeResponse(packet, kind);
      }
      assertPacketKind(packet, this.cmd, this.subcmd);
      return decodeHistorySyncEvent(packet, kind);
    }
  };
}
function encodeTimestamp(timestamp) {
  if (!Number.isInteger(timestamp) || timestamp < 0 || timestamp > 4294967295) {
    throw new ProtocolError("history sync timestamp must be uint32 seconds.");
  }
  return new Uint8Array([
    timestamp & 255,
    timestamp >> 8 & 255,
    timestamp >> 16 & 255,
    Math.floor(timestamp / 16777216) & 255
  ]);
}
function decodeHistorySyncEvent(packet, kind) {
  const rawHex = bytesToHex(encodePacket(packet));
  if (packet.data.byteLength < 8) {
    throw new ProtocolError(`Unexpected history data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  const totalNumber = reader.readUint32Le();
  const sequence = reader.readUint32Le();
  if (totalNumber === 0) {
    return {
      type: "no_data",
      kind,
      status: "no_data",
      totalNumber,
      sequence,
      progress: 100,
      rawHex
    };
  }
  if (totalNumber === BUSY_TOTAL_NUMBER) {
    return {
      type: "busy",
      kind,
      status: "error",
      totalNumber,
      sequence,
      progress: 0,
      message: "\u8BBE\u5907\u7E41\u5FD9\uFF0C\u6682\u65F6\u65E0\u6CD5\u540C\u6B65\u5386\u53F2\u6570\u636E",
      rawHex
    };
  }
  if (packet.data.byteLength < 8 + BASE_RECORD_LENGTH) {
    throw new ProtocolError(`Unexpected history record data length: ${packet.data.byteLength}.`);
  }
  const record = decodeHistoryRecord(packet, kind, totalNumber, sequence);
  return {
    type: "record",
    kind,
    status: record.progress >= 100 ? "completed" : "syncing",
    totalNumber,
    sequence,
    progress: record.progress,
    record,
    rawHex
  };
}
function decodeHistoryRecord(packet, _kind, totalNumber, sequence) {
  const rawHex = bytesToHex(encodePacket(packet));
  const reader = new ByteReader(packet.data.slice(8));
  const timestamp = reader.readUint32Le();
  const stepCount = reader.readUint16Le();
  const heartRate = reader.readUint8();
  const bloodOxygen = reader.readUint8();
  const heartRateVariability = reader.readUint8();
  const stressIndex = reader.readUint8();
  const temperatureRaw = reader.readInt16Le();
  const activityIntensity = reader.readUint8();
  const sleepType = reader.readUint8();
  const piReserved = reader.readUint8();
  const resReserved = reader.readUint8();
  const arrayCount = reader.readUint8();
  const arrayValues = readUint16Array(reader, arrayCount);
  const extensionOffset = 8 + BASE_RECORD_LENGTH + arrayCount * 2;
  const rawExtensionHex = bytesToHex(packet.data.slice(extensionOffset));
  const extensionFields = readExtensionFields(reader);
  return {
    totalNumber,
    sequence,
    progress: calculateProgress(totalNumber, sequence),
    timestamp,
    timestampMs: timestamp * 1e3,
    stepCount,
    heartRate,
    bloodOxygen,
    heartRateVariability,
    stressIndex,
    temperatureRaw,
    temperatureCelsius: temperatureRaw / 100,
    activityIntensity,
    sleepType,
    piReserved,
    resReserved,
    arrayCount,
    arrayValues,
    rrIntervals: arrayCount === 4 ? [] : arrayValues,
    sleepFeatureValues: arrayCount === 4 ? arrayValues : [],
    extensionFields,
    rawExtensionHex,
    extensions: parseExtensionFields(extensionFields),
    rawDataHex: bytesToHex(packet.data),
    rawHex
  };
}
function readUint16Array(reader, count) {
  const values = [];
  for (let i = 0; i < count; i += 1) {
    values.push(reader.readUint16Le());
  }
  return values;
}
function readExtensionFields(reader) {
  const fields = [];
  while (reader.remaining > 0) {
    const length = reader.readUint8();
    if (length === 0) {
      break;
    }
    if (reader.remaining < 1) {
      fields.push({
        type: -1,
        length,
        data: [],
        rawHex: "",
        truncated: true
      });
      break;
    }
    const type = reader.readUint8();
    const valueLength = Math.max(0, length - 1);
    const truncated = reader.remaining < valueLength;
    const data = readRawBytes(reader, Math.min(valueLength, reader.remaining));
    fields.push({
      type,
      length,
      data,
      rawHex: bytesToHex(new Uint8Array(data)),
      truncated: truncated || void 0
    });
    if (truncated) {
      break;
    }
  }
  return fields;
}
function readRawBytes(reader, length) {
  const values = [];
  for (let i = 0; i < length; i += 1) {
    values.push(reader.readUint8());
  }
  return values;
}
function parseExtensionFields(fields) {
  const parsed = {};
  for (const field of fields) {
    parseExtensionField(field, parsed);
  }
  return parsed;
}
function parseExtensionField(field, parsed) {
  if (field.truncated) {
    return;
  }
  const data = new Uint8Array(field.data);
  const reader = new ByteReader(data);
  switch (field.type) {
    case 1:
      parsed.measureType = readOptionalUint8(reader);
      break;
    case 2:
      parsed.periodStepCount = readOptionalUint16(reader);
      break;
    case 3:
      parsed.runningFlag = readOptionalUint8(reader);
      break;
    case 4:
      parsed.batteryLevel = readOptionalUint8(reader);
      break;
    case 5:
      parsed.batteryVoltageRaw = readOptionalUint16(reader);
      parsed.batteryVoltage = parsed.batteryVoltageRaw === void 0 ? void 0 : parsed.batteryVoltageRaw / 1e3;
      break;
    case 6:
      parsed.notWearingReason = readOptionalUint8(reader);
      break;
    case 7:
      parsed.calibrationFlag = readOptionalUint8(reader);
      break;
    case 8:
      parsed.ambientLight = readOptionalUint8(reader);
      break;
    case 9:
      parsed.temperatures = parseUint16ListWithCount(data).map((value) => signedInt16(value) / 100);
      break;
    case 10:
      parsed.maxStepFrequency = field.data[0];
      parsed.minStepFrequency = field.data[1];
      break;
    case 11:
      parsed.respiratoryRate = field.data[0];
      parsed.respiratoryConfidence = field.data[1];
      break;
    case 12:
      parsed.motionState = readOptionalUint8(reader);
      break;
    case 13:
      parsed.totalCalories = readOptionalUint16(reader);
      parsed.basalCalories = readOptionalUint16(reader);
      parsed.activeCalories = readOptionalUint16(reader);
      break;
    case 14:
      parsed.hardAdt = readOptionalUint16(reader);
      break;
    case 15:
      parsed.diastolicPressure = field.data[0];
      parsed.systolicPressure = field.data[1];
      break;
    case 16:
      parsed.extendedStepCount = readOptionalUint32(reader);
      break;
    case 17:
      parsed.extendedHeartRate = readOptionalUint8(reader);
      break;
    case 18:
      parsed.extendedBloodOxygen = readOptionalUint8(reader);
      break;
    case 19:
      parsed.extendedHeartRateVariability = readOptionalUint8(reader);
      break;
    case 20:
      parsed.extendedStressIndex = readOptionalUint8(reader);
      break;
    case 21:
      parsed.extendedActivityIntensity = readOptionalUint8(reader);
      break;
    case 22:
      parsed.extendedRRIntervals = parseUint16ListWithCount(data);
      break;
  }
}
function parseUint16ListWithCount(data) {
  if (data.byteLength === 0) {
    return [];
  }
  const count = data[0];
  const reader = new ByteReader(data.slice(1));
  const values = [];
  const readableCount = Math.min(count, Math.floor(reader.remaining / 2));
  for (let i = 0; i < readableCount; i += 1) {
    values.push(reader.readUint16Le());
  }
  return values;
}
function readOptionalUint8(reader) {
  return reader.remaining >= 1 ? reader.readUint8() : void 0;
}
function readOptionalUint16(reader) {
  return reader.remaining >= 2 ? reader.readUint16Le() : void 0;
}
function readOptionalUint32(reader) {
  return reader.remaining >= 4 ? reader.readUint32Le() : void 0;
}
function signedInt16(value) {
  return value >= 32768 ? value - 65536 : value;
}
function calculateProgress(totalNumber, sequence) {
  if (totalNumber <= 0) {
    return 0;
  }
  const completed = sequence <= 0 ? sequence + 1 : sequence;
  return Math.min(100, Math.max(0, Math.floor(completed / totalNumber * 100)));
}
function decodeNegativeResponse(packet, kind) {
  var _a;
  const errorCode = (_a = packet.data[0]) !== null && _a !== void 0 ? _a : 255;
  return {
    type: "negative_response",
    kind,
    status: "error",
    totalNumber: 0,
    sequence: 0,
    progress: 0,
    errorCode,
    message: ringDataNegativeMessage(errorCode),
    rawHex: bytesToHex(encodePacket(packet))
  };
}
function assertRingDataPacket(packet, subcmd) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind(packet, CMD_RING_DATA, subcmd);
}

// packages/protocol-core/dist/app-composite-events.js
var CMD_APP_COMPOSITE = 160;
var CMD_RING_DATA2 = 54;
var SUBCMD_BIND = 0;
var SUBCMD_CONNECT = 1;
var SUBCMD_REFRESH = 2;
var SUBCMD_NEGATIVE_RESPONSE2 = 255;
var appCompositeBindCodec = createAppCompositeCodec(SUBCMD_BIND, "bind");
var appCompositeConnectCodec = createAppCompositeCodec(SUBCMD_CONNECT, "connect");
var appCompositeRefreshCodec = createAppCompositeCodec(SUBCMD_REFRESH, "refresh");
function isAppCompositePacket(packet) {
  return packet.cmd === CMD_APP_COMPOSITE || isHistorySyncPacket(packet);
}
function isAppCompositeFailure(event) {
  if (event.type === "history") {
    return isHistorySyncFailure(event.history);
  }
  return !event.isSuccess && event.isTerminal;
}
function createAppCompositeCodec(subcmd, kind) {
  return {
    cmd: CMD_APP_COMPOSITE,
    subcmd,
    encode(request, frameId) {
      return createPacket(frameId, this.cmd, this.subcmd, encodeAppCompositeRequest(request, kind));
    },
    decode(packet) {
      if (packet.cmd === CMD_RING_DATA2) {
        const historyCodec = packet.subcmd === 1 ? syncAllHistoryDataCodec : syncUnuploadedHistoryDataCodec;
        const history = historyCodec.decode(packet);
        return {
          type: "history",
          kind,
          history,
          isTerminal: isHistorySyncTerminal(history),
          isSuccess: history.status === "completed" || history.status === "no_data"
        };
      }
      if (packet.cmd === CMD_APP_COMPOSITE && packet.subcmd === SUBCMD_NEGATIVE_RESPONSE2) {
        return decodeNegativeResponse2(packet, kind);
      }
      assertPacketKind(packet, this.cmd, this.subcmd);
      return {
        type: "device_info",
        kind,
        deviceInfo: decodeDeviceInfo(packet),
        isTerminal: kind === "bind",
        isSuccess: true
      };
    }
  };
}
function encodeAppCompositeRequest(request, kind) {
  var _a, _b, _c;
  const timestampMs = (_a = request === null || request === void 0 ? void 0 : request.timestampMs) !== null && _a !== void 0 ? _a : Date.now();
  const timezone = (_b = request === null || request === void 0 ? void 0 : request.timezone) !== null && _b !== void 0 ? _b : 8;
  const writer = new ByteWriter();
  writeUint48Le(writer, timestampMs);
  writer.writeUint8(0).writeUint8(0).writeInt8(timezone).writeUint8(1);
  if (kind !== "bind") {
    writer.writeUint32Le((_c = request === null || request === void 0 ? void 0 : request.filterTimestamp) !== null && _c !== void 0 ? _c : 0);
  }
  return writer.toBytes();
}
function writeUint48Le(writer, value) {
  if (!Number.isSafeInteger(value) || value < 0 || value > 281474976710655) {
    throw new ProtocolError("app composite timestampMs must be a uint48 safe integer.");
  }
  let rest = value;
  for (let i = 0; i < 6; i += 1) {
    writer.writeUint8(rest % 256);
    rest = Math.floor(rest / 256);
  }
}
function decodeDeviceInfo(packet) {
  if (packet.data.byteLength < 60) {
    throw new ProtocolError(`Unexpected app composite device info length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  const firmwareVersion = trimVersion(reader.readAscii(10));
  const hardwareVersion = trimVersion(reader.readAscii(10));
  const batteryLevel = reader.readUint8();
  const chargingState = reader.readUint8();
  const collectInterval = reader.readUint32Le();
  const stepCount = reader.readUint16Le();
  const selfInspectionFlag = reader.readUint16Le();
  const hidSupported = reader.readUint8() === 1;
  const hid = hidSupported && packet.data.byteLength >= 50 ? readHidCapabilities(packet.data) : void 0;
  const features = readFeatureFlags(packet.data);
  const goMore = readGoMoreUserInfo(packet.data);
  return {
    firmwareVersion,
    hardwareVersion,
    batteryLevel,
    chargingState,
    collectInterval,
    stepCount,
    selfInspectionFlag,
    hidSupported,
    hid,
    features,
    goMore,
    extraHex: packet.data.byteLength > 75 ? bytesToHex(packet.data.slice(75)) : "",
    rawHex: bytesToHex(encodePacket(packet))
  };
}
function readHidCapabilities(data) {
  var _a, _b, _c, _d, _e;
  const touch = (_a = data[31]) !== null && _a !== void 0 ? _a : 0;
  const gesture = (_b = data[39]) !== null && _b !== void 0 ? _b : 0;
  return {
    photo: (touch & 1) !== 0,
    shortVideo: (touch & 2) !== 0,
    music: (touch & 4) !== 0,
    ppt: (touch & 8) !== 0,
    audioUpload: (touch & 16) !== 0,
    pinchPhoto: (gesture & 1) !== 0,
    pinchShortVideo: (gesture & 2) !== 0,
    pinchMusic: (gesture & 4) !== 0,
    pinchPpt: (gesture & 8) !== 0,
    snapPhoto: (gesture & 16) !== 0,
    touchHidMode: (_c = data[47]) !== null && _c !== void 0 ? _c : 0,
    gestureHidMode: (_d = data[48]) !== null && _d !== void 0 ? _d : 0,
    systemType: (_e = data[49]) !== null && _e !== void 0 ? _e : 0
  };
}
function readFeatureFlags(data) {
  return {
    heartRateCurve: boolByte(data[50]),
    bloodOxygenCurve: boolByte(data[51]),
    heartRateVariabilityCurve: boolByte(data[52]),
    stressCurve: boolByte(data[53]),
    temperatureCurve: boolByte(data[54]),
    femaleHealth: boolByte(data[55]),
    vibrationAlarm: boolByte(data[56]),
    ecg: boolByte(data[57]),
    microphone: boolByte(data[58]),
    sportMode: boolByte(data[59]),
    bloodPressureMeasurement: boolByte(data[60]),
    bloodGlucoseMeasurement: boolByte(data[61]),
    fileSystem: boolByte(data[62]),
    goMoreSleepAlgorithm: boolByte(data[63]),
    bloodPressureCurve: boolByte(data[72]),
    hidServiceEnabled: boolByte(data[74])
  };
}
function readGoMoreUserInfo(data) {
  if (data.byteLength < 64) {
    return void 0;
  }
  const maxHeartRateRaw = data.byteLength >= 70 ? new ByteReader(data.slice(68, 70)).readInt16Le() : void 0;
  return {
    age: data[64],
    gender: data[65],
    height: data[66],
    weight: data[67],
    maxHeartRate: maxHeartRateRaw === void 0 || maxHeartRateRaw === -1 ? void 0 : maxHeartRateRaw,
    restingHeartRate: data[70] === void 0 || data[70] === 255 ? void 0 : data[70],
    maxOxygenUptake: data[71] === void 0 || data[71] === 255 ? void 0 : data[71],
    authStatus: data[73]
  };
}
function decodeNegativeResponse2(packet, kind) {
  var _a;
  const errorCode = (_a = packet.data[0]) !== null && _a !== void 0 ? _a : 255;
  return {
    type: "negative_response",
    kind,
    errorCode,
    message: `App \u590D\u5408\u6307\u4EE4\u5931\u8D25\uFF0C\u9519\u8BEF\u7801 ${errorCode}`,
    rawHex: bytesToHex(encodePacket(packet)),
    isTerminal: true,
    isSuccess: false
  };
}
function trimVersion(value) {
  return value.replace(/[\u0000-\u001f\u007f]/g, "").trim();
}
function boolByte(value) {
  return value === void 0 ? void 0 : value === 1;
}

// packages/protocol-core/dist/battery.js
var CMD_BATTERY = 18;
var SUBCMD_BATTERY_LEVEL = 0;
var SUBCMD_CHARGING_STATE = 1;
var SUBCMD_BATTERY_PUSH = 2;
var getBatteryLevelCodec = {
  cmd: CMD_BATTERY,
  subcmd: SUBCMD_BATTERY_LEVEL,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertResponsePacket(packet, this.cmd, this.subcmd, 1);
    return parseBatteryLevel(new ByteReader(packet.data).readUint8());
  }
};
var getChargingStateCodec = {
  cmd: CMD_BATTERY,
  subcmd: SUBCMD_CHARGING_STATE,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertResponsePacket(packet, this.cmd, this.subcmd, 1);
    return {
      state: parseChargingState(new ByteReader(packet.data).readUint8())
    };
  }
};
function isBatteryPushPacket(packet) {
  return packet.cmd === CMD_BATTERY && (packet.subcmd === SUBCMD_BATTERY_LEVEL || packet.subcmd === SUBCMD_BATTERY_PUSH);
}
function decodeBatteryPushPacket(packet, rawHex = "") {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frame type: 0x${packet.frameType.toString(16)}.`);
  }
  if (!isBatteryPushPacket(packet)) {
    throw new ProtocolError(`Unexpected battery push packet: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
  }
  if (packet.data.byteLength < 1) {
    throw new ProtocolError("Battery push payload must contain at least one byte.");
  }
  const value = parseBatteryValue(new ByteReader(packet.data).readUint8());
  const explicitChargingState = packet.subcmd === SUBCMD_BATTERY_PUSH && packet.data.byteLength >= 6 ? tryParseChargingState(packet.data[5]) : void 0;
  return {
    ...value,
    chargingState: explicitChargingState !== null && explicitChargingState !== void 0 ? explicitChargingState : value.chargingState,
    source: packet.subcmd === SUBCMD_BATTERY_LEVEL ? "read_compatible_push" : "battery_push",
    rawHex
  };
}
function parseBatteryLevel(value) {
  var _a;
  const parsed = parseBatteryValue(value);
  return {
    level: (_a = parsed.level) !== null && _a !== void 0 ? _a : 0,
    isCharging: value === 101,
    isFull: value === 102,
    isLevelValid: parsed.isLevelValid
  };
}
function parseBatteryValue(value) {
  if (value <= 100) {
    return {
      rawValue: value,
      level: value,
      isLevelValid: true
    };
  }
  return {
    rawValue: value,
    isLevelValid: false,
    chargingState: value === 101 ? "charging" : value === 102 ? "full" : void 0
  };
}
function parseChargingState(value) {
  if (value === 0) {
    return "not_charging";
  }
  if (value === 1) {
    return "charging";
  }
  if (value === 2) {
    return "full";
  }
  throw new ProtocolError(`Unknown charging state: ${value}.`);
}
function tryParseChargingState(value) {
  try {
    return parseChargingState(value);
  } catch (_) {
    return void 0;
  }
}

// packages/protocol-core/dist/blood-oxygen.js
var CMD_BLOOD_OXYGEN = 50;
var SUBCMD_TAKE = 0;
var SUBCMD_WAVEFORM = 1;
var SUBCMD_PERFUSION_RATE = 2;
var SUBCMD_BLOOD_PRESSURE = 5;
var SUBCMD_STOP = 6;
var SUBCMD_PROGRESS = 255;
var startBloodOxygenCodec = {
  cmd: CMD_BLOOD_OXYGEN,
  subcmd: SUBCMD_TAKE,
  encode(request, frameId) {
    const normalized = normalizeBloodOxygenRequest(request);
    const data = new ByteWriter().writeUint8(normalized.collectTime).writeUint8(normalized.collectFrequency).writeUint8(normalized.waveformConfig).writeUint8(normalized.progressConfig).toBytes();
    return createPacket(frameId, this.cmd, this.subcmd, data);
  },
  decode(packet) {
    assertBloodOxygenPacket(packet);
    if (packet.subcmd === SUBCMD_TAKE)
      return decodeBloodOxygenResult(packet);
    if (packet.subcmd === SUBCMD_PROGRESS)
      return decodeBloodOxygenProgress(packet);
    if (packet.subcmd === SUBCMD_WAVEFORM)
      return decodeBloodOxygenWaveform(packet);
    if (packet.subcmd === SUBCMD_PERFUSION_RATE)
      return decodeBloodOxygenPerfusionRate(packet);
    if (packet.subcmd === SUBCMD_BLOOD_PRESSURE)
      return decodeBloodOxygenBloodPressure(packet);
    throw new ProtocolError(`Unexpected blood oxygen subcmd: 0x${packet.subcmd.toString(16)}.`);
  }
};
var stopBloodOxygenCodec = {
  cmd: CMD_BLOOD_OXYGEN,
  subcmd: SUBCMD_STOP,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    if (packet.frameType !== 0) {
      throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
    }
    assertPacketKind(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected stop blood oxygen data length: ${packet.data.byteLength}.`);
    }
    return { stopped: true };
  }
};
function isBloodOxygenMeasurePacket(packet) {
  return packet.cmd === CMD_BLOOD_OXYGEN && [SUBCMD_TAKE, SUBCMD_WAVEFORM, SUBCMD_PERFUSION_RATE, SUBCMD_BLOOD_PRESSURE, SUBCMD_PROGRESS].includes(packet.subcmd);
}
function isBloodOxygenMeasureTerminal(event) {
  return event.isTerminal;
}
function isBloodOxygenMeasureFailure(event) {
  return event.isTerminal && !event.isSuccess;
}
function normalizeBloodOxygenRequest(request) {
  var _a, _b, _c, _d;
  const normalized = {
    collectTime: (_a = request === null || request === void 0 ? void 0 : request.collectTime) !== null && _a !== void 0 ? _a : 30,
    collectFrequency: (_b = request === null || request === void 0 ? void 0 : request.collectFrequency) !== null && _b !== void 0 ? _b : 50,
    waveformConfig: (_c = request === null || request === void 0 ? void 0 : request.waveformConfig) !== null && _c !== void 0 ? _c : 1,
    progressConfig: (_d = request === null || request === void 0 ? void 0 : request.progressConfig) !== null && _d !== void 0 ? _d : 1
  };
  assertPositiveByte(normalized.collectTime, "collectTime");
  assertPositiveByte(normalized.collectFrequency, "collectFrequency");
  assertFlag(normalized.waveformConfig, "waveformConfig");
  assertFlag(normalized.progressConfig, "progressConfig");
  return normalized;
}
function assertBloodOxygenPacket(packet) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  if (!isBloodOxygenMeasurePacket(packet)) {
    throw new ProtocolError(`Unexpected blood oxygen packet: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
  }
}
function decodeBloodOxygenResult(packet) {
  if (packet.data.byteLength < 1) {
    throw new ProtocolError("Blood oxygen result response must contain status byte.");
  }
  const reader = new ByteReader(packet.data);
  const status = parseBloodOxygenStatus(reader.readUint8());
  const heartRate = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const bloodOxygen = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const temperatureRaw = reader.remaining >= 2 ? reader.readInt16Le() : void 0;
  const isFailure = ["not_wearing", "charging", "busy", "timeout"].includes(status);
  const isSuccess = status === "completed";
  return {
    type: "result",
    status,
    heartRate,
    bloodOxygen,
    temperatureRaw,
    temperatureCelsius: temperatureRaw === void 0 ? void 0 : temperatureRaw / 100,
    isTerminal: isFailure || isSuccess,
    isSuccess
  };
}
function decodeBloodOxygenProgress(packet) {
  if (packet.data.byteLength !== 1) {
    throw new ProtocolError(`Unexpected blood oxygen progress data length: ${packet.data.byteLength}.`);
  }
  const progress = new ByteReader(packet.data).readUint8();
  return {
    type: "progress",
    progress,
    isTerminal: progress >= 100,
    isSuccess: progress >= 100
  };
}
function decodeBloodOxygenWaveform(packet) {
  if (packet.data.byteLength < 2) {
    throw new ProtocolError("Blood oxygen waveform response must contain sequence and count.");
  }
  const reader = new ByteReader(packet.data);
  const sequence = reader.readUint8();
  const count = reader.readUint8();
  if (reader.remaining !== count * 14) {
    throw new ProtocolError(`Unexpected blood oxygen waveform data length: ${reader.remaining} for ${count} samples.`);
  }
  const samples = [];
  for (let i = 0; i < count; i += 1) {
    samples.push({
      red: reader.readInt32Le(),
      infrared: reader.readInt32Le(),
      x: reader.readInt16Le(),
      y: reader.readInt16Le(),
      z: reader.readInt16Le()
    });
  }
  return {
    type: "waveform",
    sequence,
    count,
    samples,
    isTerminal: false,
    isSuccess: false
  };
}
function decodeBloodOxygenPerfusionRate(packet) {
  if (packet.data.byteLength !== 4) {
    throw new ProtocolError(`Unexpected blood oxygen perfusion rate data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  return {
    type: "perfusion_rate",
    perfusionRate: reader.readUint8(),
    reserved: [reader.readUint8(), reader.readUint8(), reader.readUint8()],
    isTerminal: false,
    isSuccess: false
  };
}
function decodeBloodOxygenBloodPressure(packet) {
  if (packet.data.byteLength !== 2) {
    throw new ProtocolError(`Unexpected blood oxygen blood pressure data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  return {
    type: "blood_pressure",
    diastolicPressure: reader.readUint8(),
    systolicPressure: reader.readUint8(),
    isTerminal: false,
    isSuccess: false
  };
}
function parseBloodOxygenStatus(value) {
  if (value === 0)
    return "not_wearing";
  if (value === 1)
    return "wearing";
  if (value === 2)
    return "charging";
  if (value === 3)
    return "measuring";
  if (value === 4)
    return "busy";
  if (value === 5)
    return "timeout";
  if (value === 6)
    return "completed";
  throw new ProtocolError(`Unknown blood oxygen measure status: ${value}.`);
}
function assertPositiveByte(value, name) {
  if (!Number.isInteger(value) || value <= 0 || value > 255) {
    throw new ProtocolError(`${name} must be an integer between 1 and 255.`);
  }
}
function assertFlag(value, name) {
  if (value !== 0 && value !== 1) {
    throw new ProtocolError(`${name} must be 0 or 1.`);
  }
}

// packages/protocol-core/dist/version.js
var CMD_VERSION = 17;
var VERSION_LENGTH = 10;
var getFirmwareVersionCodec = createVersionCodec(0);
var getHardwareVersionCodec = createVersionCodec(1);
function createVersionCodec(subcmd) {
  return {
    cmd: CMD_VERSION,
    subcmd,
    encode(_, frameId) {
      return createPacket(frameId, this.cmd, this.subcmd);
    },
    decode(packet) {
      assertResponsePacket(packet, this.cmd, this.subcmd, VERSION_LENGTH);
      const reader = new ByteReader(packet.data);
      return {
        version: trimVersion2(reader.readAscii(VERSION_LENGTH))
      };
    }
  };
}
function trimVersion2(value) {
  return value.replace(/[\u0000 ]+$/g, "");
}

// packages/protocol-core/dist/time.js
var CMD_TIME = 16;
var setTimeCodec = {
  cmd: CMD_TIME,
  subcmd: 0,
  encode(request, frameId) {
    const data = new ByteWriter().writeUint64Le(request.timestampMs).writeInt8(request.timezone).toBytes();
    return createPacket(frameId, this.cmd, this.subcmd, data);
  },
  decode(packet) {
    assertPacketKind(packet, this.cmd, this.subcmd);
  }
};
var getTimeCodec = {
  cmd: CMD_TIME,
  subcmd: 1,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertResponsePacket(packet, this.cmd, this.subcmd, 9);
    const reader = new ByteReader(packet.data);
    return {
      // 协议中时间戳为 8 字节小端无符号整数，后跟 1 字节时区。
      timestampMs: reader.readUint64Le(),
      timezone: reader.readInt8()
    };
  }
};

// packages/protocol-core/dist/temperature.js
var CMD_TEMPERATURE = 52;
var SUBCMD_FAST = 0;
var measureTemperatureCodec = {
  cmd: CMD_TEMPERATURE,
  subcmd: SUBCMD_FAST,
  encode(request, frameId) {
    if ((request === null || request === void 0 ? void 0 : request.mode) && request.mode !== "fast") {
      throw new ProtocolError(`Unsupported temperature measure mode: ${request.mode}.`);
    }
    return createPacket(frameId, this.cmd, this.subcmd, new Uint8Array([0]));
  },
  decode(packet) {
    if (packet.frameType !== 0) {
      throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
    }
    assertPacketKind(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength < 1) {
      throw new ProtocolError("Temperature response must contain status byte.");
    }
    const reader = new ByteReader(packet.data);
    const status = parseTemperatureStatus(reader.readUint8());
    const temperatureRaw = reader.remaining >= 2 ? reader.readInt16Le() : void 0;
    return {
      status,
      temperatureRaw,
      temperatureCelsius: temperatureRaw === void 0 ? void 0 : temperatureRaw / 100,
      isTerminal: status !== "measuring",
      isSuccess: status === "completed"
    };
  }
};
function isTemperatureMeasureTerminal(response) {
  return response.isTerminal;
}
function isTemperatureMeasureFailure(response) {
  return response.isTerminal && !response.isSuccess;
}
function parseTemperatureStatus(value) {
  if (value === 0) {
    return "measuring";
  }
  if (value === 1) {
    return "completed";
  }
  if (value === 2) {
    return "not_wearing";
  }
  if (value === 3) {
    return "busy";
  }
  if (value === 4) {
    return "charging";
  }
  if (value === 5) {
    return "invalid";
  }
  throw new ProtocolError(`Unknown temperature measure status: ${value}.`);
}

// packages/protocol-core/dist/step-count.js
var CMD_STEP_COUNT = 53;
var SUBCMD_READ = 0;
var SUBCMD_CLEAR = 1;
var getStepCountCodec = {
  cmd: CMD_STEP_COUNT,
  subcmd: SUBCMD_READ,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertStepPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 2) {
      throw new ProtocolError(`Unexpected step count data length: ${packet.data.byteLength}.`);
    }
    return {
      stepCount: new ByteReader(packet.data).readUint16Le()
    };
  }
};
var clearStepCountCodec = {
  cmd: CMD_STEP_COUNT,
  subcmd: SUBCMD_CLEAR,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertStepPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected clear step count data length: ${packet.data.byteLength}.`);
    }
    return { cleared: true };
  }
};
function assertStepPacket(packet, cmd, subcmd) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind(packet, cmd, subcmd);
}

// packages/protocol-core/dist/system-settings.js
var CMD_SYSTEM_SETTINGS = 55;
var CMD_FIXTURE_TESTING = 242;
var SUBCMD_SET_COLLECTION_PERIOD = 0;
var SUBCMD_GET_COLLECTION_PERIOD = 1;
var SUBCMD_RESTORE_FACTORY_SETTINGS = 2;
var SUBCMD_SET_BLUETOOTH_NAME = 3;
var SUBCMD_GET_BLUETOOTH_NAME = 4;
var SUBCMD_ONE_KEY_SELF_INSPECTION = 24;
var MAX_BLUETOOTH_NAME_BYTES = 12;
var SELF_INSPECTION_FLAGS = [
  { bit: 1, key: "ppg_communication", description: "PPG\u901A\u8BAF\u9519\u8BEF" },
  { bit: 2, key: "gsensor_communication", description: "Gsensor\u901A\u8BAF\u9519\u8BEF" },
  { bit: 4, key: "pmic_communication", description: "PMIC\u901A\u8BAF\u9519\u8BEF" },
  { bit: 8, key: "bat_adc", description: "BatAdc\u9519\u8BEF" },
  { bit: 16, key: "temp_adc", description: "TempAdc\u9519\u8BEF" },
  { bit: 32, key: "ppg_led", description: "PPG led\u6545\u969C" },
  { bit: 64, key: "gsensor", description: "Gsensor\u6545\u969C" },
  { bit: 128, key: "puf", description: "puf\u52A0\u5BC6\u82AF\u7247\u901A\u4FE1\u6545\u969C" },
  { bit: 256, key: "touch", description: "touch\u901A\u4FE1\u6545\u969C" }
];
var setCollectionPeriodCodec = {
  cmd: CMD_SYSTEM_SETTINGS,
  subcmd: SUBCMD_SET_COLLECTION_PERIOD,
  encode(request, frameId) {
    assertCollectionPeriod(request.periodSeconds);
    return createPacket(frameId, this.cmd, this.subcmd, new ByteWriter().writeUint32Le(request.periodSeconds).toBytes());
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    return decodeSettingResult(packet, "set collection period");
  }
};
var getCollectionPeriodCodec = {
  cmd: CMD_SYSTEM_SETTINGS,
  subcmd: SUBCMD_GET_COLLECTION_PERIOD,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 4) {
      throw new ProtocolError(`Unexpected collection period data length: ${packet.data.byteLength}.`);
    }
    return { periodSeconds: new ByteReader(packet.data).readUint32Le() };
  }
};
var restoreFactorySettingsCodec = {
  cmd: CMD_SYSTEM_SETTINGS,
  subcmd: SUBCMD_RESTORE_FACTORY_SETTINGS,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected restore factory settings data length: ${packet.data.byteLength}.`);
    }
    return { accepted: true };
  }
};
var setBluetoothNameCodec = {
  cmd: CMD_SYSTEM_SETTINGS,
  subcmd: SUBCMD_SET_BLUETOOTH_NAME,
  encode(request, frameId) {
    const nameBytes = encodeUtf8Name(request.name);
    const data = new Uint8Array(nameBytes.byteLength + 1);
    data[0] = nameBytes.byteLength;
    data.set(nameBytes, 1);
    return createPacket(frameId, this.cmd, this.subcmd, data);
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    return decodeSettingResult(packet, "set bluetooth name");
  }
};
var getBluetoothNameCodec = {
  cmd: CMD_SYSTEM_SETTINGS,
  subcmd: SUBCMD_GET_BLUETOOTH_NAME,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength < 1) {
      throw new ProtocolError("Bluetooth name response must contain length byte.");
    }
    const length = packet.data[0];
    if (length > MAX_BLUETOOTH_NAME_BYTES) {
      throw new ProtocolError(`Bluetooth name length exceeds ${MAX_BLUETOOTH_NAME_BYTES} bytes.`);
    }
    if (packet.data.byteLength < length + 1) {
      throw new ProtocolError(`Bluetooth name payload is shorter than declared length: ${length}.`);
    }
    return {
      length,
      name: decodeUtf8(packet.data.slice(1, length + 1))
    };
  }
};
var oneKeySelfInspectionCodec = {
  cmd: CMD_FIXTURE_TESTING,
  subcmd: SUBCMD_ONE_KEY_SELF_INSPECTION,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertSystemSettingPacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 2) {
      throw new ProtocolError(`Unexpected self inspection data length: ${packet.data.byteLength}.`);
    }
    const errorCode = new ByteReader(packet.data).readUint16Le();
    const faults = SELF_INSPECTION_FLAGS.filter((flag) => (errorCode & flag.bit) !== 0).map((flag) => ({
      bit: flag.bit,
      key: flag.key,
      description: flag.description
    }));
    return {
      errorCode,
      hasError: errorCode > 0,
      faults,
      description: faults.length === 0 ? "\u8BBE\u5907\u81EA\u68C0\u6B63\u5E38\uFF0C\u65E0\u6545\u969C" : `\u8BBE\u5907\u81EA\u68C0\u53D1\u73B0\u6545\u969C\uFF1A${faults.map((fault) => fault.description).join("\u3001")}`
    };
  }
};
function decodeSettingResult(packet, label) {
  if (packet.data.byteLength !== 1) {
    throw new ProtocolError(`Unexpected ${label} data length: ${packet.data.byteLength}.`);
  }
  const status = packet.data[0];
  return {
    status,
    success: status === 1
  };
}
function assertSystemSettingPacket(packet, cmd, subcmd) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind(packet, cmd, subcmd);
}
function assertCollectionPeriod(periodSeconds) {
  if (!Number.isInteger(periodSeconds) || periodSeconds < 0 || periodSeconds > 4294967295) {
    throw new ProtocolError("collection period must be an integer between 0 and 4294967295.");
  }
  if (periodSeconds !== 0 && periodSeconds < 60) {
    throw new ProtocolError("collection period must be 0 or at least 60 seconds.");
  }
}
function encodeUtf8Name(name) {
  if (name.length === 0) {
    throw new ProtocolError("Bluetooth name cannot be empty.");
  }
  const bytes = encodeUtf8(name);
  if (bytes.byteLength > MAX_BLUETOOTH_NAME_BYTES) {
    throw new ProtocolError(`Bluetooth name must be at most ${MAX_BLUETOOTH_NAME_BYTES} UTF-8 bytes.`);
  }
  return bytes;
}
function encodeUtf8(value) {
  const encoded = encodeURIComponent(value);
  const bytes = [];
  for (let i = 0; i < encoded.length; i += 1) {
    if (encoded[i] === "%") {
      bytes.push(Number.parseInt(encoded.slice(i + 1, i + 3), 16));
      i += 2;
    } else {
      bytes.push(encoded.charCodeAt(i));
    }
  }
  return new Uint8Array(bytes);
}
function decodeUtf8(bytes) {
  let encoded = "";
  for (const byte of bytes) {
    encoded += `%${byte.toString(16).padStart(2, "0")}`;
  }
  try {
    return decodeURIComponent(encoded);
  } catch (_) {
    throw new ProtocolError("Bluetooth name contains invalid UTF-8 bytes.");
  }
}

// packages/protocol-core/dist/heart-rate.js
var CMD_HEART_RATE = 49;
var SUBCMD_TAKE2 = 0;
var SUBCMD_WAVEFORM2 = 1;
var SUBCMD_RR_INTERVAL = 2;
var SUBCMD_STOP2 = 4;
var SUBCMD_PROGRESS2 = 255;
var startHeartRateCodec = {
  cmd: CMD_HEART_RATE,
  subcmd: SUBCMD_TAKE2,
  encode(request, frameId) {
    const normalized = normalizeHeartRateRequest(request);
    const data = new ByteWriter().writeUint8(normalized.collectTime).writeUint8(normalized.collectFrequency).writeUint8(normalized.waveformConfig).writeUint8(normalized.progressConfig).writeUint8(normalized.intervalConfig).toBytes();
    return createPacket(frameId, this.cmd, this.subcmd, data);
  },
  decode(packet) {
    assertHeartRatePacket(packet);
    if (packet.subcmd === SUBCMD_TAKE2) {
      return decodeHeartRateResult(packet);
    }
    if (packet.subcmd === SUBCMD_PROGRESS2) {
      return decodeHeartRateProgress(packet);
    }
    if (packet.subcmd === SUBCMD_WAVEFORM2) {
      return decodeHeartRateWaveform(packet);
    }
    if (packet.subcmd === SUBCMD_RR_INTERVAL) {
      return decodeHeartRateRRInterval(packet);
    }
    throw new ProtocolError(`Unexpected heart rate subcmd: 0x${packet.subcmd.toString(16)}.`);
  }
};
var stopHeartRateCodec = {
  cmd: CMD_HEART_RATE,
  subcmd: SUBCMD_STOP2,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    if (packet.frameType !== 0) {
      throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
    }
    assertPacketKind(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength !== 0) {
      throw new ProtocolError(`Unexpected stop heart rate data length: ${packet.data.byteLength}.`);
    }
    return { stopped: true };
  }
};
function isHeartRateMeasurePacket(packet) {
  return packet.cmd === CMD_HEART_RATE && [SUBCMD_TAKE2, SUBCMD_WAVEFORM2, SUBCMD_RR_INTERVAL, SUBCMD_PROGRESS2].includes(packet.subcmd);
}
function isHeartRateMeasureTerminal(event) {
  return event.isTerminal;
}
function isHeartRateMeasureFailure(event) {
  return event.isTerminal && !event.isSuccess;
}
function normalizeHeartRateRequest(request) {
  var _a, _b, _c, _d, _e;
  const normalized = {
    collectTime: (_a = request === null || request === void 0 ? void 0 : request.collectTime) !== null && _a !== void 0 ? _a : 30,
    collectFrequency: (_b = request === null || request === void 0 ? void 0 : request.collectFrequency) !== null && _b !== void 0 ? _b : 50,
    waveformConfig: (_c = request === null || request === void 0 ? void 0 : request.waveformConfig) !== null && _c !== void 0 ? _c : 1,
    progressConfig: (_d = request === null || request === void 0 ? void 0 : request.progressConfig) !== null && _d !== void 0 ? _d : 1,
    intervalConfig: (_e = request === null || request === void 0 ? void 0 : request.intervalConfig) !== null && _e !== void 0 ? _e : 1
  };
  assertPositiveByte2(normalized.collectTime, "collectTime");
  assertPositiveByte2(normalized.collectFrequency, "collectFrequency");
  assertFlag2(normalized.waveformConfig, "waveformConfig");
  assertFlag2(normalized.progressConfig, "progressConfig");
  assertFlag2(normalized.intervalConfig, "intervalConfig");
  return normalized;
}
function assertHeartRatePacket(packet) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  if (!isHeartRateMeasurePacket(packet)) {
    throw new ProtocolError(`Unexpected heart rate packet: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
  }
}
function decodeHeartRateResult(packet) {
  if (packet.data.byteLength < 1) {
    throw new ProtocolError("Heart rate result response must contain status byte.");
  }
  const reader = new ByteReader(packet.data);
  const status = parseHeartRateStatus(reader.readUint8());
  const heartRate = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const heartRateVariability = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const stressIndex = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const temperatureRaw = reader.remaining >= 2 ? reader.readInt16Le() : void 0;
  const progress = reader.remaining >= 1 ? reader.readUint8() : void 0;
  const isFailure = ["not_wearing", "charging", "busy", "timeout"].includes(status);
  const isSuccess = status === "completed" || progress === 100;
  return {
    type: "result",
    status,
    heartRate,
    heartRateVariability,
    stressIndex,
    temperatureRaw,
    temperatureCelsius: temperatureRaw === void 0 ? void 0 : temperatureRaw / 100,
    progress,
    isTerminal: isFailure || isSuccess,
    isSuccess
  };
}
function decodeHeartRateProgress(packet) {
  if (packet.data.byteLength !== 1) {
    throw new ProtocolError(`Unexpected heart rate progress data length: ${packet.data.byteLength}.`);
  }
  const progress = new ByteReader(packet.data).readUint8();
  return {
    type: "progress",
    progress,
    isTerminal: progress >= 100,
    isSuccess: progress >= 100
  };
}
function decodeHeartRateWaveform(packet) {
  if (packet.data.byteLength < 2) {
    throw new ProtocolError("Heart rate waveform response must contain sequence and count.");
  }
  const reader = new ByteReader(packet.data);
  const sequence = reader.readUint8();
  const count = reader.readUint8();
  if (reader.remaining !== count * 10) {
    throw new ProtocolError(`Unexpected heart rate waveform data length: ${reader.remaining} for ${count} samples.`);
  }
  const samples = [];
  for (let i = 0; i < count; i += 1) {
    samples.push({
      green: reader.readInt32Le(),
      x: reader.readInt16Le(),
      y: reader.readInt16Le(),
      z: reader.readInt16Le()
    });
  }
  return {
    type: "waveform",
    sequence,
    count,
    samples,
    isTerminal: false,
    isSuccess: false
  };
}
function decodeHeartRateRRInterval(packet) {
  if (packet.data.byteLength < 2) {
    throw new ProtocolError("Heart rate RR interval response must contain sequence and count.");
  }
  if ((packet.data.byteLength - 2) % 2 !== 0) {
    throw new ProtocolError(`Unexpected RR interval byte length: ${packet.data.byteLength - 2}.`);
  }
  const reader = new ByteReader(packet.data);
  const sequence = reader.readUint8();
  const count = reader.readUint8();
  const intervalsMs = [];
  while (reader.remaining >= 2) {
    intervalsMs.push(reader.readUint16Le());
  }
  return {
    type: "rr_interval",
    sequence,
    count,
    intervalsMs,
    isTerminal: false,
    isSuccess: false
  };
}
function parseHeartRateStatus(value) {
  if (value === 0)
    return "not_wearing";
  if (value === 1)
    return "wearing";
  if (value === 2)
    return "charging";
  if (value === 3)
    return "measuring";
  if (value === 4)
    return "busy";
  if (value === 5)
    return "timeout";
  if (value === 6)
    return "completed";
  throw new ProtocolError(`Unknown heart rate measure status: ${value}.`);
}
function assertPositiveByte2(value, name) {
  if (!Number.isInteger(value) || value <= 0 || value > 255) {
    throw new ProtocolError(`${name} must be an integer between 1 and 255.`);
  }
}
function assertFlag2(value, name) {
  if (value !== 0 && value !== 1) {
    throw new ProtocolError(`${name} must be 0 or 1.`);
  }
}

// packages/protocol-core/dist/gomore.js
var CMD_GOMORE_AUTH = 129;
var CMD_RING_DATA3 = 54;
var CMD_SYSTEM_SETTINGS2 = 55;
var SUBCMD_QUERY_AUTH_STATUS = 3;
var SUBCMD_SEND_PKEY = 4;
var SUBCMD_READ_SLEEP_DATA = 5;
var SUBCMD_SET_PERSONAL_INFO = 35;
var SUBCMD_GET_PERSONAL_INFO = 36;
var PKEY_BYTE_LENGTH = 64;
var queryGoMoreAuthStatusCodec = {
  cmd: CMD_GOMORE_AUTH,
  subcmd: SUBCMD_QUERY_AUTH_STATUS,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertGoMorePacket(packet, this.cmd, this.subcmd);
    return decodeAuthStatus(packet);
  }
};
var sendGoMorePKeyCodec = {
  cmd: CMD_GOMORE_AUTH,
  subcmd: SUBCMD_SEND_PKEY,
  encode(request, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd, encodePKey(request.pKey));
  },
  decode(packet) {
    assertGoMorePacket(packet, this.cmd, this.subcmd);
    return decodeAuthStatus(packet);
  }
};
var setGoMorePersonalInformationCodec = {
  cmd: CMD_SYSTEM_SETTINGS2,
  subcmd: SUBCMD_SET_PERSONAL_INFO,
  encode(request, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd, encodePersonalInformation(request));
  },
  decode(packet) {
    assertGoMorePacket(packet, this.cmd, this.subcmd);
    if (packet.data.byteLength < 1) {
      throw new ProtocolError("GoMore set personal information response must contain status byte.");
    }
    const status = packet.data[0];
    return { status, success: status === 0 };
  }
};
var getGoMorePersonalInformationCodec = {
  cmd: CMD_SYSTEM_SETTINGS2,
  subcmd: SUBCMD_GET_PERSONAL_INFO,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertGoMorePacket(packet, this.cmd, this.subcmd);
    return decodePersonalInformation(packet.data);
  }
};
var readGoMoreSleepDataCodec = {
  cmd: CMD_RING_DATA3,
  subcmd: SUBCMD_READ_SLEEP_DATA,
  encode(_, frameId) {
    return createPacket(frameId, this.cmd, this.subcmd);
  },
  decode(packet) {
    assertGoMorePacket(packet, this.cmd, this.subcmd);
    return decodeGoMoreSleepEvent(packet);
  }
};
function isGoMoreSleepDataPacket(packet) {
  return packet.cmd === CMD_RING_DATA3 && packet.subcmd === SUBCMD_READ_SLEEP_DATA;
}
function decodeAuthStatus(packet) {
  if (packet.data.byteLength < 9) {
    throw new ProtocolError(`Unexpected GoMore auth status data length: ${packet.data.byteLength}.`);
  }
  const authStatus = packet.data[0];
  const rawMcuId = packet.data.slice(1, 9);
  return {
    authStatus,
    isAuthorized: authStatus === 0,
    rawMcuIdHex: bytesToHex(rawMcuId),
    mcuIdHexString: reorderMcuId(rawMcuId),
    rawHex: bytesToHex(encodePacket(packet))
  };
}
function encodePKey(pKey) {
  const pKeyBytes = encodeUtf82(pKey);
  const data = new Uint8Array(PKEY_BYTE_LENGTH);
  data.set(pKeyBytes.slice(0, PKEY_BYTE_LENGTH));
  return data;
}
function encodePersonalInformation(request) {
  assertPersonalInformation(request);
  const data = new Uint8Array(8);
  data[0] = request.age;
  data[1] = request.gender;
  data[2] = request.height;
  data[3] = request.weight;
  const maxHeartRate = optionalInt(request.maxHeartRate);
  if (maxHeartRate === void 0) {
    data[4] = 255;
    data[5] = 255;
  } else {
    assertRange(maxHeartRate, 0, 65535, "GoMore maxHeartRate");
    data[4] = maxHeartRate & 255;
    data[5] = maxHeartRate >> 8 & 255;
  }
  const normalHeartRate = optionalInt(request.normalHeartRate);
  data[6] = normalHeartRate === void 0 ? 255 : checkedByte(normalHeartRate, "GoMore normalHeartRate");
  const maxOxygenUptake = optionalInt(request.maxOxygenUptake);
  data[7] = maxOxygenUptake === void 0 ? 255 : checkedByte(maxOxygenUptake, "GoMore maxOxygenUptake");
  return data;
}
function decodePersonalInformation(data) {
  if (data.byteLength < 8) {
    throw new ProtocolError(`Unexpected GoMore personal information data length: ${data.byteLength}.`);
  }
  const reader = new ByteReader(data);
  const age = reader.readUint8();
  const gender = reader.readUint8();
  const height = reader.readUint8();
  const weight = reader.readUint8();
  const maxHeartRateRaw = reader.readUint16Le();
  const normalHeartRateRaw = reader.readUint8();
  const maxOxygenUptakeRaw = reader.readUint8();
  return {
    age,
    gender: gender === 0 ? 0 : 1,
    height,
    weight,
    maxHeartRate: maxHeartRateRaw === 65535 ? void 0 : maxHeartRateRaw,
    normalHeartRate: normalHeartRateRaw === 255 ? void 0 : normalHeartRateRaw,
    maxOxygenUptake: maxOxygenUptakeRaw === 255 ? void 0 : maxOxygenUptakeRaw
  };
}
function decodeGoMoreSleepEvent(packet) {
  if (packet.data.byteLength < 1) {
    throw new ProtocolError("GoMore sleep data response must contain resType byte.");
  }
  const resType = packet.data[0];
  if (resType === 0 && isAllZero(packet.data)) {
    return { type: "no_data", resType: 2, isTerminal: true, rawHex: bytesToHex(encodePacket(packet)) };
  }
  if (resType === 0) {
    return decodeSleepOverview(packet);
  }
  if (resType === 1) {
    return decodeSleepStages(packet);
  }
  if (resType === 2) {
    return { type: "no_data", resType, isTerminal: true, rawHex: bytesToHex(encodePacket(packet)) };
  }
  if (resType === 3) {
    return { type: "end", resType, isTerminal: true, rawHex: bytesToHex(encodePacket(packet)) };
  }
  throw new ProtocolError(`Unknown GoMore sleep resType: ${resType}.`);
}
function decodeSleepOverview(packet) {
  if (packet.data.byteLength < 41) {
    throw new ProtocolError(`Unexpected GoMore sleep overview data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  reader.readUint8();
  const overview = {
    type: "overview",
    resType: 0,
    startTs: reader.readUint32Le(),
    endTs: reader.readUint32Le(),
    numEpochs: reader.readUint16Le(),
    latency: reader.readUint16Le(),
    wakeTimes: reader.readUint16Le(),
    totalSleepTime: reader.readUint16Le(),
    waso: reader.readUint16Le(),
    sleepPeriod: reader.readUint16Le(),
    efficiency: reader.readUint16Le(),
    wakeRatio: reader.readUint16Le(),
    remRatio: reader.readUint16Le(),
    lightRatio: reader.readUint16Le(),
    deepRatio: reader.readUint16Le(),
    wakeNumMinutes: reader.readUint16Le(),
    remNumMinutes: reader.readUint16Le(),
    lightNumMinutes: reader.readUint16Le(),
    deepNumMinutes: reader.readUint16Le(),
    score: reader.readUint8(),
    sleepType: reader.readUint8(),
    isTerminal: false,
    rawHex: bytesToHex(encodePacket(packet))
  };
  if (packet.data.byteLength >= 78) {
    overview.totalSleepTimeScore = readFloat32Le(packet.data, 41);
    overview.sleepEfficiencyScore = readFloat32Le(packet.data, 45);
    overview.wakeTimeScore = readFloat32Le(packet.data, 49);
    overview.deepRatioScore = readFloat32Le(packet.data, 53);
    overview.remRatioScore = readFloat32Le(packet.data, 57);
    overview.sriScore = readFloat32Le(packet.data, 61);
    overview.hrvScore = readFloat32Le(packet.data, 65);
    overview.sri = packet.data[69] > 127 ? packet.data[69] - 256 : packet.data[69];
    overview.nightlyRmssd = readFloat32Le(packet.data, 70);
    overview.sleepScore = readFloat32Le(packet.data, 74);
  }
  return overview;
}
function decodeSleepStages(packet) {
  if (packet.data.byteLength < 12) {
    throw new ProtocolError(`Unexpected GoMore sleep stages data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader(packet.data);
  reader.readUint8();
  const startTs = reader.readUint32Le();
  const endTs = reader.readUint32Le();
  const packNum = reader.readUint8();
  const packNo = reader.readUint8();
  const stageNum = reader.readUint8();
  const expectedLength = 12 + stageNum;
  if (packet.data.byteLength < expectedLength) {
    throw new ProtocolError(`Unexpected GoMore sleep stages data length: expected ${expectedLength}, got ${packet.data.byteLength}.`);
  }
  const stages = [];
  for (let i = 0; i < stageNum; i += 1) {
    stages.push(reader.readInt8());
  }
  return {
    type: "stages",
    resType: 1,
    startTs,
    endTs,
    packNum,
    packNo,
    stageNum,
    stages,
    isTerminal: false,
    rawHex: bytesToHex(encodePacket(packet))
  };
}
function reorderMcuId(mcuId) {
  const reordered = [
    ...Array.from(mcuId.slice(0, 4)).reverse(),
    ...Array.from(mcuId.slice(4, 8)).reverse()
  ];
  return bytesToHex(new Uint8Array(reordered)).toUpperCase();
}
function assertGoMorePacket(packet, cmd, subcmd) {
  if (packet.frameType !== 0) {
    throw new ProtocolError(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind(packet, cmd, subcmd);
}
function assertPersonalInformation(request) {
  assertRange(request.age, 10, 99, "GoMore age");
  assertRange(request.gender, 0, 1, "GoMore gender");
  assertRange(request.height, 100, 220, "GoMore height");
  assertRange(request.weight, 10, 150, "GoMore weight");
}
function assertRange(value, min, max, label) {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new ProtocolError(`${label} must be an integer between ${min} and ${max}.`);
  }
}
function optionalInt(value) {
  if (value === null || value === void 0 || value < 0) {
    return void 0;
  }
  if (!Number.isInteger(value)) {
    throw new ProtocolError("GoMore optional personal information value must be an integer.");
  }
  return value;
}
function checkedByte(value, label) {
  assertRange(value, 0, 255, label);
  return value;
}
function isAllZero(data) {
  for (const value of data) {
    if (value !== 0) {
      return false;
    }
  }
  return true;
}
function readFloat32Le(data, offset) {
  const view = new DataView(data.buffer, data.byteOffset + offset, 4);
  return view.getFloat32(0, true);
}
function encodeUtf82(value) {
  const encoded = encodeURIComponent(value);
  const bytes = [];
  for (let i = 0; i < encoded.length; i += 1) {
    if (encoded[i] === "%") {
      bytes.push(Number.parseInt(encoded.slice(i + 1, i + 3), 16));
      i += 2;
    } else {
      bytes.push(encoded.charCodeAt(i));
    }
  }
  return new Uint8Array(bytes);
}

// packages/protocol-core/dist/ota/nordic.js
function parseNordicFirmware(firmware) {
  if (!((firmware === null || firmware === void 0 ? void 0 : firmware.initPacket) instanceof Uint8Array) || !((firmware === null || firmware === void 0 ? void 0 : firmware.image) instanceof Uint8Array) || firmware.initPacket.length === 0 || firmware.initPacket.length > 65535 || firmware.image.length === 0 || firmware.image.length > 16 * 1024 * 1024) {
    throw new Error("Nordic \u56FA\u4EF6\u9700\u8981\u975E\u7A7A DAT\uFF08\u226465535\uFF09\u548C BIN\uFF08\u226416MiB\uFF09");
  }
  return { initPacket: firmware.initPacket.slice(), image: firmware.image.slice() };
}
function nordicCrc32(data, previous = 0) {
  let crc = (previous ^ 4294967295) >>> 0;
  for (const byte of data) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++)
      crc = crc >>> 1 ^ (crc & 1 ? 3988292384 : 0);
  }
  return (crc ^ 4294967295) >>> 0;
}
function encodeNordicCreate(type, size) {
  if (type !== 1 && type !== 2 || !Number.isInteger(size) || size <= 0 || size > 4294967295)
    throw new Error("Nordic \u5BF9\u8C61\u957F\u5EA6\u65E0\u6548");
  const result = new Uint8Array([1, type, 0, 0, 0, 0]);
  new DataView(result.buffer).setUint32(2, size, true);
  return result;
}
function decodeNordicResponse(data, opcode) {
  var _a;
  if (data.length < 3 || data[0] !== 96 || data[1] !== opcode)
    throw new Error("Nordic \u63A7\u5236\u70B9\u54CD\u5E94\u5934\u65E0\u6548");
  if (data[2] !== 1)
    throw new Error(`Nordic \u62D2\u7EDD\u547D\u4EE4 0x${opcode.toString(16)}\uFF0C\u72B6\u6001 0x${data[2].toString(16)}${data[2] === 11 ? `\uFF0C\u6269\u5C55\u7801 ${(_a = data[3]) !== null && _a !== void 0 ? _a : "\u7F3A\u5931"}` : ""}`);
  const length = opcode === 6 ? 15 : opcode === 3 ? 11 : 3;
  if (data.length !== length)
    throw new Error(`Nordic \u54CD\u5E94\u957F\u5EA6\u65E0\u6548\uFF0C\u9884\u671F ${length}\uFF0C\u5B9E\u9645 ${data.length}`);
  return data.slice(3);
}
function encodeNordicBootloaderName(name) {
  if (!/^[\x21-\x7e]{1,20}$/.test(name))
    throw new Error("Nordic \u4E34\u65F6\u5E7F\u64AD\u540D\u5FC5\u987B\u4E3A 1\uFF5E20 \u5B57\u8282 ASCII");
  return new Uint8Array([2, name.length, ...Array.from(name, (c) => c.charCodeAt(0))]);
}
function decodeNordicButtonlessResponse(data, opcode) {
  if (data.length !== 3 || data[0] !== 32 || data[1] !== opcode)
    throw new Error("Nordic Buttonless \u54CD\u5E94\u683C\u5F0F\u65E0\u6548");
  return data[2];
}

// packages/protocol-core/dist/ota/phy.js
var PHY_PACKET_SIZE = 237;
var PHY_WINDOW_SIZE = 16;
function phyCrc16(data, seed = 0) {
  const table = [
    0,
    52225,
    55297,
    5120,
    61441,
    15360,
    10240,
    58369,
    40961,
    27648,
    30720,
    46081,
    20480,
    39937,
    34817,
    17408
  ];
  let crc = seed & 65535;
  for (const byte of data) {
    crc = crc >>> 4 ^ table[crc & 15] ^ table[byte & 15];
    crc = crc >>> 4 ^ table[crc & 15] ^ table[byte >>> 4];
  }
  return crc & 65535;
}
function parsePhyFirmware(input) {
  var _a;
  if (input.length > 8 * 1024 * 1024)
    throw new Error("PHY HEX \u6587\u4EF6\u8D85\u8FC7 8MiB");
  let text = typeof input === "string" ? input : "";
  if (input instanceof Uint8Array) {
    for (let offset = 0; offset < input.length; offset += 8192)
      text += String.fromCharCode(...input.subarray(offset, offset + 8192));
  }
  const sections = [];
  let current;
  let eof = false;
  let nextFlash = 0;
  const finish = () => {
    if (!current)
      return;
    if (!current.bytes.length || current.start === void 0)
      throw new Error("PHY \u5B58\u5728\u7A7A\u5206\u533A");
    const runAddress = current.base + current.start;
    const direct = runAddress >= 285212672 && runAddress <= 285736959;
    const flashAddress = direct ? runAddress : nextFlash;
    const data = new Uint8Array(current.bytes);
    if (flashAddress + data.length > 4294967296 || runAddress + data.length > 4294967296)
      throw new Error("PHY \u5206\u533A\u5730\u5740\u6EA2\u51FA");
    sections.push({ index: sections.length, runAddress, flashAddress, data, crc: phyCrc16(data) });
    if (!direct)
      nextFlash += data.length + 8;
    current = void 0;
  };
  for (const [index, raw] of text.split(/\r?\n/).entries()) {
    const line = raw.trim();
    if (!line)
      continue;
    if (eof)
      throw new Error(`PHY EOF \u540E\u8FD8\u6709\u8BB0\u5F55\uFF0C\u7B2C ${index + 1} \u884C`);
    if (!/^:(?:[0-9a-fA-F]{2}){5,}$/.test(line))
      throw new Error(`PHY HEX \u683C\u5F0F\u9519\u8BEF\uFF0C\u7B2C ${index + 1} \u884C`);
    const bytes = new Uint8Array(line.slice(1).match(/../g).map((v) => parseInt(v, 16)));
    if (bytes.length !== bytes[0] + 5 || bytes.reduce((a, b) => a + b, 0) % 256 !== 0)
      throw new Error(`PHY HEX \u957F\u5EA6\u6216\u6821\u9A8C\u548C\u9519\u8BEF\uFF0C\u7B2C ${index + 1} \u884C`);
    const length = bytes[0];
    const address = bytes[1] * 256 + bytes[2];
    const type = bytes[3];
    if (type === 4) {
      if (length !== 2 || address !== 0)
        throw new Error("PHY \u6269\u5C55\u7EBF\u6027\u5730\u5740\u8BB0\u5F55\u65E0\u6548");
      finish();
      current = { base: (bytes[4] * 256 + bytes[5]) * 65536, bytes: [] };
    } else if (type === 0) {
      if (!current || !length || address + length > 65536)
        throw new Error("PHY \u6570\u636E\u7F3A\u5C11\u5206\u533A\u5934\u6216\u8DE8\u8D8A\u5730\u5740\u8FB9\u754C");
      if (current.next !== void 0 && current.next !== address)
        throw new Error("PHY \u5206\u533A\u5730\u5740\u4E0D\u8FDE\u7EED\uFF0C\u4E0D\u80FD\u63A8\u6D4B\u586B\u5145\u503C");
      (_a = current.start) !== null && _a !== void 0 ? _a : current.start = address;
      current.next = address + length;
      current.bytes.push(...bytes.subarray(4, 4 + length));
    } else if (type === 1 && length === 0 && address === 0) {
      finish();
      eof = true;
    } else
      throw new Error(`PHY \u6682\u4E0D\u652F\u6301 HEX \u8BB0\u5F55\u7C7B\u578B ${type}`);
  }
  if (!eof || !sections.length || sections.length > 255)
    throw new Error("PHY \u7F3A\u5C11 EOF\u3001\u6709\u6548\u5206\u533A\u6216\u5206\u533A\u6570\u8D85\u8FC7 255");
  return { sections, totalBytes: sections.reduce((sum, s) => sum + s.data.length, 0) };
}
function encodePhySection(section) {
  const bytes = new Uint8Array(16);
  const view = new DataView(bytes.buffer);
  bytes.set([2, section.index]);
  view.setUint32(2, section.flashAddress, true);
  view.setUint32(6, section.runAddress, true);
  view.setUint32(10, section.data.length, true);
  view.setUint16(14, section.crc, true);
  return bytes;
}
function decodePhyAck(data) {
  if (data.length < 2)
    throw new Error("PHY \u5E94\u7B54\u4E0D\u8DB3 2 \u5B57\u8282");
  if (![129, 132, 135, 133, 131].includes(data[1]))
    throw new Error(`PHY \u672A\u77E5\u5E94\u7B54 ${data[1]}`);
  return { status: data[0], opcode: data[1] };
}
function isPhyBootAdvertisement(device) {
  return [device.name, device.localName].some((name) => name === null || name === void 0 ? void 0 : name.toLowerCase().includes("pplusota"));
}
function shiftPhyMac(mac, delta) {
  if (!/^(?:[0-9a-f]{2}:){5}[0-9a-f]{2}$/i.test(mac))
    return void 0;
  const value = parseInt(mac.replace(/:/g, ""), 16) + delta;
  if (value < 0 || value > 281474976710655)
    return void 0;
  return value.toString(16).padStart(12, "0").toUpperCase().match(/../g).join(":");
}
function getPhyBootMac(data) {
  return data.length >= 8 ? [7, 6, 5, 4, 3, 2].map((i) => data[i].toString(16).padStart(2, "0").toUpperCase()).join(":") : void 0;
}

// packages/sdk-core/dist/ota/apollo-ota.js
var ApolloOtaError = class extends Error {
  constructor(code, message, status) {
    super(message);
    this.code = code;
    this.status = status;
    this.name = "ApolloOtaError";
  }
};
var occupiedTransports = /* @__PURE__ */ new WeakSet();
var ApolloOtaUpdater = class {
  constructor(transport) {
    this.transport = transport;
  }
  /** 从头升级；入参固件在首次写入前复制，失败后不自动重发或续传。 */
  async start(firmware, options = {}) {
    var _a, _b, _c, _d;
    if (this.active || occupiedTransports.has(this.transport)) {
      throw new ApolloOtaError("busy", "Apollo \u901A\u9053\u4ECD\u6709\u5347\u7EA7\u6216\u672A\u5B8C\u6210\u5199\u5165");
    }
    const payloadSize = (_a = options.payloadSize) !== null && _a !== void 0 ? _a : 237;
    const timeoutMs = (_b = options.timeoutMs) !== null && _b !== void 0 ? _b : 5e3;
    const intervalMs = (_c = options.intervalMs) !== null && _c !== void 0 ? _c : 0;
    if (!Number.isInteger(payloadSize) || payloadSize < 1 || payloadSize > 237 || !Number.isFinite(timeoutMs) || timeoutMs <= 0 || timeoutMs > 2147483647 || !Number.isFinite(intervalMs) || intervalMs < 0 || intervalMs > 2147483647) {
      throw new ApolloOtaError("invalid_options", "Apollo \u5206\u7247\u5927\u5C0F\u3001\u8D85\u65F6\u6216\u95F4\u9694\u65E0\u6548");
    }
    let image;
    try {
      image = parseApolloFirmware(firmware);
    } catch (error) {
      throw new ApolloOtaError("invalid_firmware", error instanceof Error ? error.message : "\u56FA\u4EF6\u65E0\u6548");
    }
    let releaseIdle;
    const idle = new Promise((resolve) => {
      releaseIdle = resolve;
    });
    const session = {
      state: "preparing",
      totalBytes: image.bodySize,
      offset: 0,
      subscriptions: [],
      writes: /* @__PURE__ */ new Set(),
      done: false,
      idle,
      release: releaseIdle,
      options: { ...options, payloadSize, timeoutMs, intervalMs }
    };
    this.active = session;
    occupiedTransports.add(this.transport);
    try {
      session.subscriptions.push(this.transport.onNotification((data) => this.handleNotification(session, data)));
      session.subscriptions.push(this.transport.onDisconnect(() => {
        if (!session.done)
          this.fail(session, new ApolloOtaError("disconnected", "Apollo \u5347\u7EA7\u8BBE\u5907\u5DF2\u65AD\u8FDE"));
      }));
      this.progress(session, "preparing");
      this.progress(session, "sendingHeader");
      await this.exchange(session, 1, image.header, 0);
      this.progress(session, "sendingData");
      while (session.offset < image.bodySize) {
        const end = Math.min(session.offset + APOLLO_BLOCK_SIZE, image.bodySize);
        await this.exchange(session, 2, image.body.subarray(session.offset, end), end);
        session.offset = end;
        this.progress(session, "sendingData");
      }
      this.progress(session, "verifying");
      await this.exchange(session, 3);
      this.progress(session, "resetting");
      await this.exchange(session, 4);
      this.assertActive(session);
      session.done = true;
      this.progress(session, "completed");
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: session.offset };
    } catch (error) {
      const failure = (_d = session.error) !== null && _d !== void 0 ? _d : error instanceof ApolloOtaError ? error : new ApolloOtaError("transport_error", error instanceof Error ? error.message : "OTA \u4F20\u8F93\u5F02\u5E38");
      session.error = failure;
      session.done = true;
      this.progress(session, failure.code === "cancelled" ? "cancelled" : "failed");
      this.debug(session, "error", new Uint8Array(), failure);
      throw failure;
    } finally {
      session.done = true;
      if (session.pending)
        clearTimeout(session.pending.timer);
      session.pending = void 0;
      for (const unsubscribe of session.subscriptions)
        safeCall(unsubscribe);
      session.subscriptions = [];
      this.releaseIfIdle(session);
    }
  }
  /** 立即拒绝当前会话；不能撤回平台已提交的单次写入。 */
  cancel() {
    if (this.active && !this.active.done) {
      this.fail(this.active, new ApolloOtaError("cancelled", "Apollo \u5347\u7EA7\u5DF2\u53D6\u6D88\uFF1B\u8BBE\u5907\u6062\u590D\u9700\u6309\u771F\u673A\u7B56\u7565\u5904\u7406"));
    }
  }
  /** 等待包括取消前已提交写入在内的所有操作结束，用于安全解除设备互斥。 */
  whenIdle() {
    var _a, _b;
    return (_b = (_a = this.active) === null || _a === void 0 ? void 0 : _a.idle) !== null && _b !== void 0 ? _b : Promise.resolve();
  }
  /** 先注册确认等待，再启动写入，避免丢失同步或快速 ACK。 */
  exchange(session, command, payload, expectedOffset) {
    this.assertActive(session);
    const packet = encodeApolloOtaPacket(command, payload);
    return new Promise((resolve, reject) => {
      const pending = {
        command,
        expectedOffset,
        finalSubmitted: false,
        acknowledged: false,
        writesCompleted: false,
        timer: setTimeout(() => this.fail(session, new ApolloOtaError("timeout", `Apollo \u547D\u4EE4 ${command} \u5199\u5165\u6216\u786E\u8BA4\u8D85\u65F6`)), session.options.timeoutMs),
        resolve,
        reject
      };
      session.pending = pending;
      this.debug(session, "packet", packet);
      void this.writePacket(session, pending, packet).catch((error) => {
        this.fail(session, error instanceof ApolloOtaError ? error : new ApolloOtaError("write_failed", error instanceof Error ? error.message : "Apollo \u5206\u7247\u5199\u5165\u5931\u8D25"));
      });
    });
  }
  /** 每次只提交一片；取消/超时后旧写入回调不会继续提交后续分片。 */
  async writePacket(session, pending, packet) {
    const { payloadSize, intervalMs } = session.options;
    for (let offset = 0; offset < packet.length; offset += payloadSize) {
      this.assertActive(session);
      const fragment = packet.slice(offset, offset + payloadSize);
      pending.finalSubmitted = offset + fragment.length === packet.length;
      this.debug(session, "write", fragment);
      this.assertActive(session);
      const write = Promise.resolve().then(() => {
        this.assertActive(session);
        return this.transport.write(fragment);
      });
      session.writes.add(write);
      try {
        await write;
      } finally {
        session.writes.delete(write);
        this.releaseIfIdle(session);
      }
      this.assertActive(session);
      if (intervalMs > 0 && !pending.finalSubmitted) {
        await new Promise((resolve) => {
          pending.delay = { timer: setTimeout(resolve, intervalMs), resolve };
        });
        pending.delay = void 0;
      }
    }
    pending.writesCompleted = true;
    this.completeAck(session, pending);
  }
  /** 只处理本会话完整通知；错误命令不推进，短包明确失败。 */
  handleNotification(session, data) {
    if (session.done || session.error)
      return;
    this.debug(session, "notification", data);
    const pending = session.pending;
    if (!pending) {
      this.debug(session, "ignored", data);
      return;
    }
    try {
      const ack = decodeApolloOtaAck(data);
      if (ack.command === 0) {
        this.fail(session, new ApolloOtaError("device_rejected", "Apollo \u8BBE\u5907\u62A5\u544A\u672A\u77E5\u547D\u4EE4", ack.status));
        return;
      }
      if (ack.command !== pending.command || !pending.finalSubmitted || pending.acknowledged) {
        this.debug(session, "ignored", data);
        return;
      }
      if (ack.status !== 0) {
        this.fail(session, new ApolloOtaError("device_rejected", `Apollo \u8BBE\u5907\u62D2\u7EDD\u547D\u4EE4 ${ack.command}\uFF0C\u72B6\u6001 ${ack.status}`, ack.status));
      } else if (ack.offset !== void 0 && ack.offset !== pending.expectedOffset) {
        this.fail(session, new ApolloOtaError("offset_mismatch", `Apollo \u786E\u8BA4\u504F\u79FB ${ack.offset} \u4E0E\u9884\u671F ${pending.expectedOffset} \u4E0D\u4E00\u81F4`));
      } else {
        pending.acknowledged = true;
        this.completeAck(session, pending);
      }
    } catch (error) {
      this.fail(session, new ApolloOtaError("invalid_ack", error instanceof Error ? error.message : "Apollo \u786E\u8BA4\u683C\u5F0F\u65E0\u6548"));
    }
  }
  /** ACK 不能替代平台写入成功；两者都完成才放行下一逻辑包。 */
  completeAck(session, pending) {
    if (!session.error && session.pending === pending && pending.acknowledged && pending.writesCompleted) {
      clearTimeout(pending.timer);
      session.pending = void 0;
      pending.resolve();
    }
  }
  /** 失败信号幂等，保留首个错误并立即唤醒等待。 */
  fail(session, error) {
    if (session.done || session.error)
      return;
    session.error = error;
    if (session.pending) {
      clearTimeout(session.pending.timer);
      if (session.pending.delay) {
        clearTimeout(session.pending.delay.timer);
        session.pending.delay.resolve();
      }
      session.pending.reject(error);
      session.pending = void 0;
    }
  }
  /** 防止回调重入取消后仍发包。 */
  assertActive(session) {
    if (session.error)
      throw session.error;
    if (session.done)
      throw new ApolloOtaError("cancelled", "Apollo \u4F1A\u8BDD\u5DF2\u7ECF\u7ED3\u675F");
  }
  /** 只有会话结束且底层写入排空才解除共享通道占用。 */
  releaseIfIdle(session) {
    if (!session.done || session.writes.size > 0 || this.active !== session)
      return;
    occupiedTransports.delete(this.transport);
    this.active = void 0;
    session.release();
  }
  /** 进度只统计设备已确认的正文，所有阶段都提供快照。 */
  progress(session, state) {
    if (state !== "completed" && state !== "failed" && state !== "cancelled")
      this.assertActive(session);
    session.state = state;
    safeCall(() => {
      var _a, _b;
      return (_b = (_a = session.options).onProgress) === null || _b === void 0 ? void 0 : _b.call(_a, {
        state,
        totalBytes: session.totalBytes,
        acknowledgedBytes: session.offset,
        percent: session.offset / session.totalBytes * 100
      });
    });
  }
  /** 日志异常不破坏 OTA 生命周期，完整包与分片分别记录。 */
  debug(session, type, data, error) {
    safeCall(() => {
      var _a, _b, _c;
      return (_b = (_a = session.options).debug) === null || _b === void 0 ? void 0 : _b.call(_a, {
        type,
        state: session.state,
        command: (_c = session.pending) === null || _c === void 0 ? void 0 : _c.command,
        offset: session.offset,
        hex: bytesToHex(data),
        ...error ? { error: { code: error.code, message: error.message, status: error.status } } : {}
      });
    });
  }
};
function safeCall(callback) {
  try {
    callback();
  } catch (_a) {
  }
}

// packages/sdk-core/dist/command-executor.js
var CommandExecutor = class {
  constructor(transport, options = {}) {
    var _a, _b;
    this.transport = transport;
    this.exclusive = false;
    this.closed = false;
    this.activeWrites = 0;
    this.nextFrameId = 1;
    this.pending = /* @__PURE__ */ new Map();
    this.timeoutMs = (_a = options.timeoutMs) !== null && _a !== void 0 ? _a : 5e3;
    this.maxFrameId = (_b = options.maxFrameId) !== null && _b !== void 0 ? _b : 127;
    this.debug = options.debug;
    this.onUnhandledNotification = options.onUnhandledNotification;
    this.unsubscribe = transport.onNotification((data) => this.handleNotification(data));
  }
  /** 发送有响应的命令，并用 codec 解析返回值。 */
  execute(codec, request) {
    return this.enqueue(codec, request, {});
  }
  /** 发送持续性命令，中间态回调 progress，终态才结束请求。 */
  executeContinuous(codec, request, options) {
    return this.enqueue(codec, request, {
      onProgress: options.onProgress,
      isTerminal: options.isTerminal,
      isFailure: options.isFailure,
      toError: options.toError,
      acceptsPacket: options.acceptsPacket,
      onDecodeError: options.onDecodeError
    });
  }
  enqueue(codec, request, options) {
    var _a;
    if (this.exclusive || this.closed) {
      return Promise.reject(new ProtocolError(this.closed ? "Command executor closed." : "\u8BBE\u5907\u6B63\u5728\u8FDB\u884C OTA \u5347\u7EA7"));
    }
    const frameId = this.allocateFrameId(codec.cmd, codec.subcmd);
    const packet = codec.encode(request, frameId);
    const encodedPacket = encodePacket(packet);
    const key = pendingKey(packet);
    (_a = this.debug) === null || _a === void 0 ? void 0 : _a.call(this, {
      type: "write",
      cmd: codec.cmd,
      subcmd: codec.subcmd,
      frameId,
      request,
      hex: bytesToHex(encodedPacket)
    });
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(key);
        reject(new ProtocolError(`Command timeout: cmd=0x${codec.cmd.toString(16)}, subcmd=0x${codec.subcmd.toString(16)}.`));
      }, this.timeoutMs);
      this.pending.set(key, {
        codec,
        key,
        frameId,
        timer,
        resolve,
        reject,
        onProgress: options.onProgress,
        isTerminal: options.isTerminal,
        isFailure: options.isFailure,
        toError: options.toError,
        acceptsPacket: options.acceptsPacket,
        onDecodeError: options.onDecodeError
      });
      this.write(encodedPacket).catch((error) => {
        clearTimeout(timer);
        this.pending.delete(key);
        reject(error instanceof Error ? error : new ProtocolError("Command write failed."));
      });
    });
  }
  /** 发送无响应命令，只负责完成写入。 */
  async send(codec, request) {
    var _a;
    if (this.exclusive || this.closed) {
      throw new ProtocolError(this.closed ? "Command executor closed." : "\u8BBE\u5907\u6B63\u5728\u8FDB\u884C OTA \u5347\u7EA7");
    }
    const frameId = this.allocateFrameId(codec.cmd, codec.subcmd);
    const packet = codec.encode(request, frameId);
    const encodedPacket = encodePacket(packet);
    (_a = this.debug) === null || _a === void 0 ? void 0 : _a.call(this, {
      type: "write",
      cmd: codec.cmd,
      subcmd: codec.subcmd,
      frameId,
      request,
      hex: bytesToHex(encodedPacket)
    });
    await this.write(encodedPacket);
  }
  /** 仅在普通请求和平台写入都空闲时获取独占权，返回幂等释放函数。 */
  acquireExclusive() {
    if (this.closed || this.exclusive || this.pending.size > 0 || this.activeWrites > 0) {
      throw new ProtocolError("\u8BBE\u5907\u5B58\u5728\u672A\u5B8C\u6210\u6307\u4EE4\u3001\u5199\u5165\u6216\u72EC\u5360\u64CD\u4F5C\uFF0C\u65E0\u6CD5\u5F00\u59CB OTA");
    }
    this.exclusive = true;
    let released = false;
    return () => {
      if (!released) {
        released = true;
        this.exclusive = false;
      }
    };
  }
  /** 跟踪真实平台写入，避免快速响应造成设备空闲的误判。 */
  async write(data) {
    if (this.exclusive || this.closed) {
      throw new ProtocolError(this.closed ? "Command executor closed." : "\u8BBE\u5907\u6B63\u5728\u8FDB\u884C OTA \u5347\u7EA7");
    }
    this.activeWrites += 1;
    try {
      await this.transport.write(data);
    } finally {
      this.activeWrites -= 1;
    }
  }
  /** 按命令字取消仍在等待的请求，用于主动停止持续测量。 */
  cancelPending(cmd, subcmd, error) {
    for (const [key, pending] of this.pending) {
      if (pending.codec.cmd === cmd && pending.codec.subcmd === subcmd) {
        clearTimeout(pending.timer);
        this.pending.delete(key);
        pending.reject(error);
      }
    }
  }
  /** 关闭执行器并拒绝所有未完成请求。 */
  close() {
    this.closed = true;
    this.unsubscribe();
    for (const [key, pending] of this.pending) {
      clearTimeout(pending.timer);
      pending.reject(new ProtocolError("Command executor closed."));
      this.pending.delete(key);
    }
  }
  handleNotification(data) {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    const hex = bytesToHex(data);
    (_a = this.debug) === null || _a === void 0 ? void 0 : _a.call(this, {
      type: "notification",
      hex
    });
    const packet = decodePacket(data);
    const key = pendingKey(packet);
    const pending = (_b = this.pending.get(key)) !== null && _b !== void 0 ? _b : this.findRelatedPending(packet);
    if (!pending) {
      (_c = this.onUnhandledNotification) === null || _c === void 0 ? void 0 : _c.call(this, packet, data, hex);
      return;
    }
    try {
      const response = pending.codec.decode(packet);
      if (pending.isTerminal && !pending.isTerminal(response)) {
        clearTimeout(pending.timer);
        pending.timer = this.createTimeout(pending.key, pending.codec, pending.reject);
        (_d = pending.onProgress) === null || _d === void 0 ? void 0 : _d.call(pending, response);
        return;
      }
      clearTimeout(pending.timer);
      this.pending.delete(pending.key);
      if ((_e = pending.isFailure) === null || _e === void 0 ? void 0 : _e.call(pending, response)) {
        pending.reject((_g = (_f = pending.toError) === null || _f === void 0 ? void 0 : _f.call(pending, response)) !== null && _g !== void 0 ? _g : new ProtocolError("Command completed with failure state."));
        return;
      }
      pending.resolve(response);
    } catch (error) {
      const normalizedError = error instanceof Error ? error : new ProtocolError("Command decode failed.");
      if (((_h = pending.onDecodeError) === null || _h === void 0 ? void 0 : _h.call(pending, normalizedError, packet, hex)) === "continue") {
        clearTimeout(pending.timer);
        pending.timer = this.createTimeout(pending.key, pending.codec, pending.reject);
        return;
      }
      clearTimeout(pending.timer);
      this.pending.delete(pending.key);
      pending.reject(normalizedError);
    }
  }
  createTimeout(key, codec, reject) {
    return setTimeout(() => {
      this.pending.delete(key);
      reject(new ProtocolError(`Command timeout: cmd=0x${codec.cmd.toString(16)}, subcmd=0x${codec.subcmd.toString(16)}.`));
    }, this.timeoutMs);
  }
  allocateFrameId(cmd, subcmd) {
    for (let i = 0; i < this.maxFrameId; i += 1) {
      const frameId = this.nextFrameId;
      this.nextFrameId = this.nextFrameId >= this.maxFrameId ? 1 : this.nextFrameId + 1;
      if (!this.pending.has(`${frameId}:${cmd}:${subcmd}`)) {
        return frameId;
      }
    }
    throw new ProtocolError("No available frameId for command.");
  }
  findRelatedPending(packet) {
    var _a;
    for (const pending of this.pending.values()) {
      if (pending.frameId === packet.frameId && ((_a = pending.acceptsPacket) === null || _a === void 0 ? void 0 : _a.call(pending, packet))) {
        return pending;
      }
    }
    return void 0;
  }
};
function pendingKey(packet) {
  return `${packet.frameId}:${packet.cmd}:${packet.subcmd}`;
}

// packages/sdk-core/dist/queued-command-transport.js
var QueuedCommandTransport = class {
  constructor(inner, options = {}) {
    var _a, _b, _c;
    this.inner = inner;
    this.queue = [];
    this.isProcessing = false;
    this.payloadSize = (_a = options.payloadSize) !== null && _a !== void 0 ? _a : 20;
    this.intervalMs = (_b = options.intervalMs) !== null && _b !== void 0 ? _b : 0;
    this.maxRetries = (_c = options.maxRetries) !== null && _c !== void 0 ? _c : 0;
  }
  /** 将完整协议数据加入队列，实际写入由 processQueue 串行处理。 */
  write(data) {
    if (this.payloadSize <= 0) {
      return Promise.reject(new ProtocolError("payloadSize must be greater than 0."));
    }
    return new Promise((resolve, reject) => {
      this.queue.push({ data, resolve, reject });
      void this.processQueue();
    });
  }
  /** 通知监听直接透传给内部 transport。 */
  onNotification(callback) {
    return this.inner.onNotification(callback);
  }
  async processQueue() {
    if (this.isProcessing) {
      return;
    }
    this.isProcessing = true;
    try {
      while (this.queue.length > 0) {
        const write = this.queue.shift();
        if (!write) {
          continue;
        }
        try {
          await this.writeChunks(write.data);
          write.resolve();
        } catch (error) {
          write.reject(error instanceof Error ? error : new ProtocolError("Queued write failed."));
        }
      }
    } finally {
      this.isProcessing = false;
    }
  }
  async writeChunks(data) {
    const chunks = splitIntoChunks(data, this.payloadSize);
    for (let i = 0; i < chunks.length; i += 1) {
      await this.writeWithRetry(chunks[i]);
      if (this.intervalMs > 0 && i < chunks.length - 1) {
        await delay(this.intervalMs);
      }
    }
  }
  async writeWithRetry(data) {
    let lastError;
    for (let attempt = 0; attempt <= this.maxRetries; attempt += 1) {
      try {
        await this.inner.write(data);
        return;
      } catch (error) {
        lastError = error instanceof Error ? error : new ProtocolError("Write failed.");
      }
    }
    throw lastError !== null && lastError !== void 0 ? lastError : new ProtocolError("Write failed.");
  }
};
function splitIntoChunks(data, payloadSize) {
  if (payloadSize <= 0) {
    throw new ProtocolError("payloadSize must be greater than 0.");
  }
  const chunks = [];
  for (let offset = 0; offset < data.byteLength; offset += payloadSize) {
    chunks.push(data.slice(offset, offset + payloadSize));
  }
  return chunks;
}
function delay(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

// packages/sdk-core/dist/ota/phy-ota.js
var PhyOtaError = class extends Error {
  constructor(code, message, status) {
    super(message);
    this.code = code;
    this.status = status;
    this.name = "PhyOtaError";
  }
};
var occupied = /* @__PURE__ */ new WeakSet();
var PhyOtaUpdater = class {
  constructor(transport) {
    this.transport = transport;
  }
  /** 输入 HEX 字节或文本，先复制解析全部固件再进行任何写入。 */
  async start(input, options) {
    var _a, _b, _c, _d, _e, _f, _g;
    if (this.active || occupied.has(this.transport))
      throw new PhyOtaError("busy", "PHY \u901A\u9053\u4ECD\u88AB\u5347\u7EA7\u6216\u672A\u5B8C\u6210\u5199\u5165\u5360\u7528");
    if (!Number.isInteger(options.payloadSize) || options.payloadSize < PHY_PACKET_SIZE || !Number.isFinite((_a = options.timeoutMs) !== null && _a !== void 0 ? _a : 1e4) || ((_b = options.timeoutMs) !== null && _b !== void 0 ? _b : 1e4) <= 0 || ((_c = options.timeoutMs) !== null && _c !== void 0 ? _c : 1e4) > 2147483647 || !Number.isFinite((_d = options.intervalMs) !== null && _d !== void 0 ? _d : 0) || ((_e = options.intervalMs) !== null && _e !== void 0 ? _e : 0) < 0 || ((_f = options.intervalMs) !== null && _f !== void 0 ? _f : 0) > 2147483647)
      throw new PhyOtaError("invalid_options", "PHY \u9700\u8981\u5DF2\u786E\u8BA4\u7684\u81F3\u5C11 237 \u5B57\u8282\u8D1F\u8F7D\u53CA\u5408\u6CD5\u8D85\u65F6/\u95F4\u9694");
    let image;
    try {
      image = parsePhyFirmware(input);
    } catch (e) {
      throw new PhyOtaError("invalid_firmware", String(e));
    }
    let release;
    const idle = new Promise((resolve) => {
      release = resolve;
    });
    const s = {
      progress: { state: "preparing", section: 0, acknowledgedBytes: 0, totalBytes: image.totalBytes, percent: 0 },
      options: { ...options },
      done: false,
      writes: /* @__PURE__ */ new Set(),
      idle,
      release
    };
    this.active = s;
    occupied.add(this.transport);
    const off = [];
    try {
      off.push(this.transport.onNotification((data) => this.notify(s, data)));
      off.push(this.transport.onDisconnect(() => this.fail(s, new PhyOtaError("disconnected", "PHY Boot \u8FDE\u63A5\u65AD\u5F00\uFF0C\u8BF7\u91CD\u65B0\u641C\u7D22\u6062\u590D"))));
      this.progress(s, "preparing");
      this.check(s);
      this.progress(s, "partitions");
      await this.exchange(s, [new Uint8Array([1, image.sections.length, 0])], false, 129);
      for (const section of image.sections) {
        s.progress.section = section.index;
        this.progress(s, "section");
        await this.exchange(s, [encodePhySection(section)], false, 132);
        for (let offset = 0; offset < section.data.length; ) {
          this.progress(s, "data");
          const end = Math.min(offset + PHY_PACKET_SIZE * PHY_WINDOW_SIZE, section.data.length);
          const packets = [];
          for (let n = offset; n < end; n += PHY_PACKET_SIZE)
            packets.push(section.data.slice(n, Math.min(n + PHY_PACKET_SIZE, end)));
          const expected = end < section.data.length ? 135 : section.index === image.sections.length - 1 ? 131 : 133;
          await this.exchange(s, packets, true, expected);
          this.check(s);
          s.progress.acknowledgedBytes += end - offset;
          offset = end;
          this.progress(s, "data");
        }
      }
      this.check(s);
      s.done = true;
      this.progress(s, "completed");
      return { protocolCompleted: true, rebootRequested: false, versionVerified: false, acknowledgedBytes: s.progress.acknowledgedBytes };
    } catch (e) {
      const failure = (_g = s.error) !== null && _g !== void 0 ? _g : e instanceof PhyOtaError ? e : new PhyOtaError("write_failed", String(e));
      s.error = failure;
      s.done = true;
      this.progress(s, failure.code === "cancelled" ? "cancelled" : "failed");
      this.trace(s, "error", new Uint8Array(), failure.message);
      throw failure;
    } finally {
      s.done = true;
      if (s.pending)
        clearTimeout(s.pending.timer);
      s.pending = void 0;
      for (const fn of off)
        safe(fn);
      this.release(s);
    }
  }
  /** 立即拒绝等待，已提交的单次平台写入仍需排空。 */
  cancel() {
    if (this.active)
      this.fail(this.active, new PhyOtaError("cancelled", "PHY \u5DF2\u505C\u6B62\uFF1B\u8BF7\u91CD\u65B0\u641C\u7D22\u786E\u8BA4\u8BBE\u5907\u6A21\u5F0F"));
  }
  /** 调用方必须在此完成后解除设备互斥或交接连接。 */
  whenIdle() {
    var _a, _b;
    return (_b = (_a = this.active) === null || _a === void 0 ? void 0 : _a.idle) !== null && _b !== void 0 ? _b : Promise.resolve();
  }
  /** 段末 ACK 仅在最后报已提交且全部平台写入成功后生效。 */
  exchange(s, packets, data, expected) {
    this.check(s);
    return new Promise((resolve, reject) => {
      var _a;
      const p = {
        expected,
        submitted: false,
        ack: false,
        written: false,
        resolve,
        reject,
        timer: setTimeout(() => this.fail(s, new PhyOtaError("timeout", `PHY \u9636\u6BB5 ${s.progress.state} \u5199\u5165\u6216\u786E\u8BA4\u8D85\u65F6`)), (_a = s.options.timeoutMs) !== null && _a !== void 0 ? _a : 1e4)
      };
      s.pending = p;
      void this.send(s, p, packets, data).catch((e) => this.fail(s, e instanceof PhyOtaError ? e : new PhyOtaError("write_failed", String(e))));
    });
  }
  /** 串行发送，停止/超时后任何迟到回调都不会继续发下一报。 */
  async send(s, p, packets, data) {
    for (const [index, packet] of packets.entries()) {
      this.check(s);
      this.trace(s, data ? "data" : "command", packet);
      this.check(s);
      const write = Promise.resolve().then(() => {
        this.check(s);
        p.submitted = index === packets.length - 1;
        return data ? this.transport.writeData(packet) : this.transport.writeCommand(packet);
      });
      s.writes.add(write);
      try {
        await write;
      } finally {
        s.writes.delete(write);
        this.release(s);
      }
      this.check(s);
      if (data && s.options.intervalMs && index < packets.length - 1)
        await new Promise((resolve) => {
          const timer = setTimeout(() => {
            s.stopDelay = void 0;
            resolve();
          }, s.options.intervalMs);
          s.stopDelay = () => {
            clearTimeout(timer);
            s.stopDelay = void 0;
            resolve();
          };
        });
    }
    this.check(s);
    p.written = true;
    this.complete(s, p);
  }
  /** 先校验短包与状态，再限定预期 opcode；无法消歧的同类重复 ACK 不自动重试。 */
  notify(s, data) {
    if (s.done || s.error)
      return;
    this.trace(s, "notification", data);
    try {
      const ack = decodePhyAck(data);
      const p = s.pending;
      if (ack.status) {
        this.fail(s, new PhyOtaError("device_rejected", `PHY \u8BBE\u5907\u62D2\u7EDD\uFF0C\u72B6\u6001 ${ack.status}`, ack.status));
        return;
      }
      if (!p || !p.submitted || p.ack) {
        this.trace(s, "ignored", data);
        return;
      }
      if (ack.opcode !== p.expected) {
        this.fail(s, new PhyOtaError("unexpected_ack", `PHY \u5E94\u7B54 ${ack.opcode.toString(16)} \u4E0E\u9636\u6BB5\u9884\u671F ${p.expected.toString(16)} \u4E0D\u4E00\u81F4`));
        return;
      }
      p.ack = true;
      this.complete(s, p);
    } catch (e) {
      this.fail(s, new PhyOtaError("invalid_ack", String(e)));
    }
  }
  /** 写入和设备确认缺一不可。 */
  complete(s, p) {
    if (!s.error && s.pending === p && p.ack && p.written) {
      clearTimeout(p.timer);
      s.pending = void 0;
      p.resolve();
    }
  }
  /** 首个错误胜出并唤醒定时等待。 */
  fail(s, error) {
    var _a;
    if (s.done || s.error)
      return;
    s.error = error;
    (_a = s.stopDelay) === null || _a === void 0 ? void 0 : _a.call(s);
    if (s.pending) {
      clearTimeout(s.pending.timer);
      const p = s.pending;
      s.pending = void 0;
      p.reject(error);
    }
  }
  /** 任何业务回调重入后均再次检查会话状态。 */
  check(s) {
    if (s.error)
      throw s.error;
    if (s.done)
      throw new PhyOtaError("cancelled", "PHY \u4F1A\u8BDD\u5DF2\u7ED3\u675F");
  }
  /** 挂起写入未回调前仍保持通道占用，宁可保持忙碌也不交叉发送。 */
  release(s) {
    if (s.done && !s.writes.size && this.active === s) {
      this.active = void 0;
      occupied.delete(this.transport);
      s.release();
    }
  }
  /** 回调异常仅影响展示，不影响协议。 */
  progress(s, state) {
    s.progress.state = state;
    s.progress.percent = s.progress.acknowledgedBytes / s.progress.totalBytes * 100;
    safe(() => {
      var _a, _b;
      return (_b = (_a = s.options).onProgress) === null || _b === void 0 ? void 0 : _b.call(_a, { ...s.progress });
    });
  }
  /** 完整保留实际写入和通知 Hex。 */
  trace(s, type, bytes, message) {
    safe(() => {
      var _a, _b;
      return (_b = (_a = s.options).debug) === null || _b === void 0 ? void 0 : _b.call(_a, { type, hex: bytesToHex(bytes), progress: { ...s.progress }, message });
    });
  }
};
function safe(fn) {
  try {
    fn();
  } catch (_a) {
  }
}

// packages/sdk-core/dist/ota/nordic-ota.js
var NordicOtaError = class extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
    this.name = "NordicOtaError";
  }
};
var occupied2 = /* @__PURE__ */ new WeakSet();
var NordicOtaUpdater = class {
  constructor(transport) {
    this.transport = transport;
  }
  /** 执行单 application 升级；匹配 CRC 的已传输数据可恢复，不自动重发损坏对象。 */
  async start(input, options = {}) {
    var _a, _b, _c, _d, _e;
    if (this.active || occupied2.has(this.transport))
      throw new NordicOtaError("busy", "Nordic \u901A\u9053\u4ECD\u88AB\u5360\u7528");
    const settings = {
      ...options,
      payloadSize: (_a = options.payloadSize) !== null && _a !== void 0 ? _a : 20,
      timeoutMs: (_b = options.timeoutMs) !== null && _b !== void 0 ? _b : 1e4,
      intervalMs: (_c = options.intervalMs) !== null && _c !== void 0 ? _c : 0,
      preparationDelayMs: (_d = options.preparationDelayMs) !== null && _d !== void 0 ? _d : 400
    };
    if (!Number.isInteger(settings.payloadSize) || settings.payloadSize < 1 || settings.payloadSize > 244 || [settings.timeoutMs, settings.intervalMs, settings.preparationDelayMs].some((n) => !Number.isFinite(n) || n < 0 || n > 2147483647) || settings.timeoutMs === 0)
      throw new NordicOtaError("invalid_options", "Nordic \u5206\u7247\u3001\u8D85\u65F6\u6216\u7B49\u5F85\u53C2\u6570\u65E0\u6548");
    let firmware;
    try {
      firmware = parseNordicFirmware(input);
    } catch (e) {
      throw new NordicOtaError("invalid_firmware", String(e));
    }
    let stop;
    const stopped = new Promise((_, reject) => {
      stop = reject;
    });
    void stopped.catch(() => {
    });
    let release;
    const idle = new Promise((resolve) => {
      release = resolve;
    });
    const s = {
      done: false,
      state: "preparing",
      offset: 0,
      total: firmware.image.length,
      options: settings,
      writes: /* @__PURE__ */ new Set(),
      unsubscribe: [],
      stopped,
      stop,
      idle,
      release
    };
    this.active = s;
    occupied2.add(this.transport);
    try {
      s.unsubscribe.push(this.transport.onNotification((data) => {
        if (s.done || s.error)
          return;
        this.debug(s, "notification", data);
        const p = s.pending;
        if (!p)
          return;
        if (data.length >= 2 && data[0] === 96 && data[1] !== p.opcode)
          return;
        try {
          const body = decodeNordicResponse(data, p.opcode);
          s.pending = void 0;
          p.resolve(body);
        } catch (e) {
          this.fail(s, new NordicOtaError("protocol_error", String(e)));
        }
      }));
      s.unsubscribe.push(this.transport.onDisconnect(() => this.fail(s, new NordicOtaError("disconnected", "Nordic Bootloader \u5DF2\u65AD\u8FDE\uFF1B\u4E0D\u80FD\u4EC5\u51ED\u65AD\u8FDE\u5224\u5B9A\u6210\u529F"))));
      this.progress(s, "preparing");
      await this.command(s, new Uint8Array([2, 0, 0]));
      this.progress(s, "sendingInit");
      await this.sendObjectType(s, 1, firmware.initPacket);
      this.progress(s, "sendingData");
      await this.sendObjectType(s, 2, firmware.image);
      this.assert(s);
      s.done = true;
      this.progress(s, "completed");
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: s.offset };
    } catch (e) {
      const error = (_e = s.error) !== null && _e !== void 0 ? _e : e instanceof NordicOtaError ? e : new NordicOtaError("protocol_error", String(e));
      s.done = true;
      this.progress(s, error.code === "cancelled" ? "cancelled" : "failed");
      this.debug(s, "error", new Uint8Array(), error.message);
      throw error;
    } finally {
      s.done = true;
      s.pending = void 0;
      for (const off of s.unsubscribe)
        safe2(off);
      this.release(s);
    }
  }
  /** 停止后续发送，无法撤回平台已提交写入，也不向设备发送回滚命令。 */
  cancel() {
    if (this.active)
      this.fail(this.active, new NordicOtaError("cancelled", "Nordic \u5347\u7EA7\u5DF2\u53D6\u6D88"));
  }
  /** 设备锁必须等待所有已提交写入结束后再释放。 */
  whenIdle() {
    var _a, _b;
    return (_b = (_a = this.active) === null || _a === void 0 ? void 0 : _a.idle) !== null && _b !== void 0 ? _b : Promise.resolve();
  }
  /** Select → Create/恢复 → Packet → CRC → Execute，数据 CRC 是整个 BIN 的累计值。 */
  async sendObjectType(s, type, bytes) {
    const selected = await this.command(s, new Uint8Array([6, type]));
    const view = new DataView(selected.buffer, selected.byteOffset, selected.byteLength);
    const max = view.getUint32(0, true);
    let offset = view.getUint32(4, true);
    const crc = view.getUint32(8, true);
    if (!max || type === 1 && bytes.length > max)
      throw new NordicOtaError("invalid_firmware", "Nordic \u5BF9\u8C61\u5927\u5C0F\u4E0E Bootloader \u4E0D\u517C\u5BB9");
    let expectedCrc = nordicCrc32(bytes.subarray(0, offset));
    const matches2 = offset <= bytes.length && expectedCrc === crc;
    if (type === 2 && !matches2)
      throw new NordicOtaError("resume_mismatch", "Bootloader \u5DF2\u6709\u6570\u636E\u4E0E\u6240\u9009\u56FA\u4EF6 CRC/\u504F\u79FB\u4E0D\u5339\u914D\uFF0C\u8BF7\u5148\u6309\u8BBE\u5907\u6D41\u7A0B\u6062\u590D");
    if (type === 1 && !matches2) {
      offset = 0;
      expectedCrc = 0;
    }
    let recovering = offset > 0;
    while (offset < bytes.length || recovering) {
      this.assert(s);
      const start = offset;
      const end = recovering ? Math.min(bytes.length, type === 1 ? bytes.length : Math.ceil(offset / max) * max) : Math.min(bytes.length, offset + (type === 1 ? bytes.length : max));
      if (!recovering) {
        await this.command(s, encodeNordicCreate(type, end - start));
        if (type === 2)
          await this.delay(s, s.options.preparationDelayMs);
      }
      for (; offset < end; ) {
        const fragment = bytes.slice(offset, Math.min(end, offset + s.options.payloadSize));
        this.debug(s, "packet", fragment);
        await this.write(s, () => this.transport.writePacket(fragment));
        expectedCrc = nordicCrc32(fragment, expectedCrc);
        offset += fragment.length;
        await this.delay(s, s.options.intervalMs);
      }
      const sum = await this.command(s, new Uint8Array([3]));
      const checksum = new DataView(sum.buffer, sum.byteOffset, sum.byteLength);
      if (checksum.getUint32(0, true) !== offset || checksum.getUint32(4, true) !== expectedCrc) {
        throw new NordicOtaError("checksum_mismatch", "Nordic \u5BF9\u8C61\u7D2F\u8BA1\u504F\u79FB\u6216 CRC32 \u4E0D\u5339\u914D");
      }
      await this.command(s, new Uint8Array([4]));
      if (type === 2) {
        s.offset = offset;
        this.progress(s, "sendingData");
      }
      recovering = false;
    }
  }
  /** 等待通知先注册，快速 ACK 与写入完成均满足后才进入下一条命令。 */
  async command(s, data) {
    this.assert(s);
    const response = new Promise((resolve, reject) => {
      s.pending = { opcode: data[0], resolve, reject };
    });
    this.debug(s, "control", data);
    const result = await this.bounded(s, Promise.all([response, this.write(s, () => this.transport.writeControl(data))]));
    return result[0];
  }
  /** 跟踪真实写入；超时拒绝上层后仍保持通道互斥，直到平台回调结束。 */
  async write(s, callback) {
    this.assert(s);
    const write = Promise.resolve().then(() => {
      this.assert(s);
      return callback();
    });
    s.writes.add(write);
    void write.then(() => {
      s.writes.delete(write);
      this.release(s);
    }, () => {
      s.writes.delete(write);
      this.release(s);
    });
    try {
      await this.bounded(s, write);
    } catch (e) {
      if (e instanceof NordicOtaError)
        throw e;
      throw new NordicOtaError("write_failed", String(e));
    }
    this.assert(s);
  }
  /** 所有等待可被取消或断连立即唤醒，不把最终重启断连当作 ACK。 */
  async bounded(s, task) {
    let timer;
    const timeout = new Promise((_, reject) => {
      timer = setTimeout(() => {
        const error = new NordicOtaError("timeout", "Nordic \u5199\u5165\u6216\u54CD\u5E94\u8D85\u65F6");
        this.fail(s, error);
        reject(error);
      }, s.options.timeoutMs);
    });
    try {
      return await Promise.race([task, s.stopped, timeout]);
    } finally {
      clearTimeout(timer);
    }
  }
  /** 节流等待在取消时清理计时器，避免旧循环继续提交分片。 */
  async delay(s, ms) {
    this.assert(s);
    if (!ms)
      return;
    let timer;
    try {
      await Promise.race([new Promise((resolve) => {
        timer = setTimeout(resolve, ms);
      }), s.stopped]);
    } finally {
      clearTimeout(timer);
    }
    this.assert(s);
  }
  /** 首个错误保留，迟到的通知不能覆盖取消原因。 */
  fail(s, error) {
    var _a;
    if (s.done || s.error)
      return;
    s.error = error;
    s.stop(error);
    (_a = s.pending) === null || _a === void 0 ? void 0 : _a.reject(error);
    s.pending = void 0;
  }
  /** 回调重入取消后也必须停止写入。 */
  assert(s) {
    if (s.error)
      throw s.error;
    if (s.done)
      throw new NordicOtaError("cancelled", "\u4F1A\u8BDD\u5DF2\u7ED3\u675F");
  }
  /** 日志与展示异常均不能破坏设备锁清理。 */
  progress(s, state) {
    s.state = state;
    safe2(() => {
      var _a, _b;
      return (_b = (_a = s.options).onProgress) === null || _b === void 0 ? void 0 : _b.call(_a, { state, totalBytes: s.total, acknowledgedBytes: s.offset, percent: s.offset / s.total * 100 });
    });
  }
  /** 保留原始协议 Hex，供真机与官方日志对照。 */
  debug(s, type, data, message) {
    safe2(() => {
      var _a, _b;
      return (_b = (_a = s.options).debug) === null || _b === void 0 ? void 0 : _b.call(_a, { type, hex: bytesToHex(data), message });
    });
  }
  /** 直到已提交写入排空才释放当前会话。 */
  release(s) {
    if (!s.done || s.writes.size || this.active !== s)
      return;
    occupied2.delete(this.transport);
    this.active = void 0;
    s.release();
  }
};
function safe2(callback) {
  try {
    callback();
  } catch (_a) {
  }
}

// packages/sdk-core/dist/ring-sdk.js
var TemperatureMeasurementError = class extends Error {
  constructor(status, message = temperatureFailureMessage(status)) {
    super(message);
    this.status = status;
    this.name = "TemperatureMeasurementError";
  }
};
var HeartRateMeasurementError = class extends Error {
  constructor(status, message = heartRateFailureMessage(status)) {
    super(message);
    this.status = status;
    this.name = "HeartRateMeasurementError";
  }
};
var BloodOxygenMeasurementError = class extends Error {
  constructor(status, message = bloodOxygenFailureMessage(status)) {
    super(message);
    this.status = status;
    this.name = "BloodOxygenMeasurementError";
  }
};
var HistoryDataSyncError = class extends Error {
  constructor(status, message = `\u5386\u53F2\u6570\u636E\u540C\u6B65\u5931\u8D25\uFF1A${status}`) {
    super(message);
    this.status = status;
    this.name = "HistoryDataSyncError";
  }
};
var AppCompositeError = class extends Error {
  constructor(kind, status, message = `App \u590D\u5408\u6307\u4EE4\u5931\u8D25\uFF1A${kind}`) {
    super(message);
    this.kind = kind;
    this.status = status;
    this.name = "AppCompositeError";
  }
};
var GoMoreSleepDataError = class extends Error {
  constructor(message = "GoMore \u7761\u7720\u6570\u636E\u8BFB\u53D6\u5931\u8D25") {
    super(message);
    this.name = "GoMoreSleepDataError";
  }
};
var RingSDK = class {
  constructor(transport, options = {}) {
    this.batteryListeners = /* @__PURE__ */ new Set();
    this.chargingStateListeners = /* @__PURE__ */ new Set();
    this.bloodOxygenActive = false;
    this.heartRateActive = false;
    this.historySyncActive = false;
    this.appCompositeActive = false;
    this.executor = new CommandExecutor(transport, {
      ...options,
      onUnhandledNotification: (packet, data, hex) => {
        var _a;
        (_a = options.onUnhandledNotification) === null || _a === void 0 ? void 0 : _a.call(options, packet, data, hex);
        this.handleUnhandledNotification(packet, hex);
      }
    });
  }
  /** 使用已准备好的独立 OTA 通道升级；完成仅表示 reset ACK，仍需重连验证版本。 */
  async startApolloUpgrade(transport, firmware, options = {}) {
    if (this.apolloUpdater || this.nordicUpdater || this.phyUpdater || this.bloodOxygenActive || this.heartRateActive || this.historySyncActive || this.appCompositeActive) {
      throw new ApolloOtaError("busy", "\u8BBE\u5907\u5B58\u5728\u5347\u7EA7\u3001\u6D4B\u91CF\u6216\u540C\u6B65\u4EFB\u52A1");
    }
    let release;
    try {
      release = this.executor.acquireExclusive();
    } catch (error) {
      throw new ApolloOtaError("busy", error instanceof Error ? error.message : "\u8BBE\u5907\u5FD9\u788C");
    }
    const updater = new ApolloOtaUpdater(transport);
    this.apolloUpdater = updater;
    try {
      return await updater.start(firmware, options);
    } finally {
      void updater.whenIdle().then(() => {
        if (this.apolloUpdater === updater)
          this.apolloUpdater = void 0;
        release();
      });
    }
  }
  /** 停止 Apollo 后续发包；设备侧恢复方式取决于固件，不能视为安全回滚。 */
  stopApolloUpgrade() {
    var _a;
    (_a = this.apolloUpdater) === null || _a === void 0 ? void 0 : _a.cancel();
  }
  /** 使用已准备的 Bootloader 通道升级；不负责应用态切换或扫描身份推断。 */
  async startNordicUpgrade(transport, firmware, options = {}) {
    if (this.apolloUpdater || this.nordicUpdater || this.phyUpdater || this.bloodOxygenActive || this.heartRateActive || this.historySyncActive || this.appCompositeActive) {
      throw new NordicOtaError("busy", "\u8BBE\u5907\u5B58\u5728\u5347\u7EA7\u3001\u6D4B\u91CF\u6216\u540C\u6B65\u4EFB\u52A1");
    }
    let release;
    try {
      release = this.executor.acquireExclusive();
    } catch (e) {
      throw new NordicOtaError("busy", String(e));
    }
    const updater = new NordicOtaUpdater(transport);
    this.nordicUpdater = updater;
    try {
      return await updater.start(firmware, options);
    } finally {
      void updater.whenIdle().then(() => {
        if (this.nordicUpdater === updater)
          this.nordicUpdater = void 0;
        release();
      });
    }
  }
  /** 立即停止后续 Nordic 分片；不能撤回已提交写入或回滚设备。 */
  stopNordicUpgrade() {
    var _a;
    (_a = this.nordicUpdater) === null || _a === void 0 ? void 0 : _a.cancel();
  }
  /** 已准备 Boot 通道的完整重刷；模式切换、持久恢复和重启由调用方协调。 */
  async startPhyUpgrade(transport, firmware, options) {
    if (this.apolloUpdater || this.nordicUpdater || this.phyUpdater || this.bloodOxygenActive || this.heartRateActive || this.historySyncActive || this.appCompositeActive) {
      throw new PhyOtaError("busy", "\u8BBE\u5907\u5B58\u5728\u5347\u7EA7\u3001\u6D4B\u91CF\u6216\u540C\u6B65\u4EFB\u52A1");
    }
    let release;
    try {
      release = this.executor.acquireExclusive();
    } catch (e) {
      throw new PhyOtaError("busy", String(e));
    }
    const updater = new PhyOtaUpdater(transport);
    this.phyUpdater = updater;
    try {
      return await updater.start(firmware, options);
    } finally {
      void updater.whenIdle().then(() => {
        if (this.phyUpdater === updater)
          this.phyUpdater = void 0;
        release();
      });
    }
  }
  /** 停止后续发送，不退出 Boot，也不声称设备已经回滚。 */
  stopPhyUpgrade() {
    var _a;
    (_a = this.phyUpdater) === null || _a === void 0 ? void 0 : _a.cancel();
  }
  /** 同步当前时间到戒指。 */
  syncTime(request) {
    return this.executor.send(setTimeCodec, request);
  }
  /** 读取戒指当前保存的时间。 */
  getTime() {
    return this.executor.execute(getTimeCodec, void 0);
  }
  /** 获取固件版本号。 */
  getFirmwareVersion() {
    return this.executor.execute(getFirmwareVersionCodec, void 0);
  }
  /** 获取硬件版本号。 */
  getHardwareVersion() {
    return this.executor.execute(getHardwareVersionCodec, void 0);
  }
  /** 获取电量百分比或特殊电池状态。 */
  getBatteryLevel() {
    return this.executor.execute(getBatteryLevelCodec, void 0);
  }
  /** 获取当前充电状态。 */
  getChargingState() {
    return this.executor.execute(getChargingStateCodec, void 0);
  }
  /** 读取戒指当前实时步数。 */
  getStepCount() {
    return this.executor.execute(getStepCountCodec, void 0);
  }
  /** 读取实时步数，保留与 iOS SDK readStepCount 接近的命名。 */
  readStepCount() {
    return this.getStepCount();
  }
  /** 清除戒指当前实时步数。 */
  clearStepCount() {
    return this.executor.execute(clearStepCountCodec, void 0);
  }
  /** 设置采集周期，单位秒；0 表示关闭周期采集。 */
  setCollectionPeriod(request) {
    return this.executor.execute(setCollectionPeriodCodec, request);
  }
  /** 读取当前采集周期，单位秒。 */
  getCollectionPeriod() {
    return this.executor.execute(getCollectionPeriodCodec, void 0);
  }
  /** 设置戒指蓝牙名称，UTF-8 字节长度最大 12。 */
  setBluetoothName(request) {
    return this.executor.execute(setBluetoothNameCodec, request);
  }
  /** 读取戒指蓝牙名称。 */
  getBluetoothName() {
    return this.executor.execute(getBluetoothNameCodec, void 0);
  }
  /** 执行一键自检。 */
  oneKeySelfInspection() {
    return this.executor.execute(oneKeySelfInspectionCodec, void 0);
  }
  /** 恢复出厂设置，会清空设备侧数据。 */
  restoreFactorySettings() {
    return this.executor.execute(restoreFactorySettingsCodec, void 0);
  }
  /** 同步戒指内全部历史数据。 */
  syncAllHistoryData(options = {}) {
    return this.syncHistoryData("all", options);
  }
  /** 同步戒指内未上传的历史数据。 */
  syncUnuploadedHistoryData(options = {}) {
    return this.syncHistoryData("unuploaded", options);
  }
  /** 读取全部历史数据，保留与 iOS SDK 接近的命名。 */
  readAllHistoryData(options = {}) {
    return this.syncAllHistoryData(options);
  }
  /** 读取未上传历史数据，保留与 iOS SDK 接近的命名。 */
  readUnUploadData(options = {}) {
    return this.syncUnuploadedHistoryData(options);
  }
  /** 删除戒指内全部历史数据。 */
  deleteAllHistoryData() {
    return this.executor.executeContinuous(deleteAllHistoryDataCodec, void 0, {
      isTerminal: () => true,
      acceptsPacket: (packet) => packet.cmd === deleteAllHistoryDataCodec.cmd && (packet.subcmd === deleteAllHistoryDataCodec.subcmd || packet.subcmd === 255)
    });
  }
  /** 删除戒指内全部历史数据，保留与 iOS SDK 接近的命名。 */
  deleteRingAllHistoryData() {
    return this.deleteAllHistoryData();
  }
  /** App 复合绑定指令，通常用于首次绑定并读取设备基础状态。 */
  async appEventBind(options = {}) {
    const event = await this.executor.executeContinuous(appCompositeBindCodec, normalizeAppCompositeRequest(options.request), {
      isTerminal: () => true,
      isFailure: isAppCompositeFailure,
      toError: (response) => appCompositeEventToError(response),
      acceptsPacket: (packet) => isAppCompositePacket(packet)
    });
    if (event.type !== "device_info") {
      throw new AppCompositeError("bind", "error", "App \u7ED1\u5B9A\u6307\u4EE4\u672A\u8FD4\u56DE\u8BBE\u5907\u4FE1\u606F");
    }
    return event.deviceInfo;
  }
  /** App 复合绑定指令，保留与原生 Demo 语义接近的命名。 */
  bindAppEvent(options = {}) {
    return this.appEventBind(options);
  }
  /** App 复合连接指令，会返回设备信息并同步历史数据。 */
  appEventConnect(options = {}) {
    return this.runAppCompositeSync("connect", options);
  }
  /** App 复合连接指令，保留与原生 Demo 语义接近的命名。 */
  connectAppEvent(options = {}) {
    return this.appEventConnect(options);
  }
  /** App 复合刷新指令，会返回设备信息并同步历史数据。 */
  appEventRefresh(options = {}) {
    return this.runAppCompositeSync("refresh", options);
  }
  /** App 复合刷新指令，保留与原生 Demo 语义接近的命名。 */
  refreshAppEvent(options = {}) {
    return this.appEventRefresh(options);
  }
  /** 查询 GoMore 授权状态，返回授权标志和 MCU ID。 */
  queryGoMoreAuthStatus() {
    return this.executor.execute(queryGoMoreAuthStatusCodec, void 0);
  }
  /** 下发 GoMore 授权 PKey，PKey 按协议固定写入 64 字节。 */
  sendGoMorePKey(request) {
    return this.executor.execute(sendGoMorePKeyCodec, request);
  }
  /** 设置 GoMore 个人信息，参数范围按原生 SDK 校验。 */
  goMoreSetPersonalInformation(request) {
    return this.executor.execute(setGoMorePersonalInformationCodec, request);
  }
  /** 获取 GoMore 个人信息。 */
  goMoreGetPersonalInformation() {
    return this.executor.execute(getGoMorePersonalInformationCodec, void 0);
  }
  /** 读取戒指中 GoMore 睡眠数据，过程包通过回调返回。 */
  async readGoMoreSleepData(options = {}) {
    var _a, _b, _c;
    const sleepModels = [];
    try {
      const finalEvent = await this.executor.executeContinuous(readGoMoreSleepDataCodec, void 0, {
        onProgress: (event) => {
          var _a2, _b2;
          (_a2 = options.onPacket) === null || _a2 === void 0 ? void 0 : _a2.call(options, event);
          if (event.type === "overview" || event.type === "stages") {
            sleepModels.push(event);
            (_b2 = options.onModel) === null || _b2 === void 0 ? void 0 : _b2.call(options, event);
          }
        },
        isTerminal: (event) => {
          if (event.type === "no_data" && sleepModels.length > 0) {
            return false;
          }
          return event.isTerminal;
        },
        acceptsPacket: (packet) => isGoMoreSleepDataPacket(packet),
        onDecodeError: (error, _packet, rawHex) => {
          var _a2;
          (_a2 = options.onMalformedPacket) === null || _a2 === void 0 ? void 0 : _a2.call(options, error, rawHex);
          return "continue";
        }
      });
      (_a = options.onPacket) === null || _a === void 0 ? void 0 : _a.call(options, finalEvent);
      const result = { sleepModels: [...sleepModels], finalEvent };
      (_b = options.onCompleted) === null || _b === void 0 ? void 0 : _b.call(options, result.sleepModels);
      return result;
    } catch (error) {
      const normalizedError = error instanceof Error ? error : new GoMoreSleepDataError();
      (_c = options.onError) === null || _c === void 0 ? void 0 : _c.call(options, normalizedError);
      throw normalizedError;
    }
  }
  /** 停止上传本地历史数据，主要用于同步生命周期清理。 */
  stopHistoryDataUpload() {
    this.historySyncActive = false;
    this.executor.cancelPending(syncAllHistoryDataCodec.cmd, syncAllHistoryDataCodec.subcmd, new HistoryDataSyncError("error", "\u5386\u53F2\u6570\u636E\u540C\u6B65\u5DF2\u505C\u6B62"));
    this.executor.cancelPending(syncUnuploadedHistoryDataCodec.cmd, syncUnuploadedHistoryDataCodec.subcmd, new HistoryDataSyncError("error", "\u5386\u53F2\u6570\u636E\u540C\u6B65\u5DF2\u505C\u6B62"));
    return this.executor.execute(stopHistoryDataUploadCodec, void 0);
  }
  /** 主动测量温度，默认使用快速预测模式。 */
  measureTemperature(options = {}) {
    return this.executor.executeContinuous(measureTemperatureCodec, options.request, {
      onProgress: options.onProgress,
      isTerminal: isTemperatureMeasureTerminal,
      isFailure: isTemperatureMeasureFailure,
      toError: (response) => new TemperatureMeasurementError(response.status)
    });
  }
  /** 读取温度，保留与 iOS SDK readTemperature 接近的命名。 */
  readTemperature(options = {}) {
    return this.measureTemperature(options);
  }
  /** 开始主动测量心率，过程数据通过回调返回。 */
  async startHeartRate(options = {}) {
    var _a, _b, _c;
    if (this.heartRateActive) {
      throw new HeartRateMeasurementError("busy", "\u5FC3\u7387\u6D4B\u91CF\u5DF2\u5728\u8FDB\u884C\u4E2D");
    }
    this.heartRateActive = true;
    try {
      const result = await this.executor.executeContinuous(startHeartRateCodec, options.request, {
        onProgress: (event) => this.dispatchHeartRateEvent(event, options),
        isTerminal: isHeartRateMeasureTerminal,
        isFailure: isHeartRateMeasureFailure,
        toError: (event) => new HeartRateMeasurementError(event.type === "result" ? event.status : "stopped"),
        acceptsPacket: (packet) => isHeartRateMeasurePacket(packet)
      });
      this.heartRateActive = false;
      if (result.type === "result") {
        (_a = options.onStatusChanged) === null || _a === void 0 ? void 0 : _a.call(options, result.status, result);
        if (result.heartRate !== void 0) {
          (_b = options.onMeasureValue) === null || _b === void 0 ? void 0 : _b.call(options, result);
        }
      } else if (result.type === "progress") {
        (_c = options.onProgress) === null || _c === void 0 ? void 0 : _c.call(options, result);
      }
      return result;
    } catch (error) {
      this.heartRateActive = false;
      throw error;
    }
  }
  /** 停止主动测量心率。 */
  async stopHeartRate() {
    await this.executor.execute(stopHeartRateCodec, void 0);
    this.heartRateActive = false;
    this.executor.cancelPending(startHeartRateCodec.cmd, startHeartRateCodec.subcmd, new HeartRateMeasurementError("stopped"));
  }
  /** 开始主动测量血氧，过程数据通过回调返回。 */
  async startBloodOxygen(options = {}) {
    if (this.bloodOxygenActive) {
      throw new BloodOxygenMeasurementError("busy", "\u8840\u6C27\u6D4B\u91CF\u5DF2\u5728\u8FDB\u884C\u4E2D");
    }
    this.bloodOxygenActive = true;
    try {
      const result = await this.executor.executeContinuous(startBloodOxygenCodec, options.request, {
        onProgress: (event) => this.dispatchBloodOxygenEvent(event, options),
        isTerminal: isBloodOxygenMeasureTerminal,
        isFailure: isBloodOxygenMeasureFailure,
        toError: (event) => new BloodOxygenMeasurementError(event.type === "result" ? event.status : "stopped"),
        acceptsPacket: (packet) => isBloodOxygenMeasurePacket(packet)
      });
      this.bloodOxygenActive = false;
      this.dispatchBloodOxygenEvent(result, options);
      return result;
    } catch (error) {
      this.bloodOxygenActive = false;
      throw error;
    }
  }
  /** 停止主动测量血氧。 */
  async stopBloodOxygen() {
    this.bloodOxygenActive = false;
    this.executor.cancelPending(startBloodOxygenCodec.cmd, startBloodOxygenCodec.subcmd, new BloodOxygenMeasurementError("stopped"));
    await this.executor.send(stopBloodOxygenCodec, void 0);
  }
  /** 监听戒指主动推送的电池信息，返回函数用于取消监听。 */
  onBatteryPush(listener) {
    this.batteryListeners.add(listener);
    return () => {
      this.batteryListeners.delete(listener);
    };
  }
  /** 监听从电池主动推送中解析出的充电状态变化。 */
  onChargingStateChanged(listener) {
    this.chargingStateListeners.add(listener);
    return () => {
      this.chargingStateListeners.delete(listener);
    };
  }
  /** 释放通知监听并清理未完成请求。 */
  close() {
    this.stopApolloUpgrade();
    this.stopNordicUpgrade();
    this.stopPhyUpgrade();
    this.batteryListeners.clear();
    this.chargingStateListeners.clear();
    this.bloodOxygenActive = false;
    this.heartRateActive = false;
    this.historySyncActive = false;
    this.appCompositeActive = false;
    this.executor.close();
  }
  async runAppCompositeSync(kind, options) {
    var _a, _b;
    if (this.historySyncActive || this.appCompositeActive) {
      throw new AppCompositeError(kind, "busy", "App \u590D\u5408\u6307\u4EE4\u6216\u5386\u53F2\u6570\u636E\u540C\u6B65\u5DF2\u5728\u8FDB\u884C\u4E2D");
    }
    this.appCompositeActive = true;
    const records = [];
    let deviceInfo;
    const codec = kind === "connect" ? appCompositeConnectCodec : appCompositeRefreshCodec;
    const historyCallbacks = {
      onStatusChanged: options.onStatusChanged,
      onProgress: options.onProgress,
      onRecord: options.onRecord,
      onError: options.onError,
      onMalformedRecord: options.onMalformedRecord
    };
    try {
      const finalEvent = await this.executor.executeContinuous(codec, normalizeAppCompositeRequest(options.request), {
        onProgress: (event) => {
          var _a2;
          if (event.type === "device_info") {
            deviceInfo = event.deviceInfo;
            (_a2 = options.onDeviceInfo) === null || _a2 === void 0 ? void 0 : _a2.call(options, event.deviceInfo);
            return;
          }
          if (event.type === "history") {
            this.dispatchHistorySyncEvent(event.history, records, historyCallbacks);
          }
        },
        isTerminal: (event) => event.type === "negative_response" || event.type === "history" && isHistorySyncTerminal(event.history) && deviceInfo !== void 0,
        isFailure: isAppCompositeFailure,
        toError: (event) => appCompositeEventToError(event),
        acceptsPacket: (packet) => isAppCompositePacket(packet),
        onDecodeError: (error, _packet, rawHex) => {
          var _a2;
          (_a2 = options.onMalformedRecord) === null || _a2 === void 0 ? void 0 : _a2.call(options, error, rawHex);
          return "continue";
        }
      });
      this.appCompositeActive = false;
      if (finalEvent.type === "history") {
        this.dispatchHistorySyncEvent(finalEvent.history, records, historyCallbacks);
      }
      const result = {
        kind,
        deviceInfo,
        records: [...records],
        finalEvent
      };
      (_a = options.onCompleted) === null || _a === void 0 ? void 0 : _a.call(options, result);
      return result;
    } catch (error) {
      this.appCompositeActive = false;
      const normalizedError = error instanceof Error ? error : new AppCompositeError(kind, "error");
      (_b = options.onError) === null || _b === void 0 ? void 0 : _b.call(options, normalizedError);
      throw normalizedError;
    }
  }
  async syncHistoryData(kind, options) {
    var _a, _b, _c;
    if (this.historySyncActive) {
      throw new HistoryDataSyncError("busy", "\u5386\u53F2\u6570\u636E\u540C\u6B65\u5DF2\u5728\u8FDB\u884C\u4E2D");
    }
    this.historySyncActive = true;
    const records = [];
    const codec = kind === "all" ? syncAllHistoryDataCodec : syncUnuploadedHistoryDataCodec;
    try {
      const finalEvent = await this.executor.executeContinuous(codec, { timestamp: (_a = options.timestamp) !== null && _a !== void 0 ? _a : 0 }, {
        onProgress: (event) => {
          this.dispatchHistorySyncEvent(event, records, options);
        },
        isTerminal: isHistorySyncTerminal,
        isFailure: isHistorySyncFailure,
        toError: (event) => historySyncEventToError(event),
        acceptsPacket: (packet) => isHistorySyncPacket(packet),
        onDecodeError: (error, _packet, rawHex) => {
          var _a2;
          (_a2 = options.onMalformedRecord) === null || _a2 === void 0 ? void 0 : _a2.call(options, error, rawHex);
          return "continue";
        }
      });
      this.historySyncActive = false;
      this.dispatchHistorySyncEvent(finalEvent, records, options);
      const result = {
        kind,
        status: finalEvent.status,
        records: [...records],
        finalEvent
      };
      if (finalEvent.status === "completed" || finalEvent.status === "no_data") {
        (_b = options.onCompleted) === null || _b === void 0 ? void 0 : _b.call(options, result.records);
      }
      return result;
    } catch (error) {
      this.historySyncActive = false;
      const normalizedError = error instanceof Error ? error : new ProtocolError("\u5386\u53F2\u6570\u636E\u540C\u6B65\u5931\u8D25");
      (_c = options.onError) === null || _c === void 0 ? void 0 : _c.call(options, normalizedError);
      throw normalizedError;
    }
  }
  handleUnhandledNotification(packet, rawHex) {
    if (!isBatteryPushPacket(packet)) {
      return;
    }
    let event;
    try {
      event = decodeBatteryPushPacket(packet, rawHex);
    } catch (_) {
      return;
    }
    for (const listener of this.batteryListeners) {
      listener(event);
    }
    if (!event.chargingState) {
      return;
    }
    for (const listener of this.chargingStateListeners) {
      listener(event.chargingState, event);
    }
  }
  dispatchHeartRateEvent(event, options) {
    var _a, _b, _c, _d, _e, _f;
    if (event.type === "result") {
      (_a = options.onStatusChanged) === null || _a === void 0 ? void 0 : _a.call(options, event.status, event);
      if (event.heartRate !== void 0) {
        (_b = options.onMeasureValue) === null || _b === void 0 ? void 0 : _b.call(options, event);
      }
      if (event.progress !== void 0) {
        (_c = options.onProgress) === null || _c === void 0 ? void 0 : _c.call(options, event);
      }
      return;
    }
    if (event.type === "progress") {
      (_d = options.onProgress) === null || _d === void 0 ? void 0 : _d.call(options, event);
      return;
    }
    if (event.type === "waveform") {
      (_e = options.onWaveform) === null || _e === void 0 ? void 0 : _e.call(options, event);
      return;
    }
    (_f = options.onRRInterval) === null || _f === void 0 ? void 0 : _f.call(options, event);
  }
  dispatchBloodOxygenEvent(event, options) {
    var _a, _b, _c, _d, _e, _f;
    if (event.type === "result") {
      (_a = options.onStatusChanged) === null || _a === void 0 ? void 0 : _a.call(options, event.status, event);
      if (event.bloodOxygen !== void 0 || event.heartRate !== void 0 || event.temperatureCelsius !== void 0 || event.temperatureRaw !== void 0) {
        (_b = options.onMeasureValue) === null || _b === void 0 ? void 0 : _b.call(options, event);
      }
      return;
    }
    if (event.type === "progress") {
      (_c = options.onProgress) === null || _c === void 0 ? void 0 : _c.call(options, event);
      return;
    }
    if (event.type === "waveform") {
      (_d = options.onWaveform) === null || _d === void 0 ? void 0 : _d.call(options, event);
      return;
    }
    if (event.type === "perfusion_rate") {
      (_e = options.onPerfusionRate) === null || _e === void 0 ? void 0 : _e.call(options, event);
      return;
    }
    (_f = options.onBloodPressure) === null || _f === void 0 ? void 0 : _f.call(options, event);
  }
  dispatchHistorySyncEvent(event, records, options) {
    var _a, _b, _c;
    (_a = options.onStatusChanged) === null || _a === void 0 ? void 0 : _a.call(options, event.status, event);
    if (event.type !== "record" || !event.record) {
      return;
    }
    records.push(event.record);
    (_b = options.onRecord) === null || _b === void 0 ? void 0 : _b.call(options, event.record);
    (_c = options.onProgress) === null || _c === void 0 ? void 0 : _c.call(options, event.totalNumber, event.sequence, event.progress, event.record);
  }
};
function temperatureFailureMessage(status) {
  if (status === "not_wearing") {
    return "\u68C0\u6D4B\u672A\u4F69\u6234\uFF0C\u6D4B\u91CF\u5931\u8D25";
  }
  if (status === "busy") {
    return "\u8BBE\u5907\u7E41\u5FD9\uFF0C\u65E0\u6CD5\u6D4B\u91CF";
  }
  if (status === "charging") {
    return "\u8BBE\u5907\u6B63\u5728\u5145\u7535\uFF0C\u65E0\u6CD5\u6D4B\u91CF";
  }
  if (status === "invalid") {
    return "\u6E29\u5EA6\u6570\u636E\u65E0\u6548";
  }
  return `\u6E29\u5EA6\u6D4B\u91CF\u5931\u8D25\uFF1A${status}`;
}
function heartRateFailureMessage(status) {
  if (status === "not_wearing") {
    return "\u8BBE\u5907\u672A\u4F69\u6234\uFF0C\u8BF7\u5148\u4F69\u6234\u8BBE\u5907";
  }
  if (status === "busy") {
    return "\u8BBE\u5907\u6B63\u5FD9\uFF0C\u8BF7\u7A0D\u540E\u518D\u8BD5";
  }
  if (status === "charging") {
    return "\u8BBE\u5907\u6B63\u5728\u5145\u7535\uFF0C\u65E0\u6CD5\u6D4B\u91CF";
  }
  if (status === "timeout") {
    return "\u5FC3\u7387\u6570\u636E\u91C7\u96C6\u8D85\u65F6";
  }
  if (status === "stopped") {
    return "\u5FC3\u7387\u6D4B\u91CF\u5DF2\u505C\u6B62";
  }
  return `\u5FC3\u7387\u6D4B\u91CF\u5931\u8D25\uFF1A${status}`;
}
function bloodOxygenFailureMessage(status) {
  if (status === "not_wearing") {
    return "\u8BBE\u5907\u672A\u4F69\u6234\uFF0C\u8BF7\u5148\u4F69\u6234\u8BBE\u5907";
  }
  if (status === "busy") {
    return "\u8BBE\u5907\u6B63\u5FD9\uFF0C\u8BF7\u7A0D\u540E\u518D\u8BD5";
  }
  if (status === "charging") {
    return "\u8BBE\u5907\u6B63\u5728\u5145\u7535\uFF0C\u65E0\u6CD5\u6D4B\u91CF";
  }
  if (status === "timeout") {
    return "\u8840\u6C27\u6570\u636E\u91C7\u96C6\u8D85\u65F6";
  }
  if (status === "stopped") {
    return "\u8840\u6C27\u6D4B\u91CF\u5DF2\u505C\u6B62";
  }
  return `\u8840\u6C27\u6D4B\u91CF\u5931\u8D25\uFF1A${status}`;
}
function historySyncEventToError(event) {
  var _a, _b, _c, _d;
  if (event.type === "negative_response") {
    return new HistoryDataSyncError("negative_response", (_a = event.message) !== null && _a !== void 0 ? _a : ringDataNegativeMessage((_b = event.errorCode) !== null && _b !== void 0 ? _b : 255));
  }
  if (event.type === "busy") {
    return new HistoryDataSyncError("busy", (_c = event.message) !== null && _c !== void 0 ? _c : "\u8BBE\u5907\u7E41\u5FD9\uFF0C\u6682\u65F6\u65E0\u6CD5\u540C\u6B65\u5386\u53F2\u6570\u636E");
  }
  return new HistoryDataSyncError("error", (_d = event.message) !== null && _d !== void 0 ? _d : "\u5386\u53F2\u6570\u636E\u540C\u6B65\u5931\u8D25");
}
function appCompositeEventToError(event) {
  if (event.type === "negative_response") {
    return new AppCompositeError(event.kind, "negative_response", event.message);
  }
  if (event.type === "history") {
    const error = historySyncEventToError(event.history);
    return new AppCompositeError(event.kind, event.history.type === "busy" ? "busy" : "error", error.message);
  }
  return new AppCompositeError(event.kind, "error");
}
function normalizeAppCompositeRequest(request) {
  var _a, _b, _c;
  return {
    timestampMs: (_a = request === null || request === void 0 ? void 0 : request.timestampMs) !== null && _a !== void 0 ? _a : Date.now(),
    timezone: (_b = request === null || request === void 0 ? void 0 : request.timezone) !== null && _b !== void 0 ? _b : 8,
    filterTimestamp: (_c = request === null || request === void 0 ? void 0 : request.filterTimestamp) !== null && _c !== void 0 ? _c : 0
  };
}

// packages/transport/dist/index.js
var BleCommandTransport = class {
  constructor(platform, config) {
    this.platform = platform;
    this.config = config;
  }
  /** 写入命令特征。 */
  write(data) {
    return this.platform.writeCharacteristic({
      deviceId: this.config.deviceId,
      serviceId: this.config.serviceId,
      characteristicId: this.config.writeCharacteristicId,
      data
    });
  }
  /** 只向上层透传当前设备和 notify 特征匹配的通知。 */
  onNotification(callback) {
    return this.platform.onCharacteristicValueChanged((event) => {
      if (!this.isCommandNotification(event)) {
        return;
      }
      callback(event.data);
    });
  }
  isCommandNotification(event) {
    return event.deviceId === this.config.deviceId && event.serviceId === this.config.serviceId && event.characteristicId === this.config.notifyCharacteristicId;
  }
};

// packages/adapter-wechat/src/index.ts
function getWechatBlePlatform(wx) {
  var _a, _b;
  for (const read of [() => {
    var _a2;
    return (_a2 = wx.getDeviceInfo) == null ? void 0 : _a2.call(wx);
  }, () => {
    var _a2;
    return (_a2 = wx.getSystemInfoSync) == null ? void 0 : _a2.call(wx);
  }]) {
    try {
      const platform = (_b = (_a = read()) == null ? void 0 : _a.platform) == null ? void 0 : _b.toLowerCase();
      if (platform === "ios" || platform === "android") return platform;
    } catch (e) {
    }
  }
  return "unknown";
}
var DEFAULT_WECHAT_TOKEN_STORAGE_KEY = "bcl_ring_network_token";
function createWechatTokenStore(options) {
  var _a;
  const storageKey = (_a = options.storageKey) != null ? _a : DEFAULT_WECHAT_TOKEN_STORAGE_KEY;
  return {
    getToken() {
      const value = options.wx.getStorageSync(storageKey);
      return typeof value === "string" && value ? value : void 0;
    },
    setToken(token) {
      if (token) {
        options.wx.setStorageSync(storageKey, token);
      } else {
        options.wx.removeStorageSync(storageKey);
      }
    }
  };
}
function setWechatToken(options, token) {
  const normalizedToken = token == null ? void 0 : token.trim();
  if (!normalizedToken) {
    throw new Error("token\u4E0D\u80FD\u4E3A\u7A7A\uFF0C\u9000\u51FA\u767B\u5F55\u8BF7\u8C03\u7528clearWechatToken");
  }
  const storage = createWechatTokenStore(options);
  storage.setToken(normalizedToken);
}
function clearWechatToken(options) {
  const storage = createWechatTokenStore(options);
  storage.setToken(void 0);
}
var DEFAULT_RING_SERVICE_UUID = "0001";
var DEFAULT_RING_WRITE_CHARACTERISTIC_UUID = "0010";
var DEFAULT_RING_NOTIFY_CHARACTERISTIC_UUID = "0011";
var WechatBlePlatformTransport = class {
  constructor(options) {
    this.options = options;
  }
  /** 写入微信 BLE 特征。 */
  writeCharacteristic(params) {
    return new Promise((resolve, reject) => {
      this.options.wx.writeBLECharacteristicValue({
        deviceId: params.deviceId,
        serviceId: params.serviceId,
        characteristicId: params.characteristicId,
        value: toArrayBuffer(params.data),
        writeType: this.options.writeType,
        success: () => resolve(),
        fail: (error) => reject(toWechatBleError(error, {
          deviceId: params.deviceId,
          serviceId: params.serviceId,
          characteristicId: params.characteristicId,
          writeType: this.options.writeType
        }))
      });
    });
  }
  /** 监听微信 BLE 特征变化，并转换为 transport 统一事件。 */
  onCharacteristicValueChanged(callback) {
    const listener = (event) => {
      callback({
        deviceId: event.deviceId,
        serviceId: event.serviceId,
        characteristicId: event.characteristicId,
        data: new Uint8Array(event.value)
      });
    };
    this.options.wx.onBLECharacteristicValueChange(listener);
    return () => {
      var _a, _b;
      (_b = (_a = this.options.wx).offBLECharacteristicValueChange) == null ? void 0 : _b.call(_a, listener);
    };
  }
};
function createWechatRingSDK(options) {
  const platform = new WechatBlePlatformTransport({
    wx: options.wx,
    writeType: options.writeType
  });
  const bleCommandTransport = new BleCommandTransport(platform, options.channel);
  const queuedTransport = new QueuedCommandTransport(bleCommandTransport, options.queue);
  return new RingSDK(queuedTransport, options.command);
}
async function connectWechatRingSDK(options) {
  await createBleConnection(options.wx, options.deviceId, options.connectTimeoutMs);
  const unsubscribeMtuChange = subscribeBleMtuChange(options);
  try {
    const channel = await prepareWechatRingChannel({
      wx: options.wx,
      deviceId: options.deviceId,
      serviceUuid: options.serviceUuid,
      writeCharacteristicUuid: options.writeCharacteristicUuid,
      notifyCharacteristicUuid: options.notifyCharacteristicUuid,
      notifyType: options.notifyType
    });
    const mtuResult = await configureBleMtu(options);
    const sdk = createWechatRingSDK({
      wx: options.wx,
      writeType: options.writeType,
      channel,
      command: options.command,
      queue: options.queue
    });
    return {
      sdk,
      channel,
      platform: getWechatBlePlatform(options.wx),
      mtu: mtuResult.mtu,
      currentMtu: mtuResult.currentMtu,
      disconnect: async () => {
        sdk.close();
        unsubscribeMtuChange();
        await closeBleConnection(options.wx, options.deviceId);
      }
    };
  } catch (error) {
    unsubscribeMtuChange();
    await closeBleConnection(options.wx, options.deviceId).catch(() => {
    });
    throw error;
  }
}
async function scanWechatRingDevices(options) {
  var _a, _b, _c, _d, _e;
  const devices = /* @__PURE__ */ new Map();
  let active = true;
  const listener = (event) => {
    var _a2;
    if (!active) {
      return;
    }
    for (const device of event.devices) {
      const normalizedDevice = normalizeScannedDevice({ ...device, systemConnected: void 0 });
      (_a2 = options.onDeviceFound) == null ? void 0 : _a2.call(options, normalizedDevice);
      if (matchesScanFilter(normalizedDevice, options)) {
        devices.set(normalizedDevice.deviceId, normalizedDevice);
      }
    }
  };
  await openBluetoothAdapter(options.wx);
  options.wx.onBluetoothDeviceFound(listener);
  try {
    await startBluetoothDevicesDiscovery(options.wx, {
      services: options.services,
      allowDuplicatesKey: options.allowDuplicatesKey,
      interval: options.interval,
      powerLevel: options.powerLevel
    });
    await delay2((_a = options.durationMs) != null ? _a : 5e3);
    const cachedDevices = await getBluetoothDevices(options.wx).catch(() => []);
    for (const device of cachedDevices) {
      const normalizedDevice = normalizeScannedDevice({ ...device, systemConnected: void 0 });
      (_b = options.onDeviceFound) == null ? void 0 : _b.call(options, normalizedDevice);
      if (matchesScanFilter(normalizedDevice, options)) {
        devices.set(normalizedDevice.deviceId, normalizedDevice);
      }
    }
    if (options.includeConnectedDevices && typeof options.wx.getConnectedBluetoothDevices === "function") {
      const connected = await new Promise((resolve) => {
        var _a2;
        const timer = setTimeout(() => resolve([]), 2e3);
        const finish = (items) => {
          clearTimeout(timer);
          resolve(items);
        };
        try {
          options.wx.getConnectedBluetoothDevices({
            services: ((_a2 = options.services) == null ? void 0 : _a2.length) ? options.services : [DEFAULT_RING_SERVICE_UUID],
            success: (result) => finish(result.devices),
            fail: () => finish([])
          });
        } catch (e) {
          finish([]);
        }
      });
      for (const item of connected) {
        const previous = devices.get(item.deviceId);
        const device = normalizeScannedDevice({ ...previous, ...item, systemConnected: true });
        (_c = options.onDeviceFound) == null ? void 0 : _c.call(options, device);
        if (matchesScanFilter(device, options)) devices.set(device.deviceId, device);
      }
    }
  } finally {
    active = false;
    (_e = (_d = options.wx).offBluetoothDeviceFound) == null ? void 0 : _e.call(_d, listener);
    await stopBluetoothDevicesDiscovery(options.wx).catch(() => {
    });
  }
  return Array.from(devices.values());
}
async function prepareWechatRingChannel(options) {
  var _a, _b;
  const serviceId = await findServiceId(options);
  const characteristics = await getCharacteristics(options.wx, options.deviceId, serviceId);
  const writeCharacteristicId = findCharacteristicId(
    characteristics,
    (_a = options.writeCharacteristicUuid) != null ? _a : DEFAULT_RING_WRITE_CHARACTERISTIC_UUID,
    (characteristic) => {
      var _a2, _b2;
      return ((_a2 = characteristic.properties) == null ? void 0 : _a2.write) === true || ((_b2 = characteristic.properties) == null ? void 0 : _b2.writeNoResponse) === true;
    }
  );
  const notifyCharacteristicId = findCharacteristicId(
    characteristics,
    (_b = options.notifyCharacteristicUuid) != null ? _b : DEFAULT_RING_NOTIFY_CHARACTERISTIC_UUID,
    (characteristic) => {
      var _a2, _b2;
      return ((_a2 = characteristic.properties) == null ? void 0 : _a2.notify) === true || ((_b2 = characteristic.properties) == null ? void 0 : _b2.indicate) === true;
    }
  );
  await enableNotify(options.wx, {
    deviceId: options.deviceId,
    serviceId,
    characteristicId: notifyCharacteristicId,
    type: options.notifyType
  });
  return {
    deviceId: options.deviceId,
    serviceId,
    writeCharacteristicId,
    notifyCharacteristicId
  };
}
var WechatBlePlatformError = class extends Error {
  constructor(error) {
    var _a;
    const codePrefix = error.errCode === void 0 ? "" : `[${error.errCode}] `;
    super(`${codePrefix}${(_a = error.errMsg) != null ? _a : "WeChat BLE operation failed."}`);
    this.name = "WechatBlePlatformError";
    this.errCode = error.errCode;
    this.errMsg = error.errMsg;
  }
};
function toArrayBuffer(bytes) {
  const copy = new Uint8Array(bytes.byteLength);
  copy.set(bytes);
  return copy.buffer;
}
function toWechatBleError(error, context) {
  var _a;
  if (!context) {
    return new WechatBlePlatformError(error);
  }
  const contextText = Object.entries(context).filter(([, value]) => value).map(([key, value]) => `${key}=${value}`).join(" ");
  return new WechatBlePlatformError({
    errCode: error.errCode,
    errMsg: contextText ? `${(_a = error.errMsg) != null ? _a : "WeChat BLE operation failed."} (${contextText})` : error.errMsg
  });
}
function createBleConnection(wx, deviceId, timeout) {
  return new Promise((resolve, reject) => {
    wx.createBLEConnection({
      deviceId,
      timeout,
      success: () => resolve(),
      fail: (error) => {
        if (error.errCode === -1 || error.errCode === 10010) resolve();
        else reject(toWechatBleError(error));
      }
    });
  });
}
function subscribeBleMtuChange(options) {
  if (getWechatBlePlatform(options.wx) !== "android" || typeof options.wx.onBLEMTUChange !== "function") {
    return () => {
    };
  }
  const listener = (event) => {
    var _a;
    if (event.deviceId === options.deviceId) {
      (_a = options.onMtuChanged) == null ? void 0 : _a.call(options, event);
    }
  };
  options.wx.onBLEMTUChange(listener);
  return () => {
    var _a, _b;
    (_b = (_a = options.wx).offBLEMTUChange) == null ? void 0 : _b.call(_a, listener);
  };
}
async function configureBleMtu(options) {
  var _a, _b;
  if (getWechatBlePlatform(options.wx) !== "android" || !options.preferredMtu || typeof options.wx.setBLEMTU !== "function") {
    const currentMtu = await getBleMtu(options.wx, options.deviceId, options.writeType).catch(() => void 0);
    return { currentMtu };
  }
  try {
    const mtu = await setBleMtu(options.wx, options.deviceId, options.preferredMtu);
    const currentMtu = await getBleMtu(options.wx, options.deviceId, options.writeType).catch(() => mtu);
    (_a = options.onMtuConfigured) == null ? void 0 : _a.call(options, { requestedMtu: options.preferredMtu, mtu, currentMtu });
    return { mtu, currentMtu };
  } catch (error) {
    const platformError = error instanceof WechatBlePlatformError ? error : new WechatBlePlatformError({ errMsg: String(error) });
    const currentMtu = await getBleMtu(options.wx, options.deviceId, options.writeType).catch(() => void 0);
    (_b = options.onMtuConfigured) == null ? void 0 : _b.call(options, { requestedMtu: options.preferredMtu, currentMtu, error: platformError });
    return { currentMtu };
  }
}
function setBleMtu(wx, deviceId, mtu) {
  return new Promise((resolve, reject) => {
    var _a;
    (_a = wx.setBLEMTU) == null ? void 0 : _a.call(wx, {
      deviceId,
      mtu,
      success: (result) => {
        var _a2;
        return resolve((_a2 = result.mtu) != null ? _a2 : mtu);
      },
      fail: (error) => reject(toWechatBleError(error, {
        deviceId,
        mtu: String(mtu)
      }))
    });
  });
}
function getBleMtu(wx, deviceId, writeType) {
  return new Promise((resolve, reject) => {
    if (typeof wx.getBLEMTU !== "function") {
      reject(new WechatBlePlatformError({ errMsg: "wx.getBLEMTU is not supported." }));
      return;
    }
    wx.getBLEMTU({
      deviceId,
      writeType,
      success: (result) => {
        if (!Number.isInteger(result.mtu) || result.mtu < 23) {
          reject(new WechatBlePlatformError({ errMsg: "wx.getBLEMTU returned an invalid ATT_MTU." }));
          return;
        }
        resolve(result.mtu);
      },
      fail: (error) => reject(toWechatBleError(error, {
        deviceId,
        writeType
      }))
    });
  });
}
function closeBleConnection(wx, deviceId) {
  return new Promise((resolve, reject) => {
    wx.closeBLEConnection({
      deviceId,
      success: () => resolve(),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function openBluetoothAdapter(wx) {
  return new Promise((resolve, reject) => {
    wx.openBluetoothAdapter({
      success: () => resolve(),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function startBluetoothDevicesDiscovery(wx, options) {
  return new Promise((resolve, reject) => {
    wx.startBluetoothDevicesDiscovery({
      ...options,
      success: () => resolve(),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function stopBluetoothDevicesDiscovery(wx) {
  return new Promise((resolve, reject) => {
    wx.stopBluetoothDevicesDiscovery({
      success: () => resolve(),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function getBluetoothDevices(wx) {
  if (!wx.getBluetoothDevices) {
    return Promise.resolve([]);
  }
  return new Promise((resolve, reject) => {
    var _a;
    (_a = wx.getBluetoothDevices) == null ? void 0 : _a.call(wx, {
      success: (result) => resolve(result.devices),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function matchesScanFilter(device, options) {
  var _a, _b;
  const name = device.localName || device.name || "";
  if (options.deviceId && device.deviceId !== options.deviceId) {
    return false;
  }
  if (options.filterBclManufacturerData && !(options.includePhyBootloader && device.mode === "phyBootloader") && !isBclManufacturerData((_a = device.manufacturerData) != null ? _a : []) && !(device.systemConnected && !((_b = device.manufacturerData) == null ? void 0 : _b.length))) {
    return false;
  }
  if (options.namePrefix && !name.startsWith(options.namePrefix)) {
    return false;
  }
  if (options.nameIncludes && !name.includes(options.nameIncludes)) {
    return false;
  }
  if (options.filter && !options.filter(device)) {
    return false;
  }
  return true;
}
function normalizeScannedDevice(device) {
  const manufacturerData = getManufacturerData(device);
  const boot = isPhyBootAdvertisement(device);
  const mac = boot ? getPhyBootMac(manufacturerData) : getMacAddressFromManufacturerData(manufacturerData);
  return {
    ...device,
    manufacturerData,
    manufacturerDataHex: bytesToHex2(manufacturerData),
    macAddress: mac,
    mode: boot ? "phyBootloader" : isBclManufacturerData(manufacturerData) ? "application" : "unknown",
    applicationMac: boot && mac ? shiftPhyMac(mac, -1) : void 0
  };
}
function isBclManufacturerData(manufacturerData) {
  return (manufacturerData.length === 8 || manufacturerData.length === 9) && manufacturerData[1] === 255;
}
function getMacAddressFromManufacturerData(manufacturerData) {
  if (!isBclManufacturerData(manufacturerData)) {
    return void 0;
  }
  return [7, 6, 5, 4, 3, 2].map((index) => manufacturerData[index].toString(16).padStart(2, "0").toUpperCase()).join(":");
}
function getManufacturerData(device) {
  if (!device.advertisData) {
    return [];
  }
  return Array.from(new Uint8Array(device.advertisData));
}
function bytesToHex2(bytes) {
  return bytes.map((byte) => byte.toString(16).padStart(2, "0").toUpperCase()).join("");
}
async function findServiceId(options) {
  var _a;
  const services = await getServices(options.wx, options.deviceId);
  const serviceUuid = (_a = options.serviceUuid) != null ? _a : DEFAULT_RING_SERVICE_UUID;
  const service = services.find((item) => uuidMatches(item.uuid, serviceUuid));
  if (!service) {
    throw new WechatBlePlatformError({ errMsg: `BLE service not found: ${serviceUuid}` });
  }
  return service.uuid;
}
function getServices(wx, deviceId) {
  return new Promise((resolve, reject) => {
    wx.getBLEDeviceServices({
      deviceId,
      success: (result) => resolve(result.services),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function getCharacteristics(wx, deviceId, serviceId) {
  return new Promise((resolve, reject) => {
    wx.getBLEDeviceCharacteristics({
      deviceId,
      serviceId,
      success: (result) => resolve(result.characteristics),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function enableNotify(wx, params) {
  return new Promise((resolve, reject) => {
    wx.notifyBLECharacteristicValueChange({
      ...params,
      state: true,
      success: () => resolve(),
      fail: (error) => reject(toWechatBleError(error))
    });
  });
}
function findCharacteristicId(characteristics, uuid, supportsRole) {
  const characteristic = characteristics.find((item) => uuidMatches(item.uuid, uuid) && supportsRole(item));
  if (!characteristic) {
    throw new WechatBlePlatformError({ errMsg: `BLE characteristic not found: ${uuid}` });
  }
  return characteristic.uuid;
}
function uuidMatches(actual, expected) {
  const normalizedActual = normalizeUuid(actual);
  const normalizedExpected = normalizeUuid(expected);
  if (normalizedActual === normalizedExpected) {
    return true;
  }
  if (normalizedExpected.length <= 4) {
    const firstField = normalizedActual.slice(0, 8);
    return normalizedActual.startsWith(normalizedExpected) || firstField.endsWith(normalizedExpected.padStart(4, "0"));
  }
  return false;
}
function normalizeUuid(uuid) {
  return uuid.replace(/^0x/i, "").replace(/-/g, "").toLowerCase();
}
function delay2(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

// packages/network-core/src/errors.ts
var BCLNetworkError = class extends Error {
  constructor(code, message, options = {}) {
    super(message);
    this.name = "BCLNetworkError";
    this.code = code;
    this.status = options.status;
    this.cause = options.cause;
  }
};
function invalidParameters(message) {
  return new BCLNetworkError("invalid_parameters", message);
}
function tokenError(message) {
  return new BCLNetworkError("token_error", message || "Token\u5DF2\u5931\u6548\uFF0C\u9700\u8981\u91CD\u65B0\u767B\u5F55", { status: 401 });
}
function serverError(status, message) {
  return new BCLNetworkError("server_error", message || `\u670D\u52A1\u5668\u9519\u8BEF: ${status}`, { status });
}

// packages/network-core/src/compression.ts
async function gzipBase64(text) {
  if (!text) {
    return text;
  }
  if (typeof CompressionStream === "undefined") {
    throw new BCLNetworkError("unsupported_compressor", "\u5F53\u524D\u8FD0\u884C\u65F6\u4E0D\u652F\u6301 gzip \u538B\u7F29\uFF0C\u8BF7\u6CE8\u5165 compressWaveData\u3002");
  }
  const stream = new Blob([text]).stream().pipeThrough(new CompressionStream("gzip"));
  const compressed = await new Response(stream).arrayBuffer();
  return bytesToBase64(new Uint8Array(compressed));
}
function bytesToBase64(bytes) {
  let binary = "";
  const chunkSize = 32768;
  for (let offset = 0; offset < bytes.length; offset += chunkSize) {
    const chunk = bytes.subarray(offset, offset + chunkSize);
    binary += String.fromCharCode(...chunk);
  }
  return btoa(binary);
}

// packages/network-core/src/token-store.ts
var MemoryTokenStore = class {
  constructor(initialToken) {
    this.tokenValue = initialToken;
  }
  /** 读取当前 Token。 */
  getToken() {
    return this.tokenValue;
  }
  /** 保存当前 Token。 */
  setToken(token) {
    this.tokenValue = token;
  }
};

// packages/network-core/src/http-client.ts
var DOMESTIC_BASE_URL = "https://ali.bravechip.cn";
var OVERSEAS_BASE_URL = "http://47.237.0.109:8080";
var BCLHttpClient = class {
  constructor(options = {}) {
    var _a, _b, _c, _d, _e, _f;
    this.region = (_a = options.region) != null ? _a : "domestic";
    this.baseURL = (_b = options.baseURL) != null ? _b : this.region === "domestic" ? DOMESTIC_BASE_URL : OVERSEAS_BASE_URL;
    this.clientType = (_c = options.clientType) != null ? _c : "WeChatMP";
    this.timezoneOffset = (_d = options.timezoneOffset) != null ? _d : getCurrentTimezoneOffset();
    this.fetchImpl = (_e = options.fetch) != null ? _e : globalThis.fetch;
    this.tokenStore = (_f = options.tokenStore) != null ? _f : new MemoryTokenStore();
    if (!this.fetchImpl) {
      throw new BCLNetworkError("network_error", "\u5F53\u524D\u8FD0\u884C\u65F6\u4E0D\u652F\u6301 fetch\uFF0C\u8BF7\u6CE8\u5165 fetch \u5B9E\u73B0\u3002");
    }
  }
  /** 读取当前 Token。 */
  async getToken() {
    return this.tokenStore.getToken();
  }
  /** 设置当前 Token；后续网络请求会自动携带 Bearer 认证头。 */
  async setToken(token) {
    await this.tokenStore.setToken(token);
  }
  /** 清除当前 Token；后续网络请求不再携带 Authorization 和 access_token。 */
  async clearToken() {
    await this.tokenStore.setToken(void 0);
  }
  /** 发送请求并按 BCL 服务端响应格式校验状态。 */
  async request(request) {
    const response = await this.fetchImpl(this.buildURL(request), await this.buildRequestInit(request));
    if (!response.ok) {
      throw new BCLNetworkError("http_error", `HTTP\u8BF7\u6C42\u5931\u8D25: ${response.status}`, { status: response.status });
    }
    let json;
    try {
      json = await response.json();
    } catch (error) {
      throw new BCLNetworkError("decoding_error", "\u54CD\u5E94JSON\u89E3\u6790\u5931\u8D25", { cause: error });
    }
    validateServerResponse(json, request.acceptedStatuses);
    return json;
  }
  /** 生成完整 URL，国内区域自动补 /api 前缀。 */
  buildURL(request) {
    var _a;
    const path = this.region === "domestic" ? `/api${request.path}` : request.path;
    let url = `${this.baseURL.replace(/\/$/, "")}/${path.replace(/^\//, "")}`;
    const method = (_a = request.method) != null ? _a : "GET";
    if ((method === "GET" || request.useURLParameters) && request.parameters) {
      const queryItems = [];
      for (const [key, value] of Object.entries(request.parameters)) {
        if (value !== void 0 && value !== null) {
          queryItems.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
        }
      }
      if (queryItems.length) {
        url += `${url.includes("?") ? "&" : "?"}${queryItems.join("&")}`;
      }
    }
    return url;
  }
  async buildRequestInit(request) {
    var _a, _b;
    const method = (_a = request.method) != null ? _a : "GET";
    const headers = {
      "Content-Type": "application/json",
      clientType: this.clientType,
      accept: "*/*",
      timeZone: String(this.timezoneOffset),
      ...(_b = request.headers) != null ? _b : {}
    };
    const token = await this.getToken();
    if (token) {
      headers.Authorization = `Bearer ${token}`;
      headers.access_token = token;
    }
    const init = { method, headers };
    if (method !== "GET" && !request.useURLParameters) {
      const body = request.rawBody !== void 0 ? request.rawBody : request.parameters;
      if (body !== void 0) {
        init.body = request.rawBodyIsEncoded ? body : JSON.stringify(body);
      }
    }
    return init;
  }
};
function getResponseStatus(response) {
  var _a, _b;
  return (_b = (_a = response.status) != null ? _a : response.code) != null ? _b : 0;
}
function getResponseMessage(response) {
  var _a, _b;
  return (_b = (_a = response.message) != null ? _a : response.msg) != null ? _b : "";
}
function isSuccessResponse(response) {
  return getResponseStatus(response) === 200;
}
function validateServerResponse(response, acceptedStatuses = [200]) {
  const status = getResponseStatus(response);
  const message = getResponseMessage(response);
  if (status === 401) {
    throw tokenError(message);
  }
  if (!acceptedStatuses.includes(status)) {
    throw serverError(status, message);
  }
}
function getCurrentTimezoneOffset() {
  return -(/* @__PURE__ */ new Date()).getTimezoneOffset() / 60;
}

// packages/network-core/src/client.ts
var API_ENDPOINTS = {
  createToken: "/app/createTokenForThirdPartCompany",
  refreshToken: "/app/refreshToken",
  checkVersion: "/app/checkDeviceVersion",
  uploadHistory: "/app/uploadHistory",
  uploadMeasureRecord: "/app/insertMeasureRecordRequest",
  firmwareVersionList: "/app/firmwareList",
  loadUserLatestHistory: "/app/loadUserLatestHistory",
  timeline: "/app/timeline",
  uploadFile: "/common/upload",
  questionFeedback: "/app/feedback",
  logout: "/logoutForPhone",
  deleteAccount: "/system/user/profile/cancelUser",
  bindDevice: "/app/bindDevice",
  unbindDevice: "/app/unbindDevice",
  updateDeviceInfo: "/app/uploadDeviceInfo",
  insertActiveMeasureData: "/app/insertMeasureRecord",
  queryActiveMeasureData: "/app/selectMeasureRecordList",
  queryHistoryData: "/app/historyForDevice",
  sleepData: "/app/sleepData",
  sleepDataBatch: "/app/loadSleepDataBatch",
  uploadGoMoreSleepData: "/app/insertGomoreSleepList",
  goMoreSleepData: "/app/getSleepDataWithGoMore",
  goMoreSleepDataBatch: "/app/getSleepDataWithGoMoreBatch",
  sportData: "/app/sportInfo",
  getDeviceByMac: "/app/getDeviceByMac",
  saveUserTarget: "/app/saveUserTarget",
  getUserTarget: "/app/getUserTarget"
};
var BCLRingNetworkSDK = class {
  constructor(options = {}) {
    var _a;
    this.httpClient = new BCLHttpClient(options);
    this.downloader = options.downloader;
    this.compressWaveData = (_a = options.compressWaveData) != null ? _a : gzipBase64;
  }
  /**
   * 设置 App 已有的登录 Token，后续 SDK 网络接口会自动携带该 Token。
   * 空字符串不代表退出登录，退出时应显式调用 clearToken()。
   */
  async setToken(token) {
    const normalizedToken = token == null ? void 0 : token.trim();
    if (!normalizedToken) {
      throw invalidParameters("token\u4E0D\u80FD\u4E3A\u7A7A\uFF0C\u9000\u51FA\u767B\u5F55\u8BF7\u8C03\u7528clearToken");
    }
    await this.httpClient.setToken(normalizedToken);
  }
  /** 清除 SDK 当前 Token，适用于 App 退出登录或登录态失效场景。 */
  clearToken() {
    return this.httpClient.clearToken();
  }
  /** 设置自定义 Token；保留该接口以兼容已有接入代码。 */
  setCustomToken(token) {
    return this.httpClient.setToken(token);
  }
  /** 读取当前 Token，便于 Demo 展示或调试请求头。 */
  getToken() {
    return this.httpClient.getToken();
  }
  /** 创建 Token，成功后会自动保存到 SDK Token 存储。 */
  async createToken(apiKey, userIdentifier) {
    var _a, _b, _c;
    if (!apiKey || !userIdentifier) {
      throw invalidParameters("apiKey\u6216userIdentifier\u4E3A\u7A7A");
    }
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.createToken,
      method: "POST",
      parameters: { apiKey, username: userIdentifier }
    });
    const token = (_c = (_a = response.result) == null ? void 0 : _a.token) != null ? _c : (_b = response.data) == null ? void 0 : _b.token;
    if (!token) {
      throw new BCLNetworkError("invalid_response", "Token\u54CD\u5E94\u4E3A\u7A7A");
    }
    await this.httpClient.setToken(token);
    return token;
  }
  /** 刷新 Token；与原生一致，成功时只延长服务端 Token 时效，不替换本地 Token。 */
  async refreshToken() {
    await this.httpClient.request({
      path: API_ENDPOINTS.refreshToken,
      method: "POST"
    });
  }
  /**
   * 上传通用文件。请求体使用与 Rings iOS 工程一致的 multipart/form-data，字段名固定为 file。
   * Uni-app/微信小程序可把文件读取为 ArrayBuffer 后传入，避免依赖浏览器 FormData。
   */
  async uploadFile(fileData, fileName, mimeType) {
    var _a;
    if (!fileData || !fileName || !mimeType) {
      throw invalidParameters("\u6587\u4EF6\u6570\u636E\u3001\u6587\u4EF6\u540D\u6216MIME\u7C7B\u578B\u4E3A\u7A7A");
    }
    const multipart = await createMultipartFileBody(fileData, fileName, mimeType);
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.uploadFile,
      method: "POST",
      rawBody: multipart.body,
      rawBodyIsEncoded: true,
      headers: { "Content-Type": `multipart/form-data; boundary=${multipart.boundary}` }
    });
    const result = (_a = response.data) != null ? _a : response.result;
    if (!(result == null ? void 0 : result.url) || !result.fileName) {
      throw new BCLNetworkError("invalid_response", "\u6587\u4EF6\u4E0A\u4F20\u54CD\u5E94\u7F3A\u5C11url\u6216fileName");
    }
    return result;
  }
  /** 提交问题反馈；logPath 通常来自 uploadFile() 返回的 fileName。 */
  async questionFeedback(content, logPath, feedbackType, receivedFollow) {
    await this.httpClient.request({
      path: API_ENDPOINTS.questionFeedback,
      method: "POST",
      parameters: { content, logPath, feedbackType, receivedFollow }
    });
  }
  /** 调用服务端退出登录接口；成功后由业务按需调用 clearToken() 清理本地 Token。 */
  async logout() {
    await this.httpClient.request({ path: API_ENDPOINTS.logout, method: "GET" });
  }
  /** 注销当前账户；成功后由业务清理本地用户资料和 Token。 */
  async deleteAccount() {
    await this.httpClient.request({ path: API_ENDPOINTS.deleteAccount, method: "POST", parameters: {} });
  }
  /** 绑定设备 MAC。 */
  async bindDevice(macAddress) {
    if (!macAddress) throw invalidParameters("macAddress\u4E0D\u80FD\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.bindDevice,
      method: "POST",
      parameters: { mac: macAddress }
    });
  }
  /** 解绑设备 MAC。 */
  async unbindDevice(macAddress) {
    if (!macAddress) throw invalidParameters("macAddress\u4E0D\u80FD\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.unbindDevice,
      method: "POST",
      parameters: { mac: macAddress }
    });
  }
  /** 更新服务端戒指信息，只提交调用方明确传入的字段。 */
  async updateDeviceInfo(info) {
    const parameters = compactParameters({
      mac: info.macAddress,
      name: info.name,
      collectPeriod: info.collectPeriod,
      battery: info.battery,
      bindingIndicatorBit: info.bindingIndicatorBit,
      chargingIndicator: info.chargingIndicator,
      communicationProtocolVersion: info.communicationProtocolVersion,
      latitude: info.latitude,
      longitude: info.longitude,
      softwareVersion: info.softwareVersion,
      gomoreEnable: info.gomoreEnable
    });
    if (Object.keys(parameters).length === 0) throw invalidParameters("\u8BBE\u5907\u66F4\u65B0\u5B57\u6BB5\u4E0D\u80FD\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.updateDeviceInfo,
      method: "POST",
      parameters
    });
  }
  /** 插入心率、血氧、温度、ECG 等主动测量记录。 */
  async insertActiveMeasureData(data) {
    const parameters = compactParameters(data);
    if (Object.keys(parameters).length === 0) throw invalidParameters("\u4E3B\u52A8\u6D4B\u91CF\u6570\u636E\u4E0D\u80FD\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.insertActiveMeasureData,
      method: "POST",
      parameters
    });
  }
  /** 查询当前用户的主动测量记录。 */
  async queryActiveMeasureData() {
    var _a, _b;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.queryActiveMeasureData,
      method: "GET"
    });
    return (_b = (_a = response.result) != null ? _a : response.data) != null ? _b : [];
  }
  /** 查询历史健康记录，时间参数使用秒级 Unix 时间戳。 */
  async queryHistoryData(query = {}) {
    var _a, _b;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.queryHistoryData,
      method: "POST",
      parameters: toHealthQueryParameters(query, true)
    });
    return (_b = (_a = response.result) != null ? _a : response.data) != null ? _b : [];
  }
  /** 查询单日睡眠数据，时间参数使用秒级 Unix 时间戳。 */
  async getSleepData(query = {}) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.sleepData,
      method: "POST",
      parameters: toHealthQueryParameters(query),
      useURLParameters: true
    });
    const result = (_a = response.result) != null ? _a : response.data;
    return typeof result === "object" && result !== null ? result : null;
  }
  /** 按日期数组查询周/月睡眠数据，日期格式沿用原生 yyyy-MM-dd。 */
  async getSleepDataByWeekOrMonth(dates, userId) {
    var _a, _b;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.sleepDataBatch,
      method: "POST",
      parameters: compactParameters({ dates, userId })
    });
    return (_b = (_a = response.result) != null ? _a : response.data) != null ? _b : [];
  }
  /** 上传从戒指读取的 GoMore 睡眠总览和分期包，Body 为原生接口要求的 JSON 数组。 */
  async uploadGoMoreSleepData(sleepModels) {
    if (sleepModels.length === 0) throw invalidParameters("GoMore\u7761\u7720\u6570\u636E\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.uploadGoMoreSleepData,
      method: "POST",
      rawBody: sleepModels
    });
  }
  /** 查询单日 GoMore 睡眠详情，时间参数使用秒级 Unix 时间戳。 */
  async getGoMoreSleepData(query = {}) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.goMoreSleepData,
      method: "POST",
      parameters: toHealthQueryParameters(query)
    });
    const result = (_a = response.result) != null ? _a : response.data;
    return typeof result === "object" && result !== null ? result : null;
  }
  /** 按日期数组查询周/月 GoMore 睡眠摘要。 */
  async getGoMoreSleepDataBatch(dates, userId) {
    var _a, _b;
    if (dates.length === 0) throw invalidParameters("GoMore\u7761\u7720\u67E5\u8BE2\u65E5\u671F\u4E3A\u7A7A");
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.goMoreSleepDataBatch,
      method: "POST",
      parameters: compactParameters({ dates, userId })
    });
    return (_b = (_a = response.result) != null ? _a : response.data) != null ? _b : [];
  }
  /** 查询运动汇总数据，时间参数使用秒级 Unix 时间戳。 */
  async getSportData(query = {}) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.sportData,
      method: "POST",
      parameters: toHealthQueryParameters(query),
      useURLParameters: true
    });
    const result = (_a = response.result) != null ? _a : response.data;
    return typeof result === "object" && result !== null ? result : null;
  }
  /** 上传戒指历史数据，data 字段为历史数据 JSON 字符串。 */
  async uploadHistory(historyData, mac) {
    if (historyData.length === 0 || !mac) {
      throw invalidParameters("\u5386\u53F2\u6570\u636E\u4E3A\u7A7A\u6216MAC\u5730\u5740\u4E3A\u7A7A");
    }
    await this.httpClient.request({
      path: API_ENDPOINTS.uploadHistory,
      method: "POST",
      parameters: {
        data: JSON.stringify(historyData),
        mac
      }
    });
  }
  /** 原生命名兼容入口：上传戒指历史记录。 */
  uploadHistoryData(macAddress, historyData) {
    return this.uploadHistory(historyData, macAddress);
  }
  /** 上传血压波形数据并返回高压、低压。 */
  async uploadBloodPressureData(mac, waveData) {
    if (!mac) {
      throw invalidParameters("mac\u4E0D\u80FD\u4E3A\u7A7A");
    }
    const response = await this.uploadMeasureRecord(mac, "\u8840\u538B", waveData);
    const result = parseMeasureResult(response.result);
    const systolic = toNumber(result.sbp);
    const diastolic = toNumber(result.dbp);
    if (systolic === void 0 || diastolic === void 0) {
      throw new BCLNetworkError("invalid_response", "\u8840\u538B\u7ED3\u679C\u89E3\u6790\u5931\u8D25");
    }
    return { systolic, diastolic };
  }
  /** 上传血糖波形数据并返回 mmol/L 数值。 */
  async uploadBloodGlucoseData(mac, waveData) {
    if (!mac) {
      throw invalidParameters("mac\u4E0D\u80FD\u4E3A\u7A7A");
    }
    const response = await this.uploadMeasureRecord(mac, "\u8840\u7CD6", waveData);
    const result = parseMeasureResult(response.result);
    const glucose = toNumber(result.mean_mmol_l);
    if (glucose === void 0) {
      throw new BCLNetworkError("invalid_response", "\u8840\u7CD6\u7ED3\u679C\u89E3\u6790\u5931\u8D25");
    }
    return glucose;
  }
  /** 检查固件更新；status=100 表示无新版本，status=200 表示有新版本。 */
  async checkFirmwareUpdate(version) {
    if (!version) {
      throw invalidParameters("\u7248\u672C\u53F7\u4E3A\u7A7A");
    }
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.checkVersion,
      method: "POST",
      parameters: { version },
      acceptedStatuses: [100, 200]
    });
    const status = getResponseStatus(response);
    if (status !== 100 && status !== 200) {
      validateServerResponse(response);
    }
    const result = typeof response.result === "object" && response.result !== null ? response.result : void 0;
    if (status === 200 && (!(result == null ? void 0 : result.version) || !result.download || !result.fileName)) {
      throw new BCLNetworkError("invalid_response", "\u56FA\u4EF6\u7248\u672C\u54CD\u5E94\u7F3A\u5C11\u5FC5\u8981\u5B57\u6BB5");
    }
    return {
      hasNewVersion: status === 200,
      version: result == null ? void 0 : result.version,
      downloadUrl: result == null ? void 0 : result.download,
      fileName: result == null ? void 0 : result.fileName,
      upgradeDescribe: result == null ? void 0 : result.upgradeDescribe,
      message: getResponseMessage(response)
    };
  }
  /** 查询固件版本历史列表，category 会按原生逻辑转成大写。 */
  async getFirmwareVersionList(category) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.firmwareVersionList,
      method: "GET",
      parameters: { category: category.toUpperCase() }
    });
    return (_a = response.result) != null ? _a : [];
  }
  /** 下载固件文件，实际保存能力由平台下载器提供。 */
  async downloadFirmware(url, fileName, destinationPath, onProgress) {
    if (!url || !fileName || !destinationPath) {
      throw invalidParameters("\u4E0B\u8F7D\u53C2\u6570\u4E0D\u80FD\u4E3A\u7A7A");
    }
    if (!this.downloader) {
      throw new BCLNetworkError("network_error", "\u5F53\u524D\u672A\u914D\u7F6E\u56FA\u4EF6\u4E0B\u8F7D\u5668\uFF0C\u8BF7\u6CE8\u5165 downloader\u3002");
    }
    return this.downloader.download({ url, fileName, destinationPath, onProgress });
  }
  /** 获取用户活动时间线；入参为秒级时间戳，返回项中的时间为毫秒。 */
  async getTimeline(startTime, endTime) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.timeline,
      method: "POST",
      parameters: { startTime, endTime },
      useURLParameters: true
    });
    return (_a = response.result) != null ? _a : [];
  }
  /** 原生命名兼容入口：查询时间线，时间参数使用秒级 Unix 时间戳。 */
  async queryTimelineData(startTime, endTime) {
    var _a, _b;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.timeline,
      method: "POST",
      parameters: compactParameters({ startTime, endTime }),
      useURLParameters: true
    });
    return (_b = (_a = response.result) != null ? _a : response.data) != null ? _b : [];
  }
  /** 根据 MAC 地址查询服务端设备信息。 */
  async getDeviceByMac(macAddress) {
    var _a;
    if (!macAddress) throw invalidParameters("macAddress\u4E0D\u80FD\u4E3A\u7A7A");
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.getDeviceByMac,
      method: "GET",
      parameters: { mac: macAddress }
    });
    const result = (_a = response.result) != null ? _a : response.data;
    return typeof result === "object" && result !== null ? result : null;
  }
  /** 保存用户卡路里、距离、步数和运动时长目标。 */
  async saveUserTarget(target) {
    const parameters = compactParameters(target);
    if (Object.keys(parameters).length === 0) throw invalidParameters("\u7528\u6237\u76EE\u6807\u5B57\u6BB5\u4E0D\u80FD\u4E3A\u7A7A");
    await this.httpClient.request({
      path: API_ENDPOINTS.saveUserTarget,
      method: "POST",
      parameters
    });
  }
  /** 查询当前用户或亲情账户用户的目标设置。 */
  async getUserTarget(userId) {
    var _a;
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.getUserTarget,
      method: "GET",
      parameters: compactParameters({ userId })
    });
    const result = (_a = response.result) != null ? _a : response.data;
    return typeof result === "object" && result !== null ? result : null;
  }
  /** 获取用户最新一条历史数据；服务端 result 为空时返回 null。 */
  async loadUserLatestHistory() {
    const response = await this.httpClient.request({
      path: API_ENDPOINTS.loadUserLatestHistory,
      method: "GET"
    });
    return typeof response.result === "object" && response.result !== null ? response.result : null;
  }
  async uploadMeasureRecord(mac, testType, waveData) {
    const compressedWaveForm = await this.compressWaveData(formatWaveData(waveData));
    return this.httpClient.request({
      path: API_ENDPOINTS.uploadMeasureRecord,
      method: "POST",
      parameters: {
        mac,
        testType,
        compressedWaveForm
      }
    });
  }
};
function compactParameters(values) {
  return Object.fromEntries(Object.entries(values).filter(([, value]) => value !== void 0 && value !== null));
}
function toHealthQueryParameters(query, includeMac = false) {
  return compactParameters({
    mac: includeMac && "macAddress" in query ? query.macAddress : void 0,
    startTime: query.startTime === void 0 ? void 0 : Math.trunc(query.startTime),
    endTime: query.endTime === void 0 ? void 0 : Math.trunc(query.endTime),
    userId: query.userId
  });
}
async function createMultipartFileBody(fileData, fileName, mimeType) {
  const boundary = `----BCLRingSDK${Date.now().toString(16)}${Math.random().toString(16).slice(2)}`;
  const escapedFileName = fileName.replace(/[\r\n"]/g, "_");
  const header = `--${boundary}\r
Content-Disposition: form-data; name="file"; filename="${escapedFileName}"\r
Content-Type: ${mimeType}\r
\r
`;
  const footer = `\r
--${boundary}--\r
`;
  const fileBytes = await toUint8Array(fileData);
  const headerBytes = encodeUtf83(header);
  const footerBytes = encodeUtf83(footer);
  const body = new Uint8Array(headerBytes.length + fileBytes.length + footerBytes.length);
  body.set(headerBytes, 0);
  body.set(fileBytes, headerBytes.length);
  body.set(footerBytes, headerBytes.length + fileBytes.length);
  return { boundary, body: body.buffer };
}
async function toUint8Array(data) {
  if (data instanceof ArrayBuffer) return new Uint8Array(data);
  if (typeof Blob !== "undefined" && data instanceof Blob) return new Uint8Array(await data.arrayBuffer());
  if (ArrayBuffer.isView(data)) return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
  throw invalidParameters("\u4E0D\u652F\u6301\u7684\u6587\u4EF6\u6570\u636E\u7C7B\u578B");
}
function encodeUtf83(value) {
  if (typeof TextEncoder !== "undefined") return new TextEncoder().encode(value);
  const escaped = unescape(encodeURIComponent(value));
  const bytes = new Uint8Array(escaped.length);
  for (let index = 0; index < escaped.length; index += 1) bytes[index] = escaped.charCodeAt(index);
  return bytes;
}
function formatWaveData(waveData) {
  return waveData.map((point) => {
    const normalized = normalizeWaveDataPoint(point);
    return `red:${normalized.red};ied:${normalized.infrared};accX:${normalized.accX};accY:${normalized.accY};accZ:${normalized.accZ}\r
`;
  }).join("");
}
function normalizeWaveDataPoint(point) {
  if (Array.isArray(point)) {
    return {
      red: point[0],
      infrared: point[1],
      accX: point[2],
      accY: point[3],
      accZ: point[4]
    };
  }
  return point;
}
function parseMeasureResult(result) {
  if (!result) {
    throw new BCLNetworkError("invalid_response", "\u6D4B\u91CF\u7ED3\u679C\u4E3A\u7A7A");
  }
  if (result.includes("\u8BA1\u7B97\u51FA\u9519")) {
    throw serverError(200, result);
  }
  try {
    return JSON.parse(result);
  } catch (error) {
    throw new BCLNetworkError("invalid_response", "\u6D4B\u91CF\u7ED3\u679CJSON\u89E3\u6790\u5931\u8D25", { cause: error });
  }
}
function toNumber(value) {
  if (value === void 0 || value === "") {
    return void 0;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : void 0;
}

// packages/protocol-core/src/errors.ts
var ProtocolError2 = class extends Error {
  constructor(message) {
    super(message);
    this.name = "ProtocolError";
  }
};

// packages/protocol-core/src/ota/apollo.ts
var APOLLO_OTA_SERVICE_UUID2 = "00002760-08C2-11E1-9073-0E8AC72E1001";
var APOLLO_OTA_WRITE_UUID2 = "00002760-08C2-11E1-9073-0E8AC72E0001";
var APOLLO_OTA_NOTIFY_UUID2 = "00002760-08C2-11E1-9073-0E8AC72E0002";
var APOLLO_HEADER_SIZE2 = 48;
function parseApolloFirmware2(firmware) {
  if (!(firmware instanceof Uint8Array) || firmware.length <= APOLLO_HEADER_SIZE2) {
    throw new ProtocolError2("Apollo \u56FA\u4EF6\u5FC5\u987B\u5305\u542B 48 \u5B57\u8282\u5934\u548C\u975E\u7A7A\u6B63\u6587");
  }
  const bodySize = new DataView(firmware.buffer, firmware.byteOffset, firmware.byteLength).getUint32(8, true);
  if (bodySize === 0 || bodySize !== firmware.length - APOLLO_HEADER_SIZE2) {
    throw new ProtocolError2("Apollo \u56FA\u4EF6\u58F0\u660E\u7684\u6B63\u6587\u957F\u5EA6\u4E0E\u5B9E\u9645\u6587\u4EF6\u4E0D\u4E00\u81F4");
  }
  return { header: firmware.slice(0, APOLLO_HEADER_SIZE2), body: firmware.slice(APOLLO_HEADER_SIZE2), bodySize };
}

// packages/protocol-core/src/byte-reader.ts
var ByteReader2 = class {
  constructor(bytes) {
    this.bytes = bytes;
    this.offset = 0;
  }
  /** 当前还未读取的字节数。 */
  get remaining() {
    return this.bytes.byteLength - this.offset;
  }
  /** 读取 1 字节无符号整数。 */
  readUint8() {
    this.ensure(1);
    const value = this.bytes[this.offset];
    this.offset += 1;
    return value;
  }
  /** 读取 1 字节有符号整数。 */
  readInt8() {
    const value = this.readUint8();
    return value > 127 ? value - 256 : value;
  }
  /** 读取 4 字节小端无符号整数。 */
  readUint32Le() {
    this.ensure(4);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8 | this.bytes[this.offset + 2] << 16 | this.bytes[this.offset + 3] * 16777216;
    this.offset += 4;
    return value >>> 0;
  }
  /** 读取 2 字节小端无符号整数。 */
  readUint16Le() {
    this.ensure(2);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8;
    this.offset += 2;
    return value;
  }
  /** 读取 2 字节小端有符号整数。 */
  readInt16Le() {
    this.ensure(2);
    const value = this.bytes[this.offset] | this.bytes[this.offset + 1] << 8;
    this.offset += 2;
    return value >= 32768 ? value - 65536 : value;
  }
  /** 读取 4 字节小端有符号整数。 */
  readInt32Le() {
    const value = this.readUint32Le();
    return value > 2147483647 ? value - 4294967296 : value;
  }
  /** 读取 8 字节小端无符号整数，并限制在 JavaScript 安全整数范围内。 */
  readUint64Le() {
    this.ensure(8);
    let value = BigInt(0);
    for (let i = 7; i >= 0; i -= 1) {
      value = value << BigInt(8) | BigInt(this.bytes[this.offset + i]);
    }
    this.offset += 8;
    const numberValue = Number(value);
    if (!Number.isSafeInteger(numberValue)) {
      throw new ProtocolError2("uint64 value exceeds JavaScript safe integer range.");
    }
    return numberValue;
  }
  /** 读取固定长度 ASCII 字符串。 */
  readAscii(length) {
    this.ensure(length);
    let value = "";
    for (let i = 0; i < length; i += 1) {
      value += String.fromCharCode(this.bytes[this.offset + i]);
    }
    this.offset += length;
    return value;
  }
  ensure(length) {
    if (this.remaining < length) {
      throw new ProtocolError2("Packet data is shorter than expected.");
    }
  }
};

// packages/protocol-core/src/byte-writer.ts
var ByteWriter2 = class {
  constructor() {
    this.bytes = [];
  }
  /** 写入 1 字节无符号整数。 */
  writeUint8(value) {
    assertIntegerInRange2(value, 0, 255, "uint8");
    this.bytes.push(value);
    return this;
  }
  /** 写入 1 字节有符号整数。 */
  writeInt8(value) {
    assertIntegerInRange2(value, -128, 127, "int8");
    this.bytes.push(value < 0 ? value + 256 : value);
    return this;
  }
  /** 写入 4 字节小端无符号整数。 */
  writeUint32Le(value) {
    assertIntegerInRange2(value, 0, 4294967295, "uint32");
    this.bytes.push(value & 255, value >>> 8 & 255, value >>> 16 & 255, Math.floor(value / 16777216) & 255);
    return this;
  }
  /** 写入 8 字节小端无符号整数。 */
  writeUint64Le(value) {
    if (typeof value === "number" && (!Number.isSafeInteger(value) || value < 0)) {
      throw new ProtocolError2("uint64 value is out of range.");
    }
    const bigValue = typeof value === "bigint" ? value : BigInt(value);
    if (bigValue < BigInt(0) || bigValue > BigInt("0xffffffffffffffff")) {
      throw new ProtocolError2("uint64 value is out of range.");
    }
    for (let i = 0; i < 8; i += 1) {
      this.bytes.push(Number(bigValue >> BigInt(i * 8) & BigInt(255)));
    }
    return this;
  }
  /** 输出已写入的完整字节数组。 */
  toBytes() {
    return new Uint8Array(this.bytes);
  }
};
function assertIntegerInRange2(value, min, max, typeName) {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new ProtocolError2(`${typeName} value is out of range.`);
  }
}

// packages/protocol-core/src/packet.ts
function createPacket2(frameId, cmd, subcmd, data = new Uint8Array()) {
  assertByte2(frameId, "frameId");
  assertByte2(cmd, "cmd");
  assertByte2(subcmd, "subcmd");
  return {
    frameType: 0,
    frameId,
    cmd,
    subcmd,
    data
  };
}
function encodePacket2(packet) {
  assertByte2(packet.frameType, "frameType");
  assertByte2(packet.frameId, "frameId");
  assertByte2(packet.cmd, "cmd");
  assertByte2(packet.subcmd, "subcmd");
  if (packet.data.byteLength > 240) {
    throw new ProtocolError2("Packet data must not exceed 240 bytes.");
  }
  const out = new Uint8Array(4 + packet.data.byteLength);
  out[0] = packet.frameType;
  out[1] = packet.frameId;
  out[2] = packet.cmd;
  out[3] = packet.subcmd;
  out.set(packet.data, 4);
  return out;
}
function assertPacketKind2(packet, cmd, subcmd) {
  if (packet.cmd !== cmd || packet.subcmd !== subcmd) {
    throw new ProtocolError2(`Unexpected packet kind: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
  }
}
function assertByte2(value, name) {
  if (!Number.isInteger(value) || value < 0 || value > 255) {
    throw new ProtocolError2(`${name} must be a byte.`);
  }
}

// packages/protocol-core/src/codec-utils.ts
function assertResponsePacket2(packet, cmd, subcmd, dataLength) {
  if (packet.frameType !== 0) {
    throw new ProtocolError2(`Unexpected frameType: 0x${packet.frameType.toString(16)}.`);
  }
  assertPacketKind2(packet, cmd, subcmd);
  if (packet.data.byteLength !== dataLength) {
    throw new ProtocolError2(`Unexpected data length: expected ${dataLength}, got ${packet.data.byteLength}.`);
  }
}

// packages/protocol-core/src/hex.ts
function bytesToHex3(bytes) {
  let hex = "";
  for (let i = 0; i < bytes.byteLength; i += 1) {
    hex += bytes[i].toString(16).padStart(2, "0");
  }
  return hex;
}

// packages/protocol-core/src/ring-history-data.ts
var CMD_RING_DATA4 = 54;
var SUBCMD_SYNC_UNUPLOADED2 = 0;
var SUBCMD_SYNC_ALL2 = 1;
var SUBCMD_NEGATIVE_RESPONSE3 = 255;
var EMPTY_TIMESTAMP2 = 0;
var BUSY_TOTAL_NUMBER2 = 4294967295;
var BASE_RECORD_LENGTH2 = 17;
var syncUnuploadedHistoryDataCodec2 = createHistorySyncCodec2(
  SUBCMD_SYNC_UNUPLOADED2,
  "unuploaded"
);
var syncAllHistoryDataCodec2 = createHistorySyncCodec2(
  SUBCMD_SYNC_ALL2,
  "all"
);
function isHistorySyncTerminal2(event) {
  return event.status === "completed" || event.status === "no_data" || event.status === "error";
}
function ringDataNegativeMessage2(errorCode) {
  if (errorCode === 0) {
    return "\u8BBE\u5907\u6B63\u5728\u6D4B\u91CF\u4E2D\uFF0C\u6682\u65F6\u65E0\u6CD5\u64CD\u4F5C\u5386\u53F2\u6570\u636E";
  }
  if (errorCode === 1) {
    return "\u8BBE\u5907\u6B63\u5728\u4E0A\u4F20\u5386\u53F2\u8BB0\u5F55";
  }
  if (errorCode === 2) {
    return "\u8BBE\u5907\u6B63\u5728\u5220\u9664\u5386\u53F2\u8BB0\u5F55";
  }
  if (errorCode === 3) {
    return "\u8BBE\u5907\u6587\u4EF6\u7CFB\u7EDF\u635F\u574F";
  }
  return `\u6212\u6307\u5185\u6570\u636E\u64CD\u4F5C\u5931\u8D25\uFF0C\u9519\u8BEF\u7801 ${errorCode}`;
}
function createHistorySyncCodec2(subcmd, kind) {
  return {
    cmd: CMD_RING_DATA4,
    subcmd,
    encode(request, frameId) {
      var _a;
      return createPacket2(frameId, this.cmd, this.subcmd, encodeTimestamp2((_a = request == null ? void 0 : request.timestamp) != null ? _a : EMPTY_TIMESTAMP2));
    },
    decode(packet) {
      if (packet.cmd !== CMD_RING_DATA4) {
        throw new ProtocolError2(`Unexpected packet kind: cmd=0x${packet.cmd.toString(16)}, subcmd=0x${packet.subcmd.toString(16)}.`);
      }
      if (packet.subcmd === SUBCMD_NEGATIVE_RESPONSE3) {
        return decodeNegativeResponse3(packet, kind);
      }
      assertPacketKind2(packet, this.cmd, this.subcmd);
      return decodeHistorySyncEvent2(packet, kind);
    }
  };
}
function encodeTimestamp2(timestamp) {
  if (!Number.isInteger(timestamp) || timestamp < 0 || timestamp > 4294967295) {
    throw new ProtocolError2("history sync timestamp must be uint32 seconds.");
  }
  return new Uint8Array([
    timestamp & 255,
    timestamp >> 8 & 255,
    timestamp >> 16 & 255,
    Math.floor(timestamp / 16777216) & 255
  ]);
}
function decodeHistorySyncEvent2(packet, kind) {
  const rawHex = bytesToHex3(encodePacket2(packet));
  if (packet.data.byteLength < 8) {
    throw new ProtocolError2(`Unexpected history data length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader2(packet.data);
  const totalNumber = reader.readUint32Le();
  const sequence = reader.readUint32Le();
  if (totalNumber === 0) {
    return {
      type: "no_data",
      kind,
      status: "no_data",
      totalNumber,
      sequence,
      progress: 100,
      rawHex
    };
  }
  if (totalNumber === BUSY_TOTAL_NUMBER2) {
    return {
      type: "busy",
      kind,
      status: "error",
      totalNumber,
      sequence,
      progress: 0,
      message: "\u8BBE\u5907\u7E41\u5FD9\uFF0C\u6682\u65F6\u65E0\u6CD5\u540C\u6B65\u5386\u53F2\u6570\u636E",
      rawHex
    };
  }
  if (packet.data.byteLength < 8 + BASE_RECORD_LENGTH2) {
    throw new ProtocolError2(`Unexpected history record data length: ${packet.data.byteLength}.`);
  }
  const record = decodeHistoryRecord2(packet, kind, totalNumber, sequence);
  return {
    type: "record",
    kind,
    status: record.progress >= 100 ? "completed" : "syncing",
    totalNumber,
    sequence,
    progress: record.progress,
    record,
    rawHex
  };
}
function decodeHistoryRecord2(packet, _kind, totalNumber, sequence) {
  const rawHex = bytesToHex3(encodePacket2(packet));
  const reader = new ByteReader2(packet.data.slice(8));
  const timestamp = reader.readUint32Le();
  const stepCount = reader.readUint16Le();
  const heartRate = reader.readUint8();
  const bloodOxygen = reader.readUint8();
  const heartRateVariability = reader.readUint8();
  const stressIndex = reader.readUint8();
  const temperatureRaw = reader.readInt16Le();
  const activityIntensity = reader.readUint8();
  const sleepType = reader.readUint8();
  const piReserved = reader.readUint8();
  const resReserved = reader.readUint8();
  const arrayCount = reader.readUint8();
  const arrayValues = readUint16Array2(reader, arrayCount);
  const extensionOffset = 8 + BASE_RECORD_LENGTH2 + arrayCount * 2;
  const rawExtensionHex = bytesToHex3(packet.data.slice(extensionOffset));
  const extensionFields = readExtensionFields2(reader);
  return {
    totalNumber,
    sequence,
    progress: calculateProgress2(totalNumber, sequence),
    timestamp,
    timestampMs: timestamp * 1e3,
    stepCount,
    heartRate,
    bloodOxygen,
    heartRateVariability,
    stressIndex,
    temperatureRaw,
    temperatureCelsius: temperatureRaw / 100,
    activityIntensity,
    sleepType,
    piReserved,
    resReserved,
    arrayCount,
    arrayValues,
    rrIntervals: arrayCount === 4 ? [] : arrayValues,
    sleepFeatureValues: arrayCount === 4 ? arrayValues : [],
    extensionFields,
    rawExtensionHex,
    extensions: parseExtensionFields2(extensionFields),
    rawDataHex: bytesToHex3(packet.data),
    rawHex
  };
}
function readUint16Array2(reader, count) {
  const values = [];
  for (let i = 0; i < count; i += 1) {
    values.push(reader.readUint16Le());
  }
  return values;
}
function readExtensionFields2(reader) {
  const fields = [];
  while (reader.remaining > 0) {
    const length = reader.readUint8();
    if (length === 0) {
      break;
    }
    if (reader.remaining < 1) {
      fields.push({
        type: -1,
        length,
        data: [],
        rawHex: "",
        truncated: true
      });
      break;
    }
    const type = reader.readUint8();
    const valueLength = Math.max(0, length - 1);
    const truncated = reader.remaining < valueLength;
    const data = readRawBytes2(reader, Math.min(valueLength, reader.remaining));
    fields.push({
      type,
      length,
      data,
      rawHex: bytesToHex3(new Uint8Array(data)),
      truncated: truncated || void 0
    });
    if (truncated) {
      break;
    }
  }
  return fields;
}
function readRawBytes2(reader, length) {
  const values = [];
  for (let i = 0; i < length; i += 1) {
    values.push(reader.readUint8());
  }
  return values;
}
function parseExtensionFields2(fields) {
  const parsed = {};
  for (const field of fields) {
    parseExtensionField2(field, parsed);
  }
  return parsed;
}
function parseExtensionField2(field, parsed) {
  if (field.truncated) {
    return;
  }
  const data = new Uint8Array(field.data);
  const reader = new ByteReader2(data);
  switch (field.type) {
    case 1:
      parsed.measureType = readOptionalUint82(reader);
      break;
    case 2:
      parsed.periodStepCount = readOptionalUint162(reader);
      break;
    case 3:
      parsed.runningFlag = readOptionalUint82(reader);
      break;
    case 4:
      parsed.batteryLevel = readOptionalUint82(reader);
      break;
    case 5:
      parsed.batteryVoltageRaw = readOptionalUint162(reader);
      parsed.batteryVoltage = parsed.batteryVoltageRaw === void 0 ? void 0 : parsed.batteryVoltageRaw / 1e3;
      break;
    case 6:
      parsed.notWearingReason = readOptionalUint82(reader);
      break;
    case 7:
      parsed.calibrationFlag = readOptionalUint82(reader);
      break;
    case 8:
      parsed.ambientLight = readOptionalUint82(reader);
      break;
    case 9:
      parsed.temperatures = parseUint16ListWithCount2(data).map((value) => signedInt162(value) / 100);
      break;
    case 10:
      parsed.maxStepFrequency = field.data[0];
      parsed.minStepFrequency = field.data[1];
      break;
    case 11:
      parsed.respiratoryRate = field.data[0];
      parsed.respiratoryConfidence = field.data[1];
      break;
    case 12:
      parsed.motionState = readOptionalUint82(reader);
      break;
    case 13:
      parsed.totalCalories = readOptionalUint162(reader);
      parsed.basalCalories = readOptionalUint162(reader);
      parsed.activeCalories = readOptionalUint162(reader);
      break;
    case 14:
      parsed.hardAdt = readOptionalUint162(reader);
      break;
    case 15:
      parsed.diastolicPressure = field.data[0];
      parsed.systolicPressure = field.data[1];
      break;
    case 16:
      parsed.extendedStepCount = readOptionalUint322(reader);
      break;
    case 17:
      parsed.extendedHeartRate = readOptionalUint82(reader);
      break;
    case 18:
      parsed.extendedBloodOxygen = readOptionalUint82(reader);
      break;
    case 19:
      parsed.extendedHeartRateVariability = readOptionalUint82(reader);
      break;
    case 20:
      parsed.extendedStressIndex = readOptionalUint82(reader);
      break;
    case 21:
      parsed.extendedActivityIntensity = readOptionalUint82(reader);
      break;
    case 22:
      parsed.extendedRRIntervals = parseUint16ListWithCount2(data);
      break;
  }
}
function parseUint16ListWithCount2(data) {
  if (data.byteLength === 0) {
    return [];
  }
  const count = data[0];
  const reader = new ByteReader2(data.slice(1));
  const values = [];
  const readableCount = Math.min(count, Math.floor(reader.remaining / 2));
  for (let i = 0; i < readableCount; i += 1) {
    values.push(reader.readUint16Le());
  }
  return values;
}
function readOptionalUint82(reader) {
  return reader.remaining >= 1 ? reader.readUint8() : void 0;
}
function readOptionalUint162(reader) {
  return reader.remaining >= 2 ? reader.readUint16Le() : void 0;
}
function readOptionalUint322(reader) {
  return reader.remaining >= 4 ? reader.readUint32Le() : void 0;
}
function signedInt162(value) {
  return value >= 32768 ? value - 65536 : value;
}
function calculateProgress2(totalNumber, sequence) {
  if (totalNumber <= 0) {
    return 0;
  }
  const completed = sequence <= 0 ? sequence + 1 : sequence;
  return Math.min(100, Math.max(0, Math.floor(completed / totalNumber * 100)));
}
function decodeNegativeResponse3(packet, kind) {
  var _a;
  const errorCode = (_a = packet.data[0]) != null ? _a : 255;
  return {
    type: "negative_response",
    kind,
    status: "error",
    totalNumber: 0,
    sequence: 0,
    progress: 0,
    errorCode,
    message: ringDataNegativeMessage2(errorCode),
    rawHex: bytesToHex3(encodePacket2(packet))
  };
}

// packages/protocol-core/src/app-composite-events.ts
var CMD_APP_COMPOSITE2 = 160;
var CMD_RING_DATA5 = 54;
var SUBCMD_BIND2 = 0;
var SUBCMD_CONNECT2 = 1;
var SUBCMD_REFRESH2 = 2;
var SUBCMD_NEGATIVE_RESPONSE4 = 255;
var appCompositeBindCodec2 = createAppCompositeCodec2(
  SUBCMD_BIND2,
  "bind"
);
var appCompositeConnectCodec2 = createAppCompositeCodec2(
  SUBCMD_CONNECT2,
  "connect"
);
var appCompositeRefreshCodec2 = createAppCompositeCodec2(
  SUBCMD_REFRESH2,
  "refresh"
);
function createAppCompositeCodec2(subcmd, kind) {
  return {
    cmd: CMD_APP_COMPOSITE2,
    subcmd,
    encode(request, frameId) {
      return createPacket2(frameId, this.cmd, this.subcmd, encodeAppCompositeRequest2(request, kind));
    },
    decode(packet) {
      if (packet.cmd === CMD_RING_DATA5) {
        const historyCodec = packet.subcmd === 1 ? syncAllHistoryDataCodec2 : syncUnuploadedHistoryDataCodec2;
        const history = historyCodec.decode(packet);
        return {
          type: "history",
          kind,
          history,
          isTerminal: isHistorySyncTerminal2(history),
          isSuccess: history.status === "completed" || history.status === "no_data"
        };
      }
      if (packet.cmd === CMD_APP_COMPOSITE2 && packet.subcmd === SUBCMD_NEGATIVE_RESPONSE4) {
        return decodeNegativeResponse4(packet, kind);
      }
      assertPacketKind2(packet, this.cmd, this.subcmd);
      return {
        type: "device_info",
        kind,
        deviceInfo: decodeDeviceInfo2(packet),
        isTerminal: kind === "bind",
        isSuccess: true
      };
    }
  };
}
function encodeAppCompositeRequest2(request, kind) {
  var _a, _b, _c;
  const timestampMs = (_a = request == null ? void 0 : request.timestampMs) != null ? _a : Date.now();
  const timezone = (_b = request == null ? void 0 : request.timezone) != null ? _b : 8;
  const writer = new ByteWriter2();
  writeUint48Le2(writer, timestampMs);
  writer.writeUint8(0).writeUint8(0).writeInt8(timezone).writeUint8(1);
  if (kind !== "bind") {
    writer.writeUint32Le((_c = request == null ? void 0 : request.filterTimestamp) != null ? _c : 0);
  }
  return writer.toBytes();
}
function writeUint48Le2(writer, value) {
  if (!Number.isSafeInteger(value) || value < 0 || value > 281474976710655) {
    throw new ProtocolError2("app composite timestampMs must be a uint48 safe integer.");
  }
  let rest = value;
  for (let i = 0; i < 6; i += 1) {
    writer.writeUint8(rest % 256);
    rest = Math.floor(rest / 256);
  }
}
function decodeDeviceInfo2(packet) {
  if (packet.data.byteLength < 60) {
    throw new ProtocolError2(`Unexpected app composite device info length: ${packet.data.byteLength}.`);
  }
  const reader = new ByteReader2(packet.data);
  const firmwareVersion = trimVersion3(reader.readAscii(10));
  const hardwareVersion = trimVersion3(reader.readAscii(10));
  const batteryLevel = reader.readUint8();
  const chargingState = reader.readUint8();
  const collectInterval = reader.readUint32Le();
  const stepCount = reader.readUint16Le();
  const selfInspectionFlag = reader.readUint16Le();
  const hidSupported = reader.readUint8() === 1;
  const hid = hidSupported && packet.data.byteLength >= 50 ? readHidCapabilities2(packet.data) : void 0;
  const features = readFeatureFlags2(packet.data);
  const goMore = readGoMoreUserInfo2(packet.data);
  return {
    firmwareVersion,
    hardwareVersion,
    batteryLevel,
    chargingState,
    collectInterval,
    stepCount,
    selfInspectionFlag,
    hidSupported,
    hid,
    features,
    goMore,
    extraHex: packet.data.byteLength > 75 ? bytesToHex3(packet.data.slice(75)) : "",
    rawHex: bytesToHex3(encodePacket2(packet))
  };
}
function readHidCapabilities2(data) {
  var _a, _b, _c, _d, _e;
  const touch = (_a = data[31]) != null ? _a : 0;
  const gesture = (_b = data[39]) != null ? _b : 0;
  return {
    photo: (touch & 1) !== 0,
    shortVideo: (touch & 2) !== 0,
    music: (touch & 4) !== 0,
    ppt: (touch & 8) !== 0,
    audioUpload: (touch & 16) !== 0,
    pinchPhoto: (gesture & 1) !== 0,
    pinchShortVideo: (gesture & 2) !== 0,
    pinchMusic: (gesture & 4) !== 0,
    pinchPpt: (gesture & 8) !== 0,
    snapPhoto: (gesture & 16) !== 0,
    touchHidMode: (_c = data[47]) != null ? _c : 0,
    gestureHidMode: (_d = data[48]) != null ? _d : 0,
    systemType: (_e = data[49]) != null ? _e : 0
  };
}
function readFeatureFlags2(data) {
  return {
    heartRateCurve: boolByte2(data[50]),
    bloodOxygenCurve: boolByte2(data[51]),
    heartRateVariabilityCurve: boolByte2(data[52]),
    stressCurve: boolByte2(data[53]),
    temperatureCurve: boolByte2(data[54]),
    femaleHealth: boolByte2(data[55]),
    vibrationAlarm: boolByte2(data[56]),
    ecg: boolByte2(data[57]),
    microphone: boolByte2(data[58]),
    sportMode: boolByte2(data[59]),
    bloodPressureMeasurement: boolByte2(data[60]),
    bloodGlucoseMeasurement: boolByte2(data[61]),
    fileSystem: boolByte2(data[62]),
    goMoreSleepAlgorithm: boolByte2(data[63]),
    bloodPressureCurve: boolByte2(data[72]),
    hidServiceEnabled: boolByte2(data[74])
  };
}
function readGoMoreUserInfo2(data) {
  if (data.byteLength < 64) {
    return void 0;
  }
  const maxHeartRateRaw = data.byteLength >= 70 ? new ByteReader2(data.slice(68, 70)).readInt16Le() : void 0;
  return {
    age: data[64],
    gender: data[65],
    height: data[66],
    weight: data[67],
    maxHeartRate: maxHeartRateRaw === void 0 || maxHeartRateRaw === -1 ? void 0 : maxHeartRateRaw,
    restingHeartRate: data[70] === void 0 || data[70] === 255 ? void 0 : data[70],
    maxOxygenUptake: data[71] === void 0 || data[71] === 255 ? void 0 : data[71],
    authStatus: data[73]
  };
}
function decodeNegativeResponse4(packet, kind) {
  var _a;
  const errorCode = (_a = packet.data[0]) != null ? _a : 255;
  return {
    type: "negative_response",
    kind,
    errorCode,
    message: `App \u590D\u5408\u6307\u4EE4\u5931\u8D25\uFF0C\u9519\u8BEF\u7801 ${errorCode}`,
    rawHex: bytesToHex3(encodePacket2(packet)),
    isTerminal: true,
    isSuccess: false
  };
}
function trimVersion3(value) {
  return value.replace(/[\u0000-\u001f\u007f]/g, "").trim();
}
function boolByte2(value) {
  return value === void 0 ? void 0 : value === 1;
}

// packages/protocol-core/src/version.ts
var CMD_VERSION2 = 17;
var VERSION_LENGTH2 = 10;
var getFirmwareVersionCodec2 = createVersionCodec2(0);
var getHardwareVersionCodec2 = createVersionCodec2(1);
function createVersionCodec2(subcmd) {
  return {
    cmd: CMD_VERSION2,
    subcmd,
    encode(_, frameId) {
      return createPacket2(frameId, this.cmd, this.subcmd);
    },
    decode(packet) {
      assertResponsePacket2(packet, this.cmd, this.subcmd, VERSION_LENGTH2);
      const reader = new ByteReader2(packet.data);
      return {
        version: trimVersion4(reader.readAscii(VERSION_LENGTH2))
      };
    }
  };
}
function trimVersion4(value) {
  return value.replace(/[\u0000 ]+$/g, "");
}

// packages/protocol-core/src/ota/nordic.ts
var NORDIC_DFU_SERVICE_UUID = "0000FE59-0000-1000-8000-00805F9B34FB";
var NORDIC_DFU_CONTROL_UUID = "8EC90001-F315-4F60-9FB8-838830DAEA50";
var NORDIC_DFU_PACKET_UUID = "8EC90002-F315-4F60-9FB8-838830DAEA50";
var NORDIC_DFU_BUTTONLESS_UUID = "8EC90003-F315-4F60-9FB8-838830DAEA50";
var NORDIC_DFU_BUTTONLESS_BONDED_UUID = "8EC90004-F315-4F60-9FB8-838830DAEA50";
var NORDIC_GATT_SERVICE_UUID = "00001801-0000-1000-8000-00805F9B34FB";
var NORDIC_SERVICE_CHANGED_UUID = "00002A05-0000-1000-8000-00805F9B34FB";
function parseNordicManifest(json) {
  const root = JSON.parse(json);
  const manifest = root == null ? void 0 : root.manifest;
  if (!manifest || typeof manifest !== "object" || Array.isArray(manifest) || Object.keys(manifest).length !== 1 || !Object.prototype.hasOwnProperty.call(manifest, "application")) {
    throw new Error("\u4EC5\u652F\u6301 Nordic Secure DFU \u5355 application ZIP\uFF1B\u4E0D\u652F\u6301 SoftDevice/Bootloader \u591A\u955C\u50CF");
  }
  const app = manifest.application;
  return { datFile: safePath(app == null ? void 0 : app.dat_file, ".dat"), binFile: safePath(app == null ? void 0 : app.bin_file, ".bin") };
}
function safePath(value, suffix) {
  if (typeof value !== "string" || !value.toLowerCase().endsWith(suffix) || !/^[a-zA-Z0-9_./ -]+$/.test(value) || value.split("/").some((part) => !part || part === "." || part === "..")) {
    throw new Error(`Nordic manifest \u4E2D\u7684 ${suffix} \u8DEF\u5F84\u65E0\u6548`);
  }
  return value;
}
function parseNordicFirmware2(firmware) {
  if (!((firmware == null ? void 0 : firmware.initPacket) instanceof Uint8Array) || !((firmware == null ? void 0 : firmware.image) instanceof Uint8Array) || firmware.initPacket.length === 0 || firmware.initPacket.length > 65535 || firmware.image.length === 0 || firmware.image.length > 16 * 1024 * 1024) {
    throw new Error("Nordic \u56FA\u4EF6\u9700\u8981\u975E\u7A7A DAT\uFF08\u226465535\uFF09\u548C BIN\uFF08\u226416MiB\uFF09");
  }
  return { initPacket: firmware.initPacket.slice(), image: firmware.image.slice() };
}
function nordicCrc322(data, previous = 0) {
  let crc = (previous ^ 4294967295) >>> 0;
  for (const byte of data) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = crc >>> 1 ^ (crc & 1 ? 3988292384 : 0);
  }
  return (crc ^ 4294967295) >>> 0;
}
function encodeNordicCreate2(type, size) {
  if (type !== 1 && type !== 2 || !Number.isInteger(size) || size <= 0 || size > 4294967295) throw new Error("Nordic \u5BF9\u8C61\u957F\u5EA6\u65E0\u6548");
  const result = new Uint8Array([1, type, 0, 0, 0, 0]);
  new DataView(result.buffer).setUint32(2, size, true);
  return result;
}
function decodeNordicResponse2(data, opcode) {
  var _a;
  if (data.length < 3 || data[0] !== 96 || data[1] !== opcode) throw new Error("Nordic \u63A7\u5236\u70B9\u54CD\u5E94\u5934\u65E0\u6548");
  if (data[2] !== 1) throw new Error(`Nordic \u62D2\u7EDD\u547D\u4EE4 0x${opcode.toString(16)}\uFF0C\u72B6\u6001 0x${data[2].toString(16)}${data[2] === 11 ? `\uFF0C\u6269\u5C55\u7801 ${(_a = data[3]) != null ? _a : "\u7F3A\u5931"}` : ""}`);
  const length = opcode === 6 ? 15 : opcode === 3 ? 11 : 3;
  if (data.length !== length) throw new Error(`Nordic \u54CD\u5E94\u957F\u5EA6\u65E0\u6548\uFF0C\u9884\u671F ${length}\uFF0C\u5B9E\u9645 ${data.length}`);
  return data.slice(3);
}
function encodeNordicBootloaderName2(name) {
  if (!/^[\x21-\x7e]{1,20}$/.test(name)) throw new Error("Nordic \u4E34\u65F6\u5E7F\u64AD\u540D\u5FC5\u987B\u4E3A 1\uFF5E20 \u5B57\u8282 ASCII");
  return new Uint8Array([2, name.length, ...Array.from(name, (c) => c.charCodeAt(0))]);
}
function decodeNordicButtonlessResponse2(data, opcode) {
  if (data.length !== 3 || data[0] !== 32 || data[1] !== opcode) throw new Error("Nordic Buttonless \u54CD\u5E94\u683C\u5F0F\u65E0\u6548");
  return data[2];
}
function nordicBootloaderAddress(deviceId) {
  if (!/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/i.test(deviceId)) return void 0;
  const address = Number.parseInt(deviceId.replace(/:/g, ""), 16);
  if (address >= 281474976710655) return void 0;
  return (address + 1).toString(16).padStart(12, "0").match(/../g).join(":").toUpperCase();
}

// packages/protocol-core/src/ota/phy.ts
var PHY_OTA_SERVICE_UUID = "5833FF01-9B8B-5191-6142-22A4536EF123";
var PHY_OTA_COMMAND_UUID = "5833FF02-9B8B-5191-6142-22A4536EF123";
var PHY_OTA_NOTIFY_UUID = "5833FF03-9B8B-5191-6142-22A4536EF123";
var PHY_OTA_DATA_UUID = "5833FF04-9B8B-5191-6142-22A4536EF123";
var PHY_PACKET_SIZE2 = 237;
var PHY_WINDOW_SIZE2 = 16;
function phyCrc162(data, seed = 0) {
  const table = [
    0,
    52225,
    55297,
    5120,
    61441,
    15360,
    10240,
    58369,
    40961,
    27648,
    30720,
    46081,
    20480,
    39937,
    34817,
    17408
  ];
  let crc = seed & 65535;
  for (const byte of data) {
    crc = crc >>> 4 ^ table[crc & 15] ^ table[byte & 15];
    crc = crc >>> 4 ^ table[crc & 15] ^ table[byte >>> 4];
  }
  return crc & 65535;
}
function parsePhyFirmware2(input) {
  var _a;
  if (input.length > 8 * 1024 * 1024) throw new Error("PHY HEX \u6587\u4EF6\u8D85\u8FC7 8MiB");
  let text = typeof input === "string" ? input : "";
  if (input instanceof Uint8Array) {
    for (let offset = 0; offset < input.length; offset += 8192) text += String.fromCharCode(...input.subarray(offset, offset + 8192));
  }
  const sections = [];
  let current;
  let eof = false;
  let nextFlash = 0;
  const finish = () => {
    if (!current) return;
    if (!current.bytes.length || current.start === void 0) throw new Error("PHY \u5B58\u5728\u7A7A\u5206\u533A");
    const runAddress = current.base + current.start;
    const direct = runAddress >= 285212672 && runAddress <= 285736959;
    const flashAddress = direct ? runAddress : nextFlash;
    const data = new Uint8Array(current.bytes);
    if (flashAddress + data.length > 4294967296 || runAddress + data.length > 4294967296) throw new Error("PHY \u5206\u533A\u5730\u5740\u6EA2\u51FA");
    sections.push({ index: sections.length, runAddress, flashAddress, data, crc: phyCrc162(data) });
    if (!direct) nextFlash += data.length + 8;
    current = void 0;
  };
  for (const [index, raw] of text.split(/\r?\n/).entries()) {
    const line = raw.trim();
    if (!line) continue;
    if (eof) throw new Error(`PHY EOF \u540E\u8FD8\u6709\u8BB0\u5F55\uFF0C\u7B2C ${index + 1} \u884C`);
    if (!/^:(?:[0-9a-fA-F]{2}){5,}$/.test(line)) throw new Error(`PHY HEX \u683C\u5F0F\u9519\u8BEF\uFF0C\u7B2C ${index + 1} \u884C`);
    const bytes = new Uint8Array(line.slice(1).match(/../g).map((v) => parseInt(v, 16)));
    if (bytes.length !== bytes[0] + 5 || bytes.reduce((a, b) => a + b, 0) % 256 !== 0) throw new Error(`PHY HEX \u957F\u5EA6\u6216\u6821\u9A8C\u548C\u9519\u8BEF\uFF0C\u7B2C ${index + 1} \u884C`);
    const length = bytes[0];
    const address = bytes[1] * 256 + bytes[2];
    const type = bytes[3];
    if (type === 4) {
      if (length !== 2 || address !== 0) throw new Error("PHY \u6269\u5C55\u7EBF\u6027\u5730\u5740\u8BB0\u5F55\u65E0\u6548");
      finish();
      current = { base: (bytes[4] * 256 + bytes[5]) * 65536, bytes: [] };
    } else if (type === 0) {
      if (!current || !length || address + length > 65536) throw new Error("PHY \u6570\u636E\u7F3A\u5C11\u5206\u533A\u5934\u6216\u8DE8\u8D8A\u5730\u5740\u8FB9\u754C");
      if (current.next !== void 0 && current.next !== address) throw new Error("PHY \u5206\u533A\u5730\u5740\u4E0D\u8FDE\u7EED\uFF0C\u4E0D\u80FD\u63A8\u6D4B\u586B\u5145\u503C");
      (_a = current.start) != null ? _a : current.start = address;
      current.next = address + length;
      current.bytes.push(...bytes.subarray(4, 4 + length));
    } else if (type === 1 && length === 0 && address === 0) {
      finish();
      eof = true;
    } else throw new Error(`PHY \u6682\u4E0D\u652F\u6301 HEX \u8BB0\u5F55\u7C7B\u578B ${type}`);
  }
  if (!eof || !sections.length || sections.length > 255) throw new Error("PHY \u7F3A\u5C11 EOF\u3001\u6709\u6548\u5206\u533A\u6216\u5206\u533A\u6570\u8D85\u8FC7 255");
  return { sections, totalBytes: sections.reduce((sum, s) => sum + s.data.length, 0) };
}
function encodePhySection2(section) {
  const bytes = new Uint8Array(16);
  const view = new DataView(bytes.buffer);
  bytes.set([2, section.index]);
  view.setUint32(2, section.flashAddress, true);
  view.setUint32(6, section.runAddress, true);
  view.setUint32(10, section.data.length, true);
  view.setUint16(14, section.crc, true);
  return bytes;
}
function decodePhyAck2(data) {
  if (data.length < 2) throw new Error("PHY \u5E94\u7B54\u4E0D\u8DB3 2 \u5B57\u8282");
  if (![129, 132, 135, 133, 131].includes(data[1])) throw new Error(`PHY \u672A\u77E5\u5E94\u7B54 ${data[1]}`);
  return { status: data[0], opcode: data[1] };
}
function isPhyBootAdvertisement2(device) {
  return [device.name, device.localName].some((name) => name == null ? void 0 : name.toLowerCase().includes("pplusota"));
}
function shiftPhyMac2(mac, delta) {
  if (!/^(?:[0-9a-f]{2}:){5}[0-9a-f]{2}$/i.test(mac)) return void 0;
  const value = parseInt(mac.replace(/:/g, ""), 16) + delta;
  if (value < 0 || value > 281474976710655) return void 0;
  return value.toString(16).padStart(12, "0").toUpperCase().match(/../g).join(":");
}
function getPhyBootMac2(data) {
  return data.length >= 8 ? [7, 6, 5, 4, 3, 2].map((i) => data[i].toString(16).padStart(2, "0").toUpperCase()).join(":") : void 0;
}

// packages/transport/src/index.ts
var BleApolloOtaTransport = class {
  constructor(platform, config) {
    this.platform = platform;
    this.config = config;
    var _a, _b, _c;
    this.channel = {
      deviceId: config.deviceId,
      serviceId: (_a = config.serviceId) != null ? _a : APOLLO_OTA_SERVICE_UUID,
      writeCharacteristicId: (_b = config.writeCharacteristicId) != null ? _b : APOLLO_OTA_WRITE_UUID,
      notifyCharacteristicId: (_c = config.notifyCharacteristicId) != null ? _c : APOLLO_OTA_NOTIFY_UUID
    };
  }
  /** 写入方式由 platform 配置为 writeWithoutResponse，不得自动重试分片。 */
  write(data) {
    return this.platform.writeCharacteristic({
      deviceId: this.channel.deviceId,
      serviceId: this.channel.serviceId,
      characteristicId: this.channel.writeCharacteristicId,
      data
    });
  }
  /** 只接受当前 OTA 通知特征，忽略 UUID 大小写差异。 */
  onNotification(callback) {
    return this.platform.onCharacteristicValueChanged((event) => {
      if (event.deviceId === this.channel.deviceId && event.serviceId.toLowerCase() === this.channel.serviceId.toLowerCase() && event.characteristicId.toLowerCase() === this.channel.notifyCharacteristicId.toLowerCase()) {
        callback(event.data);
      }
    });
  }
  /** 复用平台当前连接的断连事件，不主动创建第二条连接。 */
  onDisconnect(callback) {
    return this.config.onDisconnect(callback);
  }
};
var BleNordicOtaTransport = class {
  constructor(control, packet, config) {
    this.control = control;
    this.packet = packet;
    this.config = config;
  }
  /** 控制点始终有响应写入。 */
  writeControl(data) {
    return this.control.writeCharacteristic({
      deviceId: this.config.deviceId,
      serviceId: this.config.serviceId,
      characteristicId: this.config.controlCharacteristicId,
      data
    });
  }
  /** 分片直接发送，不封包、不拆包、不重试。 */
  writePacket(data) {
    return this.packet.writeCharacteristic({
      deviceId: this.config.deviceId,
      serviceId: this.config.serviceId,
      characteristicId: this.config.packetCharacteristicId,
      data
    });
  }
  /** 过滤其他设备、服务或数据特征的通知。 */
  onNotification(callback) {
    return this.control.onCharacteristicValueChanged((event) => {
      if (event.deviceId === this.config.deviceId && normalizeNordicUuid(event.serviceId) === normalizeNordicUuid(this.config.serviceId) && normalizeNordicUuid(event.characteristicId) === normalizeNordicUuid(this.config.controlCharacteristicId)) callback(event.data);
    });
  }
  /** 生命周期由外部连接所有者管理。 */
  onDisconnect(callback) {
    return this.config.onDisconnect(callback);
  }
};
function normalizeNordicUuid(uuid) {
  const value = uuid.toLowerCase();
  return value.length === 4 ? `0000${value}-0000-1000-8000-00805f9b34fb` : value;
}
var BlePhyOtaTransport = class {
  constructor(command, data, config) {
    this.command = command;
    this.data = data;
    this.config = config;
  }
  /** 控制命令固定有响应写入。 */
  writeCommand(bytes) {
    return this.command.writeCharacteristic({
      deviceId: this.config.deviceId,
      serviceId: this.config.serviceId,
      characteristicId: this.config.commandCharacteristicId,
      data: bytes
    });
  }
  /** 每次提交一个完整 PHY 数据报。 */
  writeData(bytes) {
    return this.data.writeCharacteristic({
      deviceId: this.config.deviceId,
      serviceId: this.config.serviceId,
      characteristicId: this.config.dataCharacteristicId,
      data: bytes
    });
  }
  /** 设备、服务、通知特征三者必须同时匹配。 */
  onNotification(callback) {
    return this.command.onCharacteristicValueChanged((event) => {
      if (event.deviceId === this.config.deviceId && event.serviceId.toLowerCase() === this.config.serviceId.toLowerCase() && event.characteristicId.toLowerCase() === this.config.notifyCharacteristicId.toLowerCase()) callback(event.data);
    });
  }
  /** 连接所有权由平台协调器管理。 */
  onDisconnect(callback) {
    return this.config.onDisconnect(callback);
  }
};

// packages/sdk-core/src/ota/nordic-ota.ts
var NordicOtaError2 = class extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
    this.name = "NordicOtaError";
  }
};
function resolveNordicPayloadSize(attMtu) {
  if (attMtu === void 0) return 20;
  if (!Number.isInteger(attMtu) || attMtu < 23 || attMtu > 517) throw new NordicOtaError2("invalid_options", "Nordic ATT MTU \u5FC5\u987B\u4E3A 23\uFF5E517 \u7684\u6574\u6570");
  return Math.floor(Math.min(attMtu - 3, 244) / 4) * 4;
}
var occupied3 = /* @__PURE__ */ new WeakSet();
var NordicOtaUpdater2 = class {
  constructor(transport) {
    this.transport = transport;
  }
  /** 执行单 application 升级；匹配 CRC 的已传输数据可恢复，不自动重发损坏对象。 */
  async start(input, options = {}) {
    var _a, _b, _c, _d, _e;
    if (this.active || occupied3.has(this.transport)) throw new NordicOtaError2("busy", "Nordic \u901A\u9053\u4ECD\u88AB\u5360\u7528");
    const settings = {
      ...options,
      payloadSize: (_a = options.payloadSize) != null ? _a : 20,
      timeoutMs: (_b = options.timeoutMs) != null ? _b : 1e4,
      intervalMs: (_c = options.intervalMs) != null ? _c : 0,
      preparationDelayMs: (_d = options.preparationDelayMs) != null ? _d : 400
    };
    if (!Number.isInteger(settings.payloadSize) || settings.payloadSize < 1 || settings.payloadSize > 244 || [settings.timeoutMs, settings.intervalMs, settings.preparationDelayMs].some((n) => !Number.isFinite(n) || n < 0 || n > 2147483647) || settings.timeoutMs === 0) throw new NordicOtaError2("invalid_options", "Nordic \u5206\u7247\u3001\u8D85\u65F6\u6216\u7B49\u5F85\u53C2\u6570\u65E0\u6548");
    let firmware;
    try {
      firmware = parseNordicFirmware(input);
    } catch (e) {
      throw new NordicOtaError2("invalid_firmware", String(e));
    }
    let stop;
    const stopped = new Promise((_, reject) => {
      stop = reject;
    });
    void stopped.catch(() => {
    });
    let release;
    const idle = new Promise((resolve) => {
      release = resolve;
    });
    const s = {
      done: false,
      state: "preparing",
      offset: 0,
      total: firmware.image.length,
      options: settings,
      writes: /* @__PURE__ */ new Set(),
      unsubscribe: [],
      stopped,
      stop,
      idle,
      release
    };
    this.active = s;
    occupied3.add(this.transport);
    try {
      s.unsubscribe.push(this.transport.onNotification((data) => {
        if (s.done || s.error) return;
        this.debug(s, "notification", data);
        const p = s.pending;
        if (!p) return;
        if (data.length >= 2 && data[0] === 96 && data[1] !== p.opcode) return;
        try {
          const body = decodeNordicResponse(data, p.opcode);
          s.pending = void 0;
          p.resolve(body);
        } catch (e) {
          this.fail(s, new NordicOtaError2("protocol_error", String(e)));
        }
      }));
      s.unsubscribe.push(this.transport.onDisconnect(() => this.fail(s, new NordicOtaError2("disconnected", "Nordic Bootloader \u5DF2\u65AD\u8FDE\uFF1B\u4E0D\u80FD\u4EC5\u51ED\u65AD\u8FDE\u5224\u5B9A\u6210\u529F"))));
      this.progress(s, "preparing");
      await this.command(s, new Uint8Array([2, 0, 0]));
      this.progress(s, "sendingInit");
      await this.sendObjectType(s, 1, firmware.initPacket);
      this.progress(s, "sendingData");
      await this.sendObjectType(s, 2, firmware.image);
      this.assert(s);
      s.done = true;
      this.progress(s, "completed");
      return { protocolCompleted: true, versionVerified: false, acknowledgedBytes: s.offset };
    } catch (e) {
      const error = (_e = s.error) != null ? _e : e instanceof NordicOtaError2 ? e : new NordicOtaError2("protocol_error", String(e));
      s.done = true;
      this.progress(s, error.code === "cancelled" ? "cancelled" : "failed");
      this.debug(s, "error", new Uint8Array(), error.message);
      throw error;
    } finally {
      s.done = true;
      s.pending = void 0;
      for (const off of s.unsubscribe) safe3(off);
      this.release(s);
    }
  }
  /** 停止后续发送，无法撤回平台已提交写入，也不向设备发送回滚命令。 */
  cancel() {
    if (this.active) this.fail(this.active, new NordicOtaError2("cancelled", "Nordic \u5347\u7EA7\u5DF2\u53D6\u6D88"));
  }
  /** 设备锁必须等待所有已提交写入结束后再释放。 */
  whenIdle() {
    var _a, _b;
    return (_b = (_a = this.active) == null ? void 0 : _a.idle) != null ? _b : Promise.resolve();
  }
  /** Select → Create/恢复 → Packet → CRC → Execute，数据 CRC 是整个 BIN 的累计值。 */
  async sendObjectType(s, type, bytes) {
    const selected = await this.command(s, new Uint8Array([6, type]));
    const view = new DataView(selected.buffer, selected.byteOffset, selected.byteLength);
    const max = view.getUint32(0, true);
    let offset = view.getUint32(4, true);
    const crc = view.getUint32(8, true);
    if (!max || type === 1 && bytes.length > max) throw new NordicOtaError2("invalid_firmware", "Nordic \u5BF9\u8C61\u5927\u5C0F\u4E0E Bootloader \u4E0D\u517C\u5BB9");
    let expectedCrc = nordicCrc32(bytes.subarray(0, offset));
    const matches2 = offset <= bytes.length && expectedCrc === crc;
    if (type === 2 && !matches2) throw new NordicOtaError2("resume_mismatch", "Bootloader \u5DF2\u6709\u6570\u636E\u4E0E\u6240\u9009\u56FA\u4EF6 CRC/\u504F\u79FB\u4E0D\u5339\u914D\uFF0C\u8BF7\u5148\u6309\u8BBE\u5907\u6D41\u7A0B\u6062\u590D");
    if (type === 1 && !matches2) {
      offset = 0;
      expectedCrc = 0;
    }
    let recovering = offset > 0;
    while (offset < bytes.length || recovering) {
      this.assert(s);
      const start = offset;
      const end = recovering ? Math.min(bytes.length, type === 1 ? bytes.length : Math.ceil(offset / max) * max) : Math.min(bytes.length, offset + (type === 1 ? bytes.length : max));
      if (!recovering) {
        await this.command(s, encodeNordicCreate(type, end - start));
        if (type === 2) await this.delay(s, s.options.preparationDelayMs);
      }
      for (; offset < end; ) {
        const fragment = bytes.slice(offset, Math.min(end, offset + s.options.payloadSize));
        this.debug(s, "packet", fragment);
        await this.write(s, () => this.transport.writePacket(fragment));
        expectedCrc = nordicCrc32(fragment, expectedCrc);
        offset += fragment.length;
        await this.delay(s, s.options.intervalMs);
      }
      const sum = await this.command(s, new Uint8Array([3]));
      const checksum = new DataView(sum.buffer, sum.byteOffset, sum.byteLength);
      if (checksum.getUint32(0, true) !== offset || checksum.getUint32(4, true) !== expectedCrc) {
        throw new NordicOtaError2("checksum_mismatch", "Nordic \u5BF9\u8C61\u7D2F\u8BA1\u504F\u79FB\u6216 CRC32 \u4E0D\u5339\u914D");
      }
      await this.command(s, new Uint8Array([4]));
      if (type === 2) {
        s.offset = offset;
        this.progress(s, "sendingData");
      }
      recovering = false;
    }
  }
  /** 等待通知先注册，快速 ACK 与写入完成均满足后才进入下一条命令。 */
  async command(s, data) {
    this.assert(s);
    const response = new Promise((resolve, reject) => {
      s.pending = { opcode: data[0], resolve, reject };
    });
    this.debug(s, "control", data);
    const result = await this.bounded(s, Promise.all([response, this.write(s, () => this.transport.writeControl(data))]));
    return result[0];
  }
  /** 跟踪真实写入；超时拒绝上层后仍保持通道互斥，直到平台回调结束。 */
  async write(s, callback) {
    this.assert(s);
    const write = Promise.resolve().then(() => {
      this.assert(s);
      return callback();
    });
    s.writes.add(write);
    void write.then(() => {
      s.writes.delete(write);
      this.release(s);
    }, () => {
      s.writes.delete(write);
      this.release(s);
    });
    try {
      await this.bounded(s, write);
    } catch (e) {
      if (e instanceof NordicOtaError2) throw e;
      throw new NordicOtaError2("write_failed", String(e));
    }
    this.assert(s);
  }
  /** 所有等待可被取消或断连立即唤醒，不把最终重启断连当作 ACK。 */
  async bounded(s, task) {
    let timer;
    const timeout = new Promise((_, reject) => {
      timer = setTimeout(() => {
        const error = new NordicOtaError2("timeout", "Nordic \u5199\u5165\u6216\u54CD\u5E94\u8D85\u65F6");
        this.fail(s, error);
        reject(error);
      }, s.options.timeoutMs);
    });
    try {
      return await Promise.race([task, s.stopped, timeout]);
    } finally {
      clearTimeout(timer);
    }
  }
  /** 节流等待在取消时清理计时器，避免旧循环继续提交分片。 */
  async delay(s, ms) {
    this.assert(s);
    if (!ms) return;
    let timer;
    try {
      await Promise.race([new Promise((resolve) => {
        timer = setTimeout(resolve, ms);
      }), s.stopped]);
    } finally {
      clearTimeout(timer);
    }
    this.assert(s);
  }
  /** 首个错误保留，迟到的通知不能覆盖取消原因。 */
  fail(s, error) {
    var _a;
    if (s.done || s.error) return;
    s.error = error;
    s.stop(error);
    (_a = s.pending) == null ? void 0 : _a.reject(error);
    s.pending = void 0;
  }
  /** 回调重入取消后也必须停止写入。 */
  assert(s) {
    if (s.error) throw s.error;
    if (s.done) throw new NordicOtaError2("cancelled", "\u4F1A\u8BDD\u5DF2\u7ED3\u675F");
  }
  /** 日志与展示异常均不能破坏设备锁清理。 */
  progress(s, state) {
    s.state = state;
    safe3(() => {
      var _a, _b;
      return (_b = (_a = s.options).onProgress) == null ? void 0 : _b.call(_a, { state, totalBytes: s.total, acknowledgedBytes: s.offset, percent: s.offset / s.total * 100 });
    });
  }
  /** 保留原始协议 Hex，供真机与官方日志对照。 */
  debug(s, type, data, message) {
    safe3(() => {
      var _a, _b;
      return (_b = (_a = s.options).debug) == null ? void 0 : _b.call(_a, { type, hex: bytesToHex(data), message });
    });
  }
  /** 直到已提交写入排空才释放当前会话。 */
  release(s) {
    if (!s.done || s.writes.size || this.active !== s) return;
    occupied3.delete(this.transport);
    this.active = void 0;
    s.release();
  }
};
function safe3(callback) {
  try {
    callback();
  } catch (e) {
  }
}

// packages/sdk-core/src/ota/nordic-buttonless.ts
var NordicButtonlessClient = class {
  constructor(transport, debug, timeoutMs = 1e4) {
    this.transport = transport;
    this.debug = debug;
    this.timeoutMs = timeoutMs;
    /** 每次只允许一条指令，取消后仍等待已提交写入排空。 */
    this.pending = false;
    this.cancelled = false;
    this.writes = /* @__PURE__ */ new Set();
  }
  /** SDK14+ 支持临时广播名；仅明确返回 opcode 不支持时允许走旧设备地址策略。 */
  async setName(name) {
    const status = await this.request(encodeNordicBootloaderName(name));
    if (status === 2) return false;
    this.checkStatus(status);
    return true;
  }
  /** 请求当前戒指切换模式；返回只代表 indication 确认，平台还须等待断连和重发现。 */
  async enter() {
    this.checkStatus(await this.request(new Uint8Array([1])));
  }
  /** 取消当前通知等待，不能撤回已提交的平台写入。 */
  cancel() {
    var _a;
    this.cancelled = true;
    (_a = this.interrupt) == null ? void 0 : _a.call(this);
  }
  /** 用于在清理连接或释放设备锁之前等待旧写入结束。 */
  async whenIdle() {
    await Promise.allSettled([...this.writes]);
  }
  /** 先订阅再写入，ACK 与写入成功都满足后才放行下一条命令。 */
  async request(data) {
    if (this.cancelled) throw new Error("Nordic \u6A21\u5F0F\u5207\u6362\u5DF2\u505C\u6B62");
    if (this.pending || this.writes.size) throw new Error("Nordic \u6A21\u5F0F\u5207\u6362\u901A\u9053\u5FD9\u788C");
    this.pending = true;
    let off;
    let timer;
    try {
      let resolve;
      let reject;
      const response = new Promise((ok, fail) => {
        resolve = ok;
        reject = fail;
      });
      void response.catch(() => {
      });
      let stop;
      const stopped = new Promise((_, fail) => {
        stop = fail;
      });
      void stopped.catch(() => {
      });
      this.interrupt = () => stop(new Error("Nordic \u6A21\u5F0F\u5207\u6362\u5DF2\u505C\u6B62"));
      off = this.transport.onNotification((bytes) => {
        this.log("notification", bytes);
        if (bytes.length >= 2 && bytes[0] === 32 && bytes[1] !== data[0]) return;
        try {
          resolve(decodeNordicButtonlessResponse(bytes, data[0]));
        } catch (error) {
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
      this.log("write", data);
      if (this.cancelled) throw new Error("Nordic \u6A21\u5F0F\u5207\u6362\u5DF2\u505C\u6B62");
      const write = Promise.resolve().then(() => {
        if (this.cancelled) throw new Error("Nordic \u6A21\u5F0F\u5207\u6362\u5DF2\u505C\u6B62");
        return this.transport.write(data);
      });
      this.writes.add(write);
      void write.then(() => this.writes.delete(write), () => this.writes.delete(write));
      const timeout = new Promise((_, fail) => {
        timer = setTimeout(() => fail(new Error("Nordic \u6A21\u5F0F\u5207\u6362\u54CD\u5E94\u6216\u5199\u5165\u8D85\u65F6")), this.timeoutMs);
      });
      const result = await Promise.race([Promise.all([response, write]), timeout, stopped]);
      if (this.cancelled) throw new Error("Nordic \u6A21\u5F0F\u5207\u6362\u5DF2\u505C\u6B62");
      return result[0];
    } finally {
      if (timer) clearTimeout(timer);
      off == null ? void 0 : off();
      this.interrupt = void 0;
      this.pending = false;
    }
  }
  /** 设备拒绝时保留原始状态，禁止静默切换其他设备。 */
  checkStatus(status) {
    if (status !== 1) throw new Error(`Nordic Buttonless \u64CD\u4F5C\u5931\u8D25\uFF0C\u72B6\u6001 ${status}`);
  }
  /** 调试异常不影响协议生命周期。 */
  log(type, bytes) {
    var _a;
    try {
      (_a = this.debug) == null ? void 0 : _a.call(this, { type, hex: bytesToHex(bytes) });
    } catch (e) {
    }
  }
};

// examples/shared/nordic-demo.ts
function createNordicDemoState() {
  return {
    busy: false,
    ready: false,
    fileName: "",
    status: "\u8BF7\u9009\u62E9\u5347\u7EA7\u6587\u4EF6",
    percent: 0,
    protocolCompleted: false,
    canRetry: false,
    reconnected: false,
    firmwareVersion: "",
    canReconnect: false
  };
}
var NordicDemoController = class {
  constructor(api, state, changed, log, acquire, getConnectedDevice = () => null, packetTrace, restoreApplication) {
    __publicField(this, "api", api);
    __publicField(this, "state", state);
    __publicField(this, "changed", changed);
    __publicField(this, "log", log);
    __publicField(this, "acquire", acquire);
    __publicField(this, "getConnectedDevice", getConnectedDevice);
    __publicField(this, "packetTrace", packetTrace);
    __publicField(this, "restoreApplication", restoreApplication);
    /** 二进制仅保留内存副本，临时目录读取完立即清理。 */
    __publicField(this, "firmware");
    /** 当前执行器独立于普通戒指 SDK，Bootloader 无业务服务也能连接。 */
    __publicField(this, "updater");
    /** 标记取消/销毁，使准备阶段迟到回调不再发起 BLE 操作。 */
    __publicField(this, "cancelled", false);
    /** 当前任务类型决定后台保护是否需要停止 BLE 流程。 */
    __publicField(this, "operation");
    /** 保留首次取消来源，迟到回调不能覆盖真正原因。 */
    __publicField(this, "stopReason");
    __publicField(this, "disposed", false);
    /** 标准 Buttonless 指令也必须可取消并等待真实写入排空。 */
    __publicField(this, "buttonless");
    /** 绑定模式的 Service Changed 观察跨越重连阶段，结束时统一注销。 */
    __publicField(this, "offServiceChanged");
    /** 取消会立即唤醒扫描、断连和平台准备等待。 */
    __publicField(this, "stoppers", /* @__PURE__ */ new Set());
    /** 仅复用已确认的目标身份；不得在失败后任选附近同名设备。 */
    __publicField(this, "recovery");
    /** 传输结束后保留原应用态目标，失败时只重连，不重新发送固件。 */
    __publicField(this, "applicationToRestore");
    /** 高频原始分片日志按对象/8KiB 批量落盘，避免每片刷新日志 UI 或调用文件桥。 */
    __publicField(this, "packetLogs", []);
    __publicField(this, "packetLogChars", 0);
  }
  /** 聊天选择 ZIP，通过微信解压能力解决原生 ZIP/NordicDFU 依赖。 */
  async chooseZip() {
    await this.run("file", async () => {
      this.firmware = void 0;
      Object.assign(this.state, { ready: false, fileName: "", percent: 0, protocolCompleted: false, reconnected: false, firmwareVersion: "", canReconnect: false });
      this.emit();
      this.status("\u8BF7\u9009\u62E9\u5FAE\u4FE1\u804A\u5929\u4E2D\u7684 ZIP \u5347\u7EA7\u6587\u4EF6");
      let chosen;
      try {
        chosen = await call(this.api, "chooseMessageFile", { count: 1, type: "file", extension: ["zip"] });
      } catch (e) {
        if (/cancel/i.test(errorText(e))) {
          this.status("\u5DF2\u53D6\u6D88\u9009\u62E9\u6587\u4EF6");
          return;
        }
        throw e;
      }
      this.assert();
      const file = chosen.tempFiles[0];
      if (!file || !/\.zip$/i.test(file.name) || !Number.isFinite(file.size) || file.size <= 0 || file.size > 20 * 1024 * 1024) {
        throw new Error("\u8BF7\u9009\u62E9\u4E0D\u8D85\u8FC7 20MiB \u7684 Nordic ZIP \u6587\u4EF6");
      }
      this.status(`\u5DF2\u9009\u62E9 ${file.name}\uFF0C\u6B63\u5728\u89E3\u538B\u5E76\u6821\u9A8C\u6587\u4EF6`);
      const fs = this.api.getFileSystemManager();
      const root = this.api.env.USER_DATA_PATH;
      const targetPath = `${root}/nordic-dfu-${Date.now()}-${Math.random().toString(16).slice(2)}`;
      await call(fs, "mkdir", { dirPath: targetPath, recursive: true });
      try {
        await call(fs, "unzip", { zipFilePath: file.path, targetPath });
        this.assert();
        const manifest = await call(fs, "readFile", { filePath: `${targetPath}/manifest.json`, encoding: "utf8" });
        this.assert();
        const refs = parseNordicManifest(manifest.data);
        const read = async (path, limit) => {
          const result = await call(fs, "stat", { path: `${targetPath}/${path}` });
          this.assert();
          if (result.stats.size <= 0 || result.stats.size > limit) throw new Error(`Nordic \u6587\u4EF6\u5927\u5C0F\u5F02\u5E38\uFF1A${path}`);
          const resultFile = await call(fs, "readFile", { filePath: `${targetPath}/${path}` });
          this.assert();
          return new Uint8Array(resultFile.data);
        };
        const initPacket = await read(refs.datFile, 65535);
        const image = await read(refs.binFile, 16 * 1024 * 1024);
        this.firmware = parseNordicFirmware2({ initPacket, image });
        Object.assign(this.state, { ready: true, fileName: file.name });
        this.log(`Nordic \u6587\u4EF6\u6821\u9A8C\uFF1ADAT ${initPacket.length} \u5B57\u8282\uFF0CBIN ${image.length} \u5B57\u8282\uFF1B\u7B7E\u540D\u7531\u8BBE\u5907\u9A8C\u8BC1`);
        this.status("\u6587\u4EF6\u6821\u9A8C\u901A\u8FC7\uFF0C\u53EF\u4EE5\u5F00\u59CB\u5347\u7EA7");
      } finally {
        await call(fs, "rmdir", { dirPath: targetPath, recursive: true }).catch((e) => this.log(`Nordic \u4E34\u65F6\u76EE\u5F55\u6E05\u7406\u5931\u8D25\uFF1A${errorText(e)}`));
      }
    });
  }
  /** 对当前已连接戒指一键升级；模式切换和 Bootloader 发现均在内部完成。 */
  async start() {
    await this.run("upgrade", async () => {
      var _a, _b, _c, _d, _e, _f;
      const firmware = this.firmware;
      const connected = this.getConnectedDevice();
      if (!firmware) throw new Error("\u8BF7\u5148\u9009\u62E9\u5E76\u6821\u9A8C\u5347\u7EA7\u6587\u4EF6");
      if (!connected && !this.recovery) throw new Error("\u8BF7\u5148\u8FDE\u63A5\u9700\u8981\u5347\u7EA7\u7684\u6212\u6307\uFF0C\u518D\u70B9\u51FB\u5F00\u59CB\u5347\u7EA7");
      if (connected && connected.deviceId !== ((_a = this.recovery) == null ? void 0 : _a.application.deviceId)) {
        this.recovery = void 0;
        this.state.canRetry = false;
      }
      Object.assign(this.state, { protocolCompleted: false, percent: 0, reconnected: false, firmwareVersion: "", canReconnect: false });
      let bootId;
      let ownsConnection = false;
      try {
        let channel;
        if (connected) {
          this.status("\u6B63\u5728\u51C6\u5907\u5F53\u524D\u6212\u6307\u7684\u5347\u7EA7\u8FDE\u63A5\u2026");
          channel = await this.discover(connected.deviceId);
          this.assert();
          if (this.isBootloader(channel)) {
            bootId = connected.deviceId;
            ownsConnection = true;
            this.recovery = { application: connected, bootId };
            this.state.canRetry = true;
          } else {
            await this.switchToBootloader(connected, channel);
            this.assert();
            bootId = await this.findBootloader(this.recovery);
            this.assert();
            ownsConnection = true;
            await call(this.api, "createBLEConnection", { deviceId: bootId, timeout: 1e4 });
            this.assert();
            channel = await this.discoverBootloader(bootId, ((_b = this.recovery) == null ? void 0 : _b.bonded) === true);
            this.assert();
          }
        } else {
          this.status("\u6B63\u5728\u6062\u590D\u76EE\u6807\u6212\u6307\u7684\u5347\u7EA7\u8FDE\u63A5\u2026");
          bootId = await this.findBootloader(this.recovery);
          this.assert();
          ownsConnection = true;
          await call(this.api, "createBLEConnection", { deviceId: bootId, timeout: 1e4 });
          this.assert();
          channel = await this.discoverBootloader(bootId, ((_c = this.recovery) == null ? void 0 : _c.bonded) === true);
          this.assert();
        }
        if (!this.isBootloader(channel)) throw new Error("\u76EE\u6807\u6212\u6307\u7684\u5347\u7EA7\u670D\u52A1\u5C1A\u672A\u5C31\u7EEA\uFF0C\u8BF7\u7A0D\u540E\u91CD\u8BD5");
        this.recovery.bootId = bootId;
        const control = channel.characteristics.find((c) => same(c.uuid, NORDIC_DFU_CONTROL_UUID));
        const packet = channel.characteristics.find((c) => same(c.uuid, NORDIC_DFU_PACKET_UUID));
        const deviceId = bootId;
        const params = { deviceId, serviceId: channel.serviceId, characteristicId: control.uuid };
        await call(this.api, "notifyBLECharacteristicValueChange", { ...params, state: true, type: "notification" });
        this.assert();
        const payloadSize = await this.preparePayloadSize(deviceId);
        this.assert();
        const startedAt = Date.now();
        const statistics = { packetWrites: 0, controlWrites: 0, packetBytes: 0 };
        const write = (characteristicId, writeType, data) => call(this.api, "writeBLECharacteristicValue", { deviceId, serviceId: channel.serviceId, characteristicId, writeType, value: data.slice().buffer });
        const transport = {
          writeControl: async (data) => {
            await write(control.uuid, "write", data);
            statistics.controlWrites++;
          },
          writePacket: async (data) => {
            await write(packet.uuid, "writeNoResponse", data);
            statistics.packetWrites++;
            statistics.packetBytes += data.length;
          },
          onNotification: (callback) => watch(this.api, "BLECharacteristicValueChange", (e) => {
            if (matches(e, params)) callback(new Uint8Array(e.value));
          }),
          onDisconnect: (callback) => watch(this.api, "BLEConnectionStateChange", (e) => {
            if (e.deviceId === deviceId && !e.connected) callback();
          })
        };
        this.updater = new NordicOtaUpdater2(transport);
        await this.updater.start(firmware, {
          payloadSize,
          intervalMs: 0,
          preparationDelayMs: 400,
          onProgress: (p) => {
            this.state.percent = Math.floor(p.percent);
            const phase = p.state === "sendingInit" ? "\u6B63\u5728\u6821\u9A8C\u5347\u7EA7\u6587\u4EF6" : p.state === "sendingData" ? "\u6B63\u5728\u4F20\u8F93\u56FA\u4EF6" : "\u6B63\u5728\u5904\u7406\u5347\u7EA7";
            this.state.status = `${phase} \xB7 ${this.state.percent}%`;
            this.emit();
          },
          debug: (e) => {
            const line = `Nordic ${e.type} Hex:${e.hex}${e.message ? ` ${e.message}` : ""}`;
            if (e.type === "packet") {
              this.packetLogs.push(line);
              this.packetLogChars += line.length + 1;
              if (this.packetLogChars >= 8192) this.flushPacketLogs();
            } else {
              this.flushPacketLogs();
              this.log(line);
            }
          }
        });
        this.flushPacketLogs();
        const elapsedMs = Math.max(Date.now() - startedAt, 1);
        this.log(`Nordic \u4F20\u8F93\u7EDF\u8BA1 \u8D1F\u8F7D:${payloadSize} \u95F4\u9694:0ms \u5BF9\u8C61\u51C6\u5907:400ms \u6570\u636E\u5199\u5165:${statistics.packetWrites} \u63A7\u5236\u5199\u5165:${statistics.controlWrites} \u53D1\u9001\u5B57\u8282:${statistics.packetBytes} \u8017\u65F6:${elapsedMs}ms \u5E73\u5747\u53D1\u9001:${(statistics.packetBytes * 1e3 / elapsedMs / 1024).toFixed(2)}KiB/s\uFF08\u542B\u521D\u59CB\u5316\u4E0EFlash\u7B49\u5F85\uFF09`);
        this.state.protocolCompleted = true;
        this.state.canReconnect = !!this.restoreApplication;
        this.applicationToRestore = { ...this.recovery.application };
        this.recovery = void 0;
        this.state.canRetry = false;
        await this.updater.whenIdle();
        if (ownsConnection && bootId) {
          await call(this.api, "closeBLEConnection", { deviceId: bootId }).catch(() => {
          });
          ownsConnection = false;
        }
        this.assert();
        if (this.restoreApplication) await this.restoreApplicationConnection();
        else this.status("\u56FA\u4EF6\u4F20\u8F93\u5B8C\u6210\uFF0C\u6212\u6307\u6B63\u5728\u91CD\u542F\uFF1B\u91CD\u8FDE\u540E\u53EF\u67E5\u770B\u5F53\u524D\u56FA\u4EF6\u7248\u672C");
      } finally {
        this.flushPacketLogs();
        (_d = this.offServiceChanged) == null ? void 0 : _d.call(this);
        this.offServiceChanged = void 0;
        await ((_e = this.buttonless) == null ? void 0 : _e.whenIdle());
        this.buttonless = void 0;
        await ((_f = this.updater) == null ? void 0 : _f.whenIdle());
        this.updater = void 0;
        if (ownsConnection && bootId) await call(this.api, "closeBLEConnection", { deviceId: bootId }).catch(() => {
        });
      }
    });
  }
  /** 协议已经完成时仅重试应用态连接和版本读取，不重新刷写固件。 */
  async reconnect() {
    await this.run("upgrade", async () => {
      if (!this.state.protocolCompleted || !this.applicationToRestore) throw new Error("\u5C1A\u65E0\u5DF2\u5B8C\u6210\u5347\u7EA7\u7684\u91CD\u8FDE\u76EE\u6807");
      await this.restoreApplicationConnection();
    });
  }
  /** 固定原应用态 deviceId，等待重启并有限重试；重连失败不能否定已确认的传输。 */
  async restoreApplicationConnection() {
    if (!this.restoreApplication || !this.applicationToRestore) return;
    const target = { ...this.applicationToRestore };
    this.state.canReconnect = true;
    this.state.reconnected = false;
    for (let attempt = 1; attempt <= 4; attempt++) {
      this.assert();
      this.status(`\u56FA\u4EF6\u4F20\u8F93\u5B8C\u6210\uFF0C\u6B63\u5728\u7B49\u5F85\u6212\u6307\u91CD\u542F\u5E76\u91CD\u65B0\u8FDE\u63A5\uFF08${attempt}/4\uFF09\u2026`);
      let timer;
      try {
        await this.wait(new Promise((resolve) => {
          timer = setTimeout(resolve, attempt === 1 ? 1e3 : 750);
        }), 2e3, "\u91CD\u542F\u7B49\u5F85\u8D85\u65F6");
      } finally {
        clearTimeout(timer);
      }
      this.assert();
      try {
        const result = await this.restoreApplication(target, () => this.assert());
        this.assert();
        if (result.deviceId !== target.deviceId) throw new Error("\u5E94\u7528\u6001\u91CD\u8FDE\u76EE\u6807\u4E0E\u5347\u7EA7\u524D\u8BBE\u5907\u4E0D\u4E00\u81F4");
        if (!result.version) throw new Error("\u5E94\u7528\u6001\u672A\u8FD4\u56DE\u6709\u6548\u56FA\u4EF6\u7248\u672C");
        this.state.reconnected = true;
        this.state.canReconnect = false;
        this.state.firmwareVersion = result.version;
        this.log(`Nordic \u5E94\u7528\u6001\u81EA\u52A8\u91CD\u8FDE\u6210\u529F \u8BBE\u5907:${result.deviceId} \u5B9E\u9645\u56FA\u4EF6\u7248\u672C:${result.version}`);
        this.status(`\u56FA\u4EF6\u4F20\u8F93\u5B8C\u6210\uFF0C\u5DF2\u91CD\u65B0\u8FDE\u63A5\uFF1B\u5F53\u524D\u56FA\u4EF6\u7248\u672C\uFF1A${result.version}`);
        return;
      } catch (error) {
        this.assert();
        this.log(`Nordic \u5E94\u7528\u6001\u91CD\u8FDE ${attempt}/4 \u672A\u5B8C\u6210\uFF1A${errorText(error)}`);
      }
    }
    this.status("\u56FA\u4EF6\u4F20\u8F93\u5DF2\u5B8C\u6210\uFF0C\u4F46\u81EA\u52A8\u91CD\u8FDE\u672A\u6210\u529F\uFF1B\u53EF\u70B9\u51FB\u91CD\u65B0\u8FDE\u63A5\uFF0C\u6216\u56DE\u9996\u9875\u91CD\u8FDE\uFF0C\u4E0D\u9700\u8981\u91CD\u590D\u5347\u7EA7");
  }
  /** 在已启用通知的 Bootloader 连接上读取真实 MTU，未知时才使用 20 字节兼容模式。 */
  async preparePayloadSize(deviceId) {
    var _a, _b;
    let platform = "unknown";
    try {
      const deviceApi = this.api;
      platform = (((_a = deviceApi.getDeviceInfo) == null ? void 0 : _a.call(deviceApi).platform) || ((_b = deviceApi.getSystemInfoSync) == null ? void 0 : _b.call(deviceApi).platform) || "unknown").toLowerCase();
    } catch (e) {
    }
    if (platform === "android" && typeof this.api.setBLEMTU === "function") {
      let settled = false;
      const negotiation = call(this.api, "setBLEMTU", { deviceId, mtu: 247 });
      void negotiation.then(() => {
        settled = true;
      }, () => {
        settled = true;
      });
      try {
        await this.wait(negotiation, 3e3, "MTU \u534F\u5546\u7B49\u5F85\u8D85\u65F6");
      } catch (error) {
        this.assert();
        this.log(`Nordic Android MTU \u534F\u5546\u672A\u5B8C\u6210\uFF1A${errorText(error)}`);
        if (!settled) {
          this.log("Nordic MTU \u8BF7\u6C42\u4ECD\u5728\u8FDB\u884C\uFF0C\u56DE\u900020\u5B57\u8282\u517C\u5BB9\u6A21\u5F0F\uFF0C\u907F\u514D\u8FDF\u5230\u534F\u5546\u6539\u53D8\u8D1F\u8F7D\u8FB9\u754C");
          return 20;
        }
      }
    }
    this.assert();
    try {
      const result = await this.wait(call(this.api, "getBLEMTU", { deviceId, writeType: "writeNoResponse" }), 3e3, "\u8BFB\u53D6\u5347\u7EA7 MTU \u8D85\u65F6");
      this.assert();
      const payload = resolveNordicPayloadSize(result.mtu);
      if (result.mtu === void 0) throw new Error("getBLEMTU \u672A\u8FD4\u56DE\u6709\u6548 MTU");
      this.log(`Nordic \u5F53\u524D\u5347\u7EA7\u8FDE\u63A5:${deviceId} \u5E73\u53F0:${platform} ATT_MTU:${result.mtu} \u6709\u6548\u8D1F\u8F7D:${payload} \u5B57\u8282 \u989D\u5916\u7247\u95F4\u9694:0ms`);
      return payload;
    } catch (error) {
      this.assert();
      this.log(`Nordic \u65E0\u6CD5\u786E\u8BA4\u5F53\u524D\u5347\u7EA7 MTU\uFF0C\u56DE\u900020\u5B57\u8282\u517C\u5BB9\u6A21\u5F0F\uFF08\u901F\u5EA6\u8F83\u6162\uFF09\uFF1A${errorText(error)}`);
      return resolveNordicPayloadSize();
    }
  }
  /** 全部原始 Hex 按顺序保留；高频数据不进入 UI，ACK/错误前先刷新缓存。 */
  flushPacketLogs() {
    var _a;
    if (!this.packetLogs.length) return;
    const text = this.packetLogs.join("\n");
    this.packetLogs = [];
    this.packetLogChars = 0;
    try {
      ((_a = this.packetTrace) != null ? _a : this.log)(text);
    } catch (e) {
      try {
        this.log("Nordic \u5206\u7247\u8BCA\u65AD\u5199\u5165\u56DE\u8C03\u5931\u8D25");
      } catch (e2) {
      }
    }
  }
  /** 检查两个升级特征及写入/通知能力，不能把应用态控制特征误当 Bootloader。 */
  isBootloader(channel) {
    return channel.characteristics.some((c) => same(c.uuid, NORDIC_DFU_CONTROL_UUID) && c.properties.write && c.properties.notify) && channel.characteristics.some((c) => same(c.uuid, NORDIC_DFU_PACKET_UUID) && c.properties.writeNoResponse);
  }
  /** 按实际 GATT 区分绑定共享与非共享；配对弹窗本身不决定升级模式。 */
  async switchToBootloader(target, channel) {
    const bondedButton = channel.characteristics.find((c) => same(c.uuid, NORDIC_DFU_BUTTONLESS_BONDED_UUID));
    const button = bondedButton != null ? bondedButton : channel.characteristics.find((c) => same(c.uuid, NORDIC_DFU_BUTTONLESS_UUID));
    const bonded = !!bondedButton;
    if (!(button == null ? void 0 : button.properties.write) || !button.properties.indicate) {
      throw new Error("\u5F53\u524D\u6212\u6307\u672A\u63D0\u4F9B\u652F\u6301\u7684\u81EA\u52A8\u5347\u7EA7\u5165\u53E3\uFF0C\u8BF7\u67E5\u770B\u65E5\u5FD7\u4E2D\u7684\u670D\u52A1\u4FE1\u606F");
    }
    const params = { deviceId: target.deviceId, serviceId: channel.serviceId, characteristicId: button.uuid };
    let disconnected;
    const lost = new Promise((resolve) => {
      disconnected = resolve;
    });
    const off = watch(this.api, "BLEConnectionStateChange", (e) => {
      if (e.deviceId === target.deviceId && !e.connected) disconnected();
    });
    try {
      await call(this.api, "notifyBLECharacteristicValueChange", { ...params, state: true, type: "indication" });
      this.assert();
      this.buttonless = new NordicButtonlessClient({
        write: (data) => call(this.api, "writeBLECharacteristicValue", { ...params, value: data.slice().buffer, writeType: "write" }),
        onNotification: (callback) => watch(this.api, "BLECharacteristicValueChange", (e) => {
          if (matches(e, params)) callback(new Uint8Array(e.value));
        })
      }, (e) => this.log(`Nordic Buttonless ${e.type} Hex:${e.hex}`));
      this.status("\u6B63\u5728\u51C6\u5907\u6212\u6307\u5347\u7EA7\u2026");
      this.log(`Nordic DFU \u6A21\u5F0F:${bonded ? "\u5171\u4EAB\u7ED1\u5B9A\u4FE1\u606F\uFF088EC90004\uFF09" : "\u4E0D\u5171\u4EAB\u7ED1\u5B9A\u4FE1\u606F\uFF088EC90003\uFF09"} \u5F53\u524D\u8BBE\u5907:${target.deviceId}`);
      if (bonded) {
        this.offServiceChanged = await this.prepareServiceChanged(target.deviceId).catch((error) => {
          this.assert();
          this.log(`Nordic \u65E0\u6CD5\u4ECE\u5C0F\u7A0B\u5E8F\u8BBF\u95EE Service Changed\uFF0C\u7B49\u5F85\u7CFB\u7EDF\u5904\u7406\uFF1A${errorText(error)}`);
          return () => {
          };
        });
        this.assert();
        this.recovery = { application: { ...target }, bootId: target.deviceId, bonded: true };
        this.log(`Nordic \u81EA\u52A8\u5B9A\u4F4D\u7B56\u7565:\u5171\u4EAB\u7ED1\u5B9A\u4FE1\u606F\uFF0C\u4FDD\u6301\u8BBE\u5907\u6807\u8BC6 ${target.deviceId}`);
      } else {
        const name = `BCL${Math.random().toString(16).slice(2, 10).padEnd(8, "0")}`;
        const named = await this.buttonless.setName(name);
        this.assert();
        const address = nordicBootloaderAddress(target.deviceId);
        if (!named && !address) throw new Error("\u6B64\u6212\u6307\u4E0D\u652F\u6301\u4E34\u65F6\u5347\u7EA7\u6807\u8BC6\uFF0C\u5F53\u524D\u7CFB\u7EDF\u65E0\u6CD5\u81EA\u52A8\u5B9A\u4F4D\uFF1B\u8BF7\u67E5\u770B\u65E5\u5FD7\u786E\u8BA4\u56FA\u4EF6\u7684\u5347\u7EA7\u5165\u53E3\u652F\u6301\u60C5\u51B5");
        this.recovery = { application: { ...target }, ...named ? { bootName: name } : { bootId: address } };
        this.log(`Nordic \u81EA\u52A8\u5B9A\u4F4D\u7B56\u7565:${named ? "\u4E34\u65F6\u5E7F\u64AD\u540D" : "MAC+1"} \u76EE\u6807:${named ? name : address}`);
      }
      this.state.canRetry = true;
      this.status("\u6B63\u5728\u5207\u6362\u6212\u6307\u5347\u7EA7\u6A21\u5F0F\u2026");
      await this.buttonless.enter();
      this.assert();
      this.state.canRetry = true;
      await this.wait(lost, 1e4, "\u7B49\u5F85\u6212\u6307\u5207\u6362\u8D85\u65F6\uFF0C\u8BF7\u91CD\u65B0\u8FDE\u63A5\u6212\u6307\u540E\u91CD\u8BD5");
      this.assert();
      await call(this.api, "closeBLEConnection", { deviceId: target.deviceId }).catch(() => {
      });
      this.assert();
    } finally {
      off();
    }
  }
  /** 仅接受本次设置的临时名或准确的目标地址；未知广播不参与选择。 */
  async findBootloader(target) {
    this.status("\u6B63\u5728\u91CD\u65B0\u8FDE\u63A5\u6212\u6307\uFF0C\u8BF7\u7A0D\u5019\u2026");
    if (target.bonded) {
      if (!target.bootId) throw new Error("\u7ED1\u5B9A\u5347\u7EA7\u76EE\u6807\u6807\u8BC6\u7F3A\u5931");
      return target.bootId;
    }
    await call(this.api, "openBluetoothAdapter");
    this.assert();
    const candidates = /* @__PURE__ */ new Set();
    let notify;
    const found = new Promise((resolve) => {
      notify = resolve;
    });
    const off = watch(this.api, "BluetoothDeviceFound", (event) => {
      var _a;
      if (this.cancelled || this.disposed) return;
      for (const device of event.devices) {
        const matchesTarget = target.bootName ? (device.localName || device.name) === target.bootName : device.deviceId.toUpperCase() === ((_a = target.bootId) == null ? void 0 : _a.toUpperCase());
        if (matchesTarget) {
          candidates.add(device.deviceId);
          this.log(`Nordic \u627E\u5230\u76EE\u6807\u5347\u7EA7\u5E7F\u64AD:${device.deviceId}`);
          notify();
        }
      }
    });
    try {
      await call(this.api, "startBluetoothDevicesDiscovery", { allowDuplicatesKey: true });
      this.assert();
      await this.wait(found, 2e4, "\u672A\u80FD\u91CD\u65B0\u8FDE\u63A5\u76EE\u6807\u6212\u6307\uFF0C\u8BF7\u8BA9\u6212\u6307\u9760\u8FD1\u624B\u673A\u540E\u70B9\u51FB\u5F00\u59CB\u91CD\u8BD5");
      let settleTimer;
      try {
        await this.wait(new Promise((resolve) => {
          settleTimer = setTimeout(resolve, 300);
        }), 1e3, "\u5347\u7EA7\u8BBE\u5907\u8BC6\u522B\u8D85\u65F6");
      } finally {
        clearTimeout(settleTimer);
      }
      this.assert();
      if (candidates.size !== 1) throw new Error("\u68C0\u6D4B\u5230\u51B2\u7A81\u7684\u5347\u7EA7\u8BBE\u5907\u6807\u8BC6\uFF0C\u8BF7\u505C\u6B62\u5176\u4ED6\u8BBE\u5907\u5347\u7EA7\u540E\u91CD\u8BD5");
      return [...candidates][0];
    } finally {
      off();
      await call(this.api, "stopBluetoothDevicesDiscovery").catch(() => {
      });
    }
  }
  /** 绑定设备服务缓存由系统接收 Service Changed 后刷新，准备阶段只重试只读发现。 */
  async discoverBootloader(deviceId, bonded) {
    const attempts = bonded ? 6 : 1;
    for (let index = 0; index < attempts; index++) {
      this.assert();
      try {
        const channel = await this.discover(deviceId);
        this.assert();
        if (this.isBootloader(channel)) return channel;
      } catch (error) {
        this.assert();
        this.log(`Nordic \u5347\u7EA7\u670D\u52A1\u53D1\u73B0 ${index + 1}/${attempts}\uFF1A${errorText(error)}`);
        if (!bonded) throw error;
      }
      if (index + 1 < attempts) {
        this.status("\u6B63\u5728\u7B49\u5F85\u6212\u6307\u5347\u7EA7\u670D\u52A1\u5C31\u7EEA\u2026");
        let timer;
        try {
          await this.wait(new Promise((resolve) => {
            timer = setTimeout(resolve, 400);
          }), 1e3, "\u5347\u7EA7\u670D\u52A1\u7B49\u5F85\u8D85\u65F6");
        } finally {
          clearTimeout(timer);
        }
      }
    }
    throw new Error(bonded ? "\u7ED1\u5B9A\u8BBE\u5907\u7684\u5347\u7EA7\u670D\u52A1\u5C1A\u672A\u5C31\u7EEA\uFF0C\u8BF7\u68C0\u67E5\u6212\u6307 Service Changed \u4E0E\u7CFB\u7EDF\u7ED1\u5B9A\u72B6\u6001\uFF0C\u8BE6\u7EC6\u4FE1\u606F\u89C1\u65E5\u5FD7" : "\u76EE\u6807\u6212\u6307\u7684\u5347\u7EA7\u670D\u52A1\u5C1A\u672A\u5C31\u7EEA\uFF0C\u8BF7\u7A0D\u540E\u91CD\u8BD5");
  }
  /** 尝试启用标准 Service Changed；iOS 通常由系统自动管理，不读取或输出绑定密钥。 */
  async prepareServiceChanged(deviceId) {
    const { services } = await call(this.api, "getBLEDeviceServices", { deviceId });
    this.assert();
    const service = services.find((s) => same(s.uuid, NORDIC_GATT_SERVICE_UUID));
    if (!service) {
      this.log("Nordic \u672A\u53D1\u73B0 Generic Attribute \u670D\u52A1\uFF1B\u7ED1\u5B9A\u6A21\u5F0F\u9700\u8BBE\u5907\u6B63\u786E\u53D1\u9001 Service Changed\uFF0C\u7CFB\u7EDF\u53EF\u80FD\u4E0D\u5411\u5C0F\u7A0B\u5E8F\u66B4\u9732\u6B64\u670D\u52A1");
      return () => {
      };
    }
    const { characteristics } = await call(this.api, "getBLEDeviceCharacteristics", { deviceId, serviceId: service.uuid });
    this.assert();
    const changed = characteristics.find((c) => same(c.uuid, NORDIC_SERVICE_CHANGED_UUID) && c.properties.indicate);
    if (!changed) {
      this.log("Nordic \u672A\u53D1\u73B0\u53EF\u8BA2\u9605\u7684 Service Changed\uFF0C\u540E\u7EED\u901A\u8FC7\u91CD\u65B0\u53D1\u73B0\u9A8C\u8BC1\u7CFB\u7EDF\u662F\u5426\u5DF2\u5237\u65B0\u670D\u52A1");
      return () => {
      };
    }
    const params = { deviceId, serviceId: service.uuid, characteristicId: changed.uuid };
    const off = watch(this.api, "BLECharacteristicValueChange", (event) => {
      if (matches(event, params)) this.log(`Nordic Service Changed Hex:${bytesToHex3(new Uint8Array(event.value))}`);
    });
    try {
      await call(this.api, "notifyBLECharacteristicValueChange", { ...params, state: true, type: "indication" });
      this.assert();
      this.log("Nordic Service Changed indication \u5DF2\u542F\u7528\uFF1B\u7B49\u5F85\u7CFB\u7EDF\u5237\u65B0\u7ED1\u5B9A\u8BBE\u5907 GATT \u7F13\u5B58");
      return off;
    } catch (error) {
      off();
      this.assert();
      this.log(`Nordic Service Changed \u8BA2\u9605\u672A\u7531\u5C0F\u7A0B\u5E8F\u5B8C\u6210\uFF0C\u4EA4\u7531\u7CFB\u7EDF\u5904\u7406\uFF1A${errorText(error)}`);
      return () => {
      };
    }
  }
  /** 准备阶段等待同样支持取消、超时和监听清理。 */
  async wait(task, ms, message) {
    this.assert();
    let timer;
    let stop;
    const interrupted = new Promise((_, reject) => {
      stop = () => reject(new Error("\u64CD\u4F5C\u5DF2\u505C\u6B62"));
    });
    this.stoppers.add(stop);
    try {
      return await Promise.race([task, interrupted, new Promise((_, reject) => {
        timer = setTimeout(() => reject(new Error(message)), ms);
      })]);
    } finally {
      clearTimeout(timer);
      this.stoppers.delete(stop);
    }
  }
  /** 文件准备中的后台事件只记录；用户停止/销毁仍取消，BLE 升级后台立即停止。 */
  cancel(reason = "user") {
    var _a, _b, _c;
    if (!this.state.busy || this.cancelled) return;
    if (reason === "background" && this.operation === "file") {
      this.log("Nordic \u6587\u4EF6\u51C6\u5907\u671F\u95F4\u6536\u5230\u540E\u53F0\u4E8B\u4EF6\uFF0C\u7EE7\u7EED\u7B49\u5F85\u9009\u62E9/\u6821\u9A8C\u7ED3\u679C\uFF1B\u6B64\u9636\u6BB5\u672A\u53D1\u9001\u5347\u7EA7\u6307\u4EE4");
      return;
    }
    this.cancelled = true;
    this.stopReason = reason;
    this.log(`Nordic \u505C\u6B62\u8BF7\u6C42 \u6765\u6E90:${reason} \u4EFB\u52A1:${(_a = this.operation) != null ? _a : "unknown"}`);
    (_b = this.updater) == null ? void 0 : _b.cancel();
    (_c = this.buttonless) == null ? void 0 : _c.cancel();
    for (const stop of this.stoppers) stop();
  }
  /** 销毁始终废弃文件结果，即使发生在微信原生选择器等待期间。 */
  dispose() {
    this.disposed = true;
    this.cancel("disposed");
    this.firmware = void 0;
  }
  /** 每次都重新发现 GATT，使用平台实际返回的 UUID。 */
  async discover(deviceId) {
    const { services } = await call(this.api, "getBLEDeviceServices", { deviceId });
    this.assert();
    this.log(`Nordic GATT \u8BBE\u5907:${deviceId} \u670D\u52A1\u5217\u8868:${JSON.stringify(services)}`);
    const service = services.find((s) => same(s.uuid, NORDIC_DFU_SERVICE_UUID));
    if (!service) throw new Error("\u672A\u53D1\u73B0 FE59 Secure DFU \u670D\u52A1\uFF1BLegacy/\u5176\u4ED6 OTA \u6A21\u5F0F\u4E0D\u80FD\u4F7F\u7528\u6B64\u5347\u7EA7\u5668");
    const { characteristics } = await call(this.api, "getBLEDeviceCharacteristics", { deviceId, serviceId: service.uuid });
    this.assert();
    this.log(`Nordic GATT \u8BBE\u5907:${deviceId} \u670D\u52A1:${service.uuid} \u7279\u5F81:${JSON.stringify(characteristics)}`);
    return { serviceId: service.uuid, characteristics };
  }
  /** 全程占用 Demo 设备锁，异常统一记录日志和状态，不产生未处理拒绝。 */
  async run(kind, task) {
    if (this.disposed || this.state.busy) return;
    let release;
    try {
      release = this.acquire((reason) => this.cancel(reason));
      this.cancelled = false;
      this.stopReason = void 0;
      this.operation = kind;
      this.state.busy = true;
      this.emit();
      await task();
    } catch (e) {
      const reason = this.stopReason === "background" ? "\u5C0F\u7A0B\u5E8F\u8FDB\u5165\u540E\u53F0\uFF0C\u8BF7\u4FDD\u6301\u524D\u53F0\u540E\u91CD\u8BD5" : this.stopReason === "disposed" ? "\u5347\u7EA7\u9875\u9762\u5DF2\u5173\u95ED" : "\u7528\u6237\u505C\u6B62\u4E86\u5F53\u524D\u64CD\u4F5C";
      this.status(`${this.state.protocolCompleted ? "\u56FA\u4EF6\u4F20\u8F93\u5DF2\u5B8C\u6210\uFF1B" : ""}${this.cancelled ? `\u64CD\u4F5C\u5DF2\u505C\u6B62\uFF1A${reason}` : `\u64CD\u4F5C\u5931\u8D25\uFF1A${errorText(e)}`}`);
    } finally {
      this.state.busy = false;
      this.operation = void 0;
      release == null ? void 0 : release();
      this.emit();
    }
  }
  /** 检查异步结果是否仍属于有效操作。 */
  assert() {
    if (this.disposed || this.cancelled) throw new Error("\u64CD\u4F5C\u5DF2\u505C\u6B62");
  }
  /** 阶段信息写入统一日志，Hex 由 SDK debug 回调记录。 */
  status(text) {
    this.state.status = text;
    this.log(`Nordic ${text}`);
    this.emit();
  }
  /** 只通知仍存活页面，避免销毁后 setData。 */
  emit() {
    if (!this.disposed) this.changed();
  }
};
function call(api, name, params = {}) {
  return new Promise((resolve, reject) => {
    const method = api[name];
    if (typeof method !== "function") {
      reject(new Error(`\u5F53\u524D\u5FAE\u4FE1\u7F3A\u5C11 ${name}\uFF0C\u8BF7\u66F4\u65B0\u5FAE\u4FE1\u5E76\u5728\u771F\u673A\u8FD0\u884C`));
      return;
    }
    method.call(api, { ...params, success: resolve, fail: reject });
  });
}
function watch(api, name, callback) {
  const methods = api;
  const on = methods[`on${name}`];
  const off = methods[`off${name}`];
  if (typeof on !== "function" || typeof off !== "function") throw new Error(`\u7F3A\u5C11\u53EF\u6E05\u7406\u7684 ${name} \u76D1\u542C`);
  on.call(api, callback);
  return () => off.call(api, callback);
}
function same(a, b) {
  const normalize = (s) => s.length === 4 ? `0000${s.toUpperCase()}-0000-1000-8000-00805F9B34FB` : s.toUpperCase();
  return normalize(a) === normalize(b);
}
function matches(e, p) {
  return e.deviceId === p.deviceId && same(e.serviceId, p.serviceId) && same(e.characteristicId, p.characteristicId);
}
function errorText(error) {
  return error instanceof Error ? error.message : typeof (error == null ? void 0 : error.errMsg) === "string" ? error.errMsg : String(error);
}

// packages/sdk-core/src/ota/phy-ota.ts
var PhyOtaError2 = class extends Error {
  constructor(code, message, status) {
    super(message);
    this.code = code;
    this.status = status;
    this.name = "PhyOtaError";
  }
};
var occupied4 = /* @__PURE__ */ new WeakSet();
var PhyOtaUpdater2 = class {
  constructor(transport) {
    this.transport = transport;
  }
  /** 输入 HEX 字节或文本，先复制解析全部固件再进行任何写入。 */
  async start(input, options) {
    var _a, _b, _c, _d, _e, _f, _g;
    if (this.active || occupied4.has(this.transport)) throw new PhyOtaError2("busy", "PHY \u901A\u9053\u4ECD\u88AB\u5347\u7EA7\u6216\u672A\u5B8C\u6210\u5199\u5165\u5360\u7528");
    if (!Number.isInteger(options.payloadSize) || options.payloadSize < PHY_PACKET_SIZE || !Number.isFinite((_a = options.timeoutMs) != null ? _a : 1e4) || ((_b = options.timeoutMs) != null ? _b : 1e4) <= 0 || ((_c = options.timeoutMs) != null ? _c : 1e4) > 2147483647 || !Number.isFinite((_d = options.intervalMs) != null ? _d : 0) || ((_e = options.intervalMs) != null ? _e : 0) < 0 || ((_f = options.intervalMs) != null ? _f : 0) > 2147483647) throw new PhyOtaError2("invalid_options", "PHY \u9700\u8981\u5DF2\u786E\u8BA4\u7684\u81F3\u5C11 237 \u5B57\u8282\u8D1F\u8F7D\u53CA\u5408\u6CD5\u8D85\u65F6/\u95F4\u9694");
    let image;
    try {
      image = parsePhyFirmware(input);
    } catch (e) {
      throw new PhyOtaError2("invalid_firmware", String(e));
    }
    let release;
    const idle = new Promise((resolve) => {
      release = resolve;
    });
    const s = {
      progress: { state: "preparing", section: 0, acknowledgedBytes: 0, totalBytes: image.totalBytes, percent: 0 },
      options: { ...options },
      done: false,
      writes: /* @__PURE__ */ new Set(),
      idle,
      release
    };
    this.active = s;
    occupied4.add(this.transport);
    const off = [];
    try {
      off.push(this.transport.onNotification((data) => this.notify(s, data)));
      off.push(this.transport.onDisconnect(() => this.fail(s, new PhyOtaError2("disconnected", "PHY Boot \u8FDE\u63A5\u65AD\u5F00\uFF0C\u8BF7\u91CD\u65B0\u641C\u7D22\u6062\u590D"))));
      this.progress(s, "preparing");
      this.check(s);
      this.progress(s, "partitions");
      await this.exchange(s, [new Uint8Array([1, image.sections.length, 0])], false, 129);
      for (const section of image.sections) {
        s.progress.section = section.index;
        this.progress(s, "section");
        await this.exchange(s, [encodePhySection(section)], false, 132);
        for (let offset = 0; offset < section.data.length; ) {
          this.progress(s, "data");
          const end = Math.min(offset + PHY_PACKET_SIZE * PHY_WINDOW_SIZE, section.data.length);
          const packets = [];
          for (let n = offset; n < end; n += PHY_PACKET_SIZE) packets.push(section.data.slice(n, Math.min(n + PHY_PACKET_SIZE, end)));
          const expected = end < section.data.length ? 135 : section.index === image.sections.length - 1 ? 131 : 133;
          await this.exchange(s, packets, true, expected);
          this.check(s);
          s.progress.acknowledgedBytes += end - offset;
          offset = end;
          this.progress(s, "data");
        }
      }
      this.check(s);
      s.done = true;
      this.progress(s, "completed");
      return { protocolCompleted: true, rebootRequested: false, versionVerified: false, acknowledgedBytes: s.progress.acknowledgedBytes };
    } catch (e) {
      const failure = (_g = s.error) != null ? _g : e instanceof PhyOtaError2 ? e : new PhyOtaError2("write_failed", String(e));
      s.error = failure;
      s.done = true;
      this.progress(s, failure.code === "cancelled" ? "cancelled" : "failed");
      this.trace(s, "error", new Uint8Array(), failure.message);
      throw failure;
    } finally {
      s.done = true;
      if (s.pending) clearTimeout(s.pending.timer);
      s.pending = void 0;
      for (const fn of off) safe4(fn);
      this.release(s);
    }
  }
  /** 立即拒绝等待，已提交的单次平台写入仍需排空。 */
  cancel() {
    if (this.active) this.fail(this.active, new PhyOtaError2("cancelled", "PHY \u5DF2\u505C\u6B62\uFF1B\u8BF7\u91CD\u65B0\u641C\u7D22\u786E\u8BA4\u8BBE\u5907\u6A21\u5F0F"));
  }
  /** 调用方必须在此完成后解除设备互斥或交接连接。 */
  whenIdle() {
    var _a, _b;
    return (_b = (_a = this.active) == null ? void 0 : _a.idle) != null ? _b : Promise.resolve();
  }
  /** 段末 ACK 仅在最后报已提交且全部平台写入成功后生效。 */
  exchange(s, packets, data, expected) {
    this.check(s);
    return new Promise((resolve, reject) => {
      var _a;
      const p = {
        expected,
        submitted: false,
        ack: false,
        written: false,
        resolve,
        reject,
        timer: setTimeout(() => this.fail(s, new PhyOtaError2("timeout", `PHY \u9636\u6BB5 ${s.progress.state} \u5199\u5165\u6216\u786E\u8BA4\u8D85\u65F6`)), (_a = s.options.timeoutMs) != null ? _a : 1e4)
      };
      s.pending = p;
      void this.send(s, p, packets, data).catch((e) => this.fail(s, e instanceof PhyOtaError2 ? e : new PhyOtaError2("write_failed", String(e))));
    });
  }
  /** 串行发送，停止/超时后任何迟到回调都不会继续发下一报。 */
  async send(s, p, packets, data) {
    for (const [index, packet] of packets.entries()) {
      this.check(s);
      this.trace(s, data ? "data" : "command", packet);
      this.check(s);
      const write = Promise.resolve().then(() => {
        this.check(s);
        p.submitted = index === packets.length - 1;
        return data ? this.transport.writeData(packet) : this.transport.writeCommand(packet);
      });
      s.writes.add(write);
      try {
        await write;
      } finally {
        s.writes.delete(write);
        this.release(s);
      }
      this.check(s);
      if (data && s.options.intervalMs && index < packets.length - 1) await new Promise((resolve) => {
        const timer = setTimeout(() => {
          s.stopDelay = void 0;
          resolve();
        }, s.options.intervalMs);
        s.stopDelay = () => {
          clearTimeout(timer);
          s.stopDelay = void 0;
          resolve();
        };
      });
    }
    this.check(s);
    p.written = true;
    this.complete(s, p);
  }
  /** 先校验短包与状态，再限定预期 opcode；无法消歧的同类重复 ACK 不自动重试。 */
  notify(s, data) {
    if (s.done || s.error) return;
    this.trace(s, "notification", data);
    try {
      const ack = decodePhyAck(data);
      const p = s.pending;
      if (ack.status) {
        this.fail(s, new PhyOtaError2("device_rejected", `PHY \u8BBE\u5907\u62D2\u7EDD\uFF0C\u72B6\u6001 ${ack.status}`, ack.status));
        return;
      }
      if (!p || !p.submitted || p.ack) {
        this.trace(s, "ignored", data);
        return;
      }
      if (ack.opcode !== p.expected) {
        this.fail(s, new PhyOtaError2("unexpected_ack", `PHY \u5E94\u7B54 ${ack.opcode.toString(16)} \u4E0E\u9636\u6BB5\u9884\u671F ${p.expected.toString(16)} \u4E0D\u4E00\u81F4`));
        return;
      }
      p.ack = true;
      this.complete(s, p);
    } catch (e) {
      this.fail(s, new PhyOtaError2("invalid_ack", String(e)));
    }
  }
  /** 写入和设备确认缺一不可。 */
  complete(s, p) {
    if (!s.error && s.pending === p && p.ack && p.written) {
      clearTimeout(p.timer);
      s.pending = void 0;
      p.resolve();
    }
  }
  /** 首个错误胜出并唤醒定时等待。 */
  fail(s, error) {
    var _a;
    if (s.done || s.error) return;
    s.error = error;
    (_a = s.stopDelay) == null ? void 0 : _a.call(s);
    if (s.pending) {
      clearTimeout(s.pending.timer);
      const p = s.pending;
      s.pending = void 0;
      p.reject(error);
    }
  }
  /** 任何业务回调重入后均再次检查会话状态。 */
  check(s) {
    if (s.error) throw s.error;
    if (s.done) throw new PhyOtaError2("cancelled", "PHY \u4F1A\u8BDD\u5DF2\u7ED3\u675F");
  }
  /** 挂起写入未回调前仍保持通道占用，宁可保持忙碌也不交叉发送。 */
  release(s) {
    if (s.done && !s.writes.size && this.active === s) {
      this.active = void 0;
      occupied4.delete(this.transport);
      s.release();
    }
  }
  /** 回调异常仅影响展示，不影响协议。 */
  progress(s, state) {
    s.progress.state = state;
    s.progress.percent = s.progress.acknowledgedBytes / s.progress.totalBytes * 100;
    safe4(() => {
      var _a, _b;
      return (_b = (_a = s.options).onProgress) == null ? void 0 : _b.call(_a, { ...s.progress });
    });
  }
  /** 完整保留实际写入和通知 Hex。 */
  trace(s, type, bytes, message) {
    safe4(() => {
      var _a, _b;
      return (_b = (_a = s.options).debug) == null ? void 0 : _b.call(_a, { type, hex: bytesToHex(bytes), progress: { ...s.progress }, message });
    });
  }
};
function safe4(fn) {
  try {
    fn();
  } catch (e) {
  }
}

// examples/shared/phy-demo.ts
function createPhyDemoState() {
  return {
    busy: false,
    ready: false,
    fileName: "",
    confirmed: false,
    status: "\u8BF7\u9009\u62E9\u9002\u914D\u7684 PHY HEX16 \u56FA\u4EF6",
    percent: 0,
    devices: [],
    selectedId: "",
    hasRecovery: false,
    protocolCompleted: false,
    firmwareVersion: "",
    reconnected: false
  };
}
var RECORD_KEY = "bcl-phy-recovery-v1";
var PhyDemoController = class {
  constructor(api, state, changed, log, acquire, getConnected, restore, packetTrace = log) {
    __publicField(this, "api", api);
    __publicField(this, "state", state);
    __publicField(this, "changed", changed);
    __publicField(this, "log", log);
    __publicField(this, "acquire", acquire);
    __publicField(this, "getConnected", getConnected);
    __publicField(this, "restore", restore);
    __publicField(this, "packetTrace", packetTrace);
    /** 全量字节只留在非响应式对象中。 */
    __publicField(this, "firmware");
    __publicField(this, "filePath", "");
    /** 待恢复记录在实际设备模式变化前持久化。 */
    __publicField(this, "record");
    /** 每次传输独立执行器。 */
    __publicField(this, "updater");
    /** 页面销毁永久禁止所有后续操作。 */
    __publicField(this, "disposed", false);
    /** 本轮取消立即阻止准备和发送。 */
    __publicField(this, "cancelled", false);
    /** 每轮任务独立编号，取消后重试不能使旧恢复回调重新有效。 */
    __publicField(this, "generation", 0);
    /** 文件选择期间的后台事件与 BLE 操作分开处理。 */
    __publicField(this, "operation");
    /** 取消立即唤醒平台等待。 */
    __publicField(this, "stops", /* @__PURE__ */ new Set());
    /** 已提交写入、扫描启动和连接变更未回调时保持全局锁，防止迟到操作误伤新会话。 */
    __publicField(this, "writes", /* @__PURE__ */ new Set());
    /** 真实断连可终结模式命令的旧写入，并唤醒已进入排空的取消流程。 */
    __publicField(this, "wakeDrain");
    /** 当前操作拥有的专用连接，绝不在 finally 关闭移交后的应用态会话。 */
    __publicField(this, "owned", /* @__PURE__ */ new Set());
    __publicField(this, "packetLog", "");
    try {
      const value = this.sync("getStorageSync", RECORD_KEY);
      if (value) {
        const root = this.root();
        if (value.schema !== 1 || typeof value.applicationMac !== "string" || shiftPhyMac2(value.applicationMac, 1) !== value.bootMac || typeof value.path !== "string" || !value.path.startsWith(`${root}/phy-`) || value.path.includes("..") || typeof value.fileName !== "string" || typeof value.fingerprint !== "string" || typeof value.protocolCompleted !== "boolean") throw new Error("\u6062\u590D\u8BB0\u5F55\u7ED3\u6784\u6216\u8DEF\u5F84\u65E0\u6548\uFF0C\u8BF7\u6838\u5B9E\u8BBE\u5907\u4E0E\u56FA\u4EF6\u540E\u6E05\u9664\u8BB0\u5F55");
        const { expectedVersion: _legacyVersion, ...record } = value;
        this.record = record;
        Object.assign(state, {
          hasRecovery: true,
          fileName: value.fileName,
          protocolCompleted: value.protocolCompleted,
          status: "\u53D1\u73B0\u5F85\u5904\u7406\u7684 PHY \u5347\u7EA7\uFF0C\u8BF7\u52A0\u8F7D\u539F\u56FA\u4EF6\u6216\u91CD\u65B0\u641C\u7D22\u8BBE\u5907"
        });
      }
    } catch (e) {
      this.status(`\u6062\u590D\u8BB0\u5F55\u8BFB\u53D6\u5931\u8D25\uFF1A${errorText2(e)}`);
    }
  }
  /** 选择新文件必须重新确认硬件适配，不自动清除上次目标记录。 */
  async chooseFile() {
    await this.run("file", async () => {
      var _a;
      this.firmware = void 0;
      Object.assign(this.state, { ready: false, confirmed: false });
      this.emit();
      const result = await this.step(call2(this.api, "chooseMessageFile", {
        count: 1,
        type: "file",
        extension: ["hex16", "hex"]
      }), 3e5);
      const file = result.tempFiles[0];
      if (!file || !/\.(hex16|hex)$/i.test(file.name) || !file.size || file.size > 8 * 1024 * 1024) throw new Error("\u8BF7\u9009\u62E9\u4E0D\u8D85\u8FC7 8MiB \u7684 PHY HEX16/HEX \u56FA\u4EF6");
      const bytes = await this.read(file.path);
      parsePhyFirmware2(bytes);
      this.assert();
      const path = `${this.root()}/phy-${Date.now()}-${Math.random().toString(16).slice(2)}.hex16`;
      await this.step(call2(this.fs(), "writeFile", { filePath: path, data: bytes.slice().buffer }));
      this.assert();
      if (this.filePath && this.filePath !== ((_a = this.record) == null ? void 0 : _a.path)) await call2(this.fs(), "unlink", { filePath: this.filePath }).catch(() => {
      });
      this.firmware = bytes;
      this.filePath = path;
      Object.assign(this.state, { ready: true, fileName: file.name, reconnected: false, firmwareVersion: "" });
      this.status(`\u56FA\u4EF6\u6821\u9A8C\u901A\u8FC7\uFF1A${file.name}\uFF0C\u8BF7\u786E\u8BA4\u56FA\u4EF6\u9002\u7528\u4E8E\u76EE\u6807\u6212\u6307`);
    });
  }
  /** 重开后只加载已记录的持久副本并验证一致性，不自动开始刷写。 */
  async loadRecovery() {
    await this.run("file", async () => {
      if (!this.record) throw new Error("\u6CA1\u6709\u53EF\u52A0\u8F7D\u7684\u6062\u590D\u8BB0\u5F55");
      this.firmware = void 0;
      this.state.ready = false;
      this.state.confirmed = false;
      const bytes = await this.read(this.record.path);
      if (fingerprint(bytes) !== this.record.fingerprint) throw new Error("\u6062\u590D\u56FA\u4EF6\u5DF2\u6539\u53D8\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9\u5E76\u6838\u5B9E\u539F\u56FA\u4EF6");
      parsePhyFirmware2(bytes);
      this.assert();
      this.firmware = bytes;
      this.filePath = this.record.path;
      Object.assign(this.state, { ready: true, fileName: this.record.fileName });
      this.status("\u539F\u56FA\u4EF6\u5DF2\u52A0\u8F7D\uFF0C\u8BF7\u91CD\u65B0\u786E\u8BA4\u8BBE\u5907\u9002\u914D\u540E\u5F00\u59CB\u6062\u590D\uFF1B\u4E0D\u4F1A\u4F7F\u7528\u4E0A\u6B21\u767E\u5206\u6BD4\u7EED\u4F20");
    });
  }
  /** 用户确认文件适用于所选硬件；结构校验无法替代此项。 */
  confirm(value) {
    if (!this.state.busy) {
      this.state.confirmed = value;
      this.emit();
    }
  }
  /** 直接从全局设备列表传入 Boot 候选，不触发普通 SDK 连接。 */
  selectDevice(device) {
    var _a;
    if (this.state.busy || !isPhyBootAdvertisement2(device)) return;
    this.state.devices = [device];
    this.state.selectedId = device.deviceId;
    this.state.confirmed = false;
    this.status(`\u5DF2\u9009\u62E9 PHY \u6062\u590D\u8BBE\u5907 ${(_a = device.macAddress) != null ? _a : device.deviceId}`);
  }
  /** 新鲜扫描始终可用，无历史记录也能发现并选择 Boot 设备。 */
  async scan() {
    await this.run("ble", async () => {
      this.state.selectedId = "";
      this.state.devices = [];
      this.state.confirmed = false;
      this.emit();
      this.state.devices = (await this.scanFresh()).filter(isPhyBootAdvertisement2);
      this.status(`\u53D1\u73B0 ${this.state.devices.length} \u4E2A Boot \u5019\u9009\uFF0C\u8BF7\u6838\u5B9E MAC \u540E\u9009\u62E9`);
    });
  }
  /** 恢复列表显式选择，不默认刷最近或最强信号设备。 */
  select(id) {
    const target = this.state.devices.find((d) => d.deviceId === id);
    if (target) this.selectDevice(target);
  }
  /** 清除本地标记不会修改或退出设备 Boot，用户可重新扫描恢复。 */
  clearRecovery() {
    if (this.state.busy) return;
    try {
      this.sync("removeStorageSync", RECORD_KEY);
      this.record = void 0;
      Object.assign(this.state, { hasRecovery: false, protocolCompleted: false, confirmed: false, reconnected: false });
      this.status("\u5DF2\u6E05\u9664\u672C\u5730\u6062\u590D\u6807\u8BB0\uFF1B\u8BBE\u5907\u6A21\u5F0F\u672A\u6539\u53D8\uFF0C\u8BF7\u91CD\u65B0\u786E\u8BA4\u76EE\u6807");
    } catch (e) {
      this.status(`\u65E0\u6CD5\u6E05\u9664\u6062\u590D\u6807\u8BB0\uFF1A${errorText2(e)}`);
    }
  }
  /** 正常与恢复入口共用：切换前持久化，已在 Boot 则直接从首分区重刷。 */
  async start() {
    await this.run("ble", async () => {
      var _a, _b, _c, _d, _e;
      if (!this.firmware || !this.state.ready || !this.state.confirmed) throw new Error("\u8BF7\u5148\u52A0\u8F7D\u56FA\u4EF6\u5E76\u786E\u8BA4\u5176\u9002\u7528\u4E8E\u76EE\u6807\u6212\u6307");
      parsePhyFirmware2(this.firmware);
      const selected = this.state.devices.find((d) => d.deviceId === this.state.selectedId);
      const connected = this.getConnected();
      if (selected && connected) throw new Error("\u6062\u590D Boot \u524D\u8BF7\u5148\u65AD\u5F00\u5F53\u524D\u666E\u901A\u6212\u6307\u8FDE\u63A5");
      const appMac = (selected == null ? void 0 : selected.macAddress) ? shiftPhyMac2(selected.macAddress, -1) : (_b = connected == null ? void 0 : connected.macAddress) != null ? _b : (_a = this.record) == null ? void 0 : _a.applicationMac;
      if (!appMac || !shiftPhyMac2(appMac, 1)) throw new Error("\u7F3A\u5C11\u53EF\u9A8C\u8BC1\u7684\u5E7F\u64AD MAC\uFF0C\u4E0D\u80FD\u5BF9\u5E73\u53F0 UUID \u8FD0\u7B97\u6216\u731C\u6D4B\u56FA\u4EF6\u76EE\u6807");
      if (selected && !selected.macAddress) throw new Error("\u6B64 Boot \u5019\u9009\u7F3A\u5C11 MAC\uFF0C\u65E0\u6CD5\u786E\u8BA4\u6062\u590D\u8EAB\u4EFD");
      if (this.record && this.record.applicationMac !== appMac.toUpperCase()) throw new Error("\u4ECD\u6709\u53E6\u4E00\u53EA\u6212\u6307\u7684\u6062\u590D\u8BB0\u5F55\uFF0C\u8BF7\u5148\u6838\u5B9E\u5E76\u6E05\u9664\u65E7\u6807\u8BB0");
      if (((_c = this.record) == null ? void 0 : _c.protocolCompleted) && !selected) throw new Error("\u4E0A\u6B21\u534F\u8BAE\u5DF2\u5B8C\u6210\uFF0C\u8BF7\u5148\u70B9\u51FB\u91CD\u65B0\u641C\u7D22\u5E76\u8BFB\u53D6\u7248\u672C\uFF1B\u4ECD\u5728 Boot \u65F6\u663E\u5F0F\u9009\u62E9\u540E\u91CD\u5237");
      this.record = {
        schema: 1,
        applicationMac: appMac.toUpperCase(),
        bootMac: shiftPhyMac2(appMac, 1),
        applicationId: (_e = connected == null ? void 0 : connected.deviceId) != null ? _e : (_d = this.record) == null ? void 0 : _d.applicationId,
        path: this.filePath,
        fileName: this.state.fileName,
        fingerprint: fingerprint(this.firmware),
        phase: "prepared",
        protocolCompleted: false,
        updatedAt: Date.now()
      };
      this.save("prepared");
      Object.assign(this.state, { percent: 0, protocolCompleted: false, reconnected: false, firmwareVersion: "" });
      let boot;
      if (connected) {
        const channel2 = await this.discover(connected.deviceId, "application");
        this.save("switchingToBoot");
        this.status("\u8BF7\u6C42\u8FDB\u5165 Boot\uFF0C\u7B49\u5F85\u6212\u6307\u65AD\u8FDE");
        await this.modeCommand(channel2, new Uint8Array([1, 2]), true);
        boot = await this.find(this.record.bootMac, true);
      } else {
        boot = await this.find(this.record.bootMac, true);
        if (selected && boot.deviceId !== selected.deviceId) throw new Error("Boot \u5E73\u53F0\u6807\u8BC6\u5DF2\u53D8\u5316\uFF0C\u8BF7\u91CD\u65B0\u641C\u7D22\u5E76\u9009\u62E9\u786E\u8BA4");
      }
      this.save("connectingBoot");
      await this.connect(boot.deviceId);
      const channel = await this.discover(boot.deviceId, "bootloader");
      await this.step(call2(this.api, "notifyBLECharacteristicValueChange", {
        deviceId: channel.deviceId,
        serviceId: channel.serviceId,
        characteristicId: channel.notify,
        state: true
      }));
      this.assert();
      const payload = await this.payload(boot.deviceId);
      const transport = {
        writeCommand: (bytes) => this.write(channel, bytes, false),
        writeData: (bytes) => this.write(channel, bytes, true),
        onNotification: (cb) => watch2(this.api, "BLECharacteristicValueChange", (e) => {
          if (e.deviceId === channel.deviceId && same2(e.serviceId, channel.serviceId) && same2(e.characteristicId, channel.notify)) cb(new Uint8Array(e.value));
        }),
        onDisconnect: (cb) => watch2(this.api, "BLEConnectionStateChange", (e) => {
          if (e.deviceId === boot.deviceId && !e.connected) cb();
        })
      };
      this.updater = new PhyOtaUpdater2(transport);
      this.save("transferring");
      this.status("\u6B63\u5728\u5B8C\u6574\u4F20\u8F93 PHY \u56FA\u4EF6\uFF0C\u8BF7\u4FDD\u6301\u524D\u53F0");
      await this.updater.start(this.firmware, {
        payloadSize: payload,
        onProgress: (p) => {
          this.state.percent = Math.floor(p.percent);
          this.emit();
        },
        debug: (e) => {
          var _a2;
          this.packetLog += `PHY ${e.type} \u5206\u533A:${e.progress.section} \u9636\u6BB5:${e.progress.state} Hex:${e.hex} ${(_a2 = e.message) != null ? _a2 : ""}
`;
          if (this.packetLog.length > 16e3 || e.type === "notification") this.flush();
        }
      });
      this.assert();
      this.state.protocolCompleted = true;
      this.save("protocolCompleted", true);
      this.status("\u4F20\u8F93\u5B8C\u6210\uFF0C\u6B63\u5728\u8BF7\u6C42\u9000\u51FA Boot \u5E76\u6062\u590D\u5E94\u7528\u6001");
      await this.modeCommand(channel, new Uint8Array([4]), false);
      this.save("rebootRequested", true);
      await this.closeOwned();
      this.assert();
      await this.pause(1e3);
      await this.restoreApplication();
    });
  }
  /** 只搜索真实模式并读取版本，不发送固件、0102 或 04。 */
  async reconnect() {
    await this.run("ble", async () => {
      if (!this.record) throw new Error("\u6CA1\u6709\u5F85\u6062\u590D\u7684\u76EE\u6807\u8BB0\u5F55");
      await this.restoreApplication();
    });
  }
  /** 后台停止实际 BLE；选择器导致的文件阶段隐藏允许继续。 */
  cancel(reason = "user") {
    var _a;
    if (!this.state.busy || reason === "background" && this.operation === "file") return;
    this.cancelled = true;
    (_a = this.updater) == null ? void 0 : _a.cancel();
    for (const stop of this.stops) stop();
    this.log(`PHY \u505C\u6B62 \u6765\u6E90:${reason}\uFF1B\u8BF7\u91CD\u65B0\u641C\u7D22\u786E\u8BA4\u5B9E\u9645\u6A21\u5F0F\uFF0C\u4E0D\u81EA\u52A8\u9000\u51FA Boot`);
  }
  /** 销毁会话后任何迟到准备结果都失效。 */
  dispose() {
    this.disposed = true;
    this.cancel("disposed");
    this.firmware = void 0;
  }
  /** 应用态定位按广播 MAC，兼容跨模式平台 ID 改变。 */
  async restoreApplication() {
    const record = this.record;
    this.status("\u91CD\u65B0\u641C\u7D22\u5E94\u7528\u6001\u6212\u6307\uFF1B\u82E5\u4ECD\u5728 Boot\uFF0C\u53EF\u5728\u6062\u590D\u5217\u8868\u91CD\u65B0\u9009\u62E9");
    const devices = await this.scanFresh();
    if (devices.some((d) => isPhyBootAdvertisement2(d) && d.macAddress === record.bootMac)) throw new Error("\u76EE\u6807\u4ECD\u5904\u4E8E Boot\uFF1B\u8BF7\u626B\u63CF\u3001\u9009\u62E9\u8BE5\u8BBE\u5907\u5E76\u91CD\u65B0\u5F00\u59CB\u5B8C\u6574\u6062\u590D");
    const apps = devices.filter((d) => !isPhyBootAdvertisement2(d) && d.macAddress === record.applicationMac);
    if (apps.length !== 1) throw new Error(apps.length ? "\u5E94\u7528\u6001\u76EE\u6807\u8EAB\u4EFD\u51B2\u7A81\uFF0C\u8BF7\u6838\u5B9E\u540E\u91CD\u8BD5" : "\u6682\u672A\u53D1\u73B0\u5E94\u7528\u6001\u76EE\u6807\uFF0C\u8BF7\u7B49\u5F85\u91CD\u542F\u540E\u91CD\u65B0\u641C\u7D22\u5E76\u8BFB\u53D6\u7248\u672C");
    const generation = this.generation;
    const result = await this.step(this.restore(apps[0], () => this.assert(generation)), 2e4);
    this.assert();
    if (result.deviceId !== apps[0].deviceId) throw new Error("\u6062\u590D\u8FD4\u56DE\u4E86\u5176\u4ED6\u8BBE\u5907\uFF0C\u505C\u6B62\u6062\u590D\u5E94\u7528\u6001\u8FDE\u63A5");
    this.state.firmwareVersion = result.version;
    this.state.reconnected = true;
    if (!record.protocolCompleted) {
      this.status(`\u5DF2\u6062\u590D\u5E94\u7528\u6001\uFF0C\u5B9E\u9645\u7248\u672C ${result.version}\uFF1B\u4E0A\u6B21\u534F\u8BAE\u672A\u786E\u8BA4\u5B8C\u6210`);
      return;
    }
    this.sync("removeStorageSync", RECORD_KEY);
    this.record = void 0;
    this.state.hasRecovery = false;
    this.status(`PHY \u5347\u7EA7\u5B8C\u6210\uFF0C\u5DF2\u91CD\u65B0\u8FDE\u63A5\uFF1B\u5F53\u524D\u56FA\u4EF6\u7248\u672C\uFF1A${result.version}`);
  }
  /** 扫描完整时间窗口后检查冲突，绝不按名称或 RSSI 自动挑选。 */
  async find(mac, boot) {
    this.status(`\u641C\u7D22${boot ? "Boot" : "\u5E94\u7528\u6001"}\u76EE\u6807 MAC:${mac}`);
    const targets = (await this.scanFresh()).filter((d) => d.macAddress === mac && isPhyBootAdvertisement2(d) === boot);
    if (targets.length !== 1) throw new Error(targets.length ? "\u591A\u4E2A\u8BBE\u5907\u58F0\u79F0\u540C\u4E00\u76EE\u6807 MAC\uFF0C\u505C\u6B62\u81EA\u52A8\u9009\u62E9" : "\u672A\u627E\u5230\u76EE\u6807\u8BBE\u5907\uFF0C\u8BF7\u91CD\u65B0\u641C\u7D22\uFF1B\u6062\u590D\u8BB0\u5F55\u5DF2\u4FDD\u7559");
    return targets[0];
  }
  /** 不使用平台缓存作为升级依据；所有停止路径注销监听并停止扫描。 */
  async scanFresh() {
    await this.step(call2(this.api, "openBluetoothAdapter"));
    const found = /* @__PURE__ */ new Map();
    let listening = true;
    const rawDevices = /* @__PURE__ */ new Map();
    const off = watch2(this.api, "BluetoothDeviceFound", (event) => {
      var _a, _b;
      if (!listening || this.cancelled || this.disposed) return;
      for (const item of event.devices) {
        const raw = { ...rawDevices.get(item.deviceId), ...item };
        rawDevices.set(item.deviceId, raw);
        const bytes = raw.advertisData ? Array.from(new Uint8Array(raw.advertisData)) : [];
        const boot = isPhyBootAdvertisement2(raw);
        const mac = boot || (bytes.length === 8 || bytes.length === 9) && bytes[1] === 255 ? getPhyBootMac2(bytes) : void 0;
        const device = {
          deviceId: raw.deviceId,
          name: raw.name,
          localName: raw.localName,
          macAddress: mac,
          mode: boot ? "phyBootloader" : mac ? "application" : "unknown"
        };
        if (JSON.stringify(found.get(raw.deviceId)) !== JSON.stringify(device)) {
          this.log(`PHY \u626B\u63CF \u8BBE\u5907:${raw.deviceId} \u540D\u79F0:${(_a = raw.name) != null ? _a : ""} \u5E7F\u64AD\u540D:${(_b = raw.localName) != null ? _b : ""} \u6A21\u5F0F:${device.mode} MAC:${mac != null ? mac : "\u7F3A\u5931"} \u5382\u5546Hex:${bytesToHex3(new Uint8Array(bytes))}`);
        }
        found.set(raw.deviceId, device);
      }
    });
    try {
      const starting = this.track(call2(this.api, "startBluetoothDevicesDiscovery", { allowDuplicatesKey: true, interval: 0, powerLevel: "high" }));
      void starting.then(() => {
        if (!listening) void this.track(call2(this.api, "stopBluetoothDevicesDiscovery")).catch(() => {
        });
      }, () => {
      });
      await this.step(starting);
      await this.pause(5e3);
      return Array.from(found.values());
    } finally {
      listening = false;
      off();
      await bounded(this.track(call2(this.api, "stopBluetoothDevicesDiscovery")), 3e3).catch(() => {
      });
    }
  }
  /** 迟到的专用连接必须立即关闭，不能发布到新会话。 */
  async connect(deviceId) {
    this.assert();
    let accepted = true;
    const task = this.track(call2(this.api, "createBLEConnection", { deviceId, timeout: 1e4 }));
    void task.then(() => {
      if (!accepted || this.cancelled || this.disposed) void this.track(call2(this.api, "closeBLEConnection", { deviceId })).catch(() => {
      });
    }, () => {
    });
    try {
      await this.step(task);
      this.assert();
      this.owned.add(deviceId);
    } catch (e) {
      accepted = false;
      throw e;
    }
  }
  async discover(deviceId, mode) {
    const result = await this.step(call2(this.api, "getBLEDeviceServices", { deviceId }));
    const service = result.services.find((s) => same2(s.uuid, PHY_OTA_SERVICE_UUID));
    if (!service) throw new Error("\u672A\u53D1\u73B0 PHY OTA \u670D\u52A1\uFF0C\u8BF7\u786E\u8BA4\u786C\u4EF6\u7C7B\u578B");
    const { characteristics } = await this.step(call2(this.api, "getBLEDeviceCharacteristics", { deviceId, serviceId: service.uuid }));
    this.log(`PHY GATT \u6A21\u5F0F:${mode} \u8BBE\u5907:${deviceId} \u670D\u52A1:${service.uuid} \u7279\u5F81:${JSON.stringify(characteristics)}`);
    const command = characteristics.find((c) => {
      var _a;
      return same2(c.uuid, PHY_OTA_COMMAND_UUID) && ((_a = c.properties) == null ? void 0 : _a.write);
    });
    if (!command) throw new Error(`PHY ${mode === "application" ? "\u5E94\u7528\u6001" : "Boot"} \u7F3A\u5C11\u652F\u6301\u6709\u54CD\u5E94\u5199\u5165\u7684 FF02 \u547D\u4EE4\u7279\u5F81`);
    if (mode === "application") {
      this.log("PHY \u5E94\u7528\u6001 FF02 \u5DF2\u5C31\u7EEA\uFF1B\u8FDB\u5165 Boot \u540E\u91CD\u65B0\u53D1\u73B0 FF03/FF04 \u5E76\u6821\u9A8C\u4F20\u8F93\u80FD\u529B");
      return { deviceId, serviceId: service.uuid, command: command.uuid };
    }
    const data = characteristics.find((c) => {
      var _a;
      return same2(c.uuid, PHY_OTA_DATA_UUID) && ((_a = c.properties) == null ? void 0 : _a.writeNoResponse);
    });
    const notify = characteristics.find((c) => {
      var _a;
      return same2(c.uuid, PHY_OTA_NOTIFY_UUID) && ((_a = c.properties) == null ? void 0 : _a.notify);
    });
    if (!data || !notify) throw new Error("PHY Boot OTA \u6570\u636E FF04\uFF08\u65E0\u54CD\u5E94\u5199\u5165\uFF09\u6216\u901A\u77E5 FF03\uFF08Notify\uFF09\u7279\u5F81\u4E0D\u5B8C\u6574\uFF0C\u4E0D\u80FD\u4F20\u8F93\u56FA\u4EF6");
    return { deviceId, serviceId: service.uuid, command: command.uuid, data: data.uuid, notify: notify.uuid };
  }
  /** Android 可请求，iOS 只读；未知或不足 240 时停止，绝不沿用旧连接 MTU。 */
  async payload(deviceId) {
    var _a, _b;
    let platform = "unknown";
    try {
      platform = (_a = this.sync("getDeviceInfo").platform) != null ? _a : "unknown";
    } catch (e) {
      try {
        platform = (_b = this.sync("getSystemInfoSync").platform) != null ? _b : "unknown";
      } catch (e2) {
      }
    }
    if (platform.toLowerCase() === "android") {
      try {
        await this.step(call2(this.api, "setBLEMTU", { deviceId, mtu: 247 }));
      } catch (e) {
        this.assert();
        this.log(`PHY MTU \u8BF7\u6C42\u5931\u8D25\uFF1A${errorText2(e)}\uFF1B\u7EE7\u7EED\u8BFB\u53D6\u771F\u5B9E\u503C`);
      }
    }
    const result = await this.step(call2(this.api, "getBLEMTU", { deviceId, writeType: "writeNoResponse" }));
    this.log(`PHY \u5F53\u524D Boot \u8FDE\u63A5\u5E73\u53F0:${platform} MTU:${result.mtu} \u9700\u8981\u6709\u6548\u8D1F\u8F7D:237`);
    if (!Number.isInteger(result.mtu) || result.mtu < 240) throw new Error(`PHY \u5F53\u524D MTU=${result.mtu}\uFF0C\u9700\u8981\u81F3\u5C11 240\uFF1B\u5C0F MTU \u91CD\u7EC4\u5C1A\u672A\u9A8C\u8BC1`);
    return 237;
  }
  /** 模式命令可能让外设先断连而不回写回调；真实断连可终结旧连接写入，不能终结普通数据传输。 */
  async modeCommand(channel, bytes, requireDisconnect) {
    this.assert();
    const disconnected = deferred();
    const accepted = deferred();
    let submitted = false;
    let linkEnded = false;
    let writeSettled = false;
    let waitingEnded = false;
    let writeTask;
    let writeOutcome = "\u5E73\u53F0\u5199\u5165\u56DE\u8C03\u5C1A\u672A\u8FD4\u56DE";
    const commandHex = bytesToHex3(bytes);
    const off = watch2(this.api, "BLEConnectionStateChange", (event) => {
      if (!submitted || event.deviceId !== channel.deviceId || event.connected || linkEnded) return;
      linkEnded = true;
      if (writeTask) this.retire(writeTask);
      this.log(`PHY \u6A21\u5F0F\u547D\u4EE4 Hex:${commandHex} \u5DF2\u786E\u8BA4\u65E7\u8BBE\u5907\u65AD\u8FDE\uFF1B${writeOutcome}\uFF0C\u65E7\u8FDE\u63A5\u4E0D\u4F1A\u7EE7\u7EED\u53D1\u5305\uFF0C\u540E\u7EED\u91CD\u65B0\u626B\u63CF\u9A8C\u8BC1\u6A21\u5F0F`);
      disconnected.resolve();
      if (waitingEnded) off();
    });
    try {
      submitted = true;
      writeTask = this.write(channel, bytes, false);
      if (linkEnded) this.retire(writeTask);
      void writeTask.then(() => {
        writeSettled = true;
        writeOutcome = "\u5E73\u53F0\u5199\u5165\u6210\u529F\u56DE\u8C03\u5DF2\u8FD4\u56DE";
        accepted.resolve();
        this.log(`PHY \u6A21\u5F0F\u547D\u4EE4 Hex:${commandHex} ${writeOutcome}`);
        if (waitingEnded) off();
      }, (error) => {
        writeSettled = true;
        writeOutcome = `\u5E73\u53F0\u5199\u5165\u5931\u8D25\u56DE\u8C03:${errorText2(error)}`;
        this.log(`PHY \u6A21\u5F0F\u547D\u4EE4 Hex:${commandHex} ${writeOutcome}\uFF1B\u4EC5\u6B64\u56DE\u8C03\u4E0D\u5224\u5B9A\u8BBE\u5907\u6A21\u5F0F`);
        if (waitingEnded) off();
      });
      await this.step(requireDisconnect ? disconnected.promise : Promise.race([accepted.promise, disconnected.promise]));
    } catch (error) {
      this.assert();
      throw new Error(`PHY \u6A21\u5F0F\u547D\u4EE4 ${commandHex} \u7B49\u5F85${requireDisconnect ? "\u771F\u5B9E\u65AD\u8FDE" : "\u5199\u5165\u56DE\u8C03\u6216\u771F\u5B9E\u65AD\u8FDE"}\u672A\u5B8C\u6210\uFF1A${writeOutcome}\uFF1B${errorText2(error)}`);
    } finally {
      waitingEnded = true;
      if (linkEnded || writeSettled || !writeTask) off();
    }
  }
  /** 原始写入独立跟踪，ACK 永远不能替代平台回调。 */
  write(channel, bytes, data) {
    this.assert();
    const characteristicId = data ? channel.data : channel.command;
    if (!characteristicId) throw new Error("PHY \u5F53\u524D\u901A\u9053\u7F3A\u5C11 Boot \u6570\u636E\u7279\u5F81\uFF0C\u4E0D\u80FD\u53D1\u9001\u56FA\u4EF6");
    if (!data) this.log(`PHY \u547D\u4EE4 \u8BBE\u5907:${channel.deviceId} Hex:${bytesToHex3(bytes)}`);
    const task = call2(this.api, "writeBLECharacteristicValue", {
      deviceId: channel.deviceId,
      serviceId: channel.serviceId,
      characteristicId,
      value: bytes.slice().buffer,
      writeType: data ? "writeNoResponse" : "write"
    });
    return this.track(task);
  }
  /** 原始平台任务一直追踪到回调；外层超时不能代表设备操作已经撤回。 */
  track(task) {
    this.writes.add(task);
    void task.then(() => this.retire(task), () => this.retire(task));
    return task;
  }
  /** 写回调或模式命令真实断连终结旧任务；普通数据写入不能以任意断连替代。 */
  retire(task) {
    var _a;
    if (this.writes.delete(task)) (_a = this.wakeDrain) == null ? void 0 : _a.call(this);
  }
  /** 排空时也覆盖迟到连接的关闭任务，允许真实断连唤醒已经等待的旧模式写入。 */
  async drain() {
    while (this.writes.size) {
      const changed = deferred();
      this.wakeDrain = () => changed.resolve();
      try {
        await Promise.race([Promise.allSettled(Array.from(this.writes)), changed.promise]);
      } finally {
        this.wakeDrain = void 0;
      }
    }
  }
  /** 每个不可逆阶段先保存，存储失败则停止下一次设备命令。 */
  save(phase, completed = ((_b) => (_b = ((_a) => (_a = this.record) == null ? void 0 : _a.protocolCompleted)()) != null ? _b : false)(), error) {
    if (!this.record) return;
    this.record = { ...this.record, phase, protocolCompleted: completed, error, updatedAt: Date.now() };
    this.sync("setStorageSync", RECORD_KEY, this.record);
    this.state.hasRecovery = true;
  }
  /** 全操作持锁，失败保留身份和固件；绝不在失败清理中发送 04。 */
  async run(kind, task) {
    if (this.disposed || this.state.busy) return;
    let release;
    try {
      release = this.acquire((reason) => this.cancel(reason));
      this.generation++;
      this.cancelled = false;
      this.operation = kind;
      this.state.busy = true;
      this.emit();
      await task();
    } catch (e) {
      if (this.record && kind === "ble") {
        try {
          this.save("interrupted", this.record.protocolCompleted, errorText2(e));
        } catch (storage) {
          this.log(`PHY \u6062\u590D\u8BB0\u5F55\u4FDD\u5B58\u5931\u8D25\uFF1A${errorText2(storage)}`);
        }
      }
      this.status(`${this.state.protocolCompleted ? "\u534F\u8BAE\u4F20\u8F93\u5DF2\u5B8C\u6210\uFF1B" : ""}${this.cancelled ? "\u64CD\u4F5C\u5DF2\u505C\u6B62\uFF0C\u8BF7\u91CD\u65B0\u641C\u7D22" : errorText2(e)}`);
    } finally {
      this.generation++;
      if (this.updater) await this.updater.whenIdle();
      this.updater = void 0;
      await this.drain();
      try {
        await this.closeOwned();
      } catch (e) {
        this.log(`PHY \u4E13\u7528\u8FDE\u63A5\u6E05\u7406\u5931\u8D25\uFF1A${errorText2(e)}\uFF1B\u518D\u6B21\u64CD\u4F5C\u524D\u9700\u6838\u5B9E\u8FDE\u63A5`);
      }
      await this.drain();
      this.flush();
      this.operation = void 0;
      this.state.busy = false;
      release == null ? void 0 : release();
      this.emit();
    }
  }
  /** 仅关闭本控制器创建的 Boot 连接。 */
  async closeOwned() {
    for (const id of this.owned) {
      try {
        await bounded(this.track(call2(this.api, "closeBLEConnection", { deviceId: id })), 5e3);
      } finally {
        this.owned.delete(id);
      }
    }
  }
  /** 准备等待可超时且可取消，迟到结果由操作身份检查丢弃。 */
  async step(task, ms = 1e4) {
    this.assert();
    const generation = this.generation;
    let stop;
    const interrupted = new Promise((_, reject) => {
      stop = () => reject(new Error("PHY \u64CD\u4F5C\u5DF2\u505C\u6B62"));
    });
    this.stops.add(stop);
    try {
      const result = await bounded(Promise.race([task, interrupted]), ms);
      this.assert(generation);
      return result;
    } finally {
      this.stops.delete(stop);
    }
  }
  /** 可取消扫描窗口，不遗留后台计时器。 */
  async pause(ms) {
    const ready = deferred();
    const timer = setTimeout(ready.resolve, ms);
    try {
      await this.step(ready.promise, ms + 1e3);
    } finally {
      clearTimeout(timer);
    }
  }
  /** 文件大小先查再读，防止恢复路径异常造成无限分配。 */
  async read(path) {
    const info = await this.step(call2(this.fs(), "stat", { path }));
    if (!info.stats.size || info.stats.size > 8 * 1024 * 1024) throw new Error("PHY \u56FA\u4EF6\u5927\u5C0F\u65E0\u6548\u6216\u8D85\u8FC7 8MiB");
    const result = await this.step(call2(this.fs(), "readFile", { filePath: path }));
    return new Uint8Array(result.data);
  }
  /** 用户目录由运行环境提供，不信任恢复记录里的任意文件路径。 */
  root() {
    var _a;
    const root = (_a = this.api.env) == null ? void 0 : _a.USER_DATA_PATH;
    if (!root) throw new Error("\u5F53\u524D\u73AF\u5883\u7F3A\u5C11\u6301\u4E45\u6587\u4EF6\u76EE\u5F55\uFF0C\u8BF7\u4F7F\u7528\u5FAE\u4FE1\u771F\u673A");
    return root;
  }
  /** 文件接口实例不放入页面状态。 */
  fs() {
    return this.sync("getFileSystemManager");
  }
  /** 同步存储必须真实成功，缺少 API 时禁止模式切换。 */
  sync(name, ...args) {
    const fn = this.api[name];
    if (typeof fn !== "function") throw new Error(`\u5F53\u524D\u73AF\u5883\u7F3A\u5C11 ${name}`);
    return fn.apply(this.api, args);
  }
  /** 全部异步阶段统一检查生命周期。 */
  assert(generation = this.generation) {
    if (this.cancelled || this.disposed || generation !== this.generation) throw new Error("PHY \u64CD\u4F5C\u5DF2\u505C\u6B62");
  }
  /** 高频原始 Hex 按段批量落盘；日志失败回退统一日志。 */
  flush() {
    if (this.packetLog) {
      const text = this.packetLog;
      this.packetLog = "";
      try {
        this.packetTrace(text);
      } catch (e) {
        this.log(text);
      }
    }
  }
  /** 页面销毁后只写日志，不再刷新 UI。 */
  status(text) {
    this.state.status = text;
    this.log(`PHY ${text}`);
    this.emit();
  }
  emit() {
    if (!this.disposed) this.changed();
  }
};
function call2(api, name, params = {}) {
  return new Promise((resolve, reject) => {
    const method = api[name];
    if (typeof method !== "function") {
      reject(new Error(`\u5F53\u524D\u73AF\u5883\u7F3A\u5C11 ${name}`));
      return;
    }
    method.call(api, { ...params, success: resolve, fail: reject });
  });
}
function watch2(api, name, callback) {
  const methods = api;
  const on = methods[`on${name}`];
  const off = methods[`off${name}`];
  if (typeof on !== "function" || typeof off !== "function") throw new Error(`\u7F3A\u5C11\u53EF\u6E05\u7406\u7684 ${name} \u76D1\u542C`);
  on.call(api, callback);
  return () => off.call(api, callback);
}
function bounded(task, ms) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("PHY \u5E73\u53F0\u64CD\u4F5C\u8D85\u65F6")), ms);
    task.then((value) => {
      clearTimeout(timer);
      resolve(value);
    }, (error) => {
      clearTimeout(timer);
      reject(error);
    });
  });
}
function deferred() {
  let resolve;
  const promise = new Promise((done) => {
    resolve = done;
  });
  return { promise, resolve };
}
function fingerprint(bytes) {
  return `${bytes.length}:${nordicCrc322(bytes).toString(16).padStart(8, "0")}`;
}
function same2(a, b) {
  return a.toLowerCase() === b.toLowerCase();
}
function errorText2(e) {
  var _a;
  return e instanceof Error ? e.message : (_a = e == null ? void 0 : e.errMsg) != null ? _a : String(e);
}
