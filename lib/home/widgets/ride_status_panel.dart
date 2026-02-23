import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
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
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final top = h * 0.015;
    final hPad = w * 0.04;
    final vPad = h * 0.01;

    return Positioned(
      top: top,
      left: hPad,
      right: hPad,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.06),
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
              Icon(Icons.people, color: AppColors.primary, size: Responsive.iconSize(context, base: 20)),
              SizedBox(width: w * 0.02),
              Text(
                '$availableDriversCount $caption',
                textScaler: MediaQuery.textScalerOf(context),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
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
