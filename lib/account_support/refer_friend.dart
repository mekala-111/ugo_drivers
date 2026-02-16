import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReferFriendWidget extends StatefulWidget {
  const ReferFriendWidget({super.key});

  static String routeName = 'ReferFriend';
  static String routePath = '/referFriend';

  @override
  State<ReferFriendWidget> createState() => _ReferFriendWidgetState();
}

class _ReferFriendWidgetState extends State<ReferFriendWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _referralCode = '';
  String _errorMessage = '';

  // Ugo Brand Colors
  final Color ugoOrange = const Color(0xFFFF7B10);
  final Color ugoOrangeLight = const Color(0xFFFF9E4D);

  @override
  void initState() {
    super.initState();
    _fetchReferralCode();
  }

  /// Fetch referral code from backend
  Future<void> _fetchReferralCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      if (driverId == 0 || token.isEmpty) {
        setState(() {
          _errorMessage = 'Please login first';
          _isLoading = false;
        });
        return;
      }

      final response = await DriverIdfetchCall.call(
        id: driverId,
        token: token,
      );

      bool isSuccess = response.succeeded;

      if (isSuccess) {
        final referralCode = DriverIdfetchCall.referralCode(response.jsonBody);
        if (referralCode != null && referralCode.isNotEmpty) {
          setState(() {
            _referralCode = referralCode;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No referral code found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch referral code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Copy referral code to clipboard
  Future<void> _copyToClipboard() async {
    if (_referralCode.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _referralCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                FFLocalizations.of(context).getVariableText(
                  enText: 'Copied to clipboard!',
                  hiText: 'क्लिपबोर्ड पर कॉपी किया गया!',
                  teText: 'క్లిప్‌బోర్డ్‌కు కాపీ చేయబడింది!',
                ),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: ugoOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// 🚀 Helper to generate the optimized share text
  String _getShareText() {
    // ✅ Updated share text as per your request (No Play Store link)
    return 'Join UGO Taxi using my referral code: $_referralCode\nDownload the app and start earning! 🚗💰';
  }

  /// Share Logic
  Future<void> _shareReferralCode() async {
    if (_referralCode.isEmpty) return;

    final shareText = _getShareText();

    // Use generic share sheet as default fallback
    final Uri smsUrl = Uri.parse('sms:?body=${Uri.encodeComponent(shareText)}');
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    }
  }

  Future<void> _shareViaWhatsApp() async {
    if (_referralCode.isEmpty) return;

    final shareText = _getShareText();
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(shareText)}');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp not installed')));
    }
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
        backgroundColor: const Color(0xFFF5F7FA), // Light grey background
        body: Stack(
          children: [
            // 1️⃣ VIBRANT HEADER BACKGROUND
            Container(
              height: 320,
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
              ),
            ),
            // Decorative Circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 2️⃣ MAIN CONTENT
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        FlutterFlowIconButton(
                          borderColor: Colors.white.withValues(alpha: 0.3),
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 45.0,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.0),
                          onPressed: () => context.pop(),
                        ),
                        const Expanded(
                          child: Text(
                            "Refer & Earn",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 45), // Balance the back button
                      ],
                    ),
                  ),

                  // Header Text
                  const SizedBox(height: 10),
                  Text(
                    "Invite Friends,\nGet Rewards!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Earn when your friend completes their first ride.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3️⃣ SCROLLABLE CARD AREA
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: Colors.white))
                        : _errorMessage.isNotEmpty
                        ? _buildErrorView()
                        : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // 🎟️ COUPON CARD
                            _buildReferralCard(),

                            const SizedBox(height: 24),

                            // 📢 SOCIAL SHARE BUTTONS
                            Text(
                              "Share via",
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialButton(
                                  icon: FontAwesomeIcons.whatsapp,
                                  color: const Color(0xFF25D366),
                                  label: "WhatsApp",
                                  onTap: _shareViaWhatsApp,
                                ),
                                const SizedBox(width: 20),
                                _socialButton(
                                  icon: FontAwesomeIcons.solidMessage,
                                  color: const Color(0xFF3B5998),
                                  label: "Message",
                                  onTap: _shareReferralCode,
                                ),
                                const SizedBox(width: 20),
                                _socialButton(
                                  icon: Icons.share_rounded,
                                  color: ugoOrange,
                                  label: "More",
                                  onTap: _shareReferralCode,
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // ℹ️ HOW IT WORKS
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "How it works",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStepRow("1", "Invite your friends", "Share your code via WhatsApp or SMS."),
                                  _buildConnectorLine(),
                                  _buildStepRow("2", "They register", "They sign up using your referral code."),
                                  _buildConnectorLine(),

                                  // ✅ UPDATED STEP 3: Specific amount
                                  _buildStepRow(
                                      "3",
                                      "You earn rewards",
                                      "Get paid ₹10 for every Pro ride completed by the friends."
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  // 🔹 WIDGET: Coupon Card
  Widget _buildReferralCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  "YOUR REFERRAL CODE",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _copyToClipboard,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6), // Light Orange bg
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ugoOrange.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _referralCode,
                          style: GoogleFonts.robotoMono(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: ugoOrange,
                          ),
                        ),
                        Row(
                          children: [
                            Container(width: 1, height: 24, color: ugoOrange.withValues(alpha: 0.3)),
                            const SizedBox(width: 16),
                            Icon(Icons.copy_rounded, color: ugoOrange, size: 22),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dotted Divider
          Row(
            children: [
              const SizedBox(width: 10), // Notch left
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ),
              const SizedBox(width: 10), // Notch right
            ],
          ),

          // Bottom Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Share this code with your friends",
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 WIDGET: Social Button
  Widget _socialButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: FaIcon(icon, color: color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 🔹 WIDGET: Step Row
  Widget _buildStepRow(String number, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E6),
            shape: BoxShape.circle,
            border: Border.all(color: ugoOrange.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: ugoOrange),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        )
      ],
    );
  }

  // 🔹 WIDGET: Connector Line
  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
      width: 2,
      height: 20,
      color: Colors.grey[200],
    );
  }

  // 🔹 WIDGET: Error View
  Widget _buildErrorView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 40),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            FFButtonWidget(
              onPressed: _fetchReferralCode,
              text: "Retry",
              options: FFButtonOptions(
                width: 100,
                height: 40,
                padding: EdgeInsets.zero,
                color: ugoOrange,
                textStyle: const TextStyle(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}