import 'package:flutter/material.dart';

/// Online/Offline toggle switch for driver status.
/// Alias: OnlineStatusToggle for compatibility with spec.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({
    super.key,
    required this.switchValue,
    required this.isDataLoaded,
    required this.onToggle,
  });

  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Text(
            switchValue ? 'ON' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: isDataLoaded ? (_) => onToggle() : null,
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
