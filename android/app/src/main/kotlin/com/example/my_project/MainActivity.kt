package com.ugotaxi_rajkumar.driver

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ugotaxi_rajkumar.driver/floating_bubble"
    private lateinit var methodChannel: MethodChannel
    private val generalNotificationsChannelId = "general_notifications"
    private val rideRequestsChannelId = "ride_requests"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannels()

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startFloatingBubble" -> {
                    startFloatingBubbleService()
                    result.success("Floating bubble started")
                }
                "stopFloatingBubble" -> {
                    stopFloatingBubbleService()
                    result.success("Floating bubble stopped")
                }
                "showFloatingBubble" -> {
                    showFloatingBubble()
                    result.success("Floating bubble shown")
                }
                "hideFloatingBubble" -> {
                    hideFloatingBubble()
                    result.success("Floating bubble hidden")
                }
                "updateBubbleContent" -> {
                    val title = call.argument<String>("title") ?: ""
                    val subtitle = call.argument<String>("subtitle") ?: ""
                    updateBubbleContent(title, subtitle)
                    result.success("Bubble content updated")
                }
                "checkOverlayPermission" -> {
                    val hasPermission = Settings.canDrawOverlays(this)
                    result.success(hasPermission)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannels() {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val generalChannel = NotificationChannel(
            generalNotificationsChannelId,
            "General Updates",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Earnings, promotions, app updates"
            setSound(null, null)
            enableVibration(false)
        }

        val rideChannel = NotificationChannel(
            rideRequestsChannelId,
            "New Ride Requests",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Incoming ride requests - don't miss!"
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 800, 400, 800, 400, 800)
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            setSound(Settings.System.DEFAULT_NOTIFICATION_URI, audioAttributes)
        }

        manager.createNotificationChannel(generalChannel)
        manager.createNotificationChannel(rideChannel)
    }

    private fun startFloatingBubbleService() {
        val serviceIntent = Intent(this, FloatingBubbleService::class.java)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopFloatingBubbleService() {
        val serviceIntent = Intent(this, FloatingBubbleService::class.java)
        stopService(serviceIntent)
    }

    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName"))
            startActivity(intent)
        }
    }

    private fun showFloatingBubble() {
        // Ensure service is running before trying to show
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            val serviceIntent = Intent(this, FloatingBubbleService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        }

        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "SHOW_BUBBLE"
        startService(intent)
    }

    private fun hideFloatingBubble() {
        // Ensure service is running before trying to hide
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            val serviceIntent = Intent(this, FloatingBubbleService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        }

        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "HIDE_BUBBLE"
        startService(intent)
    }

    private fun updateBubbleContent(title: String, subtitle: String) {
        // Ensure service is running before trying to update
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            val serviceIntent = Intent(this, FloatingBubbleService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        }

        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "UPDATE_BUBBLE_CONTENT"
        intent.putExtra("title", title)
        intent.putExtra("subtitle", subtitle)
        startService(intent)
    }

    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
