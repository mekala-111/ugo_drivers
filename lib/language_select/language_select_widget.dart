import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectWidget extends StatefulWidget {
  const LanguageSelectWidget({super.key});

  static String routeName = 'language_select';
  static String routePath = '/language_select';

  @override
  State<LanguageSelectWidget> createState() => _LanguageSelectWidgetState();
}

class _LanguageSelectWidgetState extends State<LanguageSelectWidget> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final stored = FFLocalizations.getStoredLocale();
    if (stored != null) {
      _selectedLanguage = stored.languageCode;
    }
  }

  Future<void> _applyLanguage() async {
    await FFLocalizations.storeLocale(_selectedLanguage);
    if (mounted) {
      MyApp.of(context).setLocale(_selectedLanguage);
      context.goNamed(LoginWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    final isPortrait = size.height > size.width;

    final headerHeight = isPortrait
        ? (isTablet
            ? 320.0
            : isSmallScreen
                ? 240.0
                : 280.0)
        : (isTablet ? 220.0 : 180.0);
    final scale = isTablet
        ? 1.15
        : isSmallScreen
            ? 0.9
            : 1.0;
    final horizontalPadding = isTablet
        ? 40.0
        : isSmallScreen
            ? 16.0
            : 24.0;
    final cardPadding = isTablet
        ? 28.0
        : isSmallScreen
            ? 18.0
            : 22.0;

    final titleSize = isSmallScreen ? 24.0 : (isTablet ? 34.0 : 30.0);
    final subtitleSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);
    final buttonHeight = isSmallScreen ? 48.0 : (isTablet ? 62.0 : 56.0);
    final buttonFontSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);

    final options = <_LanguageOption>[
      const _LanguageOption('en', 'langsel0004'),
      const _LanguageOption('hi', 'langsel0005'),
      const _LanguageOption('te', 'langsel0006'),
    ];

    return Scaffold(
      backgroundColor: bgOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandGradientStart, brandPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: 20 * scale),
                      const Spacer(),
                      Text(
                        FFLocalizations.of(context).getText('langsel0001'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          fontSize: titleSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        FFLocalizations.of(context).getText('langsel0002'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: subtitleSize,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 32 * scale),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -30 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : (isTablet ? 32.0 : 20.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText('langsel0003'),
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          ...options.map((option) {
                            return RadioListTile<String>(
                              value: option.code,
                              groupValue: _selectedLanguage,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: brandPrimary,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedLanguage = value);
                              },
                              title: Text(
                                FFLocalizations.of(context)
                                    .getText(option.labelKey),
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 16 * scale),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: _applyLanguage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandPrimary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                FFLocalizations.of(context)
                                    .getText('langsel0007'),
                                style: GoogleFonts.interTight(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption(this.code, this.labelKey);

  final String code;
  final String labelKey;
}
