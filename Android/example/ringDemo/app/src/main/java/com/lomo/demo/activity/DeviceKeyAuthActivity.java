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
