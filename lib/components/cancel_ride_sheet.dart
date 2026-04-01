import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/constants/app_colors.dart';

/// Rapido-style bottom sheet: driver selects a cancellation reason before cancelling.
/// Returns the selected reason string, or null if dismissed without selecting.
Future<String?> showCancelRideReasonSheet(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _CancelRideSheet(),
  );
}

class _CancelRideSheet extends StatefulWidget {
  const _CancelRideSheet();

  @override
  State<_CancelRideSheet> createState() => _CancelRideSheetState();
}

class _CancelRideSheetState extends State<_CancelRideSheet> {
  String? _selectedReason;

  /// [key] = i18n key, [value] = value sent to API (English slug/description)
  static const List<Map<String, String>> _reasons = [
    {'key': 'drv_cancel_reason_emergency', 'value': 'Personal emergency'},
    {'key': 'drv_cancel_reason_vehicle', 'value': 'Vehicle issues'},
    {
      'key': 'drv_cancel_reason_passenger_no_show',
      'value': 'Passenger no-show'
    },
    {
      'key': 'drv_cancel_reason_wrong_pickup',
      'value': 'Incorrect pickup location'
    },
    {'key': 'drv_cancel_reason_long_wait', 'value': 'Long waiting time'},
    {'key': 'drv_cancel_reason_wrong_address', 'value': 'Wrong address'},
    {'key': 'drv_cancel_reason_change_plans', 'value': 'Change of plans'},
    {'key': 'drv_cancel_reason_other', 'value': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: bottom > 0 ? 0 : 8),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.18),
                            AppColors.primaryLight.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.cancel_schedule_send_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context)
                                .getText('drv_select_cancel_reason'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick the closest reason. This helps us improve matches.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  itemCount: _reasons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = _reasons[index];
                    final apiValue = r['value']!;
                    final displayText = _getReasonText(r['key']!, apiValue);
                    final isSelected = _selectedReason == apiValue;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedReason = apiValue),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.greyBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.greyLight,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          disabledBackgroundColor: AppColors.greyBg,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _selectedReason == null
                            ? null
                            : () => Navigator.pop(context, _selectedReason),
                        child: Text(
                          FFLocalizations.of(context).getText('drv_cancel_ride'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Go back',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greySlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getReasonText(String key, String fallback) {
    try {
      final t = FFLocalizations.of(context).getText(key);
      return (t != key) ? t : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
