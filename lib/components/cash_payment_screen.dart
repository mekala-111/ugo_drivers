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

  double get _amountToCollect => ride.finalFare ?? ride.estimatedFare ?? 0.0;
  double get _voucherTopup => ride.discountAmount ?? 0.0;

  @override
  Widget build(BuildContext context) {
    bool isPro = ride.bookingMode == 'pro';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ugoOrange,
        automaticallyImplyLeading:
            false, // Prevents backing out until cash is collected
        title: Text(
          isPro ? 'Pro Ride' : 'Ugo Ride',
          style: TextStyle(
            color: isPro ? Colors.black : Colors.white,
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

              // ✅ Large Checkmark Circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isPro ? const Color(0xFFE3CA43) : ugoGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: isPro ? Colors.black : Colors.white,
                  size: 100,
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Subtitle Text
              Text(
                'Collect Cash From ${ride.fullName.isNotEmpty ? ride.fullName : 'Passenger'}',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8), // Light grey background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Final Fare',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            ride.rawPaymentMode.toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_amountToCollect.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ugoGreen,
                      ),
                    ),
                  ],
                ),
              ),
              if (_voucherTopup > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Collect ₹${_amountToCollect.toStringAsFixed(0)} from rider. '
                  'Voucher balance ₹${_voucherTopup.toStringAsFixed(0)} will be credited to wallet.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),

              // ✅ CASH COLLECTED Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: onCollectConfirmed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPro ? const Color(0xFFE3CA43) : ugoGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CASH COLLECTED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPro ? Colors.black : Colors.white,
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
