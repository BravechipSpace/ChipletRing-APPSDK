package com.lomo.demo.amota;

import android.bluetooth.BluetoothGattCharacteristic;
import android.util.Log;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

/**
 * Created by Mike on 11/24/2016.
 */

public class AmOtaService {

    private int progress2;

    public interface AmotaCallback {
        public abstract void progressUpdate(int progress);
        public abstract void complete();
    }

    public static enum eAmotaStatus
    {
        AMOTA_STATUS_SUCCESS,
        AMOTA_STATUS_CRC_ERROR,
        AMOTA_STATUS_INVALID_HEADER_INFO,
        AMOTA_STATUS_INVALID_PKT_LENGTH,
        AMOTA_STATUS_INSUFFICIENT_BUFFER,
        AMOTA_STATUS_UNKNOWN_ERROR,
        AMOTA_STATUS_MAX
    }

    /* amota commands */
    public static enum eAmotaCommand
    {
        AMOTA_CMD_UNKNOWN,
        AMOTA_CMD_FW_HEADER,
        AMOTA_CMD_FW_DATA,
        AMOTA_CMD_FW_VERIFY,
        AMOTA_CMD_FW_RESET,
        AMOTA_CMD_MAX
    }


    private static final String TAG = AmOtaService.class.getSimpleName();
    private Semaphore dataWriteSemaphore = null;
    private Semaphore cmdResponseSemaphore = null;

    private final int AMOTA_PACKET_SIZE = 512 + 16;
    private final int AMOTA_FW_PACKET_SIZE = 512;
    private final int MAXIMUM_APP_PAYLOAD = 237;
    private final int AMOTA_LENGTH_SIZE_IN_PKT = 2;
    private final int AMOTA_CMD_SIZE_IN_PKT = 1;
    private final int AMOTA_CRC_SIZE_IN_PKT = 4;
    private final int AMOTA_HEADER_SIZE_IN_PKT = AMOTA_LENGTH_SIZE_IN_PKT + AMOTA_CMD_SIZE_IN_PKT;

    private String mSelectedFile;
    private BluetoothLeService mBluetoothLeService;
    private BluetoothGattCharacteristic mAmotaRxChar;
    private boolean mStopOta;
    FileInputStream mFsInput;
    private int mFileOffset;
    private int mFileSize;
    private AmotaCallback mAmotaCallback;
    private StringBuilder logTxt=new StringBuilder();

    public String formatHex2String(byte[] data) {
        final StringBuilder stringBuilder = new StringBuilder(data.length);
        for(byte byteChar : data)
            stringBuilder.append(String.format("%02X ", byteChar));
        return stringBuilder.toString();
    }

    private boolean waitGATTWriteComplete(long timeoutMs) {
        boolean ret = false;
        try {
            ret = dataWriteSemaphore.tryAcquire(timeoutMs, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return ret;
    }

    public void setGATTWriteComplete() {
        dataWriteSemaphore.release();
    }

    private boolean waitCmdResponse(long timeoutMs) {
        boolean ret = false;
        try {
            ret = cmdResponseSemaphore.tryAcquire(timeoutMs, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return ret;
    }

    private void cmdResponseArrived() {
        cmdResponseSemaphore.release();
    }

    private byte amOtaCmd2Byte(eAmotaCommand cmd) {
        switch (cmd) {
            case AMOTA_CMD_UNKNOWN:
                return 0;
            case AMOTA_CMD_FW_HEADER:
                return 1;
            case AMOTA_CMD_FW_DATA:
                return 2;
            case AMOTA_CMD_FW_VERIFY:
                return 3;
            case AMOTA_CMD_FW_RESET:
                return 4;
        }

        return 0;
    }

    private eAmotaCommand amOtaByte2Cmd(int cmd) {
        switch (cmd & 0xff) {
            case 1:
                return eAmotaCommand.AMOTA_CMD_FW_HEADER;
            case 2:
                return eAmotaCommand.AMOTA_CMD_FW_DATA;
            case 3:
                return eAmotaCommand.AMOTA_CMD_FW_VERIFY;
            case 4:
                return eAmotaCommand.AMOTA_CMD_FW_RESET;
        }

        return eAmotaCommand.AMOTA_CMD_UNKNOWN;
    }

    private boolean sendOneFrame(byte[] data) throws InterruptedException {
        if (mStopOta) {
            Log.i(TAG, "OTA stopped due to application control");
        }
        Log.w(TAG, "mAmotaRxChar: " + mAmotaRxChar.getUuid().toString());
        if (!mBluetoothLeService.writeCharacteristic(mAmotaRxChar, data)) {
            Log.e(TAG, "Failed to write characteristic");
            logTxt.append("OTA stopped due to application control").append("\n");
            writeLog();
            return false;
        }

        // wait for ACTION_GATT_WRITE_RESULT
        return waitGATTWriteComplete(3000);
    }

    private boolean sendPacket(byte[] data, int len) {
        int idx = 0;

        while (idx < len) {
            int frameLen;
            if ((len - idx) > MAXIMUM_APP_PAYLOAD) {
                frameLen = MAXIMUM_APP_PAYLOAD;
            } else {
                frameLen = len - idx;
            }
            byte[] frame = new byte[frameLen];
            System.arraycopy(data, idx, frame, 0, frameLen);
            if (progress2 < 3){
                Log.w(TAG, "sendPacket: "+formatHex2String(frame) );
            }
            try {
                if (!sendOneFrame(frame)) {
                    return false;
                }
            }
            catch (InterruptedException e) {
                e.printStackTrace();
            }
            idx += frameLen;
        }

        return true;
    }

    private boolean sendOtaCmd(eAmotaCommand cmd, byte[] data, int len) {
        byte cmdData = amOtaCmd2Byte(cmd);
        int checksum = 0;
        int packetLength = AMOTA_HEADER_SIZE_IN_PKT + len + AMOTA_CRC_SIZE_IN_PKT;
        byte[] packet = new byte[packetLength];

        // fill data + checksum length
        packet[0] = (byte)(len + AMOTA_CRC_SIZE_IN_PKT);
        packet[1] = (byte)((len + AMOTA_CRC_SIZE_IN_PKT) >> 8);
        packet[2] = cmdData;

        if (len != 0) {
            // calculate CRC
            checksum = CrcCalculator.calcCrc32(len, data);
            // copy data into packet
            System.arraycopy(data, 0, packet, AMOTA_HEADER_SIZE_IN_PKT, len);
        }

        // append crc into packet
        // crc is always 0 if there is no data only command
        packet[AMOTA_HEADER_SIZE_IN_PKT + len] = ((byte)(checksum));
        packet[AMOTA_HEADER_SIZE_IN_PKT + len + 1] = ((byte)(checksum >> 8));
        packet[AMOTA_HEADER_SIZE_IN_PKT + len + 2] = ((byte)(checksum >> 16));
        packet[AMOTA_HEADER_SIZE_IN_PKT + len + 3] = ((byte)(checksum >> 24));

        if (sendPacket(packet, packetLength))
            return true;
        else {
            Log.e(TAG, "sendPacket failed");
            logTxt.append("sendPacket failed").append("\n");
            writeLog();
            return false;
        }
    }

    private boolean sendFwHeader() throws IOException {
        byte[] fwHeaderRead = new byte[48];
        int ret;

        ret = mFsInput.read(fwHeaderRead);
        if (ret < 48) {
            Log.w(TAG, "invalid packed firmware length");
            return false;
        }

        mFileSize = ((fwHeaderRead[11] & 0xFF) << 24) + ((fwHeaderRead[10] & 0xFF) << 16) +
                ((fwHeaderRead[9] & 0xFF) << 8) + (fwHeaderRead[8] & 0xFF);

        Log.i(TAG, "mFileSize = " + mFileSize);
        Log.i(TAG, "send fw header " + formatHex2String(fwHeaderRead));
        if (sendOtaCmd(eAmotaCommand.AMOTA_CMD_FW_HEADER, fwHeaderRead, fwHeaderRead.length)) {
            return waitCmdResponse(3000);
        }

        return false;
    }

    private int sentFwDataPacket() throws IOException {
        int ret;
        int len = AMOTA_FW_PACKET_SIZE;
        byte[] fwData = new byte[len];
        ret = mFsInput.read(fwData);
        if (ret <= 0) {
            Log.w(TAG, "no data read from mFsInput");
            logTxt.append("no data read from mFsInput").append("\n");
            writeLog();
            return -1;
        }
        if (ret < AMOTA_FW_PACKET_SIZE)
            len = ret;
        Log.i(TAG, "send fw data len = " + len);
        if (!sendOtaCmd(eAmotaCommand.AMOTA_CMD_FW_DATA, fwData, len)) {
            return -1;
        }
        return ret;
    }

    private boolean sendFwData() {
        int fwDataSize = mFileSize;
        int ret = -1;
        int offset = mFileOffset;

        Log.d(TAG, "file size = " + mFileSize);

        while (offset < fwDataSize) {
            try {
                ret = sentFwDataPacket();
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (ret < 0) {
                Log.e(TAG, "sentFwDataPacket failed");
                logTxt.append("sentFwDataPacket failed").append("\n");
                writeLog();
                return false;
            }
            if (!waitCmdResponse(3000)) {
                Log.e(TAG, "waitCmdResponse timeout");
                return false;
            }
            offset += ret;
            mAmotaCallback.progressUpdate((offset * 100) / fwDataSize);
            progress2 = (offset * 100) / fwDataSize;
        }

        Log.i(TAG, "send firmware data complete");

        return true;
    }

    private boolean sendVerifyCmd() {
        Log.i(TAG, "send fw verify cmd");
        if (sendOtaCmd(eAmotaCommand.AMOTA_CMD_FW_VERIFY, null, 0)) {
            return waitCmdResponse(5000);
        }

        return false;
    }

    private boolean sendResetCmd() {
        Log.i(TAG, "send fw reset cmd");
        if (sendOtaCmd(eAmotaCommand.AMOTA_CMD_FW_RESET, null, 0)) {
            return waitCmdResponse(3000);
        }

        return false;
    }

    private void startOtaUpdate() {
        try {
            mFsInput = new FileInputStream(mSelectedFile);

            mFileSize = mFsInput.available();
            if (mFileSize == 0) {
                mFsInput.close();
                Log.w(TAG, "open file error, file path = " + mSelectedFile + " file size = " + mFileSize);

                return;
            }

            if (!sendFwHeader()) {
                Log.e(TAG, "send FW header failed");
                mFsInput.close();
                logTxt.append("send FW header failed").append("\n");
                writeLog();
                return;
            }

            // start to send fw data
            setFileOffset();
            if (!sendFwData()) {
                Log.e(TAG, "send FW Data failed");

                mFsInput.close();
                logTxt.append("send FW Data failed").append("\n");
                writeLog();
                return;
            }


            if (!sendVerifyCmd())
            {
                Log.e(TAG, "send FW verify cmd failed");
                mFsInput.close();
                logTxt.append("send FW verify cmd failed").append("\n");
                writeLog();
                return;
            }

            // need ACK for reset command?
            sendResetCmd();

            mFsInput.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "exit startOtaUpdate");
        mAmotaCallback.complete();
    }

    private void setFileOffset() throws IOException {
        if (mFileOffset > 0) {
            Log.i(TAG, "set file offset " + mFileOffset);
            mFsInput.skip(mFileOffset);
        }
    }

    public void otaCmdResponse(byte[] response) {
        eAmotaCommand cmd = amOtaByte2Cmd(response[2] & 0xff);

        if (cmd == eAmotaCommand.AMOTA_CMD_UNKNOWN) {
            Log.e(TAG, "got unknown response" + formatHex2String(response));
            logTxt.append("got unknown response" + formatHex2String(response)).append("\n");
            writeLog();
            return;
        }

        // TODO : handle CRC error and some more here
        if ((response[3] & 0xff) != 0) {
            Log.e(TAG, "error occurred, response = " + formatHex2String(response));
            logTxt.append("error occurred, response = " + formatHex2String(response)).append("\n");
            writeLog();
            return;
        }

        switch (cmd) {
            case AMOTA_CMD_FW_HEADER:
                mFileOffset = ((response[4] & 0xFF) + ((response[5] & 0xFF) << 8) +
                        ((response[6] & 0xFF) << 16) + ((response[7] & 0xFF) << 24));
                Log.i(TAG, "get AMOTA_CMD_FW_HEADER response, mFileOffset = " + mFileOffset);
                cmdResponseArrived();
                break;
            case AMOTA_CMD_FW_DATA:
//                Log.i(TAG, "get AMOTA_CMD_FW_DATA response");
                cmdResponseArrived();
                break;
            case AMOTA_CMD_FW_VERIFY:
                Log.i(TAG, "get AMOTA_CMD_FW_VERIFY response");
                cmdResponseArrived();
                break;
            case AMOTA_CMD_FW_RESET:
                Log.i(TAG, "get AMOTA_CMD_FW_RESET response");
                cmdResponseArrived();
                break;
            default:
                Log.i(TAG, "get response from unknown command");
        }

    }

    private Runnable updateRunnable = new Runnable() {
        public void run()
        {
            startOtaUpdate();
        }
    };

    public eAmotaStatus amOtaStart(String filePath, BluetoothLeService bleService,
                                   BluetoothGattCharacteristic amotaNotifyChar,
                                   AmotaCallback amotaCallback) {
        mSelectedFile = filePath;
        mBluetoothLeService = bleService;
        mAmotaRxChar = amotaNotifyChar;
        mStopOta = false;
        mAmotaCallback = amotaCallback;

        dataWriteSemaphore = new Semaphore(0);
        cmdResponseSemaphore = new Semaphore(0);

        mFileOffset = 0;

        Thread amOtaStartThread = new Thread(this.updateRunnable);
        amOtaStartThread.start();
        Log.d(TAG, "AmOtaService amOtaStart");
        return eAmotaStatus.AMOTA_STATUS_SUCCESS;
    }

    public void amOtaStop() {
        mStopOta = true;
    }

    private IUpdateResult iUpdateResult;

    public void setiUpdateResult(IUpdateResult iUpdateResult) {
        this.iUpdateResult = iUpdateResult;
    }

    public interface IUpdateResult{
        void errorResult(String result);
    }
    private void writeLog(){
        if(iUpdateResult!=null){
            iUpdateResult.errorResult("");
        }
       // ImageSaverUtil.saveImageToInternalStorage(App.getInstance(), "阿波罗升级错误:" + logTxt, "LM", "amotaErrLog.txt", true);
    }
}
