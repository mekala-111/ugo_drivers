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

  String? _selectedVehicleType;
  int _selectedVehicleTypeId = 0;
  String? _selectedColor;

  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _regDateController = TextEditingController();
  final TextEditingController _insuranceNumberController = TextEditingController();
  final TextEditingController _insuranceExpiryController = TextEditingController();
  final TextEditingController _pollutionExpiryController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  FFUploadedFile? _pollutionImage;
  FFUploadedFile? _insuranceImage;

  bool _isPollutionValid = false;
  bool _isInsuranceValid = false;

  final List<Map<String, dynamic>> vehicleColors = [
    {'name': 'White', 'color': AppColors.white, 'border': AppColors.greyBorder},
    {'name': 'Black', 'color': AppColors.black, 'border': AppColors.black},
    {'name': 'Silver', 'color': AppColors.silver, 'border': AppColors.greyMid},
    {'name': 'Red', 'color': AppColors.accentRed, 'border': AppColors.accentRed},
    {'name': 'Blue', 'color': AppColors.accentBlue, 'border': AppColors.accentBlue},
    {'name': 'Grey', 'color': AppColors.greyVehicle, 'border': AppColors.greyVehicle},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehicleImageModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
        print('❌ Error: $e');
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
    }
    if (FFAppState().vehicleModel.isNotEmpty) {
      _modelController.text = FFAppState().vehicleModel;
    }
    if (FFAppState().vehicleYear.isNotEmpty) {
      _yearController.text = FFAppState().vehicleYear;
    }
    if (FFAppState().vehicleColor.isNotEmpty) {
      setState(() => _selectedColor = FFAppState().vehicleColor);
    }
    if (FFAppState().licensePlate.isNotEmpty) _licensePlateController.text = FFAppState().licensePlate;
    if (FFAppState().registrationNumber.isNotEmpty) _regNumberController.text = FFAppState().registrationNumber;
    if (FFAppState().registrationDate.isNotEmpty) _regDateController.text = FFAppState().registrationDate;
    if (FFAppState().insuranceNumber.isNotEmpty) _insuranceNumberController.text = FFAppState().insuranceNumber;
    if (FFAppState().insuranceExpiryDate.isNotEmpty) _insuranceExpiryController.text = FFAppState().insuranceExpiryDate;
    if (FFAppState().pollutionExpiryDate.isNotEmpty) _pollutionExpiryController.text = FFAppState().pollutionExpiryDate;
    // Pollution Image
    if (FFAppState().pollutionBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(FFAppState().pollutionBase64);
        setState(() {
          _pollutionImage = FFUploadedFile(bytes: bytes, name: 'pollution.jpg');
          _isPollutionValid = true;
        });
      } catch (e) {
        print('❌ Pollution decode error: $e');
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
        print('❌ Insurance decode error: $e');
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
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
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

  @override
  Widget build(BuildContext context) {
    bool hasImage = (_vehicleImage?.bytes != null && _vehicleImage!.bytes!.isNotEmpty);

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
          title: Text(
            FFLocalizations.of(context).getText('veh0001'),
            style: const TextStyle(
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
                    // Vehicle Name (dynamic from API or static fallback)
                    _buildVehicleMakeDropdown(),

                    const SizedBox(height: 20),

                    // Vehicle Model (dynamic from API or static fallback)
                    _buildVehicleModelDropdown(),

                    const SizedBox(height: 20),

                    Text(
                      FFLocalizations.of(context).getText('veh0002'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    _buildColorGrid(),

                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _licensePlateController,
                      label: 'License Plate',
                      labelText:
                          FFLocalizations.of(context).getText('veh0003'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0004'),
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _regNumberController,
                      label: 'Registration Number',
                      labelText:
                          FFLocalizations.of(context).getText('veh0005'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0006'),
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _regDateController,
                      label: 'Registration Date',
                      labelText:
                          FFLocalizations.of(context).getText('veh0007'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0008'),
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _insuranceNumberController,
                      label: 'Insurance Number',
                      labelText:
                          FFLocalizations.of(context).getText('veh0009'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0010'),
                      icon: Icons.security,
                    ),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _insuranceExpiryController,
                      label: 'Insurance Expiry',
                      labelText:
                          FFLocalizations.of(context).getText('veh0011'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0008'),
                      icon: Icons.event,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 20),
                    _buildSimpleTextField(
                      controller: _pollutionExpiryController,
                      label: 'Pollution Certificate Expiry',
                      labelText:
                          FFLocalizations.of(context).getText('veh0012'),
                      hintText:
                          FFLocalizations.of(context).getText('veh0008'),
                      icon: Icons.eco,
                      keyboardType: TextInputType.datetime,
                    ),

                    const SizedBox(height: 20),

                    // Photo Upload (screenshot: large white card, icon in circle, Tap to upload photo, Camera or Gallery)
                    Text(
                      FFLocalizations.of(context).getText('veh0013'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoUpload(hasImage),
                    const SizedBox(height: 24),

                    Text(
                      FFLocalizations.of(context).getText('veh0014'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExtraImageUpload(
                      image: _pollutionImage,
                      isValid: _isPollutionValid,
                      onImageSelected: (file) {
                        setState(() {
                          _pollutionImage = file;
                          _isPollutionValid = true;
                        });

                        FFAppState().pollutionImage = file;
                        if (file?.bytes != null) {
                          FFAppState().pollutionBase64 = base64Encode(file!.bytes!);
                        }
                        FFAppState().update(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      FFLocalizations.of(context).getText('veh0015'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExtraImageUpload(
                      image: _insuranceImage,
                      isValid: _isInsuranceValid,
                      onImageSelected: (file) {
                        setState(() {
                          _insuranceImage = file;
                          _isInsuranceValid = true;
                        });

                        FFAppState().insuranceImage = file;
                        if (file?.bytes != null) {
                          FFAppState().insuranceBase64 = base64Encode(file!.bytes!);
                        }
                        FFAppState().update(() {});
                      },
                    ),

                    const SizedBox(height: 32),


                    // Submit Button
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





  Widget _buildExtraImageUpload({
    required FFUploadedFile? image,
    required bool isValid,
    required Function(FFUploadedFile?) onImageSelected,
  }) {
    bool hasImage =
    (image?.bytes != null && image!.bytes!.isNotEmpty);

    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
          context: context,
          allowPhoto: true,
        );

        if (selectedMedia != null &&
            selectedMedia.every(
                    (m) => validateFileFormat(m.storagePath, context))) {
          final file = FFUploadedFile(
            name: selectedMedia.first.storagePath.split('/').last,
            bytes: selectedMedia.first.bytes,
          );

          onImageSelected(file);
          _showSnackBar(
              FFLocalizations.of(context).getText('upload0001'));
        }
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.greyBorder,
            width: 1.5,
          ),
        ),
        child: hasImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            image.bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sectionOrangeLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                FFLocalizations.of(context).getText('upload0002'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.greySlate,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeFromApi() {
    return FutureBuilder<ApiCallResponse>(
      future: ChoosevehicleCall.call(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: const Center(
              child: SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data?.statusCode != 200) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: AppColors.greySlate, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    FFLocalizations.of(context).getText('veh0016'),
                    style: TextStyle(color: AppColors.greySlate, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: Text(
                    FFLocalizations.of(context).getText('cv0006'),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
        final rawList = ChoosevehicleCall.data(snapshot.data!.jsonBody);
        final list = (rawList is List) ? rawList : [];
        if (list.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Text(
              FFLocalizations.of(context).getText('veh0017'),
              style: TextStyle(color: AppColors.greySlate, fontSize: 14),
            ),
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
            final imageUrl = (imagePath != null && imagePath.isNotEmpty && imagePath != 'null')
                ? (imagePath.startsWith('http') ? imagePath : '${app_config.Config.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}')
                : null;
            final isSelected = (_selectedVehicleType != null && _selectedVehicleType!.toLowerCase() == name.toLowerCase()) || _selectedVehicleTypeId == id;
            return _buildVehicleTypeCard(name, id, imageUrl, isSelected);
          },
        );
      },
    );
  }

  Widget _buildVehicleTypeCard(String name, int id, String? imageUrl, bool isSelected) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sectionOrangeLight : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyBorder,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sectionOrangeLight : AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(_getVehicleIcon(name), size: 28, color: isSelected ? AppColors.primary : AppColors.greySlate))
                    : Icon(_getVehicleIcon(name), size: 28, color: isSelected ? AppColors.primary : AppColors.greySlate),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.textDark : AppColors.greySlate,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.greyBorder,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedVehicleTypeChip(String vehicleName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sectionOrangeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            FFLocalizations.of(context)
                .getText('veh0018')
                .replaceAll('%1', vehicleName),
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
    if (n.contains('bike') || n.contains('motorcycle')) return Icons.two_wheeler;
    if (n.contains('car') || n.contains('sedan') || n.contains('suv')) return Icons.directions_car;
    if (n.contains('truck')) return Icons.local_shipping;
    return Icons.directions_car_rounded;
  }

  String _getColorLabel(String name) {
    switch (name.toLowerCase()) {
      case 'white':
        return FFLocalizations.of(context).getText('color0001');
      case 'black':
        return FFLocalizations.of(context).getText('color0002');
      case 'silver':
        return FFLocalizations.of(context).getText('color0003');
      case 'red':
        return FFLocalizations.of(context).getText('color0004');
      case 'blue':
        return FFLocalizations.of(context).getText('color0005');
      case 'grey':
        return FFLocalizations.of(context).getText('color0006');
      default:
        return name;
    }
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
        if (_makeController.text.isNotEmpty && !options.contains(_makeController.text)) {
          options = [_makeController.text, ...options];
        }
        return _buildDropdownField(
          label: FFLocalizations.of(context).getText('veh0019'),
          hint: FFLocalizations.of(context).getText('veh0020'),
          icon: Icons.directions_car,
          value: _makeController.text.isEmpty ? null : _makeController.text,
          items: options,
          onChanged: (v) {
            setState(() {
              _makeController.text = v ?? '';
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
        if (_modelController.text.isNotEmpty && !options.contains(_modelController.text)) {
          options = [_modelController.text, ...options];
        }
        return _buildDropdownField(
          label: FFLocalizations.of(context).getText('veh0021'),
          hint: FFLocalizations.of(context).getText('veh0022'),
          icon: Icons.car_rental,
          value: _modelController.text.isEmpty ? null : _modelController.text,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (value != null && value.isNotEmpty) ? AppColors.primary : AppColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: (value != null && value.isNotEmpty && items.contains(value)) ? value : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.greyLight, fontSize: 15),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              suffixIcon: (value != null && value.isNotEmpty)
                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.greySlate),
            dropdownColor: AppColors.white,
            isExpanded: true,
            items: items.map((s) => DropdownMenuItem<String>(value: s, child: Text(s, style: const TextStyle(fontSize: 15, color: AppColors.textDark)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.text.isNotEmpty ? AppColors.primary : AppColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.greyLight,
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
              if (label == 'Vehicle Name') {
                FFAppState().vehicleName = value;
                FFAppState().vehicleMake = value;
              } else if (label == 'Vehicle Model') {
                FFAppState().vehicleModel = value;
              } else if (label == 'Year') {
                FFAppState().vehicleYear = value;
              } else if (label == 'License Plate') {
                FFAppState().licensePlate = value;
              } else if (label == 'Registration Number') {
                FFAppState().registrationNumber = value;
              } else if (label == 'Registration Date') {
                FFAppState().registrationDate = value;
              } else if (label == 'Insurance Number') {
                FFAppState().insuranceNumber = value;
              } else if (label == 'Insurance Expiry') {
                FFAppState().insuranceExpiryDate = value;
              } else if (label == 'Pollution Certificate Expiry') {
                FFAppState().pollutionExpiryDate = value;
              }
              FFAppState().update(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: vehicleColors.map((colorData) {
        bool isSelected = _selectedColor == colorData['name'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedColor = colorData['name']);
            FFAppState().vehicleColor = colorData['name'];
            FFAppState().update(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sectionOrangeLight : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.greyBorder,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorData['color'],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorData['border'],
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getColorLabel(colorData['name'] as String),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.primary: AppColors.greySlate,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 16, color: AppColors.primary),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoUpload(bool hasImage) {
    return GestureDetector(
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
          context: context,
          allowPhoto: true,
        );
        if (selectedMedia != null &&
            selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
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
              _vehicleImage = selectedUploadedFiles.first;
              _model.uploadedLocalFile_uploadData69q = _vehicleImage!;
              _isVehicleImageValid = true;
            });

            FFAppState().vehicleImage = _vehicleImage;
            if (_vehicleImage?.bytes != null) {
              FFAppState().vehicleBase64 = base64Encode(_vehicleImage!.bytes!);
            }
            FFAppState().update(() {});
              _showSnackBar(
                  FFLocalizations.of(context).getText('upload0001'));
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
            color: hasImage ? AppColors.primary : AppColors.greyBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _vehicleImage?.bytes != null && _vehicleImage!.bytes!.isNotEmpty
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
                      decoration: BoxDecoration(
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
                    Text(
                      FFLocalizations.of(context).getText('upload0003'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greySlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FFLocalizations.of(context).getText('upload0004'),
                      style: const TextStyle(
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
                  onTap: () {
                    setState(() {
                      _vehicleImage = null;
                      _isVehicleImageValid = false;
                    });
                    FFAppState().vehicleImage = null;
                    FFAppState().vehicleBase64 = '';
                    FFAppState().update(() {});
                    _showSnackBar(
                      FFLocalizations.of(context).getText('upload0008'),
                      isError: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: AppColors.white, size: 18),
                  ),
                ),
              ),

            if (hasImage && _isVehicleImageValid)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        FFLocalizations.of(context).getText('upload0005'),
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

  Widget _buildSubmitButton(bool hasImage) {
    final hasVehicleType = (_selectedVehicleType != null && _selectedVehicleType!.isNotEmpty) ||
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
          colors: [AppColors.primary, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: isFormValid ? null : AppColors.greyBorder,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isFormValid
              ? () async {
            final vType = _selectedVehicleType ?? (FFAppState().selectvehicle.isNotEmpty ? FFAppState().selectvehicle : FFAppState().vehicleType);
            if (vType.isNotEmpty) {
              FFAppState().vehicleType = vType;
              FFAppState().selectvehicle = vType;
              if (_selectedVehicleTypeId > 0) FFAppState().adminVehicleId = _selectedVehicleTypeId;
            }
            FFAppState().vehicleName = _makeController.text;
            FFAppState().vehicleMake = _makeController.text;
            FFAppState().vehicleModel = _modelController.text;
            FFAppState().vehicleColor = _selectedColor ?? '';
            FFAppState().licensePlate = _licensePlateController.text;
            FFAppState().registrationNumber = _regNumberController.text;
            FFAppState().registrationDate = _regDateController.text;
            FFAppState().insuranceNumber = _insuranceNumberController.text;
            FFAppState().insuranceExpiryDate = _insuranceExpiryController.text;
            FFAppState().pollutionExpiryDate = _pollutionExpiryController.text;
            FFAppState().vehicleImage = _vehicleImage;
            FFAppState().pollutionImage = _pollutionImage;
            FFAppState().insuranceImage = _insuranceImage;

            if (_vehicleImage?.bytes != null) {
              FFAppState().vehicleBase64 = base64Encode(_vehicleImage!.bytes!);
            }

            FFAppState().update(() {});

            _showSnackBar(
              FFLocalizations.of(context).getText('veh0024'));

            await Future.delayed(const Duration(milliseconds: 600));
            context.pop();
          }
              : () {
            if (!hasVehicleType) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0025'),
                  isError: true);
            } else if (_makeController.text.isEmpty) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0026'),
                  isError: true);
            } else if (_modelController.text.isEmpty) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0027'),
                  isError: true);
            } else if (!hasImage) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0028'),
                  isError: true);
            }
            else if (_pollutionImage == null) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0029'),
                  isError: true);
            }
            else if (_insuranceImage == null) {
              _showSnackBar(
                  FFLocalizations.of(context).getText('veh0030'),
                  isError: true);
            }
          },
          child: Center(
            child: Text(
              FFLocalizations.of(context).getText('veh0023'),
              style: TextStyle(
                color: isFormValid ? AppColors.white : AppColors.greyLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
