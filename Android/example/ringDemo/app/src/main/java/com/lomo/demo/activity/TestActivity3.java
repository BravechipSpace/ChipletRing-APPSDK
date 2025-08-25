package com.lomo.demo.activity;

import static com.lomo.demo.activity.TestActivity.mac;
import static com.lomo.demo.activity.TestActivity.savePcmFile;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.lm.sdk.AdPcmTool;
import com.lm.sdk.BLEService;
import com.lm.sdk.BaseLmAPi;
import com.lm.sdk.LmAPI;
import com.lm.sdk.LmAPILite;
import com.lm.sdk.LogicalApi;
import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.IFileListListener;
import com.lm.sdk.inter.IHIDListener;
import com.lm.sdk.inter.IHeartListener;
import com.lm.sdk.inter.IHistoryListener;
import com.lm.sdk.inter.IResponseListener;
import com.lm.sdk.inter.ITempListener;
import com.lm.sdk.inter.IWebHistoryResult;
import com.lm.sdk.inter.IWebSleepResult;
import com.lm.sdk.inter.IWebStepResult;
import com.lm.sdk.inter.LmOtaProgressListener;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.mode.Sleep2thBean;
import com.lm.sdk.mode.SleepBean;
import com.lm.sdk.mode.SystemControlBean;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.CMDUtils;
import com.lm.sdk.utils.Logger;
import com.lm.sdk.utils.UtilSharedPreference;
import com.lomo.demo.R;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class TestActivity3 extends BaseActivity implements IResponseListener,  View.OnClickListener {

    TextView tv_result2;
    private BluetoothDevice mBluetoothDevice;

    public final static String TAG = "TestActivity3";
    private BluetoothAdapter mBluetoothAdapter;
    private boolean autoConnect=true;//是否需要直接连接，在手动解绑断连的时候，有时候会触发取消配对的操作
    private Handler handler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 0x99:

                    Logger.show("TestActivity3", "===执行指令超时===");

                    break;
                default:
                    break;
            }
        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test3);
        tv_result2 = findViewById(R.id.tv_result2);
        findViewById(R.id.bt_jinxingpeidui).setOnClickListener(this);
        findViewById(R.id.bt_quxiaopeidui).setOnClickListener(this);
        findViewById(R.id.bt_lanyazhilian).setOnClickListener(this);
        findViewById(R.id.bt_duankailanya).setOnClickListener(this);
        findViewById(R.id.bt_fendashoushi).setOnClickListener(this);
        findViewById(R.id.bt_huoqushoushi).setOnClickListener(this);
        findViewById(R.id.bt_currentStep).setOnClickListener(this);

        mBluetoothDevice =   App.getInstance().getDeviceBean().getDevice();
        BLEUtils.isHIDDevice=false;//设置为不是配对戒指，防止sdk自动配对，进行手动进行配对操作
    }




    @Override
    public void onClick(View v) {

            if(v.getId()== R.id.bt_jinxingpeidui) {

                postView("进行配对\n");
                boolean isbonded = mBluetoothDevice.createBond();
                autoConnect = true;
                if (!isbonded) {//兼容判断，如果监测不能配对，启用老流程
                    Logger.show(TAG, "HID绑定不匹配，直接连接");
                    BLEUtils.connectLockByBLE(TestActivity3.this, mBluetoothDevice);
                } else {
                    Logger.show(TAG, "HID绑定操作");
                    // 用BroadcastReceiver来取得搜索结果
                    IntentFilter intentFilter = new IntentFilter();
                    intentFilter.addAction(BluetoothDevice.ACTION_FOUND);//搜索发现设备
                    intentFilter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED);//状态改变
                    intentFilter.addAction(BluetoothAdapter.ACTION_SCAN_MODE_CHANGED);//行动扫描模式改变了
                    intentFilter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);//动作状态发生了变化
                    intentFilter.addAction(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        getApplicationContext().registerReceiver(searchDevices, intentFilter, RECEIVER_EXPORTED);
                    } else {
                        getApplicationContext().registerReceiver(searchDevices, intentFilter);
                    }

                }
            }
            if(v.getId()==R.id.bt_quxiaopeidui) {

                postView("取消配对\n");
                BLEUtils.removeBond(mBluetoothDevice);
                App.needAutoConnect = false;
            }

            if(v.getId()== R.id.bt_lanyazhilian) {
                postView("蓝牙直连\n");
                BLEUtils.isHIDDevice = false;
                BLEUtils.connectLockByBLE(TestActivity3.this, mBluetoothDevice);
            }
            if(v.getId()== R.id.bt_duankailanya) {
                postView("断开蓝牙\n");
                BLEUtils.removeBond(mBluetoothDevice);
                BLEUtils.disconnectBLE(TestActivity3.this);
                App.needAutoConnect = false;
                autoConnect = false;
            }
            if(v.getId()==R.id.bt_fendashoushi) {
                postView("奋达手势开启\n");
                LmAPI.SET_HID_FENDA((byte) 1, (byte) 0xff, (byte) 0xff, (byte) 0xff, new IHIDListener() {
                    @Override
                    public void setHIDSetting(boolean result) {
                        postView("setHIDSetting\n" + result + "\n");
                    }

                    @Override
                    public void getHIDSetting(byte sh, byte xh, byte dxz, byte nyn) {

                    }
                });
            }
            if(v.getId()== R.id.bt_huoqushoushi) {
                postView("奋达手势关闭\n");
                LmAPI.SET_HID_FENDA((byte) 0xff, (byte) 0xff, (byte) 0xff, (byte) 0xff, new IHIDListener() {
                    @Override
                    public void setHIDSetting(boolean result) {
                        postView("setHIDSetting\n" + result + "\n");
                    }

                    @Override
                    public void getHIDSetting(byte sh, byte xh, byte dxz, byte nyn) {

                    }
                });
            }
        if(v.getId()==R.id.bt_currentStep) {

            postView("当前用户的步数\n");
            // BleDeviceInfo bleDeviceInfo = LogicalApi.getBleDeviceInfoWhenBleScan(device, rssi, bytes,false);
            //这个方法，获取广播，如果bleDeviceInfo.getStepAccumulation()>0，说明是新固件，支持每5分钟步数清零，重新累积功能
            //如果不是新固件，获取步数还是使用以前的
            LmAPI.GET_CURRENT_STEP_FROM_SERVER(true,mBluetoothDevice.getAddress(), new IWebStepResult() {
                @Override
                public void getCurrentSteps(double allStep) {
                    postView("步数：\n"+allStep);
                }

                @Override
                public void error(String message) {

                }
            });
        }

    }

    /**
     * 蓝牙接收广播
     */
    private BroadcastReceiver searchDevices = new BroadcastReceiver() {
        //接收
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            //状态改变时
            BLEUtils.setConnecting(false);

            if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(action)) {
                switch (mBluetoothDevice.getBondState()) {
                    case BluetoothDevice.BOND_BONDING://正在配对
                        Log.d("BLEService", "正在配对......===============");
                        postView("正在配对......===============\n");
                        break;
                    case BluetoothDevice.BOND_BONDED://配对结束
                        if (initializeBluetooth()) {
                            Log.d("BLEService", "连接成功    =======");
                            postView("连接成功    =======\n");
                            // sendStatusChange(CONNECT_STATE_SUCCESS);
                            BLEUtils.setMac(mBluetoothDevice.getAddress());
                        } else {
                            Log.d("BLEService", "连接失败    =======");
                            postView("连接失败    =======\n");
                            //   removeBond(mBluetoothDevice);
                        }

                        break;
                    case BluetoothDevice.BOND_NONE://取消配对/未配对
                        Log.d("BLEService", "取消配对    =======");
                        postView("取消配对    =======\n");
                        if(autoConnect){
                            postView("用户点击取消配对后直连    =======\n");
                            BLEUtils.connectLockByBLE(TestActivity3.this, mBluetoothDevice);
                        }

                    default:
                        Log.d("BLEService", "default    =======");
                        postView("default    =======\n");
                        // removeBond(mBluetoothDevice);
                        break;
                }
            }
        }
    };
    // 初始化蓝牙连接
    public boolean initializeBluetooth() {
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null) {
            return false; // 设备不支持蓝牙
        }
//        Set<BluetoothDevice> bondedDevices = mBluetoothAdapter.getBondedDevices();

        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                BLEUtils.connectLockByBLE(TestActivity3.this, mBluetoothDevice);
            }
        }, 2000);


        return true;
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        App.needAutoConnect=true;
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

    @Override
    public void lmBleConnecting(int code) {
        postView("lmBleConnecting    =======\n");
        BLEUtils.setConnecting(true);
    }

    @Override
    public void lmBleConnectionSucceeded(int code) {
        postView("lmBleConnectionSucceeded    =======\n");

        BLEUtils.setConnecting(false);

            Logger.show(TAG,"code="+code);
            if (code == 7) {

                BLEUtils.setGetToken(true);

        }

    }

    @Override
    public void lmBleConnectionFailed(int code) {
        postView("lmBleConnectionFailed    =======\n");
        BLEUtils.setGetToken(false);
        BLEUtils.setConnecting(false);
    }

    @Override
    public void VERSION(byte type, String version) {

    }

    @Override
    public void syncTime(byte datum, byte[] time) {

    }

    @Override
    public void stepCount(byte[] bytesToInt) {

    }

    @Override
    public void clearStepCount(byte data) {

    }

    @Override
    public void battery(byte b, byte datum) {

    }

    @Override
    public void battery_push(byte b, byte datum) {

    }

    @Override
    public void timeOut() {

    }

    @Override
    public void saveData(String str_data) {

    }

    @Override
    public void reset(byte[] data) {

    }

    @Override
    public void setCollection(byte result) {

    }

    @Override
    public void getCollection(byte[] data) {

    }

    @Override
    public void getSerialNum(byte[] serial) {

    }

    @Override
    public void setSerialNum(byte data) {

    }

    @Override
    public void cleanHistory(byte data) {

    }

    @Override
    public void setBlueToolName(byte data) {

    }

    @Override
    public void readBlueToolName(byte len, String name) {

    }

    @Override
    public void stopRealTimeBP(byte isSend) {

    }

    @Override
    public void BPwaveformData(byte seq, byte number, String waveDate) {

    }

    @Override
    public void onSport(int type, byte[] data) {

    }

    @Override
    public void breathLight(byte time) {

    }

    @Override
    public void SET_HID(byte result) {

    }

    @Override
    public void GET_HID(byte touch, byte gesture, byte system) {

    }

    @Override
    public void GET_HID_CODE(byte[] bytes) {

    }

    @Override
    public void GET_CONTROL_AUDIO_ADPCM(byte pcmType) {

    }

    @Override
    public void SET_AUDIO_ADPCM_AUDIO(byte result) {

    }

    @Override
    public void TOUCH_AUDIO_FINISH_XUN_FEI() {

    }

    @Override
    public void setAudio(short totalLength, int index, byte[] audioData) {

    }

    @Override
    public void stopHeart(byte data) {

    }

    @Override
    public void stopQ2(byte data) {

    }

    @Override
    public void GET_ECG(byte[] bytes) {

    }

    @Override
    public void SystemControl(SystemControlBean systemControlBean) {

    }

    @Override
    public void setUserInfo(byte result) {

    }

    @Override
    public void getUserInfo(int sex, int height, int weight, int age) {

    }

    @Override
    public void CONTROL_AUDIO(byte[] bytes) {

    }

    @Override
    public void motionCalibration(byte sport_count) {

    }

    @Override
    public void stopBloodPressure(byte data) {

    }

    @Override
    public void appBind(SystemControlBean systemControlBean) {

    }

    @Override
    public void appConnect(SystemControlBean systemControlBean) {

    }

    @Override
    public void appRefresh(SystemControlBean systemControlBean) {

    }
}
