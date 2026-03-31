import 'package:flutter/material.dart';
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
    required this.onOpenDocuments,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.canGoOnline,
    this.documentsIncomplete = false,
  });

  final String driverName;
  final String greeting;
  final bool isDataLoaded;
  final VoidCallback onGoOnline;
  final VoidCallback onOpenDocuments;
  final String verificationStatus;
  final String rejectionReason;
  /// True only when API says all required docs are uploaded **and** KYC is approved.
  final bool canGoOnline;
  /// True when API `kyc_doc_status.all_uploaded` is false.
  final bool documentsIncomplete;

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

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final btnH = Responsive.buttonHeight(context,
        base: 56); // Slightly taller for premium feel

    final normalizedStatus = widget.verificationStatus
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final isApproved =
        normalizedStatus == 'approved' || normalizedStatus == 'verified';
    final isRejected =
        normalizedStatus == 'rejected' || normalizedStatus == 'declined';
    final isPending = normalizedStatus == 'pending' ||
        normalizedStatus == 'in_review' ||
        normalizedStatus == 'under_review' ||
        normalizedStatus == 'pending_verification' ||
        normalizedStatus == 'submitted';

    String titleText = FFLocalizations.of(context).getText('drv_offline');
    String subtitleText =
        'Ready to start earning? Go online to receive ride requests.';
    IconData stateIcon = Icons.bedtime_rounded;
    Color stateColor = Colors.grey.shade400;

    if (isPending) {
      titleText = 'Pending for verification';
      subtitleText = 'Waiting for admin approval. Your documents are under review.';
      stateIcon = Icons.hourglass_top_rounded;
      stateColor = Colors.amber.shade700;
    } else if (isRejected) {
      titleText = 'Documents rejected';
      final reason = widget.rejectionReason.trim();
      subtitleText = reason.isEmpty
          ? 'Your documents were rejected. Please upload clear and valid documents.'
          : 'Reason: $reason';
      stateIcon = Icons.cancel_rounded;
      stateColor = Colors.red.shade400;
    } else if (widget.documentsIncomplete) {
      titleText = 'Documents required';
      subtitleText =
          'Upload all required documents to continue. You will be able to go online after admin approval.';
      stateIcon = Icons.upload_file_rounded;
      stateColor = AppColors.primary;
    } else if (!isApproved) {
      titleText = 'Offline';
      subtitleText = 'Complete documents to start earning.';
      stateIcon = Icons.file_present_rounded;
      stateColor = AppColors.primary;
    }

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

              SizedBox(height: Responsive.verticalSpacing(context) * 5),

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
                          stateIcon,
                          size: Responsive.value(context,
                              small: 70.0, medium: 80.0, large: 90.0),
                          color: stateColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 4),

              // --- Status Text ---
              Text(
                titleText,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              SizedBox(height: Responsive.verticalSpacing(context) * 5),

              if (isPending)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text(
                    'Waiting for admin approval. Your documents are under review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    if (widget.canGoOnline && widget.isDataLoaded) {
                      widget.onGoOnline();
                    } else if (widget.documentsIncomplete) {
                      widget.onOpenDocuments();
                    } else {
                      widget.onGoOnline();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: pad * 2.5,
                      vertical: btnH * 0.25,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (widget.canGoOnline && widget.isDataLoaded)
                            ? [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8)
                              ]
                            : [
                                AppColors.primary.withValues(alpha: 0.92),
                                AppColors.primary.withValues(alpha: 0.8)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
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
                          child: Icon(
                            widget.canGoOnline
                                ? Icons.power_settings_new_rounded
                                : Icons.upload_file_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.canGoOnline
                              ? FFLocalizations.of(context)
                                  .getText('drv_go_online')
                              : (isRejected
                                  ? 'Re-upload documents'
                                  : (widget.documentsIncomplete
                                      ? 'Complete documents'
                                      : 'Verification status')),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.fontSize(context, 17),
                            fontWeight: FontWeight.w700,
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
