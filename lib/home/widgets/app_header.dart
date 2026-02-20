import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
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
    required this.screenWidth,
    required this.isSmallScreen,
    this.balance,
    this.profileImageUrl,
    this.notificationCount = 0,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool switchValue;
  final bool isDataLoaded;
  final VoidCallback onToggleOnline;
  final double screenWidth;
  final bool isSmallScreen;
  final double? balance;
  final String? profileImageUrl;
  final int notificationCount;

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
              if (balance != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${balance!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
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
                onTap: () => context.pushNamed(ProfileSettingWidget.routeName),
                child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white24,
                        backgroundImage: profileImageUrl!.startsWith('http')
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: profileImageUrl!.startsWith('http')
                            ? null
                            : const Icon(Icons.person, color: Colors.white, size: 18),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              if (notificationCount > 0)
                Badge(
                  label: Text('$notificationCount'),
                  child: InkWell(
                    onTap: () => context.pushNamed(InboxPageWidget.routeName),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 22),
                  ),
                )
              else
                InkWell(
                  onTap: () => context.pushNamed(InboxPageWidget.routeName),
                  child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
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
