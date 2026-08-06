package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.lmApiInter.ILinearMotorCountListenerLite;
import com.lm.sdk.lmApiInter.ILinearMotorTargetListenerLite;
import com.lm.sdk.lmApiInter.IVibrationConfigListenerLite;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

/**
 * 线性马达测试Activity（cmd=0x83）
 * 包含振动配置、目标值、计数值的测试
 */
public class LinearMotorActivity extends BaseActivity implements View.OnClickListener {

    public String TAG = getClass().getSimpleName();
    TextView tv_result;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_linear_motor);

        tv_result = findViewById(R.id.tv_result);

        // 振动配置
        findViewById(R.id.bt_get_vibration_config).setOnClickListener(this);
        findViewById(R.id.bt_set_vibration_config).setOnClickListener(this);
        // 目标值
        findViewById(R.id.bt_get_target).setOnClickListener(this);
        findViewById(R.id.bt_set_target).setOnClickListener(this);
        // 计数值
        findViewById(R.id.bt_get_count).setOnClickListener(this);
        findViewById(R.id.bt_clear_count).setOnClickListener(this);
        // 计数值监听
        findViewById(R.id.bt_set_count_listener).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 读取振动配置（Subcmd=0x06）====================
        if (id == R.id.bt_get_vibration_config) {
            postView("\n读取振动配置");
            LmAPILite.GET_VIBRATION_CONFIG(new IVibrationConfigListenerLite() {
                @Override
                public void getVibrationConfigResult(int normalIntensity, int normalTime, int targetIntensity, int targetTime) {
                    postView("\n振动配置:");
                    postView("\n  常规震动强度: " + normalIntensity);
                    postView("\n  常规震动时间: " + (normalTime ) + "ms");
                    postView("\n  目标震动强度: " + targetIntensity);
                    postView("\n  目标震动时间: " + (targetTime ) + "ms");
                }

                @Override
                public void setVibrationConfigResult(boolean success) {
                    // 读取操作不会触发此回调
                }
            });
        }

        // ==================== 设置振动配置（Subcmd=0x07）====================
        if (id == R.id.bt_set_vibration_config) {
            postView("\n设置振动配置");
            int normalIntensity = 100;  // 常规震动强度 0~255
            int normalTime = 20;        // 常规震动时间（单位5ms），即100ms
            int targetIntensity = 150;  // 目标震动强度 0~255
            int targetTime = 10;        // 目标震动时间（单位5ms），即50ms

            LmAPILite.SET_VIBRATION_CONFIG(normalIntensity, normalTime, targetIntensity, targetTime, new IVibrationConfigListenerLite() {
                @Override
                public void getVibrationConfigResult(int normalIntensity, int normalTime, int targetIntensity, int targetTime) {
                    // 设置操作不会触发此回调
                }

                @Override
                public void setVibrationConfigResult(boolean success) {
                    postView("\n设置振动配置结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 读取目标值（Subcmd=0x08）====================
        if (id == R.id.bt_get_target) {
            postView("\n读取目标值");
            LmAPILite.GET_LINEAR_MOTOR_TARGET(new ILinearMotorTargetListenerLite() {
                @Override
                public void getTargetResult(int target) {
                    postView("\n目标值: " + target);
                }

                @Override
                public void setTargetResult(boolean success) {
                    // 读取操作不会触发此回调
                }
            });
        }

        // ==================== 设置目标值（Subcmd=0x09）====================
        if (id == R.id.bt_set_target) {
            postView("\n设置目标值");
            int target = 500;  // uint32_t 目标值

            LmAPILite.SET_LINEAR_MOTOR_TARGET(target, new ILinearMotorTargetListenerLite() {
                @Override
                public void getTargetResult(int target) {
                    // 设置操作不会触发此回调
                }

                @Override
                public void setTargetResult(boolean success) {
                    postView("\n设置目标值结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 读取计数值（Subcmd=0x0A）====================
        if (id == R.id.bt_get_count) {
            postView("\n读取计数值");
            LmAPILite.GET_LINEAR_MOTOR_COUNT(new ILinearMotorCountListenerLite() {
                @Override
                public void onCountResult(int count) {
                    postView("\n计数值: " + count);
                }

                @Override
                public void onClearResult(boolean success) {
                    // 读取操作不会触发此回调
                }
            });
        }

        // ==================== 清空计数值（Subcmd=0x0B）====================
        if (id == R.id.bt_clear_count) {
            postView("\n清空计数值");
            LmAPILite.CLEAR_LINEAR_MOTOR_COUNT(new ILinearMotorCountListenerLite() {
                @Override
                public void onCountResult(int count) {
                    // 清空操作不会触发此回调
                }

                @Override
                public void onClearResult(boolean success) {
                    postView("\n清空计数值结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 设置计数值监听器（接收实时推送）====================
        if (id == R.id.bt_set_count_listener) {
            postView("\n设置计数值监听器（接收实时推送）");
            LmAPILite.SET_LINEAR_MOTOR_COUNT_LISTENER(new ILinearMotorCountListenerLite() {
                @Override
                public void onCountResult(int count) {
                    postView("\n[实时推送] 计数值: " + count);
                }

                @Override
                public void onClearResult(boolean success) {
                    // 监听器不会触发此回调
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
