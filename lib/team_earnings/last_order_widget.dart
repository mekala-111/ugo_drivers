import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LastOrderWidget extends StatefulWidget {
  const LastOrderWidget({super.key});

  @override
  State<LastOrderWidget> createState() => _LastOrderWidgetState();
}

class _LastOrderWidgetState extends State<LastOrderWidget> {
  bool loading = true;
  Map? lastRide;

  // --- BRAND COLORS ---
  final Color ugoGreen = AppColors.successAlt;
  final Color ugoBlack = AppColors.textPrimary;
  final Color ugoGrey = AppColors.grey;
  final Color lightBg = AppColors.background;
  static const Color ugoBlue = AppColors.info;

  @override
  void initState() {
    super.initState();
    fetchLastRide();
  }

  Future<void> fetchLastRide() async {
    final res = await DriverRideHistoryCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      final rides = DriverRideHistoryCall.completedRides(res.jsonBody);
      if (rides.isNotEmpty) {
        if (mounted) {
          setState(() {
            lastRide = rides.first as Map; // newest completed ride
            loading = false;
          });
        }
      } else {
        if (mounted) setState(() => loading = false);
      }
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format Date & Time safely (API uses createdAt, completedAt)
    String dateStr = 'Unknown Date';
    String timeStr = '';
    final dateVal = lastRide != null
        ? (lastRide!['completedAt'] ?? lastRide!['createdAt'] ?? lastRide!['date'])
        : null;
    if (dateVal != null) {
      try {
        DateTime dt = DateTime.parse(dateVal.toString());
        dateStr = DateFormat('d MMMM, yyyy').format(dt);
        timeStr = DateFormat('h:mm a').format(dt);
      } catch (e) {
        dateStr = dateVal.toString();
      }
    }

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bike Boost Order Details',
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            if (timeStr.isNotEmpty)
              Text(
                '$timeStr | $dateStr',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_outlined,
                    size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text('Help',
                    style: GoogleFonts.inter(
                        color: Colors.black, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : lastRide == null
          ? Center(
          child: Text('No orders found',
              style: GoogleFonts.inter(color: Colors.grey)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order ID & Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ID : #${lastRide!['rideId'] ?? lastRide!['id'] ?? '---'}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: ugoBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Completed',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: ugoGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Earnings Card
            _buildEarningsCard(),

            const SizedBox(height: 16),

            // 3. Route Info Card
            _buildRouteInfoCard(),

            const SizedBox(height: 16),

            // 4. Payment Info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment info',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: ugoBlack)),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  initiallyExpanded: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Earning',
                            style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 14)),
                        Text("₹${lastRide!['fare'] ?? lastRide!['amount'] ?? '0'}",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ugoBlack)),
                      ],
                    )
                  ],
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
    final fareRaw = lastRide!['fare'] ?? lastRide!['amount'] ?? 0;
    final distRaw = lastRide!['distanceKm'] ?? lastRide!['distance'] ?? 0.0;
    final dur = lastRide!['durationMinutes'] ?? lastRide!['duration'] ?? '--';
    final fareStr = fareRaw is num ? fareRaw.toStringAsFixed(2) : fareRaw.toString();
    final distStr = distRaw is num ? distRaw.toStringAsFixed(2) : distRaw.toString();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Earning',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹$fareStr',
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: ugoBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$distStr km · $dur min',
                    style: GoogleFonts.inter(
                        color: Colors.grey[800], fontSize: 13),
                  ),
                ],
              ),
              // "Promise Delivered" / "Fixed Commission" Badge
              _buildCommissionBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: ugoGreen),
              const SizedBox(width: 6),
              Text(
                '₹$fareStr Fare received',
                style: GoogleFonts.inter(
                    color: ugoGreen, fontWeight: FontWeight.w600, fontSize: 13),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommissionBadge() {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with border
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ugoBlue, width: 2.5),
              color: Colors.transparent,
            ),
          ),
          // Fixed Commission ribbon/badge
          Transform.rotate(
            angle: -0.1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ugoBlue,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: ugoBlue.withValues(alpha:0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Fixed Commission',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    String pickup = lastRide!['pickupAddress'] ?? lastRide!['pickup_address'] ?? lastRide!['from'] ?? 'Unknown Pickup';
    String drop = lastRide!['dropAddress'] ?? lastRide!['drop_address'] ?? lastRide!['to'] ?? 'Unknown Drop';
    final distRaw = lastRide!['distanceKm'] ?? lastRide!['distance'];
    final distStr = distRaw is num ? distRaw.toStringAsFixed(2) : '0.00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup and Drop info',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold, color: ugoBlack)),
          const SizedBox(height: 20),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.black),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.black87,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                    const Icon(Icons.location_on, size: 16, color: Colors.black87),
                  ],
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        pickup,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey[800], height: 1.4),
                      ),

                      const SizedBox(height: 20),

                      Text('Drop $distStr km',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        drop,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey[800], height: 1.4),
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