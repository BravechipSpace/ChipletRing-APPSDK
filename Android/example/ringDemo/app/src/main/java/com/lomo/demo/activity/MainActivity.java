package com.lomo.demo.activity;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.widget.Toast;

import com.hjq.permissions.OnPermissionCallback;
import com.hjq.permissions.Permission;
import com.hjq.permissions.XXPermissions;
import com.lm.sdk.BLEService;
import com.lm.sdk.LmAPI;
import com.lm.sdk.LogicalApi;
import com.lm.sdk.mode.BleDeviceInfo;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.StringUtils;
import com.lm.sdk.utils.UtilSharedPreference;
import com.lomo.demo.R;
import com.lomo.demo.adapter.DeviceAdapter;
import com.lomo.demo.adapter.DeviceBean;
import com.lomo.demo.adapter.OnItemClickListener;
import com.lomo.demo.application.App;
import com.lomo.demo.base.BaseActivity;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public class MainActivity extends BaseActivity {

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

    }

    private void initPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S){
            XXPermissions.with(this)
                    // 申请多个权限
                    .permission(Permission.ACCESS_COARSE_LOCATION, Permission.ACCESS_FINE_LOCATION, Permission.BLUETOOTH_SCAN, Permission.BLUETOOTH_CONNECT, Permission.BLUETOOTH_ADVERTISE,Permission.MANAGE_EXTERNAL_STORAGE)
                    // 设置权限请求拦截器（局部设置）
                    //.interceptor(new PermissionInterceptor())
                    // 设置不触发错误检测机制（局部设置）
                    //.unchecked()
                    .request(new OnPermissionCallback() {

                        @Override
                        public void onGranted(@NonNull List<String> permissions, boolean allGranted) {
                            if (!allGranted) {
                                Toast.makeText(getApplicationContext(),"获取部分权限成功，但部分权限未正常授予",Toast.LENGTH_SHORT).show();
                                return;
                            }
//                            String mac = UtilSharedPreference.getStringValue(MainActivity.this,"address");
//                            if(StringUtils.isEmpty(mac)){
                                searchDevice();
                            //}else{
//                                //自动重连，默认软连接
//                                UtilSharedPreference.saveInt(MainActivity.this, LmAPI.needHardconnection,0);
//                                Intent intent = new Intent(MainActivity.this, TestActivity.class);
//                                startActivity(intent);
//                                finish();
                           // }

                        }

                        @Override
                        public void onDenied(@NonNull List<String> permissions, boolean doNotAskAgain) {
                            if (doNotAskAgain) {
                                Toast.makeText(getApplicationContext(),"被永久拒绝授权，请手动授予录音和日历权限",Toast.LENGTH_SHORT).show();
                                // 如果是被永久拒绝就跳转到应用权限系统设置页面
                                XXPermissions.startPermissionActivity(MainActivity.this, permissions);
                            } else {
                                Toast.makeText(getApplicationContext(),"获取录音和日历权限失败",Toast.LENGTH_SHORT).show();
                            }
                        }
                    });

        }else {
            XXPermissions.with(MainActivity.this)
                    .permission(Manifest.permission.ACCESS_COARSE_LOCATION,Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.READ_EXTERNAL_STORAGE)
                    .request(new OnPermissionCallback() {
                        @Override
                        public void onGranted(@NonNull List<String> permissions, boolean allGranted) {
                            if (!allGranted) {
                                Toast.makeText(getApplicationContext(),"获取部分权限成功，但部分权限未正常授予",Toast.LENGTH_SHORT).show();
                                return;
                            }
//                            String mac = UtilSharedPreference.getStringValue(MainActivity.this,"address");
//                            if(StringUtils.isEmpty(mac)){
                                searchDevice();
                          //  }else{
//                                //自动重连，默认软连接
//                                UtilSharedPreference.saveInt(MainActivity.this,LmAPI.needHardconnection,0);
//                                Intent intent = new Intent(MainActivity.this, TestActivity.class);
//                                startActivity(intent);
//                                finish();
                          //  }
                        }

                        @Override
                        public void onDenied(@NonNull List<String> permissions, boolean doNotAskAgain) {
                            if (doNotAskAgain) {
                                Toast.makeText(getApplicationContext(),"被永久拒绝授权，请手动授予权限",Toast.LENGTH_SHORT).show();
                                // 如果是被永久拒绝就跳转到应用权限系统设置页面
                                XXPermissions.startPermissionActivity(MainActivity.this, permissions);
                            } else {
                                Toast.makeText(getApplicationContext(),"获取权限失败",Toast.LENGTH_SHORT).show();
                            }
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
                BLEUtils.isHIDDevice=deviceBean.getBindingIndicatorBit()==1;
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

            //是否符合条件，符合条件，会返回戒指设备信息
            BleDeviceInfo bleDeviceInfo = LogicalApi.getBleDeviceInfoWhenBleScan(device, rssi, bytes);
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