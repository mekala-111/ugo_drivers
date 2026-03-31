import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ugo_driver/app_state.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';
import 'package:ugo_driver/index.dart';

/// Offline state dashboard: greeting, driver name, "Go Online" CTA.
/// Shown when driver is offline (MapContainer is hidden).
class OfflineDashboard extends StatefulWidget {
  const OfflineDashboard({
    super.key,
    required this.driverName,
    required this.greeting,
    required this.isDataLoaded,
    required this.onGoOnline,
  });

  final String driverName;
  final String greeting;
  final bool isDataLoaded;
  final VoidCallback onGoOnline;

  @override
  State<OfflineDashboard> createState() => _OfflineDashboardState();
}

class _OfflineDashboardState extends State<OfflineDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // Creates a smooth, continuous "breathing" animation for the central icon
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Widget _kycStatusBanner(BuildContext context) {
    final kyc = context.watch<FFAppState>().kycStatus.trim().toLowerCase();
    if (kyc == 'approved') return const SizedBox.shrink();

    final String textKey;
    if (kyc == 'rejected') {
      textKey = 'drv_kyc_rejected';
    } else if (kyc == 'pending_verification' || kyc == 'pending') {
      textKey = 'drv_kyc_waiting_admin';
    } else {
      textKey = 'drv_kyc_need_docs';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kyc == 'rejected'
            ? Colors.red.shade50
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kyc == 'rejected'
              ? Colors.red.shade200
              : Colors.amber.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            kyc == 'rejected' ? Icons.error_outline : Icons.hourglass_top_rounded,
            color: kyc == 'rejected' ? Colors.red.shade800 : Colors.amber.shade900,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              FFLocalizations.of(context).getText(textKey),
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 13),
                height: 1.35,
                color: kyc == 'rejected'
                    ? Colors.red.shade900
                    : Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final btnH = Responsive.buttonHeight(context,
        base: 56); // Slightly taller for premium feel
    final appState = context.watch<FFAppState>();
    final kyc = appState.kycStatus.trim().toLowerCase();
    final isHardBlocked =
        kyc != 'approved' || appState.isActive != true; // must be approved & active

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Soft, vibrant gradient background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.15), // Light warm tint at top
            Colors.white,
            Colors.white,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: pad,
            vertical: Responsive.verticalSpacing(context) * 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Responsive.verticalSpacing(context) * 2),

              // --- Greeting Section ---
              Text(
                '${widget.greeting} 👋', // Added friendly wave
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 20),
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.driverName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 32),
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 2),
              _kycStatusBanner(context),
              SizedBox(height: Responsive.verticalSpacing(context) * 3),

              // --- Animated Central Graphic ---
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: Responsive.value(context,
                      small: 160.0, medium: 180.0, large: 200.0),
                  height: Responsive.value(context,
                      small: 160.0, medium: 180.0, large: 200.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft background circle inside
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          Icons
                              .bedtime_rounded, // Changed to a lovely moon/sleep icon
                          size: Responsive.value(context,
                              small: 70.0, medium: 80.0, large: 90.0),
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 4),

              // --- Status Text ---
              Text(
                FFLocalizations.of(context).getText('drv_offline'),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to start earning? Go online to receive ride requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 5),

              // --- Premium CTA Button ---
              GestureDetector(
                onTap:
                    (widget.isDataLoaded && !isHardBlocked) ? widget.onGoOnline : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: pad * 2.5,
                    vertical: btnH * 0.25,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: (widget.isDataLoaded && !isHardBlocked)
                          ? [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8)
                            ]
                          : [Colors.grey.shade400, Colors.grey.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: widget.isDataLoaded && !isHardBlocked
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.power_settings_new_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        FFLocalizations.of(context).getText('drv_go_online'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 2),
            ],
          ),
        ),
      ),
    );
  }
}
