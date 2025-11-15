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
import com.lm.sdk.inter.IHistoryListener;
import com.lm.sdk.library.utils.DateUtils;
import com.lm.sdk.library.utils.TimeUtils;
import com.lm.sdk.mode.GoMoreSleep;
import com.lm.sdk.mode.HistoryDataBean;
import com.lm.sdk.utils.DataCovertUtils;
import com.lm.sdk.utils.GsonUtils;
import com.lm.sdk.utils.Logger;
import com.lm.sdk.utils.StringUtils;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.bean.SleepChartBean;
import com.lomo.demo.views.EchartView;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class HistoryListTempActivity extends BaseActivity implements  View.OnClickListener {
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
        setContentView(R.layout.activity_history_list_temp);
        tv_result = findViewById(R.id.tv_result2);

        findViewById(R.id.bt_getHistoryTemp).setOnClickListener(this);
        findViewById(R.id.bt_goBack).setOnClickListener(this);


    }


    @Override
    public void onClick(View v) {
        if(v.getId()== R.id.bt_getHistoryTemp){
            postView("\n获取历史温度");

            LmAPI.READ_HISTORY((byte) 0x1, 0,new IHistoryListener() {
                @Override
                public void error(int code) {
                    postView("\n获取历史数据出错");

                }

                @Override
                public void success() {
                    postView("\n读取记录完成");

                }

                @Override
                public void progress(double progress, HistoryDataBean historyDataBean) {
                    if(historyDataBean!=null){
                        if(!StringUtils.isEmpty(historyDataBean.getTemperatureData())){
                            postView("\n时间:" + DateUtils.longToString(historyDataBean.getTime() * 1000, "yyyy-MM-dd HH:mm")+",温度:"+historyDataBean.getTemperatureData());
                        }

                    }

                }

                @Override
                public void noNewDataAvailable() {

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