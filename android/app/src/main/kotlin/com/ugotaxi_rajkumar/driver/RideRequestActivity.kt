package com.ugotaxi_rajkumar.driver

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView

/**
 * Activity to show a new ride request and allow the user to accept/decline.
 */
class RideRequestActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ride_request)

        val rideData = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            intent.getSerializableExtra("ride_data", RideData::class.java)
        } else {
            intent.getSerializableExtra("ride_data") as? RideData
        }

        rideData?.let { data ->
            findViewById<TextView>(R.id.pickup_address)?.text = data.pickup
            findViewById<TextView>(R.id.drop_address)?.text = data.drop
            findViewById<TextView>(R.id.ride_fare)?.text = data.fare
            findViewById<TextView>(R.id.pickup_distance)?.text = data.pickupDistance
        }

        findViewById<Button>(R.id.btn_accept)?.setOnClickListener {
            // Handle accept
            finish()
        }

        findViewById<Button>(R.id.btn_decline)?.setOnClickListener {
            // Handle decline
            finish()
        }
    }
}
