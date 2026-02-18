import 'package:ugo_driver/teamearning/all_orders_widget.dart';
import 'package:ugo_driver/teamearning/last_order_widget.dart';
import 'package:ugo_driver/teamearning/view_rate_card_widget.dart';

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teamearning_model.dart';
export 'teamearning_model.dart';

class TeamearningWidget extends StatefulWidget {
  const TeamearningWidget({super.key});

  static String routeName = 'teamearning';
  static String routePath = '/teamearning';

  @override
  State<TeamearningWidget> createState() => _TeamearningWidgetState();
}

class _TeamearningWidgetState extends State<TeamearningWidget>
    with SingleTickerProviderStateMixin {
  late TeamearningModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Data Variables - All Earnings
  String todaysEarnings = "₹0";
  bool isLoading = true;

  // Data Variables - Team Earnings
  String teamEarnings = "₹0";
  String totalReferrals = "0";
  List<dynamic> referredDrivers = [];
  bool isLoadingTeam = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamearningModel());
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarningsData();
    _fetchTeamData(); // ✅ Fetch Team Data
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
      period: "all",   // ✅ IMPORTANT
    );

    if (response.succeeded) {
      final data = response.jsonBody['data'];

      setState(() {
        todaysEarnings =
            "₹${(data['totalEarnings'] ?? 0).toString()}";
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("Error fetching total earnings: $e");
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
    const Color brand = Color(0xFFFF7B10);
    const Color bgGrey = Color(0xFFF5F7FA);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "Earnings",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: brand,
              unselectedLabelColor: Colors.grey,
              indicatorColor: brand,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "All Earnings"),
                Tab(text: "Team Earnings"), // ✅ Renamed Tab
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ------------------------------------------------
          // 1️⃣ ALL EARNINGS TAB (Existing)
          // ------------------------------------------------
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text("Total Earnings", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 8),
                Text(todaysEarnings, style: GoogleFonts.inter(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Divider(thickness: 8, color: bgGrey),
                _buildMenuItem(Icons.receipt_long_rounded, icon: Icons.receipt_long_rounded, title: "All Rides", subtitle: "Ride History and Ride Earnings", onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AllOrdersScreen()),
  );
}),
                _buildDivider(),
                _buildMenuItem(Icons.history, icon: Icons.history, title: "Last Ride Earnings", subtitle: "View recent trip earnings", onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LastOrderWidget()),
  );
}),

                _buildDivider(),
                _buildMenuItem(Icons.currency_rupee_rounded, icon: Icons.currency_rupee_rounded, title: "View Rate Card", subtitle: null, onTap: (){
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => const RateCardWidget()),
   );
 },),
              ],
            ),
          ),

          // ------------------------------------------------
          // 2️⃣ TEAM EARNINGS TAB (New)
          // ------------------------------------------------
          isLoadingTeam
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // 💰 Total Team Earnings
                Text("Total Team Earnings", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 8),
                Text(teamEarnings, style: GoogleFonts.inter(color: Colors.green[700], fontSize: 40, fontWeight: FontWeight.bold)),

                const SizedBox(height: 24),

                // 📊 Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTeamStat("Active Drivers", totalReferrals, Icons.group),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildTeamStat("Commission", "5%", Icons.percent), // Static or from API
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Divider(thickness: 8, color: bgGrey),

                // 👥 Team List Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_2_rounded, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text("Your Team ($totalReferrals)", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // 📜 Team List
                if (referredDrivers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_add_disabled, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text("No team members yet", style: GoogleFonts.inter(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: referredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = referredDrivers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            (driver['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(driver['name'] ?? 'Unknown Driver', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text("Joined: ${driver['joined_at'] ?? 'N/A'}", style: GoogleFonts.inter(fontSize: 12)),
                        trailing: Text(
                          "₹${driver['earnings_generated'] ?? '0'}",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem(IconData history, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha:0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.blue.shade700, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 70, endIndent: 0, color: Color(0xFFEEEEEE));
  }
}