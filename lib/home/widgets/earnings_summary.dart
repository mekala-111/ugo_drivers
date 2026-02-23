import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';

/// Today earnings cards: total, team earnings, ride count.
class EarningsSummary extends StatelessWidget {
  const EarningsSummary({
    super.key,
    required this.todayTotal,
    required this.teamEarnings,
    required this.ridesToday,
    this.isLoading = false,
    this.isSmallScreen = false,
  });

  final double todayTotal;
  final double teamEarnings;
  final int ridesToday;
  final bool isLoading;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final hPad = w * (isSmallScreen ? 0.035 : 0.04);
    final vPad = h * (isSmallScreen ? 0.014 : 0.016);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _SummaryCard(
              title: FFLocalizations.of(context).getText('drv_today_total'),
              value: isLoading ? '...' : todayTotal.toStringAsFixed(0),
              isSmallScreen: isSmallScreen,
            ),
          ),
          SizedBox(width: w * (isSmallScreen ? 0.022 : 0.03)),
          Expanded(
            child: _SummaryCard(
              title: FFLocalizations.of(context).getText('drv_wallet'),
              value: isLoading ? '...' : teamEarnings.toStringAsFixed(0),
              isSmallScreen: isSmallScreen,
            ),
          ),
          SizedBox(width: w * (isSmallScreen ? 0.022 : 0.03)),
          Expanded(
            child: _SummaryCard(
              title: FFLocalizations.of(context).getText('drv_ride_count'),
              value: isLoading ? '...' : ridesToday.toString(),
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.isSmallScreen,
  });

  final String title;
  final String value;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final vPad = h * (isSmallScreen ? 0.01 : 0.014);
    final hPad = w * (isSmallScreen ? 0.01 : 0.02);
    return Container(
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
      decoration: BoxDecoration(
        color: AppColors.primaryLightBg,
        borderRadius: BorderRadius.circular(w * (isSmallScreen ? 0.028 : 0.032)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            textScaler: MediaQuery.textScalerOf(context),
            style: TextStyle(
              color: Colors.black87,
              fontSize: Responsive.fontSize(context, isSmallScreen ? 11 : 13),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: h * (isSmallScreen ? 0.008 : 0.01)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textScaler: MediaQuery.textScalerOf(context),
              style: TextStyle(
                color: Colors.black,
                fontSize: Responsive.fontSize(context, isSmallScreen ? 18 : 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
