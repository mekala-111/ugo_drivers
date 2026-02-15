import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅ Added for WhatsApp Icon
import 'support_model.dart';
export 'support_model.dart';

class SupportWidget extends StatefulWidget {
  const SupportWidget({super.key});

  static String routeName = 'support';
  static String routePath = '/support';

  @override
  State<SupportWidget> createState() => _SupportWidgetState();
}

class _SupportWidgetState extends State<SupportWidget> {
  late SupportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SupportModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Could not launch $url");
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove '+' and spaces for WhatsApp URL
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = "https://wa.me/$cleanPhone";
    _launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 App Colors
    const Color brandPrimary = Color(0xFFFF7B10); // UGO Orange
    const Color bgWhite = Colors.white;
    const Color textDark = Color(0xFF1E293B);
    const Color textGrey = Color(0xFF64748B);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgWhite,
        appBar: AppBar(
          backgroundColor: brandPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 28.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Support Center",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // 🎧 Hero Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: brandPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.headset_mic_rounded,
                    size: 50,
                    color: brandPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 📢 Hero Text
              Text(
                "We are here to help!",
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "24/7 Customer support will be available soon.\nPlease contact the company directly for any queries or details.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textGrey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // 📞 Contact Cards
              _buildContactCard(
                icon: Icons.call_rounded,
                iconColor: Colors.blue,
                bgColor: Colors.blue.shade50,
                title: "Call Us",
                subtitle: "+91 9100088718",
                onTap: () => _launchUrl("tel:+919100088718"),
              ),

              const SizedBox(height: 16),

              _buildContactCard(
                icon: FontAwesomeIcons.whatsapp,
                iconColor: Colors.green,
                bgColor: Colors.green.shade50,
                title: "WhatsApp Us",
                subtitle: "Chat with support",
                onTap: () => _launchWhatsApp("919100088718"),
              ),

              const SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.email_rounded,
                iconColor: Colors.red,
                bgColor: Colors.red.shade50,
                title: "Email Us",
                subtitle: "ugocabservice@gmail.com",
                onTap: () => _launchUrl("mailto:ugocabservice@gmail.com"),
              ),

              const SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.language_rounded,
                iconColor: Colors.purple,
                bgColor: Colors.purple.shade50,
                title: "Visit Website",
                subtitle: "ugotaxi.com",
                onTap: () => _launchUrl("https://ugotaxi.com"),
              ),

              const SizedBox(height: 50),

              // Footer
              Text(
                "UGO Taxi Services",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}