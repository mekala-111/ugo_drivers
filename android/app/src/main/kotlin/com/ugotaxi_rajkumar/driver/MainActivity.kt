package com.ugotaxi_rajkumar.driver

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.media.AudioAttributes
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ugotaxi_rajkumar.driver/floating_bubble"
    private val INSTALL_REFERRER_CHANNEL = "com.ugotaxi_rajkumar.driver/install_referrer"
    private lateinit var methodChannel: MethodChannel
    private lateinit var installReferrerChannel: MethodChannel
    private val generalNotificationsChannelId = "general_notifications"
    private val rideRequestsChannelId = "ride_requests"
    private var pendingRideAction: Map<String, Any>? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannels()

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startFloatingBubble" -> {
                    val suppressInitially =
                        call.argument<Boolean>("overlaySuppressedInitially") ?: false
                    CaptainBubbleService.suppressBubbleOverlay = suppressInitially
                    startFloatingBubbleService()
                    result.success("Floating bubble started")
                }
                "setBubbleOverlaySuppressed" -> {
                    val suppressed = call.argument<Boolean>("suppressed") ?: true
                    setBubbleOverlaySuppressed(suppressed)
                    result.success(null)
                }
                "updateBubbleBadge" -> {
                    val count = call.argument<Int>("count") ?: 0
                    sendBubbleServiceCommand(
                        CaptainBubbleService.ACTION_UPDATE_BADGE,
                        mapOf(CaptainBubbleService.EXTRA_PENDING_COUNT to count)
                    )
                    result.success(null)
                }
                "isBubbleServiceRunning" -> {
                    result.success(isServiceRunning(CaptainBubbleService::class.java))
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
                    val paymentMethod = call.argument<String>("paymentMethod") ?: ""
                    val pickupDistance = call.argument<String>("pickupDistance") ?: ""
                    val dropDistance = call.argument<String>("dropDistance") ?: ""
                    val pickup = call.argument<String>("pickup") ?: ""
                    val drop = call.argument<String>("drop") ?: ""
                    val isPro = call.argument<Boolean>("isPro") ?: false
                    showRideRequest(rideId, fare, paymentMethod, pickupDistance, dropDistance, pickup, drop, isPro)
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
                "consumePendingRideAction" -> {
                    result.success(pendingRideAction)
                    pendingRideAction = null
                }
                "clearPendingRideAction" -> {
                    pendingRideAction = null
                    result.success(null)
                }
                "moveTaskToBack" -> {
                    // Used for "Uber-like" back behavior: do not finish the Activity.
                    // This prevents orphaned overlays/bubbles when the app goes to background.
                    moveTaskToBack(true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        installReferrerChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INSTALL_REFERRER_CHANNEL
        )
        installReferrerChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstallReferrer" -> fetchInstallReferrer(result)
                else -> result.notImplemented()
            }
        }
        handleRideActionFromIntent(intent)
        flushPendingRideAction()
    }

    private fun fetchInstallReferrer(result: MethodChannel.Result) {
        val referrerClient = InstallReferrerClient.newBuilder(this).build()
        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                when (responseCode) {
                    InstallReferrerClient.InstallReferrerResponse.OK -> {
                        try {
                            val response = referrerClient.installReferrer
                            result.success(response.installReferrer)
                        } catch (e: Exception) {
                            result.error("INSTALL_REFERRER_ERROR", e.message, null)
                        } finally {
                            referrerClient.endConnection()
                        }
                    }

                    InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED,
                    InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                        result.success(null)
                        referrerClient.endConnection()
                    }

                    else -> {
                        result.success(null)
                        referrerClient.endConnection()
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                // No-op
            }
        })
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
        val serviceIntent = Intent(this, CaptainBubbleService::class.java).apply {
            action = CaptainBubbleService.ACTION_SET_SUPPRESS_OVERLAY
            putExtra(
                CaptainBubbleService.EXTRA_SUPPRESS_OVERLAY,
                CaptainBubbleService.suppressBubbleOverlay
            )
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun setBubbleOverlaySuppressed(suppressed: Boolean) {
        CaptainBubbleService.suppressBubbleOverlay = suppressed
        sendBubbleServiceCommand(
            CaptainBubbleService.ACTION_SET_SUPPRESS_OVERLAY,
            mapOf(CaptainBubbleService.EXTRA_SUPPRESS_OVERLAY to suppressed)
        )
    }

    private fun sendBubbleServiceCommand(action: String, extras: Map<String, Any>) {
        val i = Intent(this, CaptainBubbleService::class.java).apply {
            this.action = action
            extras.forEach { (k, v) ->
                when (v) {
                    is Boolean -> putExtra(k, v)
                    is Int -> putExtra(k, v)
                    else -> putExtra(k, v.toString())
                }
            }
        }
        if (!isServiceRunning(CaptainBubbleService::class.java)) {
            return
        }
        // Service is already in foreground — deliver intent with startService only.
        startService(i)
    }

    private fun stopFloatingBubbleService() {
        CaptainBubbleService.suppressBubbleOverlay = false
        CaptainBubbleService.pendingRequestCount = 0
        val serviceIntent = Intent(this, CaptainBubbleService::class.java)
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
        // Ensure service is running
        if (!isServiceRunning(CaptainBubbleService::class.java)) {
            startFloatingBubbleService()
        }
    }

    private fun hideFloatingBubble() {
        stopFloatingBubbleService()
        RideEventRepository.clearState()
    }

    private fun updateBubbleContent(title: String, subtitle: String) {
        // This can be used for extra info, but state is main driver
    }

    private fun showRideRequest(
        rideId: Int,
        fare: String,
        paymentMethod: String,
        pickupDistance: String,
        dropDistance: String,
        pickup: String,
        drop: String,
        isPro: Boolean
    ) {
        if (!isServiceRunning(CaptainBubbleService::class.java)) {
            startFloatingBubbleService()
        }
        
        RideEventRepository.updateState(
            RideState.NewRequest(rideId, fare, paymentMethod, pickupDistance, dropDistance, pickup, drop, isPro)
        )
    }

    private fun hideRideRequest() {
        RideEventRepository.clearState()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleRideActionFromIntent(intent)
        flushPendingRideAction()
    }

    private fun handleRideActionFromIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.getStringExtra("ride_action") ?: return
        val rideId = intent.getIntExtra("ride_id", 0)
        if (rideId <= 0) return
        pendingRideAction = mapOf("action" to action, "rideId" to rideId)
    }

    private fun flushPendingRideAction() {
        if (!::methodChannel.isInitialized) return
        val payload = pendingRideAction ?: return
        methodChannel.invokeMethod("rideAction", payload)
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

    /**
     * Same moment Rapido uses: user pressed Home / Recents / left the app.
     * Starts [CaptainBubbleService] while Flutter `paused` may not have run yet, so the
     * captain bubble + foreground notification still appear for online drivers.
     */
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (!isFlutterDriverCaptainOnline()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            return
        }
        if (!isServiceRunning(CaptainBubbleService::class.java)) {
            startFloatingBubbleService()
        }
    }

    /** Mirrors Flutter [FFAppState].isonline persisted via shared_preferences. */
    private fun isFlutterDriverCaptainOnline(): Boolean =
        DriverOnlinePrefs.isDriverOnline(this)
}
