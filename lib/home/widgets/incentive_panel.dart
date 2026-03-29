import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';
import '../incentive_model.dart';

/// Formats backend TIME / ISO fragments for display (e.g. 6:00 AM).
String? incentiveFormatClock(dynamic raw) {
  if (raw == null) return null;
  var s = raw.toString();
  if (s.contains('T')) {
    final parts = s.split('T');
    if (parts.length > 1) {
      s = parts[1].split('.').first;
    }
  }
  final segs = s.split(':');
  if (segs.length < 2) return s;
  final h = int.tryParse(segs[0]) ?? 0;
  final m = int.tryParse(segs[1]) ?? 0;
  final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  final suffix = h >= 12 ? 'PM' : 'AM';
  return '$hour12:${m.toString().padLeft(2, '0')} $suffix';
}

/// Collapsible incentive panel — Rapido-style quests: per-quest progress, slot, bonus header.
class IncentivePanel extends StatelessWidget {
  const IncentivePanel({
    super.key,
    required this.isExpanded,
    required this.isLoadingIncentives,
    required this.incentiveTiers,
    required this.totalIncentiveEarned,
    required this.potentialBonusTotal,
    required this.onTap,
    required this.screenWidth,
    required this.isSmallScreen,
  });

  final bool isExpanded;
  final bool isLoadingIncentives;
  final List<IncentiveTier> incentiveTiers;
  final double totalIncentiveEarned;
  /// Sum of rewards for active (ongoing) quests — shown in collapsed header when set.
  final double potentialBonusTotal;
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 14 : 18,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          )
                        else
                          Text(
                            _collapsedTrailing(context, hasIncentives),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  hasIncentives ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? (isLoadingIncentives
                    ? _buildLoadingIndicator()
                    : hasIncentives
                        ? _buildIncentiveBody(context)
                        : _buildComingSoonMessage(context))
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  String _collapsedTrailing(BuildContext context, bool hasIncentives) {
    if (!hasIncentives) {
      return FFLocalizations.of(context).getText('drv_coming_soon');
    }
    if (potentialBonusTotal > 0) {
      return '₹${potentialBonusTotal.toStringAsFixed(0)}';
    }
    final t = incentiveTiers.first;
    return '${t.completedRides}/${t.targetRides}';
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildIncentiveBody(BuildContext context) {
    final primary = incentiveTiers.first;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 20,
        0,
        isSmallScreen ? 16 : 20,
        isSmallScreen ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuestHeroCard(
            tier: primary,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context)
                        .getText('drv_incentive_label_earned'),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalIncentiveEarned.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              if (potentialBonusTotal > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FFLocalizations.of(context)
                          .getText('drv_incentive_label_bonus_upto'),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${potentialBonusTotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (incentiveTiers.length > 1) ...[
            SizedBox(height: isSmallScreen ? 14 : 18),
            Text(
              FFLocalizations.of(context).getText('drv_incentive_all_quests'),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ...incentiveTiers.map(
              (tier) => _IncentiveTierBar(
                tier: tier,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
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

class _QuestHeroCard extends StatelessWidget {
  const _QuestHeroCard({
    required this.tier,
    required this.isSmallScreen,
  });

  final IncentiveTier tier;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final target = tier.targetRides;
    final done = tier.completedRides.clamp(0, target);
    final progress = target > 0 ? (done / target).clamp(0.0, 1.0) : 0.0;
    final start = incentiveFormatClock(tier.startTime);
    final end = incentiveFormatClock(tier.endTime);
    final slot = (start != null && end != null)
        ? '$start – $end'
        : '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      child: Row(
        children: [
          SizedBox(
            width: isSmallScreen ? 64 : 72,
            height: isSmallScreen ? 64 : 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: isSmallScreen ? 5 : 6,
                    backgroundColor: Colors.grey.shade300,
                    color: AppColors.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$done',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/$target',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tier.recurrenceType != null &&
                    tier.recurrenceType!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _recurrenceLabel(context, tier.recurrenceType),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Text(
                  tier.description ??
                      FFLocalizations.of(context)
                          .getText('drv_incentive_quest'),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slot.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${FFLocalizations.of(context).getText('drv_incentive_slot')}: $slot',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _moreRidesLine(context, tier),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _recurrenceLabel(BuildContext context, String? t) {
    switch (t?.toLowerCase()) {
      case 'weekly':
        return FFLocalizations.of(context)
            .getText('drv_incentive_recurrence_weekly');
      case 'monthly':
        return FFLocalizations.of(context)
            .getText('drv_incentive_recurrence_monthly');
      case 'daily':
      default:
        return FFLocalizations.of(context)
            .getText('drv_incentive_recurrence_daily');
    }
  }

  static String _moreRidesLine(BuildContext context, IncentiveTier tier) {
    final n = tier.ridesRemaining;
    if (n <= 0) {
      return FFLocalizations.of(context).getText('drv_incentive_goal_met');
    }
    return FFLocalizations.of(context)
        .getText('drv_incentive_complete_n_more')
        .replaceAll('{n}', '$n');
  }
}

class _IncentiveTierBar extends StatelessWidget {
  const _IncentiveTierBar({
    required this.tier,
    required this.isSmallScreen,
  });

  final IncentiveTier tier;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final target = tier.targetRides;
    final done = tier.completedRides.clamp(0, target);
    final progress = target > 0 ? (done / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = done >= target && target > 0;

    final activeColor = isCompleted ? AppColors.success : AppColors.primary;
    final statusIcon = isCompleted
        ? Icons.check_circle
        : (tier.isLocked ? Icons.lock : Icons.emoji_events_outlined);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                statusIcon,
                size: isSmallScreen ? 18 : 22,
                color: tier.isLocked ? Colors.grey : activeColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.description ??
                          '${tier.targetRides} ${FFLocalizations.of(context).getText('drv_rides')}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: tier.isLocked
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$done / $target ${FFLocalizations.of(context).getText('drv_rides')} · +₹${tier.rewardAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: isSmallScreen ? 14 : 16,
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
                                      ? [
                                          AppColors.success,
                                          Colors.green.shade600
                                        ]
                                      : [
                                          AppColors.primaryLightBg,
                                          AppColors.primary
                                        ],
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
