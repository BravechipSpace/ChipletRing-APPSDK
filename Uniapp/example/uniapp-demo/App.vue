<script setup lang="ts">
import { onLaunch } from "@dcloudio/uni-app";

// 保留有效的应用入口；蓝牙和 OTA 生命周期由首页会话负责。
onLaunch(() => console.log("[BCLRingUniDemo] 应用启动，请在微信真机连接戒指验证 OTA"));
</script>

<style>
page {
  background: #f2f2f7;
  color: #000;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
</style>
