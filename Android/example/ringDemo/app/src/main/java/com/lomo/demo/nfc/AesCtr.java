package com.lomo.demo.nfc;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class AesCtr {


    // 密钥
    public static final byte[] DEFAULT_KEY = {
            0x06, (byte)0xa9, 0x21, 0x40, 0x36, (byte)0xb8, (byte)0xa1, 0x5b,
            0x51, 0x2e, 0x03, (byte)0xd5, 0x34, 0x12, 0x00, 0x07
    };

    // IV
    private static final byte[] iv = {
            0x3d, (byte)0xaf, (byte)0xba, 0x42, (byte)0x9d, (byte)0x9e, (byte)0xb4, 0x30,
            (byte)0xb4, 0x22, (byte)0xda, (byte)0x80, 0x2c, (byte)0x9f, (byte)0xac, 0x41
    };


    // AES-128 CTR 加密
    public static byte[] encryptAes128Ctr( byte[] plaintext) throws Exception {
        Cipher cipher = Cipher.getInstance("AES/CTR/NoPadding");
        SecretKeySpec keySpec = new SecretKeySpec(DEFAULT_KEY, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
        return cipher.doFinal(plaintext);
    }

    // AES-128 CTR 解密
    public static byte[] decryptAes128Ctr(byte[] ciphertext) throws Exception {
        Cipher cipher = Cipher.getInstance("AES/CTR/NoPadding");
        SecretKeySpec keySpec = new SecretKeySpec(DEFAULT_KEY, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
        return cipher.doFinal(ciphertext);
    }

    // Hex 字符串转字节数组（兼容 Java 8+）
    public static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                    + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }

    // 字节数组转 Hex 字符串（兼容 Java 8+）
    public static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b));
        }
        return sb.toString();
    }

}