package com.ugotaxi_rajkumar.driver

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.*
import android.widget.ImageView
import android.widget.TextView
import android.widget.Button
import android.media.MediaPlayer
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collectLatest

/**
 * CaptainBubbleService displays a floating overlay on the screen.
 * It manages both the small draggable bubble and the full-screen Ride Request Card.
 */
class CaptainBubbleService : Service() {
    companion object {
        private const val TAG = "CaptainBubbleService"
        const val ACTION_SET_SUPPRESS_OVERLAY = "com.ugotaxi_rajkumar.driver.SET_SUPPRESS_OVERLAY"
        const val EXTRA_SUPPRESS_OVERLAY = "suppress_overlay"
        const val ACTION_UPDATE_BADGE = "com.ugotaxi_rajkumar.driver.UPDATE_BADGE"
        const val EXTRA_PENDING_COUNT = "pending_count"

        /**
         * When true, the small draggable bubble is hidden (driver is inside the app UI).
         * Foreground service + notification stay active so Android 15+ and OEMs see a valid FGS.
         */
        @Volatile
        var suppressBubbleOverlay: Boolean = false

        /** Optional badge on bubble (e.g. stacked SEARCHING rides). */
        @Volatile
        var pendingRequestCount: Int = 0
    }

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var rideRequestView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    
    private val notificationId = 1001
    private val channelId = "floating_bubble_service"
    
    private val serviceScope = CoroutineScope(Dispatchers.Main + Job())
    private var lastRideState: RideState = RideState.Idle

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(notificationId, createNotification())
        
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        serviceScope.launch {
            RideEventRepository.rideState.collectLatest { state ->
                lastRideState = state
                applyRideState(state)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SET_SUPPRESS_OVERLAY -> {
                suppressBubbleOverlay = intent.getBooleanExtra(EXTRA_SUPPRESS_OVERLAY, suppressBubbleOverlay)
                refreshOverlayForCurrentState()
                startForeground(notificationId, createNotification())
            }
            ACTION_UPDATE_BADGE -> {
                pendingRequestCount = intent.getIntExtra(EXTRA_PENDING_COUNT, 0).coerceAtLeast(0)
                bubbleView?.findViewById<View>(R.id.bubble_badge)?.visibility =
                    if (pendingRequestCount > 0) View.VISIBLE else View.GONE
            }
        }
        return START_STICKY
    }

    /**
     * Swiping the app from Recents: restart FGS if the driver is still marked ONLINE in prefs.
     * Does not guarantee survival on aggressive OEMs (MIUI, etc.).
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        if (!DriverOnlinePrefs.isDriverOnline(this)) {
            Log.i(TAG, "onTaskRemoved: driver offline — not restarting")
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Log.w(TAG, "onTaskRemoved: no overlay permission — not restarting")
            return
        }
        try {
            val i = Intent(applicationContext, CaptainBubbleService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                applicationContext.startForegroundService(i)
            } else {
                applicationContext.startService(i)
            }
            Log.i(TAG, "onTaskRemoved: restarted foreground service (still online)")
        } catch (e: Exception) {
            Log.e(TAG, "onTaskRemoved: restart failed", e)
        }
    }

    private fun applyRideState(state: RideState) {
        when (state) {
            is RideState.NewRequest -> {
                hideBubble()
                showRideRequestOverlay(state)
            }
            is RideState.Idle -> {
                hideRideRequestOverlay()
                showBubbleIfAllowed()
            }
            is RideState.Ongoing -> {
                hideRideRequestOverlay()
                showBubbleIfAllowed()
            }
        }
    }

    private fun refreshOverlayForCurrentState() {
        applyRideState(lastRideState)
    }

    private fun showBubbleIfAllowed() {
        if (suppressBubbleOverlay) {
            hideBubble()
            return
        }
        showBubble()
    }

    private fun showRideRequestOverlay(state: RideState.NewRequest) {
        if (rideRequestView != null) return
        if (!hasOverlayPermission()) {
            Log.w(TAG, "Overlay permission missing, skipping ride request overlay")
            return
        }

        rideRequestView = LayoutInflater.from(this).inflate(R.layout.activity_ride_request, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        try {
            windowManager.addView(rideRequestView, params)
        } catch (e: SecurityException) {
            Log.e(TAG, "Failed to add ride request overlay due to missing permission", e)
            rideRequestView = null
            return
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add ride request overlay", e)
            rideRequestView = null
            return
        }

        rideRequestView?.apply {
            findViewById<TextView>(R.id.ride_fare)?.text = state.fare
            findViewById<TextView>(R.id.pickup_distance)?.text = state.pickupDistance
            findViewById<TextView>(R.id.drop_distance)?.text = state.dropDistance
            
            // Payment method logic
            findViewById<TextView>(R.id.payment_method_badge)?.apply {
                text = state.paymentMethod.uppercase()
                val bgd = GradientDrawable()
                bgd.cornerRadius = 8f * resources.displayMetrics.density
                if (state.paymentMethod.equals("cash", ignoreCase = true)) {
                    setTextColor(Color.parseColor("#27AE60"))
                    bgd.setColor(Color.parseColor("#EAFDF1"))
                    bgd.setStroke(2, Color.parseColor("#A8E6CF"))
                } else {
                    setTextColor(Color.parseColor("#2980B9"))
                    bgd.setColor(Color.parseColor("#EBF5FB"))
                    bgd.setStroke(2, Color.parseColor("#AED6F1"))
                }
                background = bgd
            }

            fun formatAddress(address: String, zipViewId: Int, mainViewId: Int, subViewId: Int) {
                // Address comes as "506000 Dilsukhnagar, Hyderabad, Telangana" (example)
                // Split by first space to get ZIP and rest.
                val parts = address.split(" ", limit = 2)
                var zipText = ""
                var mainText = address
                var subText = ""
                
                if (parts.size == 2 && parts[0].length in 5..7 && parts[0].all { it.isDigit() }) {
                    zipText = parts[0]
                    val rest = parts[1]
                    val subParts = rest.split(",", limit = 2)
                    mainText = subParts[0].trim()
                    if (subParts.size > 1) subText = subParts[1].trim()
                } else {
                    val subParts = address.split(",", limit = 2)
                    mainText = subParts[0].trim()
                    if (subParts.size > 1) subText = subParts[1].trim()
                }
                
                findViewById<TextView>(zipViewId)?.text = zipText
                findViewById<TextView>(mainViewId)?.text = mainText
                findViewById<TextView>(subViewId)?.text = subText
            }
            
            formatAddress(state.pickup, R.id.pickup_zip, R.id.pickup_main, R.id.pickup_sub)
            formatAddress(state.drop, R.id.drop_zip, R.id.drop_main, R.id.drop_sub)

            val dp = resources.displayMetrics.density
            val mainColorStr = if (state.isPro) "#E0C42F" else "#43A047"
            val mainColor = Color.parseColor(mainColorStr)
            
            // Dynamic Borders & Backgrounds
            val borderDrawable = GradientDrawable()
            borderDrawable.setColor(Color.WHITE)
            borderDrawable.cornerRadius = 32f * dp
            borderDrawable.setStroke((3 * dp).toInt(), mainColor)
            findViewById<View>(R.id.card_container)?.background = borderDrawable
            
            val topBannerBg = GradientDrawable()
            topBannerBg.setColor(mainColor)
            topBannerBg.cornerRadii = floatArrayOf(28f*dp, 28f*dp, 28f*dp, 28f*dp, 0f, 0f, 0f, 0f)
            findViewById<View>(R.id.top_banner)?.background = topBannerBg
            
            findViewById<TextView>(R.id.request_type_text)?.apply {
                text = if (state.isPro) "NEW PRO REQUEST" else "NEW REQUEST"
                setTextColor(if (state.isPro) Color.BLACK else Color.WHITE)
            }
            findViewById<TextView>(R.id.timer_text)?.apply {
                setTextColor(if (state.isPro) Color.BLACK else Color.WHITE)
                // Countdown logic is not in Service natively yet, but we will set static default or rely on refresh
                text = "30s"
            }
            
            val fareBoxBg = GradientDrawable()
            fareBoxBg.setColor(Color.WHITE)
            fareBoxBg.cornerRadius = 12f * dp
            fareBoxBg.setStroke((1f * dp).toInt(), Color.parseColor("#D0D0D0"))
            findViewById<View>(R.id.fare_box_container)?.background = fareBoxBg
            
            val dropPillBg = GradientDrawable()
            dropPillBg.setColor(Color.parseColor("#FFEBEE"))
            dropPillBg.cornerRadius = 12f * dp
            dropPillBg.setStroke((1f * dp).toInt(), Color.parseColor("#EF5350"))
            findViewById<View>(R.id.drop_pill)?.background = dropPillBg
            
            val pickupPillBg = GradientDrawable()
            pickupPillBg.setColor(Color.parseColor("#E8F5E9"))
            pickupPillBg.cornerRadius = 12f * dp
            pickupPillBg.setStroke((1f * dp).toInt(), Color.parseColor("#66BB6A"))
            findViewById<View>(R.id.pickup_pill)?.background = pickupPillBg
            
            val btnAcceptBg = GradientDrawable()
            btnAcceptBg.setColor(mainColor)
            btnAcceptBg.cornerRadius = 16f * dp
            findViewById<Button>(R.id.btn_accept)?.apply {
                background = btnAcceptBg
                setTextColor(if (state.isPro) Color.WHITE else Color.WHITE)
                setOnClickListener { sendActionToMain("accept", state.id) }
            }
            
            val btnDeclineBg = GradientDrawable()
            btnDeclineBg.setColor(Color.parseColor("#E74C3C"))
            btnDeclineBg.cornerRadius = 16f * dp
            findViewById<Button>(R.id.btn_decline)?.apply {
                background = btnDeclineBg
                setOnClickListener { sendActionToMain("decline", state.id) }
            }
        }
        
        try {
            if (mediaPlayer == null) {
                mediaPlayer = MediaPlayer.create(this, R.raw.ride_request)
                mediaPlayer?.isLooping = true
            }
            mediaPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun hideRideRequestOverlay() {
        rideRequestView?.let {
            if (it.isAttachedToWindow) {
                windowManager.removeView(it)
            }
            rideRequestView = null
        }
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
            mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun sendActionToMain(action: String, rideId: Int) {
        // Decline must reach Flutter (reject API + local ignore set); overlay-only clear
        // left the ride SEARCHING and forced a second decline in-app.
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("ride_action", action)
            putExtra("ride_id", rideId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
        RideEventRepository.clearState()
    }

    private fun showBubble() {
        if (bubbleView != null) return
        if (!hasOverlayPermission()) {
            Log.w(TAG, "Overlay permission missing, skipping floating bubble")
            return
        }

        bubbleView = LayoutInflater.from(this).inflate(R.layout.floating_bubble, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0
        params.y = 500

        try {
            windowManager.addView(bubbleView, params)
        } catch (e: SecurityException) {
            Log.e(TAG, "Failed to add bubble overlay due to missing permission", e)
            bubbleView = null
            return
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add bubble overlay", e)
            bubbleView = null
            return
        }

        bubbleView?.findViewById<View>(R.id.bubble_badge)?.visibility =
            if (pendingRequestCount > 0) View.VISIBLE else View.GONE

        val container = bubbleView?.findViewById<View>(R.id.bubble_container)

        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var isMoved = false
        val touchSlop = 10f

        container?.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isMoved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val moveX = event.rawX - initialTouchX
                    val moveY = event.rawY - initialTouchY

                    if (Math.abs(moveX) > touchSlop || Math.abs(moveY) > touchSlop) {
                        isMoved = true
                    }

                    params.x = initialX + moveX.toInt()
                    params.y = initialY + moveY.toInt()
                    windowManager.updateViewLayout(bubbleView, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!isMoved) {
                        // It's a tap! Open the MainActivity
                        val intent = Intent(this@CaptainBubbleService, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        }
                        startActivity(intent)
                    } else {
                        // Drag released -> Snap to nearest screen edge
                        val displayMetrics = resources.displayMetrics
                        val screenWidth = displayMetrics.widthPixels
                        
                        val middle = screenWidth / 2
                        val targetX = if (params.x + (view.width / 2) < middle) 0 else (screenWidth - view.width)
                        
                        params.x = targetX
                        windowManager.updateViewLayout(bubbleView, params)
                    }
                    true
                }
                else -> false
            }
        }

        // Do not stop the service (driver stays ONLINE). Open app so they can go offline.
        bubbleView?.findViewById<ImageView>(R.id.close_button)?.setOnClickListener {
            val i = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("from_bubble", true)
            }
            startActivity(i)
        }
    }

    private fun hideBubble() {
        bubbleView?.let {
            if (it.isAttachedToWindow) {
                windowManager.removeView(it)
            }
            bubbleView = null
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Floating Bubble Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val body = if (suppressBubbleOverlay) {
            "Tap to return to the app. You are online."
        } else {
            "Floating bubble active — tap bubble or notification to open the app."
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("UGO Driver — Online")
            .setContentText(body)
            .setSmallIcon(R.drawable.ugo_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        hideBubble()
        hideRideRequestOverlay()
    }
}
