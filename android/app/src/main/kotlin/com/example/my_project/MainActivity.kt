package com.ugocabs.drivers

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.content.Context.RECEIVER_NOT_EXPORTED
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ugocabs.drivers/floating_bubble"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
                "showRideRequestOverlay" -> {
                    val pickup = call.argument<String>("pickup") ?: ""
                    val drop = call.argument<String>("drop") ?: ""
                    val fare = call.argument<String>("fare") ?: ""
                    val rideId = call.argument<String>("rideId") ?: ""
                    val accessToken = call.argument<String>("accessToken") ?: ""
                    val driverId = call.argument<String>("driverId") ?: ""
                    showRideRequestOverlay(pickup, drop, fare, rideId, accessToken, driverId)
                    result.success("Ride request overlay shown")
                }
                "hideRideRequestOverlay" -> {
                    hideRideRequestOverlay()
                    result.success("Ride request overlay hidden")
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

        // Setup broadcast receiver for overlay actions
        setupOverlayActionReceiver()
    }

    private fun setupOverlayActionReceiver() {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d("MainActivity", "Broadcast received: ${intent?.action}")
                if (intent?.action == "com.ugocabs.drivers.RIDE_ACTION") {
                    val action = intent.getStringExtra("action")
                    val rideId = intent.getStringExtra("rideId")
                    Log.d("MainActivity", "Overlay action: $action, rideId: $rideId")
                    if (action != null && rideId != null) {
                        // Send the action to Flutter
                        methodChannel.invokeMethod("onOverlayAction", mapOf(
                            "action" to action,
                            "rideId" to rideId
                        ))
                        Log.d("MainActivity", "Method channel invoked for overlay action")
                    }
                }
            }
        }

        val filter = IntentFilter("com.ugocabs.drivers.RIDE_ACTION")
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
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

    private fun showRideRequestOverlay(pickup: String, drop: String, fare: String, rideId: String, accessToken: String, driverId: String) {
        // Ensure service is running before trying to show overlay
        if (!isServiceRunning(FloatingBubbleService::class.java)) {
            val serviceIntent = Intent(this, FloatingBubbleService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        }

        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "SHOW_RIDE_OVERLAY"
        intent.putExtra("pickup", pickup)
        intent.putExtra("drop", drop)
        intent.putExtra("fare", fare)
        intent.putExtra("rideId", rideId)
        intent.putExtra("accessToken", accessToken)
        intent.putExtra("driverId", driverId)
        startService(intent)
    }

    private fun hideRideRequestOverlay() {
        val intent = Intent(this, FloatingBubbleService::class.java)
        intent.action = "HIDE_RIDE_OVERLAY"
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
