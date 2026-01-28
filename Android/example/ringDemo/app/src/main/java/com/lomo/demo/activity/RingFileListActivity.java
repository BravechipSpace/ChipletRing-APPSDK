package com.lomo.demo.activity;

import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.PersistableBundle;
import android.provider.DocumentsContract;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.content.FileProvider;


import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.FileResponseCallback;
import com.lm.sdk.library.utils.ConvertUtils;
import com.lm.sdk.library.utils.ToastUtils;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.CMDUtils;
import com.lm.sdk.utils.LmApiDataUtils;
import com.lm.sdk.utils.Logger;
import com.lomo.demo.R;
import com.lomo.demo.base.BaseActivity;
import com.lomo.demo.file.CsvWriter;
import com.lomo.demo.file.FileInfo;
import com.lomo.demo.file.FileUtils;
import com.lomo.demo.file.NotificationHandler;
import com.lomo.demo.views.TipsDialog;


import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class RingFileListActivity extends BaseActivity {

    private ScrollView offlineLayout;
    private EditText exerciseTotalDurationInput;
    private RadioGroup radioGroup_time;
    private Button startExerciseButton;
    private Button stopExerciseButton;
    private TextView fileListStatus;
    private Button getFileListButton;
    private Button formatFileSystemButton;
    private Button downloadOneFile;
    private LinearLayout fileListContainer;
    private Button downloadSelectedButton;
    private Button uploadServer;
    private int currentFilePackets = 0;  // 当前文件总包数
    private int receivedPackets = 0;     // 已接收包数
    private Handler mainHandler;
    private Random random = new Random();
    private List<FileInfo> fileList = new ArrayList<>();
    private List<FileInfo> selectedFiles = new ArrayList<>();
    private boolean isDownloadingFiles = false;
    private int currentDownloadIndex = 0;
    private boolean isExercising = false;

    private static  String TARGET_PACKAGE = "com.smart.bing";
    private static final String TARGET_SUBDIR = "FileList";
    private static String downloadProgress="";
    private static double downloadSpeed=0;
    private   long lastTimestamp=0;
    private int   messageCount = 0;//接收的消息
    private boolean mergeFiles=false;//是否将所有数据保存到一个文件里
    private String oneFileName="";//合并文件为一个，文件名为第一个文件名的日期加上最后一个文件名的日期
    private FileResponseCallback fileResponseCallback=new FileResponseCallback() {
        @Override
        public void onFileListReceived(byte[] data) {
            handleFileListResponse(data);
        }

        @Override
        public void onFileInfoReceived(byte[] data) {
            handleBatchFileInfoPush(data);
        }

        @Override
        public void onDownloadStatusReceived(byte[] data){
            handleBatchDownloadStatusResponse(data);
        }
        @Override
        public void onFileDataReceived(byte[] data) {
            handleBatchFileDataPush(data);
        }

        @Override
        public void onFileState(int data) {

        }

        @Override
        public void onFilePushFileName(byte[] data) {

        }

        @Override
        public void onFilePushFileData(byte[] data) {

        }

        @Override
        public void onFileDownloadEndReceived(byte[] data){
            handleFileDownloadEndResponse(data);
        }

        @Override
        public void onDownloadAllFileProgress(byte[] data) {
            handleFileDownloadProgress(data);
        }

        @Override
        public void oneFileDownloadSuccess() {
            updateDownloadButtonFinish();
        }
    };



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ring_file_list);
        initView();
        TARGET_PACKAGE=getPackageName();

        setupClickListeners();
        mainHandler = new Handler(Looper.getMainLooper());
        if (exerciseTotalDurationInput != null) exerciseTotalDurationInput.setText("86400");//默认24小时

        // Set device command callback
        NotificationHandler.setDeviceCommandCallback(new NotificationHandler.DeviceCommandCallback() {
            @Override
            public void onExerciseStarted(int duration, int segmentTime) {
                recordLog(String.format("[采集开始] Total: %d sec, Segment: %d sec", duration, segmentTime));
                mainHandler.post(() -> {
                    updateExerciseUI(true);
                });
            }

            @Override
            public void onExerciseStopped() {
                recordLog("[采集已停止]");
                mainHandler.post(() -> {
                    updateExerciseUI(false);
                });
            }
        });
    }


// ==================== File Operations ====================

    private void getFileList() {
        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, getString(R.string.first_connect), Toast.LENGTH_SHORT).show();
            return;
        }
        LmAPILite.STOP_EXERCISE();
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                LmAPILite.GET_FILE_LIST(fileResponseCallback);
            }
        },300);
        recordLog("[Request File List] Using custom command");
        try {

            fileList.clear();
            selectedFiles.clear();
            updateFileListUI();

            mainHandler.post(() -> {
                getFileListButton.setText(getString(R.string.file_fetching));
                getFileListButton.setEnabled(false);
            });

        } catch (Exception e) {
            recordLog("Failed to send file list request: " + e.getMessage());
            Toast.makeText(this, getString(R.string.file_get_list_fail), Toast.LENGTH_SHORT).show();
        }
    }

    private Set<String> processedFiles = new HashSet<>();

    private void handleFileListResponse(byte[] data) {
        try {
            if (data == null || data.length < 12) {
                recordLog("File list response data length insufficient");
                return;
            }

            int totalFiles = readUInt32LE(data, 4);
            int seqNum = readUInt32LE(data, 8);
            int fileSize = readUInt32LE(data, 12);

            recordLog(String.format("File list info - Total: %d, Seq: %d, Size: %d", totalFiles, seqNum, fileSize));

            if (totalFiles > 0 && data.length > 16) {
                // Parse filename
                byte[] fileNameBytes = new byte[data.length - 16];
                System.arraycopy(data, 16, fileNameBytes, 0, fileNameBytes.length);

                String fileName = new String(fileNameBytes, "UTF-8").trim();
                fileName = fileName.replace("\0", "");

                if (!fileName.isEmpty()) {
                    // 创建文件唯一标识符（文件名+大小）
                    String fileKey = fileName + "|" + fileSize;


                        processedFiles.add(fileKey);
                        FileInfo fileInfo = new FileInfo(fileName, fileSize);
                        fileList.add(fileInfo);
                        recordLog("Add file: " + fileName + " (" + fileInfo.getFormattedSize() + ")");

                }
            }

            if(totalFiles==seqNum){
                mainHandler.post(() -> {
                    setupFileList();
                    getFileListButton.setText(getString(R.string.file_get_filelist));
                    getFileListButton.setEnabled(true);
                });
            }

            if(!fileList.isEmpty()){
                oneFileName="合并文件"+fileList.get(0).fileName+"至"+fileList.get(fileList.size()-1).fileName;
            }


        } catch (Exception e) {
            recordLog("Failed to parse file list: " + e.getMessage());
            mainHandler.post(() -> {
                getFileListButton.setText(getString(R.string.file_get_filelist));
                getFileListButton.setEnabled(true);
            });
        }
    }





    private void updateDownloadButtonProgress(int currentFileIndex, int totalFiles, String statusText) {
        mainHandler.post(() -> {
            if (downloadSelectedButton != null) {
                String buttonText = String.format(getString(R.string.download_progress)+" %d/%d\n%s",
                        currentFileIndex, totalFiles, statusText);
                downloadSelectedButton.setText(buttonText);
                downloadSelectedButton.setEnabled(false);
            }
        });
    }

    private void updateDownloadButtonFinish(){
        mainHandler.post(() -> {
            downloadSelectedButton.setText(getString(R.string.file_download_select)+" (" + selectedFiles.size() + ")");
            downloadSelectedButton.setEnabled(true);
        });
    }

    private void downloadAllFiles(){
        try {

            CsvWriter.clearOutputFile(RingFileListActivity.this);
            lastTimestamp=System.currentTimeMillis();
            downloadOneFile.setEnabled(false);
            LmAPILite.DOWNLOAD_ALL_FILES(fileResponseCallback);
        } catch (Exception e) {
            recordLog("Download file failed: " + e.getMessage());
        }
    }
    private void downloadSelectedFiles() {
        if (selectedFiles.isEmpty()) {
            Toast.makeText(this, getString(R.string.file_select_download), Toast.LENGTH_SHORT).show();
            return;
        }

        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, getString(R.string.first_connect), Toast.LENGTH_SHORT).show();
            return;
        }

        isDownloadingFiles = true;
        currentDownloadIndex = 0;
        currentFilePackets = 0;
        receivedPackets = 0;

        recordLog(String.format("[开始批量下载]所选文件: %d", selectedFiles.size()));
//
        // 更新按钮显示初始状态
        updateDownloadButtonProgress(0, 0, getString(R.string.device_initializing));

        downloadNextSelectedFile();
    }


    private void downloadNextSelectedFile() {
        if (currentDownloadIndex >= selectedFiles.size()) {
            // 所有文件下载完成
            isDownloadingFiles = false;
            mainHandler.post(() -> {
                downloadSelectedButton.setText(getString(R.string.file_download_select)+" (" + selectedFiles.size() + ")");
                downloadSelectedButton.setEnabled(true);
                Toast.makeText(this, getString(R.string.file_allfile_download), Toast.LENGTH_SHORT).show();
            });
            return;
        }

        FileInfo fileInfo = selectedFiles.get(currentDownloadIndex);
        recordLog(String.format(getString(R.string.file_downloading)+" %d/%d: %s",
                currentDownloadIndex + 1, selectedFiles.size(), fileInfo.fileName));

        // 重置当前文件的包计数器
        currentFilePackets = 0;
        receivedPackets = 0;

        // 更新按钮显示
        updateDownloadButtonProgress(currentDownloadIndex + 1, selectedFiles.size(),
                getString(R.string.star)+" " + fileInfo.fileName + "...");

        try {

           CsvWriter.clearOutputFile(RingFileListActivity.this, fileInfo.fileName);

            byte[] fileNameBytes = fileInfo.fileName.getBytes("UTF-8");
            LmAPILite.DOWNLOAD_FILE(fileNameBytes,fileResponseCallback);
            recordLog("已发送下载命令: " + fileInfo.fileName);

        } catch (Exception e) {
            recordLog("下载文件失败: " + e.getMessage());
            currentDownloadIndex++;
            mainHandler.postDelayed(this::downloadNextSelectedFile, 1000);
        }
    }

    private void setupFileList() {
        fileListContainer.removeAllViews();

        for (FileInfo fileInfo : fileList) {
            addFileItem(fileInfo);
        }

        updateFileListUI();
    }

    private void addFileItem(FileInfo fileInfo) {
        LinearLayout fileItem = new LinearLayout(this);
        fileItem.setOrientation(LinearLayout.HORIZONTAL);
        fileItem.setPadding(16, 12, 16, 12);
        fileItem.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT));

//        CheckBox checkBox = new CheckBox(this);
//        checkBox.setButtonTintList(ColorStateList.valueOf(Color.parseColor("#4C56F5")));
//        checkBox.setChecked(fileInfo.isSelected);
//        checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
//            fileInfo.isSelected = isChecked;
//            updateSelectedFiles();
//        });

        LinearLayout fileInfoLayout = new LinearLayout(this);
        fileInfoLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
        layoutParams.setMargins(24, 0, 0, 0);
        fileInfoLayout.setLayoutParams(layoutParams);

        TextView fileName = new TextView(this);
        fileName.setText(fileInfo.fileName);
        fileName.setTextSize(12);
        fileName.setTextColor(Color.BLACK);

        TextView fileDetails = new TextView(this);
        fileDetails.setText(fileInfo.getFileTypeDescription() + " | " + fileInfo.getFormattedSize() + " | " + fileInfo.timestamp);
        fileDetails.setTextSize(10);
        fileDetails.setTextColor(Color.GRAY);

        fileInfoLayout.addView(fileName);
        fileInfoLayout.addView(fileDetails);

      // fileItem.addView(checkBox);
        fileItem.addView(fileInfoLayout);

        fileItem.setOnClickListener(v -> {
          //checkBox.setChecked(!checkBox.isChecked());
        });

        fileListContainer.addView(fileItem);
    }

    private void updateSelectedFiles() {
        selectedFiles.clear();
        for (FileInfo file : fileList) {
            if (file.isSelected) {
                selectedFiles.add(file);
            }
        }
        updateFileListUI();
    }

    private void updateFileListUI() {
        mainHandler.post(() -> {
            fileListStatus.setText(String.format(getString(R.string.file_all_file), fileList.size()));

            // 只有在不下载时才更新按钮文本
            if (!isDownloadingFiles) {
                downloadSelectedButton.setText(getString(R.string.file_download_select)+" (" + selectedFiles.size() + ")");
                downloadSelectedButton.setEnabled(selectedFiles.size() > 0);
            }
        });
    }

    // ==================== Exercise Control ====================

    private void startExercise() {
        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, getString(R.string.first_connect), Toast.LENGTH_SHORT).show();
            return;
        }

        if (isExercising) {
            Toast.makeText(this, getString(R.string.file_in_progress), Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            String totalDurationStr = exerciseTotalDurationInput.getText().toString().trim();
            String segmentDurationStr ="";


            int selectedId = radioGroup_time.getCheckedRadioButtonId();

            if (selectedId == R.id.rb_10_minute) {
                segmentDurationStr="10";
            } else if (selectedId == R.id.rb_20_minute) {
                segmentDurationStr="20";
            } else if (selectedId == R.id.rb_30_minute) {
                segmentDurationStr="30";
            }  else if (selectedId == R.id.rb_60_minute) {
                segmentDurationStr="60";
            }
            if (totalDurationStr.isEmpty() ) {
                Toast.makeText(this, getString(R.string.file_enter_collection_time), Toast.LENGTH_SHORT).show();
                return;
            }

            int totalDuration = Integer.parseInt(totalDurationStr);
            int segmentDuration = Integer.parseInt(segmentDurationStr)*60;

            if (totalDuration < 600 || totalDuration > 86400) {
                Toast.makeText(this, getString(R.string.file_total_collection_time), Toast.LENGTH_SHORT).show();
                return;
            }


            NotificationHandler.setExerciseParams(totalDuration, segmentDuration);
            boolean success = NotificationHandler.startExercise();

            if (success) {
                isExercising = true;
                recordLog(String.format("[开始采集] 总共: %d , 进行: %d ", totalDuration, segmentDuration));
                updateExerciseUI(true);
                Toast.makeText(this, getString(R.string.file_collection_begins), Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, getString(R.string.file_failed_start_collection), Toast.LENGTH_SHORT).show();
            }

        } catch (NumberFormatException e) {
            Toast.makeText(this, getString(R.string.file_enter_valid_number), Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            recordLog("开始采集失败: " + e.getMessage());
            Toast.makeText(this, getString(R.string.file_failed_start_collection) + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void stopExercise() {
//        if (!isExercising) {
//            Toast.makeText(this, getString(R.string.file_there_are_currently_no_ongoing_collections), Toast.LENGTH_SHORT).show();
//            return;
//        }

        try {
            boolean success = NotificationHandler.stopExercise();
            if (success) {
                isExercising = false;
                recordLog("[结束采集]用户手动停止");
                updateExerciseUI(false);
                Toast.makeText(this, getString(R.string.file_collection_stopped), Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, getString(R.string.file_unable_to_stop_collection), Toast.LENGTH_SHORT).show();
            }
        } catch (Exception e) {
            recordLog("无法停止采集: " + e.getMessage());
            Toast.makeText(this, getString(R.string.file_unable_to_stop_collection) + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void updateExerciseUI(boolean exercising) {
        if (startExerciseButton != null) {
            isExercising=exercising;
            startExerciseButton.setEnabled(!exercising);
            startExerciseButton.setText(exercising ? getString(R.string.file_collecting) : getString(R.string.file_collection_begins));
        }

        if (stopExerciseButton != null) {
            stopExerciseButton.setEnabled(exercising);
            stopExerciseButton.setBackgroundColor(exercising ? Color.parseColor("#F44336") : Color.GRAY);
        }
    }


    private void recordLog(String message) {

        Log.d("recordLog", message);
    }

    /**
     * 处理硬件推送的文件信息 (0x361B)
     */
    // 硬件一键下载相关变量
    private boolean isHardwareBatchDownloading = false;
    private List<BatchFileInfo> receivedBatchFiles = new ArrayList<>();
    private BatchFileInfo currentBatchFile = null;
    private int expectedFileCount = 0;
    private long batchDownloadStartTime = 0;
    private long batchDownloadEndTime = 0;

    // 批量文件信息类
    private static class BatchFileInfo {
        public int fileIndex;
        public String fileName;
        public long startTimestamp;
        public long endTimestamp;
        public List<byte[]> fileDataPackets;
        public boolean isComplete;
        public int totalPackets;
        public int receivedPackets;

        public BatchFileInfo(int fileIndex, String fileName, long startTimestamp, long endTimestamp) {
            this.fileIndex = fileIndex;
            this.fileName = fileName;
            this.startTimestamp = startTimestamp;
            this.endTimestamp = endTimestamp;
            this.fileDataPackets = new ArrayList<>();
            this.isComplete = false;
            this.totalPackets = 0;
            this.receivedPackets = 0;
        }
    }
    private void handleBatchFileInfoPush(byte[] data) {
        try {
            if (data.length < 50) {
                recordLog("批处理文件信息长度无效: " + data.length);
                return;
            }

            int fileIndex = data[4] & 0xFF;
            int uploadStatus = data[5] & 0xFF;
            long startTimestamp = bytesToLong(Arrays.copyOfRange(data, 6, 10));
            long endTimestamp = bytesToLong(Arrays.copyOfRange(data, 10, 14));

            // 提取文件名
            byte[] fileNameBytes = Arrays.copyOfRange(data, 14, data.length);
            String fileName = extractFileName(fileNameBytes);

            if (uploadStatus == 0) {
                // 开始推送文件信息
                currentBatchFile = new BatchFileInfo(fileIndex, fileName, startTimestamp, endTimestamp);

                    CsvWriter.clearOutputFile(RingFileListActivity.this,fileName);

                recordLog(String.format("接收批处理文件信息: [%d] %s", fileIndex, fileName));

                downloadProgress=getString(R.string.file_progress)+" : " + fileIndex+"/"+fileList.size();
                mainHandler.post(() -> {
                    updateBatchDownloadProgress(downloadProgress);
                });

            }

        } catch (Exception e) {
            recordLog("处理批处理文件信息时出错: " + e.getMessage());
            e.printStackTrace();
        }
    }

    //更新每个文件下载的进度
   // StringBuilder sb = new StringBuilder();
    private void handleFileDownloadProgress(byte[] data) {
//        int progress= data[4] & 0xFF;
//            sb.setLength(0);
//            sb.append(downloadProgress).append("(").append(progress).append("%").append(")");
//        mainHandler.post(() -> {
//            updateBatchDownloadProgress(sb.toString());
//        });
    }


    private void  handleFileDownloadEndResponse(byte[] data) {
        try {
            recordLog("handleFileDownloadEndResponse: " + ConvertUtils.bytes2HexString(data));

            if (currentBatchFile != null) {
                currentBatchFile.isComplete = true;
                receivedBatchFiles.add(currentBatchFile);

                saveBatchFileData(currentBatchFile);

                currentBatchFile = null;
            }

        } catch (Exception e) {
            recordLog("处理批处理文件信息时出错: " + e.getMessage());
            e.printStackTrace();
        }
    }
    private String extractFileName(byte[] fileNameBytes) {
        try {
            // 添加调试日志
            StringBuilder hexLog = new StringBuilder();
            for (byte b : fileNameBytes) {
                hexLog.append(String.format("%02X ", b & 0xFF));
            }
            recordLog("文件名 字节: " + hexLog.toString());

            // 处理UTF-8编码的文件名
            String fileName = new String(fileNameBytes, "UTF-8");
            recordLog("原始文件名字符串: '" + fileName + "' (长度: " + fileName.length() + ")");

            // 找到第一个null字符并截断
            int nullIndex = fileName.indexOf('\0');
            if (nullIndex != -1) {
                fileName = fileName.substring(0, nullIndex);
                recordLog("找到第一个null字符并截断: '" + fileName + "'");
            }

            // 移除不可见字符但保留正常的文件名字符
            fileName = fileName.replaceAll("[\\x00-\\x1F\\x7F]", "").trim();
            recordLog("移除不可见字符但保留正常的文件名字符: '" + fileName + "'");

            // 如果文件名为空，生成默认名称
            if (fileName.isEmpty()) {
                fileName = "unknown_file_" + System.currentTimeMillis();
            }

            return fileName;
        } catch (Exception e) {
            recordLog("提取文件名时出错: " + e.getMessage());
            return "unknown_file_" + System.currentTimeMillis();
        }
    }


    /**
     * 字节数组转长整型（小端序）
     */
    private long bytesToLong(byte[] bytes) {
        if (bytes.length != 4) {
            throw new IllegalArgumentException("Byte array must be 4 bytes long");
        }
        return ((long)(bytes[0] & 0xFF)) |
                ((long)(bytes[1] & 0xFF) << 8) |
                ((long)(bytes[2] & 0xFF) << 16) |
                ((long)(bytes[3] & 0xFF) << 24);
    }


    /**
     * 处理硬件推送的文件数据
     */
    StringBuilder sbSpeed = new StringBuilder();
    private boolean handleBatchFileDataPush(byte[] data) {

        if (currentBatchFile == null) {
            recordLog("已收到文件数据，但没有当前批处理文件");
            return false;
        }

        try {
            String str_data1 = CMDUtils.toHexString(data);
            Logger.show("文件采集", "===handleBatchFileDataPush=== " + str_data1);
            byte[] fileData = Arrays.copyOfRange(data, 4, data.length);
            currentBatchFile.fileDataPackets.add(fileData);
            currentBatchFile.receivedPackets++;

            long now = System.currentTimeMillis();

            // 计算时间差（毫秒）
            long timeDiff = now - lastTimestamp;

            if (timeDiff >= 1000) { // 超过1秒则计算速率
                double   currentRate = (currentBatchFile.receivedPackets-messageCount) * 1000.0 / timeDiff;
                if(currentRate>0){
                    recordLog("速率:"+String.format(Locale.getDefault(), "%.1f", currentRate)+"条/秒");

                    //更新每个文件下载的进度（每条175b）
                    double rateKBS=currentRate*175/1024;
                    sbSpeed.setLength(0);
                    sbSpeed.append(downloadProgress).append(" ").append(getString(R.string.file_speed))
                            .append(String.format(Locale.getDefault(), "%.1f", rateKBS)).append("kb/s");
                    mainHandler.post(() -> {
                        updateBatchDownloadProgress(sbSpeed.toString());
                    });
                }
                lastTimestamp = now;
                messageCount=currentBatchFile.receivedPackets;

            }

            return true;
        } catch (Exception e) {
            recordLog("处理批处理文件数据时出错: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 保存批量文件数据
     */
    private void saveBatchFileData(BatchFileInfo fileInfo) {
        // 使用单一线程的串行执行器确保写入顺序
        ExecutorService executor = Executors.newSingleThreadExecutor();

        executor.execute(() -> {
            try {
                String safeFileName = fileInfo.fileName.replace(":", "_");
                List<String[]> allContent = new ArrayList<>();

                String fileType= FileUtils.getFileType(safeFileName);
                //先清理txt缓存的内容
                CsvWriter.clearOutputFile(RingFileListActivity.this,safeFileName);
                // 1. 先收集所有数据
                for (int i = 0; i < fileInfo.fileDataPackets.size(); i++) {
                    byte[] packetData = fileInfo.fileDataPackets.get(i);
                    byte[] contentDataByte = new byte[packetData.length - 17];
                    System.arraycopy(packetData, 17, contentDataByte, 0, contentDataByte.length);
                    List<String[]> fileContent = new ArrayList<>();
                    if(fileType.equals("7")){

                        String str_data = CMDUtils.toHexString(contentDataByte);
                        Logger.show("文件采集", "===文件内容=== " + str_data);

                        CsvWriter.appendToTxt(RingFileListActivity.this, safeFileName,str_data);
                        //fileContent = LmApiDataUtils.fileContentQingHua(contentDataByte);
                    }else if(fileType.equals("9")){
                        fileContent = LmApiDataUtils.fileContentType9(contentDataByte);
                        allContent.addAll(fileContent);

                    }
                }
                //是7类型，从缓存里获取所有数据
                if(fileType.equals("7")) {
                    String fromTxt = CsvWriter.readFromTxt(RingFileListActivity.this, safeFileName);
                    //每158个字节转码一次
                    byte[] bytes = CMDUtils.hexString2Bytes(fromTxt);

                    // 存储所有转换结果的列表
                    List<List<String[]>> allResults = new ArrayList<>();

                    // 计算总段数
                    int totalSegments = bytes.length / 158;

                    // 按158字节分段处理
                    for(int i = 0; i < totalSegments; ++i) {
                        // 计算当前段的起始位置
                        int start = i * 158;
                        int end = Math.min(start + 158, bytes.length);

                        // 提取当前158字节段
                        byte[] segment = new byte[end - start];
                        System.arraycopy(bytes, start, segment, 0, segment.length);

                        // 对当前段进行转码
                        List<String[]> segmentResult = LmApiDataUtils.fileContentQingHua(segment);
                        allResults.add(segmentResult);
                    }
                    //合并到一个列表
                    for(List<String[]> segmentList : allResults) {
                        if(segmentList != null) {
                            allContent.addAll(segmentList);
                        }
                    }



                }

                recordLog("先收集所有数据: " + allContent.size());
                long time1=new Date().getTime();
                recordLog("先收集所有数据: " + new Date());
                // 2. 一次性写入所有数据

                if(mergeFiles){
                    safeFileName=oneFileName;
                }
                if(fileType.equals("7")){
                    CsvWriter.appendToOptimizedCsv(RingFileListActivity.this, safeFileName, allContent,false);
                }else if(fileType.equals("9")){
                    CsvWriter.appendToOptimizedCsv(RingFileListActivity.this, safeFileName, allContent,true);
                }

                recordLog("写入文件中: " + (new Date().getTime()-time1));

            } catch (Exception e) {
                runOnUiThread(() -> {
                    recordLog("保存硬件批处理文件失败: " + e.getMessage());
                    Toast.makeText(RingFileListActivity.this, getString(R.string.Failed), Toast.LENGTH_SHORT).show();
                });
                e.printStackTrace();
            } finally {
                executor.shutdown();
            }
        });
    }
    private String bytesToHexString(byte[] bytes) {
        if (bytes == null || bytes.length == 0) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b & 0xFF));
        }
        return sb.toString();
    }
    /**
     * 完成批量下载
     */
    private void finalizeBatchDownload() {
        long downloadDuration = System.currentTimeMillis() - batchDownloadStartTime;

        recordLog(String.format("下载结束! 总共: %d, 用时: %d ms",
                receivedBatchFiles.size(), downloadDuration));

        mainHandler.post(() -> {
           // uploadFileToServer("");
            ToastUtils.show(R.string.operate_successfully);
            updateBatchDownloadProgress(getString(R.string.file_completed)+": " + receivedBatchFiles.size() + " "+getString(R.string.file_files));
        });

        resetHardwareBatchDownloadState();

    }


    private void handleBatchDownloadStatusResponse(byte[] data) {
        try {
            if (data.length < 5) {
                recordLog("批下载状态响应，长度无效: " + data.length);
                return;
            }

            int status = data[4] & 0xFF;

            switch (status) {
                case 0: // 设备忙
                    recordLog("设备正忙，硬件批量下载失败");
                    mainHandler.post(() -> {
                        Toast.makeText(this, getString(R.string.file_device_busy), Toast.LENGTH_SHORT).show();
                    });
                    resetHardwareBatchDownloadState();
                    break;

                case 1: // 开始硬件一键下载
                    if (data.length >= 13) {
                        long startTimestamp = bytesToLong(Arrays.copyOfRange(data, 5, 9));
                        long endTimestamp = bytesToLong(Arrays.copyOfRange(data, 9, 13));
                        batchDownloadStartTime = startTimestamp;
                        batchDownloadEndTime = endTimestamp;

                        recordLog(String.format("硬件批量下载已开始。时间范围: %d - %d",
                                startTimestamp, endTimestamp));

                    }
                    break;

                case 2: // 硬件一键下载完成
                    recordLog("硬件批量下载已完成。收到的文件总数: " + receivedBatchFiles.size());
//                    mainHandler.post(() -> {
//                        Toast.makeText(this, "硬件批量下载已完成", Toast.LENGTH_SHORT).show();
//                    });
                    finalizeBatchDownload();
                    break;

                case 3: // 文件序号不符合或其他错误
                    recordLog("硬件批量下载错误：文件序列无效");

                    resetHardwareBatchDownloadState();
                    break;

                default:
                    recordLog("未知硬件批下载状态: " + status);
                    break;
            }

        } catch (Exception e) {
            recordLog("处理批量下载状态时出错: " + e.getMessage());
            e.printStackTrace();
        }
    }
    /**
     * 更新批量下载进度显示
     */
    private void updateBatchDownloadProgress(String status) {
        if(mergeFiles){
            if (downloadOneFile != null) {
                downloadOneFile.setText(getString(R.string.download_progress) + status);
            }
        }

    }

    private void resetHardwareBatchDownloadState() {
        isHardwareBatchDownloading = false;
        currentBatchFile = null;

        mainHandler.post(() -> {

            if (downloadOneFile != null) {
                downloadOneFile.setText(getString(R.string.file_download_one_file_local));
                downloadOneFile.setEnabled(true);
            }
        });
    }

    private int readUInt32LE(byte[] data, int offset) {
        if (offset + 4 > data.length) {
            throw new IndexOutOfBoundsException("数据不足，无法读取4字节整数");
        }
        return (data[offset] & 0xFF) |
                ((data[offset + 1] & 0xFF) << 8) |
                ((data[offset + 2] & 0xFF) << 16) |
                ((data[offset + 3] & 0xFF) << 24);
    }
    public void formatFileSystem() {
        new AlertDialog.Builder(this)
                .setTitle(getString(R.string.file_format_file_system))
                .setMessage(getString(R.string.file_format_file_system_notice))
                .setIcon(android.R.drawable.ic_dialog_alert)
                .setPositiveButton(getString(R.string.file_format_file_system_sure), (dialog, which) -> {
                    performFormatFileSystem();
                })
                .setNegativeButton(getString(R.string.cancel) ,null)
                .show();
    }
    private void performFormatFileSystem() {
        try {
            LmAPILite.PERFORM_FORMAT_FILESYSTEM(fileResponseCallback);
        } catch (Exception e) {
            e.printStackTrace();


        }
    }
    private void initView() {
        offlineLayout = (ScrollView) findViewById(R.id.offlineLayout);
        exerciseTotalDurationInput = (EditText) findViewById(R.id.exerciseTotalDurationInput);
        radioGroup_time=  findViewById(R.id.radioGroup_time);
        startExerciseButton = (Button) findViewById(R.id.startExerciseButton);
        stopExerciseButton = (Button) findViewById(R.id.stopExerciseButton);
        fileListStatus = (TextView) findViewById(R.id.fileListStatus);
        getFileListButton = (Button) findViewById(R.id.getFileListButton);
        formatFileSystemButton = (Button) findViewById(R.id.formatFileSystemButton);
        downloadOneFile = (Button) findViewById(R.id.downloadOneFile);
        fileListContainer = (LinearLayout) findViewById(R.id.fileListContainer);
        downloadSelectedButton = (Button) findViewById(R.id.downloadSelectedButton);

        uploadServer = (Button) findViewById(R.id.uploadServer);

    }

    private void setupClickListeners() {

        getFileListButton.setOnClickListener(v -> getFileList());
        downloadSelectedButton.setOnClickListener(v -> downloadSelectedFiles());

        formatFileSystemButton.setOnClickListener(v-> formatFileSystem());

        downloadOneFile.setOnClickListener(v->{
            mergeFiles=true;
            downloadAllFiles();
        });
        // Exercise control buttons
        if (startExerciseButton != null) {
            startExerciseButton.setOnClickListener(v ->{
                if (!BLEUtils.isGetToken()) {
                    Toast.makeText(this, getString(R.string.file_device_no_connect), Toast.LENGTH_SHORT).show();
                    return;
                }

                TipsDialog dialog = new TipsDialog(RingFileListActivity.this);

                dialog.setDialogTitle(R.string.hint);
                dialog.setDialogMsg(getString(R.string.file_format_file_system_first));
                dialog.setCommitClickListener(getString(R.string.file_format_file_system_sure), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        performFormatFileSystem();
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                startExercise();
                                dialog.dismiss();
                            }
                        },500);
                    }
                });
                dialog.setCancelClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startExercise();
                        dialog.dismiss();
                    }
                });

                dialog.show();


            } );
        }
        if (stopExerciseButton != null) {
            stopExerciseButton.setOnClickListener(v -> stopExercise());
        }

    }



    private long readUInt64LE(byte[] data, int offset) {
        if (offset + 8 > data.length) {
            throw new IndexOutOfBoundsException("Insufficient data to read 8-byte timestamp");
        }
        long result = 0;
        for (int i = 0; i < 8; i++) {
            result |= ((long)(data[offset + i] & 0xFF)) << (i * 8);
        }
        return result;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

    }

    @Override
    public void lmBleConnectionFailed(int code) {
        super.lmBleConnectionFailed(code);
        Log.e("lmBleConnecting", "连接失败");

    }

    private void openTargetFolder() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ 使用SAF尝试打开
            openWithStorageAccessFramework();
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 特殊处理
            openWithMediaStore();
        } else {
            // Android 9及以下版本
            openWithLegacyMethod();
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.R)
    private void openWithStorageAccessFramework() {
        // 方法1：尝试直接打开目标文件夹（可能不成功）
        try {
            Uri uri = Uri.parse("content://com.android.externalstorage.documents/tree/primary:Android%2Fdata%2F" +
                    TARGET_PACKAGE + "%2Ffiles%2F" + TARGET_SUBDIR);

            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(uri, "vnd.android.document/root");
            intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

            startActivity(intent);
        } catch (Exception e) {
            // 方法1失败后尝试方法2：引导用户手动导航
            openFallbackAlternative();
        }
    }

    private void openFallbackAlternative() {
        // 显示指导信息
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.file_operation_guide));
        builder.setMessage(getString(R.string.file_manually_navigate_to) + TARGET_PACKAGE + " > files > " + TARGET_SUBDIR);
        builder.setPositiveButton(getString(R.string.file_open_file_manager), (dialog, which) -> {
            // 打开文件管理器根目录
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse("content://com.android.externalstorage.documents/root/primary"));
            try {
                startActivity(intent);
            } catch (ActivityNotFoundException e) {
                Toast.makeText(this, getString(R.string.file_manager_application_not_found), Toast.LENGTH_SHORT).show();
            }
        });
        builder.setNegativeButton(getString(R.string.cancel), null);
        builder.show();
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private void openWithMediaStore() {
        // Android 10的特殊处理方式
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("content://media/external/file"));
        try {
            startActivity(intent);
        } catch (ActivityNotFoundException e) {
            Toast.makeText(this, getString(R.string.file_manager_application_not_found), Toast.LENGTH_SHORT).show();
        }
    }

    private void openWithLegacyMethod() {
        File targetDir = new File(Environment.getExternalStorageDirectory(),
                "Android/data/" + TARGET_PACKAGE + "/files/" + TARGET_SUBDIR);

        if (targetDir.exists()) {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            Uri uri = FileProvider.getUriForFile(this,
                    getPackageName() + ".provider",
                    targetDir);

            intent.setDataAndType(uri, "resource/folder");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

            // 授予临时权限
            List<ResolveInfo> resInfoList = getPackageManager()
                    .queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
            for (ResolveInfo resolveInfo : resInfoList) {
                grantUriPermission(resolveInfo.activityInfo.packageName,
                        uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }

            try {
                startActivity(intent);
            } catch (ActivityNotFoundException e) {
                Toast.makeText(this, getString(R.string.file_manager_application_not_found), Toast.LENGTH_SHORT).show();
            }
        } else {
            Toast.makeText(this, getString(R.string.file_target_folder_does_not_exist), Toast.LENGTH_SHORT).show();
        }
    }
}