package com.ugotaxi_rajkumar.driver

import android.content.Context

/**
 * Reads Flutter [FFAppState].isonline from SharedPreferences (same keys Flutter uses).
 */
object DriverOnlinePrefs {
    private const val FLUTTER_PREFS = "FlutterSharedPreferences"

    fun isDriverOnline(context: Context): Boolean {
        val p = context.applicationContext.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        return p.getBoolean("flutter.ff_isonline", false) ||
            p.getBoolean("ff_isonline", false)
    }
}
