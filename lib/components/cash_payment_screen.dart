import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
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
        title: Text(
          FFLocalizations.of(context).getText('drv_ride_completed'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(Icons.payments_outlined,
                      size: 64, color: ugoOrange.withValues(alpha: 0.8)),
                  const SizedBox(height: 24),
                  Text(
                    FFLocalizations.of(context).getText('drv_collect_cash'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹${_amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: ugoGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FFLocalizations.of(context).getText('drv_from_passenger'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onCollectConfirmed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ugoGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        FFLocalizations.of(context)
                            .getText('drv_received_cash'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
