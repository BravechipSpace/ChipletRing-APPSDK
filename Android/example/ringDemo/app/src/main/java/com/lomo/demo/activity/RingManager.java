package com.lomo.demo.activity;

import android.content.Context;

import com.lm.sdk.LmAPI;
import com.lm.sdk.inter.IResponseListener;

public class RingManager {
    public void init(Context context, IResponseListener listener){
        LmAPI.addWLSCmdListener(context,listener);
    }
}
