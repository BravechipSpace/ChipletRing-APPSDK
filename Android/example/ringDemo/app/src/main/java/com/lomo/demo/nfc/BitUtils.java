package com.lomo.demo.nfc;

public class BitUtils {

    // 辅助方法：字节数组转Hex
    public  static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /**
     * 将Hex字符串转换为字节数组
     * @param hexStr 十六进制字符串（如 "3a7d4f8e1c9b2a6f5d8e3c1a7b2f4e6"）
     * @return 对应的字节数组
     * @throws IllegalArgumentException 如果输入不是有效的Hex字符串
     */
    public static byte[] hexToBytes(String hexStr) {
        if (hexStr == null || hexStr.length() % 2 != 0) {
            throw new IllegalArgumentException("Invalid Hex String");
        }

        byte[] bytes = new byte[hexStr.length() / 2];
        for (int i = 0; i < hexStr.length(); i += 2) {
            String byteStr = hexStr.substring(i, i + 2);
            bytes[i / 2] = (byte) Integer.parseInt(byteStr, 16);
        }
        return bytes;
    }

}
