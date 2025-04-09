package com.lm.sdk.activity;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toolbar;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.lm.library.utils.ImageSaverUtil;
import com.lm.sdk.LmAPI;
import com.lm.sdk.R;
import com.lm.sdk.inter.IECGListener;
import com.lm.sdk.inter.IResponseListener;
import com.lm.sdk.mode.SystemControlBean;
import com.lm.sdk.utils.DataCovertUtils;
import com.lxj.xpopup.XPopup;
import com.lxj.xpopup.interfaces.OnSelectListener;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Deque;

public class ElectrocardiogramActivity extends Activity {

    private WebView webView;
    private TextView tv_gain;
    private RelativeLayout rl_gain;
    private RelativeLayout rl_walking_speed;
    private TextView tv_walking_speed;
    private TextView tv_HR;
    private TextView tv_pr_interval;
    private TextView tv_atrial_rate;
    private TextView tv_qrs_time_limit;
    private TextView tv_rr_interval;
    private TextView tv_qt_time_limit;
    private Button btn_star;
    private Handler handler = new Handler();
    private Runnable runnable;
    private long interval = 40;//每4ms读一个数据，一次读80
    private float divisor = 60;//除数
    private boolean handlerStar = false;
    private boolean stopRunnable = true;
    private double scale = 1;
    private int dataListMaxLength = 450;
    private Deque<Integer> ecgDatasDeque = new ArrayDeque<>();//心电图数据队列
    private boolean isFirst=true;

    public Toolbar toolbar;

    public TextView txt_title;
    public ImageView img_back;
    public TextView iv_more;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_electrocardiogram);
        toolbar = findViewById(com.lm.library.R.id.toolbar);
        txt_title = findViewById(com.lm.library.R.id.txt_title);
        img_back = findViewById(com.lm.library.R.id.img_back);
        iv_more = findViewById(com.lm.library.R.id.iv_more);
        if (toolbar != null) {
            setActionBar(toolbar);
            txt_title.setText(getString(R.string.ECG_chart));
            img_back.setVisibility(View.GONE);
        }

        webView = findViewById(R.id.web);
        tv_gain = findViewById(R.id.tv_gain);
        tv_walking_speed = findViewById(R.id.tv_walking_speed);
        rl_gain = findViewById(R.id.rl_gain);
        rl_walking_speed = findViewById(R.id.rl_walking_speed);
        tv_HR = findViewById(R.id.tv_HR);
        tv_pr_interval = findViewById(R.id.tv_pr_interval);
        tv_atrial_rate = findViewById(R.id.tv_atrial_rate);
        tv_qrs_time_limit = findViewById(R.id.tv_qrs_time_limit);
        tv_rr_interval = findViewById(R.id.tv_rr_interval);
        tv_qt_time_limit = findViewById(R.id.tv_qt_time_limit);
        btn_star = findViewById(R.id.btn_star);

        tv_gain.setText("5mm/mV");
        tv_walking_speed.setText("25mm/s");

        DisplayMetrics dm = getResources().getDisplayMetrics();
        int widthPixels = dm.widthPixels;

        ViewGroup.LayoutParams params = webView.getLayoutParams();
        params.width = widthPixels;
        params.height = (int) (widthPixels * 0.67);
        webView.setLayoutParams(params);

        initWebView();
        webView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                switch (webView.getVisibility()) {
                    case View.VISIBLE:
                        if(isFirst){
                            new Handler().postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    webView.loadUrl("file:///android_asset/jsWeb/electrocardiogram.html");
                                }
                            }, 300);
                        }
                        isFirst=false;

                        break;
                    case View.GONE:

                        break;
                }

            }
        });


        ArrayList<Double> arrayList=new ArrayList<>();
        runnable = new Runnable() {

            @Override
            public void run() {
                if (stopRunnable) {
                    return;
                }
                for(int i=0;i<ecgDatasDeque.size();i++){
                    int firstData = ecgDatasDeque.removeFirst();//从头取出，然后删除掉
                    double a = firstData - 10000;
                    double b = a ;
                    double realData = b / divisor;
                    arrayList.add(realData);
                    if(arrayList.size()>dataListMaxLength){
                        break;
                    }
                }
                // 将数组转换为JSON字符串
                StringBuilder jsonArray = new StringBuilder("[");
                for (int i = 0; i < arrayList.size(); i++) {
                    jsonArray.append(arrayList.get(i));
                    if (i < arrayList.size() - 1) {
                        jsonArray.append(",");
                    }
                }
                jsonArray.append("]");

                webView.evaluateJavascript("javascript:updateDatas('" + jsonArray.toString() + "')",
                        new ValueCallback<String>() {
                            @Override
                            public void onReceiveValue(String value) {
                                if(arrayList.size()>dataListMaxLength){
                                    arrayList.clear();

                                }
                                interval = 100;
                            }
                        });

                handler.postDelayed(this, interval);

            }
        };

        /**
         * 5mm/mv  +-5mv  		  10000uv  100格 ，每格 100uv         value/100
         * 10mm/mv  +-2.5mv               5000uv  100格，每格50uv                value/50
         * 20mm/mv  +-1.25mv             2500uv 100格  每格25 			value/25
         */
        rl_gain.setOnClickListener(v -> {
            ImageSaverUtil.saveImageToInternalStorage(ElectrocardiogramActivity.this, "心电图增益", "LM", "buttonClick.txt", true);
            new XPopup.Builder(this)
                    .asBottomList("增益", new String[]{"1mm/mV", "2mm/mV", "5mm/mV", "10mm/mV"},
                            new OnSelectListener() {
                                @Override
                                public void onSelect(int position, String text) {
                                    tv_gain.setText(text);

                                    if (position == 0) {
                                        scale = 0.03;
                                        divisor = 300;
                                    }
                                    if (position == 1) {
                                        scale = 0.07;
                                        divisor = 150;
                                    }
                                    if (position == 2) {
                                        scale = 0.17;
                                        divisor = 60;
                                    }
                                    if (position == 3) {
                                        scale = 0.34;
                                        divisor = 30;
                                    }



                                    handler.removeCallbacks(runnable);//先暂停绘制
                                    stopRunnable = true;
                                    arrayList.clear();
                                    webView.evaluateJavascript("javascript:updateScale('" + scale + "')",
                                            new ValueCallback<String>() {
                                                @Override
                                                public void onReceiveValue(String value) {
                                                }
                                            });

                                    webView.evaluateJavascript("javascript:clearData()",
                                            new ValueCallback<String>() {
                                                @Override
                                                public void onReceiveValue(String value) {
                                                    //   starUpdateDatas();
                                                }
                                            });


                                }
                            })
                    .show();
        });

        rl_walking_speed.setOnClickListener(v -> {
            ImageSaverUtil.saveImageToInternalStorage(ElectrocardiogramActivity.this, "心电图走速", "LM", "buttonClick.txt", true);

            new XPopup.Builder(this)
                    .asBottomList("走速", new String[]{"12.5mm/s", "25mm/s", "50mm/s"},
                            new OnSelectListener() {
                                @Override
                                public void onSelect(int position, String text) {
                                    double speed = 1;
                                    if (position == 0) {
                                        // interval = 100;
                                        dataListMaxLength=900;
                                        speed = 2;
                                    }
                                    if (position == 1) {
                                        //  interval = 40;
                                        dataListMaxLength=450;
                                        speed = 1;
                                    }
                                    if (position == 2) {
                                        //  interval = 20;
                                        dataListMaxLength=225;
                                        speed = 0.5;
                                    }

                                    stopRunnable = true;
                                    handler.removeCallbacks(runnable);//先暂停
                                    arrayList.clear();

                                    webView.evaluateJavascript("javascript:updateSpeed('" + speed + "')",
                                            new ValueCallback<String>() {
                                                @Override
                                                public void onReceiveValue(String value) {
                                                }
                                            });

                                    webView.evaluateJavascript("javascript:clearData()",
                                            new ValueCallback<String>() {
                                                @Override
                                                public void onReceiveValue(String value) {
                                                    //     starUpdateDatas();
                                                }
                                            });

                                    tv_walking_speed.setText(text);
                                }
                            })
                    .show();
        });
        btn_star.setOnClickListener(v -> {
            ImageSaverUtil.saveImageToInternalStorage(ElectrocardiogramActivity.this, "心电图开始和结束", "LM", "buttonClick.txt", true);

            if(!handlerStar){

                btn_star.setText(getString(R.string.stop));
                handlerStar = true;
               // LmAPI.STAR_ELECTROCARDIOGRAM();
                LmAPI.STAR_ELEC(new IECGListener() {
                    @Override
                    public void resultData(byte[] bytes) {
                        if (!handlerStar) {
                            return;
                        }
                        int HRValue = (bytes[7] & 0xFF)*2;
                        tv_HR.setText(HRValue + "");
                        byte[] subArray = Arrays.copyOfRange(bytes, 17, bytes.length - 2);

                        int[] intArray = DataCovertUtils.convertByteArrayToUShortArray(subArray);
                        //   Logger.show(BLEService.TAG, "===intArray[]=== " + Arrays.toString(intArray));
                        for (int i = 0; i < 80; i++) {//只取前80位
                            if (i < intArray.length) {
                                ecgDatasDeque.addLast(intArray[i]);//从尾部插入
                            }

                        }
                        if (!ecgDatasDeque.isEmpty() && stopRunnable) {//数据不为空，并且没启动

                            starUpdateDatas();


                        }
                    }

                    @Override
                    public void error(int code) {

                    }
                });
            }else{
                btn_star.setText(getString(R.string.star));
                handlerStar = false;
                stopRunnable = true;
                LmAPI.STOP_ELECTROCARDIOGRAM();
                handler.removeCallbacks(runnable);
            }

        });


    }


    private void starUpdateDatas() {
        handler.removeCallbacks(runnable);
        stopRunnable = false;
        handler.postDelayed(runnable, interval); // 重新设置任务
    }


    private void initWebView() {
        WebSettings webSettings = webView.getSettings();

        webSettings.setJavaScriptEnabled(true);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setSupportZoom(true);
        webSettings.setDisplayZoomControls(true);
        webView.setWebContentsDebuggingEnabled(true);
        webView.setHorizontalScrollBarEnabled(false);//水平不显示
        webView.setVerticalScrollBarEnabled(false); //垂直不显示
        webView.setScrollBarStyle(View.SCROLLBARS_INSIDE_INSET);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView webView, String s) {
                super.onPageFinished(webView, s);

            }
        });
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onJsAlert(WebView webView, String s, String message, JsResult jsResult) {
                Log.e("wangguoyi", "onJsAlert:" + message);
                return super.onJsAlert(webView, s, message, jsResult);
            }
        });

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LmAPI.STOP_ELECTROCARDIOGRAM();
//停止
        handler.removeCallbacks(runnable);
        handler = null;
        ecgDatasDeque.clear();
        ecgDatasDeque = null;
    }


}