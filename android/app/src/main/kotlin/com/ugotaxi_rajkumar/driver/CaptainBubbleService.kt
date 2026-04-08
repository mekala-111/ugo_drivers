package com.ugotaxi_rajkumar.driver

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.animation.ValueAnimator
import android.graphics.PixelFormat
import android.os.Build
import android.content.pm.ServiceInfo
import android.os.CountDownTimer
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.*
import android.widget.ImageView
import android.widget.TextView
import android.widget.Button
import android.widget.FrameLayout
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
    private var rideCountDown: CountDownTimer? = null
    private var isRideCardCollapsed: Boolean = false
    
    private val notificationId = 1001
    private val channelId = "floating_bubble_service"
    private val prefsName = "captain_bubble_ui_prefs"
    private val prefBubbleX = "bubble_x"
    private val prefBubbleY = "bubble_y"
    private val prefBubblePosSet = "bubble_pos_set"
    
    private val serviceScope = CoroutineScope(Dispatchers.Main + Job())
    private var lastRideState: RideState = RideState.Idle

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        
        safeStartForeground()
        
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
                safeStartForeground()
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

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // Re-apply overlays so they remain within safe drag bounds after rotate.
        hideBubble()
        hideRideRequestOverlay()
        refreshOverlayForCurrentState()
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

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun getScreenSizePx(): Pair<Int, Int> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = windowManager.currentWindowMetrics.bounds
            bounds.width() to bounds.height()
        } else {
            val dm = resources.displayMetrics
            dm.widthPixels to dm.heightPixels
        }
    }

    private fun statusBarInsetPx(): Int {
        val id = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else dp(24)
    }

    private fun navBarInsetPx(): Int {
        val id = resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else dp(20)
    }

    private fun bubbleSizePx(screenWidth: Int): Int {
        val widthDp = screenWidth / resources.displayMetrics.density
        return when {
            widthDp < 360f -> dp(54)
            widthDp < 420f -> dp(60)
            widthDp < 600f -> dp(64)
            else -> dp(70)
        }
    }

    private fun restoreOrDefaultBubblePosition(params: WindowManager.LayoutParams, bubbleW: Int, bubbleH: Int) {
        val (screenW, screenH) = getScreenSizePx()
        val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val hasSaved = prefs.getBoolean(prefBubblePosSet, false)

        val safeTop = statusBarInsetPx() + dp(8)
        val safeBottom = navBarInsetPx() + dp(8)
        val maxX = (screenW - bubbleW).coerceAtLeast(0)
        val maxY = (screenH - bubbleH - safeBottom).coerceAtLeast(safeTop)

        val restoredX = prefs.getInt(prefBubbleX, maxX)
        val restoredY = prefs.getInt(prefBubbleY, (screenH * 0.45f).toInt())

        params.x = if (hasSaved) restoredX else maxX
        params.y = if (hasSaved) restoredY else (screenH * 0.45f).toInt()
        clampBubbleWithinScreen(params, bubbleW, bubbleH)
    }

    private fun persistBubblePosition(x: Int, y: Int) {
        getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(prefBubblePosSet, true)
            .putInt(prefBubbleX, x)
            .putInt(prefBubbleY, y)
            .apply()
    }

    private fun clampBubbleWithinScreen(params: WindowManager.LayoutParams, bubbleW: Int, bubbleH: Int) {
        val (screenW, screenH) = getScreenSizePx()
        val safeTop = statusBarInsetPx() + dp(8)
        val safeBottom = navBarInsetPx() + dp(8)
        val maxX = (screenW - bubbleW).coerceAtLeast(0)
        val maxY = (screenH - bubbleH - safeBottom).coerceAtLeast(safeTop)
        params.x = params.x.coerceIn(0, maxX)
        params.y = params.y.coerceIn(safeTop, maxY)
    }

    private fun snapBubbleToEdge(
        params: WindowManager.LayoutParams,
        bubbleW: Int,
        bubbleH: Int,
        animate: Boolean = true
    ) {
        clampBubbleWithinScreen(params, bubbleW, bubbleH)
        val (screenW, _) = getScreenSizePx()
        val targetX = if (params.x + (bubbleW / 2) < screenW / 2) 0 else (screenW - bubbleW).coerceAtLeast(0)
        if (!animate) {
            params.x = targetX
            bubbleView?.let {
                if (it.isAttachedToWindow) {
                    windowManager.updateViewLayout(it, params)
                }
            }
            persistBubblePosition(params.x, params.y)
            return
        }
        val startX = params.x
        ValueAnimator.ofInt(startX, targetX).apply {
            duration = 180L
            addUpdateListener { animator ->
                params.x = animator.animatedValue as Int
                bubbleView?.let {
                    if (it.isAttachedToWindow) {
                        windowManager.updateViewLayout(it, params)
                    }
                }
            }
            start()
        }
        persistBubblePosition(targetX, params.y)
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

        isRideCardCollapsed = false
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
            val (screenW, screenH) = getScreenSizePx()
            val density = resources.displayMetrics.density
            val screenDp = screenW / density
            val isLandscape =
                resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

            val cardWidth = when {
                screenDp < 360f -> (screenW * 0.97f).toInt()
                screenDp < 600f -> (screenW * 0.94f).toInt()
                else -> minOf((screenW * 0.72f).toInt(), dp(560))
            }
            val cardMarginBottom = navBarInsetPx() + dp(6)
            val maxScrollHeight = if (isLandscape) {
                (screenH * 0.34f).toInt()
            } else {
                if (screenDp < 360f) (screenH * 0.36f).toInt() else (screenH * 0.43f).toInt()
            }.coerceIn(dp(190), dp(430))

            findViewById<View>(R.id.card_container)?.layoutParams =
                FrameLayout.LayoutParams(cardWidth, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                    gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                    bottomMargin = cardMarginBottom
                }
            findViewById<View>(R.id.overlay_card_scroll)?.layoutParams =
                findViewById<View>(R.id.overlay_card_scroll)?.layoutParams?.apply {
                    height = maxScrollHeight
                }

            val compactFare = findViewById<TextView>(R.id.compact_fare)
            val compactPickup = findViewById<TextView>(R.id.compact_pickup_distance)
            val compactDrop = findViewById<TextView>(R.id.compact_drop_distance)
            val compactMeta = findViewById<View>(R.id.card_compact_meta)
            val scrollSection = findViewById<View>(R.id.overlay_card_scroll)
            val collapseBtn = findViewById<ImageView>(R.id.btn_collapse_overlay)
            val closeBtn = findViewById<ImageView>(R.id.btn_close_overlay)
            val maxCardDrag = (screenH * 0.28f).toInt().coerceAtLeast(dp(120)).toFloat()

            findViewById<TextView>(R.id.ride_fare)?.text = state.fare
            findViewById<TextView>(R.id.pickup_distance)?.text = state.pickupDistance
            findViewById<TextView>(R.id.drop_distance)?.text = state.dropDistance
            compactFare?.text = state.fare
            compactPickup?.text = "Pickup ${state.pickupDistance}"
            compactDrop?.text = "Drop ${state.dropDistance}"
            
            // Payment method logic
            findViewById<TextView>(R.id.payment_method_badge)?.apply {
                text = state.paymentMethod.uppercase().ifEmpty { "UNKNOWN" }
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

            fun applyCollapsedState(collapsed: Boolean, animate: Boolean = true) {
                isRideCardCollapsed = collapsed
                if (animate) {
                    scrollSection?.animate()?.alpha(if (collapsed) 0f else 1f)?.setDuration(150)?.start()
                    if (collapsed) {
                        compactMeta?.alpha = 0f
                        compactMeta?.visibility = View.VISIBLE
                        compactMeta?.animate()?.alpha(1f)?.setDuration(150)?.start()
                    } else {
                        scrollSection?.visibility = View.VISIBLE
                        compactMeta?.animate()?.alpha(0f)?.setDuration(120)?.withEndAction {
                            compactMeta.visibility = View.GONE
                        }?.start()
                    }
                    if (collapsed) {
                        scrollSection?.postDelayed({ scrollSection.visibility = View.GONE }, 130)
                    }
                } else {
                    scrollSection?.visibility = if (collapsed) View.GONE else View.VISIBLE
                    compactMeta?.visibility = if (collapsed) View.VISIBLE else View.GONE
                    scrollSection?.alpha = if (collapsed) 0f else 1f
                    compactMeta?.alpha = if (collapsed) 1f else 0f
                }
                collapseBtn?.setImageResource(
                    if (collapsed) android.R.drawable.arrow_up_float
                    else android.R.drawable.arrow_down_float
                )
                collapseBtn?.contentDescription =
                    if (collapsed) "Expand ride request details" else "Collapse ride request details"
            }

            applyCollapsedState(collapsed = false, animate = false)

            collapseBtn?.setOnClickListener {
                val nextCollapsed = !isRideCardCollapsed
                applyCollapsedState(nextCollapsed, animate = true)
                this.animate()
                    .translationY(if (nextCollapsed) maxCardDrag * 0.7f else 0f)
                    .setDuration(170)
                    .start()
            }

            closeBtn?.setOnClickListener {
                val i = Intent(this@CaptainBubbleService, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra("from_bubble", true)
                }
                startActivity(i)
            }

            val dragSurface = findViewById<View>(R.id.overlay_drag_handle) ?: findViewById(R.id.top_banner)
            var startTouchY = 0f
            var startTranslationY = 0f

            dragSurface?.setOnTouchListener { _, event ->
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        startTouchY = event.rawY
                        startTranslationY = this.translationY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dy = event.rawY - startTouchY
                        this.translationY = (startTranslationY + dy).coerceIn(0f, maxCardDrag)
                        true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        val shouldCollapse = this.translationY > (maxCardDrag * 0.45f)
                        applyCollapsedState(shouldCollapse, animate = true)
                        this.animate()
                            .translationY(if (shouldCollapse) maxCardDrag * 0.7f else 0f)
                            .setDuration(170)
                            .start()
                        true
                    }
                    else -> false
                }
            }
        }

        rideCountDown?.cancel()
        rideCountDown = object : CountDownTimer(30_000L, 1_000L) {
            override fun onTick(millisUntilFinished: Long) {
                rideRequestView?.findViewById<TextView>(R.id.timer_text)?.text =
                    "${(millisUntilFinished / 1000L).coerceAtLeast(0)}s"
            }

            override fun onFinish() {
                rideRequestView?.findViewById<TextView>(R.id.timer_text)?.text = "0s"
            }
        }.start()
        
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
        rideCountDown?.cancel()
        rideCountDown = null
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
        // 1. If decline, persist immediately from native so Flutter sees it on cold start.
        if (action == "decline") {
            try {
                val p = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val currentSet = p.getStringSet("flutter.ff_sessionDeclinedRideIds", null) ?: mutableSetOf<String>()
                val newSet = currentSet.toMutableSet()
                newSet.add(rideId.toString())
                
                // Keep the list manageable (match Flutter side limit)
                if (newSet.size > 50) {
                    val iterator = newSet.iterator()
                    if (iterator.hasNext()) {
                        iterator.next()
                        iterator.remove()
                    }
                }
                
                p.edit().putStringSet("flutter.ff_sessionDeclinedRideIds", newSet).apply()
                Log.d(TAG, "Native: Persisted declined ride $rideId to SharedPreferences")
            } catch (e: Exception) {
                Log.e(TAG, "Native: Failed to persist decline", e)
            }
        }

        // 2. Try direct method channel if MainActivity instance is alive (warm start)
        if (action == "decline") {
            val sent = MainActivity.sendRideActionDirectly(action, rideId)
            if (sent) {
                RideEventRepository.clearState()
                return
            }
        }

        // 3. Fallback: Start activity (Accept always starts activity; Decline starts if process was dead)
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("ride_action", action)
            putExtra("ride_id", rideId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            if (action == "decline") {
                putExtra("background_action", true)
            }
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
        val (screenW, _) = getScreenSizePx()
        val computedBubbleSize = bubbleSizePx(screenW)
        restoreOrDefaultBubblePosition(params, computedBubbleSize, computedBubbleSize)

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

        bubbleView?.findViewById<View>(R.id.bubble_container)?.layoutParams =
            bubbleView?.findViewById<View>(R.id.bubble_container)?.layoutParams?.apply {
                width = computedBubbleSize
                height = computedBubbleSize
            }

        bubbleView?.findViewById<View>(R.id.bubble_badge)?.visibility =
            if (pendingRequestCount > 0) View.VISIBLE else View.GONE

        val container = bubbleView?.findViewById<View>(R.id.bubble_container)
        val closeButton = bubbleView?.findViewById<ImageView>(R.id.close_button)

        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var isMoved = false
        val touchSlop = dp(4).toFloat()

        container?.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isMoved = false
                    closeButton?.visibility = View.GONE
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val moveX = event.rawX - initialTouchX
                    val moveY = event.rawY - initialTouchY

                    if (kotlin.math.abs(moveX) > touchSlop || kotlin.math.abs(moveY) > touchSlop) {
                        isMoved = true
                    }

                    params.x = initialX + moveX.toInt()
                    params.y = initialY + moveY.toInt()
                    clampBubbleWithinScreen(params, computedBubbleSize, computedBubbleSize)
                    bubbleView?.let {
                        if (it.isAttachedToWindow) {
                            windowManager.updateViewLayout(it, params)
                        }
                    }
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
                        // Drag released -> snap to nearest safe edge and persist position.
                        snapBubbleToEdge(
                            params = params,
                            bubbleW = computedBubbleSize,
                            bubbleH = computedBubbleSize,
                            animate = true
                        )
                    }
                    true
                }
                else -> false
            }
        }

        container?.setOnLongClickListener {
            closeButton?.visibility = if (closeButton?.visibility == View.VISIBLE) View.GONE else View.VISIBLE
            true
        }

        // Do not stop the service (driver stays ONLINE). Open app so they can go offline.
        closeButton?.setOnClickListener {
            val i = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("from_bubble", true)
            }
            startActivity(i)
            closeButton.visibility = View.GONE
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
            "Waiting For Rides..."
        } else {
            "Waiting For Rides..."
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

    /**
     * Safely starts the foreground service with the correct type for Android 14+.
     * Catches ForegroundServiceStartNotAllowedException on Android 12+.
     */
    private fun safeStartForeground() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    notificationId,
                    createNotification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
                )
            } else {
                startForeground(notificationId, createNotification())
            }
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && 
                e is ForegroundServiceStartNotAllowedException) {
                Log.e(TAG, "Failed to start foreground service from background", e)
            } else {
                Log.e(TAG, "Failed to start foreground service", e)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        hideBubble()
        hideRideRequestOverlay()
    }
}
