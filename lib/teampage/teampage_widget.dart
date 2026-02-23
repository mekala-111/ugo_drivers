import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/constants/app_colors.dart';
import '/backend/api_requests/api_calls.dart';
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

  // Ugo Brand Colors
  final Color ugoOrange = AppColors.primary;
  final Color ugoOrangeLight = AppColors.primaryLight;
  final Color ugoGreen = AppColors.success;
  final Color ugoBlue = AppColors.accentBlue;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeampageModel());

    // Load data with a slight delay for animation effect
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReferralData());
  }

  Future<void> _loadReferralData() async {
    final response = await DriverMyReferralsCall.call(
      token: FFAppState().accessToken,
    );

    if (response.succeeded) {
      setState(() {
        _model.referralData = response.jsonBody;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
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
        backgroundColor: AppColors.backgroundAlt, // Light Grey Background
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: ugoOrange))
            : Stack(
          children: [
            // 1️⃣ HEADER BACKGROUND
            Container(
              height: 280,
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
                    color: ugoOrange.withValues(alpha:0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),

            // 2️⃣ CONTENT
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        FlutterFlowIconButton(
                          borderColor: Colors.white.withValues(alpha:0.3),
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 45.0,
                          fillColor: Colors.white.withValues(alpha:0.2),
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
                      ],
                    ),
                  ),

                  // Header Info (Summary)
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
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _model.referralData != null
                                  ? '${getJsonField(_model.referralData, r'$.data.total_referrals') ?? 0}'
                                  : '0',
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
                            color: Colors.white.withValues(alpha:0.2),
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
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3️⃣ STATS CARDS (Floating)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Row(
                        children: [
                          // Total Rides Card
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Referrals',
                              value: _model.referralData != null
                                  ? '${getJsonField(_model.referralData, r'$.data.total_referrals') ?? 0}'
                                  : '0',
                              icon: Icons.people_alt,
                              color: ugoBlue,
                              delay: 100,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Earnings Card
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Earnings',
                              value: _model.referralData != null
                                  ? '₹${getJsonField(_model.referralData, r'$.data.total_earnings') ?? 0}'
                                  : '₹0',
                              icon: Icons.account_balance_wallet,
                              color: ugoGreen,
                              delay: 200,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4️⃣ TEAM LIST SECTION
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
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
                          Text(
                            'My Referrals',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your referred drivers',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LIST BUILDER
                          Expanded(
                            child: _buildTeamList(),
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

  // 🔹 WIDGET: Animated Stat Card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double val, child) {
        return Transform.scale(
          scale: val,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha:0.2),
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
                      color: color.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔹 WIDGET: Team List
  Widget _buildTeamList() {
    final referrals = getJsonField(
        _model.referralData, r'$.data.referrals') as List?;

    if (referrals == null || referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No referrals found',
                style: GoogleFonts.inter(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: referrals.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final driver = referrals[index];
        final name = getJsonField(driver, r'$.name')?.toString() ?? 'Unknown';
        final mobile = getJsonField(driver, r'$.mobile_number')?.toString() ?? '';
        final status = getJsonField(driver, r'$.status')?.toString() ?? 'unknown';
        final amountPerRide =
            getJsonField(driver, r'$.amount_per_pro_ride') ?? 0;
        final createdAt =
            getJsonField(driver, r'$.created_at')?.toString() ?? '';
        final createdAtText = createdAt.isNotEmpty
            ? dateTimeFormat(
                'MMM d, yyyy',
                DateTime.tryParse(createdAt) ?? DateTime.now(),
              )
            : '-';

        // Staggered Animation
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, double val, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - val)),
              child: Opacity(
                opacity: val,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: ugoOrange.withValues(alpha:0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(
                              color: ugoOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: ugoBlue),
                                const SizedBox(width: 4),
                                Text(
                                  mobile.isNotEmpty ? mobile : 'No phone',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.verified,
                                    size: 14, color: ugoGreen),
                                const SizedBox(width: 4),
                                Text(
                                  '${status.toUpperCase()} • $createdAtText',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Earning
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PER RIDE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            '₹$amountPerRide',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ugoGreen,
                            ),
                          ),
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
}