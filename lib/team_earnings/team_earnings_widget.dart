import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ugo_driver/services/team_referral_aggregate.dart';
import 'package:ugo_driver/team_earnings/view_rate_card_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
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

  // Data Variables - Team Earnings (Pro referral commission)
  String teamEarnings = '₹0';
  String pendingToday = '₹0';
  String additionalIfMatchedAll = '₹0';
  String totalReferrals = '0';
  List<dynamic> _referralsToday = [];
  List<dynamic> _referralsYesterday = [];
  Map<String, dynamic>? _dashboardDriver;
  int _myProRidesToday = 0;
  String _walletSchedule = 'end_of_day';
  bool isLoadingTeam = true;
  String? _proReferralCode;
  List<dynamic> _recentDriverPayouts = [];
  double _dailyReferralInr = 0;
  int _dailyMatchedRides = 0;

  /// When dashboard today/yesterday are empty but Pro roster has drivers.
  List<Map<String, dynamic>> _rosterFallback = [];

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamEarningsModel());
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarningsData();
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
      final snapshot = await loadTeamReferralSnapshot(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      final dashboardBody = snapshot.dashboardBody ?? <String, dynamic>{};
      final earningsBody = snapshot.earningsBody ?? <String, dynamic>{};

      final dashboardReferrals =
          ReferralDashboardCall.totalReferrals(dashboardBody);
      final successfulReferrals =
          ReferralEarningsCall.successfulReferralsCount(earningsBody);
      final mergedN = snapshot.mergedTeamMembers.length;
      final proN = snapshot.proMyTotalFromApi;
      final referredCount = math
          .max(
            math.max(dashboardReferrals, successfulReferrals),
            math.max(mergedN, proN),
          )
          .toString();

      final earningsTotal = ReferralEarningsCall.totalEarnings(earningsBody);
      final lifetimeCommission = earningsTotal > 0
          ? earningsTotal
          : ReferralDashboardCall.totalEarnings(dashboardBody);

      final todayList = snapshot.todayLiveReferrals
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      snapshot.applyDailyProToRows(todayList);

      final yesterdayList = snapshot.yesterdayReferrals
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final daily = snapshot.proDailyBody;
      final dailyInr = _parseAmount(daily?['my_referral_earnings_inr']);
      final matched = _parseIntAny(daily?['matched_rides_total']);

      setState(() {
        teamEarnings = '₹$lifetimeCommission';
        pendingToday =
            '₹${ReferralDashboardCall.todayPendingCommission(dashboardBody)}';
        additionalIfMatchedAll =
            '₹${ReferralDashboardCall.additionalCommissionIfMatchedAll(dashboardBody)}';
        totalReferrals = referredCount;
        _referralsToday = todayList;
        _referralsYesterday = yesterdayList;
        _dashboardDriver = ReferralDashboardCall.driverInfo(dashboardBody);
        _myProRidesToday = daily != null
            ? _parseIntAny(daily['my_pro_rides_today'])
            : ReferralDashboardCall.todayMyProRides(dashboardBody);
        _walletSchedule =
            ReferralDashboardCall.walletCreditSchedule(dashboardBody);
        _proReferralCode = snapshot.proReferralCode;
        _recentDriverPayouts = snapshot.proHistoryDriverRows.take(6).toList();
        _dailyReferralInr = dailyInr;
        _dailyMatchedRides = matched;
        if (todayList.isEmpty &&
            yesterdayList.isEmpty &&
            snapshot.mergedTeamMembers.isNotEmpty) {
          _rosterFallback = snapshot.mergedTeamMembers
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          _rosterFallback = [];
        }
        isLoadingTeam = false;
      });
    } catch (e) {
      debugPrint('Error fetching team data: $e');
      setState(() => isLoadingTeam = false);
    }
  }

  static double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _parseIntAny(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
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
          'Earnings',
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
                Tab(text: 'My trips'),
                Tab(text: 'Pro referrals'),
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

          // ── TAB 2: Pro referral commission (clear for captains) ─────────────
          isLoadingTeam
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _fetchTeamData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedListItem(
                          index: 0,
                          child: _buildYouProfileCard(brand),
                        ),
                        if (_proReferralCode != null &&
                            _proReferralCode!.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          AnimatedListItem(
                            index: 1,
                            child:
                                _buildReferralCodeCaptainCard(brand, context),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AnimatedListItem(
                          index: 2,
                          child: _buildTotalCommissionCard(brand),
                        ),
                        const SizedBox(height: 12),
                        AnimatedListItem(
                          index: 3,
                          child: _buildTodaySnapshotRow(brand),
                        ),
                        if (_dailyReferralInr > 0 ||
                            _dailyMatchedRides > 0) ...[
                          const SizedBox(height: 12),
                          AnimatedListItem(
                            index: 4,
                            child: _buildProDailyV2Card(brand),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AnimatedListItem(
                          index: 5,
                          child: _buildExplainBox(),
                        ),
                        if (_recentDriverPayouts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          AnimatedListItem(
                            index: 6,
                            child: _buildRecentPayoutsCard(brand),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          'Friends you referred — Pro rides only',
                          style: GoogleFonts.interTight(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'We only count Pro bookings. Commission is ₹10 per matched Pro ride (you and your friend both complete Pro trips the same day).',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.35,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_referralsToday.isEmpty &&
                            _referralsYesterday.isEmpty &&
                            _rosterFallback.isEmpty)
                          _buildEmptyReferrals()
                        else if (_referralsToday.isEmpty &&
                            _referralsYesterday.isEmpty &&
                            _rosterFallback.isNotEmpty) ...[
                          Text(
                            'Your invited team',
                            style: GoogleFonts.interTight(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Live Pro stats will appear here once the dashboard syncs. These captains joined with your code.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.35,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._rosterFallback.asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AnimatedListItem(
                                    index: 30 + e.key,
                                    child: _buildFriendReferralCard(
                                      e.value,
                                      yesterday: true,
                                      brand: brand,
                                    ),
                                  ),
                                ),
                              ),
                        ] else ...[
                          if (_referralsToday.isNotEmpty) ...[
                            Text(
                              'Today',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: brand,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._referralsToday.asMap().entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: AnimatedListItem(
                                      index: 8 + e.key,
                                      child: _buildFriendReferralCard(
                                        Map<String, dynamic>.from(
                                          e.value as Map,
                                        ),
                                        yesterday: false,
                                        brand: brand,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                          if (_referralsYesterday.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Yesterday (already settled)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._referralsYesterday.asMap().entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: AnimatedListItem(
                                      index: 20 + e.key,
                                      child: _buildFriendReferralCard(
                                        Map<String, dynamic>.from(
                                          e.value as Map,
                                        ),
                                        yesterday: true,
                                        brand: brand,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _driverDisplayName() {
    final n = _dashboardDriver?['name']?.toString().trim();
    if (n != null && n.isNotEmpty && n != 'null') return n;
    final f = FFAppState().firstName.trim();
    final l = FFAppState().lastName.trim();
    final joined = '$f $l'.trim();
    return joined.isEmpty ? 'Captain' : joined;
  }

  String _formatMobile() {
    final m = FFAppState().mobileNo;
    if (m <= 0) return '';
    return m.toString();
  }

  double _readNum(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final n = num.tryParse(v.toString());
      if (n != null) return n.toDouble();
    }
    return 0;
  }

  Widget _buildYouProfileCard(Color brand) {
    final initial = _driverDisplayName().isNotEmpty
        ? _driverDisplayName().substring(0, 1).toUpperCase()
        : '?';
    final referredBy = _dashboardDriver?['referred_by'];
    String? referredByName;
    if (referredBy is Map) {
      referredByName = referredBy['name']?.toString();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: brand.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: GoogleFonts.interTight(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: brand,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _driverDisplayName(),
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (_formatMobile().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatMobile(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                if (referredByName != null &&
                    referredByName.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.waving_hand_rounded,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'You were referred by $referredByName',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCommissionCard(Color brand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brand, brand.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: brand.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total referral commission earned',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            teamEarnings,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is all Pro-referral money credited to you from friends’ matched Pro rides (paid after daily calculation).',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySnapshotRow(Color brand) {
    return Row(
      children: [
        Expanded(
          child: _snapshotTile(
            icon: Icons.electric_moped_rounded,
            label: 'Your Pro rides today',
            value: '$_myProRidesToday',
            sub: 'You need Pro trips to “match” friends',
            color: brand,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _snapshotTile(
            icon: Icons.people_outline_rounded,
            label: 'Friends referred',
            value: totalReferrals,
            sub: 'Active in your team',
            color: const Color(0xFF5C6BC0),
          ),
        ),
      ],
    );
  }

  Widget _snapshotTile({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.interTight(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style:
                GoogleFonts.inter(fontSize: 10.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildExplainBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pending today',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$pendingToday — estimated commission if today’s Pro rides stay matched. '
            'Extra if you catch up: $additionalIfMatchedAll.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.35,
              color: Colors.brown.shade800,
            ),
          ),
          if (_walletSchedule.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _walletSchedule == 'end_of_day'
                  ? 'Wallet credit: usually at end of day after we match rides.'
                  : 'Wallet credit: $_walletSchedule',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.brown.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferralCodeCaptainCard(Color brand, BuildContext context) {
    final code = _proReferralCode!.trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded, color: brand, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your captain invite code',
                    style: GoogleFonts.interTight(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: brand,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied')),
                      );
                    }
                  },
                  child: const Text('Copy code'),
                ),
                TextButton(
                  onPressed: () =>
                      context.pushNamed(ProReferralMyWidget.routeName),
                  child: Text(
                    'Open referral hub',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: brand,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProDailyV2Card(Color brand) {
    final rupees = _dailyReferralInr % 1 == 0
        ? _dailyReferralInr.toInt().toString()
        : _dailyReferralInr.toStringAsFixed(2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.indigo.shade700, size: 22),
              const SizedBox(width: 8),
              Text(
                'Today · live Pro referral',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Matched rides today: $_dailyMatchedRides',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your referral earnings (today’s calc): ₹$rupees',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.35,
              color: Colors.indigo.shade900,
            ),
          ),
        ],
      ),
    );
  }

  String _shortPayoutDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    final d = DateTime.tryParse(s);
    if (d != null) {
      final l = d.toLocal();
      return '${l.day}/${l.month} ${l.hour}:${l.minute.toString().padLeft(2, '0')}';
    }
    return s.length > 20 ? '${s.substring(0, 20)}…' : s;
  }

  Widget _buildRecentPayoutsCard(Color brand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_rounded, color: brand, size: 22),
              const SizedBox(width: 8),
              Text(
                'Recent referral credits',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentDriverPayouts.take(5).map((raw) {
            if (raw is! Map) return const SizedBox.shrink();
            final m = Map<String, dynamic>.from(raw);
            final amt = _parseAmount(
                m['amount'] ?? m['driver_reward_amount'] ?? m['reward_amount']);
            final rupees =
                amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(2);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shortPayoutDate(m['created_at']),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Text(
                    '₹$rupees',
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyReferrals() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.person_add_alt_1_rounded,
              size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No referred captains yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your referral code from Refer & earn. When friends join and drive Pro rides, their Pro trip counts show here and you earn commission on matched days.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendReferralCard(
    Map<String, dynamic> row, {
    required bool yesterday,
    required Color brand,
  }) {
    final name = (row['name'] ?? row['referred_name'] ?? 'Friend').toString();
    final vehicle = (row['vehicle_number'] ?? '—').toString();
    final proOnly = _readNum(row, ['pro_rides_completed']).round();
    final commission = yesterday
        ? _readNum(row, ['commission_earned'])
        : _readNum(row, ['commission_earned', 'commission_earned_by_72']);
    final perRide = _readNum(row, ['amount_per_pro_ride']);
    final matched = _readNum(row, ['matched_rides_now']).round();
    final needMore =
        _readNum(row, ['additional_rides_needed_to_match']).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: brand.withValues(alpha: 0.12),
                child: Icon(Icons.person_rounded, color: brand, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      vehicle == 'null' || vehicle.isEmpty
                          ? 'Vehicle —'
                          : vehicle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Their Pro rides',
                  '$proOnly',
                  subtitle: yesterday ? '(that day)' : '(today)',
                ),
              ),
              Expanded(
                child: _miniStat(
                  'Your commission',
                  '₹${commission % 1 == 0 ? commission.toInt().toString() : commission.toStringAsFixed(2)}',
                  subtitle: yesterday ? 'Paid to wallet' : 'If matched today',
                ),
              ),
            ],
          ),
          if (!yesterday && (matched > 0 || needMore > 0 || perRide > 0)) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                needMore > 0
                    ? 'You need $needMore more Pro ride${needMore == 1 ? '' : 's'} today to match their $proOnly and unlock up to ₹${(needMore * (perRide > 0 ? perRide : 10)).toStringAsFixed(0)} more.'
                    : 'Matched $matched Pro ride${matched == 1 ? '' : 's'} today — commission uses ₹${perRide > 0 ? perRide.toStringAsFixed(0) : '10'} per match.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  height: 1.35,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.interTight(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
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
