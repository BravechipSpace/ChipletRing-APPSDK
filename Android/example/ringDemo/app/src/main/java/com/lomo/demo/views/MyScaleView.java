package com.lomo.demo.views;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

public class MyScaleView extends View {

    private Paint mPaint;
    private int mWidth;
    private int mHeight;

    // 刻度相关
    private int mMinValue;
    private int mMaxValue;
    private int mScaleGap;
    private int mScaleHeight;


    public MyScaleView(Context context) {
        this(context, null);
    }

    public MyScaleView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MyScaleView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(Color.parseColor("#9BABFF"));
        mPaint.setStrokeWidth(2);
        mPaint.setTextSize(30);

        // 初始化刻度相关参数
        mMinValue = 0;
        mMaxValue = 100;
        mScaleGap = 10;
        mScaleHeight = 8;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mWidth = w;
        mHeight = h;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        // 绘制刻度线
        drawScale(canvas);
    }

    private void drawScale(Canvas canvas) {
        int totalGap = mMaxValue - mMinValue;
        int scaleCount = 100;

        for (int i = 0; i < scaleCount; i++) {
            int x = (int) (mWidth * 2.0f / totalGap * i);
            int y = mHeight - mScaleHeight-20;
            if (i % 5 == 0) {
                // 绘制长刻度线
                mPaint.setStrokeWidth(8);
                canvas.drawLine(x, y-10, x, mHeight, mPaint);
//                // 绘制刻度值
            } else {
                // 绘制短刻度线
                mPaint.setStrokeWidth(2);
                canvas.drawLine(x, y, x, mHeight - mScaleHeight / 2, mPaint);
            }
        }
    }

}