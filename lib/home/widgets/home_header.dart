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
      height: isSmallScreen ? 45 : 60,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              InkWell(
                onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                child: const Icon(Icons.qr_code, color: Colors.black, size: 24),
              ),
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
