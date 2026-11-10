# demo移植文档

> 本文档是 **SDK demo 移植总文档**：本项目 `app` 模块（demo）演示了 SDK 全部协议的调用方式，其他引用本项目生成的 SDK（aar）的项目，可按本文档同步实现需要的协议功能。
> 每次协议新增/修改后，对应的 demo 修改会按"协议批次"追加到本文档相应章节，并在文末修改记录中登记。
> 各批次协议详细说明见对应文档（如 [《辉扬定制协议.md》](../blelibrary/src/main/java/com/lm/sdk/辉扬定制协议.md)、《新增协议方法文档.md》、《aivela定制协议.md》等）。

## 修改记录（全局）

| 日期 | 协议批次 | 修改内容 |
|------|---------|---------|
| 2026-11-09 | 辉扬定制（0x81 密钥鉴权） | 新增设备密钥鉴权（0x81/0x9）、查授权状态（0x81/0xA）协议及 `IDeviceKeyAuthListenerLite` 接口；新增 DeviceKeyAuthActivity 测试页面，TestActivity 添加"密钥鉴权(0x81)"入口按钮 |

---

## 一、辉扬定制协议（0x81 密钥鉴权 / 0x83 线性马达 / 0x84 Touch控制）

### 1.1 SDK 依赖清单（其他项目需同步的 SDK 修改）

#### 1. 新增文件

**`blelibrary/src/main/java/com/lm/sdk/lmApiInter/IDeviceKeyAuthListenerLite.java`**（全文）：

```java
package com.lm.sdk.lmApiInter;

/**
 * 设备密钥鉴权监听器（cmd=0x81）-辉扬使用
 * Subcmd=0x9：设备密钥鉴权；Subcmd=0xA：查授权状态
 */
public interface IDeviceKeyAuthListenerLite {
    /**
     * 设备密钥鉴权结果（Subcmd=0x9）
     *
     * @param success true-成功，false-失败
     * @param key     成功时回传的原密钥，失败时为null
     */
    void onDeviceKeyAuthResult(boolean success, String key);

    /**
     * 授权状态结果（Subcmd=0xA）
     *
     * @param authorized true-已授权，false-未授权
     */
    void onAuthStatusResult(boolean authorized);
}
```

#### 2. 修改文件：`blelibrary/src/main/java/com/lm/sdk/LmAPILite.java`

**a. import 区新增**（`ITouchControlListenerLite` import 之后）：

```java
import com.lm.sdk.lmApiInter.IDeviceKeyAuthListenerLite;
```

**b. 监听器字段区新增**（`iTouchControlListenerLite` 字段之后）：

```java
    /** 设备密钥鉴权监听器（cmd=0x81, subcmd=0x9/0xA）-辉扬使用 */
    private static IDeviceKeyAuthListenerLite iDeviceKeyAuthListenerLite;
```

**c. 响应路由修改**（`case CMD_APP_AUTH:` 分支，原为直接调用 `handleGoMoreKey`）：

```java
                case CMD_APP_AUTH:
                    if (data[3] == 0x9 || data[3] == 0xA) {
                        // ==== 辉扬定制：设备密钥鉴权（Subcmd=0x9）/查授权状态（Subcmd=0xA）====
                        handleDeviceKeyAuth(data);
                    } else {
                        handleGoMoreKey(data, data[3]);
                    }
                    break;
```

**d. 辉扬方法区新增**（`WAKEUP_TOUCH()` 方法之后）：

```java
    /**
     * 设备密钥鉴权（辉扬）（0x81，Subcmd=0x9）
     * Data: 密钥字节（长度key_len）
     * 返回Data: 1+key_len字节
     *   [0]: 状态 0-成功（随后回传原密钥），1-失败
     *
     * @param key      密钥字符串
     * @param listener 回调监听器
     */
    public static void SET_DEVICE_KEY_AUTH(String key, IDeviceKeyAuthListenerLite listener) {
        iDeviceKeyAuthListenerLite = listener;
        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] data = new byte[1 + keyBytes.length];
        data[0] = 0x09;
        System.arraycopy(keyBytes, 0, data, 1, keyBytes.length);
        SEND_CMD(convertToBytes(0x81, data));
    }

    /**
     * 查授权状态（辉扬）（0x81，Subcmd=0xA）
     * Data: 1字节占位
     * 返回Data: 1字节
     *   [0]: 0-授权，1-未授权
     *
     * @param listener 回调监听器
     */
    public static void GET_AUTH_STATUS(IDeviceKeyAuthListenerLite listener) {
        iDeviceKeyAuthListenerLite = listener;
        SEND_CMD(convertToBytes(0x81, new byte[]{0x0A, 0x00}));
    }

    /**
     * 辉扬定制：设备密钥鉴权/查授权状态响应解析（cmd=0x81）
     * Subcmd=0x9：[0]状态（0成功，随后回传原密钥；1失败）
     * Subcmd=0xA：[0]授权状态（0授权，1未授权）
     */
    private static void handleDeviceKeyAuth(byte[] data) {
        if (iDeviceKeyAuthListenerLite == null || data.length <= 4) {
            return;
        }
        int subcmd = data[3] & 0xFF;
        if (subcmd == 0x9) {
            boolean success = data[4] == 0;
            String key = null;
            if (success && data.length > 5) {
                byte[] keyBytes = new byte[data.length - 5];
                System.arraycopy(data, 5, keyBytes, 0, keyBytes.length);
                key = new String(keyBytes, StandardCharsets.UTF_8);
            }
            iDeviceKeyAuthListenerLite.onDeviceKeyAuthResult(success, key);
        } else if (subcmd == 0xA) {
            iDeviceKeyAuthListenerLite.onAuthStatusResult(data[4] == 0);
        }
    }
```

> 注：`LmAPILite.java` 需已有 `import java.nio.charset.StandardCharsets;`（文件中已存在，若移植到旧版本需确认）。

### 1.2 SDK 调用示例（其他项目直接使用）

> 辉扬 0x81 密钥鉴权协议调用示例。

#### 1. 设备密钥鉴权（0x81，Subcmd=0x9）

```java
LmAPILite.SET_DEVICE_KEY_AUTH("your_device_key", new IDeviceKeyAuthListenerLite() {
    @Override
    public void onDeviceKeyAuthResult(boolean success, String key) {
        // success: true-成功（key为回传的原密钥），false-失败（key为null）
        Log.d("DeviceKeyAuth", "密钥鉴权: " + (success ? "成功，回传密钥:" + key : "失败"));
    }

    @Override
    public void onAuthStatusResult(boolean authorized) {
        // 鉴权操作不会触发此回调
    }
});
```

#### 2. 查授权状态（0x81，Subcmd=0xA）

```java
LmAPILite.GET_AUTH_STATUS(new IDeviceKeyAuthListenerLite() {
    @Override
    public void onDeviceKeyAuthResult(boolean success, String key) {
        // 查询操作不会触发此回调
    }

    @Override
    public void onAuthStatusResult(boolean authorized) {
        // authorized: true-已授权，false-未授权
        Log.d("DeviceKeyAuth", "授权状态: " + (authorized ? "已授权" : "未授权"));
    }
});
```

### 1.3 demo 修改清单

| 文件 | 修改内容 |
|------|---------|
| `app/src/main/java/com/lomo/demo/activity/DeviceKeyAuthActivity.java` | **新增**：设备密钥鉴权测试页面（密钥输入框 + 密钥鉴权/查授权状态按钮） |
| `app/src/main/res/layout/activity_device_key_auth.xml` | **新增**：测试页面布局 |
| `app/src/main/java/com/lomo/demo/activity/TestActivity.java` | 新增"密钥鉴权(0x81)"入口按钮注册及跳转 |
| `app/src/main/res/layout/activity_test.xml` | 新增"密钥鉴权(0x81)"入口按钮 |
| `app/src/main/AndroidManifest.xml` | 注册 DeviceKeyAuthActivity |

> 入口：TestActivity → "密钥鉴权(0x81)"按钮跳转 DeviceKeyAuthActivity。

### 1.4 demo 修改详情

#### 1. DeviceKeyAuthActivity.java（新增文件全文）

```java
package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import android.view.View;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.lmApiInter.IDeviceKeyAuthListenerLite;

import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

/**
 * 设备密钥鉴权Activity（cmd=0x81）-辉扬使用
 * 包含：设备密钥鉴权(0x9)、查授权状态(0xA)
 */
public class DeviceKeyAuthActivity extends BaseActivity implements View.OnClickListener {
    TextView tv_result;
    /** 设备密钥输入框（0x81/0x9设备密钥鉴权）-辉扬 */
    EditText etDeviceKey;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_key_auth);

        tv_result = findViewById(R.id.tv_result);
        etDeviceKey = findViewById(R.id.et_device_key);

        findViewById(R.id.bt_set_device_key).setOnClickListener(this);
        findViewById(R.id.bt_get_auth_status).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 设备密钥鉴权（Subcmd=0x9）====================
        if (id == R.id.bt_set_device_key) {
            if (TextUtils.isEmpty(etDeviceKey.getText())) {
                postView("\n请输入设备密钥");
                return;
            }
            String key = etDeviceKey.getText().toString();
            postView("\n设备密钥鉴权(0x9): " + key);
            LmAPILite.SET_DEVICE_KEY_AUTH(key, new IDeviceKeyAuthListenerLite() {
                @Override
                public void onDeviceKeyAuthResult(boolean success, String key) {
                    postView("\n设备密钥鉴权结果: " + (success ? "成功，回传密钥:" + key : "失败"));
                }

                @Override
                public void onAuthStatusResult(boolean authorized) {
                    // 鉴权操作不会触发此回调
                }
            });
        }

        // ==================== 查授权状态（Subcmd=0xA）====================
        if (id == R.id.bt_get_auth_status) {
            postView("\n查授权状态(0xA)");
            LmAPILite.GET_AUTH_STATUS(new IDeviceKeyAuthListenerLite() {
                @Override
                public void onDeviceKeyAuthResult(boolean success, String key) {
                    // 查询操作不会触发此回调
                }

                @Override
                public void onAuthStatusResult(boolean authorized) {
                    postView("\n授权状态: " + (authorized ? "已授权" : "未授权"));
                }
            });
        }
    }

    /**
     * 打印日志到界面
     */
    public void postView(String value) {
        tv_result.setMovementMethod(ScrollingMovementMethod.getInstance());
        tv_result.setScrollbarFadingEnabled(false);
        tv_result.append(value);
        int scrollAmount = tv_result.getLayout().getLineTop(tv_result.getLineCount()) - tv_result.getHeight();
        if (scrollAmount > 0)
            tv_result.scrollTo(0, scrollAmount);
        else
            tv_result.scrollTo(0, 0);
    }
}
```

> 注：`postView()` 为日志打印到界面的辅助方法（与 demo 其他测试页面一致），移植时可替换为自己的日志展示逻辑。

#### 2. activity_device_key_auth.xml（新增文件全文）

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="15dp"
    tools:context=".activity.DeviceKeyAuthActivity">

    <!-- 标题 -->
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="设备密钥鉴权（0x81）"
        android:textSize="16sp"
        android:textStyle="bold"/>

    <!-- 设备密钥输入（0x81/0x9）-辉扬 -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="15dp"
        android:orientation="horizontal">
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="设备密钥:"
            android:textSize="12sp"/>
        <EditText
            android:id="@+id/et_device_key"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:hint="输入设备密钥"
            android:textSize="12sp"/>
    </LinearLayout>

    <!-- 密钥鉴权/查授权状态（0x81/0x9、0xA）-辉扬 -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="30dp"
        android:layout_marginTop="5dp"
        android:orientation="horizontal">
        <Button
            android:id="@+id/bt_set_device_key"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:text="密钥鉴权(0x9)"
            android:textSize="12sp"
            android:textColor="@color/white"
            android:background="@drawable/button_bg_state"/>
        <Button
            android:id="@+id/bt_get_auth_status"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:text="查授权状态(0xA)"
            android:textSize="12sp"
            android:textColor="@color/white"
            android:background="@drawable/button_bg_state"/>
    </LinearLayout>

    <!-- 数据显示区（固定高度，避免被挤压） -->
    <TextView
        android:id="@+id/tv_result"
        android:layout_width="match_parent"
        android:layout_height="300dp"
        android:layout_marginTop="15dp"
        android:background="#f0f0f0"
        android:gravity="top"
        android:padding="5dp"
        android:scrollbars="vertical"
        android:textSize="12sp"
        android:text="等待操作..."/>

</LinearLayout>
```

#### 3. TestActivity 入口

**onCreate 按钮注册**（`bt_touch_setting` 注册之后）：

```java
        findViewById(R.id.bt_device_key_auth).setOnClickListener(this);
```

**onClick 跳转**（`bt_touch_setting` 分支之后）：

```java
        if(view.getId()==R.id.bt_device_key_auth) {
            Intent intent=new Intent(this,DeviceKeyAuthActivity.class);
            startActivity(intent);
        }
```

**activity_test.xml 入口按钮**（`bt_touch_setting` 按钮之后）：

```xml
            <Button
                android:id="@+id/bt_device_key_auth"
                android:layout_width="0dp"
                android:layout_weight="1"
                android:layout_height="wrap_content"
                android:text="密钥鉴权(0x81)"
                android:textSize="14sp"
                android:textColor="@color/white"
                android:background="@drawable/button_bg_state"/>
```

#### 4. AndroidManifest.xml 注册

```xml
        <activity
            android:name=".activity.DeviceKeyAuthActivity"
            android:configChanges="orientation|keyboardHidden"
            android:exported="true"
            android:windowSoftInputMode="stateHidden|stateUnchanged"
            android:screenOrientation="user">

        </activity>
```

### 1.5 移植步骤

1. **SDK 层**：按"1.1 SDK 依赖清单"同步 `IDeviceKeyAuthListenerLite.java`（新增）和 `LmAPILite.java`（4处修改），重新编译 blelibrary 并替换项目中的 SDK 依赖（aar 或模块依赖）。
2. **调用层**：按"1.2 SDK 调用示例"直接调用 `LmAPILite.SET_DEVICE_KEY_AUTH()` / `LmAPILite.GET_AUTH_STATUS()`，实现 `IDeviceKeyAuthListenerLite` 回调处理结果即可，无需 UI。
3. **（可选）测试页面**：若需要可视化测试，按"1.4 demo 修改详情"复制 DeviceKeyAuthActivity、布局文件，并完成 AndroidManifest 注册及 TestActivity 入口配置。

> 后续协议批次（aivela、skg 等定制协议）的 demo 修改，将在本文档追加"二、xxx"、"三、xxx"等章节，并同步登记到头部"修改记录（全局）"。
