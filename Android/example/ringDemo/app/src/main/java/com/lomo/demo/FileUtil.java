package com.lomo.demo;

import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.text.TextUtils;

import androidx.core.content.FileProvider;

import com.lomo.demo.application.App;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * 文件工具类 其他应用接受到升级文件时可以通过PhyOTA直接打开。
 */
public class FileUtil {
    private static final String FOLDER_NAME = "PhyOTA";
    private static final String FOLDER_TEST_NAME = "Test logs";
    private static final String TAG = FileUtil.class.getSimpleName();
    private static FileUtil mInstance;
    private static Context mContext;

    public FileUtil(Context context) {
        mContext = context;
    }

    public static FileUtil getInstance(Context context) {
        if (mInstance == null) {
            synchronized (FileUtil.class) {
                if (mInstance == null) {
                    mInstance = new FileUtil(context);
                }
            }
        }
        return mInstance;
    }
    /**
     * 获取SDCard文件路径
     * @param ctx
     * @return
     */
    public static String getSDPath(Context ctx,String fileName) {
       return getSDPath(ctx,"",fileName);
    }
    public static String getSDPath(Context ctx,String path,String fileName) {
        if(ctx==null){
            ctx = App.getInstance();
        }
        File sdDir = null;
        boolean sdCardExist = Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED);// 判断sd卡是否存在
        if (sdCardExist) {
            if (Build.VERSION.SDK_INT >= 29) {
                //Android10之后
                sdDir = ctx.getExternalFilesDir(null);
//                sdDir=  ctx.getExternalCacheDir();
            } else {
                sdDir= Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            }
        } else {
            sdDir = Environment.getRootDirectory();// 获取跟目录
        }
        if(!TextUtils.isEmpty(fileName)){
            if(!TextUtils.isEmpty(path))
                return sdDir.toString()+path+"/"+fileName;
            return sdDir.toString()+"/"+fileName;
        }
        if(!TextUtils.isEmpty(path))
            return sdDir.toString()+path;
        return sdDir.toString();
    }

    //将输入流的数据拷贝到输出流
    public static void write(InputStream is, OutputStream os) {
        byte[] buffer = new byte[1024 * 1024];
        while (true) {
            try {
                int len = is.read(buffer);
                if (len < 0) break;
                os.write(buffer, 0, len);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        try {
            os.flush();
            is.close();
            os.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Uri getUri(String filePath) {
        File tempFile = new File(filePath);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                return FileProvider.getUriForFile(mContext, mContext.getPackageName() + ".fileprovider", tempFile);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            return Uri.fromFile(tempFile);
        }
        return null;
    }

    public byte[] getBinFile(String filePath) {
        Uri uri = getUri(filePath);
        try {
            return streamToBytes(mContext.getContentResolver().openInputStream(uri));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int copy(final InputStream input, final OutputStream output) throws IOException {
        final long count = copyLarge(input, output);
        if (count > Integer.MAX_VALUE) {
            return -1;
        }
        return (int) count;
    }

    public static long copyLarge(final InputStream input, final OutputStream output)
            throws IOException {
        return copy(input, output, 1024 * 4);
    }

    public static long copy(final InputStream input, final OutputStream output, final int bufferSize)
            throws IOException {
        return copyLarge(input, output, new byte[bufferSize]);
    }

    public static long copyLarge(final InputStream input, final OutputStream output, final byte[] buffer)
            throws IOException {
        long count = 0;
        int n;
        while (-1 != (n = input.read(buffer))) {
            output.write(buffer, 0, n);
            count += n;
        }
        return count;
    }

    public static byte[] streamToBytes(InputStream input) {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int n = 0;
        try {
            while (-1 != (n = input.read(buffer))) {
                output.write(buffer, 0, n);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return output.toByteArray();
    }



    /**
     * 是SLB升级模式的升级文件
     */
    public boolean isSlbFile(String fileName) {
        return fileName.endsWith(".bin");
    }

    /**
     * 是Single Bank升级模式下的升级文件
     * @param fileName
     * @return
     */
    public boolean isSbhFile(String fileName) {
        return fileName.endsWith(".hex16")
                || fileName.endsWith(".hex")
                || fileName.endsWith(".hexe")
                || fileName.endsWith(".res")
                || fileName.endsWith(".hexe16");
    }

    public boolean isSbhHexFile(String fileName) {
        return fileName.endsWith(".hex16")
                || fileName.endsWith(".hex")
                || fileName.endsWith(".hexe");
    }

    public boolean isSbhResFile(String fileName) {
        return fileName.endsWith(".res");
    }

    public boolean isSbhEncryptFile(String fileName) {
        return fileName.endsWith(".hexe16");
    }

    public static String getDateTime() {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINESE).format(new Date());
    }

    private static FileCallback mFileCallback;

    public void setFileCallback(FileCallback fileCallback) {
        mFileCallback = fileCallback;
    }

    public interface FileCallback {
        void generateFileSuccess(File file);
    }

}
