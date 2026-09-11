package com.lomo.demo.application;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.util.Log;

import com.lm.sdk.BLEService;
import com.lm.sdk.BaseLmAPi;
import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.ICMDLogListener;
import com.lm.sdk.library.AppConfig;
import com.lm.sdk.mode.BleDeviceInfo;
import com.lm.sdk.utils.BLEUtils;
import com.lomo.demo.adapter.DeviceBean;

/**
 * @author Lizhao
 */
public class App extends Application {
    private static App app;
    private DeviceBean deviceBean;
    private BluetoothAdapter mBluetoothAdapter;
    public static boolean needAutoConnect=true;//是否需要自动重连，默认true，如果测试断连情况，可以不需要重连
    @Override
    public void onCreate() {
        super.onCreate();
        app = this;
        LmAPILite.init(this, new ICMDLogListener() {
            @Override
            public void log(String label, String type, String logs) {
                Log.d(label,type+" "+logs);
            }
        });
        LmAPILite.setDebug(true);
        // 设置发送指令回调（解耦蓝牙连接）
        BaseLmAPi.setSendCommandCallback(data -> {
            // 通过 BLEService 发送指令
            BLEService.sendCmd(data);
        });
    }


    public static App getInstance() {
        return app;
    }
    public void setDeviceBean(DeviceBean deviceBean) {
        this.deviceBean = deviceBean;

    }

    public DeviceBean getDeviceBean() {
        return deviceBean;
    }


    public BluetoothAdapter getBluetoothAdapter() {
        if (mBluetoothAdapter == null) {
            BluetoothManager bluetoothManager = (BluetoothManager) getInstance().getSystemService(Context.BLUETOOTH_SERVICE);
            mBluetoothAdapter = bluetoothManager.getAdapter();
        }
        return mBluetoothAdapter;
    }
}
