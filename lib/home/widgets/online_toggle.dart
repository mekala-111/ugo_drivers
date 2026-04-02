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
    final canInteract =
        isDataLoaded && !(blockGoingOffline && switchValue);
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: pad, vertical: vPad.clamp(2.0, 8.0)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Text(
            switchValue ? 'ON' : 'OFF',
            textScaler: MediaQuery.textScalerOf(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: canInteract ? (_) => onToggle() : null,
            activeTrackColor: Colors.green,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Alias for OnlineToggle (uses switchValue/onToggle from parent; parent may use FFAppState().isonline).
typedef OnlineStatusToggle = OnlineToggle;
