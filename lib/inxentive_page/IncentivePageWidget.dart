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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _IncentiveMilestoneCard(
          item: items[index],
          isNextAchievable: _isNextAchievable(index),
        );
      },
    );
  }

  bool _isNextAchievable(int index) {
    // Logic: If previous is completed and current is not, this is the "Next" one.
    if (index == 0) {
      return !DriverIncentivesCall.itemIsCompleted(items[0]);
    }
    return DriverIncentivesCall.itemIsCompleted(items[index - 1]) &&
        !DriverIncentivesCall.itemIsCompleted(items[index]);
  }
}

class _IncentiveMilestoneCard extends StatelessWidget {
  final dynamic item;
  final bool isNextAchievable;

  const _IncentiveMilestoneCard({
    required this.item,
    this.isNextAchievable = false,
  });

  @override
  Widget build(BuildContext context) {
    final int targetRides = DriverIncentivesCall.itemTargetRides(item);
    final int completedRides = DriverIncentivesCall.itemCompletedRides(item);
    final double rewardAmount = DriverIncentivesCall.itemRewardAmount(item);
    final bool isCompleted = DriverIncentivesCall.itemIsCompleted(item);
    final String incentiveName = DriverIncentivesCall.itemIncentiveName(item);
    final String startTime = DriverIncentivesCall.itemStartTime(item);
    final String endTime = DriverIncentivesCall.itemEndTime(item);

    final isSmall = ScreenHelper.isSmallScreen(context);
    final double progress =
        targetRides > 0 ? (completedRides / targetRides).clamp(0.0, 1.0) : 0.0;

    final Color primaryColor = isCompleted ? AppColors.success : AppColors.primary;
    final Color cardBg = isCompleted
        ? AppColors.sectionGreenTint
        : (isNextAchievable ? AppColors.sectionOrangeTint : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : (isNextAchievable
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.greyBorder),
          width: isNextAchievable || isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            if (isNextAchievable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.primary,
                child: Text(
                  'NEXT MILESTONE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(isSmall ? 16 : 20),
              child: Row(
                children: [
                  // 🏁 Circular Progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: isSmall ? 54 : 64,
                        height: isSmall ? 54 : 64,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: AppColors.greyBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 28)
                      else
                        Text(
                          '$completedRides/$targetRides',
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 11 : 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // 📝 Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                incentiveName,
                                style: GoogleFonts.inter(
                                  fontSize: isSmall ? 15 : 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '₹${rewardAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: isSmall ? 18 : 20,
                                fontWeight: FontWeight.w900,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target: $targetRides Rides',
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 13 : 14,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (startTime.isNotEmpty && endTime.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 12, color: AppColors.greyLight),
                              const SizedBox(width: 4),
                              Text(
                                '$startTime – $endTime',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.greyLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 📊 Linear Progress Bar at bottom of card
            Container(
              height: 4,
              width: double.infinity,
              color: AppColors.greyBorder,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: primaryColor),
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
      color: AppColors.accentAmber,
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
          ),
          if (onCalendarTap != null)
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
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
                                color: AppColors.registrationOrange, width: 2),
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
