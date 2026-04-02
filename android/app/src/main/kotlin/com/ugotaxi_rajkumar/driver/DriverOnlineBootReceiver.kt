package com.ugotaxi_rajkumar.driver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log

/**
 * After reboot, restore the online driver foreground service + bubble if prefs still say ONLINE.
 * OEM battery limits may still kill the service until the user opens the app once.
 */
class DriverOnlineBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) {
            return
        }
        if (!DriverOnlinePrefs.isDriverOnline(context)) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(context)
        ) {
            Log.w(TAG, "Boot: driver online but overlay missing — skip bubble service")
            return
        }

        val i = Intent(context, CaptainBubbleService::class.java).apply {
            putExtra(EXTRA_FROM_BOOT, true)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.applicationContext.startForegroundService(i)
            } else {
                context.applicationContext.startService(i)
            }
            Log.i(TAG, "Boot: restarted CaptainBubbleService for online driver")
        } catch (e: Exception) {
            Log.e(TAG, "Boot: failed to start service", e)
        }
    }

    companion object {
        private const val TAG = "DriverOnlineBoot"
        const val EXTRA_FROM_BOOT = "from_boot"
    }
}
