package com.lomo.demo.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.TextView;
import android.widget.Toolbar;

import androidx.annotation.ColorInt;

import com.lomo.demo.R;


/**
 * 作者：王凯强 on 2017/1/06 11:07
 * <p>
 * 邮箱：317097478@qq.com
 */
public class MyToolbar extends Toolbar {
    TextView tv_title;

    public MyToolbar(Context context) {
        super(context);
    }

    public MyToolbar(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public MyToolbar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    @Override
    public void setTitle(CharSequence title) {
//
//        if (hasTitle()) {
//            tv_title.setText(title);
//        } else {
//            super.setTitle(title);
//        }
    }

    @Override
    public void setTitleTextColor(@ColorInt int color) {
        if (hasTitle()) {
            tv_title.setTextColor(color);
        } else {
            super.setTitleTextColor(color);
        }
    }

    private boolean hasTitle() {
        if (tv_title == null) {
            tv_title = (TextView) this.findViewById(R.id.txt_title);
            if (tv_title == null) {
                return false;
            }
        }
        return true;
    }
}