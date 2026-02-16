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
  String _name = "Driver";
  String _image = "";
  String _rating = "";

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
        "${DriverIdfetchCall.firstName(res.jsonBody)} ${DriverIdfetchCall.lastName(res.jsonBody)}";
        _image = DriverIdfetchCall.profileImage(res.jsonBody) ?? "";
        _rating = DriverIdfetchCall.driverRating(res.jsonBody) ?? "";
      });
    }
  }

  String img(String path) =>
      path.startsWith("http") ? path : "https://ugo-api.icacorp.org/$path";

  Widget tile(
      {required IconData icon,
        required String title,
        required String sub,
        required String route,
        Color color = Colors.orange}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.pushNamed(route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(sub,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey)),
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
                20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF7B10), Color(0xFFFFA15C)]),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withValues(alpha:.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
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
                      color: const Color(0xFFFF7B10),
                      alignment: Alignment.center,
                      child: Text(
                        _name.isNotEmpty ? _name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
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
                        Text("Welcome Back",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                            child: Text(_name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
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
              tile(
                  icon: Icons.person_outline,
                  title: "Account",
                  sub: "Manage your profile",
                  route: AccountManagementWidget.routeName,
                  color: Colors.blue),
              tile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Earnings",
                  sub: "History & Bank transfer",
                  route: TeamearningWidget.routeName,
                  color: Colors.green),
              tile(
                  icon: Icons.remove_red_eye_outlined,
                  title: "Incentives",
                  sub: "Know how you get paid",
                  route: IncentivePageWidget.routeName,
                  color: Colors.purple),
              tile(
                  icon: Icons.headset_mic,
                  title: "Help",
                  sub: "Support & Accident Insurance",
                  route: SupportWidget.routeName, // Ensure this route exists or update it
                  color: Colors.red),
            ],
          ),
        ),

        /// REFER
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard,
                  color: Color(0xFFFF7B10), size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Refer friends & earn ₹10 per ride"),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7B10), Color(0xFFFFA15C)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha:.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReferFriendWidget()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Refer Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}