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
  static const String _deleteAccountUrl =
      'https://ugotaxi.com/driver-delete-account.html';

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
          if (driverRating == 'null' || driverRating.isEmpty) {
            driverRating = '5.0';
          }

          // 2. Calculate Years from 'created_at'
          if (data['created_at'] != null) {
            try {
              DateTime createdDate =
                  DateTime.parse(data['created_at'].toString());
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
        title: Text(FFLocalizations.of(context).getText('accsup0016')),
        content: Text(
          FFLocalizations.of(context).getText('accsup0017'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(FFLocalizations.of(context).getText('accsup0018')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _brandPrimary),
            child: Text(FFLocalizations.of(context).getText('accsup0016')),
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
        title: Text(
          FFLocalizations.of(context).getText('accsup0019'),
          style: const TextStyle(
              color: AppColors.errorDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          FFLocalizations.of(context).getText('accsup0020'),
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(FFLocalizations.of(context).getText('accsup0018')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(FFLocalizations.of(context).getText('accsup0019')),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FFLocalizations.of(context).getText('accsup0021')),
          backgroundColor: Colors.green,
        ));
      } else {
        setState(() => _isDeletingAccount = false);
        final err =
            getJsonField(res.jsonBody ?? {}, r'$.error')?.toString() ?? '';
        final msg =
            getJsonField(res.jsonBody ?? {}, r'$.message')?.toString() ??
                FFLocalizations.of(context).getText('accsup0022');
        final isFkError = err.toLowerCase().contains('foreign key') ||
            err.toLowerCase().contains('constraint');
        final userMsg =
            isFkError ? FFLocalizations.of(context).getText('accsup0023') : msg;
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
          content: Text(
            '${FFLocalizations.of(context).getText('accsup0024')}${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  String getDriverName() {
    if (driverData == null) {
      return FFLocalizations.of(context).getText('accsup0025');
    }
    final firstName = driverData!['first_name'] ?? '';
    final lastName = driverData!['last_name'] ?? '';
    return '$firstName $lastName'.trim().isEmpty
        ? FFLocalizations.of(context).getText('accsup0025')
        : '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWhite = Colors.white;
    const Color bgGrey = AppColors.backgroundAlt;

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final topInset = media.padding.top;
    final isSmall = width < 360;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 32.0 : (isSmall ? 12.0 : 16.0);
    final headerHeight = (height * 0.25).clamp(160.0, 220.0);
    final profileSize = isTablet ? 120.0 : (isSmall ? 96.0 : 110.0);
    final profileInnerSize = profileSize - 10.0;
    final profileBottom = isSmall ? -42.0 : -50.0;
    final titleSize = isTablet ? 22.0 : (isSmall ? 18.0 : 20.0);
    final nameSize = isTablet ? 22.0 : (isSmall ? 18.0 : 20.0);
    final buttonHeight = isSmall ? 46.0 : 50.0;
    final contentMaxWidth = isTablet ? 640.0 : double.infinity;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgWhite,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandPrimary))
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
                            height: headerHeight,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGradientStart,
                                  AppColors.primary
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: SafeArea(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(isSmall ? 12.0 : 16.0),
                                  child: InkWell(
                                    onTap: () => context
                                        .pushNamed(SupportWidget.routeName),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmall ? 10 : 12,
                                        vertical: isSmall ? 4 : 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.headset_mic_rounded,
                                              color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            FFLocalizations.of(context)
                                                .getText('accsup0001'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
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
                            top: topInset + (isSmall ? 8.0 : 12.0),
                            left: horizontalPadding,
                            right: horizontalPadding,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => context.pop(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: isSmall ? 24 : 28,
                                  ),
                                ),
                                SizedBox(width: isSmall ? 10 : 16),
                                Expanded(
                                  child: Text(
                                    FFLocalizations.of(context)
                                        .getText('accsup0002'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmall ? 72.0 : 96.0),
                              ],
                            ),
                          ),

                          // Profile Picture (Overlapping)
                          // Profile Picture + Edit Button
                          Positioned(
                            bottom: profileBottom,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque, // IMPORTANT
                              onTap: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                        driverData: driverData!),
                                  ),
                                );

                                if (updated == true) {
                                  fetchDriverDetails();
                                }
                              },
                              child: SizedBox(
                                width: profileSize,
                                height: profileSize,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: profileInnerSize,
                                      height: profileInnerSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            profileInnerSize / 2),
                                        child:
                                            driverData?['profile_image'] != null
                                                ? CachedNetworkImage(
                                                    imageUrl: getFullImageUrl(
                                                        driverData![
                                                            'profile_image']),
                                                    fit: BoxFit.cover,
                                                    errorWidget: (_, __, ___) =>
                                                        const Icon(Icons.person,
                                                            size: 50),
                                                  )
                                                : const Icon(Icons.person,
                                                    size: 50),
                                      ),
                                    ),

                                    // Pencil (visual only)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(isSmall ? 5 : 6),
                                        decoration: const BoxDecoration(
                                          color: _brandPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          size: isSmall ? 16 : 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmall ? 52 : 60),

                      // Name
                      Text(
                        getDriverName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                            fontSize: nameSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // 2️⃣ STATS ROW (Rapido Captain style)
                      // ==========================================
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 12 : 16,
                          horizontal: isSmall ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: bgGrey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stackStats = constraints.maxWidth < 320;
                            if (stackStats) {
                              return Column(
                                children: [
                                  _buildStatItem(
                                    driverRating,
                                    FFLocalizations.of(context)
                                        .getText('accsup0003'),
                                    Icons.star_rounded,
                                    isSmall: isSmall,
                                    isTablet: isTablet,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatItem(
                                    "${driverData?['total_rides_completed'] ?? 0}",
                                    FFLocalizations.of(context)
                                        .getText('accsup0004'),
                                    Icons.local_taxi_rounded,
                                    isSmall: isSmall,
                                    isTablet: isTablet,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatItem(
                                    driverYears,
                                    FFLocalizations.of(context)
                                        .getText('accsup0005'),
                                    Icons.calendar_today_rounded,
                                    isSmall: isSmall,
                                    isTablet: isTablet,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  driverRating,
                                  FFLocalizations.of(context)
                                      .getText('accsup0003'),
                                  Icons.star_rounded,
                                  isSmall: isSmall,
                                  isTablet: isTablet,
                                ),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.grey[300]),
                                _buildStatItem(
                                  "${driverData?['total_rides_completed'] ?? 0}",
                                  FFLocalizations.of(context)
                                      .getText('accsup0004'),
                                  Icons.local_taxi_rounded,
                                  isSmall: isSmall,
                                  isTablet: isTablet,
                                ),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.grey[300]),
                                _buildStatItem(
                                  driverYears,
                                  FFLocalizations.of(context)
                                      .getText('accsup0005'),
                                  Icons.calendar_today_rounded,
                                  isSmall: isSmall,
                                  isTablet: isTablet,
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // 3️⃣ MENU LIST (Rapido Captain style)
                      // ==========================================
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.description_outlined,
                              title: FFLocalizations.of(context)
                                  .getText('accsup0006'),
                              subtitle: FFLocalizations.of(context)
                                  .getText('accsup0007'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DocumentsScreen()),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuItem(
                              icon: Icons.edit_location_alt_outlined,
                              title: FFLocalizations.of(context)
                                  .getText('accsup0008'),
                              subtitle: FFLocalizations.of(context)
                                  .getText('accsup0009'),
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
                              title: FFLocalizations.of(context)
                                  .getText('accsup0010'),
                              subtitle: FFLocalizations.of(context)
                                  .getText('accsup0011'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ReferFriendWidget()),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuItem(
                              icon: Icons.description_outlined,
                              title: FFLocalizations.of(context)
                                  .getText('accsup0012'),
                              subtitle: FFLocalizations.of(context)
                                  .getText('accsup0013'),
                              onTap: () => context
                                  .pushNamed(TermsConditionsWidget.routeName),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuItem(
                              icon: Icons.privacy_tip_outlined,
                              title: FFLocalizations.of(context)
                                  .getText('accsup0014'),
                              subtitle: FFLocalizations.of(context)
                                  .getText('accsup0015'),
                              onTap: () => context
                                  .pushNamed(PrivacyPolicyPageWidget.routeName),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: OutlinedButton.icon(
                                onPressed: _isLoggingOut ? null : _logout,
                                icon: _isLoggingOut
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.power_settings_new,
                                        color: Colors.black87),
                                label: Text(
                                  _isLoggingOut
                                      ? FFLocalizations.of(context)
                                          .getText('accsup0026')
                                      : FFLocalizations.of(context)
                                          .getText('accsup0016'),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.black54, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isDeletingAccount ? null : _deleteAccount,
                                icon: _isDeletingAccount
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.delete_outline,
                                        color: Colors.white),
                                label: Text(
                                  _isDeletingAccount
                                      ? FFLocalizations.of(context)
                                          .getText('accsup0027')
                                      : FFLocalizations.of(context)
                                          .getText('accsup0019'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.errorCritical,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
              ),
            ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon, {
    bool isSmall = false,
    bool isTablet = false,
  }) {
    final valueSize = isTablet ? 22.0 : (isSmall ? 18.0 : 20.0);
    final labelSize = isTablet ? 13.0 : (isSmall ? 11.0 : 12.0);
    final iconSize = isTablet ? 24.0 : (isSmall ? 20.0 : 22.0);

    return Column(
      children: [
        Icon(icon, color: _brandPrimary, size: iconSize),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: labelSize,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
