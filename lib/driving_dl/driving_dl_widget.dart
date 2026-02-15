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
import 'driving_dl_model.dart';
export 'driving_dl_model.dart';

class DrivingDlWidget extends StatefulWidget {
  const DrivingDlWidget({super.key});

  static String routeName = 'Driving_dl';
  static String routePath = '/drivingDl';

  @override
  State<DrivingDlWidget> createState() => _DrivingDlWidgetState();
}

class _DrivingDlWidgetState extends State<DrivingDlWidget>
    with SingleTickerProviderStateMixin {
  late DrivingDlModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _licenseNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // License images
  FFUploadedFile? _frontImage;
  String? _frontImageUrl;
  bool _isFrontValid = false;

  FFUploadedFile? _backImage;
  String? _backImageUrl;
  bool _isBackValid = false;

  bool _isLicenseNumberValid = false;
  bool _isProcessingOCR = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrivingDlModel());

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
    print('📊 License FFAppState Debug Info:');
    print('═══════════════════════════════════════');
    print(
        'Front Image (bytes): ${FFAppState().imageLicense?.bytes?.length ?? 0}');
    print('Front Image URL: ${FFAppState().licenseFrontImageUrl}');
    print('Front Base64: ${FFAppState().licenseFrontBase64.length} chars');
    print(
        'Back Image (bytes): ${FFAppState().licenseBackImage?.bytes?.length ?? 0}');
    print('Back Image URL: ${FFAppState().licenseBackImageUrl}');
    print('Back Base64: ${FFAppState().licenseBackBase64.length} chars');
    print('License Number: ${FFAppState().licenseNumber}');
    print('═══════════════════════════════════════\n');
  }

  void _loadSavedData() {
    print('🔄 Loading saved license data...');

    // Load front image
    if (FFAppState().licenseFrontBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().licenseFrontBase64);
        setState(() {
          _frontImage = FFUploadedFile(bytes: bytes, name: 'license_front.jpg');
          _model.uploadedLocalFile_uploadDataQhu = _frontImage!;
          _isFrontValid = true;
        });
        print('✅ Front image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        print('❌ Error decoding front Base64: $e');
      }
    } else if (FFAppState().licenseFrontImageUrl.isNotEmpty) {
      setState(() {
        _frontImageUrl = FFAppState().licenseFrontImageUrl;
        _isFrontValid = true;
      });
    } else if (FFAppState().imageLicense?.bytes != null &&
        FFAppState().imageLicense!.bytes!.isNotEmpty) {
      setState(() {
        _frontImage = FFAppState().imageLicense;
        _model.uploadedLocalFile_uploadDataQhu = _frontImage!;
        _isFrontValid = true;
      });
    }

    // Load back image
    if (FFAppState().licenseBackBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().licenseBackBase64);
        setState(() {
          _backImage = FFUploadedFile(bytes: bytes, name: 'license_back.jpg');
          _isBackValid = true;
        });
      } catch (e) {
        print('❌ Error decoding back Base64: $e');
      }
    } else if (FFAppState().licenseBackImageUrl.isNotEmpty) {
      setState(() {
        _backImageUrl = FFAppState().licenseBackImageUrl;
        _isBackValid = true;
      });
    } else if (FFAppState().licenseBackImage?.bytes != null &&
        FFAppState().licenseBackImage!.bytes!.isNotEmpty) {
      setState(() {
        _backImage = FFAppState().licenseBackImage;
        _isBackValid = true;
      });
    }

    // Load license number
    if (FFAppState().licenseNumber.isNotEmpty) {
      setState(() {
        _licenseNumberController.text =
            FFAppState().licenseNumber.toUpperCase();
        _isLicenseNumberValid =
            _validateLicenseNumber(_licenseNumberController.text) == null;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _licenseNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 🔥 OCR - Extract DL Number from Image
  Future<void> _extractDLNumberFromImage(FFUploadedFile image) async {
    if (image.bytes == null || image.bytes!.isEmpty) {
      print('❌ No image bytes to process');
      return;
    }

    setState(() => _isProcessingOCR = true);

    try {
      // Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_license.jpg');
      await file.writeAsBytes(image.bytes!);

      // Initialize text recognizer
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      print('📝 OCR Text Extracted:');
      print(recognizedText.text);

      // Extract DL number using regex
      String? dlNumber = _extractDLNumber(recognizedText.text);

      if (dlNumber != null) {
        setState(() {
          _licenseNumberController.text = dlNumber;
          _isLicenseNumberValid = _validateLicenseNumber(dlNumber) == null;
        });

        // Save to FFAppState
        FFAppState().licenseNumber = dlNumber;
        FFAppState().update(() {});

        _showSnackBar('✅ DL Number auto-filled: $dlNumber');
        print('✅ DL Number extracted: $dlNumber');
      } else {
        _showSnackBar('⚠️ Could not detect DL number. Please enter manually.',
            isError: true);
        print('❌ No valid DL number found in text');
      }

      // Cleanup
      await textRecognizer.close();
      await file.delete();
    } catch (e) {
      print('❌ OCR Error: $e');
      _showSnackBar('OCR failed. Please enter DL number manually.',
          isError: true);
    } finally {
      setState(() => _isProcessingOCR = false);
    }
  }

  // Extract DL number from OCR text
  String? _extractDLNumber(String text) {
    // Remove all whitespace and newlines
    String cleanedText = text.replaceAll(RegExp(r'\s+'), '');

    // Indian DL format patterns
    List<RegExp> patterns = [
      // Standard format: XX00 00000000000 or XX-00-00000000000
      RegExp(r'[A-Z]{2}[-\s]?[0-9]{2}[-\s]?[0-9]{11}', caseSensitive: false),
      // Without separators: XX0000000000000
      RegExp(r'[A-Z]{2}[0-9]{13}', caseSensitive: false),
      // With space: XX00 00000000000
      RegExp(r'[A-Z]{2}\s?[0-9]{2}\s?[0-9]{11}', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(cleanedText);
      if (match != null) {
        String dlNumber = match.group(0)!.toUpperCase();
        // Remove hyphens and extra spaces
        dlNumber = dlNumber.replaceAll(RegExp(r'[-\s]'), '');

        // Format: XX00 00000000000
        if (dlNumber.length == 15) {
          return '${dlNumber.substring(0, 4)} ${dlNumber.substring(4)}';
        }
      }
    }

    // Try to find any 15-character alphanumeric string starting with 2 letters
    RegExp fallbackPattern =
        RegExp(r'[A-Z]{2}[0-9A-Z]{13}', caseSensitive: false);
    final fallbackMatch = fallbackPattern.firstMatch(cleanedText);
    if (fallbackMatch != null) {
      String dlNumber = fallbackMatch.group(0)!.toUpperCase();
      if (dlNumber.length == 15) {
        return '${dlNumber.substring(0, 4)} ${dlNumber.substring(4)}';
      }
    }

    return null;
  }

  // Driving License Number Validation (India format)
  String? _validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter license number';
    }

    String cleanedValue = value.trim().toUpperCase().replaceAll(' ', '');

    // Indian DL format: XX0000000000000 (15 chars)
    RegExp dlRegex = RegExp(r'^[A-Z]{2}[0-9]{2}\s?[0-9]{11}$');

    if (!dlRegex.hasMatch(cleanedValue)) {
      return 'Invalid license format (e.g., KA0120200001234)';
    }

    if (cleanedValue.length != 15) {
      return 'License must be 15 characters';
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF8C00).withOpacity(0.1),
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

                  // OCR Processing Overlay
                  if (_isProcessingOCR && title == 'Front Side')
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF8C00)),
                            SizedBox(height: 16),
                            Text(
                              'Reading DL Number...',
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
                                color: Colors.black.withOpacity(0.2),
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
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon:
                Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.0),
            onPressed: () => context.pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_taxi, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'UGQ TAXI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Color(0xFFFF8C00).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF8C00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.card_membership,
                                  color: Color(0xFFFF8C00), size: 32),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload Driving License',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.auto_fix_high,
                                          size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        'Auto-fill with OCR',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // OCR Info Banner
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Colors.blue[700], size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Upload front side to auto-fill DL number',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.blue[900]),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Front Side
                      _buildImageCard(
                        title: 'Front Side',
                        subtitle: 'Photo & License number visible',
                        icon: Icons.badge,
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
                              print('❌ Error: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _frontImage = selectedUploadedFiles.first;
                                _model.uploadedLocalFile_uploadDataQhu =
                                    _frontImage!;
                                _frontImageUrl = null;
                                _isFrontValid = true;
                              });

                              FFAppState().imageLicense = _frontImage;
                              if (_frontImage?.bytes != null) {
                                FFAppState().licenseFrontBase64 =
                                    base64Encode(_frontImage!.bytes!);
                              }
                              FFAppState().update(() {});
                              _showSnackBar('Front side uploaded!');

                              // 🔥 AUTO-EXTRACT DL NUMBER
                              await _extractDLNumberFromImage(_frontImage!);
                            }
                          }
                        },
                        onRemove: () {
                          setState(() {
                            _frontImage = null;
                            _frontImageUrl = null;
                            _isFrontValid = false;
                          });
                          FFAppState().imageLicense = null;
                          FFAppState().licenseFrontImageUrl = '';
                          FFAppState().licenseFrontBase64 = '';
                          FFAppState().update(() {});
                          _showSnackBar('Front side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 20),

                      // Back Side
                      _buildImageCard(
                        title: 'Back Side',
                        subtitle: 'Address & validity details visible',
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
                              print('❌ Error: $e');
                            }
                            if (selectedUploadedFiles.isNotEmpty) {
                              setState(() {
                                _backImage = selectedUploadedFiles.first;
                                _backImageUrl = null;
                                _isBackValid = true;
                              });

                              FFAppState().licenseBackImage = _backImage;
                              if (_backImage?.bytes != null) {
                                FFAppState().licenseBackBase64 =
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
                          FFAppState().licenseBackImage = null;
                          FFAppState().licenseBackImageUrl = '';
                          FFAppState().licenseBackBase64 = '';
                          FFAppState().update(() {});
                          _showSnackBar('Back side removed', isError: true);
                        },
                      ),

                      SizedBox(height: 24),

                      // License Number Input
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
                                Icon(Icons.badge,
                                    color: Color(0xFFFF8C00), size: 20),
                                SizedBox(width: 8),
                                Text('License Number',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                if (_licenseNumberController.text.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
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
                              controller: _licenseNumberController,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9\s]')),
                                LengthLimitingTextInputFormatter(16),
                                _LicenseInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: 'KA01 20200001234',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.card_membership,
                                    color: Color(0xFFFF8C00)),
                                suffixIcon: _isLicenseNumberValid
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
                              validator: _validateLicenseNumber,
                              onChanged: (value) {
                                setState(() {
                                  _isLicenseNumberValid =
                                      _validateLicenseNumber(value) == null;
                                });
                                if (_isLicenseNumberValid) {
                                  FFAppState().licenseNumber =
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
                                    _licenseNumberController.text.isEmpty
                                        ? 'Auto-filled from photo or enter manually'
                                        : 'License number verified ✓',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _licenseNumberController.text.isEmpty
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
                                Text('Important Guidelines',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildGuideline('Upload both front and back sides'),
                            _buildGuideline(
                                'All four corners should be visible'),
                            _buildGuideline(
                                'License number must be clearly readable'),
                            _buildGuideline('Avoid glare and shadows'),
                            _buildGuideline(
                                'OCR will auto-fill DL number from photo'),
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
                            FFAppState().imageLicense =
                                _frontImage; // Keep for backwards compatibility
                            FFAppState().licenseFrontImage =
                                _frontImage; // New front image property
                            FFAppState().licenseBackImage =
                                _backImage; // Back image property
                            FFAppState().licenseNumber =
                                _licenseNumberController.text
                                    .trim()
                                    .toUpperCase();

                            if (_frontImage?.bytes != null) {
                              FFAppState().licenseFrontBase64 =
                                  base64Encode(_frontImage!.bytes!);
                            }
                            if (_backImage?.bytes != null) {
                              FFAppState().licenseBackBase64 =
                                  base64Encode(_backImage!.bytes!);
                            }

                            FFAppState().update(() {});

                            print('✅ License data saved');
                            _showSnackBar('License verification completed!');

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

// License Input Formatter (same as before)
class _LicenseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.toUpperCase().replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 3 && i + 1 != text.length) {
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

// Verified Stamp Painter (same as before)
class VerifiedStampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = Color(0xFF2E7D32).withOpacity(0.9)
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
      ..color = Colors.white.withOpacity(0.95)
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
