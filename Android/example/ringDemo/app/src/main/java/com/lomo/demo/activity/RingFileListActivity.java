package com.lomo.demo.activity;

import android.app.Activity;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PersistableBundle;
import android.util.Log;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;


import androidx.annotation.Nullable;

import com.lm.sdk.LmAPI;
import com.lm.sdk.LmAPILite;
import com.lm.sdk.inter.FileResponseCallback;
import com.lm.sdk.inter.ICustomizeCmdListener;
import com.lm.sdk.library.utils.ToastUtils;
import com.lm.sdk.utils.BLEUtils;
import com.lm.sdk.utils.LmApiDataUtils;
import com.lomo.demo.R;
import com.lomo.demo.file.CsvWriter;
import com.lomo.demo.file.FileInfo;
import com.lomo.demo.file.NotificationHandler;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

public class RingFileListActivity extends Activity {

    private ScrollView offlineLayout;
    private EditText exerciseTotalDurationInput;
    private EditText exerciseSegmentDurationInput;
    private TextView exerciseStatusText;
    private Button startExerciseButton;
    private Button stopExerciseButton;
    private TextView fileListStatus;
    private Button getFileListButton;
    private Button formatFileSystemButton;
    private LinearLayout fileListContainer;
    private Button downloadSelectedButton;
    private Button downloadAll;
    private int currentFilePackets = 0;  // 当前文件总包数
    private int receivedPackets = 0;     // 已接收包数
    private Handler mainHandler;
    private Random random = new Random();
    private List<FileInfo> fileList = new ArrayList<>();
    private List<FileInfo> selectedFiles = new ArrayList<>();
    private boolean isDownloadingFiles = false;
    private int currentDownloadIndex = 0;
    private boolean isExercising = false;


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
            handleFileDataResponse(data);
        }

        @Override
        public void onFileState(int data) {

        }

        @Override
        public void onFileDownloadEndReceived(byte[] data){
            handleFileDownloadEndResponse(data);
        }

        @Override
        public void onDownloadAllFileProgress(byte[] data) {

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
        setupClickListeners();
        mainHandler = new Handler(Looper.getMainLooper());
        if (exerciseTotalDurationInput != null) exerciseTotalDurationInput.setText("300");
        if (exerciseSegmentDurationInput != null) exerciseSegmentDurationInput.setText("60");

        // Set device command callback
        NotificationHandler.setDeviceCommandCallback(new NotificationHandler.DeviceCommandCallback() {

            @Override
            public void onExerciseStarted(int duration, int segmentTime) {
                recordLog(String.format("[运动开始] Total: %d sec, Segment: %d sec", duration, segmentTime));
                mainHandler.post(() -> {
                    updateExerciseUI(true);
                    updateExerciseStatus("运动中...");
                });
            }

            @Override
            public void onExerciseStopped() {
                recordLog("[运动已停止]");
                mainHandler.post(() -> {
                    updateExerciseUI(false);
                    updateExerciseStatus("已停止");
                });
            }
        });
    }


// ==================== File Operations ====================

    private void getFileList() {
        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, "设备未连接", Toast.LENGTH_SHORT).show();
            return;
        }

        recordLog("[Request File List] Using custom command");
        try {
            LmAPI.GET_FILE_LIST(fileResponseCallback);
            fileList.clear();
            selectedFiles.clear();
            updateFileListUI();

            mainHandler.post(() -> {
                getFileListButton.setText("获取中...");
                getFileListButton.setEnabled(false);
            });

        } catch (Exception e) {
            recordLog("Failed to send file list request: " + e.getMessage());
            Toast.makeText(this, "Failed to get file list", Toast.LENGTH_SHORT).show();
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

            mainHandler.post(() -> {
                setupFileList();
                getFileListButton.setText("得到文件列表");
                getFileListButton.setEnabled(true);
            });

        } catch (Exception e) {
            recordLog("Failed to parse file list: " + e.getMessage());
            mainHandler.post(() -> {
                getFileListButton.setText("得到文件列表");
                getFileListButton.setEnabled(true);
            });
        }
    }

    private void handleFileDataResponse(byte[] data) {
        try {
            if(handleBatchFileDataPush(data)){
                return;
            }
            if (data.length < 4) {
                recordLog("File data response length insufficient");
                return;
            }

            if (data[2] == 0x36 && data[3] == 0x11) {

                int offset = 4;

                if (data.length < offset + 25) {
                    recordLog("File data structure incomplete, requires at least 25 bytes header");
                    recordLog("Actual length: " + (data.length - offset) + " bytes");
                    return;
                }

                int fileStatus = data[offset] & 0xFF;
                offset += 1;
                int fileSize = readUInt32LE(data, offset);
                offset += 4;
                int totalPackets = readUInt32LE(data, offset);
                offset += 4;
                int currentPacket = readUInt32LE(data, offset);
                offset += 4;
                int currentPacketLength = readUInt32LE(data, offset);
                offset += 4;
                long timestamp = readUInt64LE(data, offset);
                offset += 8;

                // 更新包计数器
                currentFilePackets = totalPackets;
                receivedPackets = currentPacket;


                recordLog(String.format("File packet %d/%d received, size: %d bytes",
                        currentPacket, totalPackets, currentPacketLength));

                // 实时更新下载进度到按钮
                if (isDownloadingFiles && currentDownloadIndex < selectedFiles.size()) {
                    FileInfo currentFile = selectedFiles.get(currentDownloadIndex);
                    updateDownloadButtonProgress(currentDownloadIndex + 1, selectedFiles.size(),
                            String.format("%s (%d/%d)", currentFile.fileName, currentPacket, totalPackets));
                }


                // 保存文件数据
                if (isDownloadingFiles && currentDownloadIndex < selectedFiles.size()) {
                    FileInfo currentFile = selectedFiles.get(currentDownloadIndex);

                    byte[] contentDataByte=new byte[data.length - 4-17];
                    System.arraycopy(data, 21, contentDataByte, 0, contentDataByte.length);
                    List<String[]> contentQingHua = LmApiDataUtils.fileContentQingHua(contentDataByte);
                    //生成csv文件
                    String fileName = currentFile.fileName;

                    CsvWriter.appendToOptimizedCsv(RingFileListActivity.this,fileName,contentQingHua);

                    // 检查是否是最后一个包
                    if (currentPacket >= totalPackets) {
                        recordLog("File download completed: " + fileName);

                        // 显示文件完成状态
                        updateDownloadButtonProgress(currentDownloadIndex + 1, selectedFiles.size(),
                                fileName + " ✓ 结束");

                        // 文件下载完成，处理下一个文件
                        currentDownloadIndex++;

                        // 短暂显示完成状态后开始下一个文件
                        mainHandler.postDelayed(() -> downloadNextSelectedFile(), 800);
                    }
                }
            }
        } catch (Exception e) {
            recordLog("Failed to handle file data: " + e.getMessage());
            e.printStackTrace();
        }
    }



    private void updateDownloadButtonProgress(int currentFileIndex, int totalFiles, String statusText) {
        mainHandler.post(() -> {
            if (downloadSelectedButton != null) {
                String buttonText = String.format("下载中 %d/%d\n%s",
                        currentFileIndex, totalFiles, statusText);
                downloadSelectedButton.setText(buttonText);
                downloadSelectedButton.setEnabled(false);
            }
        });
    }

    private void updateDownloadButtonFinish(){
        mainHandler.post(() -> {
            downloadSelectedButton.setText("下载选中 (" + selectedFiles.size() + ")");
            downloadSelectedButton.setEnabled(true);
        });
    }

    private void downloadAllFiles(){
        try {

            LmAPI.DOWNLOAD_ALL_FILES(fileResponseCallback);
        } catch (Exception e) {
            recordLog("Download file failed: " + e.getMessage());
        }
    }
    private void downloadSelectedFiles() {
        if (selectedFiles.isEmpty()) {
            Toast.makeText(this, "请先选择要下载的文件", Toast.LENGTH_SHORT).show();
            return;
        }

        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, "设备未连接", Toast.LENGTH_SHORT).show();
            return;
        }

        isDownloadingFiles = true;
        currentDownloadIndex = 0;
        currentFilePackets = 0;
        receivedPackets = 0;

        recordLog(String.format("[开始批量下载]所选文件: %d", selectedFiles.size()));
//
        // 更新按钮显示初始状态
        updateDownloadButtonProgress(0, 0, "正在初始化...");

        downloadNextSelectedFile();
    }


    private void downloadNextSelectedFile() {
        if (currentDownloadIndex >= selectedFiles.size()) {
            // 所有文件下载完成
            isDownloadingFiles = false;
            mainHandler.post(() -> {
                downloadSelectedButton.setText("下载选中 (" + selectedFiles.size() + ")");
                downloadSelectedButton.setEnabled(true);
                Toast.makeText(this, "所有文件已下载", Toast.LENGTH_SHORT).show();
            });
            return;
        }

        FileInfo fileInfo = selectedFiles.get(currentDownloadIndex);
        recordLog(String.format("正在下载文件 %d/%d: %s",
                currentDownloadIndex + 1, selectedFiles.size(), fileInfo.fileName));

        // 重置当前文件的包计数器
        currentFilePackets = 0;
        receivedPackets = 0;

        // 更新按钮显示
        updateDownloadButtonProgress(currentDownloadIndex + 1, selectedFiles.size(),
                "开始 " + fileInfo.fileName + "...");

        try {

           CsvWriter.clearOutputFile(RingFileListActivity.this, fileInfo.fileName);

            byte[] fileNameBytes = fileInfo.fileName.getBytes("UTF-8");
            LmAPI.DOWNLOAD_FILE(fileNameBytes,fileResponseCallback);
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

        CheckBox checkBox = new CheckBox(this);
        checkBox.setButtonTintList(ColorStateList.valueOf(Color.parseColor("#4C56F5")));
        checkBox.setChecked(fileInfo.isSelected);
        checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
            fileInfo.isSelected = isChecked;
            updateSelectedFiles();
        });

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

        fileItem.addView(checkBox);
        fileItem.addView(fileInfoLayout);

        fileItem.setOnClickListener(v -> {
            checkBox.setChecked(!checkBox.isChecked());
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
            fileListStatus.setText(String.format("所有 %d 文件, %d 已选择", fileList.size(), selectedFiles.size()));

            // 只有在不下载时才更新按钮文本
            if (!isDownloadingFiles) {
                downloadSelectedButton.setText("下载所选内容 (" + selectedFiles.size() + ")");
                downloadSelectedButton.setEnabled(selectedFiles.size() > 0);
            }
        });
    }

    // ==================== Exercise Control ====================

    private void startExercise() {
        if (!BLEUtils.isGetToken()) {
            Toast.makeText(this, "设备未连接", Toast.LENGTH_SHORT).show();
            return;
        }

        if (isExercising) {
            Toast.makeText(this, "进行中", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            String totalDurationStr = exerciseTotalDurationInput.getText().toString().trim();
            String segmentDurationStr = exerciseSegmentDurationInput.getText().toString().trim();

            if (totalDurationStr.isEmpty() || segmentDurationStr.isEmpty()) {
                Toast.makeText(this, "请输入锻炼持续时间和持续时间", Toast.LENGTH_SHORT).show();
                return;
            }

            int totalDuration = Integer.parseInt(totalDurationStr);
            int segmentDuration = Integer.parseInt(segmentDurationStr);

            if (totalDuration < 60 || totalDuration > 86400) {
                Toast.makeText(this, "总锻炼时间应在60-86400秒之间", Toast.LENGTH_SHORT).show();
                return;
            }

            if (segmentDuration < 30 || segmentDuration > totalDuration) {
                Toast.makeText(this, "持续时间应在30秒和总持续时间之间", Toast.LENGTH_SHORT).show();
                return;
            }

            NotificationHandler.setExerciseParams(totalDuration, segmentDuration);
            boolean success = NotificationHandler.startExercise();

            if (success) {
                isExercising = true;
                recordLog(String.format("[开始运动] 总共: %d , 进行: %d ", totalDuration, segmentDuration));
                updateExerciseUI(true);
                updateExerciseStatus(String.format("运动战 - 总共: %d min, 进行: %d min", totalDuration/60, segmentDuration/60));
                Toast.makeText(this, "运动开始", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "开始运动失败", Toast.LENGTH_SHORT).show();
            }

        } catch (NumberFormatException e) {
            Toast.makeText(this, "请输入有效数字", Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            recordLog("开始运动失败: " + e.getMessage());
            Toast.makeText(this, "开始运动失败: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void stopExercise() {
        if (!isExercising) {
            Toast.makeText(this, "目前没有正在进行的运动", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            boolean success = NotificationHandler.stopExercise();
            if (success) {
                isExercising = false;
                recordLog("[结束运动]用户手动停止");
                updateExerciseUI(false);
                updateExerciseStatus("已停止");
                Toast.makeText(this, "运动停止", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "无法停止运动", Toast.LENGTH_SHORT).show();
            }
        } catch (Exception e) {
            recordLog("无法停止运动: " + e.getMessage());
            Toast.makeText(this, "无法停止运动: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void updateExerciseUI(boolean exercising) {
        if (startExerciseButton != null) {
            startExerciseButton.setEnabled(!exercising);
            startExerciseButton.setText(exercising ? "运动中..." : "开始运动");
        }

        if (stopExerciseButton != null) {
            stopExerciseButton.setEnabled(exercising);
            stopExerciseButton.setBackgroundColor(exercising ? Color.parseColor("#F44336") : Color.GRAY);
        }
    }

    private void updateExerciseStatus(String status) {
        if (exerciseStatusText != null) {
            exerciseStatusText.setText("运动状态: " + status);
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

                mainHandler.post(() -> {
                    updateBatchDownloadProgress("收到: " + fileName);
                });

            }

        } catch (Exception e) {
            recordLog("处理批处理文件信息时出错: " + e.getMessage());
            e.printStackTrace();
        }
    }
    private void  handleFileDownloadEndResponse(byte[] data) {
        try {

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
    private boolean handleBatchFileDataPush(byte[] data) {

        if (currentBatchFile == null) {
            recordLog("已收到文件数据，但没有当前批处理文件");
            return false;
        }

        try {
            byte[] fileData = Arrays.copyOfRange(data, 4, data.length);
            currentBatchFile.fileDataPackets.add(fileData);
            currentBatchFile.receivedPackets++;
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
        try {

            String safeFileName = fileInfo.fileName.replace(":", "_");

            for (int i = 0; i < fileInfo.fileDataPackets.size(); i++) {
                byte[] packetData = fileInfo.fileDataPackets.get(i);
                byte[] contentDataByte=new byte[packetData.length -17];
                System.arraycopy(packetData, 17, contentDataByte, 0, contentDataByte.length);
                List<String[]> contentQingHua = LmApiDataUtils.fileContentQingHua(contentDataByte);
                CsvWriter.appendToOptimizedCsv(RingFileListActivity.this,safeFileName,contentQingHua);
            }

        } catch (Exception e) {
            recordLog("保存硬件批处理文件失败: " + e.getMessage());
            e.printStackTrace();
        }
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

            ToastUtils.show("操作成功");
            updateBatchDownloadProgress("已完成: " + receivedBatchFiles.size() + " 文件");
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
                        Toast.makeText(this, "设备正忙，请稍后再试", Toast.LENGTH_SHORT).show();
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
                    mainHandler.post(() -> {
                        Toast.makeText(this, "硬件批量下载已完成", Toast.LENGTH_SHORT).show();
                    });
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
        if (downloadAll != null) {
            downloadAll.setText("下载进度" + status);
        }
    }

    private void resetHardwareBatchDownloadState() {
        isHardwareBatchDownloading = false;
        currentBatchFile = null;

        mainHandler.post(() -> {
            if (downloadAll != null) {
                downloadAll.setText(R.string.download_all);
                downloadAll.setEnabled(true);
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
        new android.app.AlertDialog.Builder(this)
                .setTitle("格式化文件系统")
                .setMessage("警告：此操作将永久删除设备中的所有文件数据！\n" +
                        "\n" +
                        "您确定要继续格式化吗？")
                .setIcon(android.R.drawable.ic_dialog_alert)
                .setPositiveButton("确认格式化", (dialog, which) -> {
                    performFormatFileSystem();
                })
                .setNegativeButton("Cancel", null)
                .show();
    }
    private void performFormatFileSystem() {
        try {
            LmAPI.PERFORM_FORMAT_FILESYSTEM(fileResponseCallback);
        } catch (Exception e) {
            e.printStackTrace();


        }
    }
    private void initView() {
        offlineLayout = (ScrollView) findViewById(R.id.offlineLayout);
        exerciseTotalDurationInput = (EditText) findViewById(R.id.exerciseTotalDurationInput);
        exerciseSegmentDurationInput = (EditText) findViewById(R.id.exerciseSegmentDurationInput);
        exerciseStatusText = (TextView) findViewById(R.id.exerciseStatusText);
        startExerciseButton = (Button) findViewById(R.id.startExerciseButton);
        stopExerciseButton = (Button) findViewById(R.id.stopExerciseButton);
        fileListStatus = (TextView) findViewById(R.id.fileListStatus);
        getFileListButton = (Button) findViewById(R.id.getFileListButton);
        formatFileSystemButton = (Button) findViewById(R.id.formatFileSystemButton);
        fileListContainer = (LinearLayout) findViewById(R.id.fileListContainer);
        downloadSelectedButton = (Button) findViewById(R.id.downloadSelectedButton);
        downloadAll = (Button) findViewById(R.id.downloadAll);
    }

    private void setupClickListeners() {

        getFileListButton.setOnClickListener(v -> getFileList());
        downloadSelectedButton.setOnClickListener(v -> downloadSelectedFiles());
        downloadAll.setOnClickListener(v-> downloadAllFiles());
        formatFileSystemButton.setOnClickListener(v-> formatFileSystem());

        // Exercise control buttons
        if (startExerciseButton != null) {
            startExerciseButton.setOnClickListener(v -> startExercise());
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

}