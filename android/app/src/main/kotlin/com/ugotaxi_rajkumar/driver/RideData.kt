package com.ugotaxi_rajkumar.driver

import java.io.Serializable

/**
 * Data class representing a ride request or ongoing ride.
 */
data class RideData(
    val id: Int,
    val fare: String,
    val paymentMethod: String = "",
    val pickup: String = "",
    val drop: String = "",
    val pickupDistance: String = "",
    val dropDistance: String = "",
    val remainingTime: Int = 30,
    val isPro: Boolean = false,
    val pickupLocality: String = "",
    val dropLocality: String = "",
    val passengerName: String = "Passenger"
) : Serializable
