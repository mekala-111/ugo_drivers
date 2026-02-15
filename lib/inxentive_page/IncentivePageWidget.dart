import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class IncentivePageWidget extends StatefulWidget {
  const IncentivePageWidget({super.key});

  static String routeName = 'IncentivePage';
  static String routePath = '/incentivePage';

  @override
  State<IncentivePageWidget> createState() => _IncentivePageWidgetState();
}

class _IncentivePageWidgetState extends State<IncentivePageWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // API State Variables
  bool _isLoading = true;
  int _currentRides = 0;
  double _totalEarned = 0.0;
  List<dynamic> _incentiveTiers = [];

  // 📅 Weekly Date Selection
  List<DateRangeModel> _weeklyRanges = [];
  int _selectedWeeklyIndex = 0;

  // 📅 Daily Date Selection
  List<DateTime> _dailyDates = [];
  int _selectedDailyIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _generateWeeklyRanges(); // 1. Generate Weeks
    _generateDailyDates();   // 2. Generate Days (NEW)
    _fetchIncentiveData();   // 3. Load API Data
  }

  // 🔹 LOGIC: Generate Days (Today +/- 3 days)
  void _generateDailyDates() {
    DateTime now = DateTime.now();
    List<DateTime> days = [];
    // Generate 3 days back and 3 days forward (Total 7 days)
    for (int i = -3; i <= 3; i++) {
      days.add(now.add(Duration(days: i)));
    }
    setState(() {
      _dailyDates = days;
      _selectedDailyIndex = 3; // Today is at index 3
    });
  }

  // 🔹 LOGIC: Generate Weeks
  void _generateWeeklyRanges() {
    DateTime now = DateTime.now();
    DateTime currentMonday = now.subtract(Duration(days: now.weekday - 1));
    List<DateRangeModel> ranges = [];
    for (int i = -2; i <= 2; i++) {
      DateTime start = currentMonday.add(Duration(days: i * 7));
      DateTime end = start.add(const Duration(days: 6));
      ranges.add(DateRangeModel(start: start, end: end));
    }
    setState(() {
      _weeklyRanges = ranges;
      _selectedWeeklyIndex = 2; // Current Week
    });
  }

  // 🔹 LOGIC: Fetch Data from API
  Future<void> _fetchIncentiveData() async {
    setState(() => _isLoading = true);
    try {
      final response = await GetDriverIncentivesCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );
      if (response.succeeded) {
        setState(() {
          _currentRides = GetDriverIncentivesCall.currentRides(response.jsonBody) ?? 0;
          _totalEarned = GetDriverIncentivesCall.totalEarned(response.jsonBody) ?? 0.0;
          _incentiveTiers = GetDriverIncentivesCall.incentiveTiers(response.jsonBody) ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching incentives: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFFFFFFFF);
    const Color brandBlack = Color(0xFF1E293B);
    const Color bgGrey = Color(0xFFF5F7FA);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "Incentives",
          style: GoogleFonts.inter(
            color: brandBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: const Color(0xFFF3A739),
            child: TabBar(
              controller: _tabController,
              indicatorColor: brandPrimary,
              indicatorWeight: 4,
              labelColor: brandPrimary,
              unselectedLabelColor: Colors.black,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Weekly"),
                Tab(text: "Bonus"),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandPrimary))
          : TabBarView(
        controller: _tabController,
        children: [
          // 1. Daily View (Now with Dates!)
          DailyIncentivesView(
            dates: _dailyDates,
            selectedIndex: _selectedDailyIndex,
            onDateSelected: (index) => setState(() => _selectedDailyIndex = index),
            currentRides: _currentRides,
            incentives: _incentiveTiers,
          ),

          // 2. Weekly View
          WeeklyIncentivesView(
            dateRanges: _weeklyRanges,
            selectedIndex: _selectedWeeklyIndex,
            onDateSelected: (index) => setState(() => _selectedWeeklyIndex = index),
            totalEarned: _totalEarned,
          ),

          // 3. Bonus View
          BonusIncentivesView(
            currentRides: _currentRides,
            incentives: _incentiveTiers,
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 📅 1️⃣ DAILY INCENTIVES VIEW (Dynamic Dates)
// ==============================================================================
class DailyIncentivesView extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final Function(int) onDateSelected;
  final int currentRides;
  final List<dynamic> incentives;

  const DailyIncentivesView({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
    required this.currentRides,
    required this.incentives,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🗓️ DATE SELECTOR (Daily)
        Container(
          color: const Color(0xFFF3A739),
          height: 80,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final date = dates[index];
              final bool isSelected = index == selectedIndex;
              final String dayName = DateFormat('E').format(date); // Mon, Tue
              final String dayNum = DateFormat('d').format(date);  // 12, 13

              return GestureDetector(
                onTap: () => onDateSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        Container(
                          width: 50,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25), // Pill shape
                            border: Border.all(color: const Color(0xFFFF8900), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(dayName, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                              Text(dayNum, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                        )
                      else
                        Column(
                          spacing: 2,
                          children: [
                            Text(dayName, style: GoogleFonts.inter(fontSize: 10, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text(dayNum, style: GoogleFonts.inter(fontSize: 14, color: Colors.black)),
                          ],
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ⏰ TIME HEADER
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "7:00 AM to 11:59 PM",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 20),

                // 📝 REUSE BONUS VIEW LOGIC FOR DAILY LIST
                // This will show the Red/Green/Orange cards based on progress
                if (incentives.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: List.generate(incentives.length, (index) {
                        final item = incentives[index];
                        final int target = item['target_rides'] ?? 0;
                        final double reward = double.tryParse(item['reward_amount'].toString()) ?? 0.0;
                        final bool isCompleted = currentRides >= target;
                        final bool isLast = index == incentives.length - 1;

                        return _buildTimelineItem(
                          target: "Complete $target rides",
                          reward: "₹ $reward",
                          isCompleted: isCompleted,
                          isLast: isLast,
                        );
                      }),
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No incentives for this day"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Reuse the timeline item builder
  Widget _buildTimelineItem({required String target, required String reward, required bool isCompleted, required bool isLast}) {
    final Color activeColor = const Color(0xFFFFFFFF);
    final Color inactiveColor = Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? activeColor : Colors.white,
                  border: Border.all(color: isCompleted ? activeColor : inactiveColor, width: 3),
                ),
                child: isCompleted ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: isCompleted ? activeColor : inactiveColor)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(target, style: GoogleFonts.inter(fontSize: 16, fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500, color: isCompleted ? Colors.black87 : Colors.grey.shade600)),
                  Text(reward, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isCompleted ? activeColor : Colors.grey.shade400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 📅 2️⃣ WEEKLY INCENTIVES VIEW
// ==============================================================================
class WeeklyIncentivesView extends StatelessWidget {
  final List<DateRangeModel> dateRanges;
  final int selectedIndex;
  final Function(int) onDateSelected;
  final double totalEarned;

  const WeeklyIncentivesView({
    super.key,
    required this.dateRanges,
    required this.selectedIndex,
    required this.onDateSelected,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRange = dateRanges[selectedIndex];
    final String fullDateText = "${DateFormat('EEE, MMM dd').format(selectedRange.start)} - ${DateFormat('EEE, MMM dd').format(selectedRange.end)}";

    return Column(
      children: [
        Container(
          color: const Color(0xFFF3A739),
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dateRanges.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final range = dateRanges[index];
              final bool isSelected = index == selectedIndex;
              final String month = DateFormat('MMM').format(range.start);
              final String days = "${range.start.day}-${range.end.day}";

              return GestureDetector(
                onTap: () => onDateSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8900), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(month, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                              Text(days, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(month, style: GoogleFonts.inter(fontSize: 10, color: Colors.black)),
                            Text(days, style: GoogleFonts.inter(fontSize: 12, color: Colors.black)),
                          ],
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(fullDateText, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("7:00 AM to 11:59 PM", style: GoogleFonts.inter(color: Colors.grey)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, color: Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Incentives Earned", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
                            const SizedBox(height: 2),
                            Text("Processed", style: GoogleFonts.inter(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text("₹ $totalEarned", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==============================================================================
// 🏆 3️⃣ BONUS VIEW (Reuses Daily View Logic)
// ==============================================================================
class BonusIncentivesView extends StatelessWidget {
  final int currentRides;
  final List<dynamic> incentives;

  const BonusIncentivesView({
    super.key,
    required this.currentRides,
    required this.incentives,
  });

  @override
  Widget build(BuildContext context) {
    if (incentives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No Bonus Offers", style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9A4D), Color(0xFFFF7B10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text("Your Progress", style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text("$currentRides Rides Completed", style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reuse the daily list renderer but for bonus context
          DailyIncentivesView(
            dates: [], // Pass empty, we are not rendering date bar here
            selectedIndex: 0,
            onDateSelected: (_) {},
            currentRides: currentRides,
            incentives: incentives,
          ).buildListOnly(context), // Helper to just build the list
        ],
      ),
    );
  }
}

// Extension to reuse the list part
extension on DailyIncentivesView {
  Widget buildListOnly(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(incentives.length, (index) {
          final item = incentives[index];
          final int target = item['target_rides'] ?? 0;
          final double reward = double.tryParse(item['reward_amount'].toString()) ?? 0.0;
          final bool isCompleted = currentRides >= target;
          final bool isLast = index == incentives.length - 1;

          return _buildTimelineItem(
            target: "Complete $target rides",
            reward: "₹ $reward",
            isCompleted: isCompleted,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

// 🗓️ MODEL
class DateRangeModel {
  final DateTime start;
  final DateTime end;
  DateRangeModel({required this.start, required this.end});
}