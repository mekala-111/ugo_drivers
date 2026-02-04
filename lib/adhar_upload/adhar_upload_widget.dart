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
import 'dart:typed_data';
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
  }

  // Debug function to see what's in FFAppState
  void _debugPrintState() {
    print('\n═══════════════════════════════════════');
    print('📊 FFAppState Debug Info:');
    print('═══════════════════════════════════════');
    print(
        'Front Image (bytes): ${FFAppState().aadharImage?.bytes?.length ?? 0}');
    print('Front Image URL: ${FFAppState().aadharFrontImageUrl}');
    print('Front Base64: ${FFAppState().aadharFrontBase64.length} chars');
    print(
        'Back Image (bytes): ${FFAppState().aadharBackImage?.bytes?.length ?? 0}');
    print('Back Image URL: ${FFAppState().aadharBackImageUrl}');
    print('Back Base64: ${FFAppState().aadharBackBase64.length} chars');
    print('Aadhaar Number: ${FFAppState().aadharNumber}');
    print('═══════════════════════════════════════\n');
  }

  // Load previously saved images and Aadhaar number
  void _loadSavedData() {
    print('🔄 Loading saved data...');

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
        print('✅ Front image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        print('❌ Error decoding front Base64: $e');
      }
    } else if (FFAppState().aadharFrontImageUrl.isNotEmpty) {
      setState(() {
        _frontImageUrl = FFAppState().aadharFrontImageUrl;
        _isFrontValid = true;
      });
      print('✅ Front image URL loaded: ${FFAppState().aadharFrontImageUrl}');
    } else if (FFAppState().aadharImage?.bytes != null &&
        FFAppState().aadharImage!.bytes!.isNotEmpty) {
      setState(() {
        _frontImage = FFAppState().aadharImage;
        _isFrontValid = true;
      });
      print('✅ Front image loaded from memory');
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
        print('✅ Back image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        print('❌ Error decoding back Base64: $e');
      }
    } else if (FFAppState().aadharBackImageUrl.isNotEmpty) {
      setState(() {
        _backImageUrl = FFAppState().aadharBackImageUrl;
        _isBackValid = true;
      });
      print('✅ Back image URL loaded: ${FFAppState().aadharBackImageUrl}');
    } else if (FFAppState().aadharBackImage?.bytes != null &&
        FFAppState().aadharBackImage!.bytes!.isNotEmpty) {
      setState(() {
        _backImage = FFAppState().aadharBackImage;
        _isBackValid = true;
      });
      print('✅ Back image loaded from memory');
    }

    // Load saved Aadhaar number and auto-fill
    if (FFAppState().aadharNumber.isNotEmpty) {
      String formattedNumber = _formatAadhaarNumber(FFAppState().aadharNumber);
      setState(() {
        _aadhaarController.text = formattedNumber;
        _isAadhaarValid = _validateAadhaar(formattedNumber) == null;
      });
      print('✅ Aadhaar number loaded: ${FFAppState().aadharNumber}');
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
      return 'Please enter Aadhaar number';
    }

    String cleanedValue = value.replaceAll(' ', '');

    if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
      return 'Aadhaar must contain only numbers';
    }

    if (cleanedValue.length != 12) {
      return 'Aadhaar must be 12 digits';
    }

    if (cleanedValue[0] == '0' || cleanedValue[0] == '1') {
      return 'Invalid Aadhaar number';
    }

    if (!_validateAadhaarWithVerhoeff(cleanedValue)) {
      return 'Invalid Aadhaar number';
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
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFFFF8C00), size: 20),
              SizedBox(width: 8),
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
          SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 180.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isValid
                      ? Colors.green
                      : (hasImage ? Color(0xFFFF8C00) : Colors.grey[300]!),
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
                                      color: Color(0xFFFF8C00),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 40, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text('Failed to load image',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFFF8C00).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 40.0,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap to upload $title',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Camera or Gallery',
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
                        size: Size(120, 120),
                        painter: VerifiedStampPainter(),
                      ),
                    ),

                  // Top-right corner - Remove button
                  if (hasImage)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Tooltip(
                        message: 'Remove image',
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
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
              padding: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    isValid ? Icons.check_circle : Icons.info_outline,
                    size: 14,
                    color: isValid ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isValid ? '✓ Verified and uploaded' : 'Image uploaded',
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
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
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
              Icon(Icons.local_taxi, color: Colors.white, size: 24),
              SizedBox(width: 8),
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
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF8C00).withOpacity(0.1),
                              Color(0xFFFF6B00).withOpacity(0.05)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFFF8C00).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF8C00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.card_membership,
                                color: Color(0xFFFF8C00),
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload Aadhaar Card',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Both sides required',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Front Side
                      _buildImageCard(
                        title: 'Front Side',
                        subtitle: 'Photo & Aadhaar number visible',
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
                              print('❌ Error creating uploaded file: $e');
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
                                print(
                                    '✅ Front image saved as Base64 (${base64Image.length} chars)');
                              }

                              FFAppState().update(() {});

                              print('✅ Front image saved to FFAppState');
                              print('   Bytes: ${_frontImage?.bytes?.length}');

                              _showSnackBar('Front side uploaded!');
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

                          print('❌ Front image removed from FFAppState');

                          _showSnackBar('Front side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 20),

                      // Back Side
                      _buildImageCard(
                        title: 'Back Side',
                        subtitle: 'Address details visible',
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
                              print('❌ Error creating uploaded file: $e');
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
                                print(
                                    '✅ Back image saved as Base64 (${base64Image.length} chars)');
                              }

                              FFAppState().update(() {});

                              print('✅ Back image saved to FFAppState');
                              print('   Bytes: ${_backImage?.bytes?.length}');

                              _showSnackBar('Back side uploaded!');
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

                          print('❌ Back image removed from FFAppState');

                          _showSnackBar('Back side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 24),

                      // Aadhaar Number with Auto-fill Badge
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  color: Color(0xFFFF8C00),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Aadhaar Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // Auto-filled badge
                                if (_aadhaarController.text.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Saved',
                                            style: TextStyle(
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
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _aadhaarController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                                _AadhaarInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: 'XXXX XXXX XXXX',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.credit_card,
                                  color: Color(0xFFFF8C00),
                                ),
                                suffixIcon: _isAadhaarValid
                                    ? Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
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
                                  borderSide: BorderSide(
                                      color: Color(0xFFFF8C00), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2),
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
                                  print(
                                      '💾 Aadhaar saved: ${FFAppState().aadharNumber}');
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 14, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _aadhaarController.text.isEmpty
                                        ? 'Enter 12-digit Aadhaar number'
                                        : 'Aadhaar number verified ✓',
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

                      SizedBox(height: 24),

                      // Guidelines
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF4E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Color(0xFFFF8C00).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: Color(0xFFFF8C00), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Important Guidelines',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildGuideline('Upload both front and back sides'),
                            _buildGuideline(
                                'All four corners should be visible'),
                            _buildGuideline('Avoid glare and shadows'),
                            _buildGuideline('Text should be clearly readable'),
                            _buildGuideline(
                                'Verified stamp appears after upload'),
                            _buildGuideline(
                                '✓ Images persist after app restart'),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

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
                              _showSnackBar('Please upload front side',
                                  isError: true);
                              return;
                            }
                            if (!hasBackImage) {
                              _showSnackBar('Please upload back side',
                                  isError: true);
                              return;
                            }

                            // Save all data to FFAppState
                            FFAppState().aadharImage = _frontImage;
                            FFAppState().aadharBackImage = _backImage;
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

                            print('✅ All data saved to FFAppState:');
                            print(
                                '   Front: ${_frontImage?.bytes?.length ?? 0} bytes');
                            print('   Front URL: ${_frontImageUrl ?? "None"}');
                            print(
                                '   Front Base64: ${FFAppState().aadharFrontBase64.length} chars');
                            print(
                                '   Back: ${_backImage?.bytes?.length ?? 0} bytes');
                            print('   Back URL: ${_backImageUrl ?? "None"}');
                            print(
                                '   Back Base64: ${FFAppState().aadharBackBase64.length} chars');
                            print('   Number: ${FFAppState().aadharNumber}');

                            _showSnackBar('Aadhaar verification completed!');

                            // Navigate back to previous page
                            await Future.delayed(Duration(milliseconds: 500));
                            context.pop();
                          }
                        },
                        text: 'Submit',
                        icon: Icon(Icons.arrow_forward, size: 20),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          color: Color(0xFFFF8C00),
                          textStyle: TextStyle(
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
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, size: 18, color: Color(0xFFFF8C00)),
          SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
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
      ..color = Color(0xFF2E7D32).withOpacity(0.9)
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
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw border
    canvas.drawPath(path, outerPaint);

    // Draw inner circles
    final innerCirclePaint = Paint()
      ..color = Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 12, innerCirclePaint);
    canvas.drawCircle(center, radius - 16, innerCirclePaint);

    // Draw stars between circles
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) - pi / 2;
      final starX = center.dx + (radius - 14) * cos(angle);
      final starY = center.dy + (radius - 14) * sin(angle);
      _drawStar(canvas, Offset(starX, starY), 2.5, Color(0xFF2E7D32));
    }

    // Draw "VERIFIED" text in circle (top)
    _drawCurvedText(
      canvas,
      'VERIFIED',
      center,
      radius - 25,
      -pi,
      Color(0xFF2E7D32),
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
      Color(0xFF2E7D32),
      14,
      FontWeight.bold,
    );

    // Draw blue ribbon banner
    final bannerY = center.dy;
    final bannerHeight = 28.0;
    final bannerWidth = size.width * 0.85;
    final bannerLeft = center.dx - bannerWidth / 2;
    final bannerRight = center.dx + bannerWidth / 2;

    // Draw ribbon shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
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
      ..color = Color(0xFF1976D2)
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
      ..color = Color(0xFF0D47A1)
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
      ..color = Color(0xFF1565C0)
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
      text: TextSpan(
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
    final angleStep = 0.3;

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
