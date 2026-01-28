package com.lomo.demo.file;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import java.io.File;

public class FileUtils {

    public static File uriToFile(Context context, Uri uri) {
        if (uri == null) return null;

        // 检查是否是文件类型的 Uri
        if ("file".equalsIgnoreCase(uri.getScheme())) {
            return new File(uri.getPath());
        }

        // 对于 content:// 类型的 Uri
        String filePath = null;
        if ("content".equalsIgnoreCase(uri.getScheme())) {
            String[] projection = { MediaStore.Images.Media.DATA };
            Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                filePath = cursor.getString(columnIndex);
                cursor.close();
            }
        }

        return filePath != null ? new File(filePath) : null;
    }

    /**
     * 蓝牙文件系统，根据后缀名，区分类别
     * @param fileName
     * @return
     */
    public static String getFileType(String fileName) {
        // 去掉文件扩展名
        String withoutExtension = fileName.substring(0, fileName.lastIndexOf(".bin"));
        // 分割字符串
        String[] parts = withoutExtension.split("_");
        // 获取最后一个部分
        String result = parts[parts.length - 1];
        System.out.println("getFileType:" + result);
        return result==null?"":result;
    }
}
