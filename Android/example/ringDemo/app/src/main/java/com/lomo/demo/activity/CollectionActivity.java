package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.lm.sdk.LmAPI;
import com.lm.sdk.inter.ICollectionListener;
import com.lm.sdk.library.utils.DateUtils;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

public class CollectionActivity extends BaseActivity implements  View.OnClickListener {

    TextView tv_result2;
    private ICollectionListener iCollectionListener=new ICollectionListener() {
        @Override
        public void setScheduledStartup(boolean success) {
            postView("\n设置定时启动运动采集成功："+success);
        }

        @Override
        public void getScheduledStartup(int model, long startTime, long endTime) {
            postView("\n获取定时启动运动采集结果model："+model+",startTime:"+DateUtils.longToString(startTime*1000,"yyyy-MM-dd HH:mm:ss")+",endTime:"+DateUtils.longToString(endTime*1000,"yyyy-MM-dd HH:mm:ss"));
        }

        @Override
        public void setPPGFrequency(boolean success) {
            postView("\n设置ppg频率成功："+success);
        }

        @Override
        public void getPPGFrequency(int ppg) {
            postView("\n获取ppg频率："+ppg);
        }

        @Override
        public void setSensorFrequency(boolean success) {
            postView("\n设置传感器频率成功："+success);
        }

        @Override
        public void getSensorFrequency(int acc, int gyro) {
            postView("\n获取传感器频率acc："+acc+",gyro:"+gyro);
        }

        @Override
        public void setOpenGyroScope(boolean success) {
            postView("\n设置开启陀螺仪成功："+success);
        }

        @Override
        public void getOpenGyroScope(boolean open) {
            postView("\n获取是否开启陀螺仪："+open);
        }

        @Override
        public void setOpenAcceleration(boolean success) {
            postView("\n设置开启加速度成功："+success);
        }

        @Override
        public void getOpenAcceleration(boolean open) {
            postView("\n获取是否开启加速度："+open);
        }

        @Override
        public void setOpenTemperature(boolean success) {
            postView("\n设置开启温度成功："+success);
        }

        @Override
        public void getOpenTemperature(boolean open) {
            postView("\n获取是否开启温度："+open);
        }

        @Override
        public void setOpenPPG(boolean success) {
            postView("\n设置开启PPG成功："+success);
        }

        @Override
        public void getOpenPPG(boolean open) {
            postView("\n获取是否开启PPG："+open);
        }

        @Override
        public void setOpenPPGRAWData(boolean success) {
            postView("\n设置PPG RAWdata采集时长："+success);
        }

        @Override
        public void getPPGRAWData(int second) {
            postView("\n获取PPG RAWdata采集时长："+second);
        }

        @Override
        public void setOpenPPGAutomaticCollection(boolean success) {
            postView("\n设置开启ppg自动采集成功："+success);
        }

        @Override
        public void getPPGAutomaticCollection(boolean open) {
            postView("\n获取是否开ppg启自动采集："+open);
        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_collection);
        tv_result2 = findViewById(R.id.tv_result2);
        findViewById(R.id.bt_setScheduledStartup).setOnClickListener(this);
        findViewById(R.id.bt_getScheduledStartup).setOnClickListener(this);
        findViewById(R.id.bt_setPPGFrequency).setOnClickListener(this);
        findViewById(R.id.bt_getPPGFrequency).setOnClickListener(this);
        findViewById(R.id.bt_setSensorFrequency).setOnClickListener(this);
        findViewById(R.id.bt_getSensorFrequency).setOnClickListener(this);
        findViewById(R.id.bt_setOpenGyroScope).setOnClickListener(this);
        findViewById(R.id.bt_getOpenGyroScope).setOnClickListener(this);
        findViewById(R.id.bt_setOpenAcceleration).setOnClickListener(this);
        findViewById(R.id.bt_getOpenAcceleration).setOnClickListener(this);
        findViewById(R.id.bt_setOpenTemperature).setOnClickListener(this);
        findViewById(R.id.bt_getOpenTemperature).setOnClickListener(this);
        findViewById(R.id.bt_setOpenPPG).setOnClickListener(this);
        findViewById(R.id.bt_getOpenPPG).setOnClickListener(this);
        findViewById(R.id.bt_setOpenPPGRAWData).setOnClickListener(this);
        findViewById(R.id.bt_getPPGRAWData).setOnClickListener(this);
        findViewById(R.id.bt_setOpenPPGAutomaticCollection).setOnClickListener(this);
        findViewById(R.id.bt_getPPGAutomaticCollection).setOnClickListener(this);

    }



    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.bt_setScheduledStartup) {
            postView("\n设置定时启动运动采集");
            LmAPI.SET_SCHEDULED_STARTUP(0, 1746923372, 1746923372, iCollectionListener);
        } else if (id == R.id.bt_getScheduledStartup) {
            postView("\n获取定时启动运动采集");
            LmAPI.GET_SCHEDULED_STARTUP(iCollectionListener);
        } else if (id == R.id.bt_setPPGFrequency) {
            postView("\n设置ppg频率100hz");
            LmAPI.SET_PPG_FREQUENCY(100, iCollectionListener);
        } else if (id == R.id.bt_getPPGFrequency) {
            postView("\n获取ppg频率");
            LmAPI.GET_PPG_FREQUENCY(iCollectionListener);
        } else if (id == R.id.bt_setSensorFrequency) {
            postView("\n设置传感器频率100hz");
            LmAPI.SET_SENSOR_FREQUENCY(100, 100, iCollectionListener);
        } else if (id == R.id.bt_getSensorFrequency) {
            postView("\n获取传感器频率");
            LmAPI.GET_SENSOR_FREQUENCY(iCollectionListener);
        } else if (id == R.id.bt_setOpenGyroScope) {
            postView("\n设置开启陀螺仪");
            LmAPI.SET_OPEN_GYROSCOPE(1, iCollectionListener);
        } else if (id == R.id.bt_getOpenGyroScope) {
            postView("\n获取是否开启陀螺仪");
            LmAPI.GET_OPEN_GYROSCOPE(iCollectionListener);
        } else if (id == R.id.bt_setOpenAcceleration) {
            postView("\n设置开启加速度");
            LmAPI.SET_OPEN_ACCELERATION(1, iCollectionListener);
        } else if (id == R.id.bt_getOpenAcceleration) {
            postView("\n获取是否开启加速度");
            LmAPI.GET_OPEN_ACCELERATION(iCollectionListener);
        } else if (id == R.id.bt_setOpenTemperature) {
            postView("\n设置开启温度");
            LmAPI.SET_OPEN_TEMPERATURE(1, iCollectionListener);
        } else if (id == R.id.bt_getOpenTemperature) {
            postView("\n获取是否开启温度");
            LmAPI.GET_OPEN_TEMPERATURE(iCollectionListener);
        } else if (id == R.id.bt_setOpenPPG) {
            postView("\n设置开启PPG");
            LmAPI.SET_OPEN_PPG(1, iCollectionListener);
        } else if (id == R.id.bt_getOpenPPG) {
            postView("\n获取是否开启PPG");
            LmAPI.GET_OPEN_PPG(iCollectionListener);
        } else if (id == R.id.bt_setOpenPPGRAWData) {
            postView("\n设置PPG采集时长50s");
            LmAPI.SET_OPEN_PPGRAWDATA(50, iCollectionListener);
        } else if (id == R.id.bt_getPPGRAWData) {
            postView("\n获取PPG RAWdata采集时长");
            LmAPI.GET_PPG_RAWDATA(iCollectionListener);
        } else if (id == R.id.bt_setOpenPPGAutomaticCollection) {
            postView("\n设置开启ppg自动采集");
            LmAPI.SET_OPEN_PPGAUTOMATICCOLLECTION(1, iCollectionListener);
        } else if (id == R.id.bt_getPPGAutomaticCollection) {
            postView("\n获取是否开ppg启自动采集");
            LmAPI.GET_PPG_AUTOMATICCOLLECTION(iCollectionListener);
        }
    }


    /**
     * @param value 打印的log
     */
    public void postView(String value) {
        tv_result2.setMovementMethod(ScrollingMovementMethod.getInstance());
        tv_result2.setScrollbarFadingEnabled(false);//滚动条一直显示
        tv_result2.append(value);
        int scrollAmount = tv_result2.getLayout().getLineTop(tv_result2.getLineCount()) - tv_result2.getHeight();
        if (scrollAmount > 0)
            tv_result2.scrollTo(0, scrollAmount);
        else
            tv_result2.scrollTo(0, 0);

    }


}
