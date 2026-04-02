package com.lm.sdk;

import android.app.Activity;

import android.os.Handler;


import com.lm.sdk.inter.LmOtaProgressListener;
import com.lomo.demo.amota.AmotaUtils;


public class OtaApi {

    public static String fileName;
    private static Activity mActivity;
    private static LmOtaProgressListener lmOtaProgressListener;



    /**
     * 已经检查过当前版本号可以更新，根据当前版本号，进行ota升级
     *
     * @param mac 戒指mac地址
     * @param outputPath ota文件本地地址
     * @param mLmOtaProgressListener
     */
    public static void otaUpdate(String mac,String outputPath,  Activity mActivity,LmOtaProgressListener mLmOtaProgressListener) {
        lmOtaProgressListener = mLmOtaProgressListener;
        OtaApi.mActivity =mActivity;

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                AmotaUtils.init(outputPath,mac, OtaApi.mActivity);
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        AmotaUtils.startAmota(OtaApi.mActivity, lmOtaProgressListener);
                    }
                }, 3000);
            }
        },2000);

    }

    public static void destoryOta(Activity application) {
        AmotaUtils.destoryAmota(application);

    }




}

