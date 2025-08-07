package com.lomo.demo.file;

import android.util.Log;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.mode.ExerciseConfig;
import com.lm.sdk.mode.MeasurementConfig;
import com.lm.sdk.utils.LmApiDataUtils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

public class NotificationHandler {
    private static final String TAG = "NotificationHandler";

    // 设备命令发送回调接口
    public interface DeviceCommandCallback {
        default void onExerciseStarted(int duration, int segmentTime) {}
        default void onExerciseStopped() {}
    }

    // 运动状态回调接口
    public interface ExerciseStatusCallback {
        void onExerciseProgress(int currentSegment, int totalSegments, int progressPercent);
        void onSegmentCompleted(int segmentNumber, int totalSegments);
        void onExerciseCompleted();
    }

    private static DeviceCommandCallback deviceCommandCallback;
    private static ExerciseStatusCallback exerciseStatusCallback;


    // 当前状态追踪
    private static boolean isMeasuring = false;
    private static boolean isExercising = false;
    private static boolean isMeasurementOngoing = false; // 新增：区分是否正在进行测量
    private static int currentFrameId = 1;
    private static MeasurementConfig measurementConfig = new MeasurementConfig();
    private static ExerciseConfig exerciseConfig = new ExerciseConfig();
    private static Timer exerciseTimer;
    private static Timer measurementTimer; // 新增：测量定时器
    private static int currentSegment = 0;


    // 新增：简化设置运动参数的方法
    public static void setExerciseParams(int totalDurationSeconds, int segmentDurationSeconds) {
        exerciseConfig.totalDuration = Math.max(60, Math.min(86400, totalDurationSeconds));
        exerciseConfig.segmentTime = Math.max(30, Math.min(exerciseConfig.totalDuration, segmentDurationSeconds));
        Log.d(TAG, "运动参数设置：总时长=" + exerciseConfig.totalDuration + "s, 每段时长=" + exerciseConfig.segmentTime + "s");
    }

    // 设置设备命令回调
    public static void setDeviceCommandCallback(DeviceCommandCallback callback) {
        deviceCommandCallback = callback;
        Log.d(TAG, "设备命令回调已设置");
    }

    // 开始运动
    public static boolean startExercise() {
        return startExercise(exerciseConfig);
    }

    // 启动运动并传入运动配置
    public static boolean startExercise(ExerciseConfig config) {
        if (isExercising) {
            Log.w(TAG, "运动已在进行中");
            return false;
        }

        if (deviceCommandCallback == null) {
            Log.e(TAG, "设备命令回调未设置");
            return false;
        }

        try {
            isExercising = true;
            currentSegment = 0;

            // 发送运动开始命令
            LmAPILite.START_EXERCISE(config);
            // 启动运动定时器
            startExerciseTimer(config);

            deviceCommandCallback.onExerciseStarted(config.totalDuration, config.segmentTime);

            Log.i(TAG, "开始运动: " + config.getExerciseDescription());
            return true;

        } catch (Exception e) {
            Log.e(TAG, "启动运动失败", e);
            isExercising = false;
            return false;
        }
    }

    // 结束运动
    public static boolean stopExercise() {
        if (!isExercising) {
            Log.w(TAG, "没有进行中的运动");
            return false;
        }

        try {
            // 发送运动停止命令
            if (deviceCommandCallback != null) {
                LmAPILite.STOP_EXERCISE();
            }

            // 停止定时器
            if (exerciseTimer != null) {
                exerciseTimer.cancel();
                exerciseTimer = null;
            }
            isExercising = false;
            currentSegment = 0;

            if (deviceCommandCallback != null) {
                deviceCommandCallback.onExerciseStopped();
            }

            Log.i(TAG, "运动已停止");
            return true;

        } catch (Exception e) {
            Log.e(TAG, "停止运动失败", e);
            return false;
        }
    }

    // 启动运动定时器
    private static void startExerciseTimer(ExerciseConfig config) {
        exerciseTimer = new Timer();
        final int totalSegments = config.getTotalSegments();

        exerciseTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                currentSegment++;

                if (currentSegment <= totalSegments) {
                    // 通知当前段已完成
                    if (exerciseStatusCallback != null) {
                        int progress = (currentSegment * 100) / totalSegments;
                        exerciseStatusCallback.onSegmentCompleted(currentSegment, totalSegments);
                        exerciseStatusCallback.onExerciseProgress(currentSegment, totalSegments, progress);
                    }

                    // 如果不是最后一段，则启动下一个段的测量
                    if (currentSegment < totalSegments) {
                        if (config.enableRest && config.restTime > 0) {
                            // 休息间隔后开始下一个段
                            Timer restTimer = new Timer();
                            restTimer.schedule(new TimerTask() {
                                @Override
                                public void run() {
                                    startNextSegment(config);
                                }
                            }, config.restTime * 1000);
                        } else {
                            // 直接开始下一个段
                            startNextSegment(config);
                        }
                    } else {
                        // 运动完成
                        completeExercise();
                    }
                } else {
                    // 运动完成
                    completeExercise();
                }
            }
        }, config.segmentTime * 1000, config.segmentTime * 1000);
    }

    // 启动下一个运动段
    private static void startNextSegment(ExerciseConfig config) {
        if (isExercising && currentSegment < config.getTotalSegments()) {
            MeasurementConfig segmentConfig = new MeasurementConfig();
            segmentConfig.collectTime = config.segmentTime;
            segmentConfig.ledGreenCurrent = measurementConfig.ledGreenCurrent;
            segmentConfig.ledIrCurrent = measurementConfig.ledIrCurrent;
            segmentConfig.ledRedCurrent = measurementConfig.ledRedCurrent;
            segmentConfig.progressResponse = measurementConfig.progressResponse;
            segmentConfig.waveformResponse = measurementConfig.waveformResponse;

            Log.d(TAG, "开始第 " + (currentSegment + 1) + "/" + config.getTotalSegments() + " 段");
        }
    }

    // 运动完成
    private static void completeExercise() {
        if (exerciseTimer != null) {
            exerciseTimer.cancel();
            exerciseTimer = null;
        }

        isExercising = false;

        if (exerciseStatusCallback != null) {
            exerciseStatusCallback.onExerciseCompleted();
        }

        if (deviceCommandCallback != null) {
            deviceCommandCallback.onExerciseStopped();
        }

        Log.i(TAG, "运动完成");
    }

    public static int getCurrentSegment() {
        return currentSegment;
    }
}
