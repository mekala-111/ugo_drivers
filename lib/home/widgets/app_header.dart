import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/index.dart';
import 'package:ugo_driver/home/widgets/online_toggle.dart';

/// AppBar with balance, profile avatar, notifications, online toggle.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.scaffoldKey,
    required this.switchValue,
    required this.isDataLoaded,
    required this.onToggleOnline,
    this.showOnlineToggle = true,
    this.accountInactive = false,
    this.preventGoingOffline = false,
    required this.screenWidth,
    required this.isSmallScreen,
    this.balance,
    this.profileImageUrl,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.isRideLocked = false,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggleOnline;
  final bool showOnlineToggle;
  /// Admin disabled driver (`is_active: false`) — show label, not an ON switch.
  final bool accountInactive;
  /// While on an active ride, keep the online switch on (cannot slide off).
  final bool preventGoingOffline;
  final double screenWidth;
  final bool isSmallScreen;
  final double? balance;
  final String? profileImageUrl;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool isRideLocked;

  @override
  Widget build(BuildContext context) {
    final iconSz = Responsive.iconSize(context, base: isSmallScreen ? 24 : 28);
    final headerH =
        Responsive.value(context, small: 48.0, medium: 54.0, large: 60.0);
    final hPad = Responsive.horizontalPadding(context);
    const minTap = Responsive.minTouchTarget;
    return Container(
      width: double.infinity,
      height: headerH,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tapTarget(
                onTap:
                    isRideLocked ? null : () => scaffoldKey.currentState?.openDrawer(),
                child: Icon(Icons.menu, color: Colors.white, size: iconSz),
                minSize: minTap,
              ),
              if (switchValue && !isRideLocked)
                _tapTarget(
                  onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                  child: Icon(Icons.qr_code, color: Colors.white, size: iconSz),
                  minSize: minTap,
                )
              else
                const SizedBox(width: minTap, height: minTap),
              if (accountInactive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    FFLocalizations.of(context).getText('drv_header_inactive'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else if (showOnlineToggle)
                OnlineToggle(
                  switchValue: switchValue,
                  isDataLoaded: isDataLoaded,
                  onToggle: isRideLocked ? () {} : onToggleOnline,
                  blockGoingOffline: preventGoingOffline,
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'OFFLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isRideLocked)
                _tapTarget(
                  onTap: null,
                  child: Icon(Icons.lock, color: Colors.white, size: iconSz - 2),
                  minSize: minTap,
                )
              else if (notificationCount > 0)
                Badge(
                  label: Text('$notificationCount'),
                  child: _tapTarget(
                    onTap: () => onNotificationTap != null
                        ? onNotificationTap!()
                        : context.pushNamed(InboxPageWidget.routeName),
                    child: Icon(Icons.notifications_none,
                        color: Colors.white, size: iconSz),
                    minSize: minTap,
                  ),
                )
              else
                _tapTarget(
                  onTap: () => onNotificationTap != null
                      ? onNotificationTap!()
                      : context.pushNamed(InboxPageWidget.routeName),
                  child: Icon(Icons.notifications_none,
                      color: Colors.white, size: iconSz),
                  minSize: minTap,
                ),
              _tapTarget(
                onTap:
                    isRideLocked ? null : () => context.pushNamed(TeampageWidget.routeName),
                child: Icon(Icons.people, color: Colors.white, size: iconSz),
                minSize: minTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tapTarget({
    required VoidCallback? onTap,
    required Widget child,
    required double minSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(minSize / 2),
        child: SizedBox(
          width: minSize,
          height: minSize,
          child: Center(child: child),
        ),
      ),
    );
  }
}
