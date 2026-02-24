import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- Custom Staggered Animation Widget ---
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)), // Slides up smoothly
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class LastOrderWidget extends StatefulWidget {
  const LastOrderWidget({super.key});

  static const String routeName = 'LastOrder';
  static const String routePath = '/lastOrder';

  @override
  State<LastOrderWidget> createState() => _LastOrderWidgetState();
}

class _LastOrderWidgetState extends State<LastOrderWidget> {
  bool loading = true;
  Map? lastRide;

  @override
  void initState() {
    super.initState();
    fetchLastRide();
  }

  Future<void> fetchLastRide() async {
    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;
    if (token.isEmpty || driverId <= 0) {
      if (mounted) setState(() => loading = false);
      return;
    }

    var rides = <dynamic>[];
    final earningsRes = await DriverEarningsCall.call(
      token: token,
      driverId: driverId,
      period: 'weekly',
    );

    if (earningsRes.succeeded) {
      final list = DriverEarningsCall.rides(earningsRes.jsonBody);
      if (list != null && list.isNotEmpty) {
        rides = List<dynamic>.from(list);
      }
    }

    if (rides.isEmpty) {
      final historyRes = await DriverRideHistoryCall.call(
        token: token,
        id: driverId,
      );
      if (historyRes.succeeded) {
        var fromRides = DriverRideHistoryCall.completedRides(historyRes.jsonBody);
        if (fromRides.isEmpty) {
          fromRides = DriverRideHistoryCall.completedOrders(historyRes.jsonBody);
        }
        if (fromRides.isEmpty) {
          fromRides = DriverRideHistoryCall.rides(historyRes.jsonBody);
        }
        rides = fromRides;
      }
    }

    if (rides.isNotEmpty && mounted) {
      rides = List<dynamic>.from(rides);
      rides.sort((a, b) {
        final aVal = (a is Map ? a['completedAt'] ?? a['createdAt'] ?? a['date'] : null)?.toString() ?? '';
        final bVal = (b is Map ? b['completedAt'] ?? b['createdAt'] ?? b['date'] : null)?.toString() ?? '';
        return bVal.compareTo(aVal);
      });
      setState(() {
        lastRide = rides.first is Map ? rides.first as Map : null;
        loading = false;
      });
    } else if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = "Unknown Date";
    String timeStr = "";
    final dateVal = lastRide != null
        ? (lastRide!['completedAt'] ?? lastRide!['createdAt'] ?? lastRide!['date'])
        : null;
    if (dateVal != null) {
      try {
        final dt = DateTime.parse(dateVal.toString());
        dateStr = DateFormat('MMM d, yyyy').format(dt);
        timeStr = DateFormat('h:mm a').format(dt);
      } catch (e) {
        dateStr = dateVal.toString();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Soft off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        ),
        title: Column(
          children: [
            Text(
              "Ride Details",
              style: GoogleFonts.interTight(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (timeStr.isNotEmpty)
              Text(
                "$dateStr • $timeStr",
                style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLightBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text("Help", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : lastRide == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No recent orders found", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order ID & Status Header
            AnimatedListItem(
              index: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${lastRide!['orderId'] ?? lastRide!['rideId'] ?? lastRide!['id'] ?? '---'}",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Completed",
                      style: GoogleFonts.interTight(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Beautiful Earnings Card
            AnimatedListItem(index: 1, child: _buildEarningsCard()),
            const SizedBox(height: 16),

            // 3. Premium Route Info Card
            AnimatedListItem(index: 2, child: _buildRouteInfoCard()),
            const SizedBox(height: 16),

            // 4. Clean Payment Info
            AnimatedListItem(
              index: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: AppColors.primary,
                    collapsedIconColor: Colors.grey.shade400,
                    title: Text("Payment info", style: GoogleFonts.interTight(fontWeight: FontWeight.bold, fontSize: 16)),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Earning", style: GoogleFonts.inter(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            Text("₹${lastRide!['fare'] ?? lastRide!['amount'] ?? '0'}", style: GoogleFonts.interTight(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4E6), Color(0xFFFFE0B2)], // Warm peach gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.orange.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Earnings", style: GoogleFonts.inter(color: Colors.orange.shade800, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹${lastRide!['fare'] ?? lastRide!['amount'] ?? '0'}",
                    style: GoogleFonts.interTight(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -1),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "${lastRide!['distanceKm'] ?? lastRide!['distance'] ?? '0.0'} km • ${lastRide!['durationMinutes'] ?? lastRide!['duration'] ?? '--'} min",
                      style: GoogleFonts.inter(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Glowing "Fixed Commission" Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.blue, size: 20),
                      const SizedBox(height: 2),
                      Text("Fixed", style: GoogleFonts.interTight(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
                      Text("Comm.", style: GoogleFonts.interTight(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Fare received confirmation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  "₹${lastRide!['fare'] ?? lastRide!['amount'] ?? '0'} Fare successfully received",
                  style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    String pickup = lastRide!['pickupAddress'] ?? lastRide!['pickup_address'] ?? lastRide!['from'] ?? "Unknown Pickup Location";
    String drop = lastRide!['dropAddress'] ?? lastRide!['drop_address'] ?? lastRide!['to'] ?? "Unknown Drop Location";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trip Route", style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Beautiful Timeline
                Column(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 3)),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.success, width: 3)),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pickup", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(pickup, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.4)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Drop-off", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(drop, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.4)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}