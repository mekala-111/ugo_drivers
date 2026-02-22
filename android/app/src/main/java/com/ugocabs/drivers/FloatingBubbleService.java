package com.ugotaxi_rajkumar.driver;

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

public class FloatingBubbleService extends Service {
    private WindowManager windowManager;
    private View floatingBubble;
    private WindowManager.LayoutParams params;
    private int initialX;
    private int initialY;
    private float initialTouchX;
    private float initialTouchY;
    private View bubbleContainer;
    private View rideRequestCard;
    private TextView fareView;
    private TextView pickupView;
    private TextView dropView;
    private View acceptView;
    private View declineView;
    private int currentRideId = 0;

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
    }

    private void createFloatingBubble() {
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);

        // Inflate the floating bubble layout
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        floatingBubble = inflater.inflate(R.layout.floating_bubble, null);
        bubbleContainer = floatingBubble.findViewById(R.id.bubble_container);
        rideRequestCard = floatingBubble.findViewById(R.id.ride_request_card);
        fareView = floatingBubble.findViewById(R.id.ride_request_fare);
        pickupView = floatingBubble.findViewById(R.id.ride_request_pickup);
        dropView = floatingBubble.findViewById(R.id.ride_request_drop);
        acceptView = floatingBubble.findViewById(R.id.ride_request_accept);
        declineView = floatingBubble.findViewById(R.id.ride_request_decline);

        // Setup window parameters
        params = new WindowManager.LayoutParams(
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

        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 0;
        params.y = 100;

        // Setup touch listener for dragging
        floatingBubble.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = params.x;
                        initialY = params.y;
                        initialTouchX = event.getRawX();
                        initialTouchY = event.getRawY();
                        return true;

                    case MotionEvent.ACTION_MOVE:
                        params.x = initialX + (int) (event.getRawX() - initialTouchX);
                        params.y = initialY + (int) (event.getRawY() - initialTouchY);
                        windowManager.updateViewLayout(floatingBubble, params);
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

        if (acceptView != null) {
            acceptView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    sendRideAction("accept");
                }
            });
        }
        if (declineView != null) {
            declineView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    sendRideAction("decline");
                }
            });
        }

        // Add the view to window
        windowManager.addView(floatingBubble, params);
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
            } else if ("SHOW_RIDE_REQUEST".equals(action)) {
                currentRideId = intent.getIntExtra("ride_id", 0);
                String fare = intent.getStringExtra("fare");
                String pickup = intent.getStringExtra("pickup");
                String drop = intent.getStringExtra("drop");
                showRideRequest(fare, pickup, drop);
            } else if ("HIDE_RIDE_REQUEST".equals(action)) {
                hideRideRequest();
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
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public void showBubble() {
        if (floatingBubble != null && windowManager != null) {
            try {
                if (floatingBubble.getWindowToken() == null) {
                    windowManager.addView(floatingBubble, params);
                }
                if (rideRequestCard != null && rideRequestCard.getVisibility() == View.VISIBLE) {
                    Log.d("FloatingBubbleService", "Ride request visible; skip bubble");
                    return;
                }
                if (bubbleContainer != null) {
                    bubbleContainer.setVisibility(View.VISIBLE);
                }
                if (rideRequestCard != null) {
                    rideRequestCard.setVisibility(View.GONE);
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

    public void showRideRequest(String fare, String pickup, String drop) {
        if (floatingBubble != null && windowManager != null) {
            try {
                if (floatingBubble.getWindowToken() == null) {
                    windowManager.addView(floatingBubble, params);
                }
                if (bubbleContainer != null) {
                    bubbleContainer.setVisibility(View.GONE);
                }
                if (rideRequestCard != null) {
                    rideRequestCard.setVisibility(View.VISIBLE);
                }
                if (fareView != null && fare != null) {
                    fareView.setText(fare);
                }
                if (pickupView != null && pickup != null) {
                    pickupView.setText(pickup);
                }
                if (dropView != null && drop != null) {
                    dropView.setText(drop);
                }
                floatingBubble.setVisibility(View.VISIBLE);
                Log.d("FloatingBubbleService", "Ride request shown");
            } catch (Exception e) {
                Log.e("FloatingBubbleService", "Error showing ride request: " + e.getMessage());
            }
        } else {
            Log.e("FloatingBubbleService", "Cannot show ride request - floatingBubble or windowManager is null");
        }
    }

    public void hideRideRequest() {
        if (rideRequestCard != null) {
            rideRequestCard.setVisibility(View.GONE);
        }
        if (bubbleContainer != null) {
            bubbleContainer.setVisibility(View.VISIBLE);
        }
    }

    private void sendRideAction(String action) {
        hideRideRequest();
        Intent intent = new Intent(FloatingBubbleService.this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.putExtra("ride_action", action);
        intent.putExtra("ride_id", currentRideId);
        startActivity(intent);
    }
}