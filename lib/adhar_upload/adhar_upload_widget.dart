import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:convert';
import 'adhar_upload_model.dart';
export 'adhar_upload_model.dart';

class AdharUploadWidget extends StatefulWidget {
  const AdharUploadWidget({super.key});

  static String routeName = 'Adhar_Upload';
  static String routePath = '/adharUpload';

  @override
  State<AdharUploadWidget> createState() => _AdharUploadWidgetState();
}

class _AdharUploadWidgetState extends State<AdharUploadWidget>
    with SingleTickerProviderStateMixin {
  late AdharUploadModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _aadhaarController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Front side variables
  FFUploadedFile? _frontImage;
  String? _frontImageUrl;
  bool _isFrontValid = false;

  // Back side variables
  FFUploadedFile? _backImage;
  String? _backImageUrl;
  bool _isBackValid = false;

  bool _isAadhaarValid = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdharUploadModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Load saved data from FFAppState
    _loadSavedData();

    // Debug what was loaded
    _debugPrintState();

    _aadhaarController.addListener(() {
      FFAppState().aadharNumber =
          _aadhaarController.text.replaceAll(' ', '');
    });
  }

  // Debug function to see what's in FFAppState
  void _debugPrintState() {
    debugPrint('\n═══════════════════════════════════════');
    debugPrint('📊 FFAppState Debug Info:');
    debugPrint('═══════════════════════════════════════');
    debugPrint(
        'Front Image (bytes): ${FFAppState().aadharImage?.bytes?.length ?? 0}');
    debugPrint('Front Image URL: ${FFAppState().aadharFrontImageUrl}');
    debugPrint('Front Base64: ${FFAppState().aadharFrontBase64.length} chars');
    debugPrint(
        'Back Image (bytes): ${FFAppState().aadharBackImage?.bytes?.length ?? 0}');
    debugPrint('Back Image URL: ${FFAppState().aadharBackImageUrl}');
    debugPrint('Back Base64: ${FFAppState().aadharBackBase64.length} chars');
    debugPrint('Aadhaar Number: ${FFAppState().aadharNumber}');
    debugPrint('═══════════════════════════════════════\n');
  }

  // Load previously saved images and Aadhaar number
  void _loadSavedData() {
    debugPrint('🔄 Loading saved data...');

    // FRONT IMAGE LOADING PRIORITY:
    // 1. Check Base64 (persisted across restarts)
    // 2. Check URL (from server)
    // 3. Check bytes (current session only)

    if (FFAppState().aadharFrontBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().aadharFrontBase64);
        setState(() {
          _frontImage = FFUploadedFile(
            bytes: bytes,
            name: 'front_aadhaar.jpg',
          );
          _isFrontValid = true;
        });
        debugPrint('✅ Front image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        debugPrint('❌ Error decoding front Base64: $e');
      }
    } else if (FFAppState().aadharFrontImageUrl.isNotEmpty) {
      setState(() {
        _frontImageUrl = FFAppState().aadharFrontImageUrl;
        _isFrontValid = true;
      });
      debugPrint('✅ Front image URL loaded: ${FFAppState().aadharFrontImageUrl}');
    } else if (FFAppState().aadharImage?.bytes != null &&
        FFAppState().aadharImage!.bytes!.isNotEmpty) {
      setState(() {
        _frontImage = FFAppState().aadharImage;
        _isFrontValid = true;
      });
      debugPrint('✅ Front image loaded from memory');
    }

    // BACK IMAGE LOADING PRIORITY:
    // 1. Check Base64 (persisted across restarts)
    // 2. Check URL (from server)
    // 3. Check bytes (current session only)

    if (FFAppState().aadharBackBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().aadharBackBase64);
        setState(() {
          _backImage = FFUploadedFile(
            bytes: bytes,
            name: 'back_aadhaar.jpg',
          );
          _isBackValid = true;
        });
        debugPrint('✅ Back image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        debugPrint('❌ Error decoding back Base64: $e');
      }
    } else if (FFAppState().aadharBackImageUrl.isNotEmpty) {
      setState(() {
        _backImageUrl = FFAppState().aadharBackImageUrl;
        _isBackValid = true;
      });
      debugPrint('✅ Back image URL loaded: ${FFAppState().aadharBackImageUrl}');
    } else if (FFAppState().aadharBackImage?.bytes != null &&
        FFAppState().aadharBackImage!.bytes!.isNotEmpty) {
      setState(() {
        _backImage = FFAppState().aadharBackImage;
        _isBackValid = true;
      });
      debugPrint('✅ Back image loaded from memory');
    }

    // Load saved Aadhaar number and auto-fill
    if (FFAppState().aadharNumber.isNotEmpty) {
      String formattedNumber = _formatAadhaarNumber(FFAppState().aadharNumber);
      setState(() {
        _aadhaarController.text = formattedNumber;
        _isAadhaarValid = _validateAadhaar(formattedNumber) == null;
      });
      debugPrint('✅ Aadhaar number loaded: ${FFAppState().aadharNumber}');
    }
  }

  // Format Aadhaar number with spaces
  String _formatAadhaarNumber(String number) {
    String cleaned = number.replaceAll(' ', '');
    if (cleaned.length != 12) return number;

    return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)}';
  }

  @override
  void dispose() {
    _model.dispose();
    _aadhaarController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Verhoeff Algorithm for Aadhaar Validation
  bool _validateAadhaarWithVerhoeff(String aadhaar) {
    if (aadhaar.length != 12) return false;

    List<List<int>> d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
    ];

    List<List<int>> p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
    ];

    int c = 0;
    List<int> invertedArray =
        aadhaar.split('').map(int.parse).toList().reversed.toList();

    for (int i = 0; i < invertedArray.length; i++) {
      c = d[c][p[(i % 8)][invertedArray[i]]];
    }

    return c == 0;
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return FFLocalizations.of(context).getText('aad0014');
    }

    String cleanedValue = value.replaceAll(' ', '');

    if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
      return FFLocalizations.of(context).getText('aad0015');
    }

    if (cleanedValue.length != 12) {
      return FFLocalizations.of(context).getText('aad0016');
    }

    if (cleanedValue[0] == '0' || cleanedValue[0] == '1') {
      return FFLocalizations.of(context).getText('aad0017');
    }

    if (!_validateAadhaarWithVerhoeff(cleanedValue)) {
      return FFLocalizations.of(context).getText('aad0017');
    }

    return null;
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

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required IconData icon,
    FFUploadedFile? image,
    String? imageUrl,
    required bool isValid,
    required Function() onTap,
    required Function()? onRemove,
  }) {
    bool hasImage = (image?.bytes != null && image!.bytes!.isNotEmpty) ||
        (imageUrl != null && imageUrl.isNotEmpty);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.registrationOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 180.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.backgroundLight, AppColors.backgroundMuted],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isValid
                      ? Colors.green
                      : (hasImage ? AppColors.registrationOrange : Colors.grey[300]!),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Stack(
                children: [
                  // Image Display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: image?.bytes != null && image!.bytes!.isNotEmpty
                        ? Image.memory(
                            image.bytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : (imageUrl != null && imageUrl.isNotEmpty)
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: AppColors.registrationOrange,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline,
                                          size: 40, color: Colors.red),
                                      const SizedBox(height: 8),
                                      Text(
                                        FFLocalizations.of(context)
                                            .getText('upload0006'),
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.registrationOrange.withValues(alpha:0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        size: 40.0,
                                        color: AppColors.registrationOrange,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      FFLocalizations.of(context)
                                          .getText('doc0009')
                                          .replaceAll('%1', title),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textNearBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FFLocalizations.of(context)
                                          .getText('upload0004'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),

                  // VERIFIED STAMP WATERMARK (Center)
                  if (hasImage && isValid)
                    Center(
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: VerifiedStampPainter(),
                      ),
                    ),

                  // Top-right corner - Remove button
                  if (hasImage)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Tooltip(
                        message: FFLocalizations.of(context)
                            .getText('upload0007'),
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
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
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    isValid ? Icons.check_circle : Icons.info_outline,
                    size: 14,
                    color: isValid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isValid
                          ? FFLocalizations.of(context).getText('doc0007')
                          : FFLocalizations.of(context).getText('doc0008'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isValid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.registrationOrange.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.card_membership,
                                color: AppColors.registrationOrange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(context)
                                        .getText('aad0001'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textNearBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FFLocalizations.of(context)
                                        .getText('aad0002'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Front Side
                      _buildImageCard(
                        title: FFLocalizations.of(context).getText('doc0001'),
                        subtitle: FFLocalizations.of(context)
                          .getText('aad0003'),
                        icon: Icons.credit_card,
                        image: _frontImage,
                        imageUrl: _frontImageUrl,
                        isValid: _isFrontValid,
                        onTap: () async {
                          final selectedMedia =
                              await selectMediaWithSourceBottomSheet(
                            context: context,
                            allowPhoto: true,
                          );
                          if (selectedMedia != null &&
                              selectedMedia.every((m) =>
                                  validateFileFormat(m.storagePath, context))) {
                            var selectedUploadedFiles = <FFUploadedFile>[];
                            try {
                              selectedUploadedFiles = selectedMedia
                                  .map((m) => FFUploadedFile(
                                        name: m.storagePath.split('/').last,
                                        bytes: m.bytes,
                                        height: m.dimensions?.height,
                                        width: m.dimensions?.width,
                                        blurHash: m.blurHash,
                                        originalFilename: m.originalFilename,
                                      ))
                                  .toList();
                            } catch (e) {
                              debugPrint('❌ Error creating uploaded file: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _frontImage = selectedUploadedFiles.first;
                                _frontImageUrl = null;
                                _isFrontValid = true;
                              });

                              // ✅ Save to FFAppState (bytes + Base64)
                              FFAppState().aadharImage = _frontImage;

                              // Convert to Base64 for persistence
                              if (_frontImage?.bytes != null) {
                                String base64Image =
                                    base64Encode(_frontImage!.bytes!);
                                FFAppState().aadharFrontBase64 = base64Image;
                                debugPrint(
                                    '✅ Front image saved as Base64 (${base64Image.length} chars)');
                              }

                              FFAppState().update(() {});

                              debugPrint('✅ Front image saved to FFAppState');
                              debugPrint('   Bytes: ${_frontImage?.bytes?.length}');

                                _showSnackBar(FFLocalizations.of(context)
                                  .getText('doc0003'));
                            }
                          }
                        },
                        onRemove: () {
                          setState(() {
                            _frontImage = null;
                            _frontImageUrl = null;
                            _isFrontValid = false;
                          });

                          // Clear from FFAppState
                          FFAppState().aadharImage = null;
                          FFAppState().aadharFrontImageUrl = '';
                          FFAppState().aadharFrontBase64 = '';
                          FFAppState().update(() {});

                          debugPrint('❌ Front image removed from FFAppState');

                            _showSnackBar(
                              FFLocalizations.of(context).getText('doc0005'),
                              isError: true);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Back Side
                      _buildImageCard(
                        title: FFLocalizations.of(context).getText('doc0002'),
                        subtitle: FFLocalizations.of(context)
                          .getText('aad0004'),
                        icon: Icons.contact_mail,
                        image: _backImage,
                        imageUrl: _backImageUrl,
                        isValid: _isBackValid,
                        onTap: () async {
                          final selectedMedia =
                              await selectMediaWithSourceBottomSheet(
                            context: context,
                            allowPhoto: true,
                          );
                          if (selectedMedia != null &&
                              selectedMedia.every((m) =>
                                  validateFileFormat(m.storagePath, context))) {
                            var selectedUploadedFiles = <FFUploadedFile>[];
                            try {
                              selectedUploadedFiles = selectedMedia
                                  .map((m) => FFUploadedFile(
                                        name: m.storagePath.split('/').last,
                                        bytes: m.bytes,
                                        height: m.dimensions?.height,
                                        width: m.dimensions?.width,
                                        blurHash: m.blurHash,
                                        originalFilename: m.originalFilename,
                                      ))
                                  .toList();
                            } catch (e) {
                              debugPrint('❌ Error creating uploaded file: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _backImage = selectedUploadedFiles.first;
                                _backImageUrl = null;
                                _isBackValid = true;
                              });

                              // ✅ Save to FFAppState (bytes + Base64)
                              FFAppState().aadharBackImage = _backImage;

                              // Convert to Base64 for persistence
                              if (_backImage?.bytes != null) {
                                String base64Image =
                                    base64Encode(_backImage!.bytes!);
                                FFAppState().aadharBackBase64 = base64Image;
                                debugPrint(
                                    '✅ Back image saved as Base64 (${base64Image.length} chars)');
                              }

                              FFAppState().update(() {});

                              debugPrint('✅ Back image saved to FFAppState');
                              debugPrint('   Bytes: ${_backImage?.bytes?.length}');

                                _showSnackBar(FFLocalizations.of(context)
                                  .getText('doc0004'));
                            }
                          }
                        },
                        onRemove: () {
                          setState(() {
                            _backImage = null;
                            _backImageUrl = null;
                            _isBackValid = false;
                          });

                          // Clear from FFAppState
                          FFAppState().aadharBackImage = null;
                          FFAppState().aadharBackImageUrl = '';
                          FFAppState().aadharBackBase64 = '';
                          FFAppState().update(() {});

                          debugPrint('❌ Back image removed from FFAppState');

                            _showSnackBar(
                              FFLocalizations.of(context).getText('doc0006'),
                              isError: true);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Aadhaar Number with Auto-fill Badge
                      Container(
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: AppColors.registrationOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  FFLocalizations.of(context)
                                      .getText('aad0005'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // Auto-filled badge
                                if (_aadhaarController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            FFLocalizations.of(context)
                                                .getText('badge0001'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _aadhaarController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                                _AadhaarInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: FFLocalizations.of(context)
                                    .getText('aad0006'),
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(
                                  Icons.credit_card,
                                  color: AppColors.registrationOrange,
                                ),
                                suffixIcon: _isAadhaarValid
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.registrationOrange, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                              validator: _validateAadhaar,
                              onChanged: (value) {
                                setState(() {
                                  _isAadhaarValid =
                                      _validateAadhaar(value) == null;
                                });
                                // Save to FFAppState
                                if (_isAadhaarValid) {
                                  FFAppState().aadharNumber =
                                      value.replaceAll(' ', '');
                                  FFAppState().update(() {});
                                  debugPrint(
                                      '💾 Aadhaar saved: ${FFAppState().aadharNumber}');
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _aadhaarController.text.isEmpty
                                      ? FFLocalizations.of(context)
                                        .getText('aad0007')
                                      : FFLocalizations.of(context)
                                        .getText('aad0008'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _aadhaarController.text.isEmpty
                                          ? Colors.grey[600]
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Guidelines
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sectionOrangeLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.registrationOrange.withValues(alpha:0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    color: AppColors.registrationOrange, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                FFLocalizations.of(context)
                                  .getText('guide0001'),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('dl0013')),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('guide0002')),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('guide0003')),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('aad0009')),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('aad0010')),
                            _buildGuideline(
                              FFLocalizations.of(context).getText('guide0004')),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      FFButtonWidget(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Check if either bytes or URL exists
                            bool hasFrontImage = (_frontImage?.bytes != null) ||
                                (_frontImageUrl != null &&
                                    _frontImageUrl!.isNotEmpty);
                            bool hasBackImage = (_backImage?.bytes != null) ||
                                (_backImageUrl != null &&
                                    _backImageUrl!.isNotEmpty);

                            if (!hasFrontImage) {
                              _showSnackBar(
                                  FFLocalizations.of(context)
                                      .getText('aad0011'),
                                  isError: true);
                              return;
                            }
                            if (!hasBackImage) {
                              _showSnackBar(
                                  FFLocalizations.of(context)
                                      .getText('aad0012'),
                                  isError: true);
                              return;
                            }

                            // Save all data to FFAppState
                            FFAppState().aadharImage =
                                _frontImage; // Keep for backwards compatibility
                            FFAppState().aadhaarFrontImage =
                                _frontImage; // New front image property
                            FFAppState().aadhaarBackImage =
                                _backImage; // Back image property
                            FFAppState().aadharNumber =
                                _aadhaarController.text.replaceAll(' ', '');

                            // Save Base64 for persistence
                            if (_frontImage?.bytes != null) {
                              FFAppState().aadharFrontBase64 =
                                  base64Encode(_frontImage!.bytes!);
                            }
                            if (_backImage?.bytes != null) {
                              FFAppState().aadharBackBase64 =
                                  base64Encode(_backImage!.bytes!);
                            }

                            // If you have URLs from server, save them too
                            if (_frontImageUrl != null &&
                                _frontImageUrl!.isNotEmpty) {
                              FFAppState().aadharFrontImageUrl =
                                  _frontImageUrl!;
                            }
                            if (_backImageUrl != null &&
                                _backImageUrl!.isNotEmpty) {
                              FFAppState().aadharBackImageUrl = _backImageUrl!;
                            }

                            FFAppState().update(() {});

                            debugPrint('✅ All data saved to FFAppState:');
                            debugPrint(
                                '   Front: ${_frontImage?.bytes?.length ?? 0} bytes');
                            debugPrint('   Front URL: ${_frontImageUrl ?? "None"}');
                            debugPrint(
                                '   Front Base64: ${FFAppState().aadharFrontBase64.length} chars');
                            debugPrint(
                                '   Back: ${_backImage?.bytes?.length ?? 0} bytes');
                            debugPrint('   Back URL: ${_backImageUrl ?? "None"}');
                            debugPrint(
                                '   Back Base64: ${FFAppState().aadharBackBase64.length} chars');
                            debugPrint('   Number: ${FFAppState().aadharNumber}');

                            _showSnackBar(FFLocalizations.of(context)
                              .getText('aad0013'));

                            // Navigate back to previous page
                            await Future.delayed(const Duration(milliseconds: 500));
                            context.pop();
                          }
                        },
                        text: FFLocalizations.of(context).getText('drv_submit'),
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
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 18, color: AppColors.registrationOrange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: AppColors.greyMedium)),
          ),
        ],
      ),
    );
  }
}

// AADHAAR INPUT FORMATTER
class _AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ✅ VERIFIED STAMP PAINTER (Custom Watermark)
class VerifiedStampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer serrated circle (stamp edges)
    final outerPaint = Paint()
      ..color = AppColors.successDark.withValues(alpha:0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw serrated/zigzag edge
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

    // Fill background
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw border
    canvas.drawPath(path, outerPaint);

    // Draw inner circles
    final innerCirclePaint = Paint()
      ..color = AppColors.successDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 12, innerCirclePaint);
    canvas.drawCircle(center, radius - 16, innerCirclePaint);

    // Draw stars between circles
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) - pi / 2;
      final starX = center.dx + (radius - 14) * cos(angle);
      final starY = center.dy + (radius - 14) * sin(angle);
      _drawStar(canvas, Offset(starX, starY), 2.5, AppColors.successDark);
    }

    // Draw "VERIFIED" text in circle (top)
    _drawCurvedText(
      canvas,
      'VERIFIED',
      center,
      radius - 25,
      -pi,
      AppColors.successDark,
      14,
      FontWeight.bold,
    );

    // Draw "VERIFIED" text in circle (bottom)
    _drawCurvedText(
      canvas,
      'VERIFIED',
      center,
      radius - 25,
      0,
      AppColors.successDark,
      14,
      FontWeight.bold,
    );

    // Draw blue ribbon banner
    final bannerY = center.dy;
    const bannerHeight = 28.0;
    final bannerWidth = size.width * 0.85;
    final bannerLeft = center.dx - bannerWidth / 2;
    final bannerRight = center.dx + bannerWidth / 2;

    // Draw ribbon shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha:0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        bannerLeft + 2,
        bannerY - bannerHeight / 2 + 2,
        bannerWidth,
        bannerHeight,
      ),
      shadowPaint,
    );

    // Draw ribbon
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

    // Draw ribbon border
    final ribbonBorderPaint = Paint()
      ..color = AppColors.infoDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(
        bannerLeft,
        bannerY - bannerHeight / 2,
        bannerWidth,
        bannerHeight,
      ),
      ribbonBorderPaint,
    );

    // Draw ribbon folds (left)
    final leftFoldPath = Path();
    leftFoldPath.moveTo(bannerLeft, bannerY - bannerHeight / 2);
    leftFoldPath.lineTo(bannerLeft - 8, bannerY - bannerHeight / 2 + 6);
    leftFoldPath.lineTo(bannerLeft - 8, bannerY + bannerHeight / 2 - 6);
    leftFoldPath.lineTo(bannerLeft, bannerY + bannerHeight / 2);
    leftFoldPath.close();

    final leftFoldPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftFoldPath, leftFoldPaint);
    canvas.drawPath(leftFoldPath, ribbonBorderPaint);

    // Draw ribbon folds (right)
    final rightFoldPath = Path();
    rightFoldPath.moveTo(bannerRight, bannerY - bannerHeight / 2);
    rightFoldPath.lineTo(bannerRight + 8, bannerY - bannerHeight / 2 + 6);
    rightFoldPath.lineTo(bannerRight + 8, bannerY + bannerHeight / 2 - 6);
    rightFoldPath.lineTo(bannerRight, bannerY + bannerHeight / 2);
    rightFoldPath.close();

    canvas.drawPath(rightFoldPath, leftFoldPaint);
    canvas.drawPath(rightFoldPath, ribbonBorderPaint);

    // Draw "VERIFIED" text on ribbon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'VERIFIED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
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

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCurvedText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double startAngle,
    Color color,
    double fontSize,
    FontWeight fontWeight,
  ) {
    final textLength = text.length;
    const angleStep = 0.3;

    for (int i = 0; i < textLength; i++) {
      final angle = startAngle + (i - textLength / 2) * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: 1,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
