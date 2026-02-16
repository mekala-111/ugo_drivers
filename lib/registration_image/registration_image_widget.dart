import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'registration_image_model.dart';
export 'registration_image_model.dart';

class RegistrationImageWidget extends StatefulWidget {
  const RegistrationImageWidget({super.key});

  static String routeName = 'RegistrationImage';
  static String routePath = '/registrationImage';

  @override
  State<RegistrationImageWidget> createState() =>
      _RegistrationImageWidgetState();
}

class _RegistrationImageWidgetState extends State<RegistrationImageWidget>
    with SingleTickerProviderStateMixin {
  late RegistrationImageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _registrationNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // RC images - Front & Back
  FFUploadedFile? _frontImage;
  String? _frontImageUrl;
  bool _isFrontValid = false;

  FFUploadedFile? _backImage;
  String? _backImageUrl;
  bool _isBackValid = false;

  bool _isRegNumberValid = false;
  bool _isProcessingOCR = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegistrationImageModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    _loadSavedData();
    _debugPrintState();
  }

  void _debugPrintState() {
    print('\n═══════════════════════════════════════');
    print('📊 RC FFAppState Debug Info:');
    print('═══════════════════════════════════════');
    print(
        'RC Front (bytes): ${FFAppState().registrationImage?.bytes?.length ?? 0}');
    print('RC Front URL: ${FFAppState().rcFrontImageUrl}');
    print('RC Front Base64: ${FFAppState().rcFrontBase64.length} chars');
    print('RC Back (bytes): ${FFAppState().rcBackImage?.bytes?.length ?? 0}');
    print('RC Back URL: ${FFAppState().rcBackImageUrl}');
    print('RC Back Base64: ${FFAppState().rcBackBase64.length} chars');
    print('Registration Number: ${FFAppState().registrationNumber}');
    print('═══════════════════════════════════════\n');
  }

  void _loadSavedData() {
    print('🔄 Loading saved RC data...');

    // Load front image
    if (FFAppState().rcFrontBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().rcFrontBase64);
        setState(() {
          _frontImage = FFUploadedFile(bytes: bytes, name: 'rc_front.jpg');
          _model.uploadedLocalFile_uploadData1zx = _frontImage!;
          _isFrontValid = true;
        });
        print('✅ RC front loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        print('❌ Error decoding RC front Base64: $e');
      }
    } else if (FFAppState().rcFrontImageUrl.isNotEmpty) {
      setState(() {
        _frontImageUrl = FFAppState().rcFrontImageUrl;
        _isFrontValid = true;
      });
    } else if (FFAppState().registrationImage?.bytes != null &&
        FFAppState().registrationImage!.bytes!.isNotEmpty) {
      setState(() {
        _frontImage = FFAppState().registrationImage;
        _model.uploadedLocalFile_uploadData1zx = _frontImage!;
        _isFrontValid = true;
      });
    }

    // Load back image
    if (FFAppState().rcBackBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().rcBackBase64);
        setState(() {
          _backImage = FFUploadedFile(bytes: bytes, name: 'rc_back.jpg');
          _isBackValid = true;
        });
        print('✅ RC back loaded from Base64');
      } catch (e) {
        print('❌ Error decoding RC back Base64: $e');
      }
    } else if (FFAppState().rcBackImageUrl.isNotEmpty) {
      setState(() {
        _backImageUrl = FFAppState().rcBackImageUrl;
        _isBackValid = true;
      });
    } else if (FFAppState().rcBackImage?.bytes != null &&
        FFAppState().rcBackImage!.bytes!.isNotEmpty) {
      setState(() {
        _backImage = FFAppState().rcBackImage;
        _isBackValid = true;
      });
    }

    // Load registration number
    if (FFAppState().registrationNumber.isNotEmpty) {
      setState(() {
        _registrationNumberController.text =
            FFAppState().registrationNumber.toUpperCase();
        _isRegNumberValid =
            _validateRegistrationNumber(_registrationNumberController.text) ==
                null;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _registrationNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 🔥 OCR - Extract Registration Number from Image
  Future<void> _extractRegistrationNumberFromImage(FFUploadedFile image) async {
    if (image.bytes == null || image.bytes!.isEmpty) {
      print('❌ No image bytes to process');
      return;
    }

    setState(() => _isProcessingOCR = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_rc.jpg');
      await file.writeAsBytes(image.bytes!);

      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =

          await textRecognizer.processImage(inputImage);

      print('📝 OCR Text Extracted:');
      print(recognizedText.text);

      String? regNumber = _extractRegistrationNumber(recognizedText.text);

      if (regNumber != null) {
        setState(() {
          _registrationNumberController.text = regNumber;
          _isRegNumberValid = _validateRegistrationNumber(regNumber) == null;
        });

        FFAppState().registrationNumber = regNumber;
        FFAppState().update(() {});

        _showSnackBar('✅ Registration Number auto-filled: $regNumber');
        print('✅ Registration Number extracted: $regNumber');
      } else {
        _showSnackBar(
            '⚠️ Could not detect registration number. Please enter manually.',
            isError: true);
        print('❌ No valid registration number found in text');
      }

      await textRecognizer.close();
      await file.delete();
    } catch (e) {
      print('❌ OCR Error: $e');
      _showSnackBar('OCR failed. Please enter registration number manually.',
          isError: true);
    } finally {
      setState(() => _isProcessingOCR = false);
    }
  }

  String? _extractRegistrationNumber(String text) {
    String cleanedText = text.replaceAll(RegExp(r'\s+'), '');

    List<RegExp> patterns = [
      RegExp(r'[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{1,4}',
          caseSensitive: false),
      RegExp(r'[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}', caseSensitive: false),
      RegExp(r'[A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,2}\s?[0-9]{1,4}',
          caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(cleanedText);
      if (match != null) {
        String regNumber = match.group(0)!.toUpperCase();
        regNumber = regNumber.replaceAll(RegExp(r'[-\s]'), '');
        if (regNumber.length >= 9 && regNumber.length <= 10) {
          return regNumber;
        }
      }
    }

    return null;
  }

  String? _validateRegistrationNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter registration number';
    }

    String cleanedValue =
        value.trim().toUpperCase().replaceAll(RegExp(r'[-\s]'), '');
    RegExp regRegex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{1,4}$');

    if (!regRegex.hasMatch(cleanedValue)) {
      return 'Invalid format (e.g., DL03CW3121)';
    }

    if (cleanedValue.length < 9 || cleanedValue.length > 10) {
      return 'Registration must be 9-10 characters';
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
            Expanded(child: Text(message, style: TextStyle(fontSize: 14))),
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
    bool showOCROverlay = false,
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
                    Text(title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                ),
              ),
              child: Stack(
                children: [
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
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFFF8C00).withValues(alpha:0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.add_a_photo,
                                          size: 40, color: Color(0xFFFF8C00)),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap to upload $title',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Camera or Gallery',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                  ),

                  // OCR Processing Overlay
                  if (_isProcessingOCR && showOCROverlay)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.7),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF8C00)),
                            SizedBox(height: 16),
                            Text(
                              'Reading Registration Number...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (hasImage && isValid)
                    Center(
                      child: CustomPaint(
                        size: Size(120, 120),
                        painter: VerifiedStampPainter(),
                      ),
                    ),
                  if (hasImage)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 18),
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
      onTap: () => FocusScope.of(context).unfocus(),
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
            borderRadius: 30.0,
            buttonSize: 60.0,
            icon:
                Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
            onPressed: () => context.pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Vehicle Registration',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
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
                              Color(0xFFFF8C00).withValues(alpha:0.1),
                              Color(0xFFFF6B00).withValues(alpha:0.05)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Color(0xFFFF8C00).withValues(alpha:0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF8C00).withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.description,
                                  color: Color(0xFFFF8C00), size: 32),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload RC Document',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Both sides required',
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF666666)),
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
                        subtitle: 'Registration number visible',
                        icon: Icons.credit_card,
                        image: _frontImage,
                        imageUrl: _frontImageUrl,
                        isValid: _isFrontValid,
                        showOCROverlay: true,
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
                              print('❌ Error: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _frontImage = selectedUploadedFiles.first;
                                _model.uploadedLocalFile_uploadData1zx =
                                    _frontImage!;
                                _frontImageUrl = null;
                                _isFrontValid = true;
                              });

                              FFAppState().registrationImage = _frontImage;
                              if (_frontImage?.bytes != null) {
                                FFAppState().rcFrontBase64 =
                                    base64Encode(_frontImage!.bytes!);
                              }
                              FFAppState().update(() {});
                              _showSnackBar('Front side uploaded!');

                              // 🔥 AUTO-EXTRACT REGISTRATION NUMBER
                              await _extractRegistrationNumberFromImage(
                                  _frontImage!);
                            }
                          }
                        },
                        onRemove: () {
                          setState(() {
                            _frontImage = null;
                            _frontImageUrl = null;
                            _isFrontValid = false;
                          });
                          FFAppState().registrationImage = null;
                          FFAppState().rcFrontImageUrl = '';
                          FFAppState().rcFrontBase64 = '';
                          FFAppState().update(() {});
                          _showSnackBar('Front side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 20),

                      // Back Side
                      _buildImageCard(
                        title: 'Back Side',
                        subtitle: 'Owner details & address visible',
                        icon: Icons.contact_page,
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
                              print('❌ Error: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _backImage = selectedUploadedFiles.first;
                                _backImageUrl = null;
                                _isBackValid = true;
                              });

                              FFAppState().rcBackImage = _backImage;
                              if (_backImage?.bytes != null) {
                                FFAppState().rcBackBase64 =
                                    base64Encode(_backImage!.bytes!);
                              }
                              FFAppState().update(() {});
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
                          FFAppState().rcBackImage = null;
                          FFAppState().rcBackImageUrl = '';
                          FFAppState().rcBackBase64 = '';
                          FFAppState().update(() {});
                          _showSnackBar('Back side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 24),

                      // Registration Number Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.05),
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
                                Icon(Icons.confirmation_number,
                                    color: Color(0xFFFF8C00), size: 20),
                                SizedBox(width: 8),
                                Text('Registration Number',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                if (_registrationNumberController
                                    .text.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.green, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 12, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text('Auto-filled',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _registrationNumberController,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]')),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                hintText: 'DL03CW3121',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.directions_car,
                                    color: Color(0xFFFF8C00)),
                                suffixIcon: _isRegNumberValid
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
                              ),
                              validator: _validateRegistrationNumber,
                              onChanged: (value) {
                                setState(() {
                                  _isRegNumberValid =
                                      _validateRegistrationNumber(value) ==
                                          null;
                                });
                                if (_isRegNumberValid) {
                                  FFAppState().registrationNumber =
                                      value.trim().toUpperCase();
                                  FFAppState().update(() {});
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
                                    _registrationNumberController.text.isEmpty
                                        ? 'Auto-filled from photo or enter manually'
                                        : 'Registration number verified ✓',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _registrationNumberController
                                              .text.isEmpty
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
                              color: Color(0xFFFF8C00).withValues(alpha:0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: Color(0xFFFF8C00), size: 20),
                                SizedBox(width: 8),
                                Text('Important Guidelines',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildGuideline('Upload both front and back sides'),
                            _buildGuideline(
                                'Registration number must be clearly visible'),
                            _buildGuideline('All four corners should be clear'),
                            _buildGuideline('Avoid glare and shadows'),
                            _buildGuideline(
                                'OCR will auto-fill registration number'),
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

                            // Save all data to correct properties
                            FFAppState().registrationImage =
                                _frontImage; // Keep for backwards compatibility
                            FFAppState().rcFrontImage =
                                _frontImage; // New front image property
                            FFAppState().rcBackImage =
                                _backImage; // Back image property
                            FFAppState().registrationNumber =
                                _registrationNumberController.text
                                    .trim()
                                    .toUpperCase();

                            if (_frontImage?.bytes != null) {
                              FFAppState().rcFrontBase64 =
                                  base64Encode(_frontImage!.bytes!);
                            }
                            if (_backImage?.bytes != null) {
                              FFAppState().rcBackBase64 =
                                  base64Encode(_backImage!.bytes!);
                            }

                            FFAppState().update(() {});

                            print('✅ RC data saved');
                            _showSnackBar('Registration certificate uploaded!');

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
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)))),
        ],
      ),
    );
  }
}

// Verified Stamp Painter (same as before)
class VerifiedStampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = Color(0xFF2E7D32).withValues(alpha:0.9)
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
      ..color = Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 12, innerCirclePaint);

    final bannerY = center.dy;
    final bannerHeight = 28.0;
    final bannerWidth = size.width * 0.85;
    final bannerLeft = center.dx - bannerWidth / 2;

    final ribbonPaint = Paint()
      ..color = Color(0xFF1976D2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
          bannerLeft, bannerY - bannerHeight / 2, bannerWidth, bannerHeight),
      ribbonPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'VERIFIED',
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2,
            bannerY - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
