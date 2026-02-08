// import '/backend/api_requests/api_calls.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/index.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'menu_model.dart';
// export 'menu_model.dart';

// class MenuWidget extends StatefulWidget {
//   const MenuWidget({super.key});

//   @override
//   State<MenuWidget> createState() => _MenuWidgetState();
// }

// class _MenuWidgetState extends State<MenuWidget> {
//   late MenuModel _model;
//   bool _isLoadingUser = true;
//   String _userDisplayName = 'Driver';
//   String _profileImageUrl = '';
//   String _rating = '';

//   @override
//   void setState(VoidCallback callback) {
//     super.setState(callback);
//     _model.onUpdate();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => MenuModel());
//     _fetchDriverDetails();
//   }

//   String getFullImageUrl(String? imagePath) {
//     if (imagePath == null || imagePath.isEmpty) {
//       return '';
//     }
//     const String baseUrl = 'https://ugo-api.icacorp.org';
//     if (imagePath.startsWith('http')) {
//       return imagePath;
//     }
//     return '$baseUrl/$imagePath';
//   }

//   Future<void> _fetchDriverDetails() async {
//     try {
//       var userDetails = await DriverIdfetchCall.call(
//         token: FFAppState().accessToken,
//         id: FFAppState().driverid,
//       );

//       if (userDetails.succeeded && userDetails.jsonBody != null) {
//         setState(() {
//           _userDisplayName =
//               '${DriverIdfetchCall.firstName(userDetails.jsonBody)} ${DriverIdfetchCall.lastName(userDetails.jsonBody)}';
//           _profileImageUrl = getFullImageUrl(
//               DriverIdfetchCall.profileImage(userDetails.jsonBody));
//           _rating = DriverIdfetchCall.driverRating(userDetails.jsonBody) ?? '';
//           _isLoadingUser = false;
//         });
//       } else {
//         setState(() {
//           _isLoadingUser = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching driver details: $e');
//       setState(() {
//         _isLoadingUser = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _model.maybeDispose();
//     super.dispose();
//   }

//   // Helper method to create clean menu items
//   Widget _buildMenuItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String routeName,
//   }) {
//     return InkWell(
//       onTap: () async {
//         context.pushNamed(routeName);
//       },
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: Color(0xFF333333),
//               size: 28.0,
//             ),
//             SizedBox(width: 20.0),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: FlutterFlowTheme.of(context).bodyLarge.override(
//                           fontFamily: 'Outfit',
//                           color: Color(0xFF1A1A1A),
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                   SizedBox(height: 4.0),
//                   Text(
//                     subtitle,
//                     style: FlutterFlowTheme.of(context).bodyMedium.override(
//                           fontFamily: 'Readex Pro',
//                           color: Color(0xFF666666),
//                           fontSize: 14.0,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Divider widget
//   Widget _buildDivider() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.0),
//       child: Divider(
//         color: Color(0xFFE0E0E0),
//         thickness: 1.0,
//         height: 1.0,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isNarrow = MediaQuery.of(context).size.width < 380;
//     final gradientStart = Color(0xFFFF7B10);
//     final gradientEnd = Color(0xFFFF9A4D);

//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           // Orange Header Section with Profile
//           InkWell(
//             onTap: () => context.pushNamed('Account_support'),
//             child: Container(
//               padding: EdgeInsets.fromLTRB(
//                 isNarrow ? 16 : 20,
//                 MediaQuery.of(context).padding.top + (isNarrow ? 12 : 16),
//                 isNarrow ? 16 : 20,
//                 isNarrow ? 16 : 20,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [gradientStart, gradientEnd],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: isNarrow ? 60 : 70,
//                     height: isNarrow ? 60 : 70,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.12),
//                           blurRadius: 12,
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(50),
//                       child: _isLoadingUser
//                           ? Icon(Icons.person,
//                               color: gradientStart.withOpacity(0.75),
//                               size: isNarrow ? 26 : 30)
//                           : (_profileImageUrl.isNotEmpty
//                               ? Image.network(
//                                   _profileImageUrl,
//                                   fit: BoxFit.cover,
//                                   loadingBuilder: (context, child, progress) =>
//                                       progress == null
//                                           ? child
//                                           : Icon(Icons.person,
//                                               color: gradientStart
//                                                   .withOpacity(0.75),
//                                               size: isNarrow ? 26 : 30),
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       Icon(
//                                     Icons.person,
//                                     color: gradientStart,
//                                     size: isNarrow ? 26 : 30,
//                                   ),
//                                 )
//                               : Icon(Icons.person,
//                                   color: gradientStart,
//                                   size: isNarrow ? 26 : 30)),
//                     ),
//                   ),
//                   SizedBox(width: isNarrow ? 14 : 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Welcome Back',
//                           style: GoogleFonts.poppins(
//                             fontSize: isNarrow ? 16 : 19,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white.withOpacity(0.95),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         _isLoadingUser
//                             ? SizedBox(
//                                 width: 120,
//                                 height: 14,
//                                 child: LinearProgressIndicator(
//                                   backgroundColor:
//                                       Colors.white.withOpacity(0.3),
//                                   valueColor:
//                                       const AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : Row(
//                                 children: [
//                                   Text(
//                                     _userDisplayName,
//                                     style: GoogleFonts.poppins(
//                                       fontSize: isNarrow ? 16 : 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   if (_rating.isNotEmpty) ...[
//                                     SizedBox(width: 8),
//                                     Icon(Icons.star,
//                                         color: Colors.white, size: 16),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       _rating,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: isNarrow ? 14 : 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ]
//                                 ],
//                               ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Menu Items List
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               children: [
//                 // Account
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.person_outline,
//                   title: 'Account',
//                   subtitle: 'Manage your profile',
//                   routeName: AccountManagementWidget.routeName,
//                 ),
//                 _buildDivider(),

//                 // Earnings
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.account_balance_wallet_outlined,
//                   title: 'Earnings',
//                   subtitle: 'Transfer Money to Bank, History',
//                   routeName: 'Earnings', // TODO: Make sure this route exists
//                 ),
//                 _buildDivider(),

//                 // Incentives and More
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.remove_red_eye_outlined,
//                   title: 'Incentives and More',
//                   subtitle: 'Know how you get paid',
//                   routeName: 'Incentives', // TODO: Make sure this route exists
//                 ),
//                 _buildDivider(),

//                 // Rewards
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.card_giftcard_outlined,
//                   title: 'Rewards',
//                   subtitle: 'Insurance and Discounts',
//                   routeName: 'Rewards', // TODO: Make sure this route exists
//                 ),

//                 // Thicker Divider
//                 SizedBox(height: 8.0),

//                 // Help
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.headset_mic_outlined,
//                   title: 'Help',
//                   subtitle: 'Get support, Accident Insurance',
//                   routeName: 'Help', // TODO: Make sure this route exists
//                 ),
//               ],
//             ),
//           ),

//           // Bottom Referral Banner
//           Container(
//             padding: EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8.0,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 50.0,
//                   height: 50.0,
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFF7B10),
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                   child: Icon(
//                     Icons.card_giftcard,
//                     color: Colors.white,
//                     size: 28.0,
//                   ),
//                 ),
//                 SizedBox(width: 12.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Refer your friends, Earn ₹10',
//                         style: TextStyle(
//                           fontSize: 12.0,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A1A),
//                         ),
//                       ),
//                       Text(
//                         ' Per Pro Ride',
//                         style: TextStyle(
//                           fontSize: 12.0,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A1A1A),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFF7B10),
//                     borderRadius: BorderRadius.circular(24.0),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFFFF7B10),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     'Refer Now',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 14.0,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_model.dart';
export 'menu_model.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late MenuModel _model;

  bool _loading = true;
  String _name = "Driver";
  String _image = "";
  String _rating = "";

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuModel());
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
        _loading = false;
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
                  color: color.withOpacity(.15),
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
        /// HEADER
        Container(
          padding:
              EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF7B10), Color(0xFFFFA15C)]),
            boxShadow: [
              BoxShadow(
                  color: Colors.orange.withOpacity(.4),
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
                    border: Border.all(color: Colors.white, width: 3)),
                child: ClipOval(
                  child: _image.isNotEmpty
                      ? Image.network(img(_image), fit: BoxFit.cover)
                      : const Icon(Icons.person, color: Colors.white),
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
              )
            ],
          ),
        ),

        /// MENU
        Expanded(
          child: ListView(
            children: [
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
                  route: "Earnings",
                  color: Colors.green),

              tile(
                  icon: Icons.remove_red_eye_outlined,
                  title: "Incentives",
                  sub: "Know how you get paid",
                  route: "Incentives",
                  color: Colors.purple),

              tile(
                  icon: Icons.card_giftcard,
                  title: "Rewards",
                  sub: "Insurance & Discounts",
                  route: "Rewards",
                  color: Colors.orange),

              tile(
                  icon: Icons.headset_mic,
                  title: "Help",
                  sub: "Support & Accident Insurance",
                  route: "Help",
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF7B10), Color(0xFFFFA15C)]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orange.withOpacity(.4), blurRadius: 12)
                    ]),
                child: const Text("Refer Now",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        )
      ],
    );
  }
}
