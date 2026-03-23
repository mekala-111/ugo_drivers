import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String totalReferrals = '0';
  List<dynamic> referredDrivers = [];
  bool isLoadingTeam = true;

  // Weekly Chart Data
  List<double> dailyEarningsList = [0, 0, 0, 0, 0, 0, 0];
  bool isLoadingWeekly = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamEarningsModel());
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarningsData();
    _fetchWeeklyEarnings();
    _fetchTeamData();
  }

  @override
  void dispose() {
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
      final response = await ReferralDashboardCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (response.succeeded) {
        final body = response.jsonBody;

        // Total referred drivers count
        final referredCount =
            (getJsonField(body, r'$.driver.referred_driver_count') ?? 0)
                .toString();

        // Lifetime commission earned
        final lifetimeCommission =
            getJsonField(body, r'$.lifetime_statistics.total_commission_earned') ?? 0;

        // Referrals list (yesterday's activity)
        final List<dynamic> drivers =
            (getJsonField(body, r'$.yesterday_statistics.referrals', true) as List?) ?? [];

        setState(() {
          teamEarnings = '₹$lifetimeCommission';
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
        final startOfWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);

        for (var ride in rides) {
          final createdAtStr = ride['created_at'];
          if (createdAtStr == null) continue;
          
          final createdAt = DateTime.tryParse(createdAtStr.toString());
          if (createdAt == null) continue;
          
          if (createdAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
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

          // ── TAB 2: Team Earnings ──────────────────────────────────────
          isLoadingTeam
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 25, bottom: 40),
                  child: Column(
                    children: [
                      // Header & Floating Stats (same layout, fixed data)
                      AnimatedListItem(
                        index: 0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildGradientEarningsCard(
                                title: 'Total Team Earnings',
                                amount: teamEarnings,
                                colors: [
                                  const Color(0xFF2ECC71),
                                  const Color(0xFF27AE60)
                                ],
                                shadowColor: const Color(0xFF2ECC71)
                                    .withValues(alpha: 0.4),
                                icon: Icons.groups_rounded,
                                bottomPadding: 61,
                              ),
                            ),
                            // Floating Stats Box
                            Positioned(
                              bottom: -25,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width - 60,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // ✅ $.driver.referred_driver_count
                                    _buildTeamStat(
                                      'Active Drivers',
                                      totalReferrals,
                                      Icons.group_rounded,
                                      brand,
                                    ),
                                    Container(
                                        width: 1,
                                        height: 41,
                                        color: Colors.grey.shade200),
                                    // ✅ $.lifetime_statistics.total_commission_earned
                                    _buildTeamStat(
                                      'Commission',
                                      teamEarnings,
                                      Icons.currency_rupee_rounded,
                                      const Color(0xFFE74C3C),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Team List Header
                      AnimatedListItem(
                        index: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.people_alt_rounded,
                                    color: Colors.orange, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Your Team ($totalReferrals)',
                                style: GoogleFonts.interTight(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Team Members List
                      if (referredDrivers.isEmpty)
                        AnimatedListItem(
                          index: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.group_off_rounded,
                                    size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No team members yet.',
                                  style: GoogleFonts.inter(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Share your referral code to start earning!',
                                  style: GoogleFonts.inter(
                                      color: Colors.grey.shade400,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: referredDrivers.length,
                          itemBuilder: (context, index) {
                            final driver =
                                referredDrivers[index] as Map<String, dynamic>;

                            // ✅ All keys from actual API response
                            final name =
                                driver['name']?.toString() ?? 'Unknown Driver';
                            final proRides =
                                (driver['pro_rides_completed'] as num?)
                                        ?.toInt() ??
                                    0;
                            final normalRides =
                                (driver['normal_rides_completed'] as num?)
                                        ?.toInt() ??
                                    0;
                            final rideEarnings =
                                (driver['ride_earnings'] as num?)?.toInt() ?? 0;
                            final commission =
                                (driver['commission_earned_by_72'] as num?)
                                        ?.toDouble() ??
                                    0.0;
                            final totalRides = proRides + normalRides;

                            return AnimatedListItem(
                              index: index + 2,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFFFD4B2),
                                        Color(0xFFFFE0B2)
                                      ]),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : 'U',
                                        style: GoogleFonts.inter(
                                            color: Colors.orange.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  // ✅ driver['name']
                                  title: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                  // ✅ pro_rides + normal_rides + total
                                  subtitle: Text(
                                    '$proRides Pro • $normalRides Normal • $totalRides rides',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      // ✅ commission_earned_by_72
                                      Text(
                                        '₹${commission.toStringAsFixed(0)}',
                                        style: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2ECC71),
                                            fontSize: 16),
                                      ),
                                      // ✅ ride_earnings
                                      Text(
                                        '₹$rideEarnings earned',
                                        style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
          BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 10))
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