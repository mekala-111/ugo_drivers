import 'package:flutter/foundation.dart' show kDebugMode;

import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Screen Size Helper ───────────────────────────────────────
class ScreenHelper {
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  
  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1000;
  
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;
  
  static double responsivePadding(BuildContext context) =>
      isSmallScreen(context) ? 12 : 16;
  
  static double responsiveFontSize(BuildContext context, double baseSize) =>
      isSmallScreen(context) ? baseSize * 0.9 : baseSize;
}

// ==============================================================================
// MODEL
// ==============================================================================
class DateRangeModel {
  final DateTime start;
  final DateTime end;
  DateRangeModel({required this.start, required this.end});
}

// ==============================================================================
// INCENTIVE PAGE
// ==============================================================================
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

  // ─── Daily ────────────────────────────────────────────────
  List<DateTime> _dailyDates = [];
  int _selectedDailyIndex = 0;
  bool _dailyLoading = false;
  List<dynamic> _dailyList = [];

  // ─── Weekly ───────────────────────────────────────────────
  List<DateRangeModel> _weeklyRanges = [];
  int _selectedWeeklyIndex = 0;
  bool _weeklyLoading = false;
  List<dynamic> _weeklyList = [];

  // ─── Monthly ──────────────────────────────────────────────
  bool _monthlyLoading = false;
  List<dynamic> _monthlyList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _generateDailyDates();
    _generateWeeklyRanges();
    _fetchDailyData(); // load first tab immediately
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0: _fetchDailyData();   break;
      case 1: _fetchWeeklyData();  break;
      case 2: _fetchMonthlyData(); break;
    }
  }

  // ── Date Generators ──────────────────────────────────────

  void _generateDailyDates() {
    final now = DateTime.now();
    setState(() {
      _dailyDates =
          List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));
      _selectedDailyIndex = 3; // today is index 3
    });
  }

  void _generateWeeklyRanges() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    setState(() {
      _weeklyRanges = List.generate(5, (i) {
        final start = monday.add(Duration(days: (i - 2) * 7));
        return DateRangeModel(
            start: start, end: start.add(const Duration(days: 6)));
      });
      _selectedWeeklyIndex = 2; // current week
    });
  }

  // ── Unified fetch using DriverIncentivesCall ─────────────

  /// Daily  →  ?date=2026-02-11
  Future<void> _fetchDailyData() async {
    if (_dailyDates.isEmpty) return;
    setState(() => _dailyLoading = true);
    try {
      final date = DateFormat('yyyy-MM-dd')
          .format(_dailyDates[_selectedDailyIndex]);
      debugPrint('🗓 Fetching daily: date=$date');

      final res = await DriverIncentivesCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
        date: date,
      );

      debugPrint('📥 Daily response: ${res.statusCode} | ${res.jsonBody}');
      setState(() {
        _dailyList = res.succeeded
            ? DriverIncentivesCall.incentiveList(res.jsonBody)
            : [];
        _dailyLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Daily error: $e');
      setState(() => _dailyLoading = false);
    }
  }

  /// Weekly  →  ?type=weekly  (current week auto-handled by backend)
  ///         OR ?from=...&to=...  for other weeks
  Future<void> _fetchWeeklyData() async {
    if (_weeklyRanges.isEmpty) return;
    setState(() => _weeklyLoading = true);
    try {
      final range = _weeklyRanges[_selectedWeeklyIndex];
      final isCurrentWeek = _selectedWeeklyIndex == 2;

      ApiCallResponse res;
      if (isCurrentWeek) {
        debugPrint('🗓 Fetching weekly: type=weekly');
        res = await DriverIncentivesCall.call(
          token: FFAppState().accessToken,
          driverId: FFAppState().driverid,
          type: 'weekly',
        );
      } else {
        final from = DateFormat('yyyy-MM-dd').format(range.start);
        final to = DateFormat('yyyy-MM-dd').format(range.end);
        debugPrint('🗓 Fetching weekly range: from=$from to=$to');
        res = await DriverIncentivesCall.call(
          token: FFAppState().accessToken,
          driverId: FFAppState().driverid,
          from: from,
          to: to,
        );
      }

      if (kDebugMode) debugPrint('📥 Weekly response: ${res.statusCode}');
      setState(() {
        _weeklyList = res.succeeded
            ? DriverIncentivesCall.incentiveList(res.jsonBody)
            : [];
        _weeklyLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Weekly error: $e');
      setState(() => _weeklyLoading = false);
    }
  }

  /// Monthly  →  ?type=monthly
  Future<void> _fetchMonthlyData() async {
    if (_monthlyList.isNotEmpty) return; // already loaded, skip
    setState(() => _monthlyLoading = true);
    try {
      debugPrint('🗓 Fetching monthly: type=monthly');
      final res = await DriverIncentivesCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
        type: 'monthly',
      );

      if (kDebugMode) debugPrint('📥 Monthly response: ${res.statusCode}');
      setState(() {
        _monthlyList = res.succeeded
            ? DriverIncentivesCall.incentiveList(res.jsonBody)
            : [];
        _monthlyLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Monthly error: $e');
      setState(() => _monthlyLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text('Incentives',
            style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppColors.accentAmber,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 12 : 14,
              ),
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Bonus'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Daily ──────────────────────────────────
          _DailyTab(
            dates: _dailyDates,
            selectedIndex: _selectedDailyIndex,
            isLoading: _dailyLoading,
            incentiveList: _dailyList,
            onDateSelected: (i) {
              setState(() => _selectedDailyIndex = i);
              _fetchDailyData();
            },
          ),
          // ── Tab 2: Weekly ─────────────────────────────────
          _WeeklyTab(
            dateRanges: _weeklyRanges,
            selectedIndex: _selectedWeeklyIndex,
            isLoading: _weeklyLoading,
            incentiveList: _weeklyList,
            onRangeSelected: (i) {
              setState(() => _selectedWeeklyIndex = i);
              _fetchWeeklyData();
            },
          ),
          // ── Tab 3: Monthly ────────────────────────────────
          _MonthlyTab(
            isLoading: _monthlyLoading,
            incentiveList: _monthlyList,
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 1 — DAILY
// ==============================================================================
class _DailyTab extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final bool isLoading;
  final List<dynamic> incentiveList;
  final Function(int) onDateSelected;

  const _DailyTab({
    required this.dates,
    required this.selectedIndex,
    required this.isLoading,
    required this.incentiveList,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    return Column(
      children: [
        _DateSelectorBar(
          dates: dates,
          selectedIndex: selectedIndex,
          onDateSelected: onDateSelected,
        ),
        Expanded(
          child: isLoading
              ? const _Loader()
              : RefreshIndicator(
                  color: AppColors.accentAmber,
                  onRefresh: () async => onDateSelected(selectedIndex),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(ScreenHelper.responsivePadding(context)),
                    child: Column(
                      children: [
                        // 📅 Date header with full date
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmall ? 12 : 16),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.accentAmber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEEE, MMM dd, yyyy').format(dates[selectedIndex]),
                                style: GoogleFonts.inter(
                                  fontSize: ScreenHelper.responsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '7:00 AM  –  11:59 PM',
                                style: GoogleFonts.inter(
                                  fontSize: ScreenHelper.responsiveFontSize(context, 12),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        incentiveList.isNotEmpty
                            ? _IncentiveList(items: incentiveList)
                            : const _EmptyState(
                                message: 'No incentives for this day'),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ==============================================================================
// TAB 2 — WEEKLY
// ==============================================================================
class _WeeklyTab extends StatelessWidget {
  final List<DateRangeModel> dateRanges;
  final int selectedIndex;
  final bool isLoading;
  final List<dynamic> incentiveList;
  final Function(int) onRangeSelected;

  const _WeeklyTab({
    required this.dateRanges,
    required this.selectedIndex,
    required this.isLoading,
    required this.incentiveList,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final range =
        dateRanges.isNotEmpty ? dateRanges[selectedIndex] : null;
    final label = range != null
        ? '${DateFormat('EEE, MMM d').format(range.start)}  –  ${DateFormat('EEE, MMM d').format(range.end)}'
        : '';
    final isSmall = ScreenHelper.isSmallScreen(context);

    return Column(
      children: [
        _WeekSelectorBar(
          dateRanges: dateRanges,
          selectedIndex: selectedIndex,
          onRangeSelected: onRangeSelected,
        ),
        Expanded(
          child: isLoading
              ? const _Loader()
              : RefreshIndicator(
                  color: AppColors.accentAmber,
                  onRefresh: () async => onRangeSelected(selectedIndex),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(ScreenHelper.responsivePadding(context)),
                    child: Column(
                      children: [
                        // 📅 Week header
                        if (label.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmall ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.accentAmber.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(label,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenHelper.responsiveFontSize(context, 15))),
                                const SizedBox(height: 4),
                                Text('7:00 AM  –  11:59 PM',
                                    style: GoogleFonts.inter(
                                        color: Colors.grey,
                                        fontSize: ScreenHelper.responsiveFontSize(context, 12))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        incentiveList.isNotEmpty
                            ? _IncentiveList(items: incentiveList)
                            : const _EmptyState(
                                message: 'No incentives for this week'),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ==============================================================================
// TAB 3 — MONTHLY
// ==============================================================================
class _MonthlyTab extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> incentiveList;

  const _MonthlyTab(
      {required this.isLoading, required this.incentiveList});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final padding = ScreenHelper.responsivePadding(context);
    
    return isLoading
        ? const _Loader()
        : SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // Month banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: ScreenHelper.responsiveFontSize(context, 13)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monthly Incentives',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: ScreenHelper.responsiveFontSize(context, 20),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                incentiveList.isNotEmpty
                    ? _IncentiveList(items: incentiveList)
                    : const _EmptyState(
                        message: 'No monthly incentives available'),
              ],
            ),
          );
  }
}

// ==============================================================================
// INCENTIVE LIST  — renders each item from $.data[]
// ==============================================================================
class _IncentiveList extends StatelessWidget {
  final List<dynamic> items;
  const _IncentiveList({required this.items});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final padding = isSmall ? 14 : 20;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(padding.toDouble()),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return _IncentiveCard(
            item: item,
            isLast: i == items.length - 1,
          );
        }),
      ),
    );
  }
}

class _IncentiveCard extends StatelessWidget {
  final dynamic item;
  final bool isLast;

  const _IncentiveCard({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final int targetRides =
        DriverIncentivesCall.itemTargetRides(item);
    final int completedRides =
        DriverIncentivesCall.itemCompletedRides(item);
    final double rewardAmount =
        DriverIncentivesCall.itemRewardAmount(item);
    final bool isCompleted =
        DriverIncentivesCall.itemIsCompleted(item);
    final String incentiveName =
        DriverIncentivesCall.itemIncentiveName(item);
    final String startTime =
        DriverIncentivesCall.itemStartTime(item);
    final String endTime =
        DriverIncentivesCall.itemEndTime(item);

    final isSmall = ScreenHelper.isSmallScreen(context);
    final cardPadding = isSmall ? 10 : 14;
    final dotSize = isSmall ? 18.0 : 22.0;

    const Color orange = AppColors.accentAmber;
    final Color grey = Colors.grey.shade300;
    final double progress = targetRides > 0
        ? (completedRides / targetRides).clamp(0.0, 1.0)
        : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline dot + connector ────────────────────
          Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? orange : Colors.white,
                  border: Border.all(
                      color: isCompleted ? orange : grey, width: 2.5),
                ),
                child: isCompleted
                    ? Icon(Icons.check,
                        size: isSmall ? 10 : 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        width: 2,
                        color: isCompleted ? orange : grey)),
            ],
          ),
          SizedBox(width: isSmall ? 10 : 14),

          // ── Card content ─────────────────────────────────
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isSmall ? 16 : 24),
              padding: EdgeInsets.all(cardPadding.toDouble()),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.05)
                    : Colors.orange.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : orange.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + reward row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(incentiveName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: ScreenHelper.responsiveFontSize(context, 15),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '₹${rewardAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontSize: ScreenHelper.responsiveFontSize(context, isSmall ? 14 : 18),
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green
                                : Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmall ? 4 : 6),

                  // Target rides
                  Text(
                    'Complete $targetRides rides',
                    style: GoogleFonts.inter(
                        fontSize: ScreenHelper.responsiveFontSize(context, 13),
                        color: Colors.black54),
                  ),

                  // Time window
                  if (startTime.isNotEmpty && endTime.isNotEmpty) ...[
                    SizedBox(height: isSmall ? 1 : 2),
                    Text(
                      '$startTime  –  $endTime',
                      style: GoogleFonts.inter(
                          fontSize: ScreenHelper.responsiveFontSize(context, 11),
                          color: Colors.grey.shade500),
                    ),
                  ],
                  SizedBox(height: isSmall ? 6 : 10),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: isSmall ? 5 : 7,
                      backgroundColor: Colors.grey.shade200,
                      color: isCompleted ? Colors.green : orange,
                    ),
                  ),
                  SizedBox(height: isSmall ? 4 : 6),

                  // Progress label + status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedRides / $targetRides rides',
                        style: GoogleFonts.inter(
                            fontSize: ScreenHelper.responsiveFontSize(context, 12),
                            color: Colors.grey.shade600),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmall ? 8 : 10,
                            vertical: isSmall ? 2 : 3),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withValues(alpha: 0.12)
                              : orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCompleted ? '✓ Completed' : '● Ongoing',
                          style: GoogleFonts.inter(
                              fontSize: ScreenHelper.responsiveFontSize(context, 11),
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green
                                  : orange),
                        ),
                      ),
                    ],
                  ),
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
// DATE SELECTOR BAR
// ==============================================================================
class _DateSelectorBar extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final Function(int) onDateSelected;

  const _DateSelectorBar(
      {required this.dates,
      required this.selectedIndex,
      required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final barHeight = isSmall ? 70.0 : 80.0;
    final selectedSize = isSmall ? 45.0 : 50.0;
    
    return Container(
      color: AppColors.accentAmber,
      height: barHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, i) {
          final date = dates[i];
          final selected = i == selectedIndex;
          final dayName = DateFormat('E').format(date);
          final dayNum = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () => onDateSelected(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selected
                      ? Container(
                          width: selectedSize,
                          height: selectedSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(selectedSize / 2),
                            border: Border.all(
                                color: AppColors.registrationOrange,
                                width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(dayName,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange)),
                              Text(dayNum,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Text(dayName,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 9 : 10,
                                    color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(dayNum,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 12 : 14,
                                    color: Colors.black87)),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==============================================================================
// WEEK SELECTOR BAR
// ==============================================================================
class _WeekSelectorBar extends StatelessWidget {
  final List<DateRangeModel> dateRanges;
  final int selectedIndex;
  final Function(int) onRangeSelected;

  const _WeekSelectorBar(
      {required this.dateRanges,
      required this.selectedIndex,
      required this.onRangeSelected});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final barHeight = isSmall ? 70.0 : 80.0;
    final selectedSize = isSmall ? 50.0 : 56.0;
    
    return Container(
      color: AppColors.accentAmber,
      height: barHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dateRanges.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, i) {
          final range = dateRanges[i];
          final selected = i == selectedIndex;
          final month = DateFormat('MMM').format(range.start);
          final days = '${range.start.day}-${range.end.day}';

          return GestureDetector(
            onTap: () => onRangeSelected(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selected
                      ? Container(
                          width: selectedSize,
                          height: selectedSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.registrationOrange,
                                width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(month,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange)),
                              Text(days,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 10 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Text(month,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 9 : 10,
                                    color: Colors.black87)),
                            Text(days,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 10 : 12,
                                    color: Colors.black87)),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==============================================================================
// SHARED SMALL WIDGETS
// ==============================================================================
class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.accentAmber));
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 30 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline,
                size: isSmall ? 48 : 56, color: Colors.grey.shade300),
            SizedBox(height: isSmall ? 10 : 12),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: ScreenHelper.responsiveFontSize(context, 14),
                    color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

