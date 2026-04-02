package com.lomo.demo.amota;

import static android.content.Context.BIND_AUTO_CREATE;

import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;


import com.lm.sdk.OtaApi;
import com.lm.sdk.inter.LmOtaProgressListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class AmotaUtils {

    private final static String TAG = AmotaUtils.class.getSimpleName();

    private static String mDeviceAddress;
    private static BluetoothLeService mBluetoothLeService;
    private static ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattCharacteristics =
            new ArrayList<ArrayList<BluetoothGattCharacteristic>>();
    private static BluetoothGattCharacteristic mAmotaTxChar;
    private static BluetoothGattCharacteristic mAmotaRxChar;

    private static final String LIST_NAME = "NAME";
    private static final String LIST_UUID = "UUID";

    private static String mSelectedFile;
    private static AmOtaService mAmOtaService = new AmOtaService();

//    private static AmOtaService.AmotaCallback otaCallback = new AmOtaService.AmotaCallback() {
//        @Override
//        public void progressUpdate(int progress) {
//            Log.i(TAG, "progress = " + progress);
//
//        }
//    };
    //private Handler mHandler = new Handler();
    private static final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize()) {
                Log.e(TAG, "Unable to initialize Bluetooth");
            }
            // Automatically connects to the device upon successful start-up initialization.
            mBluetoothLeService.connect(mDeviceAddress);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mBluetoothLeService = null;
        }
    };


    // Handles various events fired by the Service.
    // ACTION_GATT_CONNECTED: connected to a GATT server.
    // ACTION_GATT_DISCONNECTED: disconnected from a GATT server.
    // ACTION_GATT_SERVICES_DISCOVERED: discovered GATT services.
    // ACTION_DATA_AVAILABLE: received data from the device.  This can be a result of read
    //                        or notification operations.
    private static final BroadcastReceiver mGattUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if (BluetoothLeService.ACTION_GATT_CONNECTED.equals(action)) {
                Log.d(TAG, "mGattUpdateReceiver，ACTION_GATT_CONNECTED");
            } else if (BluetoothLeService.ACTION_GATT_DISCONNECTED.equals(action)) {
                mAmOtaService.amOtaStop();
                Log.d(TAG, "mGattUpdateReceiver，ACTION_GATT_DISCONNECTED");
            } else if (BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                // Show all the supported services and characteristics on the user interface.
                parseGattServices(mBluetoothLeService.getSupportedGattServices());
                Log.d(TAG, "mGattUpdateReceiver，ACTION_GATT_SERVICES_DISCOVERED");
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE.equals(action)) {
                byte[] data = intent.getByteArrayExtra(BluetoothLeService.EXTRA_DATA);
                Log.i(TAG, "ACTION_DATA_AVAILABLE = " + mAmOtaService.formatHex2String(data));
                 mAmOtaService.otaCmdResponse(data);
            } else if (BluetoothLeService.ACTION_GATT_WRITE_RESULT.equals(action)) {
                int result = intent.getIntExtra(action, -1);
                if (result == BluetoothGatt.GATT_SUCCESS) {
                    mAmOtaService.setGATTWriteComplete();
                    Log.i(TAG, "GATT write success");
                }
                else {
                    Log.e(TAG, "GATT write failed error = " + result);
                }
            }
        }
    };

    public static   void init(String selectedFile, String deviceAddress, Activity activity){
        mSelectedFile=selectedFile;
        mDeviceAddress = deviceAddress;
        Intent gattServiceIntent = new Intent(activity, BluetoothLeService.class);
        activity.bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Log.d(TAG, "注册mGattUpdateReceiver，RECEIVER_EXPORTED");
            activity.registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter(), Context.RECEIVER_EXPORTED);
        } else {
            Log.d(TAG, "注册mGattUpdateReceiver");
            activity.registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        }

        if (mBluetoothLeService != null) {
            final boolean result = mBluetoothLeService.connect(mDeviceAddress);
            Log.d(TAG, "Connect request result=" + result);
        }

    }

    public static void startAmota(Activity application, LmOtaProgressListener lmOtaProgressListener){
        final int[] updateProgress = {0};
        mAmOtaService.setiUpdateResult(new AmOtaService.IUpdateResult() {
            @Override
            public void errorResult(String result) {
                if( lmOtaProgressListener!=null){
                    if(updateProgress[0] <100){//升级完成以后，可能还会发送指令，错误忽略掉
                        lmOtaProgressListener.error("升级失败，请重试");
                    }


                }
            }
        });

        mAmOtaService.amOtaStart(mSelectedFile, mBluetoothLeService, mAmotaRxChar, new AmOtaService.AmotaCallback() {
            @Override
            public void progressUpdate(int progress) {
                updateProgress[0] =progress;
               if( lmOtaProgressListener!=null){
                   lmOtaProgressListener.onProgress(progress);
               }

            }

            @Override
            public void complete() {
                lmOtaProgressListener.onComplete();
                OtaApi.destoryOta(application);
            }
        });


    }


    public static void destoryAmota(Activity application){
        try{
            application.unregisterReceiver(mGattUpdateReceiver);
            application.unbindService(mServiceConnection);
        }catch (Exception e){
            e.printStackTrace();
        }

       // mBluetoothLeService = null;
    }

    private static void parseGattServices(List<BluetoothGattService> gattServices) {
        if (gattServices == null) return;
        String uuid = null;
        String unknownServiceString = "Unknown service";
        String unknownCharaString = "Unknown characteristic";
        ArrayList<HashMap<String, String>> gattServiceData = new ArrayList<HashMap<String, String>>();
        ArrayList<ArrayList<HashMap<String, String>>> gattCharacteristicData
                = new ArrayList<ArrayList<HashMap<String, String>>>();
        mGattCharacteristics = new ArrayList<ArrayList<BluetoothGattCharacteristic>>();

        // Loops through available GATT Services.
        for (BluetoothGattService gattService : gattServices) {
            HashMap<String, String> currentServiceData = new HashMap<String, String>();
            uuid = gattService.getUuid().toString();
            currentServiceData.put(
                    LIST_NAME, SampleGattAttributes.lookup(uuid, unknownServiceString));
            currentServiceData.put(LIST_UUID, uuid);
            gattServiceData.add(currentServiceData);

            Log.i(TAG, "currentServiceData = " + currentServiceData.toString());

            if (uuid.equals(SampleGattAttributes.ATT_UUID_AMOTA_SERVICE)) {
                Log.i(TAG, "Ambiq OTA Service found");

            }

            ArrayList<HashMap<String, String>> gattCharacteristicGroupData =
                    new ArrayList<HashMap<String, String>>();
            List<BluetoothGattCharacteristic> gattCharacteristics =
                    gattService.getCharacteristics();
            ArrayList<BluetoothGattCharacteristic> charas =
                    new ArrayList<BluetoothGattCharacteristic>();

            // Loops through available Characteristics.
            for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
                charas.add(gattCharacteristic);
                HashMap<String, String> currentCharaData = new HashMap<String, String>();
                uuid = gattCharacteristic.getUuid().toString();
                currentCharaData.put(
                        LIST_NAME, SampleGattAttributes.lookup(uuid, unknownCharaString));
                currentCharaData.put(LIST_UUID, uuid);
                gattCharacteristicGroupData.add(currentCharaData);

                Log.i(TAG, "currentCharaData = " + currentCharaData.toString());

                if (uuid.equals(SampleGattAttributes.ATT_UUID_AMOTA_RX)) {
                    Log.i(TAG, "Ambiq OTA RX Characteristic found");

                    mAmotaRxChar = gattCharacteristic;
                } else if (uuid.equals(SampleGattAttributes.ATT_UUID_AMOTA_TX)) {
                    Log.i(TAG, "Ambiq OTA TX Characteristic found");

                    mAmotaTxChar = gattCharacteristic;

                }
            }
            mGattCharacteristics.add(charas);
            gattCharacteristicData.add(gattCharacteristicGroupData);
        }

        // enable Ambiq OTA notification (AMOTA TX)
        if (mAmotaTxChar != null) {
            mBluetoothLeService.setCharacteristicNotification(
                    mAmotaTxChar, true);
        }
    }

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_WRITE_RESULT);
        return intentFilter;
    }
}
