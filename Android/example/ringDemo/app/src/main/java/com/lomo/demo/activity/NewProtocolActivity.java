package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.lmApiInter.IAlarmClockListenerLite;
import com.lm.sdk.lmApiInter.IAlarmParamListenerLite;
import com.lm.sdk.lmApiInter.IBloodOxygenCollectionListenerLite;
import com.lm.sdk.lmApiInter.IBloodOxygenModeListenerLite;
import com.lm.sdk.lmApiInter.IElectricityMeterListenerLite;
import com.lm.sdk.lmApiInter.ILightEffectListenerLite;
import com.lm.sdk.lmApiInter.IVibrationEffectListenerLite;
import com.lm.sdk.mode.AlarmClockBean;
import com.lm.sdk.mode.AlarmParamBean;
import com.lm.sdk.mode.LightEffectBean;
import com.lm.sdk.mode.VibrationEffectBean;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * 新增协议测试Activity
 * 包含灯光特效、震动特效、戒指控制、心率压力报警参数的测试
 */
public class NewProtocolActivity extends BaseActivity implements  View.OnClickListener {
    public String TAG = getClass().getSimpleName();
    TextView tv_result;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_protocol);


        tv_result = findViewById(R.id.tv_result);

        // 灯光特效
        findViewById(R.id.bt_set_light_effect).setOnClickListener(this);
        findViewById(R.id.bt_get_light_effect).setOnClickListener(this);
        // 震动特效
        findViewById(R.id.bt_set_vibration_effect).setOnClickListener(this);
        findViewById(R.id.bt_get_vibration_effect).setOnClickListener(this);
        // 戒指控制
        findViewById(R.id.bt_start_find_ring).setOnClickListener(this);
        findViewById(R.id.bt_stop_find_ring).setOnClickListener(this);
        findViewById(R.id.bt_start_dnd).setOnClickListener(this);
        findViewById(R.id.bt_stop_dnd).setOnClickListener(this);
        findViewById(R.id.bt_start_always_on).setOnClickListener(this);
        findViewById(R.id.bt_stop_always_on).setOnClickListener(this);
        findViewById(R.id.bt_start_light_vibration).setOnClickListener(this);
        findViewById(R.id.bt_stop_light_vibration).setOnClickListener(this);
        // 心率压力报警
        findViewById(R.id.bt_set_alarm_param).setOnClickListener(this);
        findViewById(R.id.bt_get_alarm_param).setOnClickListener(this);
        // 闹钟设置
        findViewById(R.id.bt_set_alarm_clock).setOnClickListener(this);
        findViewById(R.id.bt_get_alarm_clock).setOnClickListener(this);
        // 电量计信息
        findViewById(R.id.bt_get_electricity_meter).setOnClickListener(this);
        // 血氧模式
        findViewById(R.id.bt_set_blood_oxygen_mode).setOnClickListener(this);
        findViewById(R.id.bt_get_blood_oxygen_mode).setOnClickListener(this);
        // 血氧采集周期
        findViewById(R.id.bt_set_blood_oxygen_collection).setOnClickListener(this);
        findViewById(R.id.bt_get_blood_oxygen_collection).setOnClickListener(this);



    }



    @Override
    protected void onDestroy() {
        super.onDestroy();


    }


    @Override
    public void onClick(View view) {
        // ==================== 灯光特效 ====================
        if (view.getId() == R.id.bt_set_light_effect) {
            postView("\n设置灯光特效");
            List<LightEffectBean> lightEffects = new ArrayList<>();
            LightEffectBean effect = new LightEffectBean();
            effect.setEffectIndex(0);
            // 第一段模式（模式0：无；模式1：闪烁；模式2：呼吸）
            effect.setFirstMode(2); // 呼吸
            effect.setFirstLoopCount(0); // 无限循环
            effect.setFirstStartBrightness(50);
            effect.setFirstMiddleBrightness(200);
            effect.setFirstEndBrightness(50);
            effect.setFirstRiseStepDelay(1000); // 上升1秒
            effect.setFirstFallStepDelay(1000); // 下降1秒
            // 第二段模式
            effect.setSecondMode(1); // 闪烁
            effect.setSecondLoopCount(3); // 循环3次
            effect.setSecondStartBrightness(100);
            effect.setSecondMiddleBrightness(255);
            effect.setSecondEndBrightness(0);
            effect.setSecondRiseStepDelay(500); // 上升0.5秒
            effect.setSecondFallStepDelay(500); // 下降0.5秒
            lightEffects.add(effect);

            LmAPILite.SET_LIGHT_EFFECT(lightEffects, new ILightEffectListenerLite() {
                @Override
                public void result(List<LightEffectBean> lightEffectBeanList) {
                    if (lightEffectBeanList != null) {
                        postView("\n获取灯光特效列表，数量: " + lightEffectBeanList.size());
                        for (LightEffectBean e : lightEffectBeanList) {
                            postView("\n  序号: " + e.getEffectIndex());
                            postView("\n  第一段-模式: " + e.getFirstMode()
                                    + ", 循环次数: " + e.getFirstLoopCount()
                                    + ", 起始亮度: " + e.getFirstStartBrightness()
                                    + ", 中间亮度: " + e.getFirstMiddleBrightness()
                                    + ", 结束亮度: " + e.getFirstEndBrightness()
                                    + ", 上升延时: " + e.getFirstRiseStepDelay() + "ms"
                                    + ", 下降延时: " + e.getFirstFallStepDelay() + "ms");
                            postView("\n  第二段-模式: " + e.getSecondMode()
                                    + ", 循环次数: " + e.getSecondLoopCount()
                                    + ", 起始亮度: " + e.getSecondStartBrightness()
                                    + ", 中间亮度: " + e.getSecondMiddleBrightness()
                                    + ", 结束亮度: " + e.getSecondEndBrightness()
                                    + ", 上升延时: " + e.getSecondRiseStepDelay() + "ms"
                                    + ", 下降延时: " + e.getSecondFallStepDelay() + "ms");
                        }
                    } else {
                        postView("\n无灯光特效");
                    }
                }

                @Override
                public void setLightEffectResult(boolean success) {
                    postView("\n设置灯光特效结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        if (view.getId() == R.id.bt_get_light_effect) {
            postView("\n获取灯光特效");
            LmAPILite.GET_LIGHT_EFFECT(new ILightEffectListenerLite() {
                @Override
                public void result(List<LightEffectBean> lightEffectBeanList) {
                    if (lightEffectBeanList != null) {
                        postView("\n获取灯光特效列表，数量: " + lightEffectBeanList.size());
                        for (LightEffectBean e : lightEffectBeanList) {
                            postView("\n  序号: " + e.getEffectIndex());
                            postView("\n  第一段-模式: " + e.getFirstMode()
                                    + ", 循环次数: " + e.getFirstLoopCount()
                                    + ", 起始亮度: " + e.getFirstStartBrightness()
                                    + ", 中间亮度: " + e.getFirstMiddleBrightness()
                                    + ", 结束亮度: " + e.getFirstEndBrightness()
                                    + ", 上升延时: " + e.getFirstRiseStepDelay() + "ms"
                                    + ", 下降延时: " + e.getFirstFallStepDelay() + "ms");
                            postView("\n  第二段-模式: " + e.getSecondMode()
                                    + ", 循环次数: " + e.getSecondLoopCount()
                                    + ", 起始亮度: " + e.getSecondStartBrightness()
                                    + ", 中间亮度: " + e.getSecondMiddleBrightness()
                                    + ", 结束亮度: " + e.getSecondEndBrightness()
                                    + ", 上升延时: " + e.getSecondRiseStepDelay() + "ms"
                                    + ", 下降延时: " + e.getSecondFallStepDelay() + "ms");
                        }
                    } else {
                        postView("\n无灯光特效");
                    }
                }

                @Override
                public void setLightEffectResult(boolean success) {
                    postView("\n设置灯光特效结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 震动特效 ====================
        if (view.getId() == R.id.bt_set_vibration_effect) {
            postView("\n设置震动特效");
            List<VibrationEffectBean> vibrationEffects = new ArrayList<>();
            VibrationEffectBean effect = new VibrationEffectBean();
            effect.setEffectIndex((byte) 0);
            effect.setLoopCount((byte) 3); // 循环3次
            effect.setIntensity((byte) 80); // 震动强度
            effect.setVibrationDelay(500); // 震动500ms
            effect.setPauseDelay(200); // 暂停200ms
            vibrationEffects.add(effect);

            LmAPILite.SET_VIBRATION_EFFECT(vibrationEffects, new IVibrationEffectListenerLite() {
                @Override
                public void result(List<VibrationEffectBean> vibrationEffectBeanList) {
                    if (vibrationEffectBeanList != null) {
                        postView("\n获取震动特效列表，数量: " + vibrationEffectBeanList.size());
                        for (VibrationEffectBean e : vibrationEffectBeanList) {
                            postView("\n  序号: " + e.getEffectIndex()
                                    + ", 循环次数: " + e.getLoopCount()
                                    + ", 震动强度: " + e.getIntensity()
                                    + ", 震动延时: " + e.getVibrationDelay() + "ms"
                                    + ", 暂停延时: " + e.getPauseDelay() + "ms");
                        }
                    } else {
                        postView("\n无震动特效");
                    }
                }

                @Override
                public void setVibrationEffectResult(boolean success) {
                    postView("\n设置震动特效结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        if (view.getId() == R.id.bt_get_vibration_effect) {
            postView("\n获取震动特效");
            LmAPILite.GET_VIBRATION_EFFECT(new IVibrationEffectListenerLite() {
                @Override
                public void result(List<VibrationEffectBean> vibrationEffectBeanList) {
                    if (vibrationEffectBeanList != null) {
                        postView("\n获取震动特效列表，数量: " + vibrationEffectBeanList.size());
                        for (VibrationEffectBean e : vibrationEffectBeanList) {
                            postView("\n  序号: " + e.getEffectIndex()
                                    + ", 循环次数: " + e.getLoopCount()
                                    + ", 震动强度: " + e.getIntensity()
                                    + ", 震动延时: " + e.getVibrationDelay() + "ms"
                                    + ", 暂停延时: " + e.getPauseDelay() + "ms");
                        }
                    } else {
                        postView("\n无震动特效");
                    }
                }

                @Override
                public void setVibrationEffectResult(boolean success) {
                    postView("\n设置震动特效结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 戒指控制 ====================
        if (view.getId() == R.id.bt_start_find_ring) {
            postView("\n启动查找戒指");
            LmAPILite.START_FIND_RING();
        }

        if (view.getId() == R.id.bt_stop_find_ring) {
            postView("\n结束查找戒指");
            LmAPILite.STOP_FIND_RING();
        }

        if (view.getId() == R.id.bt_start_dnd) {
            postView("\n启动勿扰模式");
            LmAPILite.START_DND_MODE();
        }

        if (view.getId() == R.id.bt_stop_dnd) {
            postView("\n结束勿扰模式");
            LmAPILite.STOP_DND_MODE();
        }

        if (view.getId() == R.id.bt_start_always_on) {
            postView("\n启动常亮模式");
            LmAPILite.START_ALWAYS_ON();
        }

        if (view.getId() == R.id.bt_stop_always_on) {
            postView("\n结束常亮模式");
            LmAPILite.STOP_ALWAYS_ON();
        }

        if (view.getId() == R.id.bt_start_light_vibration) {
            postView("\n启动灯光震动特效");
            byte vibrationIndex = 0; // 震动特效序号
            byte lightIndex = 0; // 灯光特效序号
            LmAPILite.START_LIGHT_VIBRATION_EFFECT(vibrationIndex, lightIndex);
        }

        if (view.getId() == R.id.bt_stop_light_vibration) {
            postView("\n结束灯光震动特效");
            LmAPILite.STOP_LIGHT_VIBRATION_EFFECT();
        }

        // ==================== 心率压力报警参数 ====================
        if (view.getId() == R.id.bt_set_alarm_param) {
            postView("\n设置心率压力报警参数");
            AlarmParamBean alarmParam = new AlarmParamBean();
            alarmParam.setAlarmEnable((byte) 0x03); // 允许心率压力报警
            alarmParam.setHeartRateThreshold((byte) 120); // 心率阈值120
            alarmParam.setStressThreshold((byte) 80); // 压力阈值80
            alarmParam.setWalkDelayMinutes((byte) 5); // 走路后5分钟报警
            alarmParam.setRunDelayMinutes((byte) 3); // 跑步后3分钟报警

            LmAPILite.SET_ALARM_PARAM(alarmParam);
            postView("\n已发送设置报警参数指令");
        }

        if (view.getId() == R.id.bt_get_alarm_param) {
            postView("\n读取心率压力报警参数");
            LmAPILite.GET_ALARM_PARAM(new IAlarmParamListenerLite() {
                @Override
                public void result(AlarmParamBean alarmParamBean) {
                    if (alarmParamBean != null) {
                        String alarmEnableStr = "";
                        switch (alarmParamBean.getAlarmEnable()) {
                            case 0x00:
                                alarmEnableStr = "禁止报警";
                                break;
                            case 0x01:
                                alarmEnableStr = "允许心率报警";
                                break;
                            case 0x02:
                                alarmEnableStr = "允许压力报警";
                                break;
                            case 0x03:
                                alarmEnableStr = "允许心率压力报警";
                                break;
                        }
                        postView("\n报警功能: " + alarmEnableStr);
                        postView("\n心率阈值: " + alarmParamBean.getHeartRateThreshold());
                        postView("\n压力阈值: " + alarmParamBean.getStressThreshold());
                        postView("\n走路延时: " + alarmParamBean.getWalkDelayMinutes() + "分钟");
                        postView("\n跑步延时: " + alarmParamBean.getRunDelayMinutes() + "分钟");
                    }
                }

            });
        }

        // ==================== 闹钟设置 ====================
        if (view.getId() == R.id.bt_set_alarm_clock) {
            postView("\n设置闹钟");
            List<AlarmClockBean> setAlarmClockData = new ArrayList<>();
         for (int i = 0; i < 5; i++) {
             AlarmClockBean alarmClockBean = new AlarmClockBean();
             if(i==0){//测试只设置一个闹铃的情况
                 alarmClockBean.setOnOrOff((byte) 1);
                 alarmClockBean.setVibrationEffect((byte) 1);
                 alarmClockBean.setTime(1786524900);
                 alarmClockBean.setRepetitiveType((byte) 0);
                 alarmClockBean.setWeekday(new int[]{});
             }else{//其他补0
                 alarmClockBean.setOnOrOff((byte) 0);
                 alarmClockBean.setVibrationEffect((byte) 0);
                 alarmClockBean.setTime(0);
                 alarmClockBean.setRepetitiveType((byte) 0);
                 alarmClockBean.setWeekday(new int[]{});
             }


                setAlarmClockData.add(alarmClockBean);
           }
            LmAPILite.ALARM_CLOCK_SETTING(setAlarmClockData);
            postView("\n已发送设置闹钟指令");
        }

        if (view.getId() == R.id.bt_get_alarm_clock) {
            postView("\n获取闹钟");
            LmAPILite.GET_ALARM_CLOCK(new IAlarmClockListenerLite() {
                @Override
                public void result(List<AlarmClockBean> alarmClockBeanList) {
                    if (alarmClockBeanList != null && !alarmClockBeanList.isEmpty()) {
                        postView("\n获取到闹钟数量: " + alarmClockBeanList.size());
                        for (AlarmClockBean alarmClockBean : alarmClockBeanList) {
                            if (alarmClockBean.getTime() > 0) {
                                postView("\n  时间戳: " + alarmClockBean.getTime()
                                        + ", 重复类型: " + alarmClockBean.getRepetitiveType()
                                        + ", 震动效果: " + alarmClockBean.getVibrationEffect()
                                        + ", 开关: " + alarmClockBean.getOnOrOff()
                                        + ", 灯光效果: " + alarmClockBean.getLightingEffect());
                            }
                        }
                    } else {
                        postView("\n无闹钟数据");
                    }
                }

                @Override
                public void holidayResult(com.lm.sdk.mode.HolidayResult holidayResult) {
                }

                @Override
                public void setAlarmResult(boolean success) {
                    postView("\n设置闹钟结果: " + (success ? "成功" : "失败"));
                }

                @Override
                public void setHolidayResult(boolean success) {
                }
            });
        }

        // ==================== 电量计信息 ====================
        if (view.getId() == R.id.bt_get_electricity_meter) {
            postView("\n读取电量计信息");
            LmAPILite.GET_ELECTRICITY_METER(new IElectricityMeterListenerLite() {
                @Override
                public void battery(int power, int voltage, int current, int temperature, int cyclesNumber, int health) {
                    postView("\n电量: " + power + "%");
                    postView("\n电压: " + voltage + "mV");
                    postView("\n电流: " + current + "mA");
                    postView("\n温度: " + temperature + "℃");
                    postView("\n循环次数: " + cyclesNumber);
                    postView("\n健康状态: " + health + "%");
                }
            });
        }

        // ==================== 血氧模式 ====================
        if (view.getId() == R.id.bt_set_blood_oxygen_mode) {
            postView("\n设置血氧模式: 打开");
            LmAPILite.SET_BLOOD_OXYGEN_MODE(1, new IBloodOxygenModeListenerLite() {
                @Override
                public void setBloodOxygenModeResult(boolean success) {
                    postView("\n设置血氧模式结果: " + (success ? "成功" : "失败"));
                }

                @Override
                public void getBloodOxygenModeResult(int mode) {
                }
            });
        }

        if (view.getId() == R.id.bt_get_blood_oxygen_mode) {
            postView("\n读取血氧模式");
            LmAPILite.GET_BLOOD_OXYGEN_MODE(new IBloodOxygenModeListenerLite() {
                @Override
                public void setBloodOxygenModeResult(boolean success) {
                }

                @Override
                public void getBloodOxygenModeResult(int mode) {
                    postView("\n当前血氧模式: " + (mode == 1 ? "打开" : "关闭"));
                }
            });
        }

        // ==================== 血氧采集周期 ====================
        if (view.getId() == R.id.bt_set_blood_oxygen_collection) {
            postView("\n设置血氧采集周期: 非睡眠=2, 睡眠=4");
            LmAPILite.SET_BLOOD_OXYGEN_COLLECTION(2, 4, new IBloodOxygenCollectionListenerLite() {
                @Override
                public void setBloodOxygenCollectionResult(boolean success) {
                    postView("\n设置采集周期结果: " + (success ? "成功" : "失败"));
                }

                @Override
                public void getBloodOxygenCollectionResult(int nonSleepMultiplier, int sleepMultiplier) {
                }
            });
        }

        if (view.getId() == R.id.bt_get_blood_oxygen_collection) {
            postView("\n读取血氧采集周期");
            LmAPILite.GET_BLOOD_OXYGEN_COLLECTION(new IBloodOxygenCollectionListenerLite() {
                @Override
                public void setBloodOxygenCollectionResult(boolean success) {
                }

                @Override
                public void getBloodOxygenCollectionResult(int nonSleepMultiplier, int sleepMultiplier) {
                    postView("\n非睡眠倍数: " + nonSleepMultiplier);
                    postView("\n睡眠倍数: " + sleepMultiplier);
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
