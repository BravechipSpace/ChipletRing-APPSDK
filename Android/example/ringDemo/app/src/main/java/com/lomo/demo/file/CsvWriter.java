package com.lomo.demo.file;

import android.content.Context;
import android.widget.Toast;

import com.lm.sdk.utils.FileUtil;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class CsvWriter {
    private static final String[] HEADERS = {"time","greenData", "redData", "irData", "accX", "accY","accZ", "gyroX", "gyroY", "gyroZ", "temper0", "temper1", "temper2"};

    public static void appendToOptimizedCsv(Context context, String fileName, List<String[]> data) {


        File file = getOutputFile(context, fileName);

        // 使用try-with-resources确保资源自动关闭
        try (FileOutputStream fos = new FileOutputStream(file, true);
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fos, StandardCharsets.UTF_8))) {

            // 写入表头（如果需要）
            writeHeaderIfNeeded(writer, file);

            // 写入数据行（优化后的写入逻辑）
            writeDataRows(writer, data);

        } catch (Exception e) {
            handleError(context, e);
        }
    }

    public static File getOutputFile(Context context, String fileName) {
        if(fileName.contains(".bin")){
            fileName=fileName.split(".bin")[0];
        }
        String sdPath = FileUtil.getSDPath(context, "FileList");
        File directory = new File(sdPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }
        String safeFileName = fileName + ".csv";
        return new File(directory, safeFileName);
    }

    public static void clearOutputFile(Context context, String fileName) {
      File outputFile=  getOutputFile(context,fileName);
        if(outputFile.length()>0){//如果数据不为空，清空数据，防止叠加上一次下载的数据
            try (FileWriter writer = new FileWriter(outputFile, false)) {
                writer.write(""); // 写入空字符串
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

//    public static void clearOutputFile(Context context) {
//
//        String sdPath = FileUtil.getSDPath(context, "FileList");
//        File directory = new File(sdPath);
//        deleteFolder(directory);
//
//    }
    public static boolean deleteFolder(File folder) {
        if (folder != null && folder.exists()) {
            File[] files = folder.listFiles();
            if (files != null) {
                for (File file : files) {
                    if (file.isDirectory()) {
                        deleteFolder(file);  // 递归删除子目录
                    } else {
                        file.delete();      // 删除文件
                    }
                }
            }
            return folder.delete();  // 最后删除空文件夹本身
        }
        return false;
    }
    private static void writeHeaderIfNeeded(BufferedWriter writer, File file) throws IOException {
        if (file.length() == 0 || !file.exists()) {
            writer.write(String.join(",", HEADERS));
            writer.write('\n');
        }
    }

    private static void writeDataRows(BufferedWriter writer, List<String[]> data) throws IOException {
        StringBuilder csvLine = new StringBuilder(256);
        for (String[] row : data) {
            csvLine.setLength(0);

            for (int i = 0; i < row.length; i++) {
                if (i > 0) csvLine.append(',');

                String field = row[i] != null ? row[i] : "";
                if (needsQuoting(field)) {
                    csvLine.append('"').append(field.replace("\"", "\"\"")).append('"');
                } else {
                    csvLine.append(field);
                }
            }

            writer.write(csvLine.toString());
            writer.write('\n');
        }
    }

    private static boolean needsQuoting(String field) {
        return field.indexOf(',') != -1 ||
                field.indexOf('\n') != -1 ||
                field.indexOf('"') != -1 ||
                field.indexOf('\r') != -1;
    }

    private static void handleError(Context context, Exception e) {
        e.printStackTrace();
        if (context != null) {
            Toast.makeText(context, "CSV写入失败: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}