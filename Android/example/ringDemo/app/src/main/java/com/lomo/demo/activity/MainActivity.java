package com.lomo.demo.activity;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.widget.Toast;

import com.hjq.permissions.OnPermissionCallback;

import com.hjq.permissions.XXPermissions;
import com.hjq.permissions.permission.PermissionLists;
import com.hjq.permissions.permission.base.IPermission;
import com.lm.sdk.BLEService;
import com.lm.sdk.LmAPI;
import com.lm.sdk.LogicalApi;
import com.lm.sdk.mode.BleDeviceInfo;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.Logger;
import com.lm.sdk.utils.StringUtils;
import com.lm.sdk.utils.UtilSharedPreference;
import com.lomo.demo.R;
import com.lomo.demo.adapter.DeviceAdapter;
import com.lomo.demo.adapter.DeviceBean;
import com.lomo.demo.adapter.OnItemClickListener;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.nfc.NfcActivity;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public class MainActivity extends Activity {

    RecyclerView recyclerView;
    SwipeRefreshLayout swipeRefreshLayout;
    private DeviceAdapter adapter;

    Set<String> macList = new HashSet<>();

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initView();
        //初始化权限
        initPermissions();
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            // 如果没有权限，向用户申请
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.POST_NOTIFICATIONS}, 1);
        }
    }

    private void initPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S){
            XXPermissions.with(this)
                    .permission(PermissionLists.getAccessCoarseLocationPermission())
                    .permission(PermissionLists.getAccessFineLocationPermission())
                    .permission(
                            PermissionLists.getBluetoothScanPermission())
                    .permission(PermissionLists.getBluetoothConnectPermission())
                    .permission(
                            PermissionLists.getBluetoothAdvertisePermission())
                    .permission(
                            PermissionLists.getManageExternalStoragePermission())

                    // 设置权限请求拦截器（局部设置）
                    //.interceptor(new PermissionInterceptor())
                    // 设置不触发错误检测机制（局部设置）
                    //.unchecked()
                    .request(new OnPermissionCallback() {

                        @Override
                        public void onResult(@NonNull List<IPermission> grantedList, @NonNull List<IPermission> deniedList) {
                            boolean allGranted = deniedList.isEmpty();
                            if (!allGranted) {
                                Toast.makeText(getApplicationContext(),"获取部分权限成功，但部分权限未正常授予",Toast.LENGTH_SHORT).show();
                                return;
                            }
                            searchDevice();
                        }

                    });

        }else {
            XXPermissions.with(MainActivity.this)
                    .permission(PermissionLists.getAccessCoarseLocationPermission())
                    .permission(PermissionLists.getAccessFineLocationPermission())

                     .request(new OnPermissionCallback() {
                        @Override
                        public void onResult(@NonNull List<IPermission> grantedList, @NonNull List<IPermission> deniedList) {
                            boolean allGranted = deniedList.isEmpty();
                            if (!allGranted) {
                                Toast.makeText(getApplicationContext(),"获取部分权限成功，但部分权限未正常授予",Toast.LENGTH_SHORT).show();
                                return;
                            }
                            searchDevice();
                        }

                    });
        }
    }

    /**
     * 初始化UI
     */
    private void initView() {
        recyclerView = findViewById(R.id.recyclerView);
        swipeRefreshLayout = findViewById(R.id.swipeRefreshLayout);
        findViewById(R.id.tv_nfc).setOnClickListener(v->{
            Intent intent=new Intent(MainActivity.this, NfcActivity.class);
            startActivity(intent);
        });
        // data是你的数据集合
        adapter = new DeviceAdapter();
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        //设置分割线
        recyclerView.addItemDecoration(new DividerItemDecoration(this, LinearLayoutManager.VERTICAL));

        //设置下拉刷新
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                searchDevice();
            }
        });
        adapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(Object o, int position) {
                BleDeviceInfo  deviceBean = (BleDeviceInfo) o;
              //  BLEUtils.isHIDDevice=deviceBean.getBindingIndicatorBit()==1;
                BLEUtils.isHIDDevice=false;
                 UtilSharedPreference.saveString(MainActivity.this,"address",deviceBean.getDevice().getAddress());
                App.getInstance().setDeviceBean(deviceBean);
                //关闭当前页面，跳转到TestActivity并且携带deviceBean对象
                Intent intent = new Intent(MainActivity.this, TestActivity.class);
                startActivity(intent);
                finish();
            }
        });
    }

    private void searchDevice(){
        macList.clear();
        adapter.clearData();
        //开始扫描
        BLEUtils.stopLeScan(this, leScanCallback);
        BLEUtils.startLeScan(this, leScanCallback);

        //延迟5秒，关闭
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                swipeRefreshLayout.setRefreshing(false);
                BLEUtils.stopLeScan(MainActivity.this, leScanCallback);
            }
        }, 5000);
    }



    @SuppressLint("MissingPermission")
    private BluetoothAdapter.LeScanCallback leScanCallback = new BluetoothAdapter.LeScanCallback() {
        @Override
        public void onLeScan(BluetoothDevice device, int rssi, byte[] bytes) {
            if (device == null || TextUtils.isEmpty(device.getName())) {
                return;
            }
            Logger.show("leScanCallback",device.getName());

            //是否符合条件，符合条件，会返回戒指设备信息
            BleDeviceInfo bleDeviceInfo = LogicalApi.getBleDeviceInfoWhenBleScan(device, rssi, bytes,false);
            if(bleDeviceInfo==null){
                return;
            }
            if (macList.contains(device.getAddress())) {
                return;
            }

            macList.add(device.getAddress());
            adapter.updateData(bleDeviceInfo);

        }
    };
}