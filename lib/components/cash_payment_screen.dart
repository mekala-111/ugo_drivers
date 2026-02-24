import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import '../home/ride_request_model.dart';

/// Shown after ride completion when payment mode is CASH.
/// Driver collects cash from passenger and confirms receipt.
class CashPaymentScreen extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onCollectConfirmed;

  const CashPaymentScreen({
    super.key,
    required this.ride,
    required this.onCollectConfirmed,
  });

  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;

  double get _amount => ride.finalFare ?? ride.estimatedFare ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ugoOrange,
        automaticallyImplyLeading: false, // Prevents backing out until cash is collected
        title: const Text(
          'Ugo Ride',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),

              // ✅ Large Green Checkmark Circle
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: ugoGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Subtitle Text
              Text(
                'Collect Cash From ${ride.firstName ?? 'Passenger'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ✅ Main Title Text
              const Text(
                'Ride Completed Successfully',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              // ✅ Pushes the bottom items down
              const Spacer(),

              // ✅ Final Fare Grey Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8), // Light grey background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Final Fare',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '₹${_amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ugoGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ CASH COLLECTED Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: onCollectConfirmed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ugoGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CASH COLLECTED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}