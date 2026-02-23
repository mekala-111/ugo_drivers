import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';

/// Collapsible Today earnings cards: total, ride count, wallet, and last ride.
class EarningsSummary extends StatefulWidget {
  final double todayTotal;
  final double teamEarnings; // Maps to Wallet
  final int ridesToday;      // Maps to Ride Count
  final double lastRideEarnings; // ✅ Added to match the Figma "Last Ride" box
  final bool isLoading;
  final bool isSmallScreen;

  const EarningsSummary({
    super.key,
    required this.todayTotal,
    required this.teamEarnings,
    required this.ridesToday,
    this.lastRideEarnings = 0.0, // Default to 0.0 if not provided
    this.isLoading = false,
    this.isSmallScreen = false,
  });

  @override
  State<EarningsSummary> createState() => _EarningsSummaryState();
}

class _EarningsSummaryState extends State<EarningsSummary> {
  // ✅ State variable to track if the box is expanded
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w * (widget.isSmallScreen ? 0.035 : 0.04);
    final gap = w * (widget.isSmallScreen ? 0.022 : 0.03);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1), // Grey border from Figma
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Collapsible Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: Row(
                children: [
                  Text(
                    FFLocalizations.of(context).getText('drv_today_total'), // Or hardcode 'Today Total'
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, widget.isSmallScreen ? 14 : 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.isLoading ? '...' : '₹${widget.todayTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, widget.isSmallScreen ? 14 : 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // ✅ Expanded Content (The 3 Orange Boxes)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_ride_count'), // Or 'Ride Count'
                      value: widget.isLoading ? '...' : widget.ridesToday.toString(),
                      isSmallScreen: widget.isSmallScreen,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_wallet'), // Or 'Wallet'
                      value: widget.isLoading ? '...' : '₹${widget.teamEarnings.toStringAsFixed(2)}',
                      isSmallScreen: widget.isSmallScreen,

                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _SummaryCard(
                      title: FFLocalizations.of(context).getText('drv_last_ride'), // Or 'Last Ride'
                      value: widget.isLoading ? '...' : widget.lastRideEarnings.toStringAsFixed(0),
                      isSmallScreen: widget.isSmallScreen,
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(width: double.infinity, height: 0), // Collapsed state
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
  });

  final String title;
  final String value;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCBA4), // Peach/Orange color from Figma
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: Responsive.fontSize(context, isSmallScreen ? 12 : 14),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: Responsive.fontSize(context, isSmallScreen ? 14 : 16),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}