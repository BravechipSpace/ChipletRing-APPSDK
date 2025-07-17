package com.lomo.demo;

import android.util.Base64;

import java.nio.charset.StandardCharsets;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class AES128CTR {

    // 默认密钥
    private static final byte[] DEFAULT_KEY = {
            0x06, (byte) 0xa9, 0x21, 0x40, 0x36, (byte) 0xb8, (byte) 0xa1, 0x5b,
            0x51, 0x2e, 0x03, (byte) 0xd5, 0x34, 0x12, 0x00, 0x06
    };

    // 默认IV
    private static final byte[] DEFAULT_IV = {
            0x3d, (byte) 0xaf, (byte) 0xba, 0x42, (byte) 0x9d, (byte) 0x9e, (byte) 0xb4, 0x30,
            (byte) 0xb4, 0x22, (byte) 0xda, (byte) 0x80, 0x2c, (byte) 0x9f, (byte) 0xac, 0x41
    };

    /**
     * 加密数据
     * @param plaintext 明文数据
     * @return Base64编码的加密结果
     */
    public static String encryptToBase64(String plaintext) throws Exception {
        return encryptToBase64(plaintext, DEFAULT_KEY, DEFAULT_IV);
    }

    /**
     * 加密数据（自定义密钥和IV）
     * @param plaintext 明文数据
     * @param key 加密密钥（16字节）
     * @param iv 初始向量（16字节）
     * @return Base64编码的加密结果
     */
    public static String encryptToBase64(String plaintext, byte[] key, byte[] iv) throws Exception {
        byte[] encrypted = encrypt(plaintext.getBytes(StandardCharsets.UTF_8), key, iv);
        return Base64.encodeToString(encrypted, Base64.NO_WRAP);
    }

    /**
     * 解密数据
     * @param base64Ciphertext Base64编码的密文
     * @return 解密后的字符串
     */
    public static String decryptFromBase64(String base64Ciphertext) throws Exception {
        return decryptFromBase64(base64Ciphertext, DEFAULT_KEY, DEFAULT_IV);
    }

    /**
     * 解密数据（自定义密钥和IV）
     * @param base64Ciphertext Base64编码的密文
     * @param key 加密密钥（16字节）
     * @param iv 初始向量（16字节）
     * @return 解密后的字符串
     */
    public static String decryptFromBase64(String base64Ciphertext, byte[] key, byte[] iv) throws Exception {
        byte[] decoded = Base64.decode(base64Ciphertext, Base64.NO_WRAP);
        byte[] decrypted = decrypt(decoded, key, iv);
        return new String(decrypted, StandardCharsets.UTF_8);
    }

    /**
     * 加密字节数据
     */
    public static byte[] encrypt(byte[] plaintext) throws Exception {
        return encrypt(plaintext, DEFAULT_KEY, DEFAULT_IV);
    }

    /**
     * 加密字节数据（自定义密钥和IV）
     */
    public static byte[] encrypt(byte[] plaintext, byte[] key, byte[] iv) throws Exception {
        SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        Cipher cipher = Cipher.getInstance("AES/CTR/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);

        return cipher.doFinal(plaintext);
    }

    /**
     * 解密密文字节数据
     */
    public static byte[] decrypt(byte[] ciphertext) throws Exception {
        return decrypt(ciphertext, DEFAULT_KEY, DEFAULT_IV);
    }

    /**
     * 解密密文字节数据（自定义密钥和IV）
     */
    public static byte[] decrypt(byte[] ciphertext, byte[] key, byte[] iv) throws Exception {
        SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        Cipher cipher = Cipher.getInstance("AES/CTR/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);

        return cipher.doFinal(ciphertext);
    }

    /**
     * 将字节数组转换为十六进制字符串
     */
    public static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /**
     * 将十六进制字符串转换为字节数组
     */
    public static byte[] hexToBytes(String hexString) {
        if (hexString == null || hexString.length() % 2 != 0) {
            throw new IllegalArgumentException("Invalid hex string");
        }

        int len = hexString.length();
        byte[] data = new byte[len / 2];

        for (int i = 0; i < len; i += 2) {
            int high = Character.digit(hexString.charAt(i), 16);
            int low = Character.digit(hexString.charAt(i + 1), 16);

            if (high == -1 || low == -1) {
                throw new IllegalArgumentException("Invalid hex characters");
            }

            data[i / 2] = (byte) ((high << 4) + low);
        }

        return data;
    }
}