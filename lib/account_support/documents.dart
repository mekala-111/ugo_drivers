import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
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
  Map<String, bool> _serverDocuments = {
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

  /// Fetch existing documents from server
  Future<void> _fetchExistingDocuments() async {
    setState(() {
      _isFetchingDocuments = true;
    });

    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      if (driverId == 0 || token.isEmpty) {
        setState(() {
          _isFetchingDocuments = false;
        });
        return;
      }

      // TODO: Replace with your actual API call to fetch driver details
      // Example: final response = await GetDriverDetailsCall.call(id: driverId, token: token);
      
      // For now, assuming you have an API that returns driver document URLs
      // Based on your response format:
      // {
      //   "success": true,
      //   "data": {
      //     "profile_image": "uploads/profiles/...",
      //     "license_image": "uploads/licenses/...",
      //     "aadhaar_image": "uploads/aadhaars/...",
      //     "pan_image": "uploads/pans/...",
      //     "vehicle_image": "uploads/vehicles/...",
      //     "rc_image": "uploads/images/..."
      //   }
      // }
      
      // Uncomment and modify this when you add the API call:
      /*
      final response = await GetDriverDetailsCall.call(
        id: driverId,
        token: token,
      );
      
      if (response.succeeded ?? false) {
        try {
          final profileImage = getJsonField(response.jsonBody, r'''$.data.profile_image''');
          final licenseImage = getJsonField(response.jsonBody, r'''$.data.license_image''');
          final aadhaarImage = getJsonField(response.jsonBody, r'''$.data.aadhaar_image''');
          final panImage = getJsonField(response.jsonBody, r'''$.data.pan_image''');
          final vehicleImage = getJsonField(response.jsonBody, r'''$.data.vehicle_image''');
          final rcImage = getJsonField(response.jsonBody, r'''$.data.rc_image''');
          
          setState(() {
            _serverDocuments['profilePhoto'] = profileImage != null && profileImage.toString().isNotEmpty;
            _serverDocuments['imageLicense'] = licenseImage != null && licenseImage.toString().isNotEmpty;
            _serverDocuments['aadharImage'] = aadhaarImage != null && aadhaarImage.toString().isNotEmpty;
            _serverDocuments['panImage'] = panImage != null && panImage.toString().isNotEmpty;
            _serverDocuments['vehicleImage'] = vehicleImage != null && vehicleImage.toString().isNotEmpty;
            _serverDocuments['registrationImage'] = rcImage != null && rcImage.toString().isNotEmpty;
          });
          
          print('📄 Document status:');
          print('   Profile: ${_serverDocuments['profilePhoto']}');
          print('   License: ${_serverDocuments['imageLicense']}');
          print('   Aadhaar: ${_serverDocuments['aadharImage']}');
          print('   PAN: ${_serverDocuments['panImage']}');
          print('   Vehicle: ${_serverDocuments['vehicleImage']}');
          print('   RC: ${_serverDocuments['registrationImage']}');
        } catch (e) {
          print('Error parsing document status: $e');
        }
      }
      */

      print('📄 Fetched existing documents status');
    } catch (e) {
      print('❌ Error fetching documents: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingDocuments = false;
        });
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(milliseconds: 3000),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Check if any new document has been uploaded
  bool _hasNewDocuments() {
    return FFAppState().profilePhoto != null ||
        FFAppState().imageLicense != null ||
        FFAppState().aadharImage != null ||
        FFAppState().panImage != null ||
        FFAppState().vehicleImage != null ||
        FFAppState().registrationImage != null;
  }

  /// Handle document update submission
  Future<void> _handleUpdateDocuments() async {
    // Prevent multiple submissions
    if (_isLoading) return;

    // Check if any new documents to upload
    if (!_hasNewDocuments()) {
      _showErrorMessage('Please upload at least one document to update');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get driver ID and token from FFAppState
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      // Validate authentication
      if (driverId == 0) {
        _showErrorMessage('Please login first');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (token.isEmpty) {
        _showErrorMessage('Authentication token missing. Please login again.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🚀 Starting document update...');
      print('   Driver ID: $driverId');
      print('   Token: ${token.substring(0, 20)}...');
      print('   Documents to update:');
      print('     Profile: ${FFAppState().profilePhoto != null}');
      print('     License: ${FFAppState().imageLicense != null}');
      print('     Aadhaar: ${FFAppState().aadharImage != null}');
      print('     PAN: ${FFAppState().panImage != null}');
      print('     Vehicle: ${FFAppState().vehicleImage != null}');
      print('     Registration: ${FFAppState().registrationImage != null}');

      // Call UpdateDriver API with images
      // Only send non-null images (partial update)
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

      print('📥 UpdateDriver API Response:');
      print('   Status: ${apiResult.statusCode}');
      print('   Success: ${apiResult.succeeded}');
      print('   Body: ${apiResult.jsonBody}');

      // Check if response is successful
      bool isSuccess = false;
      
      // First check the succeeded flag
      if (apiResult.succeeded == true) {
        isSuccess = true;
      } 
      // Also check status code
      else if (apiResult.statusCode == 200 || apiResult.statusCode == 201) {
        isSuccess = true;
      }
      // Finally check the JSON body for success field
      else {
        try {
          final successField = getJsonField(
            (apiResult.jsonBody ?? ''),
            r'''$.success''',
          );
          if (successField == true) {
            isSuccess = true;
          }
        } catch (e) {
          print('Error checking success field: $e');
        }
      }

      print('   Final Success Status: $isSuccess');

      // Handle API response
      if (isSuccess) {
        // Clear the uploaded images from app state after successful upload
        FFAppState().update(() {
          FFAppState().profilePhoto = null;
          FFAppState().imageLicense = null;
          FFAppState().aadharImage = null;
          FFAppState().panImage = null;
          FFAppState().vehicleImage = null;
          FFAppState().registrationImage = null;
          FFAppState().isLoggedIn = true;
        });

        // Show success message
        _showSuccessMessage('Documents updated successfully!');

        // Refresh document status
        await _fetchExistingDocuments();

        // Wait briefly to show success message
        await Future.delayed(Duration(milliseconds: 500));

        // Navigate to home
        if (mounted) {
          context.pushReplacementNamed(HomeWidget.routeName);
        }
      } else {
        // Extract error message from response
        String errorMessage = 'Failed to update documents';

        try {
          // First try to get the message field
          final message = getJsonField(
            (apiResult.jsonBody ?? ''),
            r'''$.message''',
          );
          if (message != null && message.toString().isNotEmpty) {
            errorMessage = message.toString();
          }
          
          // If no message, try to get error field
          if (errorMessage == 'Failed to update documents') {
            final error = getJsonField(
              (apiResult.jsonBody ?? ''),
              r'''$.error''',
            );
            if (error != null && error.toString().isNotEmpty) {
              errorMessage = error.toString();
            }
          }
          
          print('   Error Message: $errorMessage');
        } catch (e) {
          print('Error parsing error message: $e');
        }

        _showErrorMessage(errorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ Error updating documents: $e');
      print('Stack trace: $stackTrace');
      _showErrorMessage('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              '1zwx91lm' /* UGO */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              if (_isFetchingDocuments)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 24.0, 24.0, 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getVariableText(
                                  enText: 'Update Documents',
                                  hiText: 'दस्तावेज़ अपडेट करें',
                                  teText: 'పత్రాలను నవీకరించండి',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 28.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                FFLocalizations.of(context).getVariableText(
                                  enText:
                                      'Upload or update your documents below',
                                  hiText:
                                      'नीचे अपने दस्तावेज़ अपलोड या अपडेट करें',
                                  teText:
                                      'దిగువ మీ పత్రాలను అప్‌లోడ్ లేదా నవీకరించండి',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 15.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Steps List Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Profile Picture Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'k8fnkaky' /* Profile Picture */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().profilePhoto,
                                  _serverDocuments['profilePhoto'] ?? false,
                                ),
                                onTap: () {
                                  context.pushNamed(FaceVerifyWidget.routeName);
                                },
                                hasDocument: FFAppState().profilePhoto != null,
                                isOnServer:
                                    _serverDocuments['profilePhoto'] ?? false,
                              ),

                              SizedBox(height: 4.0),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              SizedBox(height: 4.0),

                              // Driving License Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'qg68530z' /* Driving License */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().imageLicense,
                                  _serverDocuments['imageLicense'] ?? false,
                                ),
                                onTap: () {
                                  context.pushNamed(DrivingDlWidget.routeName);
                                },
                                hasDocument: FFAppState().imageLicense != null,
                                isOnServer:
                                    _serverDocuments['imageLicense'] ?? false,
                              ),

                              SizedBox(height: 4.0),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              SizedBox(height: 4.0),

                              // Aadhaar Card Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'c0kv9v5c' /* Aadhaar Card */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().aadharImage,
                                  _serverDocuments['aadharImage'] ?? false,
                                ),
                                onTap: () {
                                  context
                                      .pushNamed(AdharUploadWidget.routeName);
                                },
                                hasDocument: FFAppState().aadharImage != null,
                                isOnServer:
                                    _serverDocuments['aadharImage'] ?? false,
                              ),

                              SizedBox(height: 4.0),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              SizedBox(height: 4.0),

                              // Pan Card Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'ymy7qbgz' /* Pan Card */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().panImage,
                                  _serverDocuments['panImage'] ?? false,
                                ),
                                onTap: () {
                                  context.pushNamed(
                                      PanuploadScreenWidget.routeName);
                                },
                                hasDocument: FFAppState().panImage != null,
                                isOnServer:
                                    _serverDocuments['panImage'] ?? false,
                              ),

                              SizedBox(height: 4.0),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              SizedBox(height: 4.0),

                              // Vehicle Photo Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'jqs0l5w3' /* Vehicle photo verification */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().vehicleImage,
                                  _serverDocuments['vehicleImage'] ?? false,
                                ),
                                onTap: () {
                                  context
                                      .pushNamed(VehicleImageWidget.routeName);
                                },
                                hasDocument: FFAppState().vehicleImage != null,
                                isOnServer:
                                    _serverDocuments['vehicleImage'] ?? false,
                              ),

                              SizedBox(height: 4.0),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              SizedBox(height: 4.0),

                              // Registration Certificate Item
                              _buildStepItem(
                                context: context,
                                title: FFLocalizations.of(context).getText(
                                  'ipks4vgn' /* Registration Certificate (RC) */,
                                ),
                                subtitle: _getDocumentStatus(
                                  FFAppState().registrationImage,
                                  _serverDocuments['registrationImage'] ??
                                      false,
                                ),
                                onTap: () {
                                  context.pushNamed(
                                      RegistrationImageWidget.routeName);
                                },
                                hasDocument:
                                    FFAppState().registrationImage != null,
                                isOnServer:
                                    _serverDocuments['registrationImage'] ??
                                        false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Update Button
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 16.0, 24.0, 24.0),
                        child: FFButtonWidget(
                          onPressed: _isLoading ? null : _handleUpdateDocuments,
                          text: _isLoading
                              ? FFLocalizations.of(context).getVariableText(
                                  enText: 'Updating...',
                                  hiText: 'अपडेट हो रहा है...',
                                  teText: 'అప్‌డేట్ అవుతోంది...',
                                )
                              : FFLocalizations.of(context).getVariableText(
                                  enText: 'Update Documents',
                                  hiText: 'दस्तावेज़ अपडेट करें',
                                  teText: 'పత్రాలను నవీకరించండి',
                                ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconAlignment: IconAlignment.start,
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _isLoading
                                ? FlutterFlowTheme.of(context).secondaryText
                                : Color(0xFFFF7B10),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading Overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get document upload status text
  String _getDocumentStatus(dynamic document, bool isOnServer) {
    if (document != null) {
      // New document ready to upload
      return FFLocalizations.of(context).getVariableText(
        enText: 'Ready to upload ⬆',
        hiText: 'अपलोड के लिए तैयार ⬆',
        teText: 'అప్‌లోడ్ చేయడానికి సిద్ధంగా ⬆',
      );
    } else if (isOnServer) {
      // Already uploaded to server
      return FFLocalizations.of(context).getVariableText(
        enText: 'Uploaded ✓',
        hiText: 'अपलोड किया गया ✓',
        teText: 'అప్‌లోడ్ చేయబడింది ✓',
      );
    } else {
      // Not uploaded
      return FFLocalizations.of(context).getVariableText(
        enText: 'Not uploaded',
        hiText: 'अपलोड नहीं किया गया',
        teText: 'అప్‌లోడ్ చేయబడలేదు',
      );
    }
  }

  /// Helper method to build consistent step items
  Widget _buildStepItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool hasDocument = false,
    bool isOnServer = false,
  }) {
    // Determine the status: newly selected, on server, or missing
    bool showGreen = hasDocument || isOnServer;
    bool showOrange = hasDocument && !isOnServer; // Ready to upload

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: showOrange
                ? Colors.orange.withOpacity(0.5)
                : showGreen
                    ? Colors.green.withOpacity(0.3)
                    : FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Document Icon
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: showOrange
                    ? Colors.orange.withOpacity(0.1)
                    : showGreen
                        ? Colors.green.withOpacity(0.1)
                        : FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                showOrange
                    ? Icons.cloud_upload
                    : showGreen
                        ? Icons.check_circle
                        : Icons.upload_file,
                color: showOrange
                    ? Colors.orange
                    : showGreen
                        ? Colors.green
                        : FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
            ),
            SizedBox(width: 12.0),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(),
                            color: showOrange
                                ? Colors.orange
                                : showGreen
                                    ? Colors.green
                                    : FlutterFlowTheme.of(context)
                                        .secondaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}