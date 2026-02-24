import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/index.dart';
// Added for AppColors.primary
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
    // Adjust padding and sizing based on screen size for a tighter fit
    final double hPad = isSmallScreen ? 16.0 : 20.0;
    final double iconSize = isSmallScreen ? 28.0 : 32.0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: isSmallScreen ? 8.0 : 12.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- LEFT SECTION: Menu & QR Box ---
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => scaffoldKey.currentState?.openDrawer(),
                      child: Icon(Icons.menu, color: Colors.white, size: iconSize),
                    ),
                    SizedBox(width: isSmallScreen ? 16 : 20),
                    if (switchValue)
                      InkWell(
                        onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                        child: Container(
                          width: isSmallScreen ? 36 : 40,
                          height: isSmallScreen ? 36 : 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.qr_code_2,
                            color: Colors.black87,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                      )
                  ],
                ),
              ),

              // --- CENTER SECTION: Online Toggle ---
              OnlineToggle(
                switchValue: switchValue,
                isDataLoaded: isDataLoaded,
                onToggle: onToggleOnline,
              ),

              // --- RIGHT SECTION: Team Avatar ---
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => context.pushNamed(TeampageWidget.routeName),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isSmallScreen ? 32 : 36,
                            height: isSmallScreen ? 32 : 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups, // Fallback icon for team
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'TEAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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
}