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

package com.lomo.demo.nfc.generic.util;

import static android.content.Context.MODE_PRIVATE;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import java.util.Map;
import java.util.Set;

/**
 * Created by CS on 6/6/2025.
 */

/**
 * Class managing the application preferences
 */
public final class PreferencesManager {

    static String TAG="PreferencesManager";


    private SharedPreferences mSharedPreferences;
    private final String PREFS_NAME = "ST25NFC_APPLICATION_PREFERENCES";


    private PreferencesManager(Context context) {
        // needed to retrieve pair value keys for location preferencies
        mSharedPreferences = context.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);


    }


    public static PreferencesManager createPreferencesManager(Context context) {
        return new PreferencesManager(context);
    }


    public static void loadPreferences(Context context) {
        String preferenceString = "";
        Map<String, ?> prefs = PreferenceManager.getDefaultSharedPreferences(context).getAll();
        for (String key : prefs.keySet()) {
            Object pref = prefs.get(key);
            String printVal = "";
            if (pref instanceof Boolean) {
                printVal =  key + " : " + (Boolean) pref;
            }
            if (pref instanceof Float) {
                printVal =  key + " : " + (Float) pref;
            }
            if (pref instanceof Integer) {
                printVal =  key + " : " + (Integer) pref;
            }
            if (pref instanceof Long) {
                printVal =  key + " : " + (Long) pref;
            }
            if (pref instanceof String) {
                printVal =  key + " : " + (String) pref;
            }
            if (pref instanceof Set<?>) {
                printVal =  key + " : " + (Set<String>) pref;
            }
            // Every new preference goes to a new line
            //prefTextView.append(printVal + "\n\n");
            preferenceString = preferenceString + printVal + "\n\n";
        }
        Log.v(TAG, preferenceString);
    }

    public static boolean isPasswordOnOneFieldSelected(Context context) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        boolean preference = sp.getBoolean("PasswordOnOneField", false);
        return preference;
    }

    public static boolean isPasswordObfuscatedSelected(Context context) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        boolean preference = sp.getBoolean("PasswordObfuscated", false);
        return preference;
    }
}
