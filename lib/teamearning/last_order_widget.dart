import '/backend/api_requests/api_calls.dart';
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
  final Color ugoGreen = const Color(0xFF00C853);
  final Color ugoBlack = const Color(0xFF1D2025);
  final Color ugoGrey = const Color(0xFF757575);
  final Color lightBg = const Color(0xFFF5F5F5);

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
      final rides = DriverRideHistoryCall.rides(res.jsonBody);
      if (rides.isNotEmpty) {
        if (mounted) {
          setState(() {
            lastRide = rides.first; // newest ride
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
    // Format Date & Time safely
    String dateStr = "Unknown Date";
    String timeStr = "";
    if (lastRide != null && lastRide!['date'] != null) {
      try {
        DateTime dt = DateTime.parse(lastRide!['date'].toString());
        dateStr = DateFormat('d MMMM, yyyy').format(dt);
        timeStr = DateFormat('h:mm a').format(dt);
      } catch (e) {
        dateStr = lastRide!['date'].toString();
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
              "Bike Boost Order Details",
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            if (timeStr.isNotEmpty)
              Text(
                "$timeStr | $dateStr",
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
                Text("Help",
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
          child: Text("No orders found",
              style: GoogleFonts.inter(color: Colors.grey)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order ID & Status
            Text(
              "Order ID : #${lastRide!['id'] ?? '---'}",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Completed",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ugoGreen,
                  fontWeight: FontWeight.bold),
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
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text("Payment info",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Earning",
                              style: GoogleFonts.inter(
                                  color: Colors.grey[700])),
                          Text("₹${lastRide!['amount'] ?? '0'}",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. My Plan Banner
            _buildPlanBanner(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Earning",
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹${lastRide!['amount'] ?? '0'}",
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: ugoBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Fallback mock data if API fields are missing
                    "${lastRide!['distance'] ?? '0.0'} km · ${lastRide!['duration'] ?? '--'} min",
                    style: GoogleFonts.inter(
                        color: Colors.grey[800], fontSize: 13),
                  ),
                ],
              ),
              // "Fixed Commission" Badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade700, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "Fixed\nComm.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Fare received confirmation
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: ugoGreen),
              const SizedBox(width: 6),
              Text(
                "₹${lastRide!['amount'] ?? '0'} Fare received",
                style: GoogleFonts.inter(
                    color: ugoGreen, fontWeight: FontWeight.w600, fontSize: 13),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    // Try to get pickup/drop addresses from known API fields
    String pickup = lastRide!['pickup_address'] ?? lastRide!['from'] ?? "Unknown Pickup";
    String drop = lastRide!['drop_address'] ?? lastRide!['to'] ?? "Unknown Drop";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pickup and Drop info",
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold, color: ugoBlack)),
          const SizedBox(height: 20),

          // Timeline Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline Line
                Column(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.black),
                    Expanded(
                      child: Container(
                        width: 1,
                        color: Colors.black,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                    const Icon(Icons.arrow_downward,
                        size: 12, color: Colors.black),
                  ],
                ),
                const SizedBox(width: 12),

                // Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup
                      Text("Pickup",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        pickup,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey[800], height: 1.4),
                      ),

                      const SizedBox(height: 24), // Space between nodes

                      // Drop
                      Text("Drop",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
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

  Widget _buildPlanBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Plan",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text("16% Commission",
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text("View All Plans",
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 10)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        size: 10, color: Colors.white)
                  ],
                ),
              )
            ],
          ),
          // "MY PLAN" Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0044FF), // Deep Blue
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                Text("MY\nPLAN",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}