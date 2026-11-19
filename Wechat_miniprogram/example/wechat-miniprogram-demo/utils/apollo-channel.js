// 在已有连接上发现 Apollo 特征，沿用 SDK 原始通道，不创建第二条连接。
async function prepareApolloTransport(wxApi, adapter, session) {
  if (typeof wxApi.onBLEConnectionStateChange !== "function" || typeof wxApi.offBLEConnectionStateChange !== "function") {
    throw new Error("当前微信环境缺少可清理的蓝牙断连监听，请更新微信");
  }
  const channel = await adapter.prepareWechatRingChannel({
    wx: wxApi, deviceId: session.channel.deviceId,
    serviceUuid: adapter.APOLLO_OTA_SERVICE_UUID,
    writeCharacteristicUuid: adapter.APOLLO_OTA_WRITE_UUID,
    notifyCharacteristicUuid: adapter.APOLLO_OTA_NOTIFY_UUID,
  });
  // 通用发现接口也允许有响应写入，Apollo 则必须具备无响应写入能力。
  const characteristics = await new Promise((resolve, reject) => wxApi.getBLEDeviceCharacteristics({
    deviceId: channel.deviceId, serviceId: channel.serviceId,
    success: (result) => resolve(result.characteristics || []), fail: reject,
  }));
  const write = characteristics.find((item) => item.uuid.toLowerCase() === channel.writeCharacteristicId.toLowerCase());
  if (!write || !write.properties || !write.properties.writeNoResponse) throw new Error("Apollo 特征不支持无响应写入");
  return new adapter.BleApolloOtaTransport(new adapter.WechatBlePlatformTransport({ wx: wxApi, writeType: "writeNoResponse" }), {
    ...channel,
    onDisconnect(callback) {
      const listener = (event) => {
        if (event.deviceId === channel.deviceId && !event.connected) callback();
      };
      wxApi.onBLEConnectionStateChange(listener);
      return () => wxApi.offBLEConnectionStateChange(listener);
    },
  });
}

// 真机验证使用 237 字节有效负载，至少需要 240 字节 ATT MTU；不再回退 20 字节。
async function validateApolloPayload(wxApi, session, payloadSize) {
  let mtu = session.currentMtu || session.mtu || 0;
  if (typeof wxApi.getBLEMTU === "function") {
    try {
      mtu = await new Promise((resolve, reject) => wxApi.getBLEMTU({
        deviceId: session.channel.deviceId, writeType: "writeNoResponse",
        success: (result) => resolve(result.mtu), fail: reject,
      }));
    } catch (_) { /* 读取失败时仅使用本连接已知的协商结果。 */ }
  }
  if (payloadSize !== 237 || !Number.isInteger(mtu) || mtu < 240) {
    const hint = session.platform === "ios" ? "iOS 不能手动设置 MTU，请确认设备连接能力后重试" : "请确认实际 MTU 和设备连接能力后重试";
    throw new Error(`当前连接无法确认支持 237 字节负载（读取 MTU=${Number.isFinite(mtu) ? mtu : "未知"}，需要至少 240）；${hint}`);
  }
  return mtu;
}

module.exports = { prepareApolloTransport, validateApolloPayload };
