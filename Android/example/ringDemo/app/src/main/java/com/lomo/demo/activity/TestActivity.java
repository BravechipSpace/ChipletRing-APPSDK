package com.lomo.demo.activity;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;


import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.lm.sdk.BLEService;
import com.lm.sdk.LmAPILite;

import com.lm.sdk.LogicalApi;
import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.ICreateToken;
import com.lm.sdk.inter.IGoMoreListener;
import com.lm.sdk.inter.IGoMoreUserListener;
import com.lm.sdk.inter.LmOtaProgressListener;
import com.lm.sdk.library.utils.DateUtils;
import com.lm.sdk.library.utils.Logger;
import com.lm.sdk.lmApiInter.IAirplaneModeListenerLite;
import com.lm.sdk.lmApiInter.IBatteryListenerLite;
import com.lm.sdk.lmApiInter.IBindConnectRefreshListenerLite;
import com.lm.sdk.lmApiInter.IBloodOxygenListenerLite;
import com.lm.sdk.lmApiInter.IExceptionLogListenerLite;
import com.lm.sdk.lmApiInter.IHeartListenerLite;
import com.lm.sdk.lmApiInter.IResponseListenerLite;
import com.lm.sdk.lmApiInter.IStepListenerLite;
import com.lm.sdk.lmApiInter.ISyncTimeListenerLite;
import com.lm.sdk.lmApiInter.ISystemControlListenerLite;
import com.lm.sdk.lmApiInter.ITempListenerLite;
import com.lm.sdk.lmApiInter.IVersionListenerLite;
import com.lm.sdk.lmApiInter.IWearStatusListenerLite;
import com.lm.sdk.lmApiInter.IWorkModeListenerLite;
import com.lm.sdk.mode.BleDeviceInfo;
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.mode.SystemControlLiteBean;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.ImageSaverUtil;
import com.lm.sdk.utils.UtilSharedPreference;
import com.lomo.demo.GsonUtils;
import com.lomo.demo.R;

import com.lomo.demo.adapter.DeviceBean;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.utils.CmdLogManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;


public class TestActivity extends BaseActivity implements IResponseListenerLite, View.OnClickListener {
    public String TAG = getClass().getSimpleName();
    TextView tv_result;
    EditText et_bluetooth_name, et_gomore_age, et_gomore_sex, et_gomore_height, et_gomore_weight;
    private DeviceBean deviceBean;
    private BluetoothDevice bluetoothDevice;
    private ActivityResultLauncher<Intent> filePickerLauncher;

    private ISystemControlListenerLite iSystemControlListenerLite=new ISystemControlListenerLite() {
        @Override
        public void reset() {
            postView("恢复出厂设置"+"\n");
        }

        @Override
        public void getSerialNum(String serial) {
            postView("得到序列号:"+serial+"\n");
        }

        @Override
        public void setCollection(boolean success) {
            postView("设置采集周期:"+(success?"成功":"失败")+"\n");
        }

        @Override
        public void getCollection(int data) {
            postView("得到周期:"+data+"秒"+"\n");
        }

        @Override
        public void setSerialNum(boolean success) {
            postView("设置序列号:"+success+"\n");
        }


        @Override
        public void setBlueToolName(boolean success) {
            postView("设置蓝牙名称:"+success+"\n");
        }

        @Override
        public void readBlueToolName(int len, String name) {
            postView("读取蓝牙名称:"+name+"，长度:"+len+"\n");
        }
    };

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


    Handler handler = new Handler(new Handler.Callback() {


        @Override
        public boolean handleMessage(@NonNull Message msg) {

            if (msg.what == 101) {

                String mac = UtilSharedPreference.getStringValue(TestActivity.this, "address");
                if (!TextUtils.isEmpty(mac) && !BLEUtils.isGetToken() && App.needAutoConnect) {
                    Log.e("TAG", "Handler  延迟重连  resetConnect 1111 ");
                    BLEUtils.setConnecting(false);
                    // BLEUtils.connectLockByBLE(TestActivity.this, deviceBean.getDevice());
                    connect(mac);
                }

            }
            return false;
        }});

    static String mac;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test);
        //注册文件选择器，兼容高版本Android
        filePickerLauncher = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
            if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                Uri uri = result.getData().getData();
                if (uri != null) {
                    handleSelectedFirmware(uri);
                }
            }
        });
        LmAPILite.addWLSCmdListener(this, this);

        tv_result=findViewById(R.id.tv_result);
        et_bluetooth_name = findViewById(R.id.et_bluetooth_name);
        et_gomore_age = findViewById(R.id.et_gomore_age);
        et_gomore_sex = findViewById(R.id.et_gomore_sex);
        et_gomore_height = findViewById(R.id.et_gomore_height);
        et_gomore_weight = findViewById(R.id.et_gomore_weight);

        findViewById(R.id.bt_app_bind).setOnClickListener(this);
        findViewById(R.id.bt_app_connect).setOnClickListener(this);
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
        findViewById(R.id.bt_test_temp).setOnClickListener(this);
        findViewById(R.id.bt_gomore_test).setOnClickListener(this);
        findViewById(R.id.bt_gomore_user).setOnClickListener(this);
        findViewById(R.id.bt_get_gomore_user).setOnClickListener(this);
        findViewById(R.id.bt_setBluttoothName).setOnClickListener(this);
        findViewById(R.id.bt_getBluttoothName).setOnClickListener(this);
        findViewById(R.id.tv_cmd_log_btn).setOnClickListener(this);
        findViewById(R.id.bt_aivela_protocol).setOnClickListener(this);
        findViewById(R.id.bt_wear_status).setOnClickListener(this);
        findViewById(R.id.bt_airplane_mode).setOnClickListener(this);
        findViewById(R.id.bt_work_mode).setOnClickListener(this);
        findViewById(R.id.bt_get_exception_log).setOnClickListener(this);
        findViewById(R.id.bt_delete_exception_log).setOnClickListener(this);
        findViewById(R.id.bt_ship_mode).setOnClickListener(this);
        findViewById(R.id.bt_reset_restart).setOnClickListener(this);
        findViewById(R.id.btn_ota).setOnClickListener(this);
        findViewById(R.id.btn_ota_local).setOnClickListener(this);
        //获取上个页面传递过来的deviceBean对象
        //部分OPPO/华为机型上Parcelable回读可能失败返回null，直接调用getDevice()会NPE闪退
        Intent intent = getIntent();
        deviceBean = intent != null ? intent.getParcelableExtra("deviceBean") : null;
        if (deviceBean != null && deviceBean.getDevice() != null) {
            bluetoothDevice = deviceBean.getDevice();
            mac = bluetoothDevice.getAddress();
            App.getInstance().setDeviceBean(deviceBean);
            try {
                BLEUtils.connectLockByBLE(this, deviceBean.getDevice());
            } catch (SecurityException e) {
                //OPPO/华为部分机型会回收BLUETOOTH_CONNECT权限，连接时抛SecurityException
                Toast.makeText(this, "缺少蓝牙权限，请到系统设置中授予", Toast.LENGTH_SHORT).show();
            }
        } else {
            Toast.makeText(this, "未知设备，请重新选择!", Toast.LENGTH_SHORT).show();
            finish();
        }

        LogicalApi.createToken("76d07e37bfe341b1a25c76c0e25f457a", "1204491582@qq.com", new ICreateToken() {
            @Override
            public void getTokenSuccess() {

            }

            @Override
            public void error(String msg) {

            }
        });
    }


    /**
     * 断联以后，重连
     *
     * @param mac
     */
    private void connect(String mac) {
        Logger.show(TAG, "connect=" + mac, 6);
        this.mac = mac;
        //合并
        checkPermission();
    }

    public void checkPermission() {


        Logger.show("ConnectDevice", "mac :" + mac);
        BluetoothDevice remote = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(mac);
        if (BLEService.isGetToken()) {
            Logger.show("ConnectDevice", " 蓝牙已连接");

        } else if (remote != null && (mac).equalsIgnoreCase(remote.getAddress())) {
                BLEUtils.connectLockByBLE(TestActivity.this, remote);
        }

    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        BLEUtils.disconnectBLE(this);
        LmAPILite.removeWLSCmdListener(this);
        handler.removeMessages(101);
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
        postView("\n连接失败 ");

        Log.e("ConnectDevice", " 蓝牙 connectionFailed");

        handler.removeMessages(101);
        handler.sendEmptyMessageDelayed(101, 5000);

    }

    @Override
    public void timeOut(String cmd) {
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
            });
        }


            if(view.getId()==R.id.bt_app_connect){
                postView("\nAPP_CONNECT");
                LmAPILite.APP_CONNECT(0, new IBindConnectRefreshListenerLite() {
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


        if(view.getId()==R.id.bt_clear_step){
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
        if(view.getId()==R.id.bt_sync_time){
            postView("\n开始同步时间");
            LmAPILite.SYNC_TIME_ZONE((byte) 8, new ISyncTimeListenerLite() {
                @Override
                public void syncTime(boolean updateTime, long timeStamp, long timeZone) {
                    postView("\n同步时间");
                }
            });
        }
        if(view.getId()==R.id.bt_read_time){
            postView("\n开始读取时间");
            LmAPILite.READ_TIME(new ISyncTimeListenerLite() {
                @Override
                public void syncTime(boolean updateTime, long timeStamp, long timeZone) {
                    postView("\n读取时间"+ DateUtils.longToString(timeStamp, "yyyy-MM-dd HH:mm")+",时区："+timeZone);
                }
            });
        }

        if(view.getId()==R.id.bt_soft_version){
            postView("\n开始获取软件版本信息");
            LmAPILite.GET_VERSION(true, new IVersionListenerLite() {
                @Override
                public void versionResult(String softwareVersion, String hardwareVersion) {
                    postView("\n获取软件版本信息成功" + softwareVersion);
                }
            });
        }


        if(view.getId()==R.id.bt_hardware_version){
            postView("\n开始获取硬件版本信息");
            LmAPILite.GET_VERSION(false, new IVersionListenerLite() {
                @Override
                public void versionResult(String softwareVersion, String hardwareVersion) {
                    postView("\n获取硬件版本信息成功" + hardwareVersion);
                }
            });
        }

        if(view.getId()==R.id.bt_battery){
            postView("\n开始获取电量信息");
            LmAPILite.GET_BATTERY((byte) 0x00, new IBatteryListenerLite() {
                @Override
                public void battery(int type, int electricity) {
                    if(type==0){
                        postView("\n获取电量信息:"+electricity);
                    }

                }

                @Override
                public void battery_push(int electricity, int chargingStatus) {
                    postView("\n电量推送:电量=" + electricity + ",充电状态=" + (chargingStatus == 0 ? "未充电" : (chargingStatus == 1 ? "充电中" : (chargingStatus == 2 ? "充满" : String.valueOf(chargingStatus)))));
                }
            });
        }

        if(view.getId()==R.id.bt_battery_state){
            postView("\n获取充电状态");
            LmAPILite.GET_BATTERY((byte) 0x01, new IBatteryListenerLite() {
                @Override
                public void battery(int type, int electricity) {
                    if(type==1){
                        postView("\n获取充电状态:"+electricity);
                    }

                }

                @Override
                public void battery_push(int electricity, int chargingStatus) {
                    postView("\n电量推送:电量=" + electricity + ",充电状态=" + (chargingStatus == 0 ? "未充电" : (chargingStatus == 1 ? "充电中" : (chargingStatus == 2 ? "充满" : String.valueOf(chargingStatus)))));
                }
            });
        }

        if(view.getId()==R.id.bt_step){
            postView("\n开始获取步数信息");
            LmAPILite.STEP_COUNTING(new IStepListenerLite() {
                @Override
                public void stepCount(int steps) {
                    postView("\n步数信息:"+steps);
                }

                @Override
                public void clearStepCount() {

                }
            });
        }

        if(view.getId()==R.id.bt_blood_oxygen){
            postView("\n开始测量血氧");
            LmAPILite.GET_HEART_Q2_WITH_TIME((byte) 1, (byte) 30, new IBloodOxygenListenerLite() {

                @Override
                public void progress(int progress) {
                    postView("\nprogress：" + progress );
                }

                @Override
                public void resultData(int bloodOxygen, int perfusion,int progress) {
                    postView("\n血氧：" + bloodOxygen + ",灌注度：" + perfusion + "%"+ ",进度：" + progress);
                }

                @Override
                public void waveformData(int serialNumber, int numberOfData, String waveformData, List<String[]> waveDataList) {
                    postView("\n波形数据：" + waveformData );
                }

                @Override
                public void error(int code, String message) {
                    postView("\nerror：" + code );
                }

                @Override
                public void success() {
                    postView("\nsuccess");
                }

                @Override
                public void stopQ2() {
                    postView("\n停止测量");
                }


            });
        }

        if(view.getId()==R.id.bt_heart) {
            postView("\n开始测量心率");
            LmAPILite.GET_HEART_ROTA((byte) 0, (byte) 30, new IHeartListenerLite() {


                @Override
                public void progress(int progress) {
                    postView("\n进度：" + progress);
                }

                @Override
                public void resultData(int heart, int heartRota, int yaLi, int temp) {
                    postView("\n测量心率数据：" + heart);
                }

                @Override
                public void waveformData(int serialNumber, int numberOfData, String waveData, List<String[]> waveDataList) {
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


            });
        }
            if(view.getId()==R.id.bt_gomore_test) {
                postView("\ngomore睡眠");
                //postView("\n开始读取未上传数据");
                List<GoMoreSleep> gomoreSleepList=new ArrayList<>();
                LmAPILite.GET_GOMORE_SLEEP(new IGoMoreListener() {
                    @Override
                    public void overviewOfSleep(GoMoreSleep goMoreSleep) {
//                        postView("\ngomore睡眠 overviewOfSleep:" + GsonUtils.beanToJson(goMoreSleep));
//                        Log.e(TAG, "overviewOfSleep: " + GsonUtils.beanToJson(goMoreSleep));
                        Gson gson = new Gson();
                        String json = gson.toJson(goMoreSleep);
                        gomoreSleepList.add(gson.fromJson(json, GoMoreSleep.class));
                    }

                    @Override
                    public void sleepStaging(GoMoreSleep goMoreSleep) {
//                        postView("\ngomore睡眠 sleepStaging:" + GsonUtils.beanToJson(goMoreSleep));
//                        Log.e(TAG, "sleepStaging: " + GsonUtils.beanToJson(goMoreSleep));
                        Gson gson = new Gson();
                        String json = gson.toJson(goMoreSleep);
                        gomoreSleepList.add(gson.fromJson(json, GoMoreSleep.class));
                    }

                    @Override
                    public void dataUploadFinish() {
                       postView("\ngomore睡眠 :" + GsonUtils.beanToJson(gomoreSleepList));
                       //Log.e(TAG, "gomore睡眠: " + GsonUtils.beanToJson(gomoreSleepList));
                        ImageSaverUtil.saveImageToInternalStorage(TestActivity.this,"gomore睡眠: " + GsonUtils.beanToJson(gomoreSleepList),"LM","gomore.txt",true);
                    }

                    @Override
                    public void noSleepData() {
                        postView("\ngomore睡眠 noSleepData");
                    }
                });
            }
        if(view.getId()==R.id.bt_test_temp) {
            postView("\n获取温度");
            LmAPILite.READ_TEMP(new ITempListenerLite() {


                @Override
                public void resultData(int temp) {
                    postView("\n测量体温完成后的结果:" + temp);
                }

                @Override
                public void testing(int temp) {

                }

                @Override
                public void error(int code) {
                    postView("\nerror:" + code);
                }
            });
        }
        if(view.getId()==R.id.bt_setBluttoothName) {
            String btName = et_bluetooth_name.getText().toString().trim();
            if (TextUtils.isEmpty(btName)) {
                Toast.makeText(this, "请正确输入内容", Toast.LENGTH_SHORT).show();
                return;
            }
            postView("\n设置蓝牙名:" + btName);
            LmAPILite.Set_BlueTooth_Name(btName, iSystemControlListenerLite);
        }
        if(view.getId()==R.id.bt_getBluttoothName) {
            postView("\n获取蓝牙名");
            LmAPILite.Get_BlueTooth_Name(iSystemControlListenerLite);
        }
        if(view.getId()==R.id.bt_gomore_user) {
            int age = parseGomoreInput(et_gomore_age.getText().toString());
            int sex = parseGomoreInput(et_gomore_sex.getText().toString());
            int height = parseGomoreInput(et_gomore_height.getText().toString());
            int weight = parseGomoreInput(et_gomore_weight.getText().toString());
            //年龄0-99，性别0/1，身高100-220（小于100置为100），体重10-150
            if (age < 0 || age > 99 || (sex != 0 && sex != 1)
                    || height < 0 || height > 220 || weight < 10 || weight > 150) {
                Toast.makeText(this, "请正确输入内容", Toast.LENGTH_SHORT).show();
                return;
            }
            if (height < 100) {
                height = 100;
            }
            postView("\n设置Gomore个人信息:" + age + "," + sex + "," + height + "," + weight);
            LmAPILite.SET_GOMORE_USER(age, sex, height, weight, -1, -1, -1, new IGoMoreUserListener() {
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
        if(view.getId()==R.id.tv_cmd_log_btn) {
            //右上角查看指令日志（多页面共用CmdLogManager）
            CmdLogManager.getInstance().show(this);
        }


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

        if(view.getId()==R.id.bt_ship_mode) {
            postView("\n设置Shipmode运输模式（0xF2/0x5），戒指将进入运输模式");
            LmAPILite.SET_SHIP_MODE();
        }

        if(view.getId()==R.id.bt_reset_restart) {
            postView("\n复位测试，重启戒指（0xF2/0x9）");
            LmAPILite.RESET_RESTART();
        }

        if(view.getId()==R.id.btn_ota) {
            LmAPILite.GET_VERSION(true, new IVersionListenerLite() {
                @Override
                public void versionResult(String softwareVersion, String hardwareVersion) {
                    postView("\n等待OTA升级");
                    //已经通过复合指令，获取到了版本号，不需要再调用LmAPILite.GET_VERSION
                    OtaApi.otaUpdateWithCheckVersion(softwareVersion, TestActivity.this, App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), new LmOtaProgressListener() {
                        @Override
                        public void error(String message) {
                            postView("\nota升级出错：" + message);
                        }

                        @Override
                        public void onProgress(int i) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    postView("\nota升级进度:"+i);
                                }
                            });

                           Logger.show("OTA", "OTA升级" + i);

                        }

                        @Override
                        public void onComplete() {

                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    postView("\nota升级结束");
                                }
                            });
                            Logger.show("OTA", "nota升级结束");
                            OtaApi.destoryOta(TestActivity.this);
                        }

                        @Override
                        public void isLatestVersion() {
                            postView("\n已是最新版本");
                        }

                        @Override
                        public void upgradeDescribe(String msg) {
                            postView("\n更新说明:"+msg);
                        }
                    });
                }
            });
        }
        if(view.getId()==R.id.btn_ota_local) {
            postView("\n选择固件文件");
            //启动文件选择器，尝试过滤.bin文件（部分设备支持）
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType("application/octet-stream");
            filePickerLauncher.launch(intent);
        }
    }

    /**
     * 处理选中的固件文件
     */
    private void handleSelectedFirmware(Uri uri) {
        try {
            //获取文件名
            String fileName = getFileNameFromUri(uri);
            if (TextUtils.isEmpty(fileName)) {
                Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
                return;
            }

            //校验文件扩展名是否为.bin
            if (!fileName.toLowerCase().endsWith(".bin")) {
                Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
                return;
            }

            //解析版本号
            String version = extractVersionFromFileName(fileName);
            if (TextUtils.isEmpty(version)) {
                Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
                return;
            }

            postView("\n本地OTA升级");
            postView("\n固件文件：" + fileName);
            postView("\n版本号：" + version);

            //将文件拷贝到应用私有目录
            File destFile = new File(getExternalFilesDir(null), fileName);
            copyUriToFile(uri, destFile);

            //设置升级文件
            OtaApi.setUpdateFile(destFile.getAbsolutePath());
            //设置文件名
            OtaApi.fileName = fileName;
            //开始OTA升级
            OtaApi.otaUpdateWithVersion(version, "", App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), TestActivity.this, new LmOtaProgressListener() {
                @Override
                public void error(String message) {
                    postView("\nota升级出错：" + message);
                }

                @Override
                public void onProgress(int i) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            postView("\nota升级进度:"+i);
                        }
                    });

                    Logger.show("OTA", "OTA升级" + i);
                }

                @Override
                public void onComplete() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            postView("\nota升级结束");
                        }
                    });
                    Logger.show("OTA", "nota升级结束");
                    OtaApi.destoryOta(TestActivity.this);
                }

                @Override
                public void isLatestVersion() {
                }

                @Override
                public void upgradeDescribe(String msg) {

                }
            });

        } catch (Exception e) {
            e.printStackTrace();
            postView("\n固件文件处理失败：" + e.getMessage());
            Toast.makeText(this, "请正确选择固件", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 从Uri获取文件名
     */
    private String getFileNameFromUri(Uri uri) {
        String fileName = null;

        //尝试从ContentResolver获取文件名
        Cursor cursor = getContentResolver().query(uri, null, null, null, null);
        if (cursor != null && cursor.moveToFirst()) {
            int nameIndex = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME);
            if (nameIndex >= 0) {
                fileName = cursor.getString(nameIndex);
            }
            cursor.close();
        }

        //如果获取失败，从Uri路径解析
        if (TextUtils.isEmpty(fileName)) {
            String path = uri.getPath();
            if (!TextUtils.isEmpty(path)) {
                fileName = path.substring(path.lastIndexOf('/') + 1);
            }
        }

        return fileName;
    }

    /**
     * 从文件名中提取版本号
     * 规则：如果有下划线，舍弃下划线前边部分，取.bin前的内容
     */
    private String extractVersionFromFileName(String fileName) {
        if (TextUtils.isEmpty(fileName)) {
            return null;
        }

        //移除.bin扩展名
        String nameWithoutExt = fileName;
        if (fileName.toLowerCase().endsWith(".bin")) {
            nameWithoutExt = fileName.substring(0, fileName.length() - 4);
        }

        //查找下划线
        int underscoreIndex = nameWithoutExt.lastIndexOf('_');
        if (underscoreIndex >= 0 && underscoreIndex < nameWithoutExt.length() - 1) {
            //返回下划线后的部分
            return nameWithoutExt.substring(underscoreIndex + 1);
        } else {
            //没有下划线，返回整个名称（不含扩展名）
            return nameWithoutExt;
        }
    }

    /**
     * 将Uri内容拷贝到文件
     */
    private void copyUriToFile(Uri uri, File destFile) throws Exception {
        InputStream inputStream = null;
        FileOutputStream outputStream = null;
        try {
            inputStream = getContentResolver().openInputStream(uri);
            outputStream = new FileOutputStream(destFile);

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            outputStream.flush();
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
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

    /**
     * 解析输入框内容，空值或非数字返回-1
     */
    private int parseGomoreInput(String text) {
        if (TextUtils.isEmpty(text)) {
            return -1;
        }
        try {
            return Integer.parseInt(text.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}