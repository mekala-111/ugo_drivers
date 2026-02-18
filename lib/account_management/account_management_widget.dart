import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'account_management_model.dart';
export 'account_management_model.dart';

class AccountManagementWidget extends StatefulWidget {
  const AccountManagementWidget({super.key});

  static String routeName = 'AccountManagement';
  static String routePath = '/accountManagement';

  @override
  State<AccountManagementWidget> createState() =>
      _AccountManagementWidgetState();
}

class _AccountManagementWidgetState extends State<AccountManagementWidget>
    with SingleTickerProviderStateMixin {
  late AccountManagementModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountManagementModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    // if (confirmLogout == true) {
    //   FFAppState().accessToken = '';
    //   FFAppState().driverid = 0;
    //   FFAppState().profilePhoto = null;
    //   FFAppState().isLoggedIn = false;

    //   context.goNamedAuth(
    //     LoginWidget.routeName,
    //     context.mounted,
    //     extra: <String, dynamic>{
    //       kTransitionInfoKey: const TransitionInfo(
    //         hasTransition: true,
    //         transitionType: PageTransitionType.fade,
    //       ),
    //     },
    //   );
    // }
     if (confirmLogout == true) {
  await FFAppState().clearAppState();   // 🔥 CLEAR EVERYTHING

  if (!context.mounted) return;

  context.goNamedAuth(
    LoginWidget.routeName,
    context.mounted,
    extra: <String, dynamic>{
      kTransitionInfoKey: const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
      ),
    },
  );
}
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 APP COLORS
    const Color brandPrimary = Color(0xFFFF7B10);
    const Color brandGradientStart = Color(0xFFFF8E32);
    const Color bgOffWhite = Color(0xFFF5F7FA);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: Stack(
          children: [
            // 1️⃣ Header Background
            Column(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [brandGradientStart, brandPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => context.pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                FFLocalizations.of(context).getText('87zx8uve' /* Account */),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(height: 4),
                          Center(
                            child: const Text(
                              "Manage your Preferences.",
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 60), // Space for card overlap
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),

            // 2️⃣ Content Layer
            Positioned.fill(
              top: 200, // Overlap the header
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Menu Card
                        _buildMenuCard(),

                        const SizedBox(height: 24),

                        // Logout Button
                        _buildLogoutButton(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    final menuItems = [
      {
        'icon': Icons.message_rounded,
        'title': FFLocalizations.of(context).getText('uwwd4cw4' /* Inbox */),
        'subtitle': 'View messages',
        'color': const Color(0xFF6366F1),
        'onTap': () => context.pushNamed(InboxPageWidget.routeName),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'title': FFLocalizations.of(context).getText('u3u05cev' /* Wallet */),
        'subtitle': 'Check balance',
        'color': const Color(0xFF10B981),
        'onTap': () => context.pushNamed(WalletWidget.routeName),
      },
      {
        'icon': Icons.person_rounded,
        'title': FFLocalizations.of(context).getVariableText(
          enText: 'Profile',
          hiText: 'प्रोफ़ाइल',
          teText: 'ప్రొఫైల్',
        ),
        'subtitle': 'Edit your info',
        'color': const Color(0xFFF59E0B),
        'onTap': () => context.pushNamed(AccountSupportWidget.routeName),
      },
      {
        'icon': Icons.description_rounded,
        'title': FFLocalizations.of(context).getText('utfxvwam' /* Terms & Conditions */),
        'subtitle': 'Legal information',
        'color': const Color(0xFF64748B),
        'onTap': () {},
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(24) : Radius.zero,
                  bottom: isLast ? const Radius.circular(24) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 76,
                  color: Colors.grey[100],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light Red Background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _handleLogout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Text(
              FFLocalizations.of(context).getText('p0413re4' /* Logout */),
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}