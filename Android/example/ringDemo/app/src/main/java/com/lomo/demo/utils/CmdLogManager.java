package com.lomo.demo.utils;

import android.app.Activity;
import android.app.Dialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Handler;
import android.os.Looper;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.lm.sdk.inter.ICMDLogListener;
import com.lomo.demo.R;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * 指令日志管理器：全局捕获SDK指令日志（App.onCreate注册一次，切换页面日志不丢失），
 * 查看日志对话框由多个页面共用（dialog_cmd_log.xml）
 */
public final class CmdLogManager {
    private static final CmdLogManager INSTANCE = new CmdLogManager();

    private final StringBuilder cmdLog = new StringBuilder();
    private final SimpleDateFormat logTimeFormat = new SimpleDateFormat("HH:mm:ss.SSS", Locale.CHINA);
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    /** 当前正在展示日志的视图，对话框关闭即清空引用 */
    private volatile TextView showingTextView;
    private volatile ScrollView showingScrollView;

    private CmdLogManager() {
    }

    public static CmdLogManager getInstance() {
        return INSTANCE;
    }

    /**
     * 全局指令日志监听器：捕获SDK发送指令/原始数据日志，对话框打开时实时刷新并滚动到底部
     */
    public final ICMDLogListener listener = new ICMDLogListener() {
        @Override
        public void log(String label, String type, String logs) {
            synchronized (cmdLog) {
                cmdLog.append("[").append(logTimeFormat.format(new Date())).append("] ")
                        .append(type).append(logs).append("\n");
            }
            final TextView tv = showingTextView;
            final ScrollView sv = showingScrollView;
            if (tv != null) {
                mainHandler.post(() -> {
                    synchronized (cmdLog) {
                        tv.setText(cmdLog.toString());
                    }
                    if (sv != null) {
                        sv.post(() -> sv.fullScroll(ScrollView.FOCUS_DOWN));
                    }
                });
            }
        }
    };

    /**
     * 弹出全屏对话框展示指令日志，提供"复制"、"清空"和"关闭"按钮
     */
    public void show(Activity activity) {
        final Dialog dialog = new Dialog(activity, android.R.style.Theme_DeviceDefault_NoActionBar_Fullscreen);
        // 全屏深色主题默认黑底，把窗口背景也刷成白色，避免黑底黑字看不见
        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
        dialog.setContentView(R.layout.dialog_cmd_log);
        TextView tvCmdLog = dialog.findViewById(R.id.tv_cmd_log);
        ScrollView svCmdLog = dialog.findViewById(R.id.sv_cmd_log);
        // 清空日志字符串并刷新显示
        dialog.findViewById(R.id.bt_clear_log).setOnClickListener(v -> {
            synchronized (cmdLog) {
                cmdLog.setLength(0);
            }
            tvCmdLog.setText("暂无日志");
        });
        // 复制日志全文到系统粘贴板
        dialog.findViewById(R.id.bt_copy_log).setOnClickListener(v -> {
            String log;
            synchronized (cmdLog) {
                log = cmdLog.toString();
            }
            ClipboardManager clipboardManager = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
            clipboardManager.setPrimaryClip(ClipData.newPlainText("cmd_log", log));
            Toast.makeText(activity, log.isEmpty() ? "暂无日志可复制" : "日志已复制到粘贴板", Toast.LENGTH_SHORT).show();
        });
        // 关闭对话框
        dialog.findViewById(R.id.bt_close_log).setOnClickListener(v -> dialog.dismiss());
        // 对话框存续期间实时刷新，关闭即清空引用
        showingTextView = tvCmdLog;
        showingScrollView = svCmdLog;
        dialog.setOnDismissListener(d -> {
            showingTextView = null;
            showingScrollView = null;
        });
        synchronized (cmdLog) {
            String log = cmdLog.toString();
            tvCmdLog.setText(log.isEmpty() ? "暂无日志" : log);
        }
        dialog.show();
        // 滚动到底部显示最新日志
        svCmdLog.post(() -> svCmdLog.fullScroll(ScrollView.FOCUS_DOWN));
    }
}
