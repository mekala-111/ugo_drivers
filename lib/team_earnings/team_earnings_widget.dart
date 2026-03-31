import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ugo_driver/team_earnings/all_orders_widget.dart';
import 'package:ugo_driver/team_earnings/last_order_widget.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/team_earnings/view_rate_card_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'team_earnings_model.dart';
export 'team_earnings_model.dart';

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
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class TeamEarningsWidget extends StatefulWidget {
  const TeamEarningsWidget({super.key});

  static String routeName = 'teamEarnings';
  static String routePath = '/teamEarnings';

  @override
  State<TeamEarningsWidget> createState() => _TeamEarningsWidgetState();
}

class _TeamEarningsWidgetState extends State<TeamEarningsWidget>
    with SingleTickerProviderStateMixin {
  late TeamEarningsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Data Variables - All Earnings
  String todaysEarnings = '0';
  bool isLoading = true;

  // Data Variables - Team Earnings
  String teamEarnings = '0';
  String pendingToday = '0';
  String additionalIfMatchedAll = '0';
  String totalReferrals = '0';
  List<dynamic> referredDrivers = [];
  bool isLoadingTeam = true;

  // Weekly Chart Data
  List<double> dailyEarningsList = [0, 0, 0, 0, 0, 0, 0];
  bool isLoadingWeekly = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamEarningsModel());
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarningsData();
    _fetchWeeklyEarnings();
    _fetchTeamData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _fetchTeamData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 1. Fetch General Earnings (unchanged)
  Future<void> _fetchEarningsData() async {
    setState(() => isLoading = true);
    try {
      final response = await DriverEarningsCall.call(
        driverId: FFAppState().driverid,
        token: FFAppState().accessToken,
        period: 'all',
      );
      if (response.succeeded) {
        final data = response.jsonBody['data'];
        setState(() {
          todaysEarnings = "₹${(data['totalEarnings'] ?? 0).toString()}";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching total earnings: $e');
      setState(() => isLoading = false);
    }
  }

  // 2. Fetch Team/Referral Data
  // ✅ Fixed to match actual API response:
  //   GET /api/referral-dashboard/:driverId/referral-dashboard
  //
  //   $.driver.referred_driver_count                         → totalReferrals
  //   $.lifetime_statistics.total_commission_earned          → teamEarnings
  //   $.yesterday_statistics.referrals                       → referredDrivers list
  //   Each item: { name, pro_rides_completed, normal_rides_completed,
  //                ride_earnings, commission_earned_by_72 }
  Future<void> _fetchTeamData() async {
    setState(() => isLoadingTeam = true);
    try {
      final dashboardResponse = await ReferralDashboardCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );
      final earningsResponse = await ReferralEarningsCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (dashboardResponse.succeeded || earningsResponse.succeeded) {
        final dashboardBody = dashboardResponse.succeeded
            ? dashboardResponse.jsonBody
            : <String, dynamic>{};
        final earningsBody = earningsResponse.succeeded
            ? earningsResponse.jsonBody
            : <String, dynamic>{};

        final dashboardReferrals =
            ReferralDashboardCall.totalReferrals(dashboardBody);
        final successfulReferrals =
            ReferralEarningsCall.successfulReferralsCount(earningsBody);
        final referredCount = (successfulReferrals > 0
                ? successfulReferrals
                : dashboardReferrals)
            .toString();

        final earningsTotal = ReferralEarningsCall.totalEarnings(earningsBody);
        final lifetimeCommission = earningsTotal > 0
            ? earningsTotal
            : ReferralDashboardCall.totalEarnings(dashboardBody);

        final List<dynamic> dashboardDrivers =
            ReferralDashboardCall.referrals(dashboardBody);
        final List<dynamic> earningsDetails =
            ReferralEarningsCall.referredDetails(earningsBody);
        final List<dynamic> drivers =
            dashboardDrivers.isNotEmpty ? dashboardDrivers : earningsDetails;

        setState(() {
          teamEarnings = '₹$lifetimeCommission';
          pendingToday =
              '₹${ReferralDashboardCall.todayPendingCommission(dashboardBody)}';
          additionalIfMatchedAll =
              '₹${ReferralDashboardCall.additionalCommissionIfMatchedAll(dashboardBody)}';
          totalReferrals = referredCount;
          referredDrivers = drivers;
          isLoadingTeam = false;
        });
      } else {
        setState(() => isLoadingTeam = false);
      }
    } catch (e) {
      debugPrint('Error fetching team data: $e');
      setState(() => isLoadingTeam = false);
    }
  }

  // 3. Fetch Weekly Earnings and Aggregate by Day
  Future<void> _fetchWeeklyEarnings() async {
    setState(() => isLoadingWeekly = true);
    try {
      final response = await DriverEarningsCall.call(
        driverId: FFAppState().driverid,
        token: FFAppState().accessToken,
        period: 'weekly',
      );

      if (response.succeeded) {
        final rides = DriverEarningsCall.rides(response.jsonBody) ?? [];
        final List<double> aggregated = [0, 0, 0, 0, 0, 0, 0];

        final now = DateTime.now();
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(
            firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);

        for (var ride in rides) {
          final createdAtStr = ride['created_at'];
          if (createdAtStr == null) continue;

          final createdAt = DateTime.tryParse(createdAtStr.toString());
          if (createdAt == null) continue;

          if (createdAt
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
            final dayIndex = createdAt.weekday - 1; // 0 for Mon, 6 for Sun
            if (dayIndex >= 0 && dayIndex < 7) {
              final fare = (ride['estimated_fare'] ?? 0).toDouble();
              aggregated[dayIndex] += fare;
            }
          }
        }

        setState(() {
          dailyEarningsList = aggregated;
          isLoadingWeekly = false;
        });
      } else {
        setState(() => isLoadingWeekly = false);
      }
    } catch (e) {
      debugPrint('Error fetching weekly earnings: $e');
      setState(() => isLoadingWeekly = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brand = AppColors.primary;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        ),
        title: Text(
          'Earnings Dashboard',
          style: GoogleFonts.interTight(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: brand,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: brand,
              indicatorWeight: 3,
              labelStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'All Earnings'),
                Tab(text: 'Team Earnings'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 1: All Earnings (completely unchanged) ────────────────
          isLoading
              ? const Center(child: CircularProgressIndicator(color: brand))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      AnimatedListItem(
                        index: 0,
                        child: _buildGradientEarningsCard(
                          title: 'Total Personal Earnings',
                          amount: todaysEarnings,
                          colors: [brand, brand.withValues(alpha: 0.8)],
                          shadowColor: brand.withValues(alpha: 0.4),
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedListItem(
                        index: 1,
                        child: _buildPremiumMenuItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'All Rides',
                          subtitle: 'Ride History and Ride Earnings',
                          color: const Color(0xFF4A90E2),
                          onTap: () =>
                              context.pushNamed(AllOrdersScreen.routeName),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedListItem(
                        index: 2,
                        child: _buildPremiumMenuItem(
                          icon: Icons.history_rounded,
                          title: 'Last Ride Earnings',
                          subtitle: 'View recent trip earnings',
                          color: const Color(0xFF9B59B6),
                          onTap: () =>
                              context.pushNamed(LastOrderWidget.routeName),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedListItem(
                        index: 3,
                        child: _buildPremiumMenuItem(
                          icon: Icons.currency_rupee_rounded,
                          title: 'View Rate Card',
                          subtitle: 'Check base fares and commission',
                          color: const Color(0xFFE74C3C),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RateCardWidget()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),

          // ── TAB 2: Team / Pro Ride Earnings – redesigned to match provided UI ──
          isLoadingTeam
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top total earnings + date (similar to second mockup header)
                      AnimatedListItem(
                        index: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamEarnings.replaceFirst('₹', ''),
                              style: GoogleFonts.interTight(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd-MM-yy EEEE')
                                  .format(DateTime.now()),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 14, color: Colors.orange),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Daily',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down_rounded,
                                      color: Colors.orange, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Simple sparkline-style earnings chart using weekly data
                      AnimatedListItem(
                        index: 1,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: CustomPaint(
                            painter: _EarningsLineChartPainter(
                              data: dailyEarningsList,
                              lineColor: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Table header: Total earnings for team, rides count
                      AnimatedListItem(
                        index: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Team',
                                  style: GoogleFonts.interTight(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total riders $totalReferrals',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Pending today',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  pendingToday,
                                  style: GoogleFonts.interTight(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Data table matching the "s/no – name – vehicle – yesterday – today" UI
                      AnimatedListItem(
                        index: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(Colors.grey[100]),
                              columnSpacing: 18,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    's/no',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Names',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Vehicle no',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Yesterday',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Today',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              rows: referredDrivers.asMap().entries.map((e) {
                                final index = e.key;
                                final driver =
                                    e.value as Map<String, dynamic>;

                                final name = (driver['name'] ??
                                        driver['referred_name'] ??
                                        'Unknown')
                                    .toString();
                                final vehicleNo =
                                    (driver['vehicle_number'] ?? '—')
                                        .toString();

                                // We do not yet have explicit per‑day fields per driver from backend.
                                // As a reasonable approximation:
                                //  - "Today" uses pro_rides_completed
                                //  - "Yesterday" uses normal_rides_completed
                                final todayPro =
                                    (driver['pro_rides_completed'] as num?)
                                            ?.toInt() ??
                                        0;
                                final yesterdayNormal =
                                    (driver['normal_rides_completed'] as num?)
                                            ?.toInt() ??
                                        0;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          const Icon(Icons.account_circle,
                                              size: 18,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            name,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        vehicleNo,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '$yesterdayNormal',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '$todayPro',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS (all unchanged from original) ---

  Widget _buildGradientEarningsCard({
    required String title,
    required String amount,
    required List<Color> colors,
    required Color shadowColor,
    required IconData icon,
    double bottomPadding = 32.0,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 32, 24, bottomPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: shadowColor, blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(
      String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor.withValues(alpha: 0.7), size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.interTight(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPremiumMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withValues(alpha: 0.1),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight sparkline‑style chart painter for weekly earnings.
class _EarningsLineChartPainter extends CustomPainter {
  _EarningsLineChartPainter({
    required this.data,
    required this.lineColor,
  });

  final List<double> data;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.every((v) => v == 0)) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(0, size.height * 0.6)
        ..lineTo(size.width, size.height * 0.6);
      canvas.drawPath(path, paint);
      return;
    }

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs() < 1 ? 1.0 : (maxVal - minVal);

    final dx = data.length == 1 ? size.width : size.width / (data.length - 1);

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = dx * i;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * (size.height * 0.7)) - 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EarningsLineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
