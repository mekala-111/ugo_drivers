import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'vehicle_image_model.dart';
export 'vehicle_image_model.dart';

class VehicleImageWidget extends StatefulWidget {
  const VehicleImageWidget({super.key});

  static String routeName = 'vehicleImage';
  static String routePath = '/vehicleImage';

  @override
  State<VehicleImageWidget> createState() => _VehicleImageWidgetState();
}

class _VehicleImageWidgetState extends State<VehicleImageWidget>
    with SingleTickerProviderStateMixin {
  late VehicleImageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FFUploadedFile? _vehicleImage;
  bool _isVehicleImageValid = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehicleImageModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadSavedImage();
  }

  void _loadSavedImage() {
    if (FFAppState().vehicleBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().vehicleBase64);
        setState(() {
          _vehicleImage = FFUploadedFile(bytes: bytes, name: 'vehicle.jpg');
          _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
          _isVehicleImageValid = true;
        });
        return;
      } catch (_) {}
    }
    if (FFAppState().vehicleImage?.bytes != null) {
      setState(() {
        _vehicleImage = FFAppState().vehicleImage;
        _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
        _isVehicleImageValid = true;
      });
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
              isError ? Icons.error_outline : Icons.check_circle,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickVehiclePhoto() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        !selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    try {
      final file = FFUploadedFile(
        name: selectedMedia.first.storagePath.split('/').last,
        bytes: selectedMedia.first.bytes,
        height: selectedMedia.first.dimensions?.height,
        width: selectedMedia.first.dimensions?.width,
        blurHash: selectedMedia.first.blurHash,
        originalFilename: selectedMedia.first.originalFilename,
      );
      setState(() {
        _vehicleImage = file;
        _model.uploadedLocalFile_uploadData69q = file;
        _isVehicleImageValid = true;
      });
      FFAppState().vehicleImage = file;
      FFAppState().vehicleBase64 =
          file.bytes != null ? base64Encode(file.bytes!) : '';
      FFAppState().update(() {});
      _showSnackBar('Vehicle photo uploaded!');
    } catch (_) {
      _showSnackBar('Upload failed. Please try again.', isError: true);
    }
  }

  void _removePhoto() {
    setState(() {
      _vehicleImage = null;
      _isVehicleImageValid = false;
    });
    FFAppState().vehicleImage = null;
    FFAppState().vehicleBase64 = '';
    FFAppState().update(() {});
    _showSnackBar('Photo removed', isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _vehicleImage?.bytes != null && _vehicleImage!.bytes!.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Vehicle Photo',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload a clear vehicle photo',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure the vehicle is fully visible.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.greySlate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoUpload(hasImage),
                  const Spacer(),
                  _buildContinueButton(hasImage),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(bool hasImage) {
    return GestureDetector(
      onTap: _pickVehiclePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.greyBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: hasImage
                  ? Image.memory(
                      _vehicleImage!.bytes!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.sectionOrangeLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to upload photo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greySlate,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyLight,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (hasImage)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _removePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: AppColors.white, size: 18),
                  ),
                ),
              ),
            if (hasImage && _isVehicleImageValid)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Uploaded',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool hasImage) {
    final isValid = hasImage;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValid
            ? () {
                context.pushNamed(
                  UploadRcWidget.routeName,
                  extra: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.rightToLeft,
                    duration: Duration(milliseconds: 300),
                  ),
                );
              }
            : () {
                _showSnackBar('Please upload vehicle photo', isError: true);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.interTight(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
