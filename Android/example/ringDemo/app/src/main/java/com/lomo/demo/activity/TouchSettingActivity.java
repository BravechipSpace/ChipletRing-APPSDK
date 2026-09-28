package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.lmApiInter.ITouchControlListenerLite;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

/**
 * Touch设置Activity（cmd=0x84）-辉扬使用
 * 包含：设置空置时间(0x05)、读取空置时间(0x06)、休眠Touch(0x07)、唤醒Touch(0x08)
 */
public class TouchSettingActivity extends BaseActivity implements View.OnClickListener {

    public String TAG = getClass().getSimpleName();
    TextView tv_result;
    /** Touch空置时间输入框，uint16 */
    EditText etTouchIdleTime;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_touch_setting);

        tv_result = findViewById(R.id.tv_result);
        etTouchIdleTime = findViewById(R.id.et_touch_idle_time);

        findViewById(R.id.bt_set_touch_idle_time).setOnClickListener(this);
        findViewById(R.id.bt_get_touch_idle_time).setOnClickListener(this);
        findViewById(R.id.bt_sleep_touch).setOnClickListener(this);
        findViewById(R.id.bt_wakeup_touch).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 设置Touch空置时间（Subcmd=0x05）====================
        if (id == R.id.bt_set_touch_idle_time) {
            int idleTime = TextUtils.isEmpty(etTouchIdleTime.getText()) ? 60 : Integer.parseInt(etTouchIdleTime.getText().toString());
            postView("\n设置空置时间: " + idleTime);
            LmAPILite.SET_TOUCH_IDLE_TIME(idleTime, new ITouchControlListenerLite() {
                @Override
                public void onSetIdleTimeResult(boolean success) {
                    postView("\n设置空置时间结果: " + (success ? "成功" : "失败"));
                }

                @Override
                public void onGetIdleTimeResult(int idleTime) {
                    // 设置操作不会触发此回调
                }

                @Override
                public void onSleepResult(boolean success) {
                    // 设置操作不会触发此回调
                }

                @Override
                public void onWakeupResult(boolean success) {
                    // 设置操作不会触发此回调
                }
            });
        }

        // ==================== 读取Touch空置时间（Subcmd=0x06）====================
        if (id == R.id.bt_get_touch_idle_time) {
            postView("\n读取空置时间");
            LmAPILite.GET_TOUCH_IDLE_TIME(new ITouchControlListenerLite() {
                @Override
                public void onSetIdleTimeResult(boolean success) {
                    // 读取操作不会触发此回调
                }

                @Override
                public void onGetIdleTimeResult(int idleTime) {
                    postView("\n空置时间: " + idleTime);
                }

                @Override
                public void onSleepResult(boolean success) {
                    // 读取操作不会触发此回调
                }

                @Override
                public void onWakeupResult(boolean success) {
                    // 读取操作不会触发此回调
                }
            });
        }

        // ==================== 休眠Touch（Subcmd=0x07）====================
        if (id == R.id.bt_sleep_touch) {
            postView("\n休眠Touch");
            LmAPILite.SLEEP_TOUCH(new ITouchControlListenerLite() {
                @Override
                public void onSetIdleTimeResult(boolean success) {
                    // 休眠操作不会触发此回调
                }

                @Override
                public void onGetIdleTimeResult(int idleTime) {
                    // 休眠操作不会触发此回调
                }

                @Override
                public void onSleepResult(boolean success) {
                    postView("\n休眠Touch结果: " + (success ? "成功" : "失败"));
                }

                @Override
                public void onWakeupResult(boolean success) {
                    // 休眠操作不会触发此回调
                }
            });
        }

        // ==================== 唤醒Touch（Subcmd=0x08）====================
        if (id == R.id.bt_wakeup_touch) {
            postView("\n唤醒Touch");
            LmAPILite.WAKEUP_TOUCH(new ITouchControlListenerLite() {
                @Override
                public void onSetIdleTimeResult(boolean success) {
                    // 唤醒操作不会触发此回调
                }

                @Override
                public void onGetIdleTimeResult(int idleTime) {
                    // 唤醒操作不会触发此回调
                }

                @Override
                public void onSleepResult(boolean success) {
                    // 唤醒操作不会触发此回调
                }

                @Override
                public void onWakeupResult(boolean success) {
                    postView("\n唤醒Touch结果: " + (success ? "成功" : "失败"));
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
