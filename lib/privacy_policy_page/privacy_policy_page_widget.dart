import '../constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'privacy_policy_page_model.dart';
export 'privacy_policy_page_model.dart';

/// Privacy Policy page for UGO Driver App (Play Store compliance)
class PrivacyPolicyPageWidget extends StatefulWidget {
  const PrivacyPolicyPageWidget({super.key});

  static String routeName = 'privacy_policy_page';
  static String routePath = '/privacy-policy';

  @override
  State<PrivacyPolicyPageWidget> createState() => _PrivacyPolicyPageWidgetState();
}

class _PrivacyPolicyPageWidgetState extends State<PrivacyPolicyPageWidget> {
  late PrivacyPolicyPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyPolicyPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Last Updated', 'This Privacy Policy was last updated and is effective as of the date displayed in the app. By using the UGO Driver App, you consent to the practices described below.'),
            _buildSection('1. Information We Collect', 'We collect information you provide directly, including: name, phone number, email, profile photo, driving license details, vehicle information, bank account details for payments, and documents such as RC, PAN, and insurance. We also collect location data when the app is in use to match you with riders and for ride tracking. Device information such as device type, operating system, and unique identifiers may be collected for app functionality and security.'),
            _buildSection('2. How We Use Your Information', 'We use your information to: provide and improve our services; verify your identity and documents; process payments and earnings; connect you with riders; ensure safety and resolve disputes; send service-related notifications; comply with legal obligations; and improve our app and user experience.'),
            _buildSection('3. Information Sharing', 'We may share your information with: riders during and after rides (name, photo, vehicle details, location); payment and banking partners for processing; service providers who assist our operations; law enforcement or authorities when required by law; and our affiliates for providing services. We do not sell your personal information to third parties.'),
            _buildSection('4. Data Retention', 'We retain your information for as long as your account is active and as needed to provide services. After account deletion, we may retain certain information for legal compliance, dispute resolution, and legitimate business purposes as permitted by law.'),
            _buildSection('5. Account Deletion', 'You can request deletion from within the app (Account > Delete Account). You can also review the full deletion steps and support contact options at https://ugotaxi.com/driver-delete-account.html.'),
            _buildSection('6. Data Security', 'We implement technical and organizational measures to protect your data, including encryption, secure transmission, and access controls. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.'),
            _buildSection('7. Your Rights', 'Depending on your location, you may have the right to: access your personal data; correct inaccurate data; request deletion of your data; object to or restrict certain processing; data portability; and withdraw consent. You can exercise these rights through the app settings or by contacting us. In India, you may also have rights under applicable data protection laws.'),
            _buildSection('8. Location Data', 'We collect location data when you use the app to provide ride services. This is essential for matching with riders, navigation, and ride tracking. If you choose to go online, we may collect location in the background to reliably match you with ride requests and to maintain trip safety. You can control location permissions in your device settings, but disabling location may limit app functionality.'),
            _buildSection('9. Display Over Other Apps (Floating Bubble)', 'UGO Driver uses an optional floating bubble to show ride requests when you are using other apps. This requires the “Display over other apps” permission and can be turned off anytime in your device settings.'),
            _buildSection('10. Children\'s Privacy', 'The UGO Driver App is not intended for users under 18 years of age. We do not knowingly collect information from children. If you believe we have collected data from a minor, please contact us to have it removed.'),
            _buildSection('11. Changes to This Policy', 'We may update this Privacy Policy from time to time. We will notify you of material changes through the app or by other reasonable means. Your continued use of the App after such changes constitutes acceptance of the updated Policy.'),
            _buildSection('12. Contact Us', 'For questions about this Privacy Policy or your personal data, please contact us through the in-app support feature or at the contact details provided in the App.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
