package com.lomo.demo.file;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

// File Information Class
public  class FileInfo {
    public String fileName;
    public int fileSize;
    public int fileType;
    public String userId;
    public String timestamp;
    public boolean isSelected = false;

    public FileInfo(String fileName, int fileSize) {
        this.fileName = fileName;
        this.fileSize = fileSize;
        parseFileName();
    }

    private void parseFileName() {
        String[] parts = fileName.replace(".bin", "").split("_");
        if (parts.length >= 3) {
            this.userId = parts[0];
            this.timestamp = convertUTCToChinaTime(parts[1]+parts[2]+parts[3]);
            this.fileType = Integer.parseInt(parts[parts.length-1]);
        }
    }

    public String getFileTypeDescription() {
        switch (fileType) {
            case 1: return "3-Axis Data";
            case 2: return "6-Axis Data";
            case 3: return "PPG IR+Red+3-Axis (SpO2)";
            case 4: return "PPG Green";
            case 5: return "PPG IR";
            case 6: return "Temperature IR";
            case 7: return "IR+Red+Green+Temp+3-Axis";
            case 8: return "PPG Green+3-Axis (HR)";
            default: return "Unknown Type";
        }
    }

    public String getFormattedSize() {
        if (fileSize < 1024) {
            return fileSize + " B";
        } else if (fileSize < 1024 * 1024) {
            return String.format("%.1f KB", fileSize / 1024.0);
        } else {
            return String.format("%.1f MB", fileSize / (1024.0 * 1024.0));
        }
    }

    private static String convertUTCToChinaTime(String utcTimeStr) {
        try {
            if (utcTimeStr == null || utcTimeStr.length() < 15) {
                return utcTimeStr;
            }

            String dateStr = utcTimeStr.substring(0, 8);
            String timeStr = utcTimeStr.substring(9);
            String year = dateStr.substring(0, 4);
            String month = dateStr.substring(4, 6);
            String day = dateStr.substring(6, 8);
            String fullUtcTimeStr = String.format("%s-%s-%s %s", year, month, day, timeStr);

            SimpleDateFormat utcFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
            utcFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date utcDate = utcFormat.parse(fullUtcTimeStr);

            SimpleDateFormat chinaFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
            chinaFormat.setTimeZone(TimeZone.getTimeZone("Asia/Shanghai"));
            return chinaFormat.format(utcDate);

        } catch (Exception e) {
            return utcTimeStr;
        }
    }
}