import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. REUSABLE PAYMENT MODE CARD WIDGET
// ==========================================
class PaymentModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String value;
  final String selectedValue;
  final List<Color> gradientColors;
  final Function(String) onSelect;

  const PaymentModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.value,
    required this.selectedValue,
    required this.gradientColors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect(value);
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSelected
                  ? const Icon(Icons.check_circle,
                  key: ValueKey('checked'),
                  color: Colors.white,
                  size: 28)
                  : const Icon(Icons.radio_button_unchecked,
                  key: ValueKey('unchecked'),
                  color: Colors.white70,
                  size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. MAIN PAGE SCAFFOLD
// ==========================================
class PreferredEarningModeWidget extends StatefulWidget {
  const PreferredEarningModeWidget({super.key});

  static String routeName = 'preferredEarningMode';
  static String routePath = '/preferredEarningMode';

  @override
  State<PreferredEarningModeWidget> createState() =>
      _PreferredEarningModeWidgetState();
}

class _PreferredEarningModeWidgetState
    extends State<PreferredEarningModeWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _selected = FFAppState().preferredEarningMode;
  }

  void _selectMode(String mode) {
    setState(() => _selected = mode);
    FFAppState().preferredEarningMode = mode;
  }

  void _goNext() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a preferred earning mode.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.pushNamed(
      OnBoardingWidget.routeName,
      queryParameters: {
        'mobile': serializeParam(FFAppState().mobileNo, ParamType.int),
        'referalcode': serializeParam(
          FFAppState().usedReferralCode.isNotEmpty
              ? FFAppState().usedReferralCode
              : FFAppState().referralCode,
          ParamType.String,
        ),
      }.withoutNulls,
      extra: const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.rightToLeft,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

    final isValid = _selected.isNotEmpty;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgOffWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Header Section ---
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [brandGradientStart, brandPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: brandPrimary.withValues(alpha:0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Payment Preference',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How would you like to collect fares?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressIndicator(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- Selection Cards Section ---
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      PaymentModeCard(
                        title: 'Cash Only',
                        subtitle: 'Collect payments in cash',
                        emoji: '💵',
                        value: 'cash',
                        selectedValue: _selected,
                        // Vibrant Green for Cash
                        gradientColors: const [Color(0xFFECCFA8), Color(
                            0xFFF3A739)],
                        onSelect: _selectMode,
                      ),
                      const SizedBox(height: 16),
                      PaymentModeCard(
                        title: 'Online Only',
                        subtitle: 'Receive payments via Wallet',
                        emoji: '📱',
                        value: 'online',
                        selectedValue: _selected,
                        // Vibrant Blue for Digital/Online
                        gradientColors: const [Color(0xFFFFFFFF), Color(0xFF2563EB)],
                        onSelect: _selectMode,
                      ),
                      const SizedBox(height: 16),
                      PaymentModeCard(
                        title: 'Both',
                        subtitle: 'Accept cash and online payments',
                        emoji: '🤝',
                        value: 'both',
                        selectedValue: _selected,
                        // Vibrant Purple/Indigo for Both
                        gradientColors: const [Color(0xFFB8DFB2), Color(
                            0xFF67ED3A)],
                        onSelect: _selectMode,
                      ),
                      const Spacer(),

                      // --- Sticky Bottom Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isValid ? _goNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPrimary,
                            foregroundColor: Colors.white,
                            elevation: isValid ? 4 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isValid ? Colors.white : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1.0, // Assuming this is the final step
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha:0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Step 3 of 3',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}