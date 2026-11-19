// 下载 URL 的查询参数可能含签名或 Token，日志只保留主路径。
function safeFirmwareUrl(url) {
  return String(url || "").split("#")[0].replace(/\?.*$/, "?[参数已脱敏]");
}

// 文件名只允许单个 bin 文件，禁止下载响应覆盖任意本地路径。
function isBinFileName(name) {
  return isSafeFileName(name) && name !== ".bin" && /\.bin$/i.test(name);
}

// 通用下载器保留其他固件格式，仅禁止目录穿越和控制字符。
function isSafeFileName(name) {
  return typeof name === "string" && name.length > 0 && name.length <= 180
    && name !== "." && name !== ".." && !/[\\/\x00-\x1f]/.test(name);
}

// 保留全部历史版本；异常条目显示原因，不猜测 filePath 是可下载地址。
function normalizeFirmwareList(items) {
  if (!Array.isArray(items)) throw new Error("固件历史列表格式错误");
  return items.map((item, index) => {
    const fileName = item && typeof item.fileName === "string" ? item.fileName : "";
    const fileUrl = item && typeof item.fileUrl === "string" ? item.fileUrl : "";
    const reason = !isBinFileName(fileName) ? "不是有效的 bin 固件文件"
      : !/^https:\/\/[^\s/?#]+(?:[/?#]|$)/i.test(fileUrl) ? "缺少有效的 HTTPS 下载地址" : "";
    return { id: String(index), fileName: fileName || "未命名文件", fileUrl,
      displayUrl: safeFirmwareUrl(fileUrl), selectable: !reason, reason };
  });
}

// 二进制读取，不指定文本 encoding；在 OTA 发包前校验头部和正文长度。
function readApolloFirmware(wxApi, adapter, filePath, fileName) {
  if (!isBinFileName(fileName)) return Promise.reject(new Error("请选择 .bin 格式固件"));
  return new Promise((resolve, reject) => {
    wxApi.getFileSystemManager().readFile({
      filePath,
      success: ({ data }) => {
        try {
          if (!(data instanceof ArrayBuffer)) throw new Error("固件读取未返回二进制数据");
          const bytes = new Uint8Array(data);
          const image = adapter.parseApolloFirmware(bytes);
          resolve({ bytes, fileName, size: bytes.length, bodySize: image.bodySize });
        } catch (error) { reject(error); }
      },
      fail: reject,
    });
  });
}

// 聊天选择器返回临时文件；主动取消不弹失败提示，也不自动开始升级。
function chooseChatFirmware(wxApi) {
  return new Promise((resolve, reject) => {
    if (typeof wxApi.chooseMessageFile !== "function") {
      reject(new Error("当前微信环境不支持聊天文件选择，请更新微信后重试"));
      return;
    }
    wxApi.chooseMessageFile({
      count: 1, type: "file", extension: ["bin"],
      success: (result) => {
        const file = result.tempFiles && result.tempFiles[0];
        if (!file || !file.path || !isBinFileName(file.name)) {
          reject(new Error("未选中有效的 .bin 文件"));
          return;
        }
        resolve(file);
      },
      fail: (error) => /cancel/i.test(error.errMsg || "") ? resolve(null) : reject(error),
    });
  });
}

// 网络 Header 中可能存在授权、Cookie 或临时密钥，统一脱敏。
function safeDownloadHeaders(headers) {
  return Object.keys(headers || {}).reduce((result, key) => {
    const value = headers[key];
    result[key] = /auth|token|key|cookie|secret/i.test(key) ? "***"
      : typeof value === "string" && /^https?:\/\//i.test(value) ? safeFirmwareUrl(value) : value;
    return result;
  }, {});
}

// 下载到用户目录，先确保目录存在；只保存成功 HTTP 响应并及时删除临时文件。
function createWechatFirmwareDownloader(wxApi, log, logError) {
  return {
    async download({ url, fileName, destinationPath, onProgress }) {
      if (!isSafeFileName(fileName)) throw new Error("固件保存文件名无效");
      const fs = wxApi.getFileSystemManager();
      const folder = destinationPath.replace(/\/$/, "");
      await new Promise((resolve, reject) => fs.mkdir({
        dirPath: folder, recursive: true, success: resolve,
        fail: (error) => {
          // 已存在目录可以复用，其余错误交由 access 确认后再决定是否失败。
          fs.access({ path: folder, success: resolve, fail: () => reject(error) });
        },
      }));
      const target = `${folder}/${fileName}`;
      const safeUrl = safeFirmwareUrl(url);
      log(`固件下载请求 Method:GET URL:${safeUrl} Header:{} Body:无`, "debug");
      return new Promise((resolve, reject) => {
        let temporaryPath = "";
        // 原始微信失败对象可能包含完整签名 URL，仅记录脱敏后的失败原因。
        const fail = (error) => {
          const message = String(error && (error.errMsg || error.message) || "固件下载失败")
            .split(String(url)).join(safeUrl).replace(/https?:\/\/[^\s"']+/g, safeFirmwareUrl);
          if (temporaryPath) fs.unlink({ filePath: temporaryPath, fail() {} });
          const failure = new Error(message);
          logError(`固件下载失败 URL:${safeUrl}`, failure);
          reject(failure);
        };
        const task = wxApi.downloadFile({
          url,
          success: (response) => {
            temporaryPath = response.tempFilePath || "";
            log(`固件下载响应 Status:${response.statusCode} URL:${safeUrl} Header:${JSON.stringify(safeDownloadHeaders(response.header))} Body:二进制文件`, "debug");
            if (response.statusCode < 200 || response.statusCode >= 300 || !temporaryPath) {
              fail(new Error(`固件下载 HTTP 失败或文件为空：${response.statusCode}`));
              return;
            }
            // 删除同名旧文件，避免第二次下载因目标已存在而失败。
            const save = () => fs.saveFile({
              tempFilePath: temporaryPath, filePath: target,
              success: (saved) => {
                const savedPath = saved.savedFilePath || target;
                log(`固件已保存：${fileName}`, "info");
                // saveFile 可能移动临时文件，删除不存在的源文件不作为失败。
                if (temporaryPath !== savedPath) fs.unlink({ filePath: temporaryPath, fail() {} });
                resolve(savedPath);
              },
              fail,
            });
            fs.unlink({ filePath: target, success: save, fail: save });
          },
          fail,
        });
        if (task && typeof task.onProgressUpdate === "function") {
          task.onProgressUpdate((progress) => onProgress && onProgress(progress.progress / 100));
        }
      });
    },
  };
}

module.exports = { safeFirmwareUrl, normalizeFirmwareList, readApolloFirmware, chooseChatFirmware, createWechatFirmwareDownloader };
