import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';

/// Collapsible Today earnings cards: total, ride count, wallet, and last ride.
class EarningsSummary extends StatefulWidget {
  final double todayTotal;
  final double teamEarnings; // Maps to Wallet
  final int ridesToday;      // Maps to Ride Count
  final double lastRideEarnings; // Matches the Figma "Last Ride" box
  final bool isLoading;
  final bool isSmallScreen;
  final VoidCallback? onRideCountTap;
  final VoidCallback? onWalletTap;
  final VoidCallback? onLastRideTap;

  const EarningsSummary({
    super.key,
    required this.todayTotal,
    required this.teamEarnings,
    required this.ridesToday,
    this.lastRideEarnings = 0.0,
    this.isLoading = false,
    this.isSmallScreen = false,
    this.onRideCountTap,
    this.onWalletTap,
    this.onLastRideTap,
  });

  @override
  State<EarningsSummary> createState() => _EarningsSummaryState();
}

class _EarningsSummaryState extends State<EarningsSummary> {
  // Starts collapsed
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w * (widget.isSmallScreen ? 0.035 : 0.04);
    final gap = w * (widget.isSmallScreen ? 0.022 : 0.03);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Collapsible Header (Strictly expands/collapses) ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // ✅ Strictly toggles the panel, no navigation
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('drv_today_total'),
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, widget.isSmallScreen ? 15 : 17),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.isLoading ? '...' : '₹${widget.todayTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, widget.isSmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Expanded Content (The 3 Orange Boxes) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutQuart,
            child: _isExpanded
                ? Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_ride_count'),
                      value: widget.isLoading ? '...' : widget.ridesToday.toString(),
                      isSmallScreen: widget.isSmallScreen,
                      onTap: widget.onRideCountTap,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_wallet'),
                      value: widget.isLoading ? '...' : '₹${widget.teamEarnings.toStringAsFixed(2)}',
                      isSmallScreen: widget.isSmallScreen,
                      onTap: widget.onWalletTap,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_last_ride'),
                      value: widget.isLoading ? '...' : '₹${widget.lastRideEarnings.toStringAsFixed(0)}',
                      isSmallScreen: widget.isSmallScreen,
                      onTap: widget.onLastRideTap,
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

// --- The Updated Summary Card ---
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.isSmallScreen,
    this.onTap,
  });

  final String title;
  final String value;
  final bool isSmallScreen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD4B2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 16,
            horizontal: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: Responsive.fontSize(context, isSmallScreen ? 12 : 13),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Responsive.fontSize(context, isSmallScreen ? 16 : 18),
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}