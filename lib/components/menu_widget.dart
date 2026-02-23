import 'package:ugo_driver/account_support/refer_friend.dart';

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Ensure AccountSupportWidget is imported or available via /index.dart
// If not in index.dart, add: import '/account_support/account_support_widget.dart';

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
      setState(() {
        _name =
            '${DriverIdfetchCall.firstName(res.jsonBody)} ${DriverIdfetchCall.lastName(res.jsonBody)}';
        _image = DriverIdfetchCall.profileImage(res.jsonBody) ?? '';
        _rating = DriverIdfetchCall.driverRating(res.jsonBody) ?? '';
      });
    }
  }

  String img(String path) =>
      path.startsWith('http') ? path : 'https://ugo-api.icacorp.org/$path';

  Widget tile(BuildContext context,
      {required IconData icon,
      required String title,
      required String sub,
      required String route,
      Color color = Colors.orange}) {
    final hPad = Responsive.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: Responsive.verticalSpacing(context) * 0.75),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.pushNamed(route),
        child: Container(
          padding: EdgeInsets.all(Responsive.verticalSpacing(context) + 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.buttonHeight(context, base: 46),
                height: Responsive.buttonHeight(context, base: 46),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: color, size: Responsive.iconSize(context, base: 24)),
              ),
              SizedBox(width: Responsive.verticalSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: Responsive.verticalSpacing(context) * 0.5),
                    Text(sub,
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(context, 13),
                            color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER (Now Clickable)
        InkWell(
          onTap: () {
            // ✅ Navigate to Account Support on Profile Click
            context.pushNamed(AccountSupportWidget.routeName);
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Responsive.horizontalPadding(context),
              MediaQuery.of(context).padding.top +
                  Responsive.verticalSpacing(context),
              Responsive.horizontalPadding(context),
              Responsive.verticalSpacing(context) + 4,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLightBg]),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withValues(alpha: .4),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.value(context,
                      small: 60.0, medium: 66.0, large: 72.0),
                  height: Responsive.value(context,
                      small: 60.0, medium: 66.0, large: 72.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: _image.isNotEmpty
                        ? Image.network(
                            img(_image),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primary,
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
                SizedBox(width: Responsive.verticalSpacing(context)),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(FFLocalizations.of(context).getText('menu0001'),
                            style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: Responsive.fontSize(context, 14))),
                        SizedBox(
                            height: Responsive.verticalSpacing(context) * 0.5),
                        Row(children: [
                          Expanded(
                            child: Text(_name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: Responsive.fontSize(context, 18),
                                    fontWeight: FontWeight.bold)),
                          ),
                          if (_rating.isNotEmpty) ...[
                            const Icon(Icons.star,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(_rating,
                                style: const TextStyle(color: Colors.white))
                          ]
                        ])
                      ]),
                ),
                // Arrow icon to indicate it's clickable
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),

        /// MENU
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 10),
              tile(context,
                  icon: Icons.person_outline,
                  title: FFLocalizations.of(context).getText('menu0002'),
                  sub: FFLocalizations.of(context).getText('menu0003'),
                  route: AccountManagementWidget.routeName,
                  color: Colors.blue),
              tile(context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: FFLocalizations.of(context).getText('menu0004'),
                  sub: FFLocalizations.of(context).getText('menu0005'),
                  route: TeamEarningsWidget.routeName,
                  color: Colors.green),
              tile(context,
                  icon: Icons.remove_red_eye_outlined,
                  title: FFLocalizations.of(context).getText('menu0006'),
                  sub: FFLocalizations.of(context).getText('menu0007'),
                  route: IncentivePageWidget.routeName,
                  color: Colors.purple),
              tile(context,
                  icon: Icons.headset_mic,
                  title: FFLocalizations.of(context).getText('menu0008'),
                  sub: FFLocalizations.of(context).getText('menu0009'),
                  route: SupportWidget
                      .routeName, // Ensure this route exists or update it
                  color: Colors.red),
            ],
          ),
        ),

        /// REFER
        Container(
          padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final textWidget = Text(
                FFLocalizations.of(context).getText('menu0010'),
                maxLines: isNarrow ? 4 : 3,
                style: TextStyle(fontSize: Responsive.fontSize(context, 14)),
              );
              final actionButton = Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLightBg],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: .4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReferFriendWidget()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding(context) + 10,
                      vertical:
                          Responsive.buttonHeight(context, base: 48) * 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    FFLocalizations.of(context).getText('menu0011'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.card_giftcard,
                            color: AppColors.primary,
                            size: Responsive.iconSize(context, base: 32)),
                        SizedBox(width: Responsive.verticalSpacing(context)),
                        Expanded(child: textWidget),
                      ],
                    ),
                    SizedBox(height: Responsive.verticalSpacing(context)),
                    Align(alignment: Alignment.centerLeft, child: actionButton),
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.card_giftcard,
                      color: AppColors.primary,
                      size: Responsive.iconSize(context, base: 32)),
                  SizedBox(width: Responsive.verticalSpacing(context)),
                  Expanded(child: textWidget),
                  actionButton,
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
