import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/account_support/documents.dart';
import 'package:ugo_driver/account_support/editg_address.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Map<String, dynamic>? driverData;
  bool isLoading = true;

  // Stats Variables
  String driverRating = "5.0"; // Default to 5.0 to avoid "null"
  String driverYears = "0.0";

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
          driverRating = data['driver_rating']?.toString() ?? "5.0";
          if (driverRating == "null" || driverRating.isEmpty) driverRating = "5.0";

          // 2. Calculate Years from 'created_at'
          if (data['created_at'] != null) {
            try {
              DateTime createdDate = DateTime.parse(data['created_at'].toString());
              DateTime now = DateTime.now();
              double years = now.difference(createdDate).inDays / 365.0;
              if (years < 0.1) years = 0.1;
              driverYears = years.toStringAsFixed(1);
            } catch (e) {
              print("Date parse error: $e");
              driverYears = "0.1";
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

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    const String baseUrl = 'https://ugo-api.icacorp.org';
    String cleanPath = imagePath.startsWith('uploads/') ? imagePath.substring(8) : imagePath;
    return '$baseUrl/$cleanPath';
  }

  String getDriverName() {
    if (driverData == null) return 'Driver Name';
    final firstName = driverData!['first_name'] ?? '';
    final lastName = driverData!['last_name'] ?? '';
    return '$firstName $lastName'.trim().isEmpty ? 'Driver Name' : '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFFFF7B10);
    const Color bgWhite = Colors.white;
    const Color bgGrey = Color(0xFFF5F7FA);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgWhite,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandPrimary))
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
                      colors: [Color(0xFFFF8E32), brandPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.headset_mic_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                  "Help",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                            ],
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
                        "My Profile",
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
                Positioned(
                  bottom: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5)
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: driverData?['profile_image'] != null
                          ? CachedNetworkImage(
                        imageUrl: getFullImageUrl(driverData!['profile_image']),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.person, size: 50, color: Colors.grey),
                      )
                          : const Icon(Icons.person, size: 50, color: Colors.grey),
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
            // 2️⃣ DYNAMIC STATS ROW
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("$driverRating ⭐", "RATING >"),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildStatItem("${driverData?['total_rides_completed'] ?? 0}", "ORDERS"),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildStatItem(driverYears, "YEARS"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Divider(thickness: 8, color: bgGrey),
            const SizedBox(height: 20),

            // ==========================================
            // 3️⃣ MENU LIST
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: "Documents (RC, DL, PAN)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.edit_location_alt_outlined,
                    title: "Edit Address",
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
                      onPressed: () {},
                      icon: const Icon(Icons.power_settings_new, color: Colors.black),
                      label: const Text(
                          "Logout",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          )
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      label: const Text(
                          "Delete Account",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          )
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
            )
        ),
        const SizedBox(height: 4),
        Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 0.5
            )
        ),
      ],
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(
                child: Text(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                    )
                )
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}