/** 本地 bundle 的仓库内类型入口；外部工程运行时只依赖同名 JS。 */
export * from "../../../packages/adapter-uniapp/src/index";
export * from "../../../packages/network-core/src/index";
export * from "../../../packages/protocol-core/src/index";
export * from "../../../packages/sdk-core/src/index";
export * from "../../../packages/transport/src/index";
export * from "../../shared/nordic-demo";

// PHY 共用控制器支持跨小程序重启恢复。
export * from "../../shared/phy-demo";
