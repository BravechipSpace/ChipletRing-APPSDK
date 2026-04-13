package com.lomo.demo;


import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.lm.sdk.library.utils.TimeUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.Date;
import java.util.concurrent.locks.ReentrantLock;

public class ImageSaverUtilLib {
    private static ReentrantLock lock = new ReentrantLock();
    // 写入sd卡需要保证线程使用
    public static void saveImageToInternalStorage(Context context, String data, String folderName, String name,boolean isAppend) {
        try {
            if (context == null) {
                return;
            }

            new Thread(() -> {
                lock.lock();
                String savedImagePath = null;
//            String sdCard;
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                sdCard= context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
//            }else{
//                sdCard= Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
//            }
//            FileUtil.getSDPath()

                if (Build.VERSION.SDK_INT >= 29) {
//                File folder = new File(sdCard, folderName);
                    String sdPath = FileUtil.getSDPath(context, folderName);
                    if(sdPath==null){
                        return;
                    }
                    File folder = new File(sdPath);
                    if (!folder.exists()) {
                        folder.mkdirs();
                    }
                    try {
                        // Create a request to save the image to the app's internal storage
                        File imageFile = new File(folder, folderName + name);
                        if (!imageFile.getParentFile().exists()) {
                            imageFile.getParentFile().mkdirs();
                            imageFile.createNewFile();
                        }
//                        //大于1M就删除
//                        double fileSize = FileUtil.getFileSize(imageFile, ConstUtils.MemoryUnit.MB);
//                        if (fileSize > 5) {
//                            try {
//                                imageFile.delete();
//                                imageFile.createNewFile();
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                            }
//
//                        }
//                    File imageFile = new File(folder,   DateUtils.getCurrentDay()+"-"+name);
                        FileOutputStream outStream = new FileOutputStream(imageFile.getAbsolutePath(), isAppend);
                        OutputStreamWriter outputStream = new OutputStreamWriter(outStream, "utf-8");
                        outputStream.write(TimeUtils.date2String(new Date()));
                        outputStream.write("=");
                        outputStream.write(data);
                        outputStream.write("\n");
                        outputStream.flush();
                        // Close the streams
                        outputStream.close();

                        savedImagePath = imageFile.getAbsolutePath();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    // Use the Scoped Storage APIs on Android 12 and higher
//                Log.d("ImageSaver", "Saved image to path: " + savedImagePath);
                }
                lock.unlock();

            }).start();
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    //删除
    public static void deleteFile(Context context,  String folderName, String name) {
        try {
            String sdPath = FileUtil.getSDPath(context, folderName);
            File folder = new File(sdPath);

            File imageFile = new File(folder, folderName + name);
            imageFile.delete();
        } catch (Exception e) {
            Log.e("TAG", "删除报错！！！: " + e.toString());
        }

    }

    //每次写入前有需要可以先把文件清空
    private static boolean deleteFiles(File file) {
        try {
            if (file.isDirectory()) { //判断是否是文件夹
                File[] files = file.listFiles();//遍历文件夹里面的所有的
                for (int i = 0; i < files.length; i++) {
                    Log.e("TAG", "删除文件>>>>>> " + files[i].toString());
                    deleteFiles(files[i]); //删除
                }
            } else {
                boolean delete = file.delete();
                System.out.println(delete);
            }
            System.gc();//系统回收垃圾
            return true;
        } catch (Exception e) {
            Log.e("TAG", "删除报错！！！: " + e.toString());
            return false;

        }

    }
}


