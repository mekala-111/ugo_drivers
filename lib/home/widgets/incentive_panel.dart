import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';
import '../incentive_model.dart';

/// Collapsible incentive panel showing ride targets and rewards.
class IncentivePanel extends StatelessWidget {
  const IncentivePanel({
    super.key,
    required this.isExpanded,
    required this.isLoadingIncentives,
    required this.incentiveTiers,
    required this.currentRides,
    required this.totalIncentiveEarned,
    required this.onTap,
    required this.screenWidth,
    required this.isSmallScreen,
  });

  final bool isExpanded;
  final bool isLoadingIncentives;
  final List<IncentiveTier> incentiveTiers;
  final int currentRides;
  final double totalIncentiveEarned;
  final VoidCallback onTap;
  final double screenWidth;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final hasIncentives = incentiveTiers.isNotEmpty;
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final hPad = w * (isSmallScreen ? 0.035 : 0.04);
    final vPad = h * (isSmallScreen ? 0.014 : 0.016);

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
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('drv_incentives'),
                    textScaler: MediaQuery.textScalerOf(context),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, isSmallScreen ? 14 : 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (isLoadingIncentives)
                        SizedBox(
                          width: w * 0.04,
                          height: w * 0.04,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      else
                        Text(
                          hasIncentives
                              ? '₹${totalIncentiveEarned.toStringAsFixed(0)}'
                              : FFLocalizations.of(context).getText('drv_coming_soon'),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: hasIncentives ? Colors.black : Colors.grey,
                          ),
                        ),
                      SizedBox(width: w * (isSmallScreen ? 0.022 : 0.03)),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        size: Responsive.iconSize(context, base: isSmallScreen ? 20 : 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            isLoadingIncentives
                ? _buildLoadingIndicator(context)
                : hasIncentives
                    ? _buildIncentiveProgressBars(context)
                    : _buildComingSoonMessage(context),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * (isSmallScreen ? 0.065 : 0.08);
    return Padding(
      padding: EdgeInsets.all(size),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildIncentiveProgressBars(BuildContext context) {
    final totalRequiredRides = incentiveTiers.isNotEmpty
        ? incentiveTiers.map((t) => t.targetRides).reduce((a, b) => a > b ? a : b)
        : 0;

    final w = MediaQuery.sizeOf(context).width;
    final pad = w * (isSmallScreen ? 0.035 : 0.04);
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentRides/$totalRequiredRides',
                textScaler: MediaQuery.textScalerOf(context),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, isSmallScreen ? 16 : 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalIncentiveEarned.toStringAsFixed(0)}',
                textScaler: MediaQuery.textScalerOf(context),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, isSmallScreen ? 16 : 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
          ...incentiveTiers.map(
            (tier) => _IncentiveTierBar(
              tier: tier,
              currentRides: currentRides,
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonMessage(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final pad = w * (isSmallScreen ? 0.065 : 0.08);
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          Icon(
            Icons.star_border_rounded,
            size: w * (isSmallScreen ? 0.13 : 0.16),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: h * 0.02),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_soon'),
            textScaler: MediaQuery.textScalerOf(context),
            style: TextStyle(
              fontSize: Responsive.fontSize(context, isSmallScreen ? 18 : 20),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: h * 0.01),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_excite'),
            textAlign: TextAlign.center,
            textScaler: MediaQuery.textScalerOf(context),
            style: TextStyle(
              fontSize: Responsive.fontSize(context, isSmallScreen ? 13 : 14),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncentiveTierBar extends StatelessWidget {
  const _IncentiveTierBar({
    required this.tier,
    required this.currentRides,
    required this.isSmallScreen,
  });

  final IncentiveTier tier;
  final int currentRides;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final progress = (currentRides / tier.targetRides).clamp(0.0, 1.0);
    final isCompleted = currentRides >= tier.targetRides;

    final h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tier.isLocked ? Icons.lock : Icons.lock_open,
                    size: Responsive.iconSize(context, base: isSmallScreen ? 16 : 18),
                    color: tier.isLocked ? Colors.grey : AppColors.primary,
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.015),
                  Text(
                    '${tier.targetRides} ${FFLocalizations.of(context).getText('drv_rides')}',
                    textScaler: MediaQuery.textScalerOf(context),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, isSmallScreen ? 13 : 14),
                      fontWeight: FontWeight.w600,
                      color: tier.isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                textScaler: MediaQuery.textScalerOf(context),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, isSmallScreen ? 14 : 16),
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
          Container(
            height: MediaQuery.sizeOf(context).height * (isSmallScreen ? 0.038 : 0.042),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * progress,
                        height: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: tier.isLocked
                                  ? [Colors.grey.shade400, Colors.grey.shade500]
                                  : isCompleted
                                      ? [Colors.green, Colors.green.shade700]
                                      : [AppColors.primaryLightBg, AppColors.primary],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
