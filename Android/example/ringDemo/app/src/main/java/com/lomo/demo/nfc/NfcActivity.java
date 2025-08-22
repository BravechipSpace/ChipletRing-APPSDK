package com.lomo.demo.nfc;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;

import com.google.android.material.navigation.NavigationView;

import com.lomo.demo.R;
import com.lomo.demo.nfc.generic.util.TagDiscovery;
import com.st.st25sdk.Helper;
import com.st.st25sdk.MultiAreaInterface;
import com.st.st25sdk.NFCTag;
import com.st.st25sdk.STException;
import com.st.st25sdk.TagHelper;
import com.st.st25sdk.ndef.NDEFMsg;
import com.st.st25sdk.ndef.NDEFRecord;
import com.st.st25sdk.ndef.TextRecord;
import com.st.st25sdk.type4a.STType4Tag;

import java.util.Arrays;
import java.util.concurrent.Semaphore;

public class NfcActivity extends AppCompatActivity implements TagDiscovery.onTagDiscoveryCompletedListener {
    private static final String TAG = "MainActivity";
    private LinearLayout main;
    private TextView tvLog;
    private Button getAes,btn_input;
    private Button createAes,createAesPassWord,getAesPassWord,getAesKey,getDeviceID,getDeviceIdPassWord;
    private  String testAesString="";
    private StringBuilder stringBuilder=new StringBuilder();

    private NFCTag myTag = null;
    private int mArea;
    private Semaphore mLock = new Semaphore(1);
    private NDEFRecord mNDEFRecord;
    private TextRecord mTextRecord;
    enum Action {
        LEAVE_PRIVACY_MODE,
        INSTANTIATE_TAG,
        TOGGLE_PRIVACY_MODE_PWD
    };

    enum ActionStatus {
        ACTION_SUCCESSFUL,
        ACTION_FAILED,
        TAG_NOT_IN_THE_FIELD,
        CONFIG_PASSWORD_NEEDED,
        AREA_PASSWORD_NEEDED
    };

    static public Resources mResources;
    protected NDEFMsg mCurrentNdefMsg;

    public static final String NEW_TAG = "new_tag";

    public static final byte[] PRIVACY_UID = new byte[] {(byte) 0xE0, (byte) 0x02, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00 };

    FragmentManager mFragmentManager;
    private NfcAdapter mNfcAdapter;
    private PendingIntent mPendingIntent;

    private SharedPreferences mSharedPreferences;
    private static Context mContext;

    private final String PREFS_NAME = "LICENSE_AGREEMENT";
    private final String SHARED_PREFERENCE_KEY = "licenseAgreement";
    private boolean mLicenseAgreement = false;
    private AlertDialog mLicenseAlertDialog;
    private Action mCurrentAction;
    private boolean mIsAreaProtectedInRead;
    private NavigationView mNavigationView;
    private byte[] mReadPassword;
    static private boolean mDisplayAndefContent;

    public interface NfcIntentHook {
        void newNfcIntent(Intent intent);
    }

    private static NfcIntentHook mNfcIntentHook;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.nfc_activity);

        initView();
        mResources = getResources();
        mNfcAdapter = NfcAdapter.getDefaultAdapter(this);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            mPendingIntent = PendingIntent.getActivity(this, 0, new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), PendingIntent.FLAG_MUTABLE);
        } else {
            mPendingIntent = PendingIntent.getActivity(this, 0, new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), PendingIntent.FLAG_IMMUTABLE);
        }


        stringBuilder.setLength(0);
        stringBuilder.append("默认aes key:").append(ConvertUtils.bytes2HexString(AesCtr.DEFAULT_KEY)).append("\n\n");
        showLog();
        createAesPassWord.setOnClickListener(v->{
            testAesString= NfcCmd.setKeyToNFC((byte) 1);
            stringBuilder.append("加密key，按照协议生成的文本:").append(testAesString).append("\n\n");
            System.out.println("加密key，按照协议生成的文本:"+testAesString);
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }

        });
        createAes.setOnClickListener(v->{
            testAesString= NfcCmd.setKeyToNFC(0);
            stringBuilder.append("明文key，按照协议生成的文本:").append(testAesString).append("\n\n");
            System.out.println("明文key，按照协议生成的文本:"+testAesString);
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }
        });
        getAesKey.setOnClickListener(v->{
            testAesString= NfcCmd.getKeyFromNFC(0);
            stringBuilder.append("获取明文的key:").append(testAesString).append("\n\n");
            System.out.println("获取明文的key，按照协议生成的文本:"+testAesString);
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }
        });
        getAesPassWord.setOnClickListener(v->{
            testAesString= NfcCmd.getKeyFromNFC(1);
            stringBuilder.append("获取加密key，按照协议生成的文本:").append(testAesString).append("\n\n");
            System.out.println("获取加密key，按照协议生成的文本:"+testAesString);
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }
        });
        getDeviceID.setOnClickListener(v->{
            testAesString= NfcCmd.getDeviceId(0);
            stringBuilder.append("明文获取设备ID，按照协议生成的文本:").append(testAesString).append("\n\n");
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }
        });

        getDeviceIdPassWord.setOnClickListener(v->{
            testAesString= NfcCmd.getDeviceId(1);
            stringBuilder.append("密文获取设备ID，按照协议生成的文本:").append(testAesString).append("\n\n");
            showLog();
            if(mTextRecord!=null){
                mTextRecord.setText(testAesString);
                writeNdefMessage();
            }
        });




    }

    private void showLog(){
        tvLog.setText(stringBuilder);
    }
    private void initView() {
        main = (LinearLayout) findViewById(R.id.main);
        tvLog = (TextView) findViewById(R.id.tv_log);
        createAesPassWord = (Button) findViewById(R.id.createAesPassWord);
        createAes = (Button) findViewById(R.id.createAes);
        getAesPassWord= (Button) findViewById(R.id.getAesPassWord);
        getAesKey= (Button) findViewById(R.id.getAesKey);
        getDeviceIdPassWord= (Button) findViewById(R.id.getDeviceIdPassWord);
        getDeviceID= (Button) findViewById(R.id.getDeviceID);

    }


    void processIntent(Intent intent) {


        if(intent == null) {
            return;
        }

        Log.d(TAG, "processIntent " + intent);

        if(mNfcIntentHook != null) {
            // NFC Intent hook used only for test purpose!
            mNfcIntentHook.newNfcIntent(intent);
            return;
        }

        Tag androidTag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
        if (androidTag != null) {
            // A tag has been taped

            byte[] uid = Helper.reverseByteArray(androidTag.getId());
            if (Arrays.equals(uid, PRIVACY_UID)) {
              //  leavePrivacyMode(androidTag, uid);
            } else {
                // Default behavior
                // Perform tag discovery in an asynchronous task
                // onTagDiscoveryCompleted() will be called when the discovery is completed.
                new TagDiscovery(this).execute(androidTag);
            }

            // This intent has been processed. Reset it to be sure that we don't process it again
            // if the MainActivity is resumed
            setIntent(null);
        }
    }

    static public void setNfcIntentHook(NfcIntentHook nfcIntentHook) {
        mNfcIntentHook = nfcIntentHook;
    }

    @Override
    public void onPause() {
        super.onPause();

        if (mNfcAdapter != null) {
            try {
                mNfcAdapter.disableForegroundDispatch(this);
                Log.v(TAG, "disableForegroundDispatch");
            } catch (IllegalStateException e) {
                Log.w(TAG, "Illegal State Exception disabling NFC. Assuming application is terminating.");
            }
            catch (UnsupportedOperationException e) {
                Log.w(TAG, "FEATURE_NFC is unavailable.");
            }
        }

    }

    @Override
    public void onResume() {
        Intent intent = getIntent();
        Log.d(TAG, "Resume mainActivity intent: " + intent);
        super.onResume();


        if (mNfcAdapter != null) {
            Log.v(TAG, "enableForegroundDispatch");
            mNfcAdapter.enableForegroundDispatch(this, mPendingIntent, null /*nfcFiltersArray*/, null /*nfcTechLists*/);

            if (mNfcAdapter.isEnabled()) {
                // NFC enabled
                stringBuilder.append("手机NFC可用").append("\n\n");
            } else {
                // NFC disabled

                stringBuilder.append("当前NFC关闭").append("\n\n");
            }

        } else {
            stringBuilder.append("手机NFC不可用").append("\n\n");
            showLog();
        }


        processIntent(intent);
        readNdefContent();
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onNewIntent(Intent intent) {
        // onResume gets called after this to handle the intent
        Log.d(TAG, "onNewIntent " + intent);
        setIntent(intent);
    }

    @Override
    public void onTagDiscoveryCompleted(NFCTag nfcTag, TagHelper.ProductID productId, STException e) {
        //Toast.makeText(getApplication(), "onTagDiscoveryCompleted. productId:" + productId, Toast.LENGTH_LONG).show();
        if (e != null) {
            Log.i(TAG, e.toString());
            Toast.makeText(getApplication(), "读标签出错!", Toast.LENGTH_LONG).show();
            stringBuilder.append("读标签出错!\n\n");
            showLog();
            return;
        }

        myTag = nfcTag;


        switch (productId) {

            case PRODUCT_GENERIC_TYPE4:
            case PRODUCT_GENERIC_TYPE4A:
            //    startTagActivity(GenericType4TagActivity.class, R.string.type4_menus);
                break;

        }
    }

    private void readNdefContent() {
        new AsyncTaskReadNdefMessage().execute();
    }


    /**
     * AsyncTask reading the NDEFMsg from the tag
     */
    private class AsyncTaskReadNdefMessage extends AsyncTask<Void, Void, ActionStatus> {

        NDEFMsg mNdefMsgRead;

        public AsyncTaskReadNdefMessage() {
        }

        @Override
        protected ActionStatus doInBackground(Void... param) {
            ActionStatus result = ActionStatus.ACTION_FAILED;

            if (myTag == null) {
                return result;
            }

            try {
                mLock.acquire();
            }
            catch (InterruptedException e) {}

            try {
                if (myTag instanceof STType4Tag) {
                    int fileId = mArea;

                    if(mIsAreaProtectedInRead) {
                        mNdefMsgRead = ((STType4Tag) myTag).readNdefMessage(fileId, mReadPassword);
                    } else {
                        mNdefMsgRead = ((STType4Tag) myTag).readNdefMessage(fileId);
                    }

                } else {
                    if (myTag instanceof MultiAreaInterface) {
                        mNdefMsgRead = ((MultiAreaInterface) myTag).readNdefMessage(mArea);
                    } else {
                        mNdefMsgRead = myTag.readNdefMessage();
                    }
                }

                if (mNdefMsgRead != null) {
                    mCurrentNdefMsg = mNdefMsgRead.copy();

                } else {
                    mCurrentNdefMsg = null;
                }





                result = ActionStatus.ACTION_SUCCESSFUL;
                mIsAreaProtectedInRead = false;

            } catch (STException e) {
                switch (e.getError()) {
                    case INVALID_CCFILE:
                    case INVALID_NDEF_DATA:
                        // This area doesn't contain a valid CCFile or NDEF but read done successfully
                        mCurrentNdefMsg = new NDEFMsg();
                        if (mDisplayAndefContent) {

                        }
                        result = ActionStatus.ACTION_SUCCESSFUL;
                        mIsAreaProtectedInRead = false;
                        break;

                    case ISO15693_BLOCK_PROTECTED:
                    case WRONG_SECURITY_STATUS:
                        result = ActionStatus.AREA_PASSWORD_NEEDED;
                        mIsAreaProtectedInRead = true;
                        break;

                    case TAG_NOT_IN_THE_FIELD:
                        result = ActionStatus.TAG_NOT_IN_THE_FIELD;
                        runOnUiThread(() -> {
                            Toast.makeText(NfcActivity.this,"不在范围:"+e.getMessage(),Toast.LENGTH_LONG).show();
                        });

                        break;

                    default:

                        runOnUiThread(() -> {
                            Toast.makeText(NfcActivity.this,"读内容出错:"+e.getMessage(),Toast.LENGTH_LONG).show();
                        });
                        e.printStackTrace();
                        break;
                }
            }

            mLock.release();

            return result;
        }

        @Override
        protected void onPostExecute(ActionStatus actionStatus) {

            switch(actionStatus) {
                case ACTION_SUCCESSFUL:
                    if (mCurrentNdefMsg != null && mCurrentNdefMsg.getNDEFRecords().size() != 0 ) {

                        mNDEFRecord= mCurrentNdefMsg.getNDEFRecord(0);

                        if (mNDEFRecord instanceof TextRecord) {
                            mTextRecord= (TextRecord) mCurrentNdefMsg.getNDEFRecord(0);
                            testAesString=((TextRecord) mNDEFRecord).getText();
                            stringBuilder.append("nfc读取的内容:").append(((TextRecord) mNDEFRecord).getText()).append("\n\n");
                            System.out.println("nfc读取的内容:"+testAesString);
                            showLog();

                            try {
                                byte[] bytes = BitUtils.hexToBytes(testAesString);
                                String aes128KeyFromNFC = NfcCmd.analyzeContent(testAesString);
                                if(bytes[3]==0){//不加密
                                    System.out.println("不加密的秘钥");

                                    stringBuilder.append("内容:").append(aes128KeyFromNFC).append("\n\n");
                                }else{
                                    stringBuilder.append("解密后的内容:").append(aes128KeyFromNFC).append("\n\n");
                                }




                                showLog();
                            } catch (Exception e) {
                               e.printStackTrace();
                            }

                        }else{
                            Toast.makeText(NfcActivity.this,"不是文本格式",Toast.LENGTH_LONG).show();
                        }
                    }
                    break;

                case TAG_NOT_IN_THE_FIELD:
                    Toast.makeText(NfcActivity.this,"标签不在场区内",Toast.LENGTH_LONG).show();
                    break;

                case ACTION_FAILED:
                default:
                  //  Toast.makeText(MainActivity.this,"命令失败！",Toast.LENGTH_LONG).show();
                    break;
            }
        }
    }




    private void writeNdefMessage() {



        new AsyncTaskWriteNdefMessage().execute();
    }

    /**
     * AsyncTask writing the NDEFMsg to the tag
     */
    private class AsyncTaskWriteNdefMessage extends AsyncTask<Void, Void, ActionStatus> {
        public AsyncTaskWriteNdefMessage() {
        }

        @Override
        protected ActionStatus doInBackground(Void... param) {
            ActionStatus result = ActionStatus.ACTION_FAILED;

            try {

                myTag.writeNdefMessage(mCurrentNdefMsg);
                result = ActionStatus.ACTION_SUCCESSFUL;


            } catch (STException e) {
                switch (e.getError()) {


                    case TAG_NOT_IN_THE_FIELD:
                        result = ActionStatus.TAG_NOT_IN_THE_FIELD;
                        break;

                    default:
                        e.printStackTrace();
                        break;
                }
            }

            return result;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected void onPostExecute(ActionStatus actionStatus) {


            switch(actionStatus) {


                case ACTION_SUCCESSFUL:

                    Toast.makeText(NfcActivity.this,"标签已更新",Toast.LENGTH_LONG).show();
                    break;


                case TAG_NOT_IN_THE_FIELD:
                    Toast.makeText(NfcActivity.this,"标签不在场区内",Toast.LENGTH_LONG).show();
                    break;

                case ACTION_FAILED:
                default:
                    Toast.makeText(NfcActivity.this,"命令失败！",Toast.LENGTH_LONG).show();
                    break;
            }
        }
    }


}