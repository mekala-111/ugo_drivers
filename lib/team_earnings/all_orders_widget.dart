import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart'; // Required for FFAppState
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  // --- State Variables ---
  bool loading = true;
  List<dynamic> allRides = [];      // Raw data from API
  List<dynamic> filteredRides = []; // Data displayed in list

  // Filters
  String timeFilter = 'Day'; // 'Day', 'Week', 'Month'
  String statusFilter = 'Completed'; // 'Completed', 'Cancelled', 'Missed'
  DateTime selectedDate = DateTime.now();

  // Dashboard Stats
  int totalCount = 0;
  double totalEarnings = 0.0;

  // --- BRAND COLORS ---
  final Color ugoYellow = AppColors.teamEarningsYellow;
  final Color ugoGreen = AppColors.teamEarningsGreen;
  final Color ugoTextGreen = AppColors.teamEarningsTextGreen;
  final Color lightGreyBg = AppColors.background;
  final Color activeTabBg = AppColors.activeTabBg;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // ---------------------------------------------------
  // 1️⃣ API INTEGRATION
  // ---------------------------------------------------
  Future<void> fetchOrders() async {
    setState(() => loading = true);

    // Calling your specific Backend Function
    final res = await DriverRideHistoryCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      // Parse using your provided helper
      final data = DriverRideHistoryCall.rides(res.jsonBody);

      if (mounted) {
        setState(() {
          allRides = data.toList();
          _applyFilters(); // Filter data immediately
          loading = false;
        });
      }
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------------------------------------------------
  // 2️⃣ FILTER LOGIC
  // ---------------------------------------------------
  void _applyFilters() {
    var temp = allRides.where((r) {
      // A. Status Check (API: status = completed, cancelled, missed)
      String rStatus = (r['status'] ?? 'completed').toString().toLowerCase();

      bool statusMatch = false;
      if (statusFilter == 'Completed') {
        statusMatch = rStatus == 'completed';
      } else if (statusFilter == 'Cancelled') {
        statusMatch = rStatus == 'cancelled' || rStatus.contains('cancel');
      } else {
        statusMatch = rStatus == 'missed';
      }

      // B. Date Check (API: createdAt, completedAt)
      String dateStr = r['completedAt'] ?? r['createdAt'] ?? r['created_at'] ?? r['date'] ?? DateTime.now().toString();
      DateTime rDate = DateTime.tryParse(dateStr.toString()) ?? DateTime.now();

      bool dateMatch = false;
      if (timeFilter == 'Day') {
        // Match exact day
        dateMatch = isSameDay(rDate, selectedDate);
      } else if (timeFilter == 'Week') {
        // Match week range (simplified: within 7 days of selected)
        // In a real app, you'd calculate week start/end
        dateMatch = rDate.isAfter(selectedDate.subtract(const Duration(days: 7))) &&
            rDate.isBefore(selectedDate.add(const Duration(days: 1)));
      } else {
        // Match Month
        dateMatch = rDate.month == selectedDate.month && rDate.year == selectedDate.year;
      }

      return statusMatch && dateMatch;
    }).toList();

    // C. Calculate Stats from Filtered Data (API: fare)
    double earnings = 0;
    for (var r in temp) {
      final val = r['fare'] ?? r['amount'];
      earnings += (val is num) ? val.toDouble() : (double.tryParse(val?.toString() ?? '0') ?? 0);
    }

    setState(() {
      filteredRides = temp;
      totalCount = temp.length;
      totalEarnings = earnings;
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Orders',
          style: GoogleFonts.inter(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20
          ),
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
                const Icon(Icons.headset_mic_outlined, size: 18, color: Colors.black),
                const SizedBox(width: 6),
                Text('Help', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
          )
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 1. Tabs
          _buildTimeFilterTabs(),
          const SizedBox(height: 20),

          // 2. Date Picker
          _buildDatePickerStrip(),
          const SizedBox(height: 20),

          // 3. Stats
          _buildStatsCard(),
          const SizedBox(height: 24),

          // 4. Filters & Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Order History',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusFilterTabs(),
          const SizedBox(height: 16),

          // 5. Date Header
          if (filteredRides.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('dd MMMM, yyyy').format(selectedDate),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.infoDark),
                ),
              ),
            ),

          // 6. Orders List
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.teamEarningsYellow))
                : filteredRides.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredRides.length,
              itemBuilder: (context, i) {
                return _buildOrderCard(filteredRides[i], statusFilter);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // WIDGET HELPERS
  // ---------------------------------------------------

  Widget _buildTimeFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: lightGreyBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: ['Day', 'Week', 'Month'].map((filter) {
          bool isActive = timeFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() { timeFilter = filter; _applyFilters(); }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? ugoYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(filter, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePickerStrip() {
    // Logic to show different UI for Day vs Month could go here
    // For now, standard Day picker similar to screenshots
    List<DateTime> dates = List.generate(5, (index) => DateTime.now().subtract(Duration(days: 2 - index)));

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blue), onPressed: () {}),
          ...dates.map((date) {
            bool isSelected = isSameDay(date, selectedDate);
            return GestureDetector(
              onTap: () => setState(() { selectedDate = date; _applyFilters(); }),
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
                    Text(DateFormat('EEE').format(date),
                        style: GoogleFonts.inter(fontSize: 12, color: isSelected ? Colors.white : Colors.grey[600])),
                    Text(DateFormat('d').format(date),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                  ],
                ),
              ),
            );
          }),
          IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.blue), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    bool isCancelled = statusFilter == 'Cancelled';
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
                  Text('$totalCount', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(isCancelled ? 'Cancelled Orders' : 'Completed Orders',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
              child: Column(
                children: [
                  Text('₹${totalEarnings.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: ugoTextGreen)),
                  const SizedBox(height: 4),
                  Text(isCancelled ? 'Cancellation Fare' : 'Order Earnings',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Completed', 'Cancelled', 'Missed'].map((status) {
          bool isActive = statusFilter == status;
          Color bgColor = lightGreyBg;
          if (isActive) bgColor = activeTabBg; // Light Yellow for active

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() { statusFilter = status; _applyFilters(); }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(dynamic r, String status) {
    bool isCancelled = status == 'Cancelled';

    // Extract Data (API: rideType, fare, pickupAddress, dropAddress, completedAt/createdAt)
    String type = (r['rideType'] ?? r['vehicle_type'] ?? 'bike').toString().toUpperCase();
    String time = 'N/A';
    final dateVal = r['completedAt'] ?? r['createdAt'] ?? r['created_at'] ?? r['date'];
    if (dateVal != null) {
      try {
        time = DateFormat('h:mm a').format(DateTime.parse(dateVal.toString()));
      } catch (e) { time = '00:00'; }
    }
    String amount = "₹${r['fare'] ?? r['amount'] ?? '0'}";
    String from = r['pickupAddress'] ?? r['pickup_address'] ?? r['from'] ?? 'Unknown Pickup';
    String to = r['dropAddress'] ?? r['drop_address'] ?? r['to'] ?? 'Unknown Drop';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
              const SizedBox(width: 6),
              const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Text(time, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: ugoTextGreen)),
              if (!isCancelled) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 16, color: AppColors.successAlt),
              ]
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),

          if (isCancelled)
            _buildCancelledContent(from)
          else
            _buildCompletedContent(from, to),
        ],
      ),
    );
  }

  Widget _buildCompletedContent(String from, String to) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.successAlt),
            Container(width: 1, height: 25, color: Colors.grey[300]),
            const Icon(Icons.circle, size: 10, color: Colors.red),
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
    );
  }

  Widget _buildCancelledContent(String from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: Colors.blue),
                Container(width: 1, height: 16, color: Colors.grey[300]), // Short Line
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accepted', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                  Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800])),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
            const SizedBox(width: 10),
            Text('Cancelled by Captain', style: GoogleFonts.inter(fontSize: 13, color: Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120, width: 120,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text('You have not completed any orders',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}