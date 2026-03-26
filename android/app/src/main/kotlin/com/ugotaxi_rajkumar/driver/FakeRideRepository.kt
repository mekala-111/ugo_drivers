package com.ugotaxi_rajkumar.driver

import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * FakeRideRepository simulates incoming ride requests for testing the overlay.
 */
object FakeRideRepository {

    private val scope = CoroutineScope(Dispatchers.Main)

    fun simulateIncomingRide(context: Context) {
        scope.launch {
            delay(3000) // Simulate delay
            val testRide = RideData(
                id = (1000..9999).random(),
                fare = "₹${(150..500).random()}",
                paymentMethod = listOf("CASH", "ONLINE").random(),
                pickup = "Green Park Extension, near Metro Station, Delhi",
                drop = "Building 10, DLF CyberHub, Phase 2, Gurgaon",
                pickupDistance = "1.8Km",
                dropDistance = "12.5Km",
                remainingTime = 30,
                isPro = listOf(true, false).random(),
                pickupLocality = "Green Park",
                dropLocality = "CyberHub"
            )
            
            // 1. Update global stateFlow
            RideEventRepository.updateState(
                RideState.NewRequest(
                    testRide.id, testRide.fare, testRide.paymentMethod, testRide.pickupDistance, testRide.dropDistance, testRide.pickup, testRide.drop, testRide.isPro
                )
            )
        }
    }
}
