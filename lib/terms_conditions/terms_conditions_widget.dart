import '../constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_conditions_model.dart';
export 'terms_conditions_model.dart';

/// Terms and Conditions page for UGO Driver App (Play Store compliance)
class TermsConditionsWidget extends StatefulWidget {
  const TermsConditionsWidget({super.key});

  static String routeName = 'terms_conditions';
  static String routePath = '/terms-conditions';

  @override
  State<TermsConditionsWidget> createState() => _TermsConditionsWidgetState();
}

class _TermsConditionsWidgetState extends State<TermsConditionsWidget> {
  late TermsConditionsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsConditionsModel());
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
          'Terms & Conditions',
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
            _buildSection('Last Updated', 'These Terms and Conditions were last updated and are effective as of the date displayed in the app.'),
            _buildSection('1. Acceptance of Terms', 'By downloading, installing, or using the UGO Driver App ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, you may not use the App or provide driver services through UGO.'),
            _buildSection('2. Eligibility', 'To use the App as a driver, you must: (a) be at least 18 years of age; (b) hold a valid driving license; (c) have appropriate vehicle registration, insurance, and other documents as required by law; (d) meet all eligibility criteria set by UGO and applicable authorities; (e) not have been previously deactivated from the UGO platform.'),
            _buildSection('3. Service Description', 'UGO provides a technology platform that connects drivers with riders seeking transportation services. You act as an independent contractor when providing ride services. UGO does not employ you and is not responsible for your conduct, vehicle, or the quality of services you provide.'),
            _buildSection('4. Driver Obligations', 'You agree to: (a) provide accurate and complete information during registration; (b) maintain valid licenses and documents at all times; (c) provide safe, professional, and courteous service; (d) comply with all applicable traffic and motor vehicle laws; (e) maintain your vehicle in good condition; (f) not discriminate against riders; (g) handle rider data and payments in accordance with our policies.'),
            _buildSection('5. Earnings and Payments', 'Earnings for completed rides will be calculated as per the prevailing fare structure. Payments are subject to verification and may be withheld in case of disputes, fraud, or policy violations. You are responsible for any taxes applicable to your earnings. UGO may deduct applicable commissions, fees, or charges as per the agreed terms.'),
            _buildSection('6. Prohibited Conduct', 'You may not: (a) use the App for any unlawful purpose; (b) accept rides under the influence of alcohol or drugs; (c) harass, threaten, or harm riders or others; (d) share your account or credentials; (e) manipulate the App or location data; (f) engage in fraud or misuse of the platform.'),
            _buildSection('7. Account Termination', 'UGO reserves the right to suspend or terminate your account at any time for violation of these terms, fraudulent activity, safety concerns, or at its discretion. You may terminate your account by following the in-app process. Upon termination, your right to use the App ceases immediately.'),
            _buildSection('8. Intellectual Property', 'The App, including its design, logos, and content, is owned by UGO or its licensors. You may not copy, modify, or distribute any part of the App without prior written permission.'),
            _buildSection('9. Limitation of Liability', 'To the maximum extent permitted by law, UGO and its affiliates shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the App or provision of services. Our total liability shall not exceed the amount you earned through the App in the preceding twelve months.'),
            _buildSection('10. Privacy', 'Your use of the App is also governed by our Privacy Policy. By using the App, you consent to the collection, use, and disclosure of your information as described in the Privacy Policy.'),
            _buildSection('11. Changes to Terms', 'UGO may modify these Terms at any time. We will notify you of material changes through the App or by other reasonable means. Continued use of the App after such changes constitutes acceptance of the updated Terms.'),
            _buildSection('12. Governing Law', 'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts in the applicable territory.'),
            _buildSection('13. Contact', 'For questions about these Terms and Conditions, please contact us through the in-app support feature or at the contact details provided in the App.'),
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
