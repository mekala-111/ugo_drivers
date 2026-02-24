import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/index.dart';
import 'package:ugo_driver/home/widgets/online_toggle.dart';

/// AppBar with menu, QR (when online), online toggle, notifications, team.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.scaffoldKey,
    required this.switchValue,
    required this.isDataLoaded,
    required this.onToggleOnline,
    required this.screenWidth,
    required this.isSmallScreen,
    this.profileImageUrl,
    this.notificationCount = 0,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggleOnline;
  final double screenWidth;
  final bool isSmallScreen;
  final String? profileImageUrl;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final iconSz = Responsive.iconSize(context, base: isSmallScreen ? 24 : 28);
    final hPad = Responsive.horizontalPadding(context);
    const minTap = Responsive.minTouchTarget;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        top: false, // Keeping your original SafeArea logic
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: MediaQuery.sizeOf(context).height * 0.01,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==========================================
              // LEFT SECTION: Menu & QR Code
              // ==========================================
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _tapTarget(
                      onTap: () => scaffoldKey.currentState?.openDrawer(),
                      child:
                          Icon(Icons.menu, color: Colors.white, size: iconSz),
                      minSize: minTap,
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    if (switchValue)
                      _tapTarget(
                        onTap: () =>
                            context.pushNamed(ScanToBookWidget.routeName),
                        // ✅ Figma-matched White Rounded QR Box
                        child: Container(
                          width: isSmallScreen ? 34 : 38,
                          height: isSmallScreen ? 34 : 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.qr_code_2,
                            color: Colors.black87,
                            size: isSmallScreen ? 22 : 26,
                          ),
                        ),
                        minSize: minTap,
                      )
                  ],
                ),
              ),

              // ==========================================
              // CENTER SECTION: Online Toggle
              // ==========================================
              OnlineToggle(
                switchValue: switchValue,
                isDataLoaded: isDataLoaded,
                onToggle: onToggleOnline,
              ),

              // ==========================================
              // RIGHT SECTION: Notifications & Team
              // ==========================================
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Notification Bell
                    if (notificationCount > 0)
                      Badge(
                        label: Text('$notificationCount'),
                        child: _tapTarget(
                          onTap: () =>
                              context.pushNamed(InboxPageWidget.routeName),
                          child: Icon(Icons.notifications,
                              color: Colors.white, size: iconSz),
                          minSize: minTap,
                        ),
                      )
                    else
                      _tapTarget(
                        onTap: () =>
                            context.pushNamed(InboxPageWidget.routeName),
                        child: Icon(Icons.notifications_none,
                            color: Colors.white, size: iconSz),
                        minSize: minTap,
                      ),

                    SizedBox(width: isSmallScreen ? 12 : 16),

                    // ✅ Figma-matched Team Avatar & Text
                    _tapTarget(
                      onTap: () => context.pushNamed(TeampageWidget.routeName),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmallScreen ? 30 : 34,
                            height: isSmallScreen ? 30 : 34,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: profileImageUrl != null &&
                                      profileImageUrl!.isNotEmpty
                                  ? Image.network(profileImageUrl!,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.groups,
                                      color: AppColors.primary, size: 20),
                            ),
                          ),
                        ],
                      ),
                      minSize: minTap,
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

  // ✅ Helper for clean, accessible tap targets
  Widget _tapTarget({
    required VoidCallback onTap,
    required Widget child,
    required double minSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(minSize / 2),
        child: Container(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
