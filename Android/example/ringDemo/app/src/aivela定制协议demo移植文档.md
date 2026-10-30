# aivela定制协议 Demo 移植文档

> 本文档汇总 com.lomo.demo（demo app 模块）针对 aivela 定制协议的全部修改，另一个项目可按本文档直接复制。
> 前提：使用本项目最新的 blelibrary（SDK 层改动见《aivela定制协议.md》）。
> 协议版本：V0.4（新增删除全部历史记录指令 0x36/0x3、蓝牙名称长度上限 12→20、0xA0 绑定/连接请求删 timeMillis 且响应精简为固定 28 字节；含 V0.3：历史记录 Subcmd 调整、长睡 4 参数、电量推送 2 字节、佩戴检测/飞行模式/工作模式/异常日志/Shipmode）。

## 一、修改清单

| 序号 | 文件 | 操作 | 说明 |
|---|---|---|---|
| 1 | `app/src/main/java/com/lomo/demo/activity/AivelaProtocolActivity.java` | 新增 | 测试页（13个入参输入框 + 11个按钮 + 指令日志对话框；V0.3 长睡改4参数） |
| 2 | `app/src/main/res/layout/activity_aivela_protocol.xml` | 新增 | 测试页布局（四大分区标题栏；V0.3 长睡参数两行输入） |
| 3 | `app/src/main/res/layout/dialog_cmd_log.xml` | 新增 | 指令日志全屏对话框布局 |
| 4 | `app/src/main/AndroidManifest.xml` | 修改 | 注册 AivelaProtocolActivity |
| 5 | `app/src/main/java/com/lomo/demo/activity/TestActivity.java` | 修改 | 跳转按钮 + V0.3 新增 7 个协议入口（佩戴检测/飞行模式/工作模式/异常日志读取/删除/Shipmode/复位测试）+ 电量推送充电状态显示 + V0.4 新增删除历史记录入口、APP_CONNECT 调用适配新签名 |
| 6 | `app/src/main/res/layout/activity_test.xml` | 修改 | 添加 V0.3 七个协议按钮（"aivela定制协议"跳转按钮放最下面）+ V0.4 异常日志行追加"删除历史记录"按钮 |
| 7 | `app/src/main/java/com/lomo/demo/application/App.java` | 修改 | `LmAPILite.init` 换成带 `ICMDLogListener` 的重载 |
| 8 | `app/src/main/java/com/lomo/demo/activity/MainActivity.java` | 修改 | 删除 `import com.lm.sdk.LmAPI;`（LmAPI 类已删除，统一用 LmAPILite） |

## 二、SDK 层前置依赖（blelibrary）

另一个项目直接整体替换为本项目的 blelibrary 即可，demo 层代码依赖以下 SDK 能力：

- 接口：`com.lm.sdk.inter.ICMDLogListener`（指令日志回调）
- Lite 系列接口（`com.lm.sdk.lmApiInter`）：`IHistoryRecordListenerLite`、`ISedentaryReminderListenerLite`、`IAllDayStaminaListenerLite`、`ILongSleepTimeListenerLite`、`ISportStatusPushListenerLite`、`IMenstrualHistoryListenerLite`、`IMenstrualPredictionListenerLite`、`IWearStatusListenerLite`（V0.3）、`IAirplaneModeListenerLite`（V0.3）、`IWorkModeListenerLite`（V0.3）、`IExceptionLogListenerLite`（V0.3）、`IDeleteHistoryListenerLite`（V0.4 新增）、`IBindConnectRefreshListenerLite`（已有，V0.4 回调数据类精简）、`IBatteryListenerLite`（已有，V0.3 签名变更）
- 数据类：`com.lm.sdk.mode.HistoryRecordLite`（V0.3 新增 wearStatus 字段）、`com.lm.sdk.mode.GoMoreSleep`（已有，V0.3 新增 reportTs 字段）、`com.lm.sdk.mode.SystemControlLiteBean`（已有，V0.4 按协议重写为 8 字段：固件版本、硬件版本、电量、充电状态、当前计步、自检标识、gomore授权、工作模式）
- 老接口：`com.lm.sdk.inter.IGoMoreListener`（Gomore睡眠复用已有接口）
- `LmAPILite` 方法：
  - `init(Application, ICMDLogListener)`（初始化重载）
  - `SET_CMD_LOG_LISTENER(ICMDLogListener)`（单独设置/清除指令日志监听，传 null 清除）
  - `READ_UNUPLOADED_HISTORY_RECORD(long, long, int, IHistoryRecordListenerLite)`（0x36/0x2E，V0.3 由 0x25 调整）
  - `READ_ALL_HISTORY_RECORD(long, long, int, IHistoryRecordListenerLite)`（0x36/0x2F，V0.3 由 0x26 调整）
  - `GET_GOMORE_SLEEP(long, long, IGoMoreListener)`（0x36/0x05 带时间范围重载）
  - `SET_SEDENTARY_REMINDER(int, List<int[]>, ISedentaryReminderListenerLite)`（0x37/0x2D）
  - `GET_SEDENTARY_REMINDER(int, ISedentaryReminderListenerLite)`（0x37/0x2E）
  - `SET_ALL_DAY_STAMINA(float, IAllDayStaminaListenerLite)`（0x37/0x2F）
  - `SET_LONG_SLEEP_TIME(int, int, int, int, ILongSleepTimeListenerLite)`（0x37/0x30，V0.3 由 2 参数扩为 4 参数：长睡开始小时、长睡结束小时、计步初始阈值 2-20、PPG周期测量时长 20-240 秒）
  - `SET_SPORT_STATUS_LISTENER(ISportStatusPushListenerLite)`（0x38/0x07，纯监听不发包）
  - `WRITE_MENSTRUAL_HISTORY(long[], long[], IMenstrualHistoryListenerLite)`（0xC0/0x00）
  - `GET_MENSTRUAL_PREDICTION(int, IMenstrualPredictionListenerLite)`（0xC0/0x01）
  - `GET_WEAR_STATUS(IWearStatusListenerLite)`（0x31/0x5，V0.3 新增，支持设备主动推送）
  - `SET_AIRPLANE_MODE(IAirplaneModeListenerLite)`（0x37/0x6，V0.3 新增）
  - `GET_WORK_MODE(IWorkModeListenerLite)`（0x37/0x39，V0.3 新增，支持设备主动推送）
  - `GET_EXCEPTION_LOG(IExceptionLogListenerLite)`（0x36/0x25，V0.3 新增，原 subcmd 由历史记录调整为异常日志读取）
  - `DELETE_EXCEPTION_LOG(IExceptionLogListenerLite)`（0x36/0x26，V0.3 新增）
  - `SET_SHIP_MODE()`（0xF2/0x5，V0.3 新增，无回调）
  - `RESET_RESTART()`（0xF2/0x9，已有，无回调）
  - `DELETE_HISTORY_RECORD(IDeleteHistoryListenerLite)`（0x36/0x3，V0.4 新增，删除全部本地数据历史记录；系统繁忙时设备空闲执行，收到响应即回调成功）
  - `APP_BIND(IBindConnectRefreshListenerLite)` / `APP_CONNECT(IBindConnectRefreshListenerLite)`（0xA0/0x0、0xA0/0x1，已有，V0.4 删除 timeMillis 入参，请求时间由 SDK 内部取系统当前时间；响应 Data 固定 28 字节，解析为精简后的 SystemControlLiteBean）
  - `Set_BlueTooth_Name(String, ISystemControlListenerLite)` / `Get_BlueTooth_Name(ISystemControlListenerLite)`（0x37/0x3、0x37/0x4，已有，V0.4 蓝牙名称长度上限由 12 改为 20，设置成功后设备 1s 自动断开并以新名称重新广播，demo 调用代码无需改动）
  - `GET_BATTERY(byte, IBatteryListenerLite)`（已有，V0.3 电量推送 Data 改 2 字节，`battery_push(electricity, chargingStatus)` 签名变更，旧固件 1 字节时 chargingStatus 回调 -1）
- 工具类：`com.lm.sdk.utils.ImageSaverUtil.saveImageToInternalStorage(Context, String, String, String, boolean)`（已有）

## 三、新增文件（直接复制全文）

### 1. AivelaProtocolActivity.java

路径：`app/src/main/java/com/lomo/demo/activity/AivelaProtocolActivity.java`

功能说明：
- 四大分区：一、操作本地数据（0x36）二、系统设置（0x37）三、运动模式（0x38）四、女性健康相关（0xC0）
- 入参全部由输入框输入，页面顶部数据区域固定 300dp，下方按钮区可滚动
- 历史记录、Gomore睡眠数据除页面显示外，还覆盖保存到本地：`LM/LocalHistoryLog.txt`、`LM/GoMoreSleepLog.txt`（每次发送指令时清空旧数据，只保存本次指令返回的数据）
- 进入页面后通过 `LmAPILite.SET_CMD_LOG_LISTENER` 捕获 SDK 指令日志（"====发送指令==="、"===原始数据==="、"===执行指令==="、"===执行指令超时==="，含产生时间），标题栏"查看日志"弹出全屏对话框展示，支持"清空"和"关闭"，对话框打开时实时刷新并滚动到底部

依赖：`com.lomo.demo.base.BaseActivity`（demo 基类，另一个项目用任意 Activity 基类替换即可）、`com.lomo.demo.R`

```java
package com.lomo.demo.activity;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.EditText;
import android.widget.ScrollView;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.ICMDLogListener;
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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Aivela定制协议测试Activity
 * 一、操作本地数据（0x36）：未上传/全部历史记录（0x2E/0x2F，V0.3调整）、Gomore睡眠（0x05）
 * 二、系统设置（0x37）：久坐提醒（0x2D/0x2E）、全天体力值（0x2F）、长睡时间（0x30，V0.3扩为4参数）
 * 三、运动模式（0x38/0x07）
 * 四、女性健康相关（0xC0）：周期写入（0x00）、获取预测（0x01）
 *
 * 历史记录和Gomore睡眠数据除页面显示外，还覆盖保存到本地：
 *   LM/LocalHistoryLog.txt、LM/GoMoreSleepLog.txt（每次发送指令时清空，只保存本次数据）
 *
 * 进入页面后捕获SDK指令日志（"====发送指令==="和"===原始数据==="，含时间），
 * 标题栏"查看日志"弹出全屏对话框展示，支持"清空"和"关闭"
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
    /** 计步初始阈值（2-20） */
    EditText etStepThreshold;
    /** PPG周期测量时长（20-240秒） */
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
    /** 指令日志（"====发送指令==="和"===原始数据==="，含产生时间） */
    private final StringBuilder cmdLog = new StringBuilder();
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    private final SimpleDateFormat logTimeFormat = new SimpleDateFormat("HH:mm:ss.SSS", Locale.CHINA);
    /** 指令日志全屏对话框 */
    private Dialog cmdLogDialog;
    private TextView tvCmdLog;
    private ScrollView svCmdLog;

    /**
     * 指令日志监听器：捕获SDK发送指令和接收原始数据的日志
     */
    private final ICMDLogListener cmdLogListener = new ICMDLogListener() {
        @Override
        public void log(String label, String type, String logs) {
            synchronized (cmdLog) {
                cmdLog.append("[").append(logTimeFormat.format(new Date())).append("] ")
                        .append(type).append(logs).append("\n");
            }
            // 对话框打开时实时刷新显示
            if (cmdLogDialog != null && cmdLogDialog.isShowing() && tvCmdLog != null) {
                runOnUiThread(() -> {
                    synchronized (cmdLog) {
                        tvCmdLog.setText(cmdLog.toString());
                    }
                    svCmdLog.post(() -> svCmdLog.fullScroll(ScrollView.FOCUS_DOWN));
                });
            }
        }
    };

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

        // 进入页面，开始捕获SDK指令日志（发送指令/原始数据）
        LmAPILite.SET_CMD_LOG_LISTENER(cmdLogListener);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // 退出页面，清除指令日志监听
        LmAPILite.SET_CMD_LOG_LISTENER(null);
        if (cmdLogDialog != null) {
            cmdLogDialog.dismiss();
            cmdLogDialog = null;
        }
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 读取未上传历史记录（0x36/0x2E）====================
        if (id == R.id.bt_read_unuploaded_history) {
            readHistoryRecords(true);
        }

        // ==================== 读取全部历史记录（0x36/0x2F）====================
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
            showCmdLogDialog();
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
     * 历史记录监听（0x2E未上传/0x2F全部共用）
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
     * 读取历史记录（0x2E未上传/0x2F全部）
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
     * 弹出全屏对话框展示指令日志，提供"清空"和"关闭"按钮
     */
    private void showCmdLogDialog() {
        if (cmdLogDialog == null) {
            cmdLogDialog = new Dialog(this, android.R.style.Theme_DeviceDefault_NoActionBar_Fullscreen);
            // 全屏深色主题默认黑底，把窗口背景也刷成白色，避免黑底黑字看不见
            if (cmdLogDialog.getWindow() != null) {
                cmdLogDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.WHITE));
            }
            cmdLogDialog.setContentView(R.layout.dialog_cmd_log);
            tvCmdLog = cmdLogDialog.findViewById(R.id.tv_cmd_log);
            svCmdLog = cmdLogDialog.findViewById(R.id.sv_cmd_log);
            // 清空日志字符串并刷新显示
            cmdLogDialog.findViewById(R.id.bt_clear_log).setOnClickListener(v -> {
                synchronized (cmdLog) {
                    cmdLog.setLength(0);
                }
                tvCmdLog.setText("暂无日志");
            });
            // 关闭对话框
            cmdLogDialog.findViewById(R.id.bt_close_log).setOnClickListener(v -> cmdLogDialog.dismiss());
        }
        synchronized (cmdLog) {
            String log = cmdLog.toString();
            tvCmdLog.setText(log.isEmpty() ? "暂无日志" : log);
        }
        cmdLogDialog.show();
        // 滚动到底部显示最新日志
        svCmdLog.post(() -> svCmdLog.fullScroll(ScrollView.FOCUS_DOWN));
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
```

### 2. activity_aivela_protocol.xml

路径：`app/src/main/res/layout/activity_aivela_protocol.xml`

结构：标题栏（含"查看日志"入口）→ 数据区域（固定300dp）→ 底部按钮区 ScrollView（weight=1，内部四大分区，每区有标题栏）

依赖资源：`@color/colorPrimary`、`@color/colorPrimaryDark`、`@color/white`、`@drawable/button_bg_state`（demo 已有）

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:paddingBottom="10dp"
    android:fitsSystemWindows="true"
    tools:context=".activity.AivelaProtocolActivity">

    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="45dp"
        android:background="@color/colorPrimary">
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="aivela定制协议"
            android:textSize="18sp"
            android:layout_centerInParent="true"
            android:textColor="@color/white"/>
        <TextView
            android:id="@+id/tv_cmd_log_btn"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="查看日志"
            android:textSize="14sp"
            android:layout_centerVertical="true"
            android:layout_marginRight="10dp"
            android:layout_alignParentRight="true"
            android:textColor="@color/white"/>
    </RelativeLayout>

    <TextView
        android:id="@+id/tv_result"
        android:layout_width="match_parent"
        android:layout_height="300dp"
        android:text="数据区域"
        android:scrollbars="vertical"
        android:padding="10dp"
        android:lineSpacingExtra="5dp"
        android:textSize="14sp"
        android:textColor="@color/colorPrimaryDark"/>

    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:padding="10dp"
            android:orientation="vertical">

            <!-- ==================== 一、操作本地数据（cmd=0x36）==================== -->
            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:background="@color/colorPrimary"
                android:padding="5dp"
                android:text="一、操作本地数据（0x36）"
                android:textColor="@color/white"
                android:textSize="14sp"
                android:textStyle="bold"/>

            <!-- 时间戳输入（历史记录/Gomore睡眠共用） -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="开始时间戳:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_start_ts"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="秒，0为全部"
                    android:text="0"
                    android:inputType="number"
                    android:textSize="12sp"/>
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="结束时间戳:"
                    android:textSize="12sp"
                    android:layout_marginLeft="5dp"/>
                <EditText
                    android:id="@+id/et_end_ts"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="秒"
                    android:text="0"
                    android:inputType="number"
                    android:textSize="12sp"/>
            </LinearLayout>

            <!-- 历史记录数据类型输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="数据类型:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_data_type"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="0心率1HRV2血氧3体温4步数5久坐6压力7呼吸率"
                    android:text="0"
                    android:inputType="number"
                    android:textSize="12sp"/>
            </LinearLayout>

            <!-- 历史记录按钮 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="30dp"
                android:layout_marginTop="5dp"
                android:orientation="horizontal">
                <Button
                    android:id="@+id/bt_read_unuploaded_history"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="读未上传历史(0x2E)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
                <Button
                    android:id="@+id/bt_read_all_history"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="读全部历史(0x2F)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
                <Button
                    android:id="@+id/bt_get_gomore_sleep"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="Gomore睡眠(0x05)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

            <!-- ==================== 二、系统设置（cmd=0x37）==================== -->
            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:background="@color/colorPrimary"
                android:padding="5dp"
                android:text="二、系统设置（0x37）"
                android:textColor="@color/white"
                android:textSize="14sp"
                android:textStyle="bold"/>

            <!-- 久坐提醒输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="周几:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_weekday"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="0-6周日-周六"
                    android:text="1"
                    android:inputType="number"
                    android:textSize="12sp"/>
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="体力值:"
                    android:textSize="12sp"
                    android:layout_marginLeft="5dp"/>
                <EditText
                    android:id="@+id/et_stamina"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="10-100"
                    android:text="50"
                    android:inputType="numberDecimal"
                    android:textSize="12sp"/>
            </LinearLayout>

            <!-- 久坐提醒配置组输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="久坐配置:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_sedentary_groups"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="类型,开始分钟,结束分钟;多组分号隔开"
                    android:text="2,540,720;2,840,1080"
                    android:textSize="12sp"/>
            </LinearLayout>

            <!-- 久坐提醒按钮 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="30dp"
                android:layout_marginTop="5dp"
                android:orientation="horizontal">
                <Button
                    android:id="@+id/bt_set_sedentary"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="设置久坐提醒(0x2D)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
                <Button
                    android:id="@+id/bt_get_sedentary"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="获取久坐提醒(0x2E)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
                <Button
                    android:id="@+id/bt_set_stamina"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="设置体力值(0x2F)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

            <!-- 长睡时间输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="长睡开始小时:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_long_sleep_start"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="0-23"
                    android:text="22"
                    android:inputType="number"
                    android:textSize="12sp"/>
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="结束小时:"
                    android:textSize="12sp"
                    android:layout_marginLeft="5dp"/>
                <EditText
                    android:id="@+id/et_long_sleep_end"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="0-23"
                    android:text="7"
                    android:inputType="number"
                    android:textSize="12sp"/>
            </LinearLayout>

            <!-- 长睡算法参数输入（计步初始阈值+PPG周期测量时长） -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="计步阈值:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_step_threshold"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="2-20"
                    android:text="10"
                    android:inputType="number"
                    android:textSize="12sp"/>
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="PPG时长(秒):"
                    android:textSize="12sp"
                    android:layout_marginLeft="5dp"/>
                <EditText
                    android:id="@+id/et_ppg_measure_sec"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="20-240"
                    android:text="120"
                    android:inputType="number"
                    android:textSize="12sp"/>
                <Button
                    android:id="@+id/bt_set_long_sleep"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginLeft="5dp"
                    android:text="设置长睡(0x30)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

            <!-- ==================== 三、运动模式（cmd=0x38）==================== -->
            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:background="@color/colorPrimary"
                android:padding="5dp"
                android:text="三、运动模式（0x38）"
                android:textColor="@color/white"
                android:textSize="14sp"
                android:textStyle="bold"/>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="30dp"
                android:layout_marginTop="10dp"
                android:orientation="horizontal">
                <Button
                    android:id="@+id/bt_set_sport_status_listener"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="设置运动状态监听(0x38/0x07)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

            <!-- ==================== 四、女性健康相关（cmd=0xC0）==================== -->
            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:background="@color/colorPrimary"
                android:padding="5dp"
                android:text="四、女性健康相关（0xC0）"
                android:textColor="@color/white"
                android:textSize="14sp"
                android:textStyle="bold"/>

            <!-- 周期时间戳数组输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="周期开始:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_menstrual_starts"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="秒,逗号隔开"
                    android:textSize="12sp"/>
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="结束:"
                    android:textSize="12sp"
                    android:layout_marginLeft="5dp"/>
                <EditText
                    android:id="@+id/et_menstrual_ends"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="秒,逗号隔开"
                    android:textSize="12sp"/>
                <Button
                    android:id="@+id/bt_write_menstrual"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginLeft="5dp"
                    android:text="写入周期(0x00)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

            <!-- 获取预测输入 -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="月经周期天数:"
                    android:textSize="12sp"/>
                <EditText
                    android:id="@+id/et_cycle_days"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:hint="13-60，-128重复之前"
                    android:text="28"
                    android:inputType="numberSigned"
                    android:textSize="12sp"/>
                <Button
                    android:id="@+id/bt_get_menstrual_prediction"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginLeft="5dp"
                    android:text="获取预测(0x01)"
                    android:textSize="11sp"
                    android:textColor="@color/white"
                    android:background="@drawable/button_bg_state"/>
            </LinearLayout>

        </LinearLayout>
    </ScrollView>
</LinearLayout>
```

> 注意：`et_menstrual_starts` / `et_menstrual_ends` 输入逗号分隔的多个时间戳，**不能**设置 `android:inputType="number"`（会无法输入逗号）。

### 3. dialog_cmd_log.xml

路径：`app/src/main/res/layout/dialog_cmd_log.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@android:color/white"
    android:fitsSystemWindows="true">

    <!-- 标题栏 -->
    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="45dp"
        android:background="@color/colorPrimary">
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="指令日志"
            android:textSize="18sp"
            android:layout_centerInParent="true"
            android:textColor="@color/white"/>
    </RelativeLayout>

    <!-- 日志内容区 -->
    <ScrollView
        android:id="@+id/sv_cmd_log"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:fillViewport="true">
        <TextView
            android:id="@+id/tv_cmd_log"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:padding="8dp"
            android:fontFamily="monospace"
            android:textSize="12sp"
            android:textColor="@color/colorPrimaryDark"
            android:text="暂无日志"/>
    </ScrollView>

    <!-- 底部按钮 -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="5dp">
        <Button
            android:id="@+id/bt_clear_log"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:text="清空"
            android:textSize="14sp"
            android:textColor="@color/white"
            android:background="@drawable/button_bg_state"/>
        <Button
            android:id="@+id/bt_close_log"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:layout_marginLeft="10dp"
            android:text="关闭"
            android:textSize="14sp"
            android:textColor="@color/white"
            android:background="@drawable/button_bg_state"/>
    </LinearLayout>
</LinearLayout>
```

## 四、修改文件（按位置添加片段）

### 4. AndroidManifest.xml

在 `<application>` 节点内任意 Activity 注册之后添加：

```xml
<activity
    android:name=".activity.AivelaProtocolActivity"
    android:configChanges="orientation|keyboardHidden"
    android:exported="true"
    android:windowSoftInputMode="stateHidden|stateUnchanged"
    android:screenOrientation="user">

</activity>
```

> `windowSoftInputMode="stateHidden|stateUnchanged"` 防止进入页面时自动弹出软键盘。

### 5. TestActivity.java

（1）import 区添加（V0.3/V0.4 新增接口）：

```java
import com.lm.sdk.lmApiInter.IWearStatusListenerLite;
import com.lm.sdk.lmApiInter.IAirplaneModeListenerLite;
import com.lm.sdk.lmApiInter.IWorkModeListenerLite;
import com.lm.sdk.lmApiInter.IExceptionLogListenerLite;
import com.lm.sdk.lmApiInter.IDeleteHistoryListenerLite;
```

（2）类成员区添加 5 个监听器（V0.3 新增 4 个 + V0.4 新增 1 个）：

```java
/** 佩戴检测监听（0x31/0x5，V0.3新增，查询响应/主动推送） */
private IWearStatusListenerLite iWearStatusListenerLite = new IWearStatusListenerLite() {
    @Override
    public void onWearStatus(int wearStatus) {
        postView("\n佩戴检测:" + (wearStatus == 1 ? "佩戴" : "未佩戴"));
    }
};

/** 飞行模式监听（0x37/0x6，V0.3新增） */
private IAirplaneModeListenerLite iAirplaneModeListenerLite = new IAirplaneModeListenerLite() {
    @Override
    public void onSetAirplaneModeResult(boolean success) {
        postView("\n设置飞行模式:" + (success ? "成功" : "失败"));
    }
};

/** 工作模式监听（0x37/0x39，V0.3新增，查询响应/主动推送） */
private IWorkModeListenerLite iWorkModeListenerLite = new IWorkModeListenerLite() {
    @Override
    public void onWorkMode(int workMode) {
        String mode;
        switch (workMode) {
            case 0: mode = "日常"; break;
            case 1: mode = "运动"; break;
            case 2: mode = "睡眠"; break;
            default: mode = "未知(" + workMode + ")"; break;
        }
        postView("\n戒指工作模式:" + mode);
    }
};

/** 异常日志监听（0x36/0x25读取、0x36/0x26删除，V0.3新增） */
private IExceptionLogListenerLite iExceptionLogListenerLite = new IExceptionLogListenerLite() {
    @Override
    public void onExceptionLog(int totalPack, int packNo, long timestamp, String log) {
        postView("\n异常日志(包" + (packNo + 1) + "/" + totalPack + ",时间戳" + timestamp + "):" + log);
    }

    @Override
    public void onExceptionLogDeleted(boolean success) {
        postView("\n删除异常日志:" + (success ? "成功" : "失败"));
    }
};

/** 删除历史记录监听（0x36/0x3，V0.4新增） */
private IDeleteHistoryListenerLite iDeleteHistoryListenerLite = new IDeleteHistoryListenerLite() {
    @Override
    public void onDeleteHistoryResult(boolean success) {
        postView("\n删除全部历史记录:" + (success ? "成功" : "失败"));
    }
};
```

（3）`onCreate` 中其他 `findViewById(...).setOnClickListener(this);` 之后添加：

```java
findViewById(R.id.bt_aivela_protocol).setOnClickListener(this);
findViewById(R.id.bt_wear_status).setOnClickListener(this);
findViewById(R.id.bt_airplane_mode).setOnClickListener(this);
findViewById(R.id.bt_work_mode).setOnClickListener(this);
findViewById(R.id.bt_get_exception_log).setOnClickListener(this);
findViewById(R.id.bt_delete_exception_log).setOnClickListener(this);
findViewById(R.id.bt_delete_history).setOnClickListener(this);
findViewById(R.id.bt_ship_mode).setOnClickListener(this);
findViewById(R.id.bt_reset_restart).setOnClickListener(this);
```

（4）`onClick` 方法末尾（其他 `if(view.getId()==R.id....)` 判断之后）添加：

```java
if(view.getId()==R.id.bt_aivela_protocol) {
    Intent intent=new Intent(this,AivelaProtocolActivity.class);
    startActivity(intent);
}

// ==== V0.3新增协议入口 ====
if(view.getId()==R.id.bt_wear_status) {
    postView("\n佩戴检测状态查询（0x31/0x5，设备主动推送时同样回调）");
    LmAPILite.GET_WEAR_STATUS(iWearStatusListenerLite);
}

if(view.getId()==R.id.bt_airplane_mode) {
    postView("\n设置飞行模式（0x37/0x6）");
    LmAPILite.SET_AIRPLANE_MODE(iAirplaneModeListenerLite);
}

if(view.getId()==R.id.bt_work_mode) {
    postView("\n获取戒指工作模式（0x37/0x39，设备主动推送时同样回调）");
    LmAPILite.GET_WORK_MODE(iWorkModeListenerLite);
}

if(view.getId()==R.id.bt_get_exception_log) {
    postView("\n读取异常日志（0x36/0x25）");
    LmAPILite.GET_EXCEPTION_LOG(iExceptionLogListenerLite);
}

if(view.getId()==R.id.bt_delete_exception_log) {
    postView("\n删除异常日志（0x36/0x26）");
    LmAPILite.DELETE_EXCEPTION_LOG(iExceptionLogListenerLite);
}

// ==== V0.4新增协议入口 ====
if(view.getId()==R.id.bt_delete_history) {
    postView("\n删除全部本地数据历史记录（0x36/0x3，系统繁忙时空闲执行）");
    LmAPILite.DELETE_HISTORY_RECORD(iDeleteHistoryListenerLite);
}

if(view.getId()==R.id.bt_ship_mode) {
    postView("\n设置Shipmode运输模式（0xF2/0x5），戒指将进入运输模式");
    LmAPILite.SET_SHIP_MODE();
}

if(view.getId()==R.id.bt_reset_restart) {
    postView("\n复位测试，重启戒指（0xF2/0x9）");
    LmAPILite.RESET_RESTART();
}
```

（5）V0.3 电量推送适配：`IBatteryListenerLite` 匿名类中 `battery_push` 签名由 `(int type, int electricity)` 改为 `(int electricity, int chargingStatus)`（两处：bt_battery、bt_battery_state）：

```java
@Override
public void battery_push(int electricity, int chargingStatus) {
    postView("\n电量推送:电量=" + electricity + ",充电状态=" + (chargingStatus == 0 ? "未充电" : (chargingStatus == 1 ? "充电中" : (chargingStatus == 2 ? "充满" : String.valueOf(chargingStatus)))));
}
```

（6）V0.3 运动结果透传显示：`ISportListenerLite.onSport` 中补充停止/被动停止结果显示：

```java
if (sportType == 0) {
    String result = step == 0 ? "失败" : (step == 1 ? "成功" : (step == 2 ? "文件数量已满" : "结果=" + step));
    postView("\n" + type + ":" + result);
} else if (sportType == 3) {
    String result = step == 0 ? "失败" : (step == 1 ? "成功" : "结果=" + step);
    postView("\n" + type + ":" + result);
} else if (sportType == 4) {
    postView("\n" + type + ":佩戴中断=" + step);
} else {
    postView("\n" + type + ":步数=" + step + ",心率=" + heart + ",卡路里=" + calorie + ",时间=" + time);
}
```

（7）V0.4 APP_CONNECT 调用适配：`LmAPILite.APP_CONNECT` 删除 timeMillis 入参（原第二参数时间戳不再传，SDK 内部自动取系统当前时间组帧），回调 bean 为 V0.4 精简后的 `SystemControlLiteBean`（8 字段：固件版本、硬件版本、电量、充电状态、当前计步、自检标识、gomore授权、工作模式；`IBindConnectRefreshListenerLite`、`SystemControlLiteBean` 的 import 原工程已存在）：

```java
if(view.getId()==R.id.bt_app_connect){
    postView("\nAPP_CONNECT");
    LmAPILite.APP_CONNECT(new IBindConnectRefreshListenerLite() {
        @Override
        public void appBind(SystemControlLiteBean systemControlBean) {

        }

        @Override
        public void appConnect(SystemControlLiteBean systemControlBean) {
            postView("\nappConnect:"+systemControlBean);
        }

        @Override
        public void appRefresh(SystemControlLiteBean systemControlBean) {

        }
    });
}
```

### 6. activity_test.xml

在按钮区末尾（最下面）添加 V0.3 七个协议按钮和"aivela定制协议"跳转按钮（跳转按钮放在最后）；V0.4 在异常日志行追加"删除历史记录"按钮（bt_delete_history，一排三个按钮）：

```xml
<!-- ==== V0.3新增协议入口 start ==== -->
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="30dp"
    android:layout_marginTop="5dp"
    android:orientation="horizontal">
    <Button
        android:id="@+id/bt_wear_status"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="佩戴检测"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
    <Button
        android:id="@+id/bt_airplane_mode"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="飞行模式"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
    <Button
        android:id="@+id/bt_work_mode"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="工作模式"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
</LinearLayout>

<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="30dp"
    android:layout_marginTop="5dp"
    android:orientation="horizontal">
    <Button
        android:id="@+id/bt_get_exception_log"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="读取异常日志"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
    <Button
        android:id="@+id/bt_delete_exception_log"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="删除异常日志"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
    <Button
        android:id="@+id/bt_delete_history"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="删除历史记录"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
</LinearLayout>

<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="30dp"
    android:layout_marginTop="5dp"
    android:orientation="horizontal">
    <Button
        android:id="@+id/bt_ship_mode"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="Shipmode运输模式"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
    <Button
        android:id="@+id/bt_reset_restart"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="复位测试"
        android:textSize="12sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>
</LinearLayout>
<!-- ==== V0.3新增协议入口 end ==== -->

<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="30dp"
    android:layout_marginTop="5dp"
    android:orientation="horizontal">

    <Button
        android:id="@+id/bt_aivela_protocol"
        android:layout_width="0dp"
        android:layout_weight="1"
        android:layout_height="wrap_content"
        android:text="aivela定制协议"
        android:textSize="14sp"
        android:textColor="@color/white"
        android:background="@drawable/button_bg_state"/>

</LinearLayout>
```

### 7. App.java

`onCreate` 中 SDK 初始化改为带 `ICMDLogListener` 的重载（原 `LmAPILite.init(this)`）：

```java
import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.ICMDLogListener;

@Override
public void onCreate() {
    super.onCreate();
    app = this;
    LmAPILite.init(this, new ICMDLogListener() {
        @Override
        public void log(String label, String type, String logs) {

        }
    });
    LmAPILite.setDebug(true);
    // ...其余原有初始化代码不变
}
```

> Application 层的空监听器仅用于让 `LmLibrary.icmdLogListener` 完成初始化；AivelaProtocolActivity 进入时会用 `SET_CMD_LOG_LISTENER` 替换成自己的监听器，退出时置 null。

### 8. MainActivity.java

删除一行（LmAPI 类已从 SDK 删除，全部统一到 LmAPILite）：

```java
import com.lm.sdk.LmAPI;  // 删除此行
```

## 五、移植步骤总结

1. 整体替换新项目的 `blelibrary` 模块（或按《aivela定制协议.md》改造 SDK 层）
2. 复制 3 个新文件到 demo/app 模块对应目录（注意改包名 `com.lomo.demo` → 目标项目包名）
3. 按"四、修改文件"在 4 个文件中添加对应片段
4. 检查目标项目的 `BaseActivity` 基类是否存在（AivelaProtocolActivity 继承它，可换成任意 Activity 基类）
5. 检查颜色/按钮背景资源（`colorPrimary`、`colorPrimaryDark`、`white`、`button_bg_state`）是否存在，不存在则替换为目标项目资源
6. 编译验证

## 六、本地日志文件说明

- `LM/LocalHistoryLog.txt`：历史记录数据（覆盖保存，每次发送读取指令时清空重写）
- `LM/GoMoreSleepLog.txt`：Gomore睡眠数据（覆盖保存，每次发送指令时清空重写）
- 保存方式：`ImageSaverUtil.saveImageToInternalStorage(context, 内容, "LM", 文件名, false)`（最后参数 false = 覆盖）

## 修改记录

- 2026-10-28：创建文档；包含 aivela 测试页、指令日志捕获与对话框、TestActivity 跳转、App 初始化改造、LmAPI 删除统一到 LmAPILite
- 2026-10-29：按协议 V0.3 更新：历史记录 Subcmd 0x25/0x26→0x2E/0x2F；AivelaProtocolActivity 长睡设置扩为 4 参数（新增计步阈值、PPG时长输入框）；TestActivity 新增佩戴检测/飞行模式/工作模式/异常日志读取/删除/Shipmode/复位测试 7 个入口及 4 个监听器；电量推送 `battery_push` 签名变更并显示充电状态；运动开始/停止/被动停止结果显示；"aivela定制协议"跳转按钮调整到页面最下面
- 2026-10-30：按协议 V0.4 更新：新增删除全部本地数据历史记录指令（0x36/0x3，TestActivity 异常日志按钮行追加"删除历史记录"按钮 + IDeleteHistoryListenerLite 监听）；蓝牙名称长度上限 12→20（Set_BlueTooth_Name/Get_BlueTooth_Name，设置后设备 1s 自动断开并重广播，demo 调用代码无需改动）；0xA0 绑定/连接 APP_BIND/APP_CONNECT 删除 timeMillis 入参（SDK 内部取当前时间）、响应 Data 精简为固定 28 字节（SystemControlLiteBean 重写为 8 字段并新增工作模式 workMode），TestActivity 的 APP_CONNECT 调用同步适配
