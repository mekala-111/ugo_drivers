import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';

/// Collapsible bottom panel showing today's earnings.
class EarningsPanel extends StatelessWidget {
  const EarningsPanel({
    super.key,
    required this.isExpanded,
    required this.isLoadingEarnings,
    required this.todayTotal,
    required this.todayRideCount,
    required this.todayWallet,
    required this.lastRideAmount,
    required this.onTap,
    required this.screenWidth,
    required this.isSmallScreen,
  });

  final bool isExpanded;
  final bool isLoadingEarnings;
  final double todayTotal;
  final int todayRideCount;
  final double todayWallet;
  final double lastRideAmount;
  final VoidCallback onTap;
  final double screenWidth;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('drv_today_total'),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isLoadingEarnings ? '...' : todayTotal.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                0,
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _OrangeCard(
                      title: FFLocalizations.of(context).getText('drv_ride_count'),
                      value: isLoadingEarnings ? '...' : todayRideCount.toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: _OrangeCard(
                      title: FFLocalizations.of(context).getText('drv_wallet'),
                      value: isLoadingEarnings ? '...' : todayWallet.toStringAsFixed(0),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: _OrangeCard(
                      title: FFLocalizations.of(context).getText('drv_last_ride'),
                      value: isLoadingEarnings ? '...' : lastRideAmount.toStringAsFixed(0),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrangeCard extends StatelessWidget {
  const _OrangeCard({
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
