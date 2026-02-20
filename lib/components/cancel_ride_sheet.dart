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
    {'key': 'drv_cancel_reason_passenger_no_show', 'value': 'Passenger no-show'},
    {'key': 'drv_cancel_reason_wrong_pickup', 'value': 'Incorrect pickup location'},
    {'key': 'drv_cancel_reason_long_wait', 'value': 'Long waiting time'},
    {'key': 'drv_cancel_reason_wrong_address', 'value': 'Wrong address'},
    {'key': 'drv_cancel_reason_change_plans', 'value': 'Change of plans'},
    {'key': 'drv_cancel_reason_other', 'value': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                FFLocalizations.of(context).getText('drv_select_cancel_reason'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: _reasons.length,
                itemBuilder: (context, index) {
                  final r = _reasons[index];
                  final apiValue = r['value']!;
                  final displayText = _getReasonText(r['key']!, apiValue);
                  final isSelected = _selectedReason == apiValue;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : Colors.grey[400],
                      size: 24,
                    ),
                    title: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    onTap: () => setState(() => _selectedReason = apiValue),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedReason == null
                      ? null
                      : () => Navigator.pop(context, _selectedReason),
                  child: Text(
                    FFLocalizations.of(context).getText('drv_cancel_ride'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
