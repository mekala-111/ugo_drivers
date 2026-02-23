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
                "showRideRequest" -> {
                    val rideId = call.argument<Int>("rideId") ?: 0
                    val fare = call.argument<String>("fare") ?: ""
                    val pickupDistance = call.argument<String>("pickupDistance") ?: ""
                    val dropDistance = call.argument<String>("dropDistance") ?: ""
                    val pickup = call.argument<String>("pickup") ?: ""
                    val drop = call.argument<String>("drop") ?: ""
                    showRideRequest(rideId, fare, pickupDistance, dropDistance, pickup, drop)
                    result.success("Ride request shown")
                }
                "hideRideRequest" -> {
                    hideRideRequest()
                    result.success("Ride request hidden")
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
        handleRideActionFromIntent(intent)
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

    private fun showRideRequest(
        rideId: Int,
        fare: String,
        pickupDistance: String,
        dropDistance: String,
        pickup: String,
        drop: String
    ) {
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            val serviceIntent = Intent(this, FloatingBubbleService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        }
        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "SHOW_RIDE_REQUEST"
        intent.putExtra("ride_id", rideId)
        intent.putExtra("fare", fare)
        intent.putExtra("pickup_distance", pickupDistance)
        intent.putExtra("drop_distance", dropDistance)
        intent.putExtra("pickup", pickup)
        intent.putExtra("drop", drop)
        startService(intent)
    }

    private fun hideRideRequest() {
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            return
        }
        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "HIDE_RIDE_REQUEST"
        startService(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleRideActionFromIntent(intent)
    }

    private fun handleRideActionFromIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.getStringExtra("ride_action") ?: return
        val rideId = intent.getIntExtra("ride_id", 0)
        if (!::methodChannel.isInitialized) return
        methodChannel.invokeMethod("rideAction", mapOf("action" to action, "rideId" to rideId))
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
