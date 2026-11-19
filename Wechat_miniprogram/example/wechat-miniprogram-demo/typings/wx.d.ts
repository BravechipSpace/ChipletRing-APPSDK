declare const wx: import("@bcl/ring-adapter-wechat").WechatBleApi & {
  showToast(options: { title: string; icon?: "success" | "error" | "none"; duration?: number }): void;
  showModal(options: { title: string; content: string; showCancel?: boolean }): void;
};

declare function require(path: string): unknown;

declare namespace WechatMiniprogram {
  interface TouchEvent {
    currentTarget: {
      dataset: Record<string, unknown>;
    };
  }
}

declare function App(options: Record<string, unknown>): void;
declare function Page<TOptions extends { data: Record<string, unknown> }>(
  options: TOptions & ThisType<TOptions & { setData(data: Partial<TOptions["data"]>): void }>,
): void;
