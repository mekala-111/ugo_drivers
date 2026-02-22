
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
                  path.toString() != 'null';

          setState(() {
            _serverDocuments['profilePhoto'] = hasDoc(data['profile_image']);
            _serverDocuments['imageLicense'] = hasDoc(data['license_image']) ||
                hasDoc(data['license_front_image']) ||
                hasDoc(data['license_back_image']);
            _serverDocuments['aadharImage'] = hasDoc(data['aadhaar_image']) ||
                hasDoc(data['aadhaar_front_image']) ||
                hasDoc(data['aadhaar_back_image']);
            _serverDocuments['panImage'] = hasDoc(data['pan_image']);
            _serverDocuments['vehicleImage'] = hasDoc(data['vehicle_image']);
            _serverDocuments['registrationImage'] = hasDoc(data['rc_image']) ||
                hasDoc(data['rc_front_image']) ||
                hasDoc(data['rc_back_image']);
          });

        }
      } else {
      }
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
      _showSnack(FFLocalizations.of(context).getText('docm0001'),
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
        insuranceImage: FFAppState().insuranceImage,
        pollutionCertificateImage: FFAppState().pollutioncertificateImage,
        vehicleName: FFAppState().vehicleMake,
        vehicleModel: FFAppState().vehicleModel,
        vehicleColor: FFAppState().vehicleColor.isNotEmpty ? FFAppState().vehicleColor : null,
        licensePlate: FFAppState().licensePlate.isNotEmpty ? FFAppState().licensePlate : null,
        registrationNumber: FFAppState().registrationNumber.isNotEmpty ? FFAppState().registrationNumber : null,
        registrationDate: FFAppState().registrationDate.isNotEmpty ? FFAppState().registrationDate : null,
        insuranceNumber: FFAppState().insuranceNumber.isNotEmpty ? FFAppState().insuranceNumber : null,
        insuranceExpiryDate: FFAppState().insuranceExpiryDate.isNotEmpty ? FFAppState().insuranceExpiryDate : null,
        pollutionExpiryDate: FFAppState().pollutionExpiryDate.isNotEmpty ? FFAppState().pollutionExpiryDate : null,
        vehicleTypeId: FFAppState().adminVehicleId > 0 ? FFAppState().adminVehicleId : null,
      );

      if ((apiResult.succeeded) || apiResult.statusCode == 200) {
        // Success Logic
        setState(() {
          // Mark locally uploaded docs as "On Server" now
          for (var key in _serverDocuments.keys) {
            if (_getLocalDoc(key) != null) _serverDocuments[key] = true;
          }
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

        _showSnack(FFLocalizations.of(context).getText('docm0002'),
            isError: false);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) context.pushReplacementNamed(HomeWidget.routeName);
      } else {
        // Error Logic
        String msg =
            getJsonField(apiResult.jsonBody, r'''$.message''')?.toString() ??
                FFLocalizations.of(context).getText('docm0003');
        _showSnack(msg, isError: true);
      }
    } catch (e) {
      _showSnack(FFLocalizations.of(context).getText('docm0004'),
          isError: true);
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
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final headerHeight = (screenHeight * 0.26).clamp(190.0, 260.0);
    final contentTop = headerHeight - 60.0;

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
                  height: headerHeight,
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
                              Text(
                                FFLocalizations.of(context)
                                    .getText('docm0005'),
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
                            child: Text(
                              FFLocalizations.of(context)
                                  .getText('docm0006'),
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
              top: contentTop,
              child: _isFetchingDocuments
                  ? const Center(
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
                        _buildSectionHeader(
                          FFLocalizations.of(context).getText('docm0007')),
                      const SizedBox(height: 16),

                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0008'),
                        'profilePhoto',
                            () => context
                            .pushNamed(FaceVerifyupdateWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0009'),
                        'imageLicense',
                            () => context
                            .pushNamed(DrivingDlUpdateWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0010'),
                        'aadharImage',
                            () => context
                            .pushNamed(AdharUploadUpdateWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0011'),
                        'panImage',
                            () => context
                            .pushNamed(PanuploadScreenUpdateWidget.routeName),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade100, thickness: 2),
                      const SizedBox(height: 24),

                        _buildSectionHeader(
                          FFLocalizations.of(context).getText('docm0012')),
                      const SizedBox(height: 16),

                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0013'),
                        'vehicleImage',
                            () => context
                            .pushNamed(VehicleImageUpdateWidget.routeName),
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        FFLocalizations.of(context).getText('docm0014'),
                        'registrationImage',
                            () => context
                            .pushNamed(RegistrationUpdateWidget.routeName),
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
                              : Text(
                            FFLocalizations.of(context)
                                .getText('docm0015'),
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
    Color bgColor = AppColors.backgroundCard;
    Color borderColor = AppColors.divider;
    Color iconColor = Colors.grey.shade400;
    IconData icon = Icons.upload_file_rounded;
    String statusText = FFLocalizations.of(context).getText('upload0002');
    Color textColor = Colors.grey.shade500;

    if (isLocal) {
      bgColor = AppColors.sectionOrangeTint;
      borderColor = AppColors.primary.withValues(alpha:0.5);
      iconColor = AppColors.primary;
      icon = Icons.cloud_upload_rounded;
      statusText = FFLocalizations.of(context).getText('docm0016');
      textColor = AppColors.primary;
    } else if (isServer) {
      bgColor = AppColors.sectionGreenTint;
      borderColor = AppColors.accentEmerald.withValues(alpha:0.5);
      iconColor = AppColors.accentEmerald;
      icon = Icons.check_circle_rounded;
      statusText = FFLocalizations.of(context).getText('upload0005');
      textColor = AppColors.accentEmerald;
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