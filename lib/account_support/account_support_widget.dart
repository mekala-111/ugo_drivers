import 'package:ugo_driver/account_support/edit_profile.dart';
import 'package:ugo_driver/account_support/refer_friend.dart';

import '/backend/api_requests/api_calls.dart';
import '/config.dart' as app_config;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ugo_driver/account_support/documents.dart';
import 'package:ugo_driver/account_support/edit_address.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account_support_model.dart';
export 'account_support_model.dart';

class AccountSupportWidget extends StatefulWidget {
  const AccountSupportWidget({super.key});

  static String routeName = 'Account_support';
  static String routePath = '/accountSupport';

  @override
  State<AccountSupportWidget> createState() => _AccountSupportWidgetState();
}

class _AccountSupportWidgetState extends State<AccountSupportWidget> {
  late AccountSupportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _brandPrimary = AppColors.primary;

  Map<String, dynamic>? driverData;
  bool isLoading = true;
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  static const String _deleteAccountUrl = 'https://ugotaxi.com/driver-delete-account.html';

  // Stats Variables
  String driverRating = '5.0'; // Default to 5.0 to avoid "null"
  String driverYears = '0.0';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountSupportModel());
    fetchDriverDetails();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> fetchDriverDetails() async {
    setState(() => isLoading = true);

    try {
      final response = await DriverIdfetchCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
      );

      if (response.succeeded) {
        final data = DriverIdfetchCall.driverData(response.jsonBody);

        setState(() {
          driverData = data;

          // 1. Get Rating
          driverRating = data['driver_rating']?.toString() ?? '5.0';
          if (driverRating == 'null' || driverRating.isEmpty) driverRating = '5.0';

          // 2. Calculate Years from 'created_at'
          if (data['created_at'] != null) {
            try {
              DateTime createdDate = DateTime.parse(data['created_at'].toString());
              DateTime now = DateTime.now();
              double years = now.difference(createdDate).inDays / 365.0;
              if (years < 0.1) years = 0.1;
              driverYears = years.toStringAsFixed(1);
            } catch (e) {
              driverYears = '0.1';
            }
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // String getFullImageUrl(String? imagePath) {
  //   if (imagePath == null || imagePath.isEmpty) return '';
  //   if (imagePath.startsWith('http')) return imagePath;
  //   const String baseUrl = 'https://ugo-api.icacorp.org';
  //   String cleanPath = imagePath.startsWith('uploads/') ? imagePath.substring(8) : imagePath;
  //   return '$baseUrl/$cleanPath';
  // }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return app_config.Config.fullImageUrl(imagePath) ?? imagePath;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Logout - clear state and navigate to login (Rapido-style)
  Future<void> _logout() async {
    if (_isLoggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to receive ride requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _brandPrimary),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    await FFAppState().clearAppState();
    if (!mounted) return;
    context.go(LoginWidget.routePath);
  }

  /// Delete account - call API, clear state, navigate to login
  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: AppColors.errorDark, fontWeight: FontWeight.bold)),
        content: const Text(
          'This action cannot be undone. All your data including ride history, earnings, and documents will be permanently deleted.\n\nAre you sure you want to delete your account?',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isDeletingAccount = true);
    try {
      final res = await DeleteDriverCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
      );
      if (!mounted) return;
      if (res.succeeded) {
        await FFAppState().clearAppState();
        if (!mounted) return;
        context.go(LoginWidget.routePath);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        setState(() => _isDeletingAccount = false);
        final err = getJsonField(res.jsonBody ?? {}, r'$.error')?.toString() ?? '';
        final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString() ?? 'Failed to delete account';
        final isFkError = err.toLowerCase().contains('foreign key') || err.toLowerCase().contains('constraint');
        final userMsg = isFkError
            ? 'Account deletion is not available. Your account has linked data. Please contact support.'
            : msg;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(userMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }


  String getDriverName() {
    if (driverData == null) return 'Driver Name';
    final firstName = driverData!['first_name'] ?? '';
    final lastName = driverData!['last_name'] ?? '';
    return '$firstName $lastName'.trim().isEmpty ? 'Driver Name' : '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWhite = Colors.white;
    const Color bgGrey = AppColors.backgroundAlt;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgWhite,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandPrimary))
          : SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1️⃣ HEADER SECTION
            // ==========================================
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Banner Background
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryGradientStart, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () => context.pushNamed(SupportWidget.routeName),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Help',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ FIXED: Back Button + "My Profile" Text
                Positioned(
                  top: 50,
                  left: 16,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Picture (Overlapping)
                // Profile Picture + Edit Button
                Positioned(
  bottom: -50,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque, // IMPORTANT
    onTap: () async {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditProfileScreen(driverData: driverData!),
        ),
      );

      if (updated == true) {
        fetchDriverDetails();
      }
    },
    child: SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: driverData?['profile_image'] != null
                  ? CachedNetworkImage(
                      imageUrl: getFullImageUrl(driverData!['profile_image']),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, size: 50),
                    )
                  : const Icon(Icons.person, size: 50),
            ),
          ),

          // Pencil (visual only)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: _brandPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  ),
),

              ],
            ),

            const SizedBox(height: 60),

            // Name
            Text(
              getDriverName(),
              style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 2️⃣ STATS ROW (Rapido Captain style)
            // ==========================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: bgGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(driverRating, 'Rating', Icons.star_rounded),
                  Container(width: 1, height: 36, color: Colors.grey[300]),
                  _buildStatItem("${driverData?['total_rides_completed'] ?? 0}", 'Trips', Icons.local_taxi_rounded),
                  Container(width: 1, height: 36, color: Colors.grey[300]),
                  _buildStatItem(driverYears, 'Years', Icons.calendar_today_rounded),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 3️⃣ MENU LIST (Rapido Captain style)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Documents',
                    subtitle: 'RC, DL, PAN & Insurance',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.edit_location_alt_outlined,
                    title: 'Edit Address',
                    subtitle: 'Update your address',
                    onTap: () {
                      if (driverData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAddressScreen(
                              driverData: driverData!,
                              onUpdate: () => fetchDriverDetails(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Refer & Earn',
                    subtitle: 'Invite friends, earn rewards',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReferFriendWidget()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Legal information',
                    onTap: () => context.pushNamed(TermsConditionsWidget.routeName),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => context.pushNamed(PrivacyPolicyPageWidget.routeName),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account Info',
                    subtitle: 'Steps and data retention',
                    onTap: () => _launchUrl(_deleteAccountUrl),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==========================================
            // 4️⃣ ACTION BUTTONS
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggingOut ? null : _logout,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.power_settings_new, color: Colors.black87),
                      label: Text(
                        _isLoggingOut ? 'Logging out...' : 'Logout',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black54, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isDeletingAccount ? null : _deleteAccount,
                      icon: _isDeletingAccount
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_outline, color: Colors.white),
                      label: Text(
                        _isDeletingAccount ? 'Deleting...' : 'Delete Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorCritical,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _brandPrimary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _brandPrimary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}