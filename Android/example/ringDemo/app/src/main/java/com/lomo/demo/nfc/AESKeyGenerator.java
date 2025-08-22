package com.lomo.demo.nfc;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;

public class AESKeyGenerator {

    public static byte[] generateAES128Key() throws NoSuchAlgorithmException {
        KeyGenerator keyGen = KeyGenerator.getInstance("AES");
        keyGen.init(128, new SecureRandom()); // 128位密钥
        SecretKey secretKey = keyGen.generateKey();
        return secretKey.getEncoded(); // 返回字节数组
    }

    // 辅助方法：字节数组转Hex
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    public static byte[] generateIV() {
        byte[] nonceAndCounter = new byte[16]; // Nonce(12) + Counter(4)
        SecureRandom random = new SecureRandom();
        random.nextBytes(nonceAndCounter); // 填充随机值
        return nonceAndCounter;
    }

}
