package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.IGoMoreListener;
import com.lm.sdk.lmApiInter.IAllDayStaminaListenerLite;
import com.lm.sdk.lmApiInter.IHistoryRecordListenerLite;
import com.lm.sdk.lmApiInter.ILongSleepTimeListenerLite;
import com.lm.sdk.lmApiInter.IMenstrualHistoryListenerLite;
import com.lm.sdk.lmApiInter.IMenstrualPredictionListenerLite;
import com.lm.sdk.lmApiInter.ISedentaryReminderListenerLite;
import com.lm.sdk.lmApiInter.ISportStatusPushListenerLite;
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.mode.HistoryRecordLite;
import com.lm.sdk.utils.ImageSaverUtil;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.utils.CmdLogManager;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Aivela定制协议测试Activity
 * 一、操作本地数据（0x36）：未上传/全部历史记录（0x25/0x26）、Gomore睡眠（0x05）
 * 二、系统设置（0x37）：久坐提醒（0x2D/0x2E）、全天体力值（0x2F）、长睡时间（0x30）
 * 三、运动模式（0x38/0x07）
 * 四、女性健康相关（0xC0）：周期写入（0x00）、获取预测（0x01）
 *
 * 历史记录和Gomore睡眠数据除页面显示外，还覆盖保存到本地：
 *   LM/LocalHistoryLog.txt、LM/GoMoreSleepLog.txt（每次发送指令时清空，只保存本次数据）
 *
 * 标题栏"查看日志"弹出全屏对话框展示SDK指令日志（多页面共用CmdLogManager）
 */
public class AivelaProtocolActivity extends BaseActivity implements View.OnClickListener {

    public String TAG = getClass().getSimpleName();
    TextView tv_result;

    /** 开始时间戳（历史记录/Gomore睡眠共用） */
    EditText etStartTs;
    /** 结束时间戳 */
    EditText etEndTs;
    /** 历史记录数据类型（0心率 1HRV 2血氧 3体温 4步数 5久坐 6压力 7呼吸率） */
    EditText etDataType;
    /** 久坐提醒周几（0-6 周日-周六） */
    EditText etWeekday;
    /** 全天体力值（10-100） */
    EditText etStamina;
    /** 久坐提醒配置组，格式"类型,开始分钟,结束分钟"，多组分号隔开 */
    EditText etSedentaryGroups;
    /** 长睡开始小时（0-23） */
    EditText etLongSleepStart;
    /** 长睡结束小时（0-23） */
    EditText etLongSleepEnd;
    /** 长睡计步初始阈值（2-20） */
    EditText etStepThreshold;
    /** 长睡PPG周期测量时长（20-240秒） */
    EditText etPpgMeasureSec;
    /** 女性健康周期开始时间戳数组，逗号隔开 */
    EditText etMenstrualStarts;
    /** 女性健康周期结束时间戳数组，逗号隔开 */
    EditText etMenstrualEnds;
    /** 月经周期天数（13-60，-128重复之前） */
    EditText etCycleDays;

    /** 历史记录本地日志（发送指令时清空，只保存本次数据） */
    private final StringBuilder historyLog = new StringBuilder();
    /** Gomore睡眠本地日志（发送指令时清空，只保存本次数据） */
    private final StringBuilder gomoreLog = new StringBuilder();
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aivela_protocol);

        tv_result = findViewById(R.id.tv_result);
        etStartTs = findViewById(R.id.et_start_ts);
        etEndTs = findViewById(R.id.et_end_ts);
        etDataType = findViewById(R.id.et_data_type);
        etWeekday = findViewById(R.id.et_weekday);
        etStamina = findViewById(R.id.et_stamina);
        etSedentaryGroups = findViewById(R.id.et_sedentary_groups);
        etLongSleepStart = findViewById(R.id.et_long_sleep_start);
        etLongSleepEnd = findViewById(R.id.et_long_sleep_end);
        etStepThreshold = findViewById(R.id.et_step_threshold);
        etPpgMeasureSec = findViewById(R.id.et_ppg_measure_sec);
        etMenstrualStarts = findViewById(R.id.et_menstrual_starts);
        etMenstrualEnds = findViewById(R.id.et_menstrual_ends);
        etCycleDays = findViewById(R.id.et_cycle_days);

        // 一、本地数据（0x36）
        findViewById(R.id.bt_read_unuploaded_history).setOnClickListener(this);
        findViewById(R.id.bt_read_all_history).setOnClickListener(this);
        findViewById(R.id.bt_get_gomore_sleep).setOnClickListener(this);
        // 二、系统设置（0x37）
        findViewById(R.id.bt_set_sedentary).setOnClickListener(this);
        findViewById(R.id.bt_get_sedentary).setOnClickListener(this);
        findViewById(R.id.bt_set_stamina).setOnClickListener(this);
        findViewById(R.id.bt_set_long_sleep).setOnClickListener(this);
        // 三、运动状态推送（0x38）
        findViewById(R.id.bt_set_sport_status_listener).setOnClickListener(this);
        // 四、女性健康（0xC0）
        findViewById(R.id.bt_write_menstrual).setOnClickListener(this);
        findViewById(R.id.bt_get_menstrual_prediction).setOnClickListener(this);
        // 查看指令日志
        findViewById(R.id.tv_cmd_log_btn).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 读取未上传历史记录（0x36/0x25）====================
        if (id == R.id.bt_read_unuploaded_history) {
            readHistoryRecords(true);
        }

        // ==================== 读取全部历史记录（0x36/0x26）====================
        if (id == R.id.bt_read_all_history) {
            readHistoryRecords(false);
        }

        // ==================== 请求Gomore睡眠（0x36/0x05）====================
        if (id == R.id.bt_get_gomore_sleep) {
            long startTs = parseLong(etStartTs, 0);
            long endTs = parseLong(etEndTs, 0);
            postView("\n请求Gomore睡眠: startTs=" + startTs + ", endTs=" + endTs);
            gomoreLog.setLength(0); // 清空旧数据，只保存本次
            gomoreLog.append("请求Gomore睡眠 startTs=").append(startTs)
                    .append(", endTs=").append(endTs).append("\n");
            saveGomoreLog();
            LmAPILite.GET_GOMORE_SLEEP(startTs, endTs, goMoreListener);
        }

        // ==================== 设置久坐提醒（0x37/0x2D）====================
        if (id == R.id.bt_set_sedentary) {
            int weekday = parseInt(etWeekday, 1);
            List<int[]> groups = parseSedentaryGroups();
            postView("\n设置久坐提醒: weekday=" + weekday + ", groups=" + groups.size() + "组");
            LmAPILite.SET_SEDENTARY_REMINDER(weekday, groups, sedentaryListener);
        }

        // ==================== 获取久坐提醒（0x37/0x2E）====================
        if (id == R.id.bt_get_sedentary) {
            int weekday = parseInt(etWeekday, 1);
            postView("\n获取久坐提醒: weekday=" + weekday);
            LmAPILite.GET_SEDENTARY_REMINDER(weekday, sedentaryListener);
        }

        // ==================== 设置全天体力值（0x37/0x2F）====================
        if (id == R.id.bt_set_stamina) {
            float stamina = parseFloat(etStamina, 50f);
            postView("\n设置全天体力值: " + stamina);
            LmAPILite.SET_ALL_DAY_STAMINA(stamina, new IAllDayStaminaListenerLite() {
                @Override
                public void onSetAllDayStaminaResult(boolean success) {
                    postView("\n设置体力值结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 设置长睡时间（0x37/0x30）====================
        if (id == R.id.bt_set_long_sleep) {
            int startHour = parseInt(etLongSleepStart, 22);
            int endHour = parseInt(etLongSleepEnd, 7);
            int stepThreshold = parseInt(etStepThreshold, 10);
            int ppgMeasureSec = parseInt(etPpgMeasureSec, 120);
            postView("\n设置长睡时间: " + startHour + "点-" + endHour + "点"
                    + ", 计步阈值=" + stepThreshold + ", PPG时长=" + ppgMeasureSec + "秒");
            LmAPILite.SET_LONG_SLEEP_TIME(startHour, endHour, stepThreshold, ppgMeasureSec, new ILongSleepTimeListenerLite() {
                @Override
                public void onSetLongSleepTimeResult(boolean success) {
                    postView("\n设置长睡时间结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 设置运动状态监听（0x38/0x07）====================
        if (id == R.id.bt_set_sport_status_listener) {
            postView("\n设置运动状态监听（设备推送时回调）");
            LmAPILite.SET_SPORT_STATUS_LISTENER(new ISportStatusPushListenerLite() {
                @Override
                public void onSportStatus(int status) {
                    postView("\n运动状态推送: " + status + (status == 0 ? "（久坐）" : ""));
                }
            });
        }

        // ==================== 写入过往生理周期（0xC0/0x00）====================
        if (id == R.id.bt_write_menstrual) {
            long[] startTimes = parseLongArray(etMenstrualStarts);
            long[] endTimes = parseLongArray(etMenstrualEnds);
            postView("\n写入生理周期: " + startTimes.length + "组");
            LmAPILite.WRITE_MENSTRUAL_HISTORY(startTimes, endTimes, new IMenstrualHistoryListenerLite() {
                @Override
                public void onWriteMenstrualHistoryResult(boolean success) {
                    postView("\n写入生理周期结果: " + (success ? "成功" : "失败"));
                }
            });
        }

        // ==================== 查看指令日志 =====================
        if (id == R.id.tv_cmd_log_btn) {
            //右上角查看指令日志（多页面共用CmdLogManager）
            CmdLogManager.getInstance().show(this);
        }

        // ==================== 获取预测（0xC0/0x01）====================
        if (id == R.id.bt_get_menstrual_prediction) {
            int cycleDays = parseInt(etCycleDays, 28);
            postView("\n获取预测: 周期=" + cycleDays + "天");
            LmAPILite.GET_MENSTRUAL_PREDICTION(cycleDays, new IMenstrualPredictionListenerLite() {
                @Override
                public void onGetMenstrualPrediction(int status, int ovulationCycle, int menstrualCycle,
                                                     long[] ovulationDates, long[] periodDates,
                                                     int periodDuration, int fertileBefore, int fertileAfter) {
                    StringBuilder sb = new StringBuilder();
                    sb.append("\n预测结果: 状态=").append(status);
                    if (status != 0) {
                        sb.append(status == 100 ? "（女性健康未使能）"
                                : status == 102 ? "（预测周期超范围10-50天）"
                                : status == 202 ? "（输入周期无效）" : "（未知）");
                    }
                    sb.append("\n  排卵周期=").append(ovulationCycle).append("天, 月经周期=").append(menstrualCycle).append("天");
                    sb.append("\n  经期时长=").append(periodDuration).append("天, 排卵前易孕期=").append(fertileBefore)
                            .append("天, 排卵后易孕期=").append(fertileAfter).append("天");
                    for (int i = 0; i < ovulationDates.length; i++) {
                        sb.append("\n  排卵日").append(i + 1).append(": ").append(formatTime(ovulationDates[i]));
                    }
                    for (int i = 0; i < periodDates.length; i++) {
                        sb.append("\n  月经日").append(i + 1).append(": ").append(formatTime(periodDates[i]));
                    }
                    postView(sb.toString());
                }
            });
        }
    }

    /**
     * 历史记录监听（0x25未上传/0x26全部共用）
     */
    private final IHistoryRecordListenerLite historyRecordListener = new IHistoryRecordListenerLite() {
        @Override
        public void onHistoryRecords(int totalNum, List<HistoryRecordLite> records) {
            StringBuilder sb = new StringBuilder();
            sb.append("\n收到历史记录包: 本包").append(records.size()).append("条, 总数=").append(totalNum);
            for (HistoryRecordLite record : records) {
                sb.append("\n  ").append(formatTime(record.timestamp)).append(" ")
                        .append(record.toString());
            }
            postView(sb.toString());
            // 追加到本地日志并覆盖保存
            historyLog.append(sb).append("\n");
            saveHistoryLog();
        }

        @Override
        public void onHistoryRecordFinish(int totalCount) {
            String msg = "\n历史记录读取完成, 共" + totalCount + "条";
            postView(msg);
            historyLog.append(msg).append("\n");
            saveHistoryLog();
        }

        @Override
        public void onHistoryRecordBusy() {
            String msg = "\n历史记录读取失败: 设备繁忙";
            postView(msg);
            historyLog.append(msg).append("\n");
            saveHistoryLog();
        }
    };

    /**
     * Gomore睡眠监听（0x36/0x05）
     */
    private final IGoMoreListener goMoreListener = new IGoMoreListener() {
        @Override
        public void overviewOfSleep(GoMoreSleep goMoreSleep) {
            String msg = "\n[睡眠总览] " + goMoreSleep;
            postView(msg);
            gomoreLog.append(msg).append("\n");
            saveGomoreLog();
        }

        @Override
        public void sleepStaging(GoMoreSleep goMoreSleep) {
            String msg = "\n[睡眠分期] " + goMoreSleep;
            postView(msg);
            gomoreLog.append(msg).append("\n");
            saveGomoreLog();
        }

        @Override
        public void noSleepData() {
            String msg = "\n[无睡眠数据]";
            postView(msg);
            gomoreLog.append(msg).append("\n");
            saveGomoreLog();
        }

        @Override
        public void dataUploadFinish() {
            String msg = "\n[Gomore数据上传结束]";
            postView(msg);
            gomoreLog.append(msg).append("\n");
            saveGomoreLog();
        }
    };

    /**
     * 久坐提醒监听（0x2D/0x2E共用）
     */
    private final ISedentaryReminderListenerLite sedentaryListener = new ISedentaryReminderListenerLite() {
        @Override
        public void onSetSedentaryReminderResult(int weekday, boolean success) {
            postView("\n设置久坐提醒结果: " + (success ? "成功, 周几=" + weekday : "失败"));
        }

        @Override
        public void onGetSedentaryReminderResult(int weekday, List<int[]> groups) {
            StringBuilder sb = new StringBuilder();
            sb.append("\n久坐提醒配置: weekday=").append(weekday);
            for (int i = 0; i < groups.size(); i++) {
                int[] group = groups.get(i);
                sb.append("\n  配置").append(i).append(": 类型=").append(group[0])
                        .append("(").append(typeName(group[0])).append(")")
                        .append(", 开始=").append(group[1]).append("分(").append(formatMinute(group[1])).append(")")
                        .append(", 结束=").append(group[2]).append("分(").append(formatMinute(group[2])).append(")");
            }
            postView(sb.toString());
        }
    };

    /**
     * 读取历史记录（0x25未上传/0x26全部）
     */
    private void readHistoryRecords(boolean unuploaded) {
        long startTs = parseLong(etStartTs, 0);
        long endTs = parseLong(etEndTs, 0);
        int dataType = parseInt(etDataType, 0);
        postView("\n读取" + (unuploaded ? "未上传" : "全部") + "历史记录: startTs=" + startTs
                + ", endTs=" + endTs + ", dataType=" + dataType + "(" + dataTypeName(dataType) + ")");
        historyLog.setLength(0); // 清空旧数据，只保存本次
        historyLog.append("读取").append(unuploaded ? "未上传" : "全部").append("历史记录 startTs=").append(startTs)
                .append(", endTs=").append(endTs)
                .append(", dataType=").append(dataType).append("(").append(dataTypeName(dataType)).append(")\n");
        saveHistoryLog();
        if (unuploaded) {
            LmAPILite.READ_UNUPLOADED_HISTORY_RECORD(startTs, endTs, dataType, historyRecordListener);
        } else {
            LmAPILite.READ_ALL_HISTORY_RECORD(startTs, endTs, dataType, historyRecordListener);
        }
    }

    /**
     * 解析久坐提醒配置组输入："2,540,720;2,840,1080" -> [[2,540,720],[2,840,1080]]
     */
    private List<int[]> parseSedentaryGroups() {
        List<int[]> groups = new ArrayList<>();
        String text = etSedentaryGroups.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            return groups;
        }
        try {
            String[] groupArray = text.split(";");
            for (String group : groupArray) {
                String[] parts = group.trim().split(",");
                if (parts.length == 3) {
                    groups.add(new int[]{Integer.parseInt(parts[0].trim()),
                            Integer.parseInt(parts[1].trim()),
                            Integer.parseInt(parts[2].trim())});
                }
            }
        } catch (NumberFormatException e) {
            postView("\n久坐配置格式错误: " + e.getMessage());
        }
        return groups;
    }

    /**
     * 解析逗号分隔的时间戳数组输入
     */
    private long[] parseLongArray(EditText editText) {
        String text = editText.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            return new long[0];
        }
        try {
            String[] parts = text.split(",");
            long[] values = new long[parts.length];
            for (int i = 0; i < parts.length; i++) {
                values[i] = Long.parseLong(parts[i].trim());
            }
            return values;
        } catch (NumberFormatException e) {
            postView("\n时间戳数组格式错误: " + e.getMessage());
            return new long[0];
        }
    }

    private int parseInt(EditText editText, int defaultValue) {
        try {
            return Integer.parseInt(editText.getText().toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private long parseLong(EditText editText, long defaultValue) {
        try {
            return Long.parseLong(editText.getText().toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private float parseFloat(EditText editText, float defaultValue) {
        try {
            return Float.parseFloat(editText.getText().toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * 覆盖保存历史记录日志到本地（LM/LocalHistoryLog.txt）
     */
    private void saveHistoryLog() {
        ImageSaverUtil.saveImageToInternalStorage(this, historyLog.toString(), "LM", "LocalHistoryLog.txt", false);
    }

    /**
     * 覆盖保存Gomore睡眠日志到本地（LM/GoMoreSleepLog.txt）
     */
    private void saveGomoreLog() {
        ImageSaverUtil.saveImageToInternalStorage(this, gomoreLog.toString(), "LM", "GoMoreSleepLog.txt", false);
    }

    private String formatTime(long timestamp) {
        if (timestamp <= 0) {
            return String.valueOf(timestamp);
        }
        return dateFormat.format(new Date(timestamp * 1000));
    }

    /**
     * 分钟数转HH:mm显示
     */
    private String formatMinute(int minute) {
        return String.format(Locale.CHINA, "%02d:%02d", minute / 60, minute % 60);
    }

    private String typeName(int type) {
        switch (type) {
            case 0: return "小睡";
            case 1: return "长睡";
            case 2: return "活动";
            default: return "未知";
        }
    }

    private String dataTypeName(int dataType) {
        switch (dataType) {
            case 0: return "心率";
            case 1: return "HRV";
            case 2: return "血氧";
            case 3: return "体温";
            case 4: return "步数/体力/卡路里/MET";
            case 5: return "久坐";
            case 6: return "压力";
            case 7: return "呼吸率";
            default: return "未知";
        }
    }

    /**
     * 打印日志到界面
     */
    public void postView(String value) {
        runOnUiThread(() -> {
            tv_result.setMovementMethod(ScrollingMovementMethod.getInstance());
            tv_result.setScrollbarFadingEnabled(false);
            tv_result.append(value);
            int scrollAmount = tv_result.getLayout().getLineTop(tv_result.getLineCount()) - tv_result.getHeight();
            if (scrollAmount > 0)
                tv_result.scrollTo(0, scrollAmount);
            else
                tv_result.scrollTo(0, 0);
        });
    }
}
