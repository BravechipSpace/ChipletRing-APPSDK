# BCL 戒指 uni-app Demo

本示例提供基础指令与 Apollo OTA 示例；本次 OTA 目标为 **Uni-app Vue 3 编译的微信小程序**：

- 时间同步
- 读取时间
- 获取固件版本
- 获取硬件版本
- 获取电量信息
- 获取充电状态
- Apollo 历史固件查询、选择下载及微信聊天 bin 文件升级

## 使用方式

1. 使用 HBuilderX 创建或打开 uni-app 项目。
2. 保留本目录的 `pages/`、`components/`、`utils/`、`libs/`、`App.vue`、`main.ts` 及配置文件，不要只复制首页。
3. Demo 已使用本地 ESM SDK bundle，运行时无需微信开发者工具构建 npm。`libs/bcl-ring-sdk.d.ts` 用于仓库内类型检查，依赖仓库 `packages/`，不参与运行时打包。
4. `manifest.json` 已配置 Vue 3 和微信 AppID；如使用自己的 AppID，请替换 `mp-weixin.appid`。
5. 在 HBuilderX 选择“运行 → 运行到小程序模拟器 → 微信开发者工具”，再使用微信真机调试，授权蓝牙。
6. 点击“蓝牙设备搜索”，选择设备后连接。首页下方的 Apollo 面板可以准备文件和开始升级。

## Apollo OTA

### 历史版本下载

1. 在微信公众平台将 `https://ali.bravechip.cn` 配置为 request 合法域名，将服务端实际返回的固件 HTTPS 域名配置为 downloadFile 合法域名。Demo 不依赖全局 fetch，列表查询通过微信请求接口适配 SDK。
2. 选择“历史版本下载”，输入固件分类（默认 `Z5X`）。接口需要登录时填写业务已有 Token；Token 只保留在本次内存会话，不落盘、不打印明文。
3. 点击“查询固件历史版本”，从完整滚动列表选择指定文件，再点击“下载所选固件”。查询不会自动下载，选择也不会自动升级。
4. 校验通过后核对文件名、大小、固件系列与当前戒指，点击“开始 Apollo 固件升级”。下载文件在读取到内存后删除，不覆盖长期保存的固件。

### 微信聊天文件

1. 把项目测试文件 `firmware/apollo/BCL603S3L_7.3.5.5Z5X.bin` 发送到微信聊天中（先确认该定制固件适用于待测设备）。
2. 选择“微信聊天文件”，点击“从微信聊天记录选择 bin 文件”。底层使用微信专有 `chooseMessageFile`，不访问电脑上的任意本地路径。
3. 选择单个 `.bin` 后立即按二进制读取并校验；取消选择不会升级，也不会继续使用之前的文件。
4. 连接戒指后点击开始。先选择文件再连接也可以，连接过程不会清空准备好的固件。

### 连接、MTU 和结果

- 复用当前连接和 `RingSDK.startApolloUpgrade`；在独立 Apollo 服务上以 `writeNoResponse` 发送，协议、CRC、确认及状态机均由 SDK 处理。
- 固定使用 237 字节有效负载，必须实际读取到 `ATT MTU >= 240`。Android 在专用 GATT 就绪后尝试设置 512，再读取实际结果；iOS/未知平台只读，不手动设置，不用请求值或默认值冒充实际 MTU，不回退到 20 字节。
- 文件准备、升级及版本读取期间，首页设备操作与普通命令互斥。开始按钮置灰时下方会说明原因，例如文件未校验或未连接设备。
- “停止升级”、页面退出、切入后台或断连会终止后续传输；必要时确认设备恢复状态，重连后从头升级。保持前台运行，取消并不代表设备回滚。
- 正文 100% 仍可能处于固件校验或等待 reset ACK。页面只在 SDK 确认完成后显示“协议完成”；等待设备重启后点击“重连并读取真实固件版本”，实际版本仅用于展示，不与目标或文件名比较。

### 日志和真机验收

首页下方统一日志保留最近 300 条，包含脱敏的请求方法、URL、Header、Body、HTTP 状态/失败原因，以及 OTA 参数、发送 Hex、原始 ACK。完整会话异步写入面板显示的 `wx.env.USER_DATA_PATH/apollo-*.log`，可通过微信开发者工具文件面板查看、导出。诊断文件写入失败会明确提示，协议传输不因此失败。聊天文件仅只读，不删除用户的聊天文件。

自动化测试不能替代真实 BLE 和微信选择器。请分别在微信 Android/iOS 真机验收：

1. 两种来源各完成一次升级，核对文件大小、阶段进度和重连后的真实版本。
2. 历史列表为空、接口授权失败、下载失败、错误固件长度、聊天取消时不允许升级。
3. 未连接设备时开始按钮提示原因；MTU 未知或不足时明确阻止；iOS 不出现主动配置 MTU 请求。
4. 准备和传输时停止、切后台、离页及断连，不再发送后续数据；恢复后重新完整升级。
5. 正文 100% 但校验/reset 失败时不能显示协议完成；长升级日志仍可从诊断文件回溯。

当前已验证控制器与真实 SDK 状态机的 mock BLE 集成、固件校验、网络适配、取消/超时/监听清理及小程序编译；本次未连接真实戒指，真机验收仍待完成。App 原生端和 H5 的文件选择不在本次范围。

## 单文件 SDK

位置：

```text
/libs/bcl-ring-sdk.js
```

复制到外部 Uni-app 项目后，可在 JavaScript 或 Vue 页面中导入：

```js
import {
  BCLRingNetworkSDK,
  connectUniAppRingSDK,
  scanUniAppRingDevices,
} from '@/libs/bcl-ring-sdk.js'
```

单文件 SDK 提供协议、命令生命周期、蓝牙适配、Apollo 原始传输和网络接口能力，包含 `parseApolloFirmware`、Apollo UUID、`BleApolloOtaTransport` 及 `UniBlePlatformTransport`，不会自动修改页面或建立连接。
扫描与直连入口都会先初始化 Uni-app 蓝牙适配器，因此冷启动时可以直接调用 `connectUniAppRingSDK`，无需业务层预先扫描。

连接成功后可通过会话主动读取实时 RSSI；该接口封装 `uni.getBLEDeviceRSSI`，仅适用于仍处于连接状态的设备：

```ts
const session = await connectUniAppRingSDK({ uni, deviceId })
const rssi = await session.readRSSI()
```

页面需要持续展示信号值时应由业务层控制轮询生命周期，只在界面可见时读取，并在弹窗关闭、页面隐藏或蓝牙断开后停止定时任务。


当前 demo 依赖已连接戒指的 BLE 广播、服务和特征值符合协议文档：

- Service: `0x0001`
- Write Characteristic: `0x0010`
- Notify Characteristic: `0x0011`

如果设备返回完整 UUID，SDK 会尝试按短 UUID 匹配。

## Nordic 固件升级

首页「Nordic 固件升级」面板面向UniApp编译的微信小程序。连接戒指后选择application ZIP并点击开始，模式切换、03/04目标定位、升级及应用态重连由共用控制器处理。面板与Apollo及普通指令互斥，传输后读取实际版本，失败时支持只重连。

- 当前升级连接的实际MTU决定分片（MTU247→244字节）；取消逐片10ms等待，保留Flash准备与CRC确认。
- 高频分片Hex批量写完整诊断；文件选择后台事件不误取消，实际升级后台停止并记录来源。
- 扫描合并匹配戒指服务的系统已连接设备并标注来源；配对记录不是系统已连接列表。


## PHY 固件升级与 Boot 恢复

首页下方新增“PHY 固件升级与 Boot 恢复”面板，复用 `examples/shared/phy-demo.ts`。设备列表的 Boot 候选通过“恢复固件”送入面板，不初始化普通 RingSDK。正常升级先连接戒指；Boot 恢复可独立扫描、选择目标 MAC 后准备聊天 HEX16/HEX 固件。选择文件不自动刷写，开始前需确认型号适配。

切换前保存持久固件和恢复记录，重开可加载原固件；协议完成、退出 Boot、应用态恢复和实际版本展示分别记录。实际 MTU 需至少 240，失败从头重刷，不做断点续传或自动退出。仅支持 UniApp 微信小程序运行时。
