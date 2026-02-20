import '/backend/api_requests/api_calls.dart';
import '/config.dart' as app_config;
import '/constants/app_colors.dart';
import '/constants/vehicle_data.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'vehicle_image_model.dart';
export 'vehicle_image_model.dart';

class VehicleImageUpdateWidget extends StatefulWidget {
  const VehicleImageUpdateWidget({super.key});

  static String routeName = 'vehicleImageUpdate';
  static String routePath = '/vehicleImageUpdate';

  @override
  State<VehicleImageUpdateWidget> createState() =>
      _VehicleImageUpdateWidgetState();
}

class _VehicleImageUpdateWidgetState extends State<VehicleImageUpdateWidget>
    with SingleTickerProviderStateMixin {
  late VehicleImageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FFUploadedFile? _vehicleImage;
  bool _isVehicleImageValid = false;
  FFUploadedFile? _pollutionImage;
  FFUploadedFile? _insuranceImage;
  bool _isPollutionValid = false;
  bool _isInsuranceValid = false;

  String? _selectedVehicleType;
  int _selectedVehicleTypeId = 0;
  String? _selectedColor;

  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _regDateController = TextEditingController();
  final TextEditingController _insuranceNumberController =
      TextEditingController();
  final TextEditingController _insuranceExpiryController =
      TextEditingController();
  final TextEditingController _pollutionExpiryController =
      TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color _primary = AppColors.primary;
  static const Color _textWhite = AppColors.white;
  static const Color _textMuted = AppColors.greySlate;
  static const Color _cardBg = AppColors.backgroundCard;

  final List<Map<String, dynamic>> vehicleColors = [
    {'name': 'White', 'color': AppColors.white, 'border': AppColors.greyBorder},
    {'name': 'Black', 'color': AppColors.black, 'border': AppColors.black},
    {'name': 'Silver', 'color': AppColors.silver, 'border': AppColors.greyMid},
    {
      'name': 'Red',
      'color': AppColors.accentRed,
      'border': AppColors.accentRed
    },
    {
      'name': 'Blue',
      'color': AppColors.accentBlue,
      'border': AppColors.accentBlue
    },
    {
      'name': 'Grey',
      'color': AppColors.greyVehicle,
      'border': AppColors.greyVehicle
    },
    {
      'name': 'Yellow',
      'color': AppColors.teamEarningsYellow,
      'border': AppColors.teamEarningsYellow
    },
    {'name': 'Green', 'color': AppColors.success, 'border': AppColors.success},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehicleImageModel());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadSavedData();
  }

  void _loadSavedData() {
    if (FFAppState().vehicleBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().vehicleBase64);
        setState(() {
          _vehicleImage = FFUploadedFile(bytes: bytes, name: 'vehicle.jpg');
          _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
          _isVehicleImageValid = true;
        });
      } catch (e) {
        print('Error: $e');
      }
    } else if (FFAppState().vehicleImage?.bytes != null) {
      setState(() {
        _vehicleImage = FFAppState().vehicleImage;
        _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
        _isVehicleImageValid = true;
      });
    }

    // Load vehicle type driver already selected (from Choose Vehicle or saved)
    if (FFAppState().selectvehicle.isNotEmpty) {
      setState(() {
        _selectedVehicleType = FFAppState().selectvehicle;
        _selectedVehicleTypeId = FFAppState().adminVehicleId;
      });
    } else if (FFAppState().vehicleType.isNotEmpty) {
      setState(() {
        _selectedVehicleType = FFAppState().vehicleType;
        _selectedVehicleTypeId = FFAppState().adminVehicleId;
      });
    }
    if (FFAppState().vehicleMake.isNotEmpty) {
      _makeController.text = FFAppState().vehicleMake;
      _vehicleNameController.text = FFAppState().vehicleMake;
    } else if (FFAppState().vehicleName.isNotEmpty) {
      _makeController.text = FFAppState().vehicleName;
      _vehicleNameController.text = FFAppState().vehicleName;
    }
    if (FFAppState().vehicleModel.isNotEmpty)
      _modelController.text = FFAppState().vehicleModel;
    if (FFAppState().vehicleYear.isNotEmpty)
      _yearController.text = FFAppState().vehicleYear;
    if (FFAppState().vehicleColor.isNotEmpty)
      setState(() => _selectedColor = FFAppState().vehicleColor);
    if (FFAppState().licensePlate.isNotEmpty)
      _licensePlateController.text = FFAppState().licensePlate;
    if (FFAppState().registrationNumber.isNotEmpty)
      _regNumberController.text = FFAppState().registrationNumber;
    if (FFAppState().registrationDate.isNotEmpty)
      _regDateController.text = FFAppState().registrationDate;
    if (FFAppState().insuranceNumber.isNotEmpty)
      _insuranceNumberController.text = FFAppState().insuranceNumber;
    if (FFAppState().insuranceExpiryDate.isNotEmpty)
      _insuranceExpiryController.text = FFAppState().insuranceExpiryDate;
    if (FFAppState().pollutionExpiryDate.isNotEmpty)
      _pollutionExpiryController.text = FFAppState().pollutionExpiryDate;
    if (FFAppState().vehicleName.isNotEmpty)
      _vehicleNameController.text = FFAppState().vehicleName;

    // Pollution Image
    if (FFAppState().pollutionBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().pollutionBase64);
        setState(() {
          _pollutionImage = FFUploadedFile(bytes: bytes, name: 'pollution.jpg');
          _isPollutionValid = true;
        });
      } catch (e) {
        print('Pollution decode error: $e');
      }
    } else if (FFAppState().pollutioncertificateImage?.bytes != null &&
        FFAppState().pollutioncertificateImage!.bytes!.isNotEmpty) {
      setState(() {
        _pollutionImage = FFAppState().pollutioncertificateImage;
        _isPollutionValid = true;
      });
    }

    // Insurance Image
    if (FFAppState().insuranceBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().insuranceBase64);
        setState(() {
          _insuranceImage = FFUploadedFile(bytes: bytes, name: 'insurance.jpg');
          _isInsuranceValid = true;
        });
      } catch (e) {
        print('Insurance decode error: $e');
      }
    } else if (FFAppState().insuranceImage?.bytes != null &&
        FFAppState().insuranceImage!.bytes!.isNotEmpty) {
      setState(() {
        _insuranceImage = FFAppState().insuranceImage;
        _isInsuranceValid = true;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _regNumberController.dispose();
    _regDateController.dispose();
    _insuranceNumberController.dispose();
    _insuranceExpiryController.dispose();
    _pollutionExpiryController.dispose();
    _vehicleNameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle,
            color: AppColors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    bool hasImage =
        (_vehicleImage?.bytes != null && _vehicleImage!.bytes!.isNotEmpty);

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
            'Vehicle Details',
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVehicleMakeDropdown(),
                    const SizedBox(height: 20),
                    _buildVehicleModelDropdown(),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                        controller: _regNumberController,
                        label: 'Registration Number',
                        hint: 'RC number',
                        icon: Icons.description,
                        stateKey: 'registrationNumber'),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                        controller: _regDateController,
                        label: 'Registration Date',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.calendar_today,
                        stateKey: 'registrationDate',
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                        controller: _insuranceNumberController,
                        label: 'Insurance Number',
                        hint: 'Policy number',
                        icon: Icons.security,
                        stateKey: 'insuranceNumber'),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                        controller: _insuranceExpiryController,
                        label: 'Insurance Expiry',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.event,
                        stateKey: 'insuranceExpiryDate',
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                        controller: _pollutionExpiryController,
                        label: 'Pollution Certificate Expiry',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.eco,
                        stateKey: 'pollutionExpiryDate',
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 20),
                    const Text('Vehicle Photo',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    _buildPhotoUpload(hasImage),
                    const SizedBox(height: 24),
                    const Text('Pollution Certificate',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    _buildExtraImageUpload(
                        image: _pollutionImage,
                        isValid: _isPollutionValid,
                        onImageSelected: _onPollutionSelected),
                    const SizedBox(height: 24),
                    const Text('Insurance Document',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    _buildExtraImageUpload(
                        image: _insuranceImage,
                        isValid: _isInsuranceValid,
                        onImageSelected: _onInsuranceSelected),
                    const SizedBox(height: 32),
                    _buildSubmitButton(hasImage),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HERO PHOTO SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHeroPhotoSection(bool hasImage) {
    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
            context: context, allowPhoto: true);
        if (selectedMedia != null &&
            selectedMedia
                .every((m) => validateFileFormat(m.storagePath, context))) {
          var files = <FFUploadedFile>[];
          try {
            files = selectedMedia
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
            print('Error: $e');
          }
          if (files.isNotEmpty) {
            setState(() {
              _vehicleImage = files.first;
              _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
              _isVehicleImageValid = true;
            });
            FFAppState().vehicleImage = _vehicleImage;
            if (_vehicleImage?.bytes != null)
              FFAppState().vehicleBase64 = base64Encode(_vehicleImage!.bytes!);
            FFAppState().update(() {});
            _showSnackBar('Vehicle photo uploaded!');
          }
        }
      },
      child: Stack(
        children: [
          // Image or placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: hasImage
                ? Image.memory(_vehicleImage!.bytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 14),
                        const Text('Upload Vehicle Photo',
                            style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Camera or Gallery',
                            style: TextStyle(color: _textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
          ),

          // Gradient overlay on image
          if (hasImage)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(22)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.black.withOpacity(0.6)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Icon(Icons.edit_rounded,
                          color: AppColors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 4),
                      Text('Tap to change',
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 12)),
                    ]),
                  ),
                ),
              ),
            ),

          // Uploaded badge
          if (hasImage && _isVehicleImageValid)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: _primary.withOpacity(0.5), blurRadius: 8)
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Uploaded',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

          // Remove button
          if (hasImage)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _vehicleImage = null;
                    _isVehicleImageValid = false;
                  });
                  FFAppState().vehicleImage = null;
                  FFAppState().vehicleBase64 = '';
                  FFAppState().update(() {});
                  _showSnackBar('Photo removed', isError: true);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 8)
                    ],
                  ),
                  child:
                      const Icon(Icons.close, color: AppColors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onPollutionSelected(FFUploadedFile? file) {
    setState(() {
      _pollutionImage = file;
      _isPollutionValid = file != null;
    });
    FFAppState().pollutionImage = file;
    if (file?.bytes != null)
      FFAppState().pollutionBase64 = base64Encode(file!.bytes!);
    else
      FFAppState().pollutionBase64 = '';
    FFAppState().update(() {});
  }

  void _onInsuranceSelected(FFUploadedFile? file) {
    setState(() {
      _insuranceImage = file;
      _isInsuranceValid = file != null;
    });
    FFAppState().insuranceImage = file;
    if (file?.bytes != null)
      FFAppState().insuranceBase64 = base64Encode(file!.bytes!);
    else
      FFAppState().insuranceBase64 = '';
    FFAppState().update(() {});
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? stateKey,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  controller.text.isNotEmpty ? _primary : AppColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.greyLight, fontSize: 15),
              prefixIcon: Icon(icon, color: _primary, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
              if (stateKey != null) {
                switch (stateKey) {
                  case 'vehicleName':
                    FFAppState().vehicleName = value;
                    FFAppState().vehicleMake = value;
                    break;
                  case 'vehicleModel':
                    FFAppState().vehicleModel = value;
                    break;
                }
                FFAppState().update(() {});
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleMakeDropdown() {
    return FutureBuilder<ApiCallResponse>(
      future: GetVehicleMakesCall.call(),
      builder: (context, snapshot) {
        List<String> options = VehicleData.defaultMakes;
        if (snapshot.hasData &&
            snapshot.data?.statusCode == 200 &&
            GetVehicleMakesCall.names(snapshot.data!.jsonBody) != null) {
          final apiList = GetVehicleMakesCall.names(snapshot.data!.jsonBody)!;
          if (apiList.isNotEmpty) options = apiList;
        }
        final value = _makeController.text;
        if (value.isNotEmpty && !options.contains(value))
          options = [value, ...options];
        return _buildDropdownField(
          label: 'Vehicle Name',
          hint: 'Select make (e.g., Toyota, Honda)',
          icon: Icons.directions_car,
          value: value.isEmpty ? null : value,
          items: options,
          onChanged: (v) {
            setState(() {
              _makeController.text = v ?? '';
              _vehicleNameController.text = _makeController.text;
              FFAppState().vehicleMake = _makeController.text;
              FFAppState().vehicleName = _makeController.text;
              FFAppState().update(() {});
            });
          },
        );
      },
    );
  }

  Widget _buildVehicleModelDropdown() {
    return FutureBuilder<ApiCallResponse>(
      key: ValueKey(_makeController.text),
      future: GetVehicleModelsCall.call(makeName: _makeController.text),
      builder: (context, snapshot) {
        List<String> options = VehicleData.defaultModels;
        if (snapshot.hasData &&
            snapshot.data?.statusCode == 200 &&
            GetVehicleModelsCall.names(snapshot.data!.jsonBody) != null) {
          final apiList = GetVehicleModelsCall.names(snapshot.data!.jsonBody)!;
          if (apiList.isNotEmpty) options = apiList;
        }
        final value = _modelController.text;
        if (value.isNotEmpty && !options.contains(value))
          options = [value, ...options];
        return _buildDropdownField(
          label: 'Vehicle Model',
          hint: 'Select model (e.g., Camry, Civic)',
          icon: Icons.car_rental,
          value: value.isEmpty ? null : value,
          items: options,
          onChanged: (v) {
            setState(() {
              _modelController.text = v ?? '';
              FFAppState().vehicleModel = _modelController.text;
              FFAppState().update(() {});
            });
          },
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (value != null && value.isNotEmpty)
                  ? _primary
                  : AppColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: (value != null && value.isNotEmpty && items.contains(value))
                ? value
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.greyLight, fontSize: 15),
              prefixIcon: Icon(icon, color: _primary, size: 20),
              suffixIcon: (value != null && value.isNotEmpty)
                  ? const Icon(Icons.check_circle,
                      color: AppColors.success, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.greySlate),
            dropdownColor: AppColors.white,
            isExpanded: true,
            items: items
                .map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textDark))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(bool hasImage) {
    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
            context: context, allowPhoto: true);
        if (selectedMedia != null &&
            selectedMedia
                .every((m) => validateFileFormat(m.storagePath, context))) {
          try {
            final file = FFUploadedFile(
              name: selectedMedia.first.storagePath.split('/').last,
              bytes: selectedMedia.first.bytes,
              height: selectedMedia.first.dimensions?.height,
              width: selectedMedia.first.dimensions?.width,
            );
            setState(() {
              _vehicleImage = file;
              _isVehicleImageValid = true;
              _model.uploadedLocalFile_uploadData69q = file;
            });
            FFAppState().vehicleImage = file;
            if (file.bytes != null)
              FFAppState().vehicleBase64 = base64Encode(file.bytes!);
            FFAppState().update(() {});
            _showSnackBar('Photo uploaded successfully! ✓');
          } catch (e) {
            print('Error: $e');
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasImage ? _primary : AppColors.greyBorder, width: 1.5),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _vehicleImage?.bytes != null &&
                      _vehicleImage!.bytes!.isNotEmpty
                  ? Image.memory(_vehicleImage!.bytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.sectionOrangeLight,
                                shape: BoxShape.circle),
                            child: Icon(Icons.add_photo_alternate,
                                size: 40, color: _primary),
                          ),
                          const SizedBox(height: 12),
                          Text('Tap to upload photo',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greySlate)),
                          const SizedBox(height: 4),
                          Text('Camera or Gallery',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.greyLight)),
                        ],
                      ),
                    ),
            ),
            if (hasImage && _isVehicleImageValid)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _primary, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, color: AppColors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Uploaded',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            if (hasImage)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _vehicleImage = null;
                      _isVehicleImageValid = false;
                    });
                    FFAppState().vehicleImage = null;
                    FFAppState().vehicleBase64 = '';
                    FFAppState().update(() {});
                    _showSnackBar('Photo removed', isError: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: AppColors.white, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraImageUpload({
    required FFUploadedFile? image,
    required bool isValid,
    required Function(FFUploadedFile?) onImageSelected,
  }) {
    bool hasImage = (image?.bytes != null && image!.bytes!.isNotEmpty);
    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
            context: context, allowPhoto: true);
        if (selectedMedia != null &&
            selectedMedia
                .every((m) => validateFileFormat(m.storagePath, context))) {
          final file = FFUploadedFile(
              name: selectedMedia.first.storagePath.split('/').last,
              bytes: selectedMedia.first.bytes);
          onImageSelected(file);
          _showSnackBar('Photo uploaded successfully! ✓');
        }
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasImage ? _primary : AppColors.greyBorder, width: 1.5),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(image!.bytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.sectionOrangeLight,
                          shape: BoxShape.circle),
                      child: Icon(Icons.add_photo_alternate,
                          size: 40, color: _primary),
                    ),
                    SizedBox(height: 12),
                    Text('Tap to upload',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greySlate,
                            fontSize: 15)),
                  ],
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION LABEL
  // ══════════════════════════════════════════════════════════════════
  Widget _sectionLabel(String title, IconData icon) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.sectionOrangeLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primary, size: 18),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          )),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  //  GLASSMORPHISM CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color accentColor = _primary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: BoxDecoration(
              color: AppColors.sectionOrangeLight.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.greyBorder)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sectionOrangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  VIBRANT TEXT FIELD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildVibrantField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? stateKey,
  }) {
    bool isFilled = controller.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                color: isFilled ? _primary : _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFilled ? _primary : AppColors.greyBorder,
                width: isFilled ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                  color: _textWhite, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.greyLight, fontSize: 14),
                prefixIcon: Icon(icon,
                    color: isFilled ? _primary : _textMuted, size: 20),
                suffixIcon: isFilled
                    ? Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (value) {
                setState(() {});
                switch (stateKey) {
                  case 'vehicleName':
                    FFAppState().vehicleName = value;
                    break;
                  case 'vehicleMake':
                    FFAppState().vehicleMake = value;
                    break;
                  case 'vehicleModel':
                    FFAppState().vehicleModel = value;
                    break;
                  case 'vehicleYear':
                    FFAppState().vehicleYear = value;
                    break;
                  case 'licensePlate':
                    FFAppState().licensePlate = value;
                    break;
                  case 'registrationNumber':
                    FFAppState().registrationNumber = value;
                    break;
                  case 'registrationDate':
                    FFAppState().registrationDate = value;
                    break;
                  case 'insuranceNumber':
                    FFAppState().insuranceNumber = value;
                    break;
                  case 'insuranceExpiryDate':
                    FFAppState().insuranceExpiryDate = value;
                    break;
                  case 'pollutionExpiryDate':
                    FFAppState().pollutionExpiryDate = value;
                    break;
                }
                FFAppState().update(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  COLOR GRID
  // ══════════════════════════════════════════════════════════════════
  Widget _buildColorGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: vehicleColors.map((colorData) {
        bool isSelected = _selectedColor == colorData['name'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedColor = colorData['name']);
            FFAppState().vehicleColor = colorData['name'];
            FFAppState().update(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sectionOrangeLight
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _primary : AppColors.greyBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: _primary.withOpacity(0.25), blurRadius: 10)
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colorData['color'],
                    shape: BoxShape.circle,
                    border: Border.all(color: colorData['border'], width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.black.withOpacity(0.15),
                          blurRadius: 4)
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(colorData['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _primary : _textMuted,
                    )),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_rounded, size: 14, color: _primary),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  VEHICLE TYPE FROM API
  // ══════════════════════════════════════════════════════════════════
  Widget _buildVehicleTypeFromApi() {
    return FutureBuilder<ApiCallResponse>(
      future: ChoosevehicleCall.call(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Center(
                child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_primary)),
            )),
          );
        }
        if (snapshot.hasError || snapshot.data?.statusCode != 200) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyBorder)),
            child: Row(children: [
              Icon(Icons.cloud_off_rounded,
                  color: AppColors.greySlate, size: 28),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Could not load vehicle types',
                      style:
                          TextStyle(color: AppColors.greySlate, fontSize: 14))),
              TextButton(
                onPressed: () => setState(() {}),
                child: Text('Retry',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700)),
              ),
            ]),
          );
        }
        final rawList = ChoosevehicleCall.data(snapshot.data!.jsonBody);
        final list = (rawList is List) ? rawList : [];
        if (list.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyBorder)),
            child: Text('No vehicle types available',
                style: TextStyle(color: AppColors.greySlate, fontSize: 14)),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = list[index];
            String name = '';
            int id = 0;
            String? imagePath;
            if (item is Map) {
              name = item['name']?.toString() ?? '';
              id = castToType<int>(item['id']) ?? 0;
              imagePath = item['image']?.toString();
            } else {
              name = getJsonField(item, r'$["name"]')?.toString() ?? '';
              id = castToType<int>(getJsonField(item, r'$["id"]')) ?? 0;
              imagePath = getJsonField(item, r'$["image"]')?.toString();
            }
            if (name.isEmpty) name = 'Unknown';
            final imageUrl = (imagePath != null &&
                    imagePath.isNotEmpty &&
                    imagePath != 'null')
                ? (imagePath.startsWith('http')
                    ? imagePath
                    : '${app_config.Config.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}')
                : null;
            final isSelected = (_selectedVehicleType != null &&
                    _selectedVehicleType!.toLowerCase() ==
                        name.toLowerCase()) ||
                _selectedVehicleTypeId == id;
            return _buildVehicleTypeCard(name, id, imageUrl, isSelected);
          },
        );
      },
    );
  }

  Widget _buildVehicleTypeCard(
      String name, int id, String? imageUrl, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = name;
          _selectedVehicleTypeId = id;
        });
        FFAppState().selectvehicle = name;
        FFAppState().adminVehicleId = id;
        FFAppState().vehicleType = name;
        FFAppState().update(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  AppColors.sectionOrangeLight,
                  AppColors.sectionOrangeLight.withOpacity(0.5)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? null : AppColors.backgroundCard,
          border: Border.all(
              color: isSelected ? _primary : AppColors.greyBorder,
              width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: _primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sectionOrangeLight
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(_getVehicleIcon(name),
                          size: 28, color: isSelected ? _primary : _textMuted))
                  : Icon(_getVehicleIcon(name),
                      size: 28, color: isSelected ? _primary : _textMuted),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _textWhite : _textMuted,
                  )),
              if (isSelected)
                Text('Selected',
                    style: TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w500)),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? _primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? _primary : AppColors.greyBorder,
                  width: 2),
            ),
            child: Icon(Icons.check,
                color: AppColors.white, size: isSelected ? 14 : 0),
          ),
        ]),
      ),
    );
  }

  Widget _buildSelectedVehicleTypeChip(String vehicleName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sectionOrangeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: _primary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Selected: $vehicleName',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('auto')) return Icons.local_taxi;
    if (n.contains('bike') || n.contains('motorcycle'))
      return Icons.two_wheeler;
    if (n.contains('car') || n.contains('sedan') || n.contains('suv'))
      return Icons.directions_car;
    if (n.contains('truck')) return Icons.local_shipping;
    return Icons.directions_car_rounded;
  }

  // ══════════════════════════════════════════════════════════════════
  //  DOCUMENT UPLOAD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildDocUpload({
    required String label,
    required IconData icon,
    required FFUploadedFile? image,
    required bool isValid,
    required Function(FFUploadedFile?) onSelected,
  }) {
    bool hasImg = image?.bytes != null && image!.bytes!.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
            context: context, allowPhoto: true);
        if (selectedMedia != null &&
            selectedMedia
                .every((m) => validateFileFormat(m.storagePath, context))) {
          final file = FFUploadedFile(
            name: selectedMedia.first.storagePath.split('/').last,
            bytes: selectedMedia.first.bytes,
          );
          onSelected(file);
          _showSnackBar('$label uploaded!');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasImg ? _primary : AppColors.greyBorder,
            width: hasImg ? 2 : 1,
          ),
          boxShadow: hasImg
              ? [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 12)]
              : [],
        ),
        child: Stack(children: [
          if (hasImg)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(image!.bytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
            )
          else
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: _primary, size: 36),
                ),
                const SizedBox(height: 10),
                Text('Upload $label',
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text('Tap to select',
                    style: TextStyle(color: AppColors.greySlate, fontSize: 12)),
              ],
            )),
          if (hasImg && isValid)
            Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: _primary, borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check, color: AppColors.white, size: 13),
                    SizedBox(width: 3),
                    Text('Valid',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ]),
                )),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SUBMIT BUTTON
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSubmitButton(bool hasImage) {
    final hasVehicleType =
        (_selectedVehicleType != null && _selectedVehicleType!.isNotEmpty) ||
            FFAppState().selectvehicle.isNotEmpty ||
            FFAppState().vehicleType.isNotEmpty;
    bool isFormValid = hasVehicleType &&
        _makeController.text.isNotEmpty &&
        _modelController.text.isNotEmpty &&
        hasImage &&
        _pollutionImage != null &&
        _insuranceImage != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isFormValid
            ? const LinearGradient(
                colors: [AppColors.primaryGradientStart, AppColors.primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight)
            : null,
        color: isFormValid ? null : AppColors.greyBorder,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                    color: _primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6))
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isFormValid
              ? () async {
                  final vType = _selectedVehicleType ??
                      (FFAppState().selectvehicle.isNotEmpty
                          ? FFAppState().selectvehicle
                          : FFAppState().vehicleType);
                  if (vType.isNotEmpty) {
                    FFAppState().vehicleType = vType;
                    FFAppState().selectvehicle = vType;
                    if (_selectedVehicleTypeId > 0)
                      FFAppState().adminVehicleId = _selectedVehicleTypeId;
                  }
                  FFAppState().vehicleName = _makeController.text;
                  FFAppState().vehicleMake = _makeController.text;
                  FFAppState().vehicleModel = _modelController.text;
                  FFAppState().vehicleColor = _selectedColor ?? '';
                  FFAppState().licensePlate = _licensePlateController.text;
                  FFAppState().registrationNumber = _regNumberController.text;
                  FFAppState().registrationDate = _regDateController.text;
                  FFAppState().insuranceNumber =
                      _insuranceNumberController.text;
                  FFAppState().insuranceExpiryDate =
                      _insuranceExpiryController.text;
                  FFAppState().pollutionExpiryDate =
                      _pollutionExpiryController.text;
                  FFAppState().vehicleImage = _vehicleImage;
                  FFAppState().pollutionImage = _pollutionImage;
                  FFAppState().insuranceImage = _insuranceImage;
                  if (_vehicleImage?.bytes != null)
                    FFAppState().vehicleBase64 =
                        base64Encode(_vehicleImage!.bytes!);
                  FFAppState().update(() {});

                  if (FFAppState().driverid > 0 &&
                      FFAppState().accessToken.isNotEmpty) {
                    try {
                      final res = await UpdateDriverCall.call(
                        id: FFAppState().driverid,
                        token: FFAppState().accessToken,
                        isonline: null,
                        vehicleImage: _vehicleImage,
                        registrationImage: FFAppState().registrationImage,
                        insuranceImage: _insuranceImage,
                        pollutionCertificateImage: _pollutionImage,
                        vehicleName: _makeController.text,
                        vehicleModel: _modelController.text,
                        vehicleColor: _selectedColor,
                        licensePlate: _licensePlateController.text,
                        registrationNumber: _regNumberController.text,
                        registrationDate: _regDateController.text.isNotEmpty
                            ? _regDateController.text
                            : null,
                        insuranceNumber: _insuranceNumberController.text,
                        insuranceExpiryDate:
                            _insuranceExpiryController.text.isNotEmpty
                                ? _insuranceExpiryController.text
                                : null,
                        pollutionExpiryDate:
                            _pollutionExpiryController.text.isNotEmpty
                                ? _pollutionExpiryController.text
                                : null,
                        vehicleTypeId: _selectedVehicleTypeId > 0
                            ? _selectedVehicleTypeId
                            : null,
                      );
                      if (!mounted) return;
                      if (res.succeeded) {
                        _showSnackBar('Vehicle details saved successfully!');
                      } else {
                        _showSnackBar(
                            getJsonField(res.jsonBody, r'$.message')
                                    ?.toString() ??
                                'Update failed',
                            isError: true);
                        return;
                      }
                    } catch (e) {
                      if (mounted)
                        _showSnackBar('Failed to update: $e', isError: true);
                      return;
                    }
                  } else {
                    _showSnackBar('Vehicle details saved successfully!');
                  }
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) context.pop();
                }
              : () {
                  if (!hasVehicleType)
                    _showSnackBar(
                        'Please select vehicle type first (from Choose Vehicle)',
                        isError: true);
                  else if (_makeController.text.isEmpty)
                    _showSnackBar('Please select vehicle name', isError: true);
                  else if (_modelController.text.isEmpty)
                    _showSnackBar('Please select vehicle model', isError: true);
                  else if (!hasImage)
                    _showSnackBar('Please upload vehicle photo', isError: true);
                  else if (_pollutionImage == null)
                    _showSnackBar('Please upload pollution certificate',
                        isError: true);
                  else if (_insuranceImage == null)
                    _showSnackBar('Please upload insurance document',
                        isError: true);
                },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFormValid ? Icons.check_circle_rounded : Icons.lock_rounded,
                  color: isFormValid ? AppColors.white : AppColors.greyLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  isFormValid ? 'Save Vehicle Details' : 'Complete All Fields',
                  style: TextStyle(
                    color: isFormValid ? AppColors.white : AppColors.greyLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
