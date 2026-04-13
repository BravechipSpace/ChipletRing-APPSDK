package com.lomo.demo.activity;

import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;


import com.lm.sdk.ErrorEnum;
import com.lm.sdk.LmAPILite;

import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.IGoMoreListener;
import com.lm.sdk.inter.IGoMoreUserListener;
import com.lm.sdk.inter.LmOtaProgressListener;
import com.lm.sdk.library.utils.DateUtils;
import com.lm.sdk.lmApiInter.IBatteryListenerLite;
import com.lm.sdk.lmApiInter.IBatteryPushListenerLite;
import com.lm.sdk.lmApiInter.IBindConnectRefreshListenerLite;
import com.lm.sdk.lmApiInter.IBloodOxygenListenerLite;
import com.lm.sdk.lmApiInter.IHeartListenerLite;
import com.lm.sdk.lmApiInter.IHistoryListenerLite;
import com.lm.sdk.lmApiInter.IResponseListenerLite;
import com.lm.sdk.lmApiInter.ITooTestListener;
import com.lm.sdk.lmApiInter.IStepListenerLite;
import com.lm.sdk.lmApiInter.ISyncTimeListenerLite;
import com.lm.sdk.lmApiInter.ISystemControlListenerLite;
import com.lm.sdk.lmApiInter.ITempListenerLite;
import com.lm.sdk.lmApiInter.IVersionListenerLite;
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.mode.SystemControlLiteBean;
import com.lm.sdk.utils.BLEUtils;
import com.lomo.demo.GsonUtils;
import com.lomo.demo.R;
import com.lomo.demo.adapter.DeviceBean;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;



public class TestActivity extends BaseActivity implements IResponseListenerLite, View.OnClickListener {
    public String TAG = getClass().getSimpleName();
    TextView tv_result;
    private DeviceBean deviceBean;
    private BluetoothDevice bluetoothDevice;

    private ISystemControlListenerLite iSystemControlListenerLite=new ISystemControlListenerLite() {
        @Override
        public void reset() {
            postView("恢复出厂设置");
        }

        @Override
        public void getSerialNum(String serial) {
            postView("得到序列号:"+serial);
        }

        @Override
        public void setCollection(boolean success) {
            postView("设置周期:"+"300秒");
        }

        @Override
        public void getCollection(int data) {
            postView("得到周期:"+data+"秒");
        }

        @Override
        public void setSerialNum(boolean success) {
            postView("设置序列号:"+success);
        }

        @Override
        public void getAirplaneMode(boolean open) {
            postView("开启飞行模式:"+open);
        }

        @Override
        public void setAirplaneMode(boolean success) {
            postView("设置飞行模式:"+success);
        }

        @Override
        public void setBlueToolName(boolean success) {
            postView("设置蓝牙名称:"+success);
        }

        @Override
        public void readBlueToolName(int len, String name) {
            postView("读取蓝牙名称:"+name+"，长度:"+len);
        }
    };
    static String mac;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test);
        LmAPILite.addWLSCmdListener(this, this);

        tv_result=findViewById(R.id.tv_result);

        findViewById(R.id.bt_app_bind).setOnClickListener(this);
        findViewById(R.id.bt_app_connect).setOnClickListener(this);
        findViewById(R.id.bt_app_refresh).setOnClickListener(this);
        findViewById(R.id.bt_sync_time).setOnClickListener(this);
        findViewById(R.id.bt_read_time).setOnClickListener(this);
        findViewById(R.id.bt_battery).setOnClickListener(this);
        findViewById(R.id.bt_battery_state).setOnClickListener(this);
        findViewById(R.id.bt_soft_version).setOnClickListener(this);
        findViewById(R.id.bt_hardware_version).setOnClickListener(this);
        findViewById(R.id.bt_clear_step).setOnClickListener(this);
        findViewById(R.id.bt_step).setOnClickListener(this);
        findViewById(R.id.bt_heart).setOnClickListener(this);
        findViewById(R.id.bt_blood_oxygen).setOnClickListener(this);
        findViewById(R.id.bt_read_log).setOnClickListener(this);
        findViewById(R.id.bt_test_temp).setOnClickListener(this);
        findViewById(R.id.bt_gomore_test).setOnClickListener(this);
        findViewById(R.id.bt_gomore_user).setOnClickListener(this);
        findViewById(R.id.bt_get_gomore_user).setOnClickListener(this);
        findViewById(R.id.bt_setSn).setOnClickListener(this);
        findViewById(R.id.bt_getSn).setOnClickListener(this);
        findViewById(R.id.bt_setBluttoothName).setOnClickListener(this);
        findViewById(R.id.bt_getBluttoothName).setOnClickListener(this);
        findViewById(R.id.tv_connect).setOnClickListener(this);
        findViewById(R.id.bt_reset).setOnClickListener(this);
        findViewById(R.id.bt_led_open).setOnClickListener(this);
        findViewById(R.id.bt_led_close).setOnClickListener(this);
        findViewById(R.id.bt_app_unBind).setOnClickListener(this);
        findViewById(R.id.bt_setCollection).setOnClickListener(this);
        findViewById(R.id.btn_getCollection).setOnClickListener(this);
        findViewById(R.id.btn_ota).setOnClickListener(this);

        //获取上个页面传递过来的deviceBean对象
        Intent intent = getIntent();
        if (intent != null) {
            deviceBean = intent.getParcelableExtra("deviceBean");
            bluetoothDevice = deviceBean.getDevice();
            mac = bluetoothDevice.getAddress();
            App.getInstance().setDeviceBean(deviceBean);
            BLEUtils.connectLockByBLE(this, deviceBean.getDevice());
        } else {
            Toast.makeText(this, "未知设备，请重新选择!", Toast.LENGTH_SHORT).show();
            finish();
        }
        //设置历史记录自动上传监听，复合指令（app_connect,app_refresh）会主动上传历史数据
        READ_HISTORY_AUTO();

        /**
         * 主动推送电量信息
         * @param electricity 0~100%百分比，101为充电中，电量无效
         * 102为充电完成，电量无效
         * @param remainingBatteryLife 剩余续航时间（秒）
         * @param chargingStatus 充电状态 0未充电 1充电中 2充满
         */
        LmAPILite.SET_BATTERY_PUSH_LISTENER(new IBatteryPushListenerLite() {
            @Override
            public void battery_push(int electricity, long remainingBatteryLife, int chargingStatus) {
                postView("电量推送\n"+"电量："+electricity+",续航:"+remainingBatteryLife+"秒"+",充电状态:"+chargingStatus);
            }
        });
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        BLEUtils.disconnectBLE(this);
        LmAPILite.removeWLSCmdListener(this);
    }

    @Override
    public void lmBleConnecting(int i) {
        postView("\n连接中..." + i);
    }

    @Override
    public void lmBleConnectionSucceeded(int i) {
        if(i==7){
            BLEUtils.setGetToken(true);
            postView("\n连接成功");
        }else{
            BLEUtils.setGetToken(false);
            postView("\n连接失败");
        }

    }

    @Override
    public void lmBleConnectionFailed(int i) {
        BLEUtils.setGetToken(false);
        postView("\n连接失败");
    }

    @Override
    public void timeOut(ErrorEnum cmd) {
        postView("\n指令超时");
    }


    @Override
    public void saveData(String s) {
    }

    @Override
    public void onClick(View view) {
            if(view.getId()==R.id.bt_app_bind){
                postView("\nAPP_BIND");
                LmAPILite.APP_BIND( new IBindConnectRefreshListenerLite() {
                    @Override
                    public void appBind(SystemControlLiteBean systemControlBean) {
                        postView("\nappBind:"+systemControlBean);
                    }

                    @Override
                    public void appConnect(SystemControlLiteBean systemControlBean) {

                    }

                    @Override
                    public void appRefresh(SystemControlLiteBean systemControlBean) {

                    }

                    @Override
                    public void appUnBind(SystemControlLiteBean systemControlLiteBean) {

                    }
                });
            }
        if(view.getId()==R.id.bt_app_unBind) {

            postView("\nAPP_UNBIND");
            LmAPILite.APP_UNBIND(new IBindConnectRefreshListenerLite() {
                @Override
                public void appBind(SystemControlLiteBean systemControlBean) {
                    postView("\nappBind:" + systemControlBean);
                }

                @Override
                public void appConnect(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appRefresh(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appUnBind(SystemControlLiteBean systemControlLiteBean) {

                }
            });
        }
        if(view.getId()==R.id.bt_app_connect) {
            postView("\nAPP_CONNECT");
            LmAPILite.APP_CONNECT(0, new IBindConnectRefreshListenerLite() {
                @Override
                public void appBind(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appConnect(SystemControlLiteBean systemControlBean) {
                    postView("\nappConnect:" + systemControlBean);
                }

                @Override
                public void appRefresh(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appUnBind(SystemControlLiteBean systemControlLiteBean) {

                }
            });
        }
        if(view.getId()==R.id.bt_app_refresh) {
            postView("\nAPP_REFRESH");
            LmAPILite.APP_REFRESH(0, new IBindConnectRefreshListenerLite() {
                @Override
                public void appBind(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appConnect(SystemControlLiteBean systemControlBean) {

                }

                @Override
                public void appRefresh(SystemControlLiteBean systemControlBean) {
                    postView("\nappRefresh:" + systemControlBean);
                }

                @Override
                public void appUnBind(SystemControlLiteBean systemControlLiteBean) {

                }
            });
        }
        if(view.getId()==R.id.bt_clear_step) {
            postView("\n开始清空步数");
            LmAPILite.CLEAR_COUNTING(new IStepListenerLite() {
                @Override
                public void stepCount(int steps) {

                }

                @Override
                public void clearStepCount() {
                    postView("\n清空步数");
                }
            });
        }
        if(view.getId()==R.id.bt_sync_time) {

            postView("\n开始同步时间");
            LmAPILite.SYNC_TIME_ZONE((byte) 8, new ISyncTimeListenerLite() {
                @Override
                public void syncTime(boolean updateTime, long timeStamp, long timeZone) {
                    postView("\n同步时间");
                }
            });
        }
        if(view.getId()==R.id.bt_read_time) {
            postView("\n开始读取时间");
            LmAPILite.READ_TIME(new ISyncTimeListenerLite() {
                @Override
                public void syncTime(boolean updateTime, long timeStamp, long timeZone) {
                    postView("\n读取时间" + DateUtils.longToString(timeStamp, "yyyy-MM-dd HH:mm") + ",时区：" + timeZone);
                }
            });
        }
        if(view.getId()==R.id.bt_soft_version) {

            postView("\n开始获取软件版本信息");
            LmAPILite.GET_VERSION(true, new IVersionListenerLite() {
                @Override
                public void versionResult(String softwareVersion, String hardwareVersion) {
                    postView("\n获取软件版本信息成功" + softwareVersion);
                }
            });
        }
        if(view.getId()==R.id.bt_hardware_version) {

            postView("\n开始获取硬件版本信息");
            LmAPILite.GET_VERSION(false, new IVersionListenerLite() {
                @Override
                public void versionResult(String softwareVersion, String hardwareVersion) {
                    postView("\n获取硬件版本信息成功" + hardwareVersion);
                }
            });
        }
        if(view.getId()==R.id.bt_battery) {
//                postView("\n开始获取HID_CODE");
//                LmAPI.GET_HID_CODE((byte) 0x00);
            postView("\n开始获取电量信息");
            LmAPILite.GET_BATTERY((byte) 0x00, new IBatteryListenerLite() {
                @Override
                public void battery(int type, int electricity) {
                    if (type == 0) {
                        postView("\n获取电量信息:" + electricity);
                    }

                }

            });
        }
        if(view.getId()==R.id.bt_battery_state) {

//                postView("\n开始获取HID_CODE");
//                LmAPI.GET_HID_CODE((byte) 0x00);
            postView("\n获取充电状态");
            LmAPILite.GET_BATTERY((byte) 0x01, new IBatteryListenerLite() {
                @Override
                public void battery(int type, int electricity) {
                    if (type == 1) {
                        postView("\n获取充电状态:" + electricity);
                    }

                }

            });
        }
        if(view.getId()==R.id.bt_step) {

            postView("\n开始获取步数信息");
            LmAPILite.STEP_COUNTING(new IStepListenerLite() {
                @Override
                public void stepCount(int steps) {
                    postView("\n步数信息:" + steps);
                }

                @Override
                public void clearStepCount() {

                }
            });
        }
        if(view.getId()==R.id.bt_blood_oxygen) {
            postView("\n开始测量血氧");
            LmAPILite.GET_HEART_Q2_WITH_TIME((byte) 1, (byte) 30, new IBloodOxygenListenerLite() {

                @Override
                public void resultData(int bloodOxygen, int perfusion, int progress) {
                    postView("\n血氧：" + bloodOxygen + ",灌注度：" + perfusion + "%" + ",进度：" + progress);
                }

                @Override
                public void waveformData(int serialNumber, int numberOfData, String waveformData) {
                    postView("\n波形数据：" + waveformData);
                }

                @Override
                public void error(int code, String message) {
                    postView("\nerror：" + code);
                }

                @Override
                public void success() {
                    postView("\nsuccess");
                }

                @Override
                public void stopQ2() {
                    postView("\n停止测量");
                }

                @Override
                public void pushQ2(int q2, int perfusion) {
                    postView("\n血氧推送：" + q2 + ",灌注度：" + perfusion + "%");
                }
            });

        }
        if(view.getId()==R.id.bt_heart) {

            postView("\n开始测量心率");
            LmAPILite.GET_HEART_ROTA((byte) 0, (byte) 30, new IHeartListenerLite() {


                @Override
                public void resultData(int heart, int progress) {
                    postView("\n测量心率数据：" + heart + ",进度：" + progress);
                }

                @Override
                public void waveformData(int seq, int number, String waveData) {
                    tv_result.setText(waveData);
                }

                @Override
                public void rriData(int seq, int number, String data) {
                    postView("\ndata的值是：" + data);
                }

                @Override
                public void error(int code, String message) {
                    postView("\n测量心率错误：" + code);
                }

                @Override
                public void success() {
                    postView("\n测量心率完成");
                }

                @Override
                public void stopHeart() {
                    postView("\n停止测量心率");
                }

                @Override
                public void pushHeart(int heart) {
                    postView("\n心率推送：" + heart);
                }


            });
        }
        if(view.getId()==R.id.bt_gomore_test) {

            postView("\ngomore睡眠");
            //postView("\n开始读取未上传数据");
            LmAPILite.GET_GOMORE_SLEEP(new IGoMoreListener() {
                @Override
                public void overviewOfSleep(GoMoreSleep goMoreSleep) {
                    postView("\ngomore睡眠 overviewOfSleep:" + GsonUtils.beanToJson(goMoreSleep));
                    Log.e(TAG, "overviewOfSleep: " + GsonUtils.beanToJson(goMoreSleep));
                }

                @Override
                public void sleepStaging(GoMoreSleep goMoreSleep) {
                    postView("\ngomore睡眠 sleepStaging:" + GsonUtils.beanToJson(goMoreSleep));
                    Log.e(TAG, "sleepStaging: " + GsonUtils.beanToJson(goMoreSleep));
                }

                @Override
                public void dataUploadFinish() {

                }

                @Override
                public void noSleepData() {
                    postView("\ngomore睡眠 noSleepData");
                }
            });
        }
        if(view.getId()==R.id.bt_read_log) {

            postView("\n开始读取全部数据");

            LmAPILite.READ_HISTORY((byte) 0x1, 0, new IHistoryListenerLite() {
                @Override
                public void error(int code) {

                }

                @Override
                public void success() {
                    postView("\n读取记录完成");

                }

                @Override
                public void progress(double progress, HistoryDataBean historyDataBean) {
                    if (historyDataBean != null) {
                        postView("\n读取记录进度:" + progress + "%");
                        postView("\n记录内容:" + historyDataBean);
                    }

                }

                @Override
                public void clearHistory() {

                }

                @Override
                public void noNewDataAvailable() {

                }

                @Override
                public void localMemoryFull(int capacitySize, int capacitySizeUsed, int totalNumber, int notUploadedNumber) {

                }

                @Override
                public void historyRefreshPush() {

                }
            });
        }
        if(view.getId()==R.id.bt_test_temp) {
            postView("\n获取温度");
            LmAPILite.READ_TEMP(new ITempListenerLite() {
                @Override
                public void resultData(int temp, int progress) {
                    postView("\n测量体温完成后的结果:" + temp + ",进度：" + progress);
                }

                @Override
                public void error(int code) {
                    postView("\nerror:" + code);
                }
            });
        }
        if(view.getId()==R.id.bt_setSn) {

            postView("\n请打开注释，设置正确的序列号");
//                LmAPILite.SET_SERIAL("1234567890".getBytes(), iSystemControlListenerLite);
//                LmAPILite.SET_SN("", new ISNListener() {
//                    @Override
//                    public void getSn(String sn) {
//
//                    }
//
//                    @Override
//                    public void setSn(boolean success) {
//
//                    }
//                });
        }
        if(view.getId()==R.id.bt_getSn) {

//            postView("\n获取序列号");
//            LmAPILite.GET_SN(new ITooTestListener() {
//                @Override
//                public void getSn(String sn) {
//                    postView("\n获取序列号:" + sn);
//                }
//
//                @Override
//                public void setSn(boolean success) {
//
//                }
//            });
        }
        if(view.getId()==R.id.bt_setBluttoothName) {

            postView("\n设置蓝牙名");
            LmAPILite.Set_BlueTooth_Name("AQRingTest", iSystemControlListenerLite);
        }
        if(view.getId()==R.id.bt_getBluttoothName) {

                postView("\n获取蓝牙名");
                LmAPILite.Get_BlueTooth_Name(iSystemControlListenerLite);
        }
        if(view.getId()==R.id.bt_gomore_user) {

            postView("\n设置Gomore个人信息");
            LmAPILite.SET_GOMORE_USER(35, 1, 183, 70, -1, -1, -1, new IGoMoreUserListener() {
                @Override
                public void setUserInfoResult(boolean success) {
                    postView("\n设置Gomore个人信息:" + success);
                }

                @Override
                public void getUserInfoResult(int age, int sex, int height, int weight, int maximumHeartRate, int normalHeartRate, int maximalOxygenUptake) {

                }
            });

        }
        if(view.getId()==R.id.bt_get_gomore_user) {

            postView("\n获取Gomore个人信息");
            LmAPILite.GET_GOMORE_USERINFO(new IGoMoreUserListener() {
                @Override
                public void setUserInfoResult(boolean success) {

                }

                @Override
                public void getUserInfoResult(int age, int sex, int height, int weight, int maximumHeartRate, int normalHeartRate, int maximalOxygenUptake) {
                    postView("\n获取Gomore个人信息:" + age + "," + sex + "," + height + "," + weight + "," + maximumHeartRate + "," + normalHeartRate + "," + maximalOxygenUptake);
                }
            });
        }

        if(view.getId()==R.id.tv_connect) {

            BLEUtils.connectLockByBLE(TestActivity.this, bluetoothDevice);
        }
        if(view.getId()==R.id.bt_reset) {

            LmAPILite.RESET();
        }
        if(view.getId()==R.id.bt_led_open) {

            LmAPILite.LED_STATUS(true);
        }
        if(view.getId()==R.id.bt_led_close) {

            LmAPILite.LED_STATUS(false);
        }
        if(view.getId()==R.id.bt_setCollection) {

            LmAPILite.SET_COLLECTION(5 * 60, iSystemControlListenerLite);
        }
        if(view.getId()==R.id.btn_getCollection) {

            LmAPILite.GET_COLLECTION(iSystemControlListenerLite);
        }
        if(view.getId()==R.id.btn_ota) {

            String outPath="/sdcard/7.3.3.7_AQ RING.bin";
            OtaApi.otaUpdate(mac, outPath, TestActivity.this, new LmOtaProgressListener() {
                @Override
                public void error(String s) {

                }

                @Override
                public void onProgress(int i) {

                }

                @Override
                public void onComplete() {

                }

                @Override
                public void isLatestVersion() {

                }
            });
        }

    }



    /**
     * @param value 打印的log
     */
    public void postView(String value) {
        // tv_result.setText(value);
        tv_result.setMovementMethod(ScrollingMovementMethod.getInstance());
        tv_result.setScrollbarFadingEnabled(false);//滚动条一直显示
        tv_result.append(value);
        int scrollAmount = tv_result.getLayout().getLineTop(tv_result.getLineCount()) - tv_result.getHeight();
        if (scrollAmount > 0)
            tv_result.scrollTo(0, scrollAmount);
        else
            tv_result.scrollTo(0, 0);

    }
    private void READ_HISTORY_AUTO() {

        LmAPILite.READ_HISTORY_AUTO( new IHistoryListenerLite() {
            @Override
            public void error(int code) {
                if (code == 3) {
                    postView("\n出现了BIX的问题");
                }
                // setMessage(TestActivity.this,"\n出现了BIX的问题");
            }

            @Override
            public void success() {
                postView("\n读取记录完成");


            }

            @Override
            public void progress(double progress, HistoryDataBean historyDataBean) {
                postView("\n读取记录进度:" + progress + "%");
                postView("\n记录内容:" + historyDataBean.toString());
            }

            @Override
            public void clearHistory() {

            }

            @Override
            public void noNewDataAvailable() {

            }

            @Override
            public void localMemoryFull(int capacitySize, int capacitySizeUsed, int totalNumber, int notUploadedNumber) {

            }

            @Override
            public void historyRefreshPush() {

            }
        });
    }
}