import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'vehicle_image_model.dart';
export 'vehicle_image_model.dart';

class VehicleImageUpdateWidget extends StatefulWidget {
  const VehicleImageUpdateWidget({super.key});

  static String routeName = 'vehicleImageUpdate';
static String routePath = '/vehicleImageUpdate';

  @override
  State<VehicleImageUpdateWidget> createState() => _VehicleImageUpdateWidgetState();
}

class _VehicleImageUpdateWidgetState extends State<VehicleImageUpdateWidget>
    with SingleTickerProviderStateMixin {
  late VehicleImageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FFUploadedFile? _vehicleImage;
  bool _isVehicleImageValid = false;

  String? _selectedVehicleType;
  String? _selectedColor;

  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> vehicleTypes = [
    {'name': 'Car', 'icon': '🚗', 'color': AppColors.accentIndigo},
    {'name': 'Bike', 'icon': '🏍️', 'color': AppColors.accentPink},
    {'name': 'Truck', 'icon': '🚚', 'color': AppColors.accentEmerald},
    {'name': 'SUV', 'icon': '🚙', 'color': AppColors.accentAmber},
  ];

  final List<Map<String, dynamic>> vehicleColors = [
    {'name': 'White', 'color': AppColors.white, 'border': Colors.grey[300]},
    {'name': 'Black', 'color': AppColors.black, 'border': Colors.black},
    {'name': 'Silver', 'color': AppColors.silver, 'border': Colors.grey[400]},
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

    if (FFAppState().vehicleType.isNotEmpty) {
      setState(() => _selectedVehicleType = FFAppState().vehicleType);
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
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[400] : Colors.green[500],
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
          backgroundColor: Colors.white,
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
                    // Vehicle Type
                    const Text(
                      'Vehicle Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleTypeGrid(),

                    const SizedBox(height: 24),

                    // Make
                    _buildSimpleTextField(
                      controller: _makeController,
                      label: 'Vehicle Make',
                      hint: 'e.g., Toyota, Honda',
                      icon: Icons.directions_car,
                    ),

                    const SizedBox(height: 20),

                    // Model
                    _buildSimpleTextField(
                      controller: _modelController,
                      label: 'Vehicle Model',
                      hint: 'e.g., Camry, Civic',
                      icon: Icons.car_rental,
                    ),

                    const SizedBox(height: 20),

                    // Year
                    _buildSimpleTextField(
                      controller: _yearController,
                      label: 'Year',
                      hint: 'e.g., 2023',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    // Color
                    const Text(
                      'Vehicle Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildColorGrid(),

                    const SizedBox(height: 24),

                    // Photo Upload
                    const Text(
                      'Vehicle Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoUpload(hasImage),

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

  Widget _buildVehicleTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: vehicleTypes.length,
      itemBuilder: (context, index) {
        final type = vehicleTypes[index];
        bool isSelected = _selectedVehicleType == type['name'];

        return GestureDetector(
          onTap: () {
            setState(() => _selectedVehicleType = type['name']);
            FFAppState().vehicleType = type['name'];
            FFAppState().update(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? type['color'] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? type['color'] : AppColors.greyBorder,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: type['color'].withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  type['name'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.greySlate,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.text.isNotEmpty ? AppColors.accentIndigo : AppColors.greyBorder,
              width: 2,
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
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyLight,
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, color: AppColors.accentIndigo, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? const Icon(Icons.check_circle, color: AppColors.accentEmerald, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
              if (label == 'Vehicle Make') {
                FFAppState().vehicleMake = value;
              } else if (label == 'Vehicle Model') {
                FFAppState().vehicleModel = value;
              } else if (label == 'Year') {
                FFAppState().vehicleYear = value;
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
              color: isSelected ? AppColors.accentIndigo.withValues(alpha:0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accentIndigo : AppColors.greyBorder,
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
                  colorData['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.accentIndigo : AppColors.greySlate,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 16, color: AppColors.accentIndigo),
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
            _showSnackBar('Photo uploaded successfully! ✓');
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: hasImage ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.accentEmerald : AppColors.greyBorder,
            width: 2,
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
                        color: AppColors.accentIndigo.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: AppColors.accentIndigo,
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
                      color: Colors.red[400],
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
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
                    color: AppColors.accentEmerald,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Uploaded',
                        style: TextStyle(
                          color: Colors.white,
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
    bool isFormValid = _selectedVehicleType != null &&
        _makeController.text.isNotEmpty &&
        _modelController.text.isNotEmpty &&
        _yearController.text.isNotEmpty &&
        _selectedColor != null &&
        hasImage;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isFormValid
            ? const LinearGradient(
          colors: [AppColors.accentIndigo, AppColors.accentPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: isFormValid ? null : AppColors.greyBorder,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
          BoxShadow(
            color: AppColors.accentIndigo.withValues(alpha:0.4),
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
            FFAppState().vehicleType = _selectedVehicleType!;
            FFAppState().vehicleYear = _yearController.text;
            FFAppState().vehicleMake = _makeController.text;
            FFAppState().vehicleModel = _modelController.text;
            FFAppState().vehicleColor = _selectedColor!;
            FFAppState().vehicleImage = _vehicleImage;

            if (_vehicleImage?.bytes != null) {
              FFAppState().vehicleBase64 = base64Encode(_vehicleImage!.bytes!);
            }

            FFAppState().update(() {});

            _showSnackBar('✓ Vehicle details saved successfully!');

            await Future.delayed(const Duration(milliseconds: 600));
            context.pop();
          }
              : () {
            if (_selectedVehicleType == null) {
              _showSnackBar('Please select vehicle type', isError: true);
            } else if (_makeController.text.isEmpty) {
              _showSnackBar('Please enter vehicle make', isError: true);
            } else if (_modelController.text.isEmpty) {
              _showSnackBar('Please enter vehicle model', isError: true);
            } else if (_yearController.text.isEmpty) {
              _showSnackBar('Please enter year', isError: true);
            } else if (_selectedColor == null) {
              _showSnackBar('Please select color', isError: true);
            } else if (!hasImage) {
              _showSnackBar('Please upload vehicle photo', isError: true);
            }
          },
          child: Center(
            child: Text(
              'Save Vehicle Details',
              style: TextStyle(
                color: isFormValid ? Colors.white : AppColors.greyLight,
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
