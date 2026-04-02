import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/services/team_referral_aggregate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teamrides_model.dart';
export 'teamrides_model.dart';

class TeamridesWidget extends StatefulWidget {
  const TeamridesWidget({super.key});

  static String routeName = 'teamrides';
  static String routePath = '/teamrides';

  @override
  State<TeamridesWidget> createState() => _TeamridesWidgetState();
}

class _TeamridesWidgetState extends State<TeamridesWidget> {
  late TeamridesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  // TL + team summary
  String _tlName = '';
  String? _referredByName;
  int _teamSize = 0;

  // Totals for cards
  int _totalProRidesToday = 0;
  int _totalProRidesYesterday = 0;
  String _totalTeamEarnings = '₹0';

  // Table rows: TL row + members
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamridesModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTeamRides());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Team Pro rides',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
                  children: [
                    _buildSummary(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadTeamRides,
                        child: _rows.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.15,
                                  ),
                                  _buildEmptyState(),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    16, 10, 16, 24),
                                itemCount: _rows.length,
                                itemBuilder: (context, index) =>
                                    _buildReferralTile(_rows[index]),
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _loadTeamRides() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await loadTeamReferralSnapshot(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      final dash = snapshot.dashboardBody ?? <String, dynamic>{};
      final earn = snapshot.earningsBody ?? <String, dynamic>{};

      if (dash.isEmpty && earn.isEmpty && snapshot.mergedTeamMembers.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final driverObj = dash['driver'] as Map<String, dynamic>? ?? {};
      final referredByObj =
          driverObj['referred_by'] as Map<String, dynamic>? ?? {};

      final myTodayPerf = (dash['today_live']?['my_performance']
              as Map<String, dynamic>?) ??
          {};
      final myYdayPerf = (dash['yesterday_statistics']?['my_performance']
              as Map<String, dynamic>?) ??
          {};

      var todayRefs = snapshot.todayLiveReferrals
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      snapshot.applyDailyProToRows(todayRefs);

      final List<dynamic> ydayRefs =
          (dash['yesterday_statistics']?['referrals'] as List?) ?? [];

      final Map<int, Map<String, dynamic>> ydayById = {};
      for (final item in ydayRefs) {
        final m = (item as Map).cast<String, dynamic>();
        final id = (m['driver_id'] as num?)?.toInt();
        if (id != null) ydayById[id] = m;
      }

      int tlTodayPro =
          (myTodayPerf['pro_rides_completed'] as num?)?.toInt() ?? 0;
      if (tlTodayPro == 0 && snapshot.proDailyBody != null) {
        tlTodayPro = (snapshot.proDailyBody!['my_pro_rides_today'] as num?)
                ?.toInt() ??
            0;
      }
      final int tlYdayPro =
          (myYdayPerf['pro_rides_completed'] as num?)?.toInt() ?? 0;

      final List<Map<String, dynamic>> rows = [];
      rows.add({
        'is_tl': true,
        'name': driverObj['name']?.toString().trim().isNotEmpty == true
            ? driverObj['name'].toString()
            : 'You (captain)',
        'vehicle_number': null,
        'yesterday': tlYdayPro,
        'today': tlTodayPro,
        'commission': 0,
      });

      for (final m in todayRefs) {
        final id = (m['driver_id'] as num?)?.toInt();
        final yday = id != null ? ydayById[id] : null;
        final int todayPro =
            (m['pro_rides_completed'] as num?)?.toInt() ?? 0;
        final int ydayPro =
            (yday?['pro_rides_completed'] as num?)?.toInt() ?? 0;
        final perRide = (m['amount_per_pro_ride'] as num?)?.toDouble() ?? 10.0;
        final double commission = todayPro * perRide;

        rows.add({
          'is_tl': false,
          'name': (m['name'] ?? m['referred_name'] ?? 'Captain').toString(),
          'vehicle_number': m['vehicle_number']?.toString(),
          'yesterday': ydayPro,
          'today': todayPro,
          'commission': commission,
        });
      }

      final mergedN = snapshot.mergedTeamMembers.length;
      final dashCount =
          (driverObj['referred_driver_count'] as num?)?.toInt() ?? 0;
      var teamSize = dashCount;
      if (mergedN > teamSize) teamSize = mergedN;
      final memberRows = rows.length - 1;
      if (memberRows > teamSize) teamSize = memberRows;

      final int totalTeamToday =
          rows.fold<int>(0, (sum, e) => sum + (e['today'] as int));
      final int totalTeamYesterday =
          rows.fold<int>(0, (sum, e) => sum + (e['yesterday'] as int));

      final earnTotal = ReferralEarningsCall.totalEarnings(earn);
      final lifetimeDash =
          ReferralDashboardCall.totalEarnings(dash);
      final int earningsTotal =
          earnTotal > 0 ? earnTotal : lifetimeDash;

      if (!mounted) return;
      setState(() {
        _tlName = driverObj['name']?.toString() ?? '';
        _referredByName = referredByObj.isNotEmpty
            ? referredByObj['name']?.toString()
            : null;
        _teamSize = teamSize;
        _totalProRidesToday = totalTeamToday;
        _totalProRidesYesterday = totalTeamYesterday;
        _totalTeamEarnings = '₹$earningsTotal';
        _rows = rows;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_referredByName != null && _referredByName!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.handshake_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Referred by $_referredByName',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            _tlName.isEmpty ? 'My Team' : _tlName,
            style: GoogleFonts.interTight(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  label: 'Pro rides (today · all)',
                  value: '$_totalProRidesToday',
                  icon: Icons.directions_car_filled_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  label: 'Referral earnings',
                  value: _totalTeamEarnings,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Captains on your team: $_teamSize  ·  Pro rides yesterday (sum): $_totalProRidesYesterday',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralTile(dynamic referral) {
    final data = referral as Map<String, dynamic>;
    final name = (data['name'] ?? 'Unknown').toString();
    final isTl = data['is_tl'] == true;
    final vehicleNo = (data['vehicle_number'] ?? '—').toString();
    final yesterday = data['yesterday'] as int? ?? 0;
    final today = data['today'] as int? ?? 0;
    final double commission = (data['commission'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.account_circle,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isTl ? '$name (TL)' : name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: isTl ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              vehicleNo,
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$yesterday',
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$today',
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${commission.toStringAsFixed(0)}',
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: commission > 0 ? FontWeight.w600 : FontWeight.w400,
                color: commission > 0
                    ? FlutterFlowTheme.of(context).success
                    : FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No team members yet',
        style: GoogleFonts.inter(
          color: FlutterFlowTheme.of(context).secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}
