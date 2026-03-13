package com.ugotaxi_rajkumar.driver

import android.app.PictureInPictureParams
import android.os.Build
import android.os.Bundle
import android.util.LayoutDirection
import android.util.Rational
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.ugotaxi_rajkumar.driver.R

class OngoingRideActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ongoing_ride)

        val nameText: TextView = findViewById(R.id.passenger_name)
        val btnComplete: Button = findViewById(R.id.btn_complete)
        val infoBox: View = findViewById(R.id.ride_info_box)

        val state = RideEventRepository.rideState.value
        if (state is RideState.Ongoing) {
            nameText.text = state.passengerName
        }

        btnComplete.setOnClickListener {
            RideEventRepository.clearState()
            finish()
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        enterPipMode()
    }

    private fun enterPipMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(1, 1)) // Square PiP for simplicity
                .build()
            enterPictureInPictureMode(params)
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: android.content.res.Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        val infoBox: View = findViewById(R.id.ride_info_box)
        if (isInPictureInPictureMode) {
            infoBox.visibility = View.GONE // Hide controls in PiP
        } else {
            infoBox.visibility = View.VISIBLE
        }
    }
}
