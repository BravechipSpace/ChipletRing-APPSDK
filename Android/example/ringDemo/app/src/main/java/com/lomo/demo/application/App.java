package com.lomo.demo.application;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.os.Process;
import android.util.Log;

import com.lm.sdk.LmAPI;
import com.lm.sdk.LmAPILite;
import com.lm.sdk.library.AppConfig;
import com.lm.sdk.mode.BleDeviceInfo;
import com.lm.sdk.utils.BLEUtils;
import com.lomo.demo.adapter.DeviceBean;
import com.tencent.bugly.crashreport.CrashReport;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * @author Lizhao
 */
public class App extends Application {
    private static final String TAG = "CrashLog";
    public static final String CRASH_LOG_FILE = "crash_log.txt";
    private static App app;
    private DeviceBean deviceBean;
    private BluetoothAdapter mBluetoothAdapter;
    public static boolean needAutoConnect=true;//是否需要自动重连，默认true，如果测试断连情况，可以不需要重连
    @Override
    public void onCreate() {
        super.onCreate();
        app = this;
        LmAPILite.init(this);
        LmAPILite.setDebug(true);
        AppConfig.setOverseas(false);
        BLEUtils.contentTitle="ChipletRing Demo";
        //debug=true 时Bugly会把崩溃堆栈打印到logcat（TAG: CrashReportApiHelper），便于adb抓取
        CrashReport.initCrashReport(getApplicationContext(), "c1bf4858f3", true);
        //Bugly只能上报Java/native崩溃，对系统主动杀进程（权限、ANR、厂商ROM拦截）无上报。
        //这里再加一层兜底：把未捕获异常写入内部文件，并保留Bugly的handler继续上报。
        installCrashFileLogger();
    }

    /**
     * 兜底崩溃日志：与ImageSaverUtil.saveImageToInternalStorage同目录（FileUtil.getSDPath(context,"LM")），
     * 文件管理器可直接找到。崩溃后进程即将被杀，这里必须同步写入，不能走ImageSaverUtil的异步线程。
     */
    private void installCrashFileLogger() {
        final Thread.UncaughtExceptionHandler previous = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread t, Throwable e) {
                try {
                    String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA).format(new Date());
                    StringWriter sw = new StringWriter();
                    e.printStackTrace(new PrintWriter(sw));
                    String content = "\n==== " + time + " thread=" + t.getName() + " ====\n" + sw;
                    File dir = new File(com.lm.sdk.utils.FileUtil.getSDPath(app, "LM"));
                    if (!dir.exists()) {
                        dir.mkdirs();
                    }
                    File file = new File(dir, CRASH_LOG_FILE);
                    try (FileOutputStream fos = new FileOutputStream(file, true)) {
                        fos.write(content.getBytes());
                        fos.flush();
                        fos.getFD().sync();
                    }
                    Log.e(TAG, "UncaughtException saved to " + file.getAbsolutePath(), e);
                    //同步上报一份给Bugly，避免进程被杀导致上报丢失
                    CrashReport.postCatchedException(e);
                } catch (Throwable ignore) {
                } finally {
                    if (previous != null) {
                        previous.uncaughtException(t, e);
                    }
                    Process.killProcess(Process.myPid());
                }
            }
        });
    }

    /**
     * 读取兜底崩溃日志（供页面展示/分享）
     */
    public static String readCrashLog() {
        try {
            File file = new File(com.lm.sdk.utils.FileUtil.getSDPath(app, "LM"), CRASH_LOG_FILE);
            if (!file.exists()) {
                return "";
            }
            byte[] buf = new byte[(int) Math.min(file.length(), 200 * 1024)];
            try (java.io.FileInputStream fis = new java.io.FileInputStream(file)) {
                int read = fis.read(buf);
                return new String(buf, 0, Math.max(read, 0));
            }
        } catch (Throwable e) {
            return "读取崩溃日志失败:" + e.getMessage();
        }
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
