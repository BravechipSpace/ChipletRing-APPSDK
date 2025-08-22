/*
  * @author STMicroelectronics MMY Application team
  *
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT 2017 STMicroelectronics</center></h2>
  *
  * Licensed under ST MIX_MYLIBERTY SOFTWARE LICENSE AGREEMENT (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/Mix_MyLiberty  
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
  * AND SPECIFICALLY DISCLAIMING THE IMPLIED WARRANTIES OF MERCHANTABILITY,
  * FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  ******************************************************************************
*/

package com.lomo.demo.nfc.generic;

import android.nfc.cardemulation.HostApduService;
import android.os.Bundle;
import android.util.Log;

import com.st.st25sdk.Helper;

public class MyHostApduService extends HostApduService {


    final static String TAG = "MyHostApduService";


    @Override
    public byte[] processCommandApdu(byte[] apdu, Bundle extras) {
        if (selectAidApdu(apdu)) {
            Log.v(TAG, "Application selected");
            Log.v(TAG, "Application: " + Helper.convertHexByteArrayToString(apdu));
            //return MainActivity.mCode.getBytes();
            return null;
            //return getWelcomeMessage();
        } else {
            Log.v(TAG, "Received: " + Helper.convertHexByteArrayToString(apdu));
            return getNextMessage();
        }
    }

    private byte[] getWelcomeMessage() {
        //return Helper.convertStringToHexBytes("Hello Reader");
        return ("123456789").getBytes();
    }

    private byte[] getNextMessage() {
        return ("Message from android app: ").getBytes();
    }

    private boolean selectAidApdu(byte[] apdu) {
        return apdu.length >= 2 && apdu[0] == (byte) 0 && apdu[1] == (byte) 0xa4;
    }

    @Override
    public void onDeactivated(int reason) {
        Log.v(TAG, "Deactivated: " + reason);
    }
}
