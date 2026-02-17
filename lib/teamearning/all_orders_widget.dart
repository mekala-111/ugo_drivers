import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  // --- State Variables ---
  bool loading = true;
  List<dynamic> allRides = [];
  List<dynamic> filteredRides = [];

  // Filters
  String timeFilter = 'Day'; // Day, Week, Month
  String statusFilter = 'Completed'; // Completed, Cancelled, Missed
  DateTime selectedDate = DateTime.now();

  // Stats
  int totalCount = 0;
  double totalEarnings = 0.0;

  // --- BRAND COLORS (Extracted from Screenshots) ---
  final Color ugoYellow = const Color(0xFFFFC107); // Active Tab
  final Color ugoGreen = const Color(0xFF004D40);  // Active Date (Dark Green)
  final Color ugoTextGreen = const Color(0xFF00897B); // Earnings Text
  final Color lightGreyBg = const Color(0xFFF5F5F5);
  final Color activeTabBg = const Color(0xFFFFF176); // Light Yellow for 'Completed' tab

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    fetchOrders();
  }

  // --- API Logic ---
  Future<void> fetchOrders() async {
    setState(() => loading = true);

    // Replace with your actual API Call
    final res = await DriverRideHistoryCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      final data = DriverRideHistoryCall.rides(res.jsonBody);
      setState(() {
        allRides = data.toList();
        _applyFilters();
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  // --- Filter Logic ---
  void _applyFilters() {
    // 1. Filter by Status
    // Note: Assuming your API returns a 'status' field. If not, map logic here.
    var temp = allRides.where((r) {
      // Mocking status logic for demo if API doesn't provide it
      // String rStatus = r['status'] ?? 'Completed';
      // return rStatus == statusFilter;
      return true; // Allowing all for now so you can see data
    }).toList();

    // 2. Calculate Stats based on current view
    double earnings = 0;
    for (var r in temp) {
      earnings += double.tryParse(r['amount']?.toString() ?? '0') ?? 0;
    }

    setState(() {
      filteredRides = temp;
      totalCount = temp.length;
      totalEarnings = earnings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "All Orders",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_outlined, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  "Help",
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 1. Day / Week / Month Switcher
          _buildTimeFilterTabs(),

          const SizedBox(height: 20),

          // 2. Date Picker Strip
          _buildDatePickerStrip(),

          const SizedBox(height: 20),

          // 3. Stats Dashboard
          _buildStatsCard(),

          const SizedBox(height: 24),

          // 4. Order History Header & Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Order History",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusFilterTabs(),

          const SizedBox(height: 16),

          // 5. Date Header (e.g. "30 November, 2025")
          if (filteredRides.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('dd MMMM, yyyy').format(selectedDate),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1) // Dark Blue from screenshot
                  ),
                ),
              ),
            ),

          // 6. List View
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredRides.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredRides.length,
              itemBuilder: (context, i) {
                // Pass status filter to decide card style
                return _buildOrderCard(filteredRides[i], statusFilter);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Time Filter Tabs ---
  Widget _buildTimeFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lightGreyBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['Day', 'Week', 'Month'].map((filter) {
          bool isActive = timeFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => timeFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? ugoYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 2. Date Picker Strip ---
  Widget _buildDatePickerStrip() {
    // Generate dates based on TimeFilter (Logic simplified for demo)
    List<DateTime> dates = List.generate(5, (index) => DateTime.now().subtract(Duration(days: 2 - index)));

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {},
          ),
          ...dates.map((date) {
            bool isSelected = date.day == selectedDate.day;
            return GestureDetector(
              onTap: () => setState(() => selectedDate = date),
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? ugoGreen : lightGreyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- 3. Stats Card ---
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "$totalCount",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusFilter == "Cancelled" ? "Cancelled Orders" : "Completed Orders",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            VerticalDivider(thickness: 1, color: Colors.grey.shade300, width: 1),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "₹${totalEarnings.toStringAsFixed(0)}",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ugoTextGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusFilter == "Cancelled" ? "Cancellation Fare" : "Order Earnings",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Status Filter Tabs ---
  Widget _buildStatusFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Completed', 'Cancelled', 'Missed'].map((status) {
          bool isActive = statusFilter == status;
          // Determine background color based on active state
          Color bgColor = lightGreyBg;
          if (isActive) {
            bgColor = activeTabBg; // Yellowish for active
          }

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  statusFilter = status;
                  _applyFilters();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 5. Order Card (Dynamic based on Status) ---
  Widget _buildOrderCard(dynamic r, String status) {
    bool isCancelled = status == "Cancelled";

    // Extract Data
    String type = "Bike Boost"; // Default or r['type']
    String time = DateFormat('h:mm a').format(DateTime.tryParse(r['date'] ?? '') ?? DateTime.now());
    String amount = "₹${r['amount']}";
    String from = r['from'] ?? "Unknown Pickup";
    String to = r['to'] ?? "Unknown Drop";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Bike Boost • Time ... Price
          Row(
            children: [
              Text(type, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 6),
              const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.orange), // Sun icon
              const SizedBox(width: 4),
              Text(time, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCancelled ? ugoTextGreen : ugoTextGreen, // Both green in screenshot
                ),
              ),
              if (!isCancelled) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF00C853)),
              ]
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Content based on Status
          if (isCancelled)
            _buildCancelledContent(from)
          else
            _buildCompletedContent(from, to),
        ],
      ),
    );
  }

  // Content for COMPLETED Ride
  Widget _buildCompletedContent(String from, String to) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.green), // Green Dot
                Container(width: 1, height: 25, color: Colors.grey[300]), // Dotted Line
                const Icon(Icons.circle, size: 10, color: Colors.red),   // Red Dot
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800])),
                  const SizedBox(height: 14),
                  Text(to, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800])),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  // Content for CANCELLED Ride
  Widget _buildCancelledContent(String from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Accepted Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: Colors.blue), // Blue Check
                Container(width: 1, height: 20, color: Colors.grey[300]), // Dotted Line
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Accepted", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800])),
                ],
              ),
            ),
          ],
        ),
        // 2. Cancelled Row
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.cancel_outlined, size: 14, color: Colors.red), // Red Cross
            const SizedBox(width: 10),
            Text("Cancelled by Captain", style: GoogleFonts.inter(fontSize: 13, color: Colors.red)),
          ],
        ),
      ],
    );
  }

  // --- 6. Empty State ---
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder Illustration (Use your asset or icon)
        Container(
          height: 150,
          width: 150,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded, size: 60, color: Colors.blueGrey),
        ),
        Text(
          "You have not completed any orders",
          style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}