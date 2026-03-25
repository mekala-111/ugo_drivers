import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart'; // Required for FFAppState
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  static const String routeName = 'AllOrders';
  static const String routePath = '/allOrders';

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  // --- State Variables ---
  bool loading = true;
  List<dynamic> allRides = []; // Raw data from API
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
      String dateStr = r['completedAt'] ??
          r['createdAt'] ??
          r['created_at'] ??
          r['date'] ??
          DateTime.now().toString();
      DateTime rDate = DateTime.tryParse(dateStr.toString()) ?? DateTime.now();

      bool dateMatch = false;
      if (timeFilter == 'Day') {
        dateMatch = isSameDay(rDate, selectedDate);
      } else if (timeFilter == 'Week') {
        // selectedDate is the Monday/start of the week
        DateTime weekEnd =
            selectedDate.add(const Duration(days: 6, hours: 23, minutes: 59));
        dateMatch =
            rDate.isAfter(selectedDate.subtract(const Duration(minutes: 1))) &&
                rDate.isBefore(weekEnd);
      } else {
        dateMatch = rDate.month == selectedDate.month &&
            rDate.year == selectedDate.year;
      }

      return statusMatch && dateMatch;
    }).toList();

    // C. Calculate Stats from Filtered Data (API: fare)
    double earnings = 0;
    for (var r in temp) {
      final val = r['fare'] ?? r['amount'];
      earnings += (val is num)
          ? val.toDouble()
          : (double.tryParse(val?.toString() ?? '0') ?? 0);
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
                    size: 18, color: Colors.black),
                const SizedBox(width: 6),
                Text('Help',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.black)),
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
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusFilterTabs(),
          const SizedBox(height: 16),

          // 5. Date Header
          if (filteredRides.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('dd MMMM, yyyy').format(selectedDate),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.infoDark),
                ),
              ),
            ),

          // 6. Orders List
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.teamEarningsYellow))
                : filteredRides.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredRides.length,
                        itemBuilder: (context, i) {
                          return _buildOrderCard(
                              filteredRides[i], statusFilter);
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
      decoration: BoxDecoration(
          color: lightGreyBg, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: ['Day', 'Week', 'Month'].map((filter) {
          bool isActive = timeFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  timeFilter = filter;
                  // Reset selectedDate based on selection so UI doesn't crash
                  if (filter == 'Week') {
                    DateTime now = DateTime.now();
                    selectedDate =
                        now.subtract(Duration(days: now.weekday - 1));
                  } else if (filter == 'Month') {
                    selectedDate =
                        DateTime(DateTime.now().year, DateTime.now().month, 1);
                  } else {
                    selectedDate = DateTime.now();
                  }
                  _applyFilters();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ]
                        : []),
                child: Text(filter,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black : Colors.grey[600])),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePickerStrip() {
    ScrollController _scrollController = ScrollController();

    // Auto-scroll to end (most recent)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    List<Widget> items = [];

    if (timeFilter == 'Day') {
      // Past 14 days
      for (int i = 13; i >= 0; i--) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        bool isSelected = isSameDay(date, selectedDate);
        items.add(_buildDateItem(
            DateFormat('EEE').format(date),
            DateFormat('d').format(date),
            isSelected,
            () => setState(() {
                  selectedDate = date;
                  _applyFilters();
                })));
      }
    } else if (timeFilter == 'Week') {
      // Past 6 weeks
      for (int i = 5; i >= 0; i--) {
        // Start week on Monday
        DateTime now = DateTime.now();
        int daysSinceMonday = now.weekday - 1;
        DateTime thisMonday = now.subtract(Duration(days: daysSinceMonday));
        DateTime weekStart = thisMonday.subtract(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));

        // Initial selectedDate check for week mode
        bool isSelected = isSameDay(selectedDate, weekStart);
        String label =
            "${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}";
        items.add(_buildDateItem(
            '',
            label,
            isSelected,
            () => setState(() {
                  selectedDate = weekStart;
                  _applyFilters();
                })));
      }
    } else {
      // Past 6 Months
      for (int i = 5; i >= 0; i--) {
        DateTime monthDate =
            DateTime(DateTime.now().year, DateTime.now().month - i, 1);
        bool isSelected = selectedDate.year == monthDate.year &&
            selectedDate.month == monthDate.month;
        items.add(_buildDateItem(
            '',
            DateFormat('MMM yyyy').format(monthDate),
            isSelected,
            () => setState(() {
                  selectedDate = monthDate;
                  _applyFilters();
                })));
      }
    }

    return SizedBox(
      height: 60,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: items,
      ),
    );
  }

  Widget _buildDateItem(
      String topText, String bottomText, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: isSelected ? ugoYellow : lightGreyBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (topText.isNotEmpty)
              Text(topText,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected ? Colors.black : Colors.grey[600])),
            Text(bottomText,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
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
                  Text('$totalCount',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(isCancelled ? 'Cancelled Orders' : 'Completed Orders',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
              child: Column(
                children: [
                  Text('₹${totalEarnings.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ugoYellow)),
                  const SizedBox(height: 4),
                  Text(isCancelled ? 'Cancellation Fare' : 'Order Earnings',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey[600])),
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
              onTap: () => setState(() {
                statusFilter = status;
                _applyFilters();
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(dynamic r, String status) {
    bool isCancelled = status == 'Cancelled';

    // Extract Data (API: orderType, fare, pickupAddress, dropAddress, completedAt/createdAt)
    String type =
        (r['orderType'] ?? r['rideType'] ?? r['vehicle_type'] ?? 'Bike')
            .toString()
            .toUpperCase();
    String time = '00:00';
    String dateLabel = '';
    final dateVal =
        r['completedAt'] ?? r['createdAt'] ?? r['created_at'] ?? r['date'];
    if (dateVal != null) {
      try {
        DateTime parsed = DateTime.parse(dateVal.toString());
        time = DateFormat('h:mm a').format(parsed);
        dateLabel = DateFormat('d MMM yyyy').format(parsed);
      } catch (e) {
        time = '00:00';
      }
    }
    String amount = "₹${r['fare'] ?? r['amount'] ?? '0'}";
    String from = r['pickupAddress'] ??
        r['pickup_address'] ??
        r['from'] ??
        'Unknown Pickup';
    String to =
        r['dropAddress'] ?? r['drop_address'] ?? r['to'] ?? 'Unknown Drop';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey[800])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(type,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black)),
                      const SizedBox(width: 8),
                      Text("•", style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(width: 8),
                      Text(time,
                          style: GoogleFonts.inter(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                  if (status == 'Completed') ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successAlt.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Completed',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successAlt)),
                    )
                  ]
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
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
            const Icon(Icons.circle, size: 10, color: Color(0xFF4CAF50)),
            Container(width: 1, height: 28, color: Colors.grey[300]),
            const Icon(Icons.square, size: 10, color: Color(0xFFF44336)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
              const SizedBox(height: 20),
              Text(to,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
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
                const Icon(Icons.check_circle_outline,
                    size: 14, color: Colors.blue),
                Container(width: 1, height: 20, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accepted',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey[600])),
                  Text(from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
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
            Text('Cancelled by Captain',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.red)),
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
            height: 120,
            width: 120,
            decoration:
                BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text('You have not completed any orders',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
