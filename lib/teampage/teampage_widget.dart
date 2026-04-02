import 'dart:async';
import 'dart:math' as math;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/index.dart';
import '/services/team_referral_aggregate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teampage_model.dart';
export 'teampage_model.dart';

class TeampageWidget extends StatefulWidget {
  const TeampageWidget({super.key});

  static String routeName = 'teampage';
  static String routePath = '/teampage';

  @override
  State<TeampageWidget> createState() => _TeampageWidgetState();
}

class _TeampageWidgetState extends State<TeampageWidget>
    with TickerProviderStateMixin {
  late TeampageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Color ugoOrange = AppColors.primary;
  final Color ugoOrangeLight = AppColors.primaryLight;
  final Color ugoGreen = AppColors.success;
  final Color ugoBlue = AppColors.accentBlue;

  bool _isLoading = true;
  Timer? _refreshTimer;
  TeamReferralSnapshot? _teamSnapshot;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeampageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReferralData());
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _loadReferralData();
    });
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await loadTeamReferralSnapshot(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      dynamic dashboardBody = snapshot.dashboardBody;
      final merged = snapshot.mergedTeamMembers;

      if (merged.isEmpty && dashboardBody == null) {
        final earningsRes = await ReferralEarningsCall.call(
          token: FFAppState().accessToken,
          driverId: FFAppState().driverid,
        );
        if (earningsRes.succeeded) {
          final details = ReferralEarningsCall.referredDetails(earningsRes.jsonBody);
          if (details.isNotEmpty) {
            final mapped = details.map((d) {
              final item = d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
              return <String, dynamic>{
                'driver_id': item['driver_id'],
                'name': (item['name'] ?? item['referred_name'] ?? 'Unknown').toString(),
                'pro_rides_completed': _asInt(item['pro_rides'] ?? item['pro_rides_completed']),
                'normal_rides_completed':
                    _asInt(item['normal_rides'] ?? item['normal_rides_completed']),
                'commission_earned': _asNum(item['amount'] ?? item['commission_earned']),
                'my_pro_rides_today': _asInt(item['my_pro_rides_today']),
                'additional_rides_needed_to_match':
                    _asInt(item['additional_rides_needed_to_match']),
              };
            }).toList();

            dashboardBody = _mergeFallbackReferrals(
              dashboardBody,
              mapped,
              totalReferrals: details.length,
              lifetimeEarnings: ReferralEarningsCall.totalEarnings(earningsRes.jsonBody),
            );
          }
        }
      }

      setState(() {
        _teamSnapshot = snapshot;
        _model.referralData = dashboardBody;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  double _asNum(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  Map<String, dynamic> _mergeFallbackReferrals(
    dynamic current,
    List<Map<String, dynamic>> referrals, {
    required int totalReferrals,
    required int lifetimeEarnings,
  }) {
    final root = current is Map ? Map<String, dynamic>.from(current) : <String, dynamic>{};
    final driver = root['driver'] is Map
        ? Map<String, dynamic>.from(root['driver'] as Map)
        : <String, dynamic>{};
    driver['referred_driver_count'] = totalReferrals;
    root['driver'] = driver;

    final lifetime = root['lifetime_statistics'] is Map
        ? Map<String, dynamic>.from(root['lifetime_statistics'] as Map)
        : <String, dynamic>{};
    lifetime['total_commission_earned'] = lifetimeEarnings;
    root['lifetime_statistics'] = lifetime;

    final today = root['today_live'] is Map
        ? Map<String, dynamic>.from(root['today_live'] as Map)
        : <String, dynamic>{};
    today['referrals'] = referrals;
    root['today_live'] = today;
    return root;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  // ── JSON path helpers ────────────────────────────────────────────────────

  /// $.driver.referred_driver_count + Pro roster merge
  String get _referredCount {
    final snap = _teamSnapshot;
    final merged = snap?.mergedTeamMembers.length ?? 0;
    final dash = _model.referralData != null
        ? ReferralDashboardCall.totalReferrals(_model.referralData)
        : 0;
    final pro = snap != null
        ? math.max(snap.proMyTotalFromApi, merged)
        : merged;
    return '${math.max(dash, pro)}';
  }

  /// $.lifetime_statistics.total_commission_earned
  String get _lifetimeCommission {
    final earn = _teamSnapshot?.earningsBody;
    if (earn != null) {
      final t = ReferralEarningsCall.totalEarnings(earn);
      if (t > 0) return '₹$t';
    }
    if (_model.referralData == null) return '₹0';
    return '₹${ReferralDashboardCall.totalEarnings(_model.referralData)}';
  }

  /// Today ride earnings (from live dashboard)
  String get _todayRideEarnings {
    if (_model.referralData == null) return '₹0';
    return '₹${castToType<int>(getJsonField(_model.referralData, r'$.today_live.my_performance.ride_earnings')) ?? 0}';
  }

  /// Pending commission today
  String get _pendingCommissionToday {
    if (_model.referralData == null) return '₹0';
    return '₹${ReferralDashboardCall.todayPendingCommission(_model.referralData)}';
  }

  /// Merged referrals: dashboard + Pro invite list (no phone)
  List<dynamic> get _referralsList {
    final snap = _teamSnapshot;
    if (snap != null && snap.mergedTeamMembers.isNotEmpty) {
      return snap.mergedTeamMembers;
    }
    if (_model.referralData == null) return [];
    return ReferralDashboardCall.referrals(_model.referralData);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundAlt,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: ugoOrange))
            : Stack(
                children: [
                  // ── HEADER GRADIENT ──
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ugoOrange, ugoOrangeLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ugoOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                  ),

                  // ── CONTENT ──
                  SafeArea(
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              FlutterFlowIconButton(
                                borderColor:
                                    Colors.white.withValues(alpha: 0.3),
                                borderRadius: 30.0,
                                borderWidth: 1.0,
                                buttonSize: 45.0,
                                fillColor: Colors.white.withValues(alpha: 0.2),
                                icon: const Icon(Icons.arrow_back_rounded,
                                    color: Colors.white, size: 24.0),
                                onPressed: () => context.pop(),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'My Team',
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              FlutterFlowIconButton(
                                borderColor:
                                    Colors.white.withValues(alpha: 0.3),
                                borderRadius: 30.0,
                                borderWidth: 1.0,
                                buttonSize: 42.0,
                                fillColor: Colors.white.withValues(alpha: 0.2),
                                icon: const Icon(Icons.card_giftcard_rounded,
                                    color: Colors.white, size: 20.0),
                                onPressed: () => context
                                    .pushNamed(ProReferralMyWidget.routeName),
                              ),
                              const SizedBox(width: 6),
                              FlutterFlowIconButton(
                                borderColor:
                                    Colors.white.withValues(alpha: 0.3),
                                borderRadius: 30.0,
                                borderWidth: 1.0,
                                buttonSize: 42.0,
                                fillColor: Colors.white.withValues(alpha: 0.2),
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white, size: 20.0),
                                onPressed: _loadReferralData,
                              ),
                            ],
                          ),
                        ),

                        // Header summary
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Referrals',
                                    style: GoogleFonts.inter(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    _referredCount,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'My Team',
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Stat cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Referrals',
                                  value: _referredCount,
                                  icon: Icons.people_alt,
                                  color: ugoBlue,
                                  delay: 100,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Earnings',
                                  value: _lifetimeCommission,
                                  icon: Icons.account_balance_wallet,
                                  color: ugoGreen,
                                  delay: 200,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Yesterday strip
                        _buildYesterdayStrip(),

                        const SizedBox(height: 12),

                        // Referrals list
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                                top: 22, left: 20, right: 20),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your team',
                                          style: GoogleFonts.interTight(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Captains you invited · Pro stats when synced',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ugoOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_referralsList.length} drivers',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: ugoOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: RefreshIndicator(
                                    color: ugoOrange,
                                    onRefresh: _loadReferralData,
                                    child: _buildTeamList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Yesterday strip ──────────────────────────────────────────────────────

  Widget _buildYesterdayStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: ugoOrange, size: 16),
            const SizedBox(width: 8),
            Text(
              'Today Live',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            _miniStat(
                label: 'Your ride earnings',
                value: _todayRideEarnings,
                color: ugoGreen),
            const SizedBox(width: 20),
            _miniStat(
                label: 'Pending commission',
                value: _pendingCommissionToday,
                color: ugoBlue),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(
      {required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.interTight(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  // ── Stat Card ────────────────────────────────────────────────────────────

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double val, child) {
        return Transform.scale(
          scale: val,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Team List ────────────────────────────────────────────────────────────

  Widget _buildTeamList() {
    // ✅ CORRECT PATH: $.yesterday_statistics.referrals
    final referrals = _referralsList;

    if (referrals.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 48),
          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No referrals yet',
              style: GoogleFonts.interTight(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Share your captain code from Earnings → Pro referrals or Referral hub.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.35,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: referrals.length,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemBuilder: (context, index) {
        final driver = referrals[index] as Map<String, dynamic>;

        // ✅ Keys from actual API response
        final name = driver['name']?.toString() ?? 'Unknown';
        final proRides = (driver['pro_rides_completed'] as num?)?.toInt() ?? 0;
        final normalRides =
            (driver['normal_rides_completed'] as num?)?.toInt() ?? 0;
        final commission = ((driver['commission_earned'] as num?) ??
                    (driver['commission_earned_by_72'] as num?))
                ?.toDouble() ??
            0.0;
        final myProRidesToday =
            (driver['my_pro_rides_today'] as num?)?.toInt() ??
                ReferralDashboardCall.todayMyProRides(_model.referralData);
        final additionalNeeded =
            (driver['additional_rides_needed_to_match'] as num?)?.toInt() ?? 0;
        final totalRides = proRides + normalRides;
        final bool isActive = totalRides > 0;

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 80)),
          curve: Curves.easeOut,
          builder: (context, double val, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - val)),
              child: Opacity(
                opacity: val,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isActive
                          ? ugoGreen.withValues(alpha: 0.45)
                          : Colors.grey[200]!,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ugoGreen.withValues(alpha: 0.12)
                              : ugoOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: GoogleFonts.interTight(
                              color: isActive ? ugoGreen : ugoOrange,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? ugoGreen.withValues(alpha: 0.12)
                                        : Colors.grey.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? ugoGreen : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _rideChip(
                                    label: '$proRides Pro', color: ugoBlue),
                                const SizedBox(width: 6),
                                _rideChip(
                                    label: '$normalRides Normal',
                                    color: ugoOrange),
                                const SizedBox(width: 6),
                                Text(
                                  'Me: $myProRidesToday Pro',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            if (additionalNeeded > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Complete $additionalNeeded more Pro rides to fully match this friend today',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: ugoOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Commission
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${commission.toStringAsFixed(0)}',
                            style: GoogleFonts.interTight(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color:
                                  commission > 0 ? ugoGreen : Colors.grey[400],
                            ),
                          ),
                          // Text(
                          //   'commission',
                          //   style: GoogleFonts.inter(
                          //     fontSize: 10,
                          //     color: Colors.grey[400],
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _rideChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
