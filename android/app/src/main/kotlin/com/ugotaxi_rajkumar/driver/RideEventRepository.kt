package com.ugotaxi_rajkumar.driver

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

sealed class RideState {
    object Idle : RideState()
    data class NewRequest(
        val id: Int,
        val fare: String,
        val pickupDistance: String,
        val dropDistance: String,
        val pickup: String,
        val drop: String
    ) : RideState()
    data class Ongoing(val id: Int, val passengerName: String) : RideState()
}

/**
 * RideEventRepository acts as a bridge between the Flutter app (via MethodChannel)
 * and the native Android features (Floating Bubble Service and PiP Activities).
 */
object RideEventRepository {
    private val _rideState = MutableStateFlow<RideState>(RideState.Idle)
    val rideState: StateFlow<RideState> = _rideState.asStateFlow()

    fun updateState(newState: RideState) {
        _rideState.value = newState
    }

    fun clearState() {
        _rideState.value = RideState.Idle
    }
}
