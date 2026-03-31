import 'package:flutter/foundation.dart' show kDebugMode;

import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
// ignore_for_file: file_names
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Screen Size Helper ───────────────────────────────────────
class ScreenHelper {
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1000;

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

  Future<void> _openDailyCalendarPicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dailyDates.isNotEmpty ? _dailyDates[_selectedDailyIndex] : now,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _dailyDates =
            List.generate(7, (i) => picked.subtract(Duration(days: 3 - i)));
        _selectedDailyIndex = 3;
      });
      _fetchDailyData();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0:
        _fetchDailyData();
        break;
      case 1:
        _fetchWeeklyData();
        break;
      case 2:
        _fetchMonthlyData();
        break;
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
      final date =
          DateFormat('yyyy-MM-dd').format(_dailyDates[_selectedDailyIndex]);
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
        centerTitle: true,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        ),
        title: Text('Incentives',
            style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent, size: 18, color: AppColors.textPrimary),
              label: Text(
                'Help',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 13 : 14,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: isSmall ? 13 : 14,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
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
            onCalendarTap: _openDailyCalendarPicker,
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
  final VoidCallback? onCalendarTap;

  const _DailyTab({
    required this.dates,
    required this.selectedIndex,
    required this.isLoading,
    required this.incentiveList,
    required this.onDateSelected,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final totalEarned = incentiveList
        .where((i) => DriverIncentivesCall.itemIsCompleted(i))
        .fold(0.0, (sum, i) => sum + DriverIncentivesCall.itemRewardAmount(i));

    return Column(
      children: [
        _DateSelectorBar(
          dates: dates,
          selectedIndex: selectedIndex,
          onDateSelected: onDateSelected,
          onCalendarTap: onCalendarTap,
        ),
        Expanded(
          child: isLoading
              ? const _Loader()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => onDateSelected(selectedIndex),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isSmall ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 💰 Summary Header
                        _SummaryHeader(
                          title: 'Daily Earnings',
                          subtitle: DateFormat('EEEE, MMM dd, yyyy')
                              .format(dates[selectedIndex]),
                          amount: totalEarned,
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Available Incentives',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
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
    final range = dateRanges.isNotEmpty ? dateRanges[selectedIndex] : null;
    final label = range != null
        ? '${DateFormat('MMM d').format(range.start)} – ${DateFormat('MMM d').format(range.end)}'
        : '';
    final isSmall = ScreenHelper.isSmallScreen(context);
    final totalEarned = incentiveList
        .where((i) => DriverIncentivesCall.itemIsCompleted(i))
        .fold(0.0, (sum, i) => sum + DriverIncentivesCall.itemRewardAmount(i));

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
                  color: AppColors.primary,
                  onRefresh: () async => onRangeSelected(selectedIndex),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isSmall ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 💰 Summary Header
                        _SummaryHeader(
                          title: 'Weekly Earnings',
                          subtitle: label,
                          amount: totalEarned,
                          icon: Icons.date_range,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Weekly Challenges',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
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

  const _MonthlyTab({required this.isLoading, required this.incentiveList});

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final totalEarned = incentiveList
        .where((i) => DriverIncentivesCall.itemIsCompleted(i))
        .fold(0.0, (sum, i) => sum + DriverIncentivesCall.itemRewardAmount(i));

    return isLoading
        ? const _Loader()
        : SingleChildScrollView(
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💰 Summary Header
                _SummaryHeader(
                  title: 'Monthly Bonus',
                  subtitle: DateFormat('MMMM yyyy').format(DateTime.now()),
                  amount: totalEarned,
                  icon: Icons.stars,
                ),
                const SizedBox(height: 24),
                Text(
                  'Special Incentives',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
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
// ==============================================================================
// INCENTIVE LIST — renders each item from $.data[]
// ==============================================================================
class _IncentiveList extends StatelessWidget {
  final List<dynamic> items;
  const _IncentiveList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final groups = <String, List<dynamic>>{};
    for (final item in items) {
      final start = DriverIncentivesCall.itemStartTime(item);
      final end = DriverIncentivesCall.itemEndTime(item);
      final name = DriverIncentivesCall.itemIncentiveName(item);
      final key = '$name|$start|$end';
      groups.putIfAbsent(key, () => []).add(item);
    }

    final groupedList = groups.values.toList();
    return Column(
      children: List.generate(groupedList.length, (index) {
        final group = groupedList[index];
        final start = DriverIncentivesCall.itemStartTime(group.first);
        final end = DriverIncentivesCall.itemEndTime(group.first);
        final hasTime = start.isNotEmpty && end.isNotEmpty;
        return Padding(
          padding: EdgeInsets.only(bottom: index == groupedList.length - 1 ? 0 : 20),
          child: Column(
            children: [
              if (hasTime)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$start to $end',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                    ],
                  ),
                ),
              _RapidoIncentiveCard(items: group),
            ],
          ),
        );
      }),
    );
  }
}

class _RapidoIncentiveCard extends StatelessWidget {
  final List<dynamic> items;
  const _RapidoIncentiveCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final totalTargetRides = items
        .map((e) => DriverIncentivesCall.itemTargetRides(e))
        .fold<int>(0, (a, b) => b > a ? b : a);
    final totalReward = items
        .map((e) => DriverIncentivesCall.itemRewardAmount(e))
        .fold<double>(0, (a, b) => a + b);
    final vehicleTypes = items
        .expand((e) => ((getJsonField(e, r'$.incentive.vehicleTypes', true) as List?) ?? const []))
        .map((v) => getJsonField(v, r'$.vehicle_type')?.toString() ?? getJsonField(v, r'$.name')?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    final vehicleLabel = vehicleTypes.join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5C400),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      'Earn up to ₹${totalReward.toStringAsFixed(0)}',
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: const Color(0xFF232323),
                      ),
                    ),
                    Text(
                      'by completing $totalTargetRides Rides',
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF232323),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (vehicleLabel.isNotEmpty)
              Container(
                width: double.infinity,
                color: const Color(0xFF353535),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Text(
                  vehicleLabel,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFB36B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final targetRides = DriverIncentivesCall.itemTargetRides(item);
                  final completedRides = DriverIncentivesCall.itemCompletedRides(item);
                  final rewardAmount = DriverIncentivesCall.itemRewardAmount(item);
                  final isCompleted = DriverIncentivesCall.itemIsCompleted(item);
                  final ridesLeft = (targetRides - completedRides).clamp(0, targetRides);
                  final isLast = index == items.length - 1;
                  final activeDot = index == 0 ? AppColors.primary : Colors.grey.shade400;
                  final rowColor = isCompleted ? AppColors.success : const Color(0xFF2F2F2F);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: activeDot,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Container(
                              width: 2,
                              height: 52,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Complete $targetRides Rides${isCompleted ? ' and get' : ''}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: rowColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${rewardAmount.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: rowColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isCompleted)
                                Text(
                                  '$ridesLeft more rides left',
                                  style: GoogleFonts.inter(
                                    color: Colors.red.shade400,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 14),
                child: Text(
                  'Terms & Conditions',
                  style: GoogleFonts.inter(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
  final VoidCallback? onCalendarTap;

  const _DateSelectorBar({
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    final barHeight = isSmall ? 70.0 : 80.0;
    final selectedSize = isSmall ? 45.0 : 50.0;

    return Container(
      color: const Color(0xFF4B4B4B),
      height: barHeight,
      child: Row(
        children: [
          Expanded(
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
                                  borderRadius:
                                      BorderRadius.circular(selectedSize / 2),
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
                                            color: AppColors.primary)),
                                    Text(dayNum,
                                        style: GoogleFonts.inter(
                                            fontSize: isSmall ? 14 : 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Text(DateFormat('MMM').format(date),
                                      style: GoogleFonts.inter(
                                          fontSize: isSmall ? 10 : 11,
                                          color: Colors.white70)),
                                  Text(dayName,
                                      style: GoogleFonts.inter(
                                          fontSize: isSmall ? 9 : 10,
                                          color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text(dayNum,
                                      style: GoogleFonts.inter(
                                          fontSize: isSmall ? 12 : 14,
                                          color: Colors.white)),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (onCalendarTap != null)
            IconButton(
              icon: const Icon(Icons.calendar_month, color: AppColors.primary),
              onPressed: onCalendarTap,
              tooltip: 'Pick date from calendar',
            ),
        ],
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
      color: const Color(0xFF4B4B4B),
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
                                color: AppColors.registrationOrange, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(month,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Text(days,
                                  style: GoogleFonts.inter(
                                      fontSize: isSmall ? 10 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              DateFormat('MMM').format(range.end),
                              style: GoogleFonts.inter(
                                  fontSize: isSmall ? 9 : 10,
                                  color: Colors.white70),
                            ),
                            Text(month,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 9 : 10,
                                    color: Colors.white70)),
                            Text(days,
                                style: GoogleFonts.inter(
                                    fontSize: isSmall ? 10 : 12,
                                    color: Colors.white)),
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
// HELPERS & UI COMPONENTS
// ==============================================================================

class _SummaryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;

  const _SummaryHeader({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenHelper.isSmallScreen(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: isSmall ? 14 : 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: isSmall ? 16 : 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: isSmall ? 32 : 40,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                child: Text(
                  'Earned',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.sectionGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }
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
