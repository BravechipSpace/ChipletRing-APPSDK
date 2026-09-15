package com.lomo.demo.activity;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.ISixAxisSensorListener;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

import java.util.List;

/**
 * 6轴传感器测试Activity（cmd=0x40）
 * 包含实时加速度与陀螺仪数据读取、关闭传感器的测试
 */
public class SixAxisSensorActivity extends BaseActivity implements View.OnClickListener {

    public String TAG = getClass().getSimpleName();
    TextView tv_result;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_six_axis_sensor);

        tv_result = findViewById(R.id.tv_result);

        // 开始实时传感器数据
        findViewById(R.id.bt_start_realtime_sensor).setOnClickListener(this);
        // 关闭传感器
        findViewById(R.id.bt_close_sensor).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();

        // ==================== 开始实时加速度与陀螺仪数据（Subcmd=0x06）====================
        if (id == R.id.bt_start_realtime_sensor) {
            postView("\n开始实时加速度与陀螺仪数据");
            LmAPILite.START_REALTIME_ACCELERATION_AND_GYROSCOPE(new ISixAxisSensorListener() {
                @Override
                public void onCloseResult() {
                    // 关闭传感器时触发
                }

                @Override
                public void onAccelerationResult(int status, int[] acceleration) {
                    // 单次加速度数据
                }

                @Override
                public void onGyroscopeResult(int status, int[] gyroscope) {
                    // 单次陀螺仪数据
                }

                @Override
                public void onAccelerationAndGyroscopeResult(int status, int[] acceleration, int[] gyroscope) {
                    // 单次加速度与陀螺仪数据
                }

                @Override
                public void onRealtimeAccelerationResult(int status, int[] acceleration) {
                    // 实时加速度数据
                }

                @Override
                public void onRealtimeGyroscopeResult(int status, int[] gyroscope) {
                    // 实时陀螺仪数据
                }

                @Override
                public void onRealtimeAccelerationAndGyroscopeResult(int status, List<int[]> dataList) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (status == 0) {
                                postView("\n[实时推送] 收到 " + dataList.size() + " 组数据:");
                                for (int i = 0; i < dataList.size(); i++) {
                                    int[] sensorData = dataList.get(i);
                                    postView(String.format("\n  数据[%d] 加速度: [%d, %d, %d] 陀螺仪: [%d, %d, %d]",
                                            i, sensorData[0], sensorData[1], sensorData[2],
                                            sensorData[3], sensorData[4], sensorData[5]));
                                }
                            } else {
                                postView("\n[实时推送] 设备忙");
                            }
                        }
                    });
                }
            });
        }

        // ==================== 关闭6轴传感器（Subcmd=0x00）====================
        if (id == R.id.bt_close_sensor) {
            postView("\n关闭6轴传感器");
            LmAPILite.CLOSE_SIX_AXIS_SENSOR(new ISixAxisSensorListener() {
                @Override
                public void onCloseResult() {
                    postView("\n已关闭6轴传感器数据上报");
                }

                @Override
                public void onAccelerationResult(int status, int[] acceleration) {
                    // 关闭传感器时不会触发
                }

                @Override
                public void onGyroscopeResult(int status, int[] gyroscope) {
                    // 关闭传感器时不会触发
                }

                @Override
                public void onAccelerationAndGyroscopeResult(int status, int[] acceleration, int[] gyroscope) {
                    // 关闭传感器时不会触发
                }

                @Override
                public void onRealtimeAccelerationResult(int status, int[] acceleration) {
                    // 关闭传感器时不会触发
                }

                @Override
                public void onRealtimeGyroscopeResult(int status, int[] gyroscope) {
                    // 关闭传感器时不会触发
                }

                @Override
                public void onRealtimeAccelerationAndGyroscopeResult(int status, List<int[]> dataList) {
                    // 关闭传感器时不会触发
                }
            });
        }
    }

    /**
     * 打印日志到界面
     */
    public void postView(String value) {
        tv_result.append(value);
    }
}
