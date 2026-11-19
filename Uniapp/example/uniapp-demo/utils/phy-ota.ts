import type { PhyDevice, PhyRestoreApplication } from "../../shared/phy-demo";
/** PHY 面板通过上下文共享普通连接、互斥和诊断。 */
export interface PhyDemoContext {
  /** 微信运行时才提供 API。 */
  api: object | null;
  /** 当前业务连接身份含广播 MAC，不能用平台 UUID 替代。 */
  getConnected(): PhyDevice | null;
  /** 其他面板和首页任务互斥。 */
  externalBusy(): boolean;
  /** 锁状态回写首页。 */
  busyChanged(value: boolean): void;
  /** 统一日志页。 */
  log(text: string): void;
  /** 高频 Hex 批量诊断。 */
  packetTrace(text: string): void;
  /** 通过真实应用态广播恢复会话并读版本。 */
  restoreApplication: PhyRestoreApplication;
}
/** 注入键，避免序列化 API 或连接实例。 */
export const PHY_DEMO_CONTEXT = "bcl-phy-demo-context";
/** 首页可向恢复面板传递明确选择的 Boot 候选。 */
export interface PhyPanelHandle {
  /** 后台停止实际传输，文件选择阶段允许等待。 */
  cancelUpgrade(reason?: string): void;
  /** 销毁旧任务。 */
  dispose(): void;
  /** 仅选择，不自动连接或刷写。 */
  selectDevice(device: PhyDevice): void;
}
