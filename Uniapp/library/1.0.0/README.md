# BCL 戒指 Uni-app SDK

`bcl-ring-sdk.js` 是可直接放入外部 Uni-app 工程的 ESM 单文件 SDK。

```js
import {
  connectUniAppRingSDK,
  scanUniAppRingDevices,
} from '@/libs/bcl-ring-sdk.js'
```

调用扫描和连接接口时需要传入 Uni-app 全局 `uni` 对象：

```js
const devices = await scanUniAppRingDevices({
  uni,
  durationMs: 5000,
  filterBclManufacturerData: true,
})
```

`scanUniAppRingDevices` 和 `connectUniAppRingSDK` 都会自行初始化蓝牙适配器；冷启动直连无需额外调用 `uni.openBluetoothAdapter`。

本目录只集成 SDK 能力，不会自动扫描、连接或修改业务页面。

Apollo OTA 所需的 `parseApolloFirmware`、Apollo UUID、`BleApolloOtaTransport`、`UniBlePlatformTransport` 和 SDK 公共类型也已导出。完整双来源示例位于上级目录的 `components/ApolloOtaPanel.vue` 与 `utils/`，详见上级 README；不要在业务页面重复封装 OTA 报文。

同名 `.d.ts` 仅供当前源码仓库内类型检查，引用仓库 `packages/` 声明；运行时只加载 JS bundle。若仅拷贝本目录到独立工程，不应将该声明视为独立类型发布包。

如果登录由 Uni-app 业务工程负责，可以把登录接口返回的 Token 设置到网络 SDK：

```js
import { BCLRingNetworkSDK } from '@/libs/bcl-ring-sdk.js'

const networkSDK = new BCLRingNetworkSDK({ fetch: appFetchAdapter })
await networkSDK.setToken(loginResult.token)

// 退出登录时必须同步清除，避免后续请求继续携带旧 Token。
await networkSDK.clearToken()
```

默认 Token 只保存在当前 SDK 实例的内存中。若需要跨应用重启保存，可以通过构造参数 `tokenStore` 注入基于 `uni.getStorageSync` 和 `uni.setStorageSync` 的持久化实现。
