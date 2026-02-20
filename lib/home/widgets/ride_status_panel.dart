import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';

/// Rapido-style "Available captains nearby" panel shown on map when online.
class RideStatusPanel extends StatelessWidget {
  const RideStatusPanel({
    super.key,
    required this.availableDriversCount,
  });

  final int availableDriversCount;

  @override
  Widget build(BuildContext context) {
    final caption = availableDriversCount != 1
        ? FFLocalizations.of(context).getText('drv_captains_nearby')
        : FFLocalizations.of(context).getText('drv_captain_nearby');

    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '$availableDriversCount $caption',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
