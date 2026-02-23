import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:convert';
import 'face_verify_model.dart';
export 'face_verify_model.dart';

class FaceVerifyupdateWidget extends StatefulWidget {
  const FaceVerifyupdateWidget({super.key});

  static String routeName = 'face_verify_update';
  static String routePath = '/faceVerifyUpdate';

  @override
  State<FaceVerifyupdateWidget> createState() => _FaceVerifyupdateWidgetState();
}

class _FaceVerifyupdateWidgetState extends State<FaceVerifyupdateWidget>
    with SingleTickerProviderStateMixin {
  late FaceVerifyModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  // Profile photo variables
  FFUploadedFile? _profilePhoto;
  String? _profilePhotoUrl;
  bool _isProfilePhotoValid = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FaceVerifyModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();

    // Load saved data
    _loadSavedData();

    // Debug
    _debugPrintState();
  }

  void _debugPrintState() {
    debugPrint('\n═══════════════════════════════════════');
    debugPrint('📊 Profile Photo FFAppState Debug Info:');
    debugPrint('═══════════════════════════════════════');
    debugPrint(
        'Profile Photo (bytes): ${FFAppState().profilePhoto?.bytes?.length ?? 0}');
    debugPrint('Profile Photo URL: ${FFAppState().profilePhotoUrl}');
    debugPrint(
        'Profile Photo Base64: ${FFAppState().profilePhotoBase64.length} chars');
    debugPrint('═══════════════════════════════════════\n');
  }

  void _loadSavedData() {
    debugPrint('🔄 Loading saved profile photo...');

    // Load profile photo - Priority: Base64 > URL > Bytes
    if (FFAppState().profilePhotoBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().profilePhotoBase64);
        setState(() {
          _profilePhoto = FFUploadedFile(
            bytes: bytes,
            name: 'profile_photo.jpg',
          );
          _model.uploadedLocalFile_uploadDataFvd = _profilePhoto!;
          _isProfilePhotoValid = true;
        });
        debugPrint('✅ Profile photo loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        debugPrint('❌ Error decoding profile photo Base64: $e');
      }
    } else if (FFAppState().profilePhotoUrl.isNotEmpty) {
      setState(() {
        _profilePhotoUrl = FFAppState().profilePhotoUrl;
        _isProfilePhotoValid = true;
      });
      debugPrint('✅ Profile photo URL loaded: ${FFAppState().profilePhotoUrl}');
    } else if (FFAppState().profilePhoto?.bytes != null &&
        FFAppState().profilePhoto!.bytes!.isNotEmpty) {
      setState(() {
        _profilePhoto = FFAppState().profilePhoto;
        _model.uploadedLocalFile_uploadDataFvd = _profilePhoto!;
        _isProfilePhotoValid = true;
      });
      debugPrint('✅ Profile photo loaded from memory');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 🔥 CAMERA ONLY - Fraud Prevention
  Future<void> _takeCameraPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front, // Force front camera
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();

        setState(() {
          _profilePhoto = FFUploadedFile(
            name: photo.name,
            bytes: bytes,
          );
          _model.uploadedLocalFile_uploadDataFvd = _profilePhoto!;
          _profilePhotoUrl = null;
          _isProfilePhotoValid = true;
        });

        // Save to FFAppState (bytes + Base64)
        FFAppState().profilePhoto = _profilePhoto;

        // Convert to Base64 for persistence
        String base64Image = base64Encode(bytes);
        FFAppState().profilePhotoBase64 = base64Image;
        FFAppState().update(() {});

        debugPrint('✅ Camera photo saved to FFAppState');
        debugPrint('   Bytes: ${bytes.length}');
        debugPrint('   Base64: ${base64Image.length} chars');

        _showSnackBar('Profile photo captured!');
      } else {
        debugPrint('❌ Camera cancelled by user');
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      _showSnackBar('Camera error: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage =
        (_profilePhoto?.bytes != null && _profilePhoto!.bytes!.isNotEmpty) ||
            (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.registrationOrange, AppColors.accentCoral],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_taxi, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'UGQ TAXI',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.registrationOrange.withValues(alpha:0.1),
                            AppColors.accentCoral.withValues(alpha:0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.registrationOrange.withValues(alpha:0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.registrationOrange.withValues(alpha:0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_circle,
                                  color: AppColors.registrationOrange,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Take your profile photo',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textNearBlack,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Live camera only - Fraud prevention',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your profile photo helps others recognize you and builds trust with passengers.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.greyMedium,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Security Notice',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'For fraud prevention, you must take a live photo using your camera. Gallery photos are not allowed.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green[800],
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Photo Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tips_and_updates,
                                  color: AppColors.registrationOrange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Photo Guidelines',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildGuideline(
                              'Make sure your face is clearly visible and well-lit'),
                          _buildGuideline(
                              'Remove sunglasses, hats, or anything covering your face'),
                          _buildGuideline(
                              'Use front camera and face directly at the camera'),
                          _buildGuideline('Neutral expression with eyes open'),
                          _buildGuideline('Avoid blurry or low-quality images'),
                          _buildGuideline(
                              '🔒 Live photo required - No saved photos allowed'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Profile Photo Card
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _takeCameraPhoto,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.backgroundLight,
                                      AppColors.backgroundMuted
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isProfilePhotoValid
                                        ? Colors.green
                                        : (hasImage
                                            ? AppColors.registrationOrange
                                            : Colors.grey[300]!),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isProfilePhotoValid
                                              ? Colors.green
                                              : AppColors.registrationOrange)
                                          .withValues(alpha:0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Image Display
                                    ClipOval(
                                      child: _profilePhoto?.bytes != null &&
                                              _profilePhoto!.bytes!.isNotEmpty
                                          ? Image.memory(
                                              _profilePhoto!.bytes!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : (_profilePhotoUrl != null &&
                                                  _profilePhotoUrl!.isNotEmpty)
                                              ? Image.network(
                                                  _profilePhotoUrl!,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                        color:
                                                            AppColors.registrationOrange,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons.error_outline,
                                                            size: 48,
                                                            color: Colors.red),
                                                        const SizedBox(height: 8),
                                                        Text(FFLocalizations.of(context).getText('face0024'),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ],
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                                  0xFFFF8C00)
                                                              .withValues(alpha:0.1),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.camera_front,
                                                          size: 48,
                                                          color:
                                                              AppColors.registrationOrange,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      const Text(
                                                        'Tap to capture',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.textNearBlack,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Live camera only',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.green[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                    ),

                                    // VERIFIED STAMP
                                    if (hasImage && _isProfilePhotoValid)
                                      Center(
                                        child: CustomPaint(
                                          size: const Size(100, 100),
                                          painter: VerifiedStampPainter(),
                                        ),
                                      ),

                                    // Remove button
                                    if (hasImage)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _profilePhoto = null;
                                              _model.uploadedLocalFile_uploadDataFvd =
                                                  FFUploadedFile(
                                                      bytes: Uint8List.fromList(
                                                          []));
                                              _profilePhotoUrl = null;
                                              _isProfilePhotoValid = false;
                                            });

                                            // Clear from FFAppState
                                            FFAppState().profilePhoto = null;
                                            FFAppState().profilePhotoUrl = '';
                                            FFAppState().profilePhotoBase64 =
                                                '';
                                            FFAppState().update(() {});

                                            debugPrint(
                                                '❌ Profile photo removed from FFAppState');

                                            _showSnackBar(
                                                'Profile photo removed',
                                                isError: true);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha:0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (hasImage)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isProfilePhotoValid
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      size: 16,
                                      color: _isProfilePhotoValid
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isProfilePhotoValid
                                          ? '✓ Photo verified'
                                          : 'Photo captured',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _isProfilePhotoValid
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Take Photo Button (if no image)
                    if (!hasImage)
                      FFButtonWidget(
                        onPressed: _takeCameraPhoto,
                        text: 'Open Camera',
                        icon: const Icon(Icons.camera_front, size: 20),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          color: AppColors.registrationOrange,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),

                    // Continue Button (if image exists)
                    if (hasImage)
                      Column(
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              // Save to FFAppState
                              FFAppState().profilePhoto = _profilePhoto;

                              // Save Base64 for persistence
                              if (_profilePhoto?.bytes != null) {
                                FFAppState().profilePhotoBase64 =
                                    base64Encode(_profilePhoto!.bytes!);
                              }

                              // If you have URL from server, save it
                              if (_profilePhotoUrl != null &&
                                  _profilePhotoUrl!.isNotEmpty) {
                                FFAppState().profilePhotoUrl =
                                    _profilePhotoUrl!;
                              }

                              FFAppState().update(() {});

                              debugPrint('✅ Profile photo saved to FFAppState:');
                              debugPrint(
                                  '   Image: ${_profilePhoto?.bytes?.length ?? 0} bytes');
                              debugPrint('   URL: ${_profilePhotoUrl ?? "None"}');
                              debugPrint(
                                  '   Base64: ${FFAppState().profilePhotoBase64.length} chars');

                              _showSnackBar(
                                  'Profile photo saved successfully!');

                              // Navigate back
                              await Future.delayed(const Duration(milliseconds: 500));
                              context.pop();
                            },
                            text: 'Continue',
                            icon: const Icon(Icons.arrow_forward, size: 20),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              color: AppColors.registrationOrange,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _takeCameraPhoto,
                            icon: const Icon(Icons.refresh, color: AppColors.registrationOrange),
                            label: const Text(
                              'Retake Photo',
                              style: TextStyle(
                                color: AppColors.registrationOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.registrationOrange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyMedium,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ VERIFIED STAMP PAINTER (same as before)
class VerifiedStampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = AppColors.successDark.withValues(alpha:0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    const numTeeth = 24;
    for (int i = 0; i < numTeeth; i++) {
      final angle = (i * 2 * pi / numTeeth);
      final outerRadius = radius;
      final innerRadius = radius - 6;
      final outerX = center.dx + outerRadius * cos(angle);
      final outerY = center.dy + outerRadius * sin(angle);
      final innerX = center.dx + innerRadius * cos(angle + pi / numTeeth);
      final innerY = center.dy + innerRadius * sin(angle + pi / numTeeth);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outerPaint);

    final innerCirclePaint = Paint()
      ..color = AppColors.successDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, innerCirclePaint);

    final bannerY = center.dy;
    const bannerHeight = 22.0;
    final bannerWidth = size.width * 0.85;
    final bannerLeft = center.dx - bannerWidth / 2;

    final ribbonPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        bannerLeft,
        bannerY - bannerHeight / 2,
        bannerWidth,
        bannerHeight,
      ),
      ribbonPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'VERIFIED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        bannerY - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
