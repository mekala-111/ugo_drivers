import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
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
                    FFLocalizations.of(context).getText('drv_incentives'),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (isLoadingIncentives)
                        const SizedBox(
                          width: 16,
                          height: 16,
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
            isLoadingIncentives
                ? _buildLoadingIndicator()
                : hasIncentives
                    ? _buildIncentiveProgressBars(context)
                    : _buildComingSoonMessage(context),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildIncentiveProgressBars(BuildContext context) {
    final totalRequiredRides = incentiveTiers.isNotEmpty
        ? incentiveTiers.map((t) => t.targetRides).reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16,
        0,
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 12 : 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentRides/$totalRequiredRides',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalIncentiveEarned.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
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
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      child: Column(
        children: [
          Icon(
            Icons.star_border_rounded,
            size: isSmallScreen ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_soon'),
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_excite'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
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

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
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
                    size: isSmallScreen ? 16 : 18,
                    color: tier.isLocked ? Colors.grey : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${tier.targetRides} ${FFLocalizations.of(context).getText('drv_rides')}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: tier.isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: isSmallScreen ? 28 : 32,
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
