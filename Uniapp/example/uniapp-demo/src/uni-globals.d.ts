declare const uni: import("../libs/bcl-ring-sdk.js").UniBleApi & {
  showToast(options: { title: string; icon?: "success" | "error" | "none"; duration?: number }): void;
};

/** 仅在 MP-WEIXIN 条件编译分支使用微信专有文件、MTU 与连接接口。 */
declare const wx: import("../utils/wechat-platform").WechatOtaApi;
