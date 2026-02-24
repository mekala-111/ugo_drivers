import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ugo_driver/account_support/refer_friend.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/constants/app_colors.dart';
import '/constants/responsive.dart';

// ✅ Custom Staggered Animation Widget
class AnimatedMenuDrop extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedMenuDrop({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
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

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  String _name = 'Driver';
  String _image = '';
  String _rating = '';

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  Future<void> _loadDriver() async {
    final res = await DriverIdfetchCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      if (mounted) {
        setState(() {
          _name =
          '${DriverIdfetchCall.firstName(res.jsonBody)} ${DriverIdfetchCall.lastName(res.jsonBody)}';
          _image = DriverIdfetchCall.profileImage(res.jsonBody) ?? '';
          _rating = DriverIdfetchCall.driverRating(res.jsonBody) ?? '';
        });
      }
    }
  }

  String img(String path) =>
      path.startsWith('http') ? path : 'https://ugo-api.icacorp.org/$path';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB), // Soft, lovely background color
      child: Column(
        children: [
          /// 1. VIBRANT HEADER
          _buildPremiumHeader(context),

          /// 2. ANIMATED MENU LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                AnimatedMenuDrop(
                  index: 0,
                  child: _buildMenuTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: FFLocalizations.of(context).getText('menu0002'),
                    sub: FFLocalizations.of(context).getText('menu0003'),
                    route: AccountManagementWidget.routeName,
                    color: const Color(0xFF4A90E2), // Vibrant Blue
                  ),
                ),
                AnimatedMenuDrop(
                  index: 1,
                  child: _buildMenuTile(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: FFLocalizations.of(context).getText('menu0004'),
                    sub: FFLocalizations.of(context).getText('menu0005'),
                    route: TeamEarningsWidget.routeName,
                    color: const Color(0xFF2ECC71), // Vibrant Green
                  ),
                ),
                AnimatedMenuDrop(
                  index: 2,
                  child: _buildMenuTile(
                    context,
                    icon: Icons.stars_rounded,
                    title: FFLocalizations.of(context).getText('menu0006'),
                    sub: FFLocalizations.of(context).getText('menu0007'),
                    route: IncentivePageWidget.routeName,
                    color: const Color(0xFF9B59B6), // Vibrant Purple
                  ),
                ),
                AnimatedMenuDrop(
                  index: 3,
                  child: _buildMenuTile(
                    context,
                    icon: Icons.headset_mic_rounded,
                    title: FFLocalizations.of(context).getText('menu0008'),
                    sub: FFLocalizations.of(context).getText('menu0009'),
                    route: SupportWidget.routeName,
                    color: const Color(0xFFE74C3C), // Vibrant Red
                  ),
                ),
              ],
            ),
          ),

          /// 3. LOVELY REFERRAL BANNER
          AnimatedMenuDrop(
            index: 4,
            child: _buildReferralCard(context),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPremiumHeader(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(AccountSupportWidget.routeName),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          Responsive.horizontalPadding(context),
          MediaQuery.of(context).padding.top + 24,
          Responsive.horizontalPadding(context),
          32,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // Glowing Avatar
            Container(
              width: Responsive.value(context, small: 64.0, medium: 72.0, large: 80.0),
              height: Responsive.value(context, small: 64.0, medium: 72.0, large: 80.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipOval(
                child: _image.isNotEmpty
                    ? Image.network(img(_image), fit: BoxFit.cover)
                    : Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  alignment: Alignment.center,
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 28),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('menu0001'),
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: Responsive.fontSize(context, 13),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_rating.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _rating,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String sub,
        required String route,
        required Color color,
      }) {
    final hPad = Responsive.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withValues(alpha: 0.1),
            highlightColor: color.withValues(alpha: 0.05),
            onTap: () => context.pushNamed(route),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Vibrant Soft Icon Box
                  Container(
                    width: Responsive.buttonHeight(context, base: 50),
                    height: Responsive.buttonHeight(context, base: 50),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: Responsive.iconSize(context, base: 26)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            fontSize: Responsive.fontSize(context, 13),
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        8,
        Responsive.horizontalPadding(context),
        Responsive.verticalSpacing(context) + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF4E6), Color(0xFFFFE0B2)], // Lovely warm peach gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReferFriendWidget()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.redeem_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite & Earn',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FFLocalizations.of(context).getText('menu0010'), // "Refer a friend..."
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: Responsive.fontSize(context, 13),
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      FFLocalizations.of(context).getText('menu0011'), // "Refer"
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}