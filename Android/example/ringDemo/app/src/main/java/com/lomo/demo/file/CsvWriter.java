package com.lomo.demo.file;

import android.content.Context;
import android.widget.Toast;

import com.lm.sdk.utils.FileUtil;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CsvWriter {
    private static final String[] HEADERS = {"time","greenData", "redData", "irData", "accX", "accY","accZ", "gyroX", "gyroY", "gyroZ", "temper0", "temper1", "temper2"};
    private static final String[] HEADERS_GOMORE = {"TIMESTAMP","accLength", "ACC_X", "ACC_Y", "ACC_Z", "ppgLength","PPG1", "PPG2", "wristOff", "timeZoneOffset","HR"};
    private static final String[] HEADERS_SIMPLE = {"time","greenData", "redData", "irData"};

    public static void appendToOptimizedCsv(Context context, String fileName, List<String[]> data,boolean isSimple) {


        File file = getOutputFile(context, fileName,false);
        File fileGoMore = getOutputFile(context, "gomore_"+fileName,false);

        // 使用try-with-resources确保资源自动关闭
        try (FileOutputStream fos = new FileOutputStream(file, true);
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fos, StandardCharsets.UTF_8))) {

                // 写入表头（如果需要）
                writeHeaderIfNeeded(writer, file,isSimple);
                // 写入数据行（优化后的写入逻辑）
                writeDataRows(writer, data);


        } catch (Exception e) {
            handleError(context, e);
        }
        try (FileOutputStream fos = new FileOutputStream(fileGoMore, true);
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fos, StandardCharsets.UTF_8))) {


                // gomore算法
                writeHeaderIfNeededGomore(writer, fileGoMore);
                writeDataRowsGomore(writer, data);


        } catch (Exception e) {
            handleError(context, e);
        }
    }

    /**
     * 将数据缓存到本地
     * @param context
     * @param fileName
     * @param data
     */
    public static void appendToTxt(Context context, String fileName, String data) {


        File file = getOutputFile(context, fileName,true);

        // 使用try-with-resources确保资源自动关闭
        try (FileOutputStream fos = new FileOutputStream(file, true);
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fos, StandardCharsets.UTF_8))) {
            writer.write(data);


        } catch (Exception e) {
            handleError(context, e);
        }

    }

    public static String readFromTxt(Context context, String fileName) {
        File file = getOutputFile(context, fileName, true);

        if (!file.exists()) {
            return "";
        }

        StringBuilder content = new StringBuilder();
        try (FileInputStream fis = new FileInputStream(file);
             BufferedReader reader = new BufferedReader(
                     new InputStreamReader(fis, StandardCharsets.UTF_8))) {

            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line);
            }

        } catch (Exception e) {
            handleError(context, e);
            return "";
        }

        return content.toString();
    }


    public static File getOutputFile(Context context, String fileName,boolean txt) {
        if(fileName.contains(".bin")){
            fileName=fileName.split(".bin")[0];
        }
        String sdPath = FileUtil.getSDPath(context, "FileList");
        File directory = new File(sdPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }
        String safeFileName = fileName + ".csv";
        if(txt){
            safeFileName = fileName + ".txt";
        }
        return new File(directory, safeFileName);
    }

    public static void clearOutputFile(Context context, String fileName) {
      File outputFile=  getOutputFile(context,fileName,false);
        if(outputFile.length()>0){//如果数据不为空，清空数据，防止叠加上一次下载的数据
            try (FileWriter writer = new FileWriter(outputFile, false)) {
                writer.write(""); // 写入空字符串
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }



    public static void clearOutputFile(Context context) {

        String sdPath = FileUtil.getSDPath(context, "FileList");
        File directory = new File(sdPath);
        deleteFolder(directory);

    }
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
    private static void writeHeaderIfNeeded(BufferedWriter writer, File file,boolean isSimple) throws IOException {
        if (file.length() == 0 || !file.exists()) {
            if(isSimple){
                writer.write(String.join(",", HEADERS_SIMPLE));
            }else{
                writer.write(String.join(",", HEADERS));
            }

            writer.write('\n');
        }
    }

    private static void writeHeaderIfNeededGomore(BufferedWriter writer, File file) throws IOException {
        if (file.length() == 0 || !file.exists()) {

                writer.write(String.join(",", HEADERS_GOMORE));


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

    private static void writeDataRowsGomore(BufferedWriter writer, List<String[]> data) throws IOException {
        if (data == null || data.isEmpty()) {
            return;
        }

        // 按时间戳分组数据
        Map<String, List<String[]>> groupedData = new LinkedHashMap<>();

        for (String[] row : data) {
            if (row == null || row.length < 7) {
                continue;
            }

            String timestamp = row[0]; // 使用原始时间戳字符串作为分组键
            groupedData.computeIfAbsent(timestamp, k -> new ArrayList<>()).add(row);
        }

        // 处理每个时间戳分组的数据
        for (Map.Entry<String, List<String[]>> entry : groupedData.entrySet()) {
            String timestamp = entry.getKey();
            List<String[]> timeGroup = entry.getValue();

            // 转换时间戳格式
            long timestampMillis = parseFormattedDateToTimestamp(timestamp);
            String timeStr = String.valueOf(timestampMillis);

            // 初始化临时数据列表
            List<String> col2 = new ArrayList<>(); // row[4] - accX
            List<String> col3 = new ArrayList<>(); // row[5] - accY
            List<String> col4 = new ArrayList<>(); // row[6] - accZ
            List<String> col6 = new ArrayList<>(); // row[1] - greenData
            List<String> col7 = new ArrayList<>(); // row[12] - temper2
            // 收集该时间戳下的所有数据
            for (String[] row : timeGroup) {
                if (row.length >= 7) {
                    col2.add(row[4]);
                    col3.add(row[5]);
                    col4.add(row[6]);
                    col6.add(row[1]);
                    col7.add(row[12]);
                }
            }

            // 构建CSV行
            StringBuilder csvLine = new StringBuilder(256);

            // 第1个字段：时间戳
            appendQuotedField(csvLine, timeStr);
            csvLine.append(',');

            // 第2个字段：数据条数
            appendQuotedField(csvLine, String.valueOf(col2.size()));
            csvLine.append(',');

            // 第3个字段：accX数据拼接
            appendQuotedField(csvLine, String.join(",", col2));
            csvLine.append(',');

            // 第4个字段：accY数据拼接
            appendQuotedField(csvLine, String.join(",", col3));
            csvLine.append(',');

            // 第5个字段：accZ数据拼接
            appendQuotedField(csvLine, String.join(",", col4));
            csvLine.append(',');

            // 第6个字段：数据条数（重复）
            appendQuotedField(csvLine, String.valueOf(col2.size()));
            csvLine.append(',');

            // 第7个字段：greenData数据拼接
            appendQuotedField(csvLine, String.join(",", col6));
            csvLine.append(',');

            // 第8-10个字段：固定值
            appendQuotedField(csvLine, "0");
            csvLine.append(',');
            appendQuotedField(csvLine, "0");
            csvLine.append(',');
            appendQuotedField(csvLine, "240");
            csvLine.append(',');

            appendQuotedField(csvLine, String.join(",", col7));
            // 写入文件
            writer.write(csvLine.toString());
            writer.write('\n');
        }
    }

    private static void appendQuotedField(StringBuilder csvLine, String field) {
        if (field == null) {
            field = "";
        }

        // 检查是否包含长数字（可能被Excel转换为科学计数法）
        if (containsLongNumbers(field)) {
            // 在字段前添加制表符，强制Excel识别为文本
            csvLine.append('"').append('\t').append(field).append('"');
        } else if (needsQuoting(field)) {
            csvLine.append('"').append(field.replace("\"", "\"\"")).append('"');
        } else {
            csvLine.append(field);
        }
    }

    private static boolean containsLongNumbers(String field) {
        // 检查是否包含可能被Excel转换为科学计数法的长数字
        // 匹配纯数字或逗号分隔的数字串
        return field.matches("\\d{10,}") || field.matches("\\d+(,\\d+)+");
    }



    public static long parseFormattedDateToTimestamp(String formattedDate) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = sdf.parse(formattedDate);
            return date.getTime()/1000;
        } catch (ParseException e) {
            e.printStackTrace();
            return -1;
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