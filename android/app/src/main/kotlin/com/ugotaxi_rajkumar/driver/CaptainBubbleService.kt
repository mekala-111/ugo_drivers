package com.ugotaxi_rajkumar.driver

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import android.widget.TextView
import android.widget.Button
import android.media.MediaPlayer
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collectLatest

/**
 * CaptainBubbleService displays a floating overlay on the screen.
 * It manages both the small draggable bubble and the full-screen Ride Request Card.
 */
class CaptainBubbleService : Service() {

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var rideRequestView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    
    private val notificationId = 1001
    private val channelId = "floating_bubble_service"
    
    private val serviceScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(notificationId, createNotification())
        
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        serviceScope.launch {
            RideEventRepository.rideState.collectLatest { state ->
                when (state) {
                    is RideState.NewRequest -> {
                        hideBubble()
                        showRideRequestOverlay(state)
                    }
                    is RideState.Idle -> {
                        hideRideRequestOverlay()
                        showBubble()
                    }
                    is RideState.Ongoing -> {
                        hideRideRequestOverlay()
                        showBubble()
                    }
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun showRideRequestOverlay(state: RideState.NewRequest) {
        if (rideRequestView != null) return

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

        windowManager.addView(rideRequestView, params)

        rideRequestView?.apply {
            findViewById<TextView>(R.id.pickup_address)?.text = state.pickup
            findViewById<TextView>(R.id.drop_address)?.text = state.drop
            findViewById<TextView>(R.id.ride_fare)?.text = state.fare
            findViewById<TextView>(R.id.pickup_distance)?.text = state.pickupDistance

            val pmBadge = findViewById<TextView>(R.id.payment_method_badge)
            if (pmBadge != null) {
                pmBadge.text = state.paymentMethod.uppercase()
                val bgDrawable = android.graphics.drawable.GradientDrawable()
                bgDrawable.cornerRadius = 8f * resources.displayMetrics.density
                
                if (state.paymentMethod.equals("cash", ignoreCase = true)) {
                    pmBadge.setTextColor(android.graphics.Color.parseColor("#27AE60"))
                    bgDrawable.setColor(android.graphics.Color.parseColor("#EAFDF1"))
                    bgDrawable.setStroke(2, android.graphics.Color.parseColor("#A8E6CF"))
                } else {
                    pmBadge.setTextColor(android.graphics.Color.parseColor("#2980B9"))
                    bgDrawable.setColor(android.graphics.Color.parseColor("#EBF5FB"))
                    bgDrawable.setStroke(2, android.graphics.Color.parseColor("#AED6F1"))
                }
                pmBadge.background = bgDrawable
            }

            findViewById<Button>(R.id.btn_accept)?.setOnClickListener {
                sendActionToMain("accept", state.id)
            }

            findViewById<Button>(R.id.btn_decline)?.setOnClickListener {
                sendActionToMain("decline", state.id)
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

        windowManager.addView(bubbleView, params)

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
                        val targetX = if (params.x + (view.width / 2) < middle) 0 else screenWidth
                        
                        params.x = targetX
                        windowManager.updateViewLayout(bubbleView, params)
                    }
                    true
                }
                else -> false
            }
        }

        bubbleView?.findViewById<ImageView>(R.id.close_button)?.setOnClickListener {
            stopSelf()
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

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("UGO Driver Bubble")
            .setContentText("Floating overlay is active")
            .setSmallIcon(R.drawable.ugo_notification)
            .setContentIntent(pendingIntent)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        hideBubble()
        hideRideRequestOverlay()
    }
}
