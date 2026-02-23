import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/index.dart';
import 'online_toggle.dart';

/// Extracted header for Home screen: menu, QR, online toggle, team.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.scaffoldKey,
    required this.switchValue,
    required this.isDataLoaded,
    required this.onToggleOnline,
    required this.screenWidth,
    required this.isSmallScreen,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggleOnline;
  final double screenWidth;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        top:true,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: isSmallScreen ? 8 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              if (switchValue)
                InkWell(
                  onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                  child: const Icon(Icons.qr_code, color: Colors.black, size: 24),
                )
              else
                const SizedBox(width: 48, height: 48),
              OnlineToggle(
                switchValue: switchValue,
                isDataLoaded: isDataLoaded,
                onToggle: onToggleOnline,
              ),
              InkWell(
                onTap: () => context.pushNamed(TeampageWidget.routeName),
                child: const Icon(Icons.people, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
