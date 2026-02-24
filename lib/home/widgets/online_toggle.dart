import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/constants/app_colors.dart';

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
    // Sizing adjustments for responsiveness
    final double trackWidth = Responsive.fontSize(context, 52);
    final double trackHeight = Responsive.fontSize(context, 28);
    final double thumbSize = trackHeight - 6; // 3px padding on all sides

    return GestureDetector(
      onTap: isDataLoaded ? onToggle : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "ON" / "OFF" Text
          Text(
            switchValue ? 'ON' : 'OFF',
            textScaler: MediaQuery.textScalerOf(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500, // slightly lighter than bold to match Figma
              fontSize: Responsive.fontSize(context, 16),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: Responsive.fontSize(context, 10)),

          // Custom Figma Switch
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: trackWidth,
            height: trackHeight,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              // Solid white when ON, translucent when OFF
              color: switchValue ? Colors.white : Colors.white.withValues(alpha: 0.4),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              // Move thumb left/right based on state
              alignment: switchValue ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Orange thumb when ON, white thumb when OFF
                  color: switchValue ? AppColors.primary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias for OnlineToggle (uses switchValue/onToggle from parent; parent may use FFAppState().isonline).
typedef OnlineStatusToggle = OnlineToggle;