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
          offset: Offset(0, 30 * (1 - value)), // Slides up smoothly
          child: Opacity(
            opacity: value,
            child: child,
          ),
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
  String todaysEarnings = '₹0';
  bool isLoading = true;

  // Data Variables - Team Earnings
  String teamEarnings = '₹0';
  String totalReferrals = '0';
  List<dynamic> referredDrivers = [];
  bool isLoadingTeam = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamEarningsModel());
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarningsData();
    _fetchTeamData();
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 1. Fetch General Earnings
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
  Future<void> _fetchTeamData() async {
    setState(() => isLoadingTeam = true);
    try {
      final response = await ReferralDashboardCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (response.succeeded) {
        final data = getJsonField(response.jsonBody, r'''$.data''');
        final summary = data['referral_summary'] ?? {};
        setState(() {
          teamEarnings = "₹${summary['total_referral_earnings'] ?? '0'}";
          totalReferrals = "${summary['total_referred_drivers'] ?? '0'}";
          referredDrivers = data['referred_drivers_detailed'] ?? [];
          isLoadingTeam = false;
        });
      } else {
        setState(() => isLoadingTeam = false);
      }
    } catch (e) {
      setState(() => isLoadingTeam = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brand = AppColors.primary;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FB), // Soft off-white for contrast
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
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
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
         
          isLoading
              ? const Center(child: CircularProgressIndicator(color: brand))
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Animated Header Card
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

                // Animated Menu Items
                AnimatedListItem(
                  index: 1,
                  child: _buildPremiumMenuItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'All Rides',
                    subtitle: 'Ride History and Ride Earnings',
                    color: const Color(0xFF4A90E2),
                    onTap: () => context.pushNamed(AllOrdersScreen.routeName),
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
                    onTap: () => context.pushNamed(LastOrderWidget.routeName),
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RateCardWidget()));
                    },
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------
          // 2️⃣ TEAM EARNINGS TAB
          // ------------------------------------------------
          isLoadingTeam
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            child: Column(
              children: [
                // Header & Floating Stats
                AnimatedListItem(
                  index: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildGradientEarningsCard(
                          title: 'Total Team Earnings',
                          amount: teamEarnings,
                          colors: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
                          shadowColor: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                          icon: Icons.groups_rounded,
                          bottomPadding: 60, // Extra space for floating card
                        ),
                      ),
                      // Floating Stats Box
                      Positioned(
                        bottom: -25,
                        child: Container(
                          width: MediaQuery.sizeOf(context).width - 60,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTeamStat('Active Drivers', totalReferrals, Icons.group_rounded, brand),
                              Container(width: 1, height: 40, color: Colors.grey.shade200),
                              _buildTeamStat('Commission', '5%', Icons.percent_rounded, const Color(0xFFE74C3C)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_alt_rounded, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Your Team ($totalReferrals)',
                          style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),

                // Team List
                if (referredDrivers.isEmpty)
                  AnimatedListItem(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No team members yet.',
                            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Share your referral code to start earning!',
                            style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: referredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = referredDrivers[index];
                      return AnimatedListItem(
                        index: index + 2, // stagger after header
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFFD4B2), Color(0xFFFFE0B2)]),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  (driver['name'] ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.inter(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                            title: Text(driver['name'] ?? 'Unknown Driver', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                            subtitle: Text("Joined: ${driver['joined_at'] ?? 'N/A'}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${driver['earnings_generated'] ?? '0'}",
                                  style: GoogleFonts.interTight(fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71), fontSize: 16),
                                ),
                                Text("Generated", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade400)),
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

  // --- WIDGET BUILDERS ---

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
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.interTight(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor.withValues(alpha: 0.7), size: 22),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.interTight(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                      Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}