package com.lomo.demo.activity;

import static com.lomo.demo.activity.TestActivity.mac;
import static com.lomo.demo.activity.TestActivity.savePcmFile;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.lm.sdk.AdPcmTool;
import com.lm.sdk.BLEService;
import com.lm.sdk.LmAPI;
import com.lm.sdk.LogicalApi;
import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.IHeartListener;
import com.lm.sdk.inter.IHistoryListener;
import com.lm.sdk.inter.IResponseListener;
import com.lm.sdk.inter.ITempListener;
import com.lm.sdk.inter.IWebHistoryResult;
import com.lm.sdk.inter.IWebSleepResult;
import com.lm.sdk.inter.LmOtaProgressListener;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.mode.Sleep2thBean;
import com.lm.sdk.mode.SleepBean;
import com.lm.sdk.mode.SystemControlBean;
import com.lm.sdk.utils.BLEUtils;
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

public class TestActivity2 extends BaseActivity implements IResponseListener, View.OnClickListener {

    TextView tv_result2;
//    Button bt_calculate_sleep;
    Button bt_open_audio;
    Button bt_close_audio;
    private Handler handler = new Handler();  // 创建一个 Handler 实例
    private Runnable runnable;                 // 创建一个 Runnable 来定义任务
    String outputPath = com.lomo.demo.FileUtil.getSDPath(App.getInstance(), "保存" + ".pcm");
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test2);
        LmAPI.addWLSCmdListener(this,this);
        tv_result2 = findViewById(R.id.tv_result2);
        findViewById(R.id.bt_unpair).setOnClickListener(this);
        findViewById(R.id.bt_set_HID).setOnClickListener(this);
        findViewById(R.id.bt_get_HID).setOnClickListener(this);
        findViewById(R.id.bt_get_HID_code).setOnClickListener(this);
        findViewById(R.id.bt_set_audio_type).setOnClickListener(this);
        findViewById(R.id.bt_get_audio_type).setOnClickListener(this);
        findViewById(R.id.bt_temp_test).setOnClickListener(this);
        findViewById(R.id.bt_get_rssi).setOnClickListener(this);
        findViewById(R.id.bt_heart).setOnClickListener(this);
        findViewById(R.id.bt_app_bind).setOnClickListener(this);
        findViewById(R.id.bt_connect).setOnClickListener(this);
        findViewById(R.id.bt_refresh).setOnClickListener(this);
        findViewById(R.id.bt_ecg_demo).setOnClickListener(this);
        findViewById(R.id.bt_sleep_sevice).setOnClickListener(this);
        findViewById(R.id.btn_upload_history).setOnClickListener(this);
        findViewById(R.id.btn_ota).setOnClickListener(this);
        findViewById(R.id.bt_calculate_sleep).setOnClickListener(this);
    }

    @Override
    public void SystemControl(SystemControlBean systemControlBean) {

    }

    @Override
    public void lmBleConnecting(int code) {

    }

    @Override
    public void lmBleConnectionSucceeded(int code) {

    }

    @Override
    public void lmBleConnectionFailed(int code) {

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

    /**
     * 获取序列号，私版
     * @param bytes
     */
    @Override
    public void getSerialNum(byte[] bytes) {

    }

    /**
     * 设置序列号，私版
     * @param b
     */
    @Override
    public void setSerialNum(byte b) {

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
        if(result == (byte)0x00){
            postView("\n设置HID失败");
        }else if(result == (byte)0x01){
            postView("\n设置HID成功");
        }
    }

    @Override
    public void GET_HID(byte touch, byte gesture, byte system) {
        postView("\n当前触摸hid模式：" + touch + "\n当前手势hid模式：" + gesture + "\n当前系统：" + system);
    }

    @Override
    public void GET_HID_CODE(byte[] bytes) {
        Logger.show("getHidCode", "支持与否：" + bytes[0] + " 触摸功能：" + bytes[1] + " 空中手势：" + bytes[9] + "\n");

        Logger.show("byteToBitString", byteToBitString(bytes[1]));
        char[] touchModes = byteToBitString(bytes[1]).toCharArray();
        char[] gestureModes = byteToBitString(bytes[9]).toCharArray();

        if (bytes[0] == 0) {
            postView("\n不支持HID功能");
        } else {
            postView("\n支持HID功能");
        }
        if ("00000000".equals(byteToBitString(bytes[1]))) {//不支持触摸功能
            postView("\n不支持触摸功能");
        } else {
            postView("\n支持触摸功能");
        }

        if (touchModes[touchModes.length - 1] == '1') {//拍照
            postView("\n支持触摸拍照功能");
        } else {
            postView("\n不支持触摸拍照功能");
        }

        if (touchModes[touchModes.length - 2] == '1') {//短视频
            postView("\n支持触摸短视频功能");
        } else {
            postView("\n不支持触摸短视频功能");
        }

        if (touchModes[touchModes.length - 3] == '1') {//音乐
            postView("\n支持触摸音乐功能");
        } else {
            postView("\n不支持触摸音乐功能");
        }

        if (touchModes[touchModes.length - 5] == '1') {//音频
            postView("\n支持触摸音频功能");
        } else {
            postView("\n不支持触摸音频功能");
        }

        if ("00000000".equals(byteToBitString(bytes[9]))) {//不支持空中手势
            postView("\n不支持空中手势功能");
        } else {
            postView("\n支持空中手势功能");
        }

        if (gestureModes[gestureModes.length - 1] == '1') {//拍照
            postView("\n支持手势拍照功能");
        } else {
            postView("\n不支持手势拍照功能");
        }

        if (gestureModes[gestureModes.length - 2] == '1') {//短视频
            postView("\n支持手势短视频功能");
        } else {
            postView("\n不支持手势短视频功能");
        }

        if (gestureModes[gestureModes.length - 3] == '1') {//音乐
            postView("\n支持手势音乐功能");
        } else {
            postView("\n不支持手势音乐功能");
        }

        if (gestureModes[gestureModes.length - 5] == '1') {//打响指（拍照）
            postView("\n支持打响指（拍照）功能");
        } else {
            postView("\n不支持打响指（拍照）功能");
        }
    }

    @Override
    public void GET_CONTROL_AUDIO_ADPCM(byte result) {
        if(result == (byte)0x00){
            postView("\n音频类型：pcm");
        }else if(result == (byte)0x01){
            postView("\n音频类型：adpcm");
        }
    }

    @Override
    public void SET_AUDIO_ADPCM_AUDIO(byte result) {
        if(result == (byte)0x00){
            postView("\n设置音频类型失败");
        }else if(result == (byte)0x01){
            postView("\n设置音频类型成功");
        }
    }

    @Override
    public void TOUCH_AUDIO_FINISH_XUN_FEI() {

    }

    public static String byteToBitString(byte b) {
        StringBuilder bitString = new StringBuilder();
        for (int i = 7; i >= 0; i--) {
            bitString.append((b >> i) & 1); // 移位并与1进行与操作，获取最低位的bit
        }
        return bitString.toString();
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
    public void CONTROL_AUDIO(byte[] bytes) {
        postView("\n音频结果：" + Arrays.toString(bytes));
        byte[] adToPcm = new AdPcmTool().adpcmToPcmFromJNI(bytes);

        savePcmFile(outputPath,adToPcm);
        postView("\n已保存：" + outputPath);
    }

    @Override
    public void motionCalibration(byte sport_count) {

    }

    @Override
    public void stopBloodPressure(byte data) {

    }

    @Override
    public void appBind(SystemControlBean systemControlBean) {
        postView("\nappBind："+systemControlBean.toString());
    }

    @Override
    public void appConnect(SystemControlBean systemControlBean) {
        postView("\nappConnect："+systemControlBean.toString());
    }

    @Override
    public void appRefresh(SystemControlBean systemControlBean) {
        postView("\nappRefresh："+systemControlBean.toString());
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.bt_set_HID:
                byte[] hidBytes = new byte[3];
                hidBytes[0] = 0x04;             //上传实时音频
                hidBytes[1] = (byte) 0xFF;      //关闭
                hidBytes[2] = 0x00;             //系统类型 0：安卓  1：IOS  2：鸿蒙
                LmAPI.SET_HID(hidBytes,TestActivity2.this);
                break;
            case R.id.bt_get_HID:
                LmAPI.GET_HID();//获取HID现在的模式
                break;
            case R.id.bt_get_HID_code:
                LmAPI.GET_HID_CODE((byte)0x00);  //系统类型 0：安卓  1：IOS  2：windows
                break;
            case R.id.bt_set_audio_type:
                LmAPI.CONTROL_AUDIO_ADPCM_AUDIO((byte)0x01); //0 pcm, 1 adpcm
                break;
            case R.id.bt_get_audio_type:
                LmAPI.GET_CONTROL_AUDIO_ADPCM();
                break;
            case R.id.bt_temp_test:
                postView("\n开始测量温度");
                LmAPI.READ_TEMP(new ITempListener() {
                    @Override
                    public void resultData(int temp) {
                        postView("\n返回的温度：" + temp * 0.01 );
                    }

                    @Override
                    public void testing(int num) {
                        postView("\n测量中：" + num * 0.01 );
                    }

                    @Override
                    public void error(int code) {
                        postView("\n温度报错了,类型:" + code);
                    }
                });
                break;
            case R.id.bt_unpair://解绑,返回扫描界面
                postView("\n解绑\n");
                BLEUtils.setGetToken(false);
                BLEUtils.disconnectBLE(this);
                BLEUtils.removeBond(BLEService.getmBluetoothDevice());
                UtilSharedPreference.saveString(TestActivity2.this,"address","");
                Intent intent = new Intent(TestActivity2.this, MainActivity.class);

                startActivity(intent);
                finish();
                break;
            case R.id.bt_get_rssi://获取信号强度,略微有点延迟；信号强度-60 > -70
                BLEService.readRomoteRssi();
                postView("\nrssi == "+ BLEService.RSSI);
                break;
            case R.id.bt_heart:
                postView("\n开始测量心率");
                LmAPI.GET_HEART_ROTA((byte) 0x00, (byte)0x30,new IHeartListener() {
                    @Override
                    public void progress(int progress) {
                        postView("\n测量心率进度：" + progress + "%");
                    }

                    @Override
                    public void resultData(int heart, int heartRota, int yaLi, int temp) {
//                        postView("\n测量心率数据：" + heart);
                    }

                    @Override
                    public void waveformData(byte seq, byte number, String waveData) {
                    }

                    @Override
                    public void rriData(byte seq, byte number, String data) {
                        postView("\ndata的值是：" + data);
                    }

                    @Override
                    public void error(int code) {
                        postView("\n测量心率错误：" + code);
                    }

                    @Override
                    public void success() {
                        postView("\n测量心率完成");
                    }

                    @Override
                    public void resultDataSHOUSHI(int heart, int bloodOxygen) {

                    }
                });
                break;
            case R.id.bt_app_bind:
                LmAPI.APP_BIND();

                break;
            case R.id.bt_connect:
                LmAPI.APP_CONNECT();
                break;
            case R.id.bt_refresh:
                LmAPI.APP_REFRESH();
                break;
            case R.id.bt_calculate_sleep:
                postView("\n开始拿calculateSleep");
                String formattedDateTime = "2025-03-5";
                try {
                    // 解析输入日期字符串为 LocalDate 对象
                    LocalDate localDate = LocalDate.parse(formattedDateTime);

                    // 转换为 LocalDateTime 对象，设置时间为午夜
                    LocalDateTime localDateTime = localDate.atTime(0, 0);

                    // 定义输出格式
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    formattedDateTime = localDateTime.format(formatter);

                    // 输出结果
                    System.out.println("Formatted date and time: " + formattedDateTime);

                } catch (Exception e) {
                    e.printStackTrace();
                }
//                SleepBean sleepBean = LogicalApi.calculateSleep(formattedDateTime, App.getInstance().getDeviceBean().getDevice().getAddress(),1);
                SleepBean sleepBean = LogicalApi.calculateSleep(formattedDateTime, mac,1);
                Logger.show("shuju","sleepBean深睡:" + sleepBean.getHighTime() );
                Logger.show("shuju","浅睡："+ sleepBean.getLowTime() );
                Logger.show("shuju","清醒："+ sleepBean.getQxTime() );
                Logger.show("shuju","眼动："+ sleepBean.getYdTime() );
                Logger.show("shuju","全部睡眠小时:" + sleepBean.getAllHours());
                Logger.show("shuju","全部睡眠分钟："+ sleepBean.getAllMinutes());
                Logger.show("shuju","入睡时间戳："+ sleepBean.getStartTime() );
                Logger.show("shuju","清醒时间戳："+ sleepBean.getEndTime() );
                Logger.show("shuju","零星睡眠小时:："+ sleepBean.getHours() );
                Logger.show("shuju","零星睡眠分钟："+ sleepBean.getMinutes() );
                postView("\nsleepBean深睡:" + sleepBean.getHighTime() +" \n浅睡："+ sleepBean.getLowTime() +" \n清醒："+ sleepBean.getQxTime() +" \n眼动："+ sleepBean.getYdTime());

                break;
            case R.id.bt_ecg_demo:
                LogicalApi.startECGActivity(TestActivity2.this);
                break;
            case R.id.bt_sleep_sevice:
                String dateTimeString = "2025-02-15 23:59:59";
                LogicalApi.getSleepDataFromService( dateTimeString, new IWebSleepResult() {
                    @Override
                    public void sleepDataSuccess(Sleep2thBean sleep2thBean) {
                        // 定义日期时间格式
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        // 将时间戳转换为 Date 对象
                        Date startDate = new Date(sleep2thBean.getStartTime()*1000);
                        // 将时间戳转换为 Date 对象
                        Date endDate = new Date(sleep2thBean.getEndTime()*1000);
                        postView("\n入睡时间:" + sdf.format(startDate)+"\n清醒时间:" +sdf.format(endDate)+"\n睡眠小时:" + sleep2thBean.getHours()+"\n睡眠分钟:" + sleep2thBean.getMinutes() );

                    }

                    @Override
                    public void error(String message) {

                    }

                });
                break;
            case R.id.btn_upload_history:
                LmAPI.READ_HISTORY_UPDATE_TO_SERVER((byte) 0x01,  mac, new IHistoryListener() {
                    @Override
                    public void error(int code) {
                        if (code == 3) {
                            postView("\n出现了BIX的问题");
                        }
                    }

                    @Override
                    public void success() {
                        postView("\n读取记录完成");

                    }

                    @Override
                    public void progress(double progress, HistoryDataBean historyDataBean) {
                        if (historyDataBean != null) {
                            postView("\n读取记录进度:" + progress + "%");
                            postView("\n记录内容:" + historyDataBean.toString());
                        }

                    }
                }, new IWebHistoryResult() {
                    @Override
                    public void updateHistoryFinish() {
                        postView("\n历史数据上传服务器完成");
                    }

                    @Override
                    public void serviceError(String errorMsg) {
                        postView("\n服务器出错");
                    }
                });

                break;
            case R.id.btn_ota:
                //提供给第三方使用的ota升级，已包含检查当前版本号是否需要更新
                OtaApi.otaUpdateWithCheckVersion("7.1.1.6Z3A", TestActivity2.this, App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), new LmOtaProgressListener() {
                    @Override
                    public void error(String message) {
                        postView("\nota升级出错："+message);
                    }

                    @Override
                    public void onProgress(int i) {
                        //  postView("\nota升级进度:"+i);
                        Logger.show("OTA","OTA升级"+i);

                    }

                    @Override
                    public void onComplete() {
                      //  postView("\nota升级结束");
                        Logger.show("OTA","nota升级结束");
                        OtaApi.destoryOta(TestActivity2.this);
                        //需要延时调用蓝牙重连
//                        BLEUtils.disconnectBLE(TestActivity2.this);
//                        BLEUtils.connectLockByBLE(TestActivity2.this,App.getInstance().getDeviceBean().getDevice());


                    }

                    @Override
                    public void isLatestVersion() {
                        postView("\n已是最新版本");
                    }
                });
//                //检查当前硬件版本是否需要更新，用于第三方公司，页面上显示更新信息
//                OtaApi.checkCurrentVersionNeedUpdate("", TestActivity.this, new ICheckOtaVersion() {
//                    @Override
//                    public void checkVersionResult(boolean needUpdate) {
//
//                    }
//                });
                //
//                OtaApi.otaUpdateWithVersion("", App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), new LmOtaProgressListener() {
//                    @Override
//                    public void error(String message) {
//
//                    }
//
//                    @Override
//                    public void onProgress(int i) {
//
//                    }
//
//                    @Override
//                    public void onComplete() {
//
//                    }
//
//                    @Override
//                    public void isLatestVersion() {
//
//                    }
//                });

                break;

            default:
                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnable);
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
