package com.lomo.demo.nfc;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

/**
 * @author Sunshine
 * @Description 转换相关工具类
 */
public class ConvertUtils {

    static final char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

    /**
     * byteArr转hexString
     * <p>例如：</p>
     * bytes2HexString(new byte[] { 0, (byte) 0xa8 }) returns 00A8
     *
     * @param bytes byte数组
     * @return 16进制大写字符串
     */
    public static String bytes2HexString(byte[] bytes) {
        char[] res = new char[bytes.length << 1];
        for (int i = 0, j = 0; i < bytes.length; i++) {
            res[j++] = hexDigits[bytes[i] >>> 4 & 0x0f];
            res[j++] = hexDigits[bytes[i] & 0x0f];
        }
        return new String(res);
    }

    /**
     * hexString转byteArr
     * <p>例如：</p>
     * hexString2Bytes("00A8") returns { 0, (byte) 0xA8 }
     *
     * @param hexString 十六进制字符串
     * @return 字节数组
     */
    public static byte[] hexString2Bytes(String hexString) {
        int len = hexString.length();
        if (len % 2 != 0) {
            throw new IllegalArgumentException("长度不是偶数");
        }
        char[] hexBytes = hexString.toUpperCase().toCharArray();
        byte[] res = new byte[len >>> 1];
        for (int i = 0; i < len; i += 2) {
            res[i >> 1] = (byte) (hex2Dec(hexBytes[i]) << 4 | hex2Dec(hexBytes[i + 1]));
        }
        return res;
    }

    /**
     * hexChar转int
     *
     * @param hexChar hex单个字节
     * @return 0..15
     */
    private static int hex2Dec(char hexChar) {
        if (hexChar >= '0' && hexChar <= '9') {
            return hexChar - '0';
        } else if (hexChar >= 'A' && hexChar <= 'F') {
            return hexChar - 'A' + 10;
        } else {
            throw new IllegalArgumentException();
        }
    }

    /**
     * charArr转byteArr
     *
     * @param chars 字符数组
     * @return 字节数组
     */
    public static byte[] chars2Bytes(char[] chars) {
        int len = chars.length;
        byte[] bytes = new byte[len];
        for (int i = 0; i < len; i++) {
            bytes[i] = (byte) (chars[i]);
        }
        return bytes;
    }

    /**
     * byteArr转charArr
     *
     * @param bytes 字节数组
     * @return 字符数组
     */
    public static char[] bytes2Chars(byte[] bytes) {
        int len = bytes.length;
        char[] chars = new char[len];
        for (int i = 0; i < len; i++) {
            chars[i] = (char) (bytes[i] & 0xff);
        }
        return chars;
    }



    /**
     * 把一个整形改为4位的byte数组
     *
     * @param value
     * @return
     * @throws Exception
     */
    public static byte[] longTo8Bytes(long value) {
        byte[] result = new byte[8];
        result[7] = (byte) ((value >>> 56) & 0xFF);
        result[6] = (byte) ((value >>> 48) & 0xFF);
        result[5] = (byte) ((value >>> 40) & 0xFF);
        result[4] = (byte) ((value >>> 32) & 0xFF);
        result[3] = (byte) ((value >>> 24) & 0xFF);
        result[2] = (byte) ((value >>> 16) & 0xFF);
        result[1] = (byte) ((value >>> 8) & 0xFF);
        result[0] = (byte) (value & 0xFF);
        return result;
    }

    /**
     * 把一个整形改为4位的byte数组
     *
     * @param value
     * @return
     * @throws Exception
     */
    public static byte[] longTo4Bytes(long value) {
        byte[] result = new byte[4];
        result[3] = (byte) ((value >>> 24) & 0xFF);
        result[2] = (byte) ((value >>> 16) & 0xFF);
        result[1] = (byte) ((value >>> 8) & 0xFF);
        result[0] = (byte) (value & 0xFF);
        return result;
    }


    /**
     * bitmap转byteArr
     *
     * @param bitmap bitmap对象
     * @param format 格式
     * @return 字节数组
     */
    public static byte[] bitmap2Bytes(Bitmap bitmap, Bitmap.CompressFormat format) {
        if (bitmap == null) return null;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(format, 100, baos);
        return baos.toByteArray();
    }

    /**
     * byteArr转bitmap
     *
     * @param bytes 字节数组
     * @return bitmap对象
     */
    public static Bitmap bytes2Bitmap(byte[] bytes) {
        return (bytes == null || bytes.length == 0) ? null : BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }

    /**
     * drawable转bitmap
     *
     * @param drawable drawable对象
     * @return bitmap对象
     */
    public static Bitmap drawable2Bitmap(Drawable drawable) {
        return drawable == null ? null : ((BitmapDrawable) drawable).getBitmap();
    }

    /**
     * bitmap转drawable
     *
     * @param resources resources对象
     * @param bitmap    bitmap对象
     * @return drawable对象
     */
    public static Drawable bitmap2Drawable(Resources resources, Bitmap bitmap) {
        return bitmap == null ? null : new BitmapDrawable(resources, bitmap);
    }

    /**
     * drawable转byteArr
     *
     * @param drawable drawable对象
     * @param format   格式
     * @return 字节数组
     */
    public static byte[] drawable2Bytes(Drawable drawable, Bitmap.CompressFormat format) {
        return bitmap2Bytes(drawable2Bitmap(drawable), format);
    }

    /**
     * byteArr转drawable
     *
     * @param resources resources对象
     * @param bytes     字节数组
     * @return drawable对象
     */
    public static Drawable bytes2Drawable(Resources resources, byte[] bytes) {
        return bitmap2Drawable(resources, bytes2Bitmap(bytes));
    }

    /**
     * 将 long 转换为小端字节数组
     * @param value
     * @return
     */
    public static byte[] longToBytesLittleEndian(long value) {
        byte[] bytes = new byte[8];  // long 是 8 字节
        for (int i = 0; i < 8; i++) {
            bytes[i] = (byte) (value >>> (i * 8));  // 获取每个字节
        }
        return bytes;
    }
    /**
     * dp转px
     *
     * @param context 上下文
     * @param dpValue dp值
     * @return px值
     */
    public static int dp2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * px转dp
     *
     * @param context 上下文
     * @param pxValue px值
     * @return dp值
     */
    public static int px2dp(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    /**
     * sp转px
     *
     * @param context 上下文
     * @param spValue sp值
     * @return px值
     */
    public static int sp2px(Context context, float spValue) {
        final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
        return (int) (spValue * fontScale + 0.5f);
    }

    /**
     * px转sp
     *
     * @param context 上下文
     * @param pxValue px值
     * @return sp值
     */
    public static int px2sp(Context context, float pxValue) {
        final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
        return (int) (pxValue / fontScale + 0.5f);
    }
    /**
     * 把一个整形改为4位的byte数组
     *
     * @param value
     * @return
     * @throws Exception
     */
    public static byte[] integerTo4Bytes(int value) {
        byte[] result = new byte[4];
        result[0] = (byte) ((value >>> 24) & 0xFF);
        result[1] = (byte) ((value >>> 16) & 0xFF);
        result[2] = (byte) ((value >>> 8) & 0xFF);
        result[3] = (byte) (value & 0xFF);
        return result;
    }

    // 将整数转换为byte数组
    public static byte[] intToByteArray(int number) {
        ByteBuffer buffer = ByteBuffer.allocate(4);  // 分配一个长度为4的字节缓冲区
        buffer.putInt(number);  // 将整数放入缓冲区
        return buffer.array();  // 返回byte数组
    }
    /**
     * 把一个整形改为3位的byte数组
     *
     * @param value
     * @return
     * @throws Exception
     */
    public static byte[] integerTo3Bytes(int value) {

        byte[] result = new byte[3];
        result[0] = (byte) ((value >>> 16) & 0xFF);
        result[1] = (byte) ((value >>> 8) & 0xFF);
        result[2] = (byte) (value & 0xFF);
        return result;
    }
    public static long BytesToLong(byte[] buffer) {
        long  values = 0;
        for (int i = buffer.length-1; i >= 0; i--) {
            values <<= 8; values|= (buffer[i] & 0xff);
        }
        return values;
    }

    public static long fourBytesToLongLittleEndian(byte[] buffer) {

        return (buffer[0] & 0xFFL) |
                ((buffer[1] & 0xFFL) << 8) |
                ((buffer[2] & 0xFFL) << 16) |
                ((buffer[3] & 0xFFL) << 24);
    }

    public static int BytesToInt(byte[] buffer) {
        int  values = 0;
        for (int i = buffer.length-1; i >=0 ; i--) {
            values <<= 8; values|= (buffer[i] & 0xff);
        }
        return values;
    }
    /**
     * 把一个3位的数组转化位整形
     *
     * @param value
     * @return
     * @throws Exception
     */
    public static int threeBytesToInteger(byte[] value) {
        int temp0 = value[0] & 0xFF;
        int temp1 = value[1] & 0xFF;
        int temp2 = value[2] & 0xFF;
        return ((temp0 << 16) + (temp1 << 8) + temp2);
    }

    public static int getHeight4(byte data){//获取高四位
        int height;
        height = ((data & 0xf0) >> 4);
        return height;
    }
    public static int getLow4(byte data){//获取低四位
        int low;
        low = (data & 0x0f);
        return low;
    }

    // 将16进制字符串转换为字节数组
    public static byte[] hexStringToByteArray(String hexString) {
        int len = hexString.length();
        byte[] byteArray = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            byteArray[i / 2] = (byte) Integer.parseInt(hexString.substring(i, i + 2), 16);
        }
        return byteArray;
    }
    // 将二进制字符串转换为字节数组
    public static byte[] binaryStringToByteArray(String binaryString) {
        // 确保二进制字符串的长度是8的倍数
        if (binaryString.length() % 8 != 0) {
            throw new IllegalArgumentException("Binary string length must be a multiple of 8.");
        }

        int length = binaryString.length();
        byte[] byteArray = new byte[length / 8];

        for (int i = 0; i < length; i += 8) {
            // 获取每8位作为一个字节
            String byteString = binaryString.substring(i, i + 8);
            // 将二进制字符串转换为字节
            byteArray[i / 8] = (byte) Integer.parseInt(byteString, 2);
        }

        return byteArray;
    }
    // 反转字节数组，处理小端模式
    public static void reverseByteArray(byte[] byteArray) {
        int i = 0;
        int j = byteArray.length - 1;
        while (i < j) {
            byte temp = byteArray[i];
            byteArray[i] = byteArray[j];
            byteArray[j] = temp;
            i++;
            j--;
        }
    }

    // 将二进制字符串转换为十进制整数
    public static int binaryStringToDecimal(String binaryString) {
        // 使用 Integer.parseInt() 方法将二进制字符串转换为十进制数
        return Integer.parseInt(binaryString, 2);
    }

    public static short[] byteArrayToShortArray(byte[] byteArray) {
        int length = byteArray.length;
        // 如果字节数组的长度是奇数，末尾将丢弃一个字节
        int shortArrayLength = length / 2;

        short[] shortArray = new short[shortArrayLength];

        for (int i = 0, j = 0; i < length; i += 2, j++) {
            // 将两个字节组合成一个 short（假设是大端字节序）
            shortArray[j] = (short) (((byteArray[i] & 0xFF) << 8) | (byteArray[i + 1] & 0xFF));
        }

        return shortArray;
    }


    /**
     * 字符转byte
     *
     * @param values 字符列表
     * @return
     */
    public static byte[] valueListConvertToBytes(int cmd, List<byte[]> values) {
        byte[] bytes = ConvertUtils.mergeByteArrays(values);
        byte[] data = new byte[4 + bytes.length];
        data[0] = 0x00;
        data[1] = (byte) new Random().nextInt(254);
        data[2] = (byte) cmd;
        data[3] = 0x03;
        System.arraycopy(bytes, 0, data, 4, bytes.length);
        return data;
    }

    public static byte[] mergeByteArrays(List<byte[]> values) {
        // 计算所有字节数组的总长度
        int totalLength = 0;
        for (byte[] array : values) {
            totalLength += array.length;
        }

        // 创建一个足够大的数组来存储所有字节
        byte[] result = new byte[totalLength];
        int currentPosition = 0;

        // 将每个字节数组复制到目标数组中
        for (byte[] array : values) {
            System.arraycopy(array, 0, result, currentPosition, array.length);
            currentPosition += array.length;
        }

        return result;
    }

    /**
     * 将一个整数转换为 2 位字节数组
     * @param number 要转换的整数
     * @return 转换后的 2 字节数组
     */
    public static byte[] intToTwoByteArray(int number) {
        byte[] byteArray = new byte[2];

        // 小端模式：低字节在前，高字节在后
        byteArray[0] = (byte) (number & 0xFF);  // 低字节
        byteArray[1] = (byte) ((number >> 8) & 0xFF);  // 高字节

        return byteArray;
    }

    //将字节字符串按长度8分解成数组
    public static byte[][] splitBytes(byte[] data) {
        if (data == null || data.length == 0) {
            return new byte[0][];
        }

        int length = data.length;
        int chunkSize = 8;
        int numOfChunks = (length + chunkSize - 1) / chunkSize;
        byte[][] result = new byte[numOfChunks][];

        for (int i = 0; i < numOfChunks; i++) {
            int start = i * chunkSize;
            int end = Math.min(start + chunkSize, length);
            result[i] = Arrays.copyOfRange(data, start, end);
        }

        return result;
    }
}
