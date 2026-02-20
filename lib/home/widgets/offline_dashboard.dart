import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
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
    final pad = Responsive.horizontalPadding(context);
    final btnH = Responsive.buttonHeight(context, base: 52);
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
              fontSize: Responsive.fontSize(context, 22),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            driverName,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 28),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.verticalSpacing(context) * 2.5),
          Icon(
            Icons.location_off_rounded,
            size: Responsive.value(context, small: 64.0, medium: 72.0, large: 80.0),
            color: Colors.grey[300],
          ),
          SizedBox(height: Responsive.verticalSpacing(context) * 1.5),
          Text(
            FFLocalizations.of(context).getText('drv_offline'),
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: Responsive.verticalSpacing(context) * 3),
          GestureDetector(
            onTap: isDataLoaded ? onGoOnline : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: pad * 2.5,
                vertical: btnH * 0.3,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 18),
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
