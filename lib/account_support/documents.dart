import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Required for HapticFeedback
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static String routeName = 'documents_screen';
  static String routePath = '/documentsScreen';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isFetchingDocuments = true;

  // Track which documents are already uploaded on server
  final Map<String, bool> _serverDocuments = {
    'profilePhoto': false,
    'imageLicense': false,
    'aadharImage': false,
    'panImage': false,
    'vehicleImage': false,
    'registrationImage': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchExistingDocuments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 1. Fetch existing documents from server using DriverIdfetchCall
  Future<void> _fetchExistingDocuments() async {
    setState(() => _isFetchingDocuments = true);

    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      if (driverId == 0 || token.isEmpty) {
        setState(() => _isFetchingDocuments = false);
        return;
      }

      // ✅ API CALL: Get Driver Details
      final response = await DriverIdfetchCall.call(
        id: driverId,
        token: token,
      );

      if (response.succeeded) {
        final data = getJsonField(response.jsonBody, r'''$.data''');

        if (data != null) {
          // Helper to check if string is valid
          bool hasDoc(dynamic path) =>
              path != null &&
                  path.toString().isNotEmpty &&
                  path.toString() != "null";

          setState(() {
            _serverDocuments['profilePhoto'] = hasDoc(data['profile_image']);
            _serverDocuments['imageLicense'] = hasDoc(data['license_image']);
            _serverDocuments['aadharImage'] = hasDoc(data['aadhaar_image']);
            _serverDocuments['panImage'] = hasDoc(data['pan_image']);
            _serverDocuments['vehicleImage'] = hasDoc(data['vehicle_image']);

            // Check both front/back or just 'rc_image' depending on API response structure
            _serverDocuments['registrationImage'] =
                hasDoc(data['rc_image']) || hasDoc(data['rc_front_image']);
          });

          print("✅ Documents Status Updated from Server");
        }
      } else {
        print("❌ Failed to fetch driver details: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error fetching documents: $e');
    } finally {
      if (mounted) setState(() => _isFetchingDocuments = false);
    }
  }

  /// Helper to get local state doc (Newly picked files)
  dynamic _getLocalDoc(String key) {
    switch (key) {
      case 'profilePhoto':
        return FFAppState().profilePhoto;
      case 'imageLicense':
        return FFAppState().imageLicense;
      case 'aadharImage':
        return FFAppState().aadharImage;
      case 'panImage':
        return FFAppState().panImage;
      case 'vehicleImage':
        return FFAppState().vehicleImage;
      case 'registrationImage':
        return FFAppState().registrationImage;
      default:
        return null;
    }
  }

  bool _hasNewDocuments() {
    return _serverDocuments.keys.any((key) => _getLocalDoc(key) != null);
  }

  /// 2. Handle Update (Upload new files)
  Future<void> _handleUpdateDocuments() async {
    HapticFeedback.mediumImpact(); // ✅ Vibrate on tap

    if (_isLoading) return;

    if (!_hasNewDocuments()) {
      _showSnack('Please upload at least one new document to update.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      final apiResult = await UpdateDriverCall.call(
        id: driverId,
        token: token,
        profileimage: FFAppState().profilePhoto,
        licenseimage: FFAppState().imageLicense,
        aadhaarimage: FFAppState().aadharImage,
        panimage: FFAppState().panImage,
        vehicleImage: FFAppState().vehicleImage,
        registrationImage: FFAppState().registrationImage,
      );

      if ((apiResult.succeeded ?? false) || apiResult.statusCode == 200) {
        // Success Logic
        setState(() {
          // Mark locally uploaded docs as "On Server" now
          _serverDocuments.keys.forEach((key) {
            if (_getLocalDoc(key) != null) _serverDocuments[key] = true;
          });
        });

        // Clear local state
        FFAppState().update(() {
          FFAppState().profilePhoto = null;
          FFAppState().imageLicense = null;
          FFAppState().aadharImage = null;
          FFAppState().panImage = null;
          FFAppState().vehicleImage = null;
          FFAppState().registrationImage = null;
        });

        _showSnack('✓ Documents updated successfully!', isError: false);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) context.pushReplacementNamed(HomeWidget.routeName);
      } else {
        // Error Logic
        String msg =
            getJsonField(apiResult.jsonBody, r'''$.message''')?.toString() ??
                'Update failed';
        _showSnack(msg, isError: true);
      }
    } catch (e) {
      _showSnack('An error occurred. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // 🎨 APP COLORS
    const Color brandPrimary = Color(0xFFFF7B10);
    const Color brandGradientStart = Color(0xFFFF8E32);
    const Color bgOffWhite = Color(0xFFF5F7FA);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: Stack(
          children: [
            // 1️⃣ Header Background
            Column(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [brandGradientStart, brandPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Back Button Row
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                "Manage Documents",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: const Text(
                              "Update your Proofs here.",
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const Spacer(),

                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),

            // 2️⃣ Floating List
            Positioned.fill(
              top: 180,
              child: _isFetchingDocuments
                  ? Center(
                  child: CircularProgressIndicator(color: brandPrimary))
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Personal Documents"),
                      const SizedBox(height: 16),

                      _buildStepItem(
                        "Profile Photo",
                        "profilePhoto",
                            () => context
                            .pushNamed(FaceVerifyWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        "Driving License",
                        "imageLicense",
                            () => context
                            .pushNamed(DrivingDlWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        "Aadhaar Card",
                        "aadharImage",
                            () => context
                            .pushNamed(AdharUploadWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        "PAN Card",
                        "panImage",
                            () => context
                            .pushNamed(PanuploadScreenWidget.routeName),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade100, thickness: 2),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Vehicle Documents"),
                      const SizedBox(height: 16),

                      _buildStepItem(
                        "Vehicle Photo",
                        "vehicleImage",
                            () => context
                            .pushNamed(VehicleImageWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        "RC Book",
                        "registrationImage",
                            () => context
                            .pushNamed(RegistrationImageWidget.routeName),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                          _isLoading ? null : _handleUpdateDocuments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPrimary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor:
                            brandPrimary.withValues(alpha:0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5),
                          )
                              : const Text(
                            "Update Documents",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStepItem(String title, String key, VoidCallback onTap) {
    // 1. Is New Local File?
    bool isLocal = _getLocalDoc(key) != null;
    // 2. Is On Server?
    bool isServer = _serverDocuments[key] ?? false;

    // Define Visuals
    Color bgColor = const Color(0xFFF9F9F9);
    Color borderColor = const Color(0xFFEEEEEE);
    Color iconColor = Colors.grey.shade400;
    IconData icon = Icons.upload_file_rounded;
    String statusText = "Tap to upload";
    Color textColor = Colors.grey.shade500;

    if (isLocal) {
      bgColor = const Color(0xFFFFF7ED); // Light Orange
      borderColor = const Color(0xFFFF7B10).withValues(alpha:0.5);
      iconColor = const Color(0xFFFF7B10);
      icon = Icons.cloud_upload_rounded;
      statusText = "Ready to Update";
      textColor = const Color(0xFFFF7B10);
    } else if (isServer) {
      bgColor = const Color(0xFFF0FDF4); // Light Green
      borderColor = const Color(0xFF10B981).withValues(alpha:0.5);
      iconColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      statusText = "Uploaded";
      textColor = const Color(0xFF10B981);
    }

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick(); // ✅ Vibrate on item tap
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}