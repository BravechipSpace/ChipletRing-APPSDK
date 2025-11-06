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
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.utils.GsonUtils;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;

public class GoMoreSleepActivity extends BaseActivity implements  View.OnClickListener {
    TextView tv_result;
    public String TAG = getClass().getSimpleName();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_go_more_sleep);
        tv_result = findViewById(R.id.tv_result2);
        findViewById(R.id.bt_goMoreSleep).setOnClickListener(this);
        findViewById(R.id.bt_goBack).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if(v.getId()== R.id.bt_goMoreSleep){
            postView("\ngomore睡眠");
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
                 //   postView("\ngomore睡眠睡眠总览原始数据:"+ GsonUtils.beanToJson(goMoreSleep));

                    Log.e(TAG, "overviewOfSleep: "+ GsonUtils.beanToJson(goMoreSleep));
                }

                @Override
                public void sleepStaging(GoMoreSleep goMoreSleep) {
                    postView("\ngomore睡眠睡眠分期原始数据:"+ GsonUtils.beanToJson(goMoreSleep));
                    Log.e(TAG, "sleepStaging: "+ GsonUtils.beanToJson(goMoreSleep));
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