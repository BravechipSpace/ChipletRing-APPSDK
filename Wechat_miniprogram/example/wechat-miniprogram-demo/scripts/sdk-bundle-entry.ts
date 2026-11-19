export * from "../../../packages/adapter-wechat/src/index";
export * from "../../../packages/network-core/src/index";
// Apollo Demo 复用核心校验与独立原始通道，不在页面内复写协议。
export { parseApolloFirmware, APOLLO_OTA_SERVICE_UUID, APOLLO_OTA_WRITE_UUID, APOLLO_OTA_NOTIFY_UUID } from "../../../packages/protocol-core/src/index";
export { BleApolloOtaTransport } from "../../../packages/transport/src/index";
// Nordic 原始执行器与双 Demo 平台控制器随 bundle 提供。
export * from "../../../packages/sdk-core/src/ota/nordic-ota";
export * from "../../../packages/protocol-core/src/ota/nordic";
export { BleNordicOtaTransport } from "../../../packages/transport/src/index";
export * from "../../shared/nordic-demo";

// PHY 共用控制器支持跨小程序重启恢复。
export * from "../../shared/phy-demo";
export * from "../../../packages/protocol-core/src/ota/phy";
export * from "../../../packages/sdk-core/src/ota/phy-ota";
export { BlePhyOtaTransport } from "../../../packages/transport/src/index";
