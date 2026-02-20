import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'account_management_model.dart';
export 'account_management_model.dart';
import '/services/voice_service.dart';

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

  Future<void> _showLanguageSelector() async {
    const options = [
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'hi', 'label': 'हिंदी', 'flag': '🇮🇳'},
      {'code': 'te', 'label': 'తెలుగు', 'flag': '🇮🇳'},
    ];
    final currentLang = FFLocalizations.of(context).languageCode;

    if (!mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              FFLocalizations.of(context).getVariableText(
                enText: 'Select Language',
                hiText: 'भाषा चुनें',
                teText: 'భాష ఎంచుకోండి',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              FFLocalizations.of(context).getVariableText(
                enText: 'App and voice will use this language',
                hiText: 'ऐप और वॉयस इस भाषा का उपयोग करेंगे',
                teText: 'యాప్ మరియు వాయిస్ ఈ భాషను ఉపయోగిస్తాయి',
              ),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final code = opt['code']!;
              final isSelected = currentLang == code;
              return InkWell(
                onTap: () => Navigator.pop(ctx, code),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPurple.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accentPurple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opt['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Text(
                        opt['label']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.accentPurple : AppColors.textDark,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle, color: AppColors.accentPurple, size: 24),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );

    if (selected != null && selected != currentLang && mounted) {
      await FFLocalizations.storeLocale(selected);
      VoiceService().setLanguage(selected);
      setAppLanguage(context, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selected == 'en'
                  ? 'Language changed to English'
                  : selected == 'hi'
                      ? 'भाषा हिंदी में बदल दी गई'
                      : 'భాష తెలుగుకు మార్చబడింది',
            ),
            backgroundColor: AppColors.accentPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 APP COLORS
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

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
                            child: Text(
                              FFLocalizations.of(context).getText('drv_manage_prefs'),
                              style: const TextStyle(
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
        'subtitle': FFLocalizations.of(context).getText('drv_view_messages'),
        'color': AppColors.accentIndigo,
        'onTap': () => context.pushNamed(InboxPageWidget.routeName),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'title': FFLocalizations.of(context).getText('u3u05cev' /* Wallet */),
        'subtitle': FFLocalizations.of(context).getText('drv_check_balance'),
        'color': AppColors.accentEmerald,
        'onTap': () => context.pushNamed(WalletWidget.routeName),
      },
      {
        'icon': Icons.person_rounded,
        'title': FFLocalizations.of(context).getVariableText(
          enText: 'Profile',
          hiText: 'प्रोफ़ाइल',
          teText: 'ప్రొఫైల్',
        ),
        'subtitle': FFLocalizations.of(context).getText('drv_edit_info'),
        'color': AppColors.accentAmber,
        'onTap': () => context.pushNamed(AccountSupportWidget.routeName),
      },
      {
        'icon': Icons.language_rounded,
        'title': FFLocalizations.of(context).getVariableText(
          enText: 'Language',
          hiText: 'भाषा',
          teText: 'భాష',
        ),
        'subtitle': FFLocalizations.of(context).getVariableText(
          enText: 'App & voice language',
          hiText: 'ऐप और वॉयस भाषा',
          teText: 'యాప్ మరియు వాయిస్ భాష',
        ),
        'color': AppColors.accentPurple,
        'onTap': _showLanguageSelector,
      },
      {
        'icon': Icons.record_voice_over_rounded,
        'title': FFLocalizations.of(context).getText('drv_voice'),
        'subtitle': FFLocalizations.of(context).getText('drv_ride_announcements'),
        'color': AppColors.accentPink,
        'isSwitch': true,
      },
      {
        'icon': Icons.description_rounded,
        'title': FFLocalizations.of(context).getText('utfxvwam' /* Terms & Conditions */),
        'subtitle': FFLocalizations.of(context).getText('drv_legal_info'),
        'color': AppColors.greySlate,
        'onTap': () => context.pushNamed(TermsConditionsWidget.routeName),
      },
      {
        'icon': Icons.privacy_tip_rounded,
        'title': FFLocalizations.of(context).getText('drv_privacy_policy'),
        'subtitle': FFLocalizations.of(context).getText('drv_how_we_handle'),
        'color': AppColors.accentIndigo,
        'onTap': () => context.pushNamed(PrivacyPolicyPageWidget.routeName),
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
          final isSwitch = item['isSwitch'] == true;

          return Column(
            children: [
              InkWell(
                onTap: isSwitch
                    ? () async {
                        final v = VoiceService().voiceEnabled;
                        await VoiceService().setVoiceEnabled(!v);
                        if (mounted) setState(() {});
                      }
                    : item['onTap'] as VoidCallback,
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
                                color: AppColors.textDark,
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
                      if (isSwitch)
                        Switch.adaptive(
                          value: VoiceService().voiceEnabled,
                          onChanged: (v) async {
                            await VoiceService().setVoiceEnabled(v);
                            if (mounted) setState(() {});
                          },
                        )
                      else
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

}