App({
  // 隐藏可能来自聊天文件选择器；传递来源，由控制器按文件/升级阶段处理。
  onHide() {
    const { getAppState } = require("./utils/demo-state");
    const state = getAppState();
    if (state.cancelOta) state.cancelOta("background");
  },
  globalData: {
    // Demo 级共享状态：跨首页、设备列表页和日志页保存连接会话与日志。
    demoState: null,
  },
});
