package com.ugotaxi_rajkumar.driver

import android.content.Context
import android.content.Intent

/**
 * Helper to show the ride request overlay.
 */
object RideRequestOverlayService {

    fun showNewRideRequest(context: Context, data: RideData) {
        val intent = Intent(context, RideRequestActivity::class.java).apply {
            putExtra("ride_data", data)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        context.startActivity(intent)
    }
}

// Minimal Service implementation since it's referenced as a service in Manifest
class RideRequestOverlayServiceStub : android.app.Service() {
    override fun onBind(intent: Intent?) = null
}
