package com.lomo.demo.views;



import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.lomo.demo.GsonUtils;
import com.lomo.demo.R;
import com.lomo.demo.bean.SleepChartBean;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EchartView extends WebView {
    private static final String TAG = EchartView.class.getSimpleName();

    public EchartView(Context context) {
        this(context, null);
    }

    public EchartView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EchartView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.Chart_type);
        int type = a.getInt(R.styleable.Chart_type_chartType, 0);
        init(type);


    }

    //    <!-- 0.心率  1.心率 日  2.心率 周  3.心率 月  4.主页 压力  5.主页步数   6.血氧日
    //    7. 血氧周 8.血氧 月 9.日 睡眠  10.睡眠周  11.睡眠月 12.温度日 13.温度周 14.温度月
    //    15.压力日 16.压力周 17.压力月  18.主页睡眠  19.运动日 20.运动周 21.运动月 -->
    public void setViewType(int type) {
        switch (type) {
            case 0://主页心率
                loadUrl("file:///android_asset/jsWeb/main_heart.html");
                break;
            case 1://心率 日
                loadUrl("file:///android_asset/jsWeb/heart_day.html");
                break;
            case 2://心率 周
                loadUrl("file:///android_asset/jsWeb/heart_week.html");
                break;
            case 3://心率 月
                loadUrl("file:///android_asset/jsWeb/heart_month.html");
                break;
            case 4://主页 压力
                loadUrl("file:///android_asset/jsWeb/main_stress.html");
                break;
            case 5://主页步数
                loadUrl("file:///android_asset/jsWeb/main_step.html");
                break;
            case 6://血氧 日
                loadUrl("file:///android_asset/jsWeb/blood_day.html");
                break;
            case 7://血氧 周
                loadUrl("file:///android_asset/jsWeb/blood_week.html");
                break;
            case 8://血氧 月
                loadUrl("file:///android_asset/jsWeb/blood_month.html");
                break;
            case 9://日 睡眠
                loadUrl("file:///android_asset/jsWeb/sleep_day.html");
                setOnTouchListener(new OnTouchListener() {
                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        if (event.getAction() == MotionEvent.ACTION_UP) {
                            requestDisallowInterceptTouchEvent(false);
                        } else {
                            requestDisallowInterceptTouchEvent(true);
                        }
                        return false;
                    }
                });
                break;
            case 10://睡眠周
                loadUrl("file:///android_asset/jsWeb/sleep_week.html");
                break;
            case 11:// 睡眠月
                loadUrl("file:///android_asset/jsWeb/sleep_month.html");
                break;
            case 12:// 温度日
                loadUrl("file:///android_asset/jsWeb/temp_day.html");
                break;
            case 13:// 温度周
                loadUrl("file:///android_asset/jsWeb/temp_week.html");
                break;
            case 14:// 温度月
                loadUrl("file:///android_asset/jsWeb/temp_month.html");
                break;
            case 15:// 压力日
                loadUrl("file:///android_asset/jsWeb/stress_day.html");
                break;
            case 16:// 压力周
                loadUrl("file:///android_asset/jsWeb/stress_week.html");
                break;
            case 17:// 压力月
                loadUrl("file:///android_asset/jsWeb/stress_month.html");
                break;
            case 18://主页睡眠
                loadUrl("file:///android_asset/jsWeb/main_sleep.html");
                break;
            case 19://运动日
                loadUrl("file:///android_asset/jsWeb/sport_day.html");
                break;
            case 20://运动周
                loadUrl("file:///android_asset/jsWeb/sport_week.html");
                break;
            case 21://运动月
                loadUrl("file:///android_asset/jsWeb/sport_month.html");
                break;
            case 22://饼图
                loadUrl("file:///android_asset/jsWeb/pie.html");
                break;
            case 23://运动记录
                loadUrl("file:///android_asset/jsWeb/sport_his_info.html");
                break;

            case 24://心率变异性
                loadUrl("file:///android_asset/jsWeb/main_heart_altered.html");
                break;
            case 25://心率变异性
                loadUrl("file:///android_asset/jsWeb/heart_altered_day.html");
                break;
            case 26://心率变异性
                loadUrl("file:///android_asset/jsWeb/heart_altered_week.html");
                break;
            case 27://心率变异性
                loadUrl("file:///android_asset/jsWeb/heart_altered_month.html");
                break;
            case 28://生理周期
                loadUrl("file:///android_asset/jsWeb/menses.html");
                break;
            case 29://生理周期详情
                loadUrl("file:///android_asset/jsWeb/menstrual_cycle.html");
                break;
            default:
                loadUrl("file:///android_asset/jsWeb/line.html");
                break;
        }
    }


    private void init(int type) {

        WebSettings webSettings = getSettings();

        webSettings.setJavaScriptEnabled(true);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setSupportZoom(false); // 禁用缩放
        webSettings.setBuiltInZoomControls(false); // 禁用缩放控件
        webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);// 禁用缓存
        CookieManager.getInstance().setAcceptCookie(false); // 禁用Cookie
        setWebContentsDebuggingEnabled(true);
        setHorizontalScrollBarEnabled(false);//水平不显示
        setVerticalScrollBarEnabled(false); //垂直不显示
        setScrollBarStyle(View.SCROLLBARS_INSIDE_INSET);

        addJavascriptInterface(new WepAppInterface(getContext()) {
        }, "Android");
// <enum name="sleep" value="1"/>
//            <enum name="line" value="2"/>
//            <enum name="bar" value="3"/>
        setViewType(type);
//        loadUrl("file:///android_asset/jsWeb/echarts.html");
//
//        loadUrl("file:///android_asset/jsWeb/temp.html");

//        setBackgroundColor(R.color.color_blue); // 设置背景色
//        setBackgroundResource(R.drawable.box_white_bg_radius); // 设置背景色
//        Drawable background = getBackground();//获取背景图
//        if (background != null) {
//            background.setAlpha(0);
//        }
        setBackgroundColor(Color.parseColor("#00000000")); // 设置背景色
        Drawable background = getBackground();//获取背景图
        if (background != null) {
            background.setAlpha(0);
        }

        setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView webView, String s) {
                super.onPageFinished(webView, s);
//                refreshEchart();
            }
        });
        setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onJsAlert(WebView webView, String s, String message, JsResult jsResult) {
                Log.e("wangguoyi", "onJsAlert:" + message);
                return super.onJsAlert(webView, s, message, jsResult);
            }
        });

        // 捕获 JavaScript 控制台日志信息
        setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                // 监听 JavaScript 错误信息
                if (consoleMessage.message().contains("ReferenceError")) {

                }
                return super.onConsoleMessage(consoleMessage);
            }
        });
    }


    class WepAppInterface {

        private Context mContext;

        public WepAppInterface(Context context) {
            this.mContext = context;
        }

        /**
         * Show a toast from the web page
         */
        @JavascriptInterface
        public void toolTips(int index ,String time, String data) {
            if (touchDataListener != null) {
                if("undefined".equals(data)){
                    touchDataListener.onTouchData(index,time, "--");
                }else{
                    touchDataListener.onTouchData(index,time, data);
                }

            }
        }
        @JavascriptInterface
        public void toolTips(int dataIndex,String data, String data2, String data3, String data4) {
            if (touchDataListener != null) {
                int  allTime=0;
//                double value2=0;
//                double value3=0;
//                double value4=0;
//                if(!"undefined".equals(data)){
//                    String[] times = data.split("\\.");
//                    allTime=Integer.parseInt(times[0])*60+Integer.parseInt(times[1]);
//                }
//                if(!"undefined".equals(data2)){
//                    String[] times = data2.split("\\.");
//                    allTime+=Integer.parseInt(times[0])*60+Integer.parseInt(times[1]);
//                }
//                if(!"undefined".equals(data3)){
//                    String[] times = data3.split("\\.");
//                    allTime+=Integer.parseInt(times[0])*60+Integer.parseInt(times[1]);
//                }
//                if(!"undefined".equals(data4)){//不计算清醒时间
////                    value4=Double.valueOf(data4);
//                }
                if(!"undefined".equals(data)){
//                    String[] times = data.split("\\.");
                    allTime=Integer.parseInt(data);
                }
                if(!"undefined".equals(data2)){
//                    String[] times = data2.split("\\.");
                    allTime+=Integer.parseInt(data2);
                }
                if(!"undefined".equals(data3)){
//                    String[] times = data3.split("\\.");
                    allTime+=Integer.parseInt(data3);
                }
                if(!"undefined".equals(data4)){//不计算清醒时间
//                    value4=Double.valueOf(data4);
//                    allTime+=Integer.parseInt(data4);//这句话确定是否增加清醒时间
                }
                int hours = (int) (allTime / 60);
                int minutes = (int) (allTime % 60);
                if(hours==0&&minutes==0){
                    touchDataListener.onTouchData(dataIndex,"--","--");
                }else{
                    touchDataListener.onTouchData(dataIndex,String.valueOf(hours),String.valueOf(minutes));
                }

            }
        }
    }

    TouchDataListener touchDataListener;

    public void setTouchDataListener(TouchDataListener touchDataListener) {
        this.touchDataListener = touchDataListener;
    }

    public interface TouchDataListener {
        void onTouchData(int index,String time, String data);
    }

    public void refreshPie(List<Long> pieEntryList) {
        this.post(new Runnable() {
            @Override
            public void run() {
               String call = "javascript:refreshData('"+  GsonUtils.beanToJson(pieEntryList)+ "')";
               loadUrlDelay(call);
            }
        });
    }

    /**
     * 日睡眠刷新
     */
    @SuppressLint("SetJavaScriptEnabled")
    public void refreshSleepDayEcharts(List<SleepChartBean> data) {

        this.post(new Runnable() {
            @Override
            public void run() {
                String [] tips={getResources().getString(R.string.sleep_type1), getResources().getString(R.string.sleep_type2),getResources().getString(R.string.sleep_type3), getResources().getString(R.string.sleep_type4)};
                String call ;
                if (data == null || data.size() == 0) {
                    call = "javascript:refreshData('" + 0 + "','"+  GsonUtils.beanToJson(tips)+ "','" + GsonUtils.beanToJson(new ArrayList<>()) + "')";
                }else{
                    call = "javascript:refreshData('" + data.get(0).getStartTime() + "','"+  GsonUtils.beanToJson(tips)+ "','" + GsonUtils.beanToJson(data) + "')";
                }
               loadUrlDelay(call);
            }
        });

    }

    private void loadUrlDelay(String url){
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                loadUrl(url);
            }
        },100);
    }

    public static List<Long> calculateFullHoursTimestamps(long startTimestamp, long endTimestamp) {
        // 将开始时间戳向下取整到整点
        long adjustedStartTimestamp = startTimestamp - (startTimestamp % ( 60 * 60));

        // 将结束时间戳向上取整到整点
        long adjustedEndTimestamp = endTimestamp + ( 60 * 60) - (endTimestamp % ( 60 * 60));

        // 创建一个列表来存储整点毫秒时间戳
        List<Long> timestamps = new ArrayList<>();

        // 从调整后的开始时间戳开始，到调整后的结束时间戳结束，按整点添加时间戳
        for (long currentTimestamp = adjustedStartTimestamp; currentTimestamp <= adjustedEndTimestamp; currentTimestamp += ( 60 * 60)) {
            timestamps.add(currentTimestamp);
        }

        return timestamps;
    }



    public void setValueSpan(int valueSpan) {
        String call = "javascript:setValueSpan(" + valueSpan + ")";
       loadUrlDelay(call);
    }

}
