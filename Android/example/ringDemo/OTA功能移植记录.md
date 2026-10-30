# SKG 分支 OTA 功能移植记录（2026-10-30）

来源：skg定制 分支 TestActivity.java L814-1050、activity_test.xml L474-500
目标：aivela定制 分支 TestActivity.java + activity_test.xml
SDK 验证：aivela 分支 ChipletRing-1.7.8-release.aar 的 OtaApi 已包含
otaUpdateWithCheckVersion / otaUpdateWithVersion / setUpdateFile / fileName / destoryOta，可直接移植。

## 功能一：在线OTA（btn_ota，云端固件OTA功能）

onClick 分支（L814-865）：

```java
if(view.getId()==R.id.btn_ota) {
    LmAPILite.GET_VERSION(true, new IVersionListenerLite() {
        @Override
        public void versionResult(String softwareVersion, String hardwareVersion) {
            postView("\n等待OTA升级");
            //已经通过复合指令，获取到了版本号，不需要再调用LmAPILite.GET_VERSION
            OtaApi.otaUpdateWithCheckVersion(softwareVersion, TestActivity.this, App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), new LmOtaProgressListener() {
                @Override
                public void error(String message) {
                    postView("\nota升级出错：" + message);
                }

                @Override
                public void onProgress(int i) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            postView("\nota升级进度:"+i);
                        }
                    });
                    Logger.show("OTA", "OTA升级" + i);
                }

                @Override
                public void onComplete() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            postView("\nota升级结束");
                        }
                    });
                    Logger.show("OTA", "nota升级结束");
                    OtaApi.destoryOta(TestActivity.this);
                }

                @Override
                public void isLatestVersion() {
                    postView("\n已是最新版本");
                }

                @Override
                public void upgradeDescribe(String msg) {
                    postView("\n更新说明:"+msg);
                }
            });
        }
    });
}
```

## 功能二：本地OTA（btn_ota_local，本地固件OTA功能）

### 1. 新增 import

```java
import android.net.Uri;
import android.database.Cursor;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
```

### 2. 类成员字段

```java
private ActivityResultLauncher<Intent> filePickerLauncher;
```

### 3. onCreate 中注册文件选择器（onCreate 里、addWLSCmdListener 之前）

```java
//注册文件选择器，兼容高版本Android
filePickerLauncher = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
    if (result.getResultCode() == RESULT_OK && result.getData() != null) {
        Uri uri = result.getData().getData();
        if (uri != null) {
            handleSelectedFirmware(uri);
        }
    }
});
```

### 4. onCreate 中注册按钮

```java
findViewById(R.id.btn_ota_local).setOnClickListener(this);
```

### 5. onClick 分支（L866-873）

```java
if(view.getId()==R.id.btn_ota_local) {
    postView("\n选择固件文件");
    //启动文件选择器，尝试过滤.bin文件（部分设备支持）
    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.setType("application/octet-stream");
    filePickerLauncher.launch(intent);
}
```

### 6. 四个工具方法（onClick 之后）

handleSelectedFirmware（校验 .bin → 从文件名提版本号 → 拷贝到应用私有目录 → setUpdateFile → otaUpdateWithVersion）：

```java
/**
 * 处理选中的固件文件
 */
private void handleSelectedFirmware(Uri uri) {
    try {
        //获取文件名
        String fileName = getFileNameFromUri(uri);
        if (TextUtils.isEmpty(fileName)) {
            Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
            return;
        }

        //校验文件扩展名是否为.bin
        if (!fileName.toLowerCase().endsWith(".bin")) {
            Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
            return;
        }

        //解析版本号
        String version = extractVersionFromFileName(fileName);
        if (TextUtils.isEmpty(version)) {
            Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
            return;
        }

        postView("\n本地OTA升级");
        postView("\n固件文件：" + fileName);
        postView("\n版本号：" + version);

        //将文件拷贝到应用私有目录
        File destFile = new File(getExternalFilesDir(null), fileName);
        copyUriToFile(uri, destFile);

        //设置升级文件
        OtaApi.setUpdateFile(destFile.getAbsolutePath());
        //设置文件名
        OtaApi.fileName = fileName;
        //开始OTA升级
        OtaApi.otaUpdateWithVersion(version, "", App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), TestActivity.this, new LmOtaProgressListener() {
            @Override
            public void error(String message) {
                postView("\nota升级出错：" + message);
            }

            @Override
            public void onProgress(int i) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        postView("\nota升级进度:"+i);
                    }
                });

                Logger.show("OTA", "OTA升级" + i);
            }

            @Override
            public void onComplete() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        postView("\nota升级结束");
                    }
                });
                Logger.show("OTA", "nota升级结束");
                OtaApi.destoryOta(TestActivity.this);
            }

            @Override
            public void isLatestVersion() {
            }

            @Override
            public void upgradeDescribe(String msg) {

            }
        });

    } catch (Exception e) {
        e.printStackTrace();
        postView("\n固件文件处理失败：" + e.getMessage());
        Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
    }
}

/**
 * 从Uri获取文件名
 */
private String getFileNameFromUri(Uri uri) {
    String fileName = null;

    //尝试从ContentResolver获取文件名
    Cursor cursor = getContentResolver().query(uri, null, null, null, null);
    if (cursor != null && cursor.moveToFirst()) {
        int nameIndex = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME);
        if (nameIndex >= 0) {
            fileName = cursor.getString(nameIndex);
        }
        cursor.close();
    }

    //如果获取失败，从Uri路径解析
    if (TextUtils.isEmpty(fileName)) {
        String path = uri.getPath();
        if (!TextUtils.isEmpty(path)) {
            fileName = path.substring(path.lastIndexOf('/') + 1);
        }
    }

    return fileName;
}

/**
 * 从文件名中提取版本号
 * 规则：如果有下划线，舍弃下划线前边部分，取.bin前的内容
 */
private String extractVersionFromFileName(String fileName) {
    if (TextUtils.isEmpty(fileName)) {
        return null;
    }

    //移除.bin扩展名
    String nameWithoutExt = fileName;
    if (fileName.toLowerCase().endsWith(".bin")) {
        nameWithoutExt = fileName.substring(0, fileName.length() - 4);
    }

    //查找下划线
    int underscoreIndex = nameWithoutExt.lastIndexOf('_');
    if (underscoreIndex >= 0 && underscoreIndex < nameWithoutExt.length() - 1) {
        //返回下划线后的部分
        return nameWithoutExt.substring(underscoreIndex + 1);
    } else {
        //没有下划线，返回整个名称（不含扩展名）
        return nameWithoutExt;
    }
}

/**
 * 将Uri内容拷贝到文件
 */
private void copyUriToFile(Uri uri, File destFile) throws Exception {
    InputStream inputStream = null;
    FileOutputStream outputStream = null;
    try {
        inputStream = getContentResolver().openInputStream(uri);
        outputStream = new FileOutputStream(destFile);

        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            outputStream.write(buffer, 0, bytesRead);
        }
        outputStream.flush();
    } finally {
        if (inputStream != null) {
            try {
                inputStream.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (outputStream != null) {
            try {
                outputStream.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
```

## 布局改动（activity_test.xml）

skg 的 OTA 按钮行（两按钮同一行）：

```xml
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="50dp"
    android:gravity="center"
    android:layout_marginTop="5dp"
    android:orientation="horizontal">

    <Button
        android:id="@+id/btn_ota"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="30dp"
        android:text="云端固件OTA功能"
        android:textSize="14sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>

    <Button
        android:id="@+id/btn_ota_local"
        android:layout_weight="1"
        android:layout_width="0dp"
        android:layout_height="30dp"
        android:text="本地固件OTA功能"
        android:textSize="14sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
</LinearLayout>
```

aivela 分支已有 btn_ota 按钮（文本"勇芯测试人员专用固件预发布OTA功能"），实施时在同行补加 btn_ota_local。
