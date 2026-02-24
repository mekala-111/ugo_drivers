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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: const [
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
          // Header Row - Large Tap Target for Drivers
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 14 : 18, // Fat-finger friendly padding
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('drv_incentives'),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        if (isLoadingIncentives)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                              color: hasIncentives ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          size: isSmallScreen ? 24 : 28,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Smoothly Animating Content Section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? (isLoadingIncentives
                ? _buildLoadingIndicator()
                : hasIncentives
                ? _buildIncentiveProgressBars(context)
                : _buildComingSoonMessage(context))
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: CircularProgressIndicator(
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
        isSmallScreen ? 16 : 20,
        0,
        isSmallScreen ? 16 : 20,
        isSmallScreen ? 16 : 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentRides / $totalRequiredRides Rides',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Total: ₹${totalIncentiveEarned.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success, // Green for total earned money
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
      child: Column(
        children: [
          Icon(
            Icons.star_border_rounded,
            size: isSmallScreen ? 48 : 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_soon'),
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FFLocalizations.of(context).getText('drv_incentives_excite'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: Colors.grey.shade600,
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

    // Define Colors and Icons based on state
    Color activeColor = isCompleted ? AppColors.success : AppColors.primary;
    IconData statusIcon = isCompleted
        ? Icons.check_circle
        : (tier.isLocked ? Icons.lock : Icons.lock_open);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    size: isSmallScreen ? 18 : 22,
                    color: tier.isLocked ? Colors.grey : activeColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tier.targetRides} ${FFLocalizations.of(context).getText('drv_rides')}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: tier.isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: tier.isLocked ? Colors.grey : activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: isSmallScreen ? 14 : 16, // Slightly thicker for glanceability
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                                  ? [AppColors.success, Colors.green.shade600] // Green if done
                                  : [AppColors.primaryLightBg, AppColors.primary], // Orange if in-progress
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