import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';
import 'package:ugo_driver/index.dart';

/// Offline state dashboard: greeting, driver name, "Go Online" CTA.
/// Shown when driver is offline (MapContainer is hidden).
class OfflineDashboard extends StatelessWidget {
  const OfflineDashboard({
    super.key,
    required this.driverName,
    required this.greeting,
    required this.isDataLoaded,
    required this.onGoOnline,
  });

  final String driverName;
  final String greeting;
  final bool isDataLoaded;
  final VoidCallback onGoOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$greeting,',
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            driverName,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Icon(
            Icons.location_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            FFLocalizations.of(context).getText('drv_offline'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: isDataLoaded ? onGoOnline : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.power_settings_new, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    FFLocalizations.of(context).getText('drv_go_online'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
