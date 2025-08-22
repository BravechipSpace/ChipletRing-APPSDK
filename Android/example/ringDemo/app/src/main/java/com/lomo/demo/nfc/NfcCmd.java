package com.lomo.demo.nfc;

import java.util.Random;

public class NfcCmd {

    /**
     * 设置AES 128位加密算法秘钥
     * @param encryptionFlag 加密标志
     * @return
     */
    public static String setKeyToNFC(int encryptionFlag){
        byte[] cmdData = new byte[36];
        cmdData[0] = 0x00;
        cmdData[1] = (byte) new Random().nextInt(254);
        cmdData[2] = 0x32;
        cmdData[3] = (byte) encryptionFlag;
        byte[] AES128Key=AesCtr.DEFAULT_KEY;

        byte[] aesContent=new byte[32];
        aesContent[0]=(byte) 0xB0;
        aesContent[1]=(byte) 0x00;
        System.arraycopy(AES128Key, 0, aesContent, 2, AES128Key.length);

        //对秘钥加密
        if(encryptionFlag==1){
            try {
                System.out.println("AES128Key 加密前："+AesCtr.bytesToHex(aesContent));
                aesContent = AesCtr.encryptAes128Ctr(aesContent);
                System.out.println("AES128Key 加密后："+AesCtr.bytesToHex(aesContent));
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        System.arraycopy(aesContent, 0, cmdData, 4, aesContent.length);
        return AesCtr.bytesToHex(cmdData);
    }

    /**
     * 设置获取key的指令
     * @return
     */
    public static String getKeyFromNFC(int encryptionFlag){
        byte[] cmdData = new byte[36];
        cmdData[0] = 0x00;
        cmdData[1] = (byte) new Random().nextInt(254);
        cmdData[2] = 0x32;
        cmdData[3] = (byte) encryptionFlag;

        byte[] aesContent=new byte[32];
        aesContent[0]=(byte) 0xB0;
        aesContent[1]=(byte) 0x01;

        //对秘钥加密
        if(encryptionFlag==1){
            try {
                System.out.println("AES128Key 加密前："+AesCtr.bytesToHex(aesContent));
                aesContent = AesCtr.encryptAes128Ctr(aesContent);
                System.out.println("AES128Key 加密后："+AesCtr.bytesToHex(aesContent));
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        System.arraycopy(aesContent, 0, cmdData, 4, aesContent.length);
        return AesCtr.bytesToHex(cmdData);
    }


    /**
     * 获取aeskey，如果是密文，就解码
     * @param dataFromNfc
     * @return
     */
    public static String analyzeContent(String dataFromNfc) throws Exception {
        byte[] bytes = BitUtils.hexToBytes(dataFromNfc);
        //不是有效数据
        if(bytes.length != 36||(bytes[0]!=0x0&&bytes[2]!=32)){
            return "";
        }

        byte[] keyBytes = new byte[32];
        System.arraycopy(bytes, 4, keyBytes, 0, keyBytes.length);
        String contentent = ConvertUtils.bytes2HexString(keyBytes);
        if(bytes[3]==0){//不加密
            System.out.println("不加密的秘钥");
            return contentent;
        }
        /**
         * 是加密文件，就解密
         */
        byte[] decryptAes128Ctr = AesCtr.decryptAes128Ctr(keyBytes);
        String decryptKey = AesCtr.bytesToHex(decryptAes128Ctr);

        System.out.println("解密以后的秘钥:"+decryptKey);
        //将新的秘钥设置为本地加密秘钥
      //  AES128CTR.DEFAULT_KEY=decryptKey;
        return decryptKey;

    }

    /**
     * 获取设备ID
     * @return
     */
    public static String getDeviceId(int encryptionFlag){
        byte[] cmdData = new byte[36];
        cmdData[0] = 0x00;
        cmdData[1] = (byte) new Random().nextInt(254);
        cmdData[2] = 0x32;
        cmdData[3] = (byte) encryptionFlag;

        byte[] aesContent=new byte[32];
        aesContent[0]=(byte) 0xB0;
        aesContent[1]=(byte) 0x02;

        //对秘钥加密
        if(encryptionFlag==1){
            try {

                aesContent = AesCtr.encryptAes128Ctr(aesContent);

            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        System.arraycopy(aesContent, 0, cmdData, 4, aesContent.length);
        return AesCtr.bytesToHex(cmdData);
    }

}
