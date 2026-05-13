package com.lomo.demo.activity;

import static com.lomo.demo.activity.TestActivity.mac;

import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
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
import com.lm.sdk.LmAPILite;
import com.lm.sdk.LogicalApi;
import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.IFileListListener;
import com.lm.sdk.inter.IHeartListener;
import com.lm.sdk.inter.IHistoryListener;
import com.lm.sdk.inter.IKeyDownListener;
import com.lm.sdk.inter.IRealTimePPGListener;
import com.lm.sdk.inter.IResponseListener;
import com.lm.sdk.inter.ITempListener;
import com.lm.sdk.inter.IWebHistoryResult;
import com.lm.sdk.inter.IWebSleepResult;
import com.lm.sdk.inter.LmOtaProgressListener;
import com.lm.sdk.lmApiInter.IAudioListenerLite;
import com.lm.sdk.lmApiInter.IHIDListenerLite;
import com.lm.sdk.lmApiInter.IHistoryListenerLite;
import com.lm.sdk.lmApiInter.IResponseListenerLite;
import com.lm.sdk.mode.GestureSupport;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.mode.Sleep2thBean;
import com.lm.sdk.mode.SleepBatchBean;
import com.lm.sdk.mode.SleepBean;
import com.lm.sdk.mode.SystemControlBean;
import com.lm.sdk.mode.TouchSupport;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.CMDUtils;
import com.lm.sdk.utils.FileUtil;
import com.lm.sdk.utils.GoMoreUtils;
import com.lm.sdk.utils.Logger;
import com.lm.sdk.utils.UtilSharedPreference;
import com.lomo.demo.R;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class TestActivity2 extends BaseActivity implements IResponseListenerLite, View.OnClickListener {

    TextView tv_result2;
//    Button bt_calculate_sleep;
    Button bt_open_audio;
    Button bt_close_audio;
    private Handler handler = new Handler();  // 创建一个 Handler 实例
    private Runnable runnable;                 // 创建一个 Runnable 来定义任务
    String outputPath = com.lomo.demo.FileUtil.getSDPath(App.getInstance(), "保存" + ".pcm");
    private byte[] fileNameByte=new byte[]{};

    private IHIDListenerLite ihidListenerLite=new IHIDListenerLite() {
        @Override
        public void setHIDResut(boolean success) {
            if(!success){
                postView("\n设置HID失败");
            }else {
                postView("\n设置HID成功");
            }
        }

        @Override
        public void getHIDInfo(int touchMode, int gestureMode, int system) {
            postView("\n当前触摸hid模式：" + touchMode + "\n当前手势hid模式：" + gestureMode + "\n当前系统：" + system);
        }

        @Override
        public void getHidCode(boolean HIDSupport, TouchSupport touchSupport, GestureSupport gestureSupport) {
            postView("\nHIDSupport：" + HIDSupport + "\ntouchSupport：" + touchSupport + "\ngestureSupport：" + gestureSupport);
        }
    };
    private IAudioListenerLite audiolistenerLite = new IAudioListenerLite() {


        @Override
        public void controlAudioResult(byte[] bytes, int audioType) {
            postView("\n音频长度"+bytes.length+",类型1单声道2双声道："+audioType);
        }

        @Override
        public void controlAudioRawDataResult(byte[] bytes) {

        }

        @Override
        public void getControlAudioAdpcmResult(boolean adpcm) {

        }

        @Override
        public void pushAudioInformationResult(boolean success) {

        }

        @Override
        public void TOUCH_AUDIO_FINISH_XUN_FEI() {

        }

        @Override
        public void recordingResult(boolean result) {

        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test2);
        tv_result2 = findViewById(R.id.tv_result2);
        findViewById(R.id.bt_unpair).setOnClickListener(this);
        findViewById(R.id.bt_set_HID).setOnClickListener(this);
        findViewById(R.id.bt_get_HID).setOnClickListener(this);
        findViewById(R.id.bt_get_HID_code).setOnClickListener(this);
        findViewById(R.id.bt_set_audio_type).setOnClickListener(this);
        findViewById(R.id.bt_stop_audio).setOnClickListener(this);
        findViewById(R.id.bt_get_audio_type).setOnClickListener(this);

        findViewById(R.id.bt_get_rssi).setOnClickListener(this);


        findViewById(R.id.bt_ecg_demo).setOnClickListener(this);
        findViewById(R.id.bt_sleep_sevice).setOnClickListener(this);

        findViewById(R.id.btn_ota).setOnClickListener(this);

        findViewById(R.id.bt_file_list).setOnClickListener(this);
        findViewById(R.id.bt_file_content).setOnClickListener(this);
        findViewById(R.id.bt_test2).setOnClickListener(this);
        findViewById(R.id.bt_star_ppg).setOnClickListener(this);
        findViewById(R.id.bt_stop_ppg).setOnClickListener(this);
        findViewById(R.id.bt_testGomore).setOnClickListener(this);
        findViewById(R.id.btn_touch_test_open).setOnClickListener(this);
        findViewById(R.id.btn_touch_test_close).setOnClickListener(this);


        /**
         * 获取戒指主动推送的按键信息
         * @param key
         * 0x0:长按
         * 0x1:单击
         * 0x2:双击
         * 0x3:三击
         * 0x4:上滑
         * 0x5:下滑
         * 0x6:左滑
         * 0x7:右滑
         */
        LmAPILite.KEY_DOWN_LISTENER(new IKeyDownListener() {
            @Override
            public void ringPushKeyDownResult(int key) {

                postView("触摸测试："+key+"\n");
            }
        });

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
    public void saveData(String str_data) {

    }




    public static String byteToBitString(byte b) {
        StringBuilder bitString = new StringBuilder();
        for (int i = 7; i >= 0; i--) {
            bitString.append((b >> i) & 1); // 移位并与1进行与操作，获取最低位的bit
        }
        return bitString.toString();
    }





    @Override
    public void onClick(View v) {
        if(v.getId()== R.id.bt_set_HID){
            LmAPILite.SET_HID(0x04,(byte) 0xFF,TestActivity2.this,ihidListenerLite);
        }

        if(v.getId()== R.id.bt_get_HID){
            LmAPILite.GET_HID(ihidListenerLite);//获取HID现在的模式
        }

        if(v.getId()== R.id.bt_get_HID_code){
            LmAPILite.GET_HID_CODE((byte)0x00,ihidListenerLite);  //系统类型 0：安卓  1：IOS  2：windows
        }

        if(v.getId()== R.id.bt_set_audio_type){
            LmAPILite.CONTROL_AUDIO_ADPCM((byte)0x01,audiolistenerLite);
        }
        if(v.getId()== R.id.bt_get_audio_type){
            LmAPILite.GET_CONTROL_AUDIO_ADPCM(audiolistenerLite);
        }
        if(v.getId()== R.id.bt_stop_audio){
            LmAPILite.CONTROL_AUDIO_ADPCM((byte)0x0,audiolistenerLite);
        }


        if(v.getId()== R.id.bt_unpair){
            postView("\n解绑\n");
            BLEUtils.setGetToken(false);
            BLEUtils.disconnectBLE(this);
            BLEUtils.removeBond(BLEService.getmBluetoothDevice());
            UtilSharedPreference.saveString(TestActivity2.this,"address","");
            Intent intent = new Intent(TestActivity2.this, MainActivity.class);

            startActivity(intent);
            finish();
        }

        if(v.getId()== R.id.bt_get_rssi){
            BLEService.readRomoteRssi();
            postView("\nrssi == "+ BLEService.RSSI);
        }


           if(v.getId()==R.id.bt_ecg_demo) {


               LogicalApi.startECGActivity(TestActivity2.this);
           }
        if(v.getId()==R.id.bt_sleep_sevice) {

            String dateTimeString = "2025-02-15 23:59:59";
            LogicalApi.getSleepDataFromService(dateTimeString, new IWebSleepResult() {
                @Override
                public void sleepDataSuccess(Sleep2thBean sleep2thBean) {
                    // 定义日期时间格式
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    // 将时间戳转换为 Date 对象
                    Date startDate = new Date(sleep2thBean.getStartTime() * 1000);
                    // 将时间戳转换为 Date 对象
                    Date endDate = new Date(sleep2thBean.getEndTime() * 1000);
                    postView("\n睡眠小时:" + sleep2thBean.getHours() + "\n睡眠分钟:" + sleep2thBean.getMinutes() + "\n开始时间和结束时间，需要通过绘图算法过滤后获得，详见3.5.3-睡眠数据绘图相关");

                }

                @Override
                public void error(String message) {

                }

                @Override
                public void sleepDataBatchSuccess(List<SleepBatchBean> sleepBeanList) {

                }


            });
        }

        if(v.getId()==R.id.btn_ota) {

            //提供给第三方使用的ota升级，已包含检查当前版本号是否需要更新
//            OtaApi.otaUpdateWithCheckVersion("7.2.7.2Z5I", TestActivity2.this, App.getInstance().getDeviceBean().getDevice(), App.getInstance().getDeviceBean().getRssi(), new LmOtaProgressListener() {
//                @Override
//                public void error(String message) {
//                    postView("\nota升级出错：" + message);
//                }
//
//                @Override
//                public void onProgress(int i) {
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            postView("\nota升级进度:"+i);
//                        }
//                    });
//
//                    Logger.show("OTA", "OTA升级" + i);
//
//                }
//
//                @Override
//                public void onComplete() {
//
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            postView("\nota升级结束");
//                        }
//                    });
//                    Logger.show("OTA", "nota升级结束");
//                    OtaApi.destoryOta(TestActivity2.this);
//                }
//
//                @Override
//                public void isLatestVersion() {
//                    postView("\n已是最新版本");
//                }
//            });
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

        }
        if(v.getId()==R.id.bt_file_list) {

            LmAPILite.GET_FILE_LIST(new IFileListListener() {
                @Override
                public void file(int fileCount, int fileIndex, int fileSize, String fileName, byte[] rawDataByte) {
                    postView("\nGET_FILE_LIST：" + "fileCount：" + fileCount + ",fileIndex：" + fileIndex + ",fileSize：" + fileSize + ",fileName：" + fileName);
                    //取其中一个测试，填入自己读取到的数据，EDB435685884_F53D0B68_8.txt只是个demo
                    if (fileName.equals("EDB435685884_F53D0B68_8.txt")) {
                        fileNameByte = rawDataByte;
                    }

                    // 去掉文件扩展名
                    String withoutExtension = fileName.substring(0, fileName.lastIndexOf(".txt"));

                    // 分割字符串
                    String[] parts = withoutExtension.split("_");

                    // 获取最后一个部分，即 "8"
                    String result = parts[parts.length - 1];
                }

                @Override
                public void fileContent(String content) {

                }

                @Override
                public void AudioFileContent(byte[] content) {

                }

                @Override
                public void getFileContentFinish() {

                }
            });
        }
        if(v.getId()==R.id.bt_file_content) {

            /**
             * 类型和文件名的最后一部分保持一致，EDB435685884_10FF0A68_8.txt，类型是8
             */
            LmAPILite.GET_FILE_CONTENT(8, fileNameByte, new IFileListListener() {
                @Override
                public void file(int fileCount, int fileIndex, int fileSize, String fileName, byte[] rawDataByte) {
                }

                @Override
                public void fileContent(String content) {
                    postView("\nGET_FILE_CONTENT：" + content);
                }

                @Override
                public void AudioFileContent(byte[] content) {

                }

                @Override
                public void getFileContentFinish() {

                }
            });
        }
        if(v.getId()==R.id.bt_test2){

            Intent intent = new Intent();
                intent.setClass(TestActivity2.this,TestActivity3.class);
                startActivity(intent);

        }

        if(v.getId()==R.id.bt_star_ppg){

            postView("\n开启实时ppg");
            //postView("\n开始读取未上传数据");
            final int[] numCount = {0};
            LmAPILite.START_REAL_TIME_PPG(40, 100, 20, 20, 20, 1, 1, new IRealTimePPGListener() {
                @Override
                public void time(long time, int zone) {
                    postView("\ntime:"+time+",zone:"+zone);
                }

                @Override
                public void waveformData(int seq, int number, List<String[]> waveData) {
                    numCount[0]=numCount[0]+waveData.size();
                    postView("\nwaveformData seq:"+seq+",number:"+number+",总条数:"+numCount[0]);

//                    for (String[] array : waveData) {
//                        postView("\nwaveData:"+Arrays.toString(array));
//                    }
                }

                @Override
                public void progress(int progress) {
                    postView("\nprogress :"+progress);
                }

                @Override
                public void RRIData(int number, byte[] rriData) {
                    postView("\nRRIData number:"+number+",rriData length:"+rriData.length);
                }

                @Override
                public void result(int result0, int heartRate, int bloodOxygen, int temperature) {
                    postView("\nresult result0:"+result0+",heartRate:"+heartRate+",bloodOxygen:"+bloodOxygen+",temperature:"+temperature);
                }
            });

        }

        if(v.getId()==R.id.bt_stop_ppg){

            postView("\n停止实时ppg");
            //postView("\n开始读取未上传数据");

            LmAPILite.STOP_REAL_TIME_PPG();

        }
        if(v.getId()==R.id.bt_testGomore){

            postView("\ngomore戒指授权");
            GoMoreUtils.goMoreAuthorizationKey(mac,"76d07e37bfe341b1a25c76c0e25f457a",new GoMoreUtils.IGomoreListener() {
                @Override
                public void authorization() {
                    postView("\nauthorization");

                }

                @Override
                public void unauthorization() {
                    postView("\nunauthorization");
                }

                @Override
                public void error(int code, String msg) {
                    postView("\nerror:"+msg);
                }


            });

        }

        if(v.getId()==R.id.btn_touch_test_open){

            LmAPILite.OPEN_TOUCH_TEST();

        }
        if(v.getId()==R.id.btn_touch_test_close){

            LmAPILite.CLOSE_TOUCH_TEST();

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
