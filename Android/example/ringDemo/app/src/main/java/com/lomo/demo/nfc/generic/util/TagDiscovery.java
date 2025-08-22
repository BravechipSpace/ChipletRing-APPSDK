package com.lomo.demo.nfc.generic.util;


import static com.st.st25sdk.TagHelper.ProductID.PRODUCT_UNKNOWN;
import static com.st.st25sdk.TagHelper.identifyIso14443BProduct;
import static com.st.st25sdk.TagHelper.identifyIso14443aType2Type4aProduct;
import static com.st.st25sdk.TagHelper.identifyType4Product;
import static com.st.st25sdk.TagHelper.identifyTypeVProduct;

import android.nfc.Tag;
import android.os.AsyncTask;
import android.util.Log;

import com.st.st25android.AndroidReaderInterface;
import com.st.st25sdk.Helper;
import com.st.st25sdk.NFCTag;
import com.st.st25sdk.STException;
import com.st.st25sdk.TagHelper;
import com.st.st25sdk.iso14443b.Iso14443bTag;
import com.st.st25sdk.type2.Type2Tag;
import com.st.st25sdk.type2.st25tn.ST25TNTag;
import com.st.st25sdk.type4a.Type4Tag;
import com.st.st25sdk.type4a.Type4aTag;
import com.st.st25sdk.type4a.m24srtahighdensity.M24SR02KTag;
import com.st.st25sdk.type4a.m24srtahighdensity.M24SR04KTag;
import com.st.st25sdk.type4a.m24srtahighdensity.M24SR16KTag;
import com.st.st25sdk.type4a.m24srtahighdensity.M24SR64KTag;
import com.st.st25sdk.type4a.m24srtahighdensity.ST25TA16KTag;
import com.st.st25sdk.type4a.m24srtahighdensity.ST25TA64KTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KBDTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KBPTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KBTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KDTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KPTag;
import com.st.st25sdk.type4a.st25ta.ST25TA02KTag;
import com.st.st25sdk.type4a.st25ta.ST25TA512BTag;
import com.st.st25sdk.type4a.st25ta.ST25TA512Tag;
import com.st.st25sdk.type4b.Type4bTag;
import com.st.st25sdk.type5.STType5Tag;
import com.st.st25sdk.type5.Type5Tag;
import com.st.st25sdk.type5.lri.LRi1KTag;
import com.st.st25sdk.type5.lri.LRi2KTag;
import com.st.st25sdk.type5.lri.LRi512Tag;
import com.st.st25sdk.type5.lri.LRiS2KTag;
import com.st.st25sdk.type5.m24lr.LRiS64KTag;
import com.st.st25sdk.type5.m24lr.M24LR04KTag;
import com.st.st25sdk.type5.m24lr.M24LR16KTag;
import com.st.st25sdk.type5.m24lr.M24LR64KTag;
import com.st.st25sdk.type5.st25dv.ST25DVCTag;
import com.st.st25sdk.type5.st25dv.ST25DVTag;
import com.st.st25sdk.type5.st25dv.ST25TV04KPTag;
import com.st.st25sdk.type5.st25dv.ST25TV16KCTag;
import com.st.st25sdk.type5.st25dv.ST25TV16KTag;
import com.st.st25sdk.type5.st25dv.ST25TV64KCTag;
import com.st.st25sdk.type5.st25dv.ST25TV64KTag;
import com.st.st25sdk.type5.st25dvpwm.ST25DV02KW1Tag;
import com.st.st25sdk.type5.st25dvpwm.ST25DV02KW2Tag;
import com.st.st25sdk.type5.st25tv.ST25TVTag;
import com.st.st25sdk.type5.st25tvc.ST25TVCTag;


/**
 * Class creating a Asynchronous Task performing the discovery of a Tag.
 *
 * The input data is an 'android.nfc.Tag' (called 'androidTag' in the code below).
 *
 * Some NFC commands are executed to identify more precisely the product.
 * A ST25SDK NFCTag is then instantiated.
 * This NFCTag can be used by the SDK to communicate with the tag.
 */
public class TagDiscovery extends AsyncTask<Tag, Void, STException> {

    static final String TAG = "TagDiscovery";

    private onTagDiscoveryCompletedListener mListener;

    // NFC Tag as defined by Android
    private Tag mAndroidTag;

    private TagHelper.ProductID mProductID;

    // NFC Tag as defined in ST25 SDK
    private NFCTag mNfcTag;

    public interface onTagDiscoveryCompletedListener {
        void onTagDiscoveryCompleted(NFCTag nfcTag, TagHelper.ProductID productId, STException e);
    }


    /**
     * Class used to store the information about the tag taped. It contains:
     * - the NFCTag object
     * - the ProductID
     */
    public static class TagInfo {
        public NFCTag nfcTag;
        public TagHelper.ProductID productID;
    }


    /**
     * Constuctor of TagDiscovery class.
     * The requester of the discovery should implement the 'onTagDiscoveryCompletedListener' Listener.
     * TagDiscovery will use this Listener to notify the requester when the discovery is finished.
     *
     * @param listener Method that will be called when the TagDiscovery is finished.
     */
    public TagDiscovery(onTagDiscoveryCompletedListener listener) {
        this.mListener = listener;
    }

    @Override
    protected STException doInBackground(Tag... param) {
        mAndroidTag = param[0];
        TagInfo tagInfo;
        try {
            tagInfo = performTagDiscovery(mAndroidTag);
        }catch(STException e) {
            mNfcTag = null;
            mProductID = PRODUCT_UNKNOWN;
            return e;
        }
        mNfcTag = tagInfo.nfcTag;
        mProductID = tagInfo.productID;

        return null;
    }

    @Override
    protected void onPostExecute(STException result) {
        // Code executed on UI Thread

        // Notify the Listener that a tag has been found
        mListener.onTagDiscoveryCompleted(mNfcTag, mProductID,result);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * This function performs the discovery of a tag (provided as an Android 'Tag' class).
     * It returns a TagInfo class containing the nfcTag (as defined by the SDK) and the ProductId.
     *
     * IMPORTANT: This function will fail if it is called from UI Thread.
     *
     * @param androidTag Tag as defined by Android ('android.nfc.Tag')
     * @return TagInfo or null if the discovery failed.
     */
    static public TagInfo performTagDiscovery(Tag androidTag) throws STException{
        TagInfo tagInfo = new TagInfo();
        tagInfo.nfcTag = null;
        tagInfo.productID = PRODUCT_UNKNOWN;

        Log.v(TAG, "Starting TagDiscovery");

        if(androidTag == null) {
            Log.e(TAG, "androidTag cannot be null!");
            return null;
        }

        AndroidReaderInterface readerInterface = AndroidReaderInterface.newInstance(androidTag);

        if (readerInterface == null) {
            tagInfo.nfcTag = null;
            tagInfo.productID = PRODUCT_UNKNOWN;
            return tagInfo;
        }

        byte[] uid = androidTag.getId();

        switch (readerInterface.mTagType) {
            case NFC_TAG_TYPE_V:
                uid = Helper.reverseByteArray(uid);
                tagInfo.productID = identifyTypeVProduct(readerInterface, uid);
                break;
            case NFC_TAG_TYPE_4A:
                tagInfo.productID = identifyType4Product(readerInterface, uid);
                break;
            case NFC_TAG_TYPE_2:
                tagInfo.productID = identifyIso14443aType2Type4aProduct(readerInterface, uid);
                break;
            case NFC_TAG_TYPE_4B:
                tagInfo.productID = identifyIso14443BProduct(readerInterface, uid);
                break;
            case NFC_TAG_TYPE_A:
            case NFC_TAG_TYPE_B:
                default:
                tagInfo.productID = PRODUCT_UNKNOWN;
                break;
        }

        // Take advantage that we are in a background thread to allocate the NFCTag.
        try {
            switch (tagInfo.productID) {
                case PRODUCT_ST_ST25DV64K_I:
                case PRODUCT_ST_ST25DV64K_J:
                case PRODUCT_ST_ST25DV16K_I:
                case PRODUCT_ST_ST25DV16K_J:
                case PRODUCT_ST_ST25DV04K_I:
                case PRODUCT_ST_ST25DV04K_J:
                    tagInfo.nfcTag = new ST25DVTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25DV04KC_I:
                case PRODUCT_ST_ST25DV04KC_J:
                case PRODUCT_ST_ST25DV16KC_I:
                case PRODUCT_ST_ST25DV16KC_J:
                case PRODUCT_ST_ST25DV64KC_I:
                case PRODUCT_ST_ST25DV64KC_J:
                    tagInfo.nfcTag = new ST25DVCTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV16KC:
                    tagInfo.nfcTag = new ST25TV16KCTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV64KC:
                    tagInfo.nfcTag = new ST25TV64KCTag(readerInterface, uid);
                    break;

                case PRODUCT_ST_LRi512:
                    tagInfo.nfcTag = new LRi512Tag(readerInterface, uid);
                    break;
                case PRODUCT_ST_LRi1K:
                    tagInfo.nfcTag = new LRi1KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_LRi2K:
                    tagInfo.nfcTag = new LRi2KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_LRiS2K:
                    tagInfo.nfcTag = new LRiS2KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_LRiS64K:
                    tagInfo.nfcTag = new LRiS64KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24SR02_Y:
                    tagInfo.nfcTag = new M24SR02KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24SR04_Y:
                case PRODUCT_ST_M24SR04_G:
                    tagInfo.nfcTag = new M24SR04KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24SR16_Y:
                    tagInfo.nfcTag = new M24SR16KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24SR64_Y:
                    tagInfo.nfcTag = new M24SR64KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV512:
                case PRODUCT_ST_ST25TV02K:
                    tagInfo.nfcTag = new ST25TVTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV04K_P:
                    tagInfo.nfcTag = new ST25TV04KPTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV02KC:
                case PRODUCT_ST_ST25TV512C:
                    tagInfo.nfcTag = new ST25TVCTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV16K:
                    tagInfo.nfcTag =  new ST25TV16KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TV64K:
                    tagInfo.nfcTag =  new ST25TV64KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25DV02K_W1:
                    tagInfo.nfcTag = new ST25DV02KW1Tag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25DV02K_W2:
                    tagInfo.nfcTag = new ST25DV02KW2Tag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24LR16E_R:
                    tagInfo.nfcTag = new M24LR16KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24LR64E_R:
                case PRODUCT_ST_M24LR64_R:
                    tagInfo.nfcTag = new M24LR64KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_M24LR04E_R:
                    tagInfo.nfcTag = new M24LR04KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02K:
                    tagInfo.nfcTag = new ST25TA02KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02KB:
                    tagInfo.nfcTag = new ST25TA02KBTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02K_P:
                    tagInfo.nfcTag = new ST25TA02KPTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02KB_P:
                    tagInfo.nfcTag = new ST25TA02KBPTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02K_D:
                    tagInfo.nfcTag = new ST25TA02KDTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA02KB_D:
                    tagInfo.nfcTag = new ST25TA02KBDTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA16K:
                    tagInfo.nfcTag = new ST25TA16KTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA512_K:
                case PRODUCT_ST_ST25TA512:
                    tagInfo.nfcTag = new ST25TA512Tag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA512B:
                    tagInfo.nfcTag = new ST25TA512BTag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TA64K:
                    tagInfo.nfcTag = new ST25TA64KTag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE4:
                    tagInfo.nfcTag =  new Type4Tag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE4A:
                    tagInfo.nfcTag =  new Type4aTag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE4B:
                    tagInfo.nfcTag =  new Type4bTag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_ISO14443B:
                    tagInfo.nfcTag =  new Iso14443bTag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE5_AND_ISO15693:
                    tagInfo.nfcTag =  new STType5Tag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE5:
                    tagInfo.nfcTag =  new Type5Tag(readerInterface, uid);
                    break;
                case PRODUCT_GENERIC_TYPE2:
                    tagInfo.nfcTag =  new Type2Tag(readerInterface, uid);
                    break;
                case PRODUCT_ST_ST25TN01K:
                case PRODUCT_ST_ST25TN512:
                    tagInfo.nfcTag =  new ST25TNTag(readerInterface, uid);
                    break;
                default:
                    tagInfo.nfcTag = null;
                    tagInfo.productID = PRODUCT_UNKNOWN;
                    break;
            }
        } catch (STException e) {
            // An STException has occured while instantiating the tag
            e.printStackTrace();
            tagInfo.productID = PRODUCT_UNKNOWN;
        }

        if(tagInfo.nfcTag != null) {
            String manufacturerName = "";
            try {
                manufacturerName = tagInfo.nfcTag.getManufacturerName();
            } catch (STException e) {
                e.printStackTrace();
            }

            if(manufacturerName.equals("STMicroelectronics")) {
                tagInfo.nfcTag.setName(tagInfo.productID.toString());
            }
        }

        return tagInfo;
    }

}
