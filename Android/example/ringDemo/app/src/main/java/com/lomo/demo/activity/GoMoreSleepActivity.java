package com.lomo.demo.activity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.lm.sdk.LmAPI;
import com.lm.sdk.inter.IGoMoreListener;
import com.lm.sdk.library.utils.DateUtils;
import com.lm.sdk.library.utils.TimeUtils;
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.utils.GsonUtils;
import com.lm.sdk.utils.Logger;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.bean.SleepChartBean;
import com.lomo.demo.views.EchartView;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class GoMoreSleepActivity extends BaseActivity implements  View.OnClickListener {
    TextView tv_result;
    TextView tv_sleep_hour;
    TextView tv_sleep_min;

    TextView start_sleep_time;

    TextView end_sleep_time;

    TextView tv_day_time;

    EchartView sleepChatView;
    View main_scale;
    TextView tv_sleep_not;
    View in_sleep_layout;
    GoMoreSleep overviewSleep = new GoMoreSleep();
    public String TAG = getClass().getSimpleName();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_go_more_sleep);
        tv_result = findViewById(R.id.tv_result2);

        findViewById(R.id.bt_goMoreSleep).setOnClickListener(this);
        findViewById(R.id.bt_goBack).setOnClickListener(this);

        tv_sleep_hour=findViewById(R.id.tv_sleep_hour);
        tv_sleep_min=findViewById(R.id.tv_sleep_min);
        start_sleep_time=findViewById(R.id.start_sleep_time);
        end_sleep_time=findViewById(R.id.end_sleep_time);
        tv_day_time=findViewById(R.id.tv_day_time);
        sleepChatView=findViewById(R.id.echarts_view);
        main_scale=findViewById(R.id.main_scale);
        tv_sleep_not=findViewById(R.id.tv_sleep_not);
        in_sleep_layout=findViewById(R.id.in_sleep_layout);

        tv_day_time.setText(getCurrentDate());
        sleepChatView.setTouchDataListener(new EchartView.TouchDataListener() {
            @Override
            public void onTouchData(int index, String startTime, String endTime) {
                tv_sleep_hour.post(new Runnable() {
                    @Override
                    public void run() {
                        tv_day_time.setText(startTime.substring(0, 11));
                        tv_sleep_hour.setText(startTime.substring(11, 16));
                        tv_sleep_min.setText(endTime.substring(11, 16));
                    }
                });

            }
        });

    }

    public String getCurrentDate() {
        // 获取当天的日期
        LocalDate today = LocalDate.now();

        // 创建一个DateTimeFormatter对象，指定所需的日期格式
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 将当天日期格式化为指定格式
        String formattedDate = today.format(formatter);

        return formattedDate;
    }

    /**
     * 初始化睡眠图
     *
     * @param historyDataBeanList
     */
    public void initSleepChat(long showStartTime, long endTimeData, List<HistoryDataBean> historyDataBeanList) {
        List<SleepChartBean> list = new ArrayList<>();
        int totalCount = 0;//记录条数
        int lastType = 0;
        int currentCount = 0;


        SleepChartBean lastData = null;

        long startTime = 0;
        long endTime = 0;

        int stepCount = 0;
        boolean wakeUp = false;
        for (int i = 0; i < historyDataBeanList.size(); i++) {
            HistoryDataBean dataBean = historyDataBeanList.get(i);
            String time = DateUtils.longToString(dataBean.getTime() * 1000, "yyyy-MM-dd HH:mm");

            totalCount++;
            if (lastType == 0) {
                if(dataBean.getSleepType()>1){
                    startTime = dataBean.getTime() * 1000;
                    lastType = dataBean.getSleepType();
                    list.add(new SleepChartBean(lastType, time, time));

                }

            } else if (lastType != dataBean.getSleepType()) {
                long changeTime = historyDataBeanList.get(i -1).getTime();
                time = DateUtils.longToString(changeTime * 1000, "yyyy-MM-dd HH:mm");
                list.get(list.size() - 1).setEndTime(time);
                long longtime = dataBean.getTime()-historyDataBeanList.get(i-1).getTime();
                lastType = dataBean.getSleepType();
                if(longtime < 90 * 60) {//两条数据相差不超过90分钟
                    list.add(new SleepChartBean(lastType, time, time));
                }
                //重置睡眠类型,重新记录

                currentCount = 0;
                currentCount++;
                stepCount = 0;
            } else {
                currentCount++;
//                if (dataBean.getSleepType() == 1) {//清醒状态。记录步数 》300直接清醒
//                    stepCount=dataBean.getStepCount();
//                    if (stepCount >= 300) {
//                        wakeUp = true;
//                    }
//                }
            }

            if(i >0 ){//识别间隔时间
                long longtime = dataBean.getTime()-historyDataBeanList.get(i-1).getTime();

                if(longtime>90*60){//超出一个小时
                    long  setEnd=DateUtils.stringToLong(list.get(list.size() - 1).getEndTime(), "yyyy-MM-dd HH:mm");
                    //long end =setEnd + 15 * 60*1000;
                    String endTime1 = DateUtils.longToString(setEnd, "yyyy-MM-dd HH:mm");
                    list.get(list.size() - 1).setEndTime(endTime1);
                    list.get(list.size() - 1).setSleepType(historyDataBeanList.get(i-1).getSleepType());

//
//                    list.add(new SleepChartBean(lastType, time, endTime1));
//                    list.get(list.size() - 1).setEndTime(endTime1);
//                    list.get(list.size() - 1).setSleepType(dataBean.getSleepType());
                    endTime = DateUtils.stringToLong(list.get(list.size() - 1).getEndTime(), "yyyy-MM-dd HH:mm");

                    break;//终止循环
                }
//           Log.e("wangguoyi","longtime :"+longtime);
            }
            if (list.size() > 0 && (totalCount == historyDataBeanList.size() || wakeUp)) { //最后一条数据
                list.get(list.size() - 1).setEndTime(time);
                list.get(list.size() - 1).setSleepType(dataBean.getSleepType());
                endTime = DateUtils.stringToLong(list.get(list.size() - 1).getEndTime(), "yyyy-MM-dd HH:mm");
                long endTrueTime = dataBean.getTime();

                break;//终止循环
            }
        }
        if(!list.isEmpty()){
            list.get(list.size()-1).setEndTime( DateUtils.longToString(endTimeData* 1000,  "yyyy-MM-dd HH:mm"));
        }

        //这里是睡眠开始的时间，显示在左下角
        setSleepTime(showStartTime, endTime);
        if (list.size() > 0) {
            sleepChatView.setVisibility(View.VISIBLE);
            in_sleep_layout.setVisibility(View.VISIBLE);
            tv_sleep_not.setVisibility(View.GONE);
            main_scale.setVisibility(View.VISIBLE);
        } else {
            sleepChatView.setVisibility(View.INVISIBLE);
            in_sleep_layout.setVisibility(View.GONE);
            main_scale.setVisibility(View.INVISIBLE);
            tv_sleep_not.setText("暂无睡眠");

            tv_sleep_not.setVisibility(View.VISIBLE);
        }

        sleepChatView.refreshSleepDayEcharts(list);
    }

    public void initSleepChatGomore(long showStartTime, long endTimeData, List<HistoryDataBean> historyDataBeanList) {
        List<SleepChartBean> list = new ArrayList<>();
        for (int i = 0; i < historyDataBeanList.size(); i++) {
            HistoryDataBean dataBean = historyDataBeanList.get(i);
            String time = DateUtils.longToString(dataBean.getTime() * 1000, "yyyy-MM-dd HH:mm:ss");
            String endtime = DateUtils.longToString((dataBean.getTime() +60)* 1000, "yyyy-MM-dd HH:mm:ss");

            list.add(new SleepChartBean(dataBean.getSleepType(), time, endtime));


                Logger.show("starttime",time);
            Logger.show("sleepType",dataBean.getSleepType()+"");
            Logger.show("endtime",endtime);
        }


        //这里是睡眠开始的时间，显示在左下角
        setSleepTime(showStartTime, endTimeData);
        if (list.size() > 0) {
            sleepChatView.setVisibility(View.VISIBLE);
            in_sleep_layout.setVisibility(View.VISIBLE);
            tv_sleep_not.setVisibility(View.GONE);
            main_scale.setVisibility(View.VISIBLE);
        } else {
            sleepChatView.setVisibility(View.INVISIBLE);
            in_sleep_layout.setVisibility(View.GONE);
            main_scale.setVisibility(View.INVISIBLE);
            tv_sleep_not.setText("暂无睡眠");

            tv_sleep_not.setVisibility(View.VISIBLE);
        }

        sleepChatView.refreshSleepDayEcharts(list);
    }

    public void setSleepTime(long startTime, long endTime) {
        if (startTime == 0 || endTime == 0) {
            start_sleep_time.setText("--");
            end_sleep_time.setText("--");
            tv_sleep_hour.setText("--");
            tv_sleep_min.setText("--");


            return;
        }
        String startTimeString = TimeUtils.date2String(new Date(startTime * 1000), TimeUtils.HH_MM);
        start_sleep_time.setText(startTimeString);
        String endTimeString = TimeUtils.date2String(new Date(endTime * 1000), TimeUtils.HH_MM);
        end_sleep_time.setText(endTimeString);


    }


    @Override
    public void onClick(View v) {
        if(v.getId()== R.id.bt_goMoreSleep){
            postView("\ngomore睡眠");
            List<GoMoreSleep> sleepStaging=new ArrayList<>();

            LmAPI.GET_GOMORE_SLEEP(new IGoMoreListener() {
                @Override
                public void overviewOfSleep(GoMoreSleep goMoreSleep) {
                    StringBuilder stringBuilder=new StringBuilder();
                    stringBuilder.append("开始时间：")
                            .append( DateUtils.longToString(goMoreSleep.getStartTS()*1000,"yyyy-MM-dd HH:mm:ss"))
                                    .append(",结束时间:")
                                            .append( DateUtils.longToString(goMoreSleep.getEndTS()*1000,"yyyy-MM-dd HH:mm:ss"))
                                                    .append(",睡眠潜伏期:").append(goMoreSleep.getLatency()).append("分钟")
                                    .append(",清醒时间:").append(goMoreSleep.getWakeTimes()).append("分钟")
                                    .append(",不包含清醒时间的总睡眠时间:").append(goMoreSleep.getTotalSleepTime()).append("分钟")
                                    .append(",入睡后的总清醒时间:").append(goMoreSleep.getWaso()).append("分钟")
                                    .append(",睡眠时间:").append(goMoreSleep.getSleepPeriod()).append("分钟")
                                    .append(",睡眠效率:").append(goMoreSleep.getEfficiency()/100).append("%")
                                    .append(",清醒与睡眠比例:").append(goMoreSleep.getWakeRatio()/100).append("%")
                                    .append(",眼动与睡眠比例:").append(goMoreSleep.getRemRatio()/100).append("%")
                                    .append(",浅睡与睡眠比例:").append(goMoreSleep.getLightRatio()/100).append("%")
                                    .append(",深睡与睡眠比例:").append(goMoreSleep.getDeepRatio()/100).append("%")
                                    .append(",清醒时间:").append(goMoreSleep.getWakeNumMinutes()).append("分钟")
                                    .append(",眼动时间:").append(goMoreSleep.getRemNumMinutes()).append("分钟")
                                    .append(",浅睡时间:").append(goMoreSleep.getLightNumMinutes()).append("分钟")
                                    .append(",深睡时间:").append(goMoreSleep.getDeepNumMinutes()).append("分钟")
                                    .append(",睡眠评分").append(goMoreSleep.getScore())
                                    .append(",睡眠类型:").append(goMoreSleep.getType()==1?"长睡":"短睡");
                    postView("\ngomore睡眠睡眠总览:"+ stringBuilder);
                    overviewSleep =goMoreSleep;
                 //   postView("\ngomore睡眠睡眠总览原始数据:"+ GsonUtils.beanToJson(goMoreSleep));

                    Log.e(TAG, "overviewOfSleep: "+ GsonUtils.beanToJson(goMoreSleep));
                }

                @Override
                public void sleepStaging(GoMoreSleep goMoreSleep) {
                    sleepStaging.add(goMoreSleep);
                    postView("\ngomore睡眠睡眠分期原始数据:"+ GsonUtils.beanToJson(goMoreSleep));
                    Log.e(TAG, "sleepStaging: "+ GsonUtils.beanToJson(goMoreSleep));
                }

                @Override
                public void dataUploadFinish() {
                    //睡眠分期是开始时间，每30s增加一个，和Sleep2thBean的List<HistoryBean> historyBeanList里的sleepType含义一致
                    long stageTimeBase= overviewSleep.getStartTS();
                    List<HistoryDataBean> historyBeanList=new ArrayList<>();
                    for (GoMoreSleep sleep : sleepStaging) {
                        for (short stage : sleep.getStages()) {

                            HistoryDataBean historyBean=new HistoryDataBean();
                            historyBean.setTime(stageTimeBase);
                            //gomore分期与原有睡眠分期标志位不同，原有的是
                            // 0：无效
                            //1：清醒
                            //2：浅睡
                            //3：深睡
                            //4：眼动期
                            //gomore分期是0：唤醒，1：眼动，2：浅睡，3：深睡
                            //适配老代码，修改为一致
                            if(stage==0){
                                stage=1;
                            }else if(stage==1){
                                stage=4;
                            }

                            historyBean.setSleepType(stage);
                            historyBeanList.add(historyBean);
                            stageTimeBase=stageTimeBase+60;
                        }
                    }


                    initSleepChatGomore(overviewSleep.getStartTS(),overviewSleep.getEndTS(),historyBeanList);
                }

                @Override
                public void noSleepData() {
                    postView("\ngomore睡眠 noSleepData");
                }
            });
        }
        if(v.getId()== R.id.bt_goBack){
            finish();
        }
    }

    public void postView(String value) {
        tv_result.setMovementMethod(ScrollingMovementMethod.getInstance());
        tv_result.setScrollbarFadingEnabled(false);//滚动条一直显示
        tv_result.append(value);
        int scrollAmount = tv_result.getLayout().getLineTop(tv_result.getLineCount()) - tv_result.getHeight();
        if (scrollAmount > 0)
            tv_result.scrollTo(0, scrollAmount);
        else
            tv_result.scrollTo(0, 0);

    }
}