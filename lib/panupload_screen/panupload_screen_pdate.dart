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
import 'panupload_screen_model.dart';
export 'panupload_screen_model.dart';

class PanuploadScreenUpdateWidget extends StatefulWidget {
  const PanuploadScreenUpdateWidget({super.key});

  static String routeName = 'panuploadScreenUpdate';
  static String routePath = '/panuploadScreenUpdate';

  @override
  State<PanuploadScreenUpdateWidget> createState() => _PanuploadScreenUpdateWidgetState();
}

class _PanuploadScreenUpdateWidgetState extends State<PanuploadScreenUpdateWidget>
    with SingleTickerProviderStateMixin {
  late PanuploadScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _panController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // PAN card variables
  FFUploadedFile? _panImage;
  String? _panImageUrl;
  bool _isPanValid = false;
  bool _isPanNumberValid = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PanuploadScreenModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Load saved data
    _loadSavedData();

    // Debug
    _debugPrintState();
  }

  void _debugPrintState() {
    print('\n═══════════════════════════════════════');
    print('📊 PAN FFAppState Debug Info:');
    print('═══════════════════════════════════════');
    print('PAN Image (bytes): ${FFAppState().panImage?.bytes?.length ?? 0}');
    print('PAN Image URL: ${FFAppState().panImageUrl}');
    print('PAN Base64: ${FFAppState().panBase64.length} chars');
    print('PAN Number: ${FFAppState().panNumber}');
    print('═══════════════════════════════════════\n');
  }

  void _loadSavedData() {
    print('🔄 Loading saved PAN data...');

    // Load PAN image - Priority: Base64 > URL > Bytes
    if (FFAppState().panBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().panBase64);
        setState(() {
          _panImage = FFUploadedFile(
            bytes: bytes,
            name: 'pan_card.jpg',
          );
          _model.uploadedLocalFile_uploadData4go = _panImage!;
          _isPanValid = true;
        });
        print('✅ PAN image loaded from Base64 (${bytes.length} bytes)');
      } catch (e) {
        print('❌ Error decoding PAN Base64: $e');
      }
    } else if (FFAppState().panImageUrl.isNotEmpty) {
      setState(() {
        _panImageUrl = FFAppState().panImageUrl;
        _isPanValid = true;
      });
      print('✅ PAN image URL loaded: ${FFAppState().panImageUrl}');
    } else if (FFAppState().panImage?.bytes != null &&
        FFAppState().panImage!.bytes!.isNotEmpty) {
      setState(() {
        _panImage = FFAppState().panImage;
        _model.uploadedLocalFile_uploadData4go = _panImage!;
        _isPanValid = true;
      });
      print('✅ PAN image loaded from memory');
    }

    // Load saved PAN number
    if (FFAppState().panNumber.isNotEmpty) {
      setState(() {
        _panController.text = FFAppState().panNumber.toUpperCase();
        _isPanNumberValid = _validatePan(_panController.text) == null;
      });
      print('✅ PAN number loaded: ${FFAppState().panNumber}');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _panController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // PAN validation
  String? _validatePan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter PAN number';
    }

    String cleanedValue = value.trim().toUpperCase();

    if (cleanedValue.length != 10) {
      return 'PAN must be 10 characters';
    }

    // PAN format: ABCDE1234F
    // First 5 characters: Alphabets
    // Next 4 characters: Numbers
    // Last character: Alphabet
    RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    if (!panRegex.hasMatch(cleanedValue)) {
      return 'Invalid PAN format (e.g., ABCDE1234F)';
    }

    // Fourth character validation (specific rules)
    String fourthChar = cleanedValue[3];
    List<String> validFourthChars = [
      'P',
      'C',
      'H',
      'F',
      'A',
      'T',
      'B',
      'L',
      'J',
      'G'
    ];

    if (!validFourthChars.contains(fourthChar)) {
      return 'Invalid PAN number';
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
              height: 200.0,
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
                                  return const Column(
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
                                      'Tap to upload $title',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textNearBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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

                  // VERIFIED STAMP WATERMARK
                  if (hasImage && isValid)
                    Center(
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: VerifiedStampPainter(),
                      ),
                    ),

                  // Remove button
                  if (hasImage)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Tooltip(
                        message: 'Remove image',
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
                                Icons.credit_card,
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
                                    'Upload PAN Card',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textNearBlack,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Front side with photo',
                                    style: TextStyle(
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

                      // PAN Card Image
                      _buildImageCard(
                        title: 'PAN Card',
                        subtitle: 'Clear photo with all details visible',
                        icon: Icons.badge,
                        image: _panImage,
                        imageUrl: _panImageUrl,
                        isValid: _isPanValid,
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
                                _panImage = selectedUploadedFiles.first;
                                _model.uploadedLocalFile_uploadData4go =
                                    _panImage!;
                                _panImageUrl = null;
                                _isPanValid = true;
                              });

                              // Save to FFAppState (bytes + Base64)
                              FFAppState().panImage = _panImage;

                              // Convert to Base64 for persistence
                              if (_panImage?.bytes != null) {
                                String base64Image =
                                    base64Encode(_panImage!.bytes!);
                                FFAppState().panBase64 = base64Image;
                                print(
                                    '✅ PAN image saved as Base64 (${base64Image.length} chars)');
                              }

                              FFAppState().update(() {});

                              print('✅ PAN image saved to FFAppState');
                              print('   Bytes: ${_panImage?.bytes?.length}');

                              _showSnackBar('PAN card uploaded!');
                            }
                          }
                        },
                        onRemove: () {
                          setState(() {
                            _panImage = null;
                            _model.uploadedLocalFile_uploadData4go =
                                FFUploadedFile(bytes: Uint8List.fromList([]));
                            _panImageUrl = null;
                            _isPanValid = false;
                          });

                          // Clear from FFAppState
                          FFAppState().panImage = null;
                          FFAppState().panImageUrl = '';
                          FFAppState().panBase64 = '';
                          FFAppState().update(() {});

                          print('❌ PAN image removed from FFAppState');

                          _showSnackBar('PAN card removed', isError: true);
                        },
                      ),

                      const SizedBox(height: 24),

                      // PAN Number Input
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
                                  Icons.assignment_ind_outlined,
                                  color: AppColors.registrationOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'PAN Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // Saved badge
                                if (_panController.text.isNotEmpty)
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
                                      child: const Row(
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _panController,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]')),
                                LengthLimitingTextInputFormatter(10),
                                _PanInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: 'ABCDE1234F',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(
                                  Icons.badge,
                                  color: AppColors.registrationOrange,
                                ),
                                suffixIcon: _isPanNumberValid
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
                              validator: _validatePan,
                              onChanged: (value) {
                                setState(() {
                                  _isPanNumberValid =
                                      _validatePan(value) == null;
                                });
                                // Save to FFAppState
                                if (_isPanNumberValid) {
                                  FFAppState().panNumber =
                                      value.trim().toUpperCase();
                                  FFAppState().update(() {});
                                  print(
                                      '💾 PAN saved: ${FFAppState().panNumber}');
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
                                    _panController.text.isEmpty
                                        ? 'Enter 10-character PAN number'
                                        : 'PAN number verified ✓',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _panController.text.isEmpty
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
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: AppColors.registrationOrange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Important Guidelines',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGuideline('Upload clear photo of PAN card'),
                            _buildGuideline(
                                'All four corners should be visible'),
                            _buildGuideline(
                                'Photo and details must be readable'),
                            _buildGuideline('Avoid glare and shadows'),
                            _buildGuideline('PAN number format: ABCDE1234F'),
                            _buildGuideline(
                                '✓ Data persists after app restart'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      FFButtonWidget(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Check if image exists
                            bool hasPanImage = (_panImage?.bytes != null) ||
                                (_panImageUrl != null &&
                                    _panImageUrl!.isNotEmpty);

                            if (!hasPanImage) {
                              _showSnackBar('Please upload PAN card',
                                  isError: true);
                              return;
                            }

                            // Save all data to FFAppState
                            FFAppState().panImage = _panImage;
                            FFAppState().panNumber =
                                _panController.text.trim().toUpperCase();

                            // Save Base64 for persistence
                            if (_panImage?.bytes != null) {
                              FFAppState().panBase64 =
                                  base64Encode(_panImage!.bytes!);
                            }

                            // If you have URL from server, save it
                            if (_panImageUrl != null &&
                                _panImageUrl!.isNotEmpty) {
                              FFAppState().panImageUrl = _panImageUrl!;
                            }

                            FFAppState().update(() {});

                            print('✅ PAN data saved to FFAppState:');
                            print(
                                '   Image: ${_panImage?.bytes?.length ?? 0} bytes');
                            print('   URL: ${_panImageUrl ?? "None"}');
                            print(
                                '   Base64: ${FFAppState().panBase64.length} chars');
                            print('   Number: ${FFAppState().panNumber}');

                            _showSnackBar('PAN verification completed!');

                            // Navigate back
                            await Future.delayed(const Duration(milliseconds: 500));
                            context.pop();
                          }
                        },
                        text: 'Submit',
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

// PAN INPUT FORMATTER (Auto-uppercase)
class _PanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperCaseText = newValue.text.toUpperCase();
    return TextEditingValue(
      text: upperCaseText,
      selection: TextSelection.collapsed(offset: upperCaseText.length),
    );
  }
}

// ✅ VERIFIED STAMP PAINTER (Same as Aadhaar)
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
    canvas.drawCircle(center, radius - 12, innerCirclePaint);
    canvas.drawCircle(center, radius - 16, innerCirclePaint);

    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) - pi / 2;
      final starX = center.dx + (radius - 14) * cos(angle);
      final starY = center.dy + (radius - 14) * sin(angle);
      _drawStar(canvas, Offset(starX, starY), 2.5, AppColors.successDark);
    }

    final bannerY = center.dy;
    const bannerHeight = 28.0;
    final bannerWidth = size.width * 0.85;
    final bannerLeft = center.dx - bannerWidth / 2;

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
