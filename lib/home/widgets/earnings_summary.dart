import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 12,
      ),
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
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: _SummaryCard(
              title: FFLocalizations.of(context).getText('drv_wallet'),
              value: isLoading ? '...' : teamEarnings.toStringAsFixed(0),
              isSmallScreen: isSmallScreen,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
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
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 8 : 12,
        horizontal: isSmallScreen ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLightBg,
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
