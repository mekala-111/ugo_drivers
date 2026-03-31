package com.ugotaxi_rajkumar.driver

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder

/**
 * Stub service responsible for showing a ride request overlay.
 *
 * Right now this only stores the latest RideData and can be expanded later
 * to actually display a system overlay if desired.
 */
class RideRequestOverlayService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // In a full implementation, you would parse the ride data from the intent
        // and update your overlay UI here.
        return START_NOT_STICKY
    }

    companion object {
        private const val EXTRA_RIDE_ID = "extra_ride_id"
        private const val EXTRA_FARE = "extra_fare"

        fun showNewRideRequest(context: Context, rideData: RideData) {
            // Minimal implementation – start the service with ride details.
            val intent = Intent(context, RideRequestOverlayService::class.java).apply {
                putExtra(EXTRA_RIDE_ID, rideData.id)
                putExtra(EXTRA_FARE, rideData.fare)
                // Add more extras if you later need them in the service.
            }
            context.startService(intent)
        }
    }
}

