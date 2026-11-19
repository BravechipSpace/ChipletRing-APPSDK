import type { NordicRestoreApplication } from "../../shared/nordic-demo";
import type { ApolloDemoContext } from "./apollo-ota";

/** Nordic 独立上下文，防止两个面板覆盖对方的设备占用状态。 */
export const NORDIC_DEMO_CONTEXT = "bcl-nordic-demo-context";

/** 复用连接上下文，但将 Nordic 高频原始分片写入独立诊断通道。 */
export interface NordicDemoContext extends ApolloDemoContext {
  /** 接收已批量拼接的原始分片 Hex，不逐片触发页面日志更新。 */
  packetTrace(text: string): void;
  /** 恢复首页普通 SDK 会话并读实际版本，失败/取消必须清理迟到连接。 */
  restoreApplication: NordicRestoreApplication;
}
