package com.ugocabs.drivers;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.core.app.NotificationCompat;

import java.io.IOException;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class FloatingBubbleService extends Service {
    private WindowManager windowManager;
    private View floatingBubble;
    private View rideRequestOverlay;
    private WindowManager.LayoutParams bubbleParams;
    private WindowManager.LayoutParams overlayParams;
    private int initialX;
    private int initialY;
    private float initialTouchX;
    private float initialTouchY;
    private String currentRideId;
    private String accessToken;
    private String driverId;
    private android.os.Handler timerHandler;
    private Runnable timerRunnable;
    private int timerSeconds = 30; // 30 second timer like Flutter

    @Override
    public void onCreate() {
        super.onCreate();

        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                "floating_bubble_channel",
                "Floating Bubble Service",
                NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }

        // Create foreground notification
        Notification notification = new NotificationCompat.Builder(this, "floating_bubble_channel")
            .setContentTitle("UGO Driver")
            .setContentText("Floating bubble active")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
        } else {
            startForeground(1, notification);
        }

        // Create floating bubble
        createFloatingBubble();
        // Create ride request overlay (initially hidden)
        createRideRequestOverlay();

        // Initialize timer handler
        timerHandler = new android.os.Handler();
        timerRunnable = new Runnable() {
            @Override
            public void run() {
                updateTimerProgress();
                timerHandler.postDelayed(this, 1000); // Update every second
            }
        };
    }

    private void createFloatingBubble() {
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);

        // Inflate the floating bubble layout
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        floatingBubble = inflater.inflate(R.layout.floating_bubble, null);

        // Setup window parameters
        bubbleParams = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL |
            WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH |
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        );

        bubbleParams.gravity = Gravity.TOP | Gravity.START;
        bubbleParams.x = 0;
        bubbleParams.y = 100;

        // Setup touch listener for dragging
        floatingBubble.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = bubbleParams.x;
                        initialY = bubbleParams.y;
                        initialTouchX = event.getRawX();
                        initialTouchY = event.getRawY();
                        return true;

                    case MotionEvent.ACTION_MOVE:
                        bubbleParams.x = initialX + (int) (event.getRawX() - initialTouchX);
                        bubbleParams.y = initialY + (int) (event.getRawY() - initialTouchY);
                        windowManager.updateViewLayout(floatingBubble, bubbleParams);
                        return true;

                    case MotionEvent.ACTION_UP:
                        // Check if it's a click (minimal movement)
                        if (Math.abs(event.getRawX() - initialTouchX) < 10 &&
                            Math.abs(event.getRawY() - initialTouchY) < 10) {
                            // Handle bubble click - open app
                            Intent intent = new Intent(FloatingBubbleService.this, MainActivity.class);
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intent);
                        }
                        return true;
                }
                return false;
            }
        });

        // Add the view to window
        windowManager.addView(floatingBubble, bubbleParams);
    }

    private void createRideRequestOverlay() {
        // Inflate the ride request overlay layout
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        rideRequestOverlay = inflater.inflate(R.layout.ride_request_overlay, null);

        // Setup window parameters for overlay
        overlayParams = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        );

        overlayParams.gravity = Gravity.CENTER;
        overlayParams.x = 0;
        overlayParams.y = 0;

        // Setup close button
        ImageView closeButton = rideRequestOverlay.findViewById(R.id.close_button);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideRideRequestOverlay();
            }
        });

        // Setup accept button
        View acceptButton = rideRequestOverlay.findViewById(R.id.accept_button);
        acceptButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d("FloatingBubbleService", "Accept button clicked for ride: " + currentRideId);
                // Make direct API call to accept ride
                acceptRide(currentRideId, accessToken, driverId);
                hideRideRequestOverlay();
            }
        });

        // Setup reject button (now a LinearLayout container)
        View rejectButtonContainer = rideRequestOverlay.findViewById(R.id.reject_button);
        if (rejectButtonContainer != null) {
            rejectButtonContainer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d("FloatingBubbleService", "Reject button clicked for ride: " + currentRideId);
                    // For reject, just hide the overlay (no API call needed)
                    hideRideRequestOverlay();
                }
            });
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String action = intent.getAction();
            Log.d("FloatingBubbleService", "onStartCommand called with action: " + action);
            if ("SHOW_BUBBLE".equals(action)) {
                showBubble();
            } else if ("HIDE_BUBBLE".equals(action)) {
                hideBubble();
            } else if ("UPDATE_BUBBLE_CONTENT".equals(action)) {
                String title = intent.getStringExtra("title");
                String subtitle = intent.getStringExtra("subtitle");
                updateBubbleContent(title, subtitle);
            } else if ("SHOW_RIDE_OVERLAY".equals(action)) {
                String pickup = intent.getStringExtra("pickup");
                String drop = intent.getStringExtra("drop");
                String fare = intent.getStringExtra("fare");
                String rideId = intent.getStringExtra("rideId");
                String accessToken = intent.getStringExtra("accessToken");
                String driverId = intent.getStringExtra("driverId");
                showRideRequestOverlay(pickup, drop, fare, rideId, accessToken, driverId);
            } else if ("HIDE_RIDE_OVERLAY".equals(action)) {
                hideRideRequestOverlay();
            }
        } else {
            Log.d("FloatingBubbleService", "onStartCommand called with null intent");
        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (floatingBubble != null && windowManager != null) {
            windowManager.removeView(floatingBubble);
        }
        if (rideRequestOverlay != null && windowManager != null) {
            try {
                windowManager.removeView(rideRequestOverlay);
            } catch (Exception e) {
                Log.e("FloatingBubbleService", "Error removing ride overlay in onDestroy: " + e.getMessage());
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public void showBubble() {
        if (floatingBubble != null && windowManager != null) {
            try {
                if (floatingBubble.getWindowToken() == null) {
                    windowManager.addView(floatingBubble, bubbleParams);
                }
                floatingBubble.setVisibility(View.VISIBLE);
                Log.d("FloatingBubbleService", "Bubble shown - visibility set to VISIBLE");
            } catch (Exception e) {
                Log.e("FloatingBubbleService", "Error showing bubble: " + e.getMessage());
            }
        } else {
            Log.e("FloatingBubbleService", "Cannot show bubble - floatingBubble or windowManager is null");
        }
    }

    public void hideBubble() {
        if (floatingBubble != null) {
            floatingBubble.setVisibility(View.GONE);
            Log.d("FloatingBubbleService", "Bubble hidden - visibility set to GONE");
        } else {
            Log.e("FloatingBubbleService", "Cannot hide bubble - floatingBubble is null");
        }
    }

    public void updateBubbleContent(String title, String subtitle) {
        if (floatingBubble != null) {
            TextView titleView = floatingBubble.findViewById(R.id.bubble_title);
            TextView subtitleView = floatingBubble.findViewById(R.id.bubble_subtitle);

            if (titleView != null && title != null) {
                titleView.setText(title);
                titleView.setVisibility(View.VISIBLE);
            }
            if (subtitleView != null && subtitle != null) {
                subtitleView.setText(subtitle);
                subtitleView.setVisibility(View.VISIBLE);
            }
            Log.d("FloatingBubbleService", "Bubble content updated - title: " + title + ", subtitle: " + subtitle);
        } else {
            Log.e("FloatingBubbleService", "Cannot update bubble content - floatingBubble is null");
        }
    }

    public void showRideRequestOverlay(String pickup, String drop, String fare, String rideId, String accessToken, String driverId) {
        currentRideId = rideId;
        this.accessToken = accessToken;
        this.driverId = driverId;
        if (rideRequestOverlay != null && windowManager != null) {
            try {
                if (rideRequestOverlay.getWindowToken() == null) {
                    windowManager.addView(rideRequestOverlay, overlayParams);
                }
                updateRideOverlayContent(pickup, drop, fare);
                rideRequestOverlay.setVisibility(View.VISIBLE);
                startTimer(); // Start the timer when overlay is shown
                Log.d("FloatingBubbleService", "Ride request overlay shown for ride: " + rideId);
            } catch (Exception e) {
                Log.e("FloatingBubbleService", "Error showing ride overlay: " + e.getMessage());
            }
        } else {
            Log.e("FloatingBubbleService", "Cannot show ride overlay - rideRequestOverlay or windowManager is null");
        }
    }

    public void hideRideRequestOverlay() {
        if (rideRequestOverlay != null) {
            stopTimer(); // Stop the timer when overlay is hidden
            rideRequestOverlay.setVisibility(View.GONE);
            if (windowManager != null) {
                try {
                    windowManager.removeView(rideRequestOverlay);
                } catch (Exception e) {
                    Log.e("FloatingBubbleService", "Error removing ride overlay view: " + e.getMessage());
                }
            }
            Log.d("FloatingBubbleService", "Ride request overlay hidden");
        } else {
            Log.e("FloatingBubbleService", "Cannot hide ride overlay - rideRequestOverlay is null");
        }
    }

    private void updateRideOverlayContent(String pickup, String drop, String fare) {
        if (rideRequestOverlay != null) {
            TextView pickupText = rideRequestOverlay.findViewById(R.id.pickup_text);
            TextView dropText = rideRequestOverlay.findViewById(R.id.drop_text);
            TextView fareText = rideRequestOverlay.findViewById(R.id.fare_text);

            if (pickupText != null && pickup != null) {
                pickupText.setText(pickup);
            }
            if (dropText != null && drop != null) {
                dropText.setText(drop);
            }
            if (fareText != null && fare != null) {
                fareText.setText("₹" + fare);
            }
            Log.d("FloatingBubbleService", "Ride overlay content updated - pickup: " + pickup + ", drop: " + drop + ", fare: " + fare);
        } else {
            Log.e("FloatingBubbleService", "Cannot update ride overlay content - rideRequestOverlay is null");
        }
    }

    private void startTimer() {
        timerSeconds = 30; // Reset to 30 seconds
        if (timerHandler != null) {
            timerHandler.removeCallbacks(timerRunnable);
            timerHandler.post(timerRunnable);
            Log.d("FloatingBubbleService", "Timer started");
        }
    }

    private void stopTimer() {
        if (timerHandler != null) {
            timerHandler.removeCallbacks(timerRunnable);
            Log.d("FloatingBubbleService", "Timer stopped");
        }
    }

    private void updateTimerProgress() {
        if (rideRequestOverlay != null) {
            android.widget.ProgressBar progressBar = rideRequestOverlay.findViewById(R.id.timer_progress);
            if (progressBar != null) {
                timerSeconds--;
                if (timerSeconds >= 0) {
                    int progress = (int) (((float) timerSeconds / 30.0) * 100);
                    progressBar.setProgress(progress);
                    Log.d("FloatingBubbleService", "Timer progress updated: " + progress + "% (" + timerSeconds + "s remaining)");
                } else {
                    // Timer expired - auto reject
                    stopTimer();
                    Intent intent = new Intent("com.ugocabs.drivers.RIDE_ACTION");
                    intent.putExtra("action", "reject");
                    intent.putExtra("rideId", currentRideId);
                    sendBroadcast(intent);
                    hideRideRequestOverlay();
                    Log.d("FloatingBubbleService", "Timer expired - auto rejecting ride");
                }
            }
        }
    }

    private void acceptRide(String rideId, String accessToken, String driverId) {
        Log.d("FloatingBubbleService", "Making API call to accept ride: " + rideId);

        OkHttpClient client = new OkHttpClient();
        String url = "https://ugotaxi.icacorp.org/api/rides/rides/" + rideId + "/accept";

        String json = "{\"driver_id\": " + driverId + "}";
        RequestBody body = RequestBody.create(json, MediaType.parse("application/json"));

        Request request = new Request.Builder()
            .url(url)
            .post(body)
            .addHeader("Authorization", "Bearer " + accessToken)
            .addHeader("Content-Type", "application/json")
            .build();

        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("FloatingBubbleService", "Accept API call failed: " + e.getMessage());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.isSuccessful()) {
                    Log.d("FloatingBubbleService", "Ride accepted successfully: " + response.body().string());
                } else {
                    Log.e("FloatingBubbleService", "Accept API call failed with code: " + response.code());
                }
            }
        });
    }
}