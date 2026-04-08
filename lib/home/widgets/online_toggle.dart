import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/responsive.dart';

/// Online/Offline toggle switch for driver status.
/// Alias: OnlineStatusToggle for compatibility with spec.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({
    super.key,
    required this.switchValue,
    required this.isDataLoaded,
    required this.onToggle,
    this.blockGoingOffline = false,
  });

  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggle;

  /// While online on an active ride, disable turning the switch off (Rapido-style).
  final bool blockGoingOffline;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context) * 0.75;
    final vPad = MediaQuery.sizeOf(context).height * 0.006;

    // FIX 1: Always allow interaction if data is loaded.
    // We let the HomeController handle the `blockGoingOffline` rejection
    // so it can actually show the error SnackBar to the driver.
    final canInteract = isDataLoaded;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: pad,
          vertical: vPad.clamp(2.0, 8.0)
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // FIX 2: Prevents the Row from stretching infinitely in the App Header
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4.0),
            child: Text(
              switchValue ? 'ON' : 'OFF',
              textScaler: MediaQuery.textScalerOf(context),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 14),
              ),
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: canInteract ? (_) => onToggle() : null,
            activeTrackColor: Colors.green,
            activeColor: Colors.white, // Sets the active thumb color
            inactiveTrackColor: Colors.grey.shade400,
            inactiveThumbColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces extra built-in margins
          ),
        ],
      ),
    );
  }
}

/// Alias for OnlineToggle (uses switchValue/onToggle from parent; parent may use FFAppState().isonline).
typedef OnlineStatusToggle = OnlineToggle;