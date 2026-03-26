import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
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
  String _teamEarnings = '₹0';
  String _coins = '0';
  String _successfulReferrals = '0';
  List<dynamic> _referredDetails = [];

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
            FFLocalizations.of(context).getText(
              'xfnx6i08' /* My Team */,
            ),
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
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildSummary(),
                    Expanded(
                      child: _referredDetails.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                              itemCount: _referredDetails.length,
                              itemBuilder: (context, index) =>
                                  _buildReferralTile(_referredDetails[index]),
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
      final response = await ReferralEarningsCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (!response.succeeded) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final body = response.jsonBody;
      final total = ReferralEarningsCall.totalEarnings(body);
      final coins = ReferralEarningsCall.totalCoinsEarned(body);
      final successCount = ReferralEarningsCall.successfulReferralsCount(body);
      final details = ReferralEarningsCall.referredDetails(body);

      if (!mounted) return;
      setState(() {
        _teamEarnings = '₹$total';
        _coins = '$coins';
        _successfulReferrals = '$successCount';
        _referredDetails = details;
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
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Earnings',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _teamEarnings,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  label: 'Successful',
                  value: _successfulReferrals,
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  label: 'Coins',
                  value: _coins,
                  icon: Icons.monetization_on_rounded,
                ),
              ),
            ],
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
    final name = (data['referred_name'] ?? data['name'] ?? 'Unknown').toString();
    final rewardAmount = data['reward_amount'] ?? 0;
    final rewardType = (data['reward_type'] ?? 'cash').toString();
    final code = (data['referral_code'] ?? '-').toString();
    final date = _formatDate(data['completion_date']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'R',
              style: GoogleFonts.interTight(
                color: FlutterFlowTheme.of(context).primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$rewardType • Code: $code',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹$rewardAmount',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).success,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No referral earnings yet',
        style: GoogleFonts.inter(
          color: FlutterFlowTheme.of(context).secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('dd MMM yyyy, h:mm a').format(parsed.toLocal());
  }
}
