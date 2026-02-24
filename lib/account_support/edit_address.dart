import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> driverData;
  final VoidCallback onUpdate;

  const EditAddressScreen({
    super.key,
    required this.driverData,
    required this.onUpdate,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool isUpdating = false;
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();

    _latitudeController = TextEditingController(
      text: widget.driverData['current_location_latitude']?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.driverData['current_location_longitude']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  String getFullAddress() {
    final address = widget.driverData['address'] ?? '';
    final city = widget.driverData['city'] ?? '';
    final state = widget.driverData['state'] ?? '';
    final postalCode = widget.driverData['postal_code'] ?? '';

    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (postalCode.isNotEmpty) parts.add(postalCode);

    return parts.isEmpty ? 'No address available' : parts.join(', ');
  }

  Future<void> getCurrentLocation() async {
    setState(() => isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!context.mounted) return;
      if (!serviceEnabled) {
        setState(() => isFetchingLocation = false);
        _showSnackBar('Location services are disabled. Please enable them.', Colors.orange);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (!context.mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!context.mounted) return;
        if (permission == LocationPermission.denied) {
          setState(() => isFetchingLocation = false);
          _showSnackBar('Location permission denied', AppColors.error);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        setState(() => isFetchingLocation = false);
        _showSnackBar('Location permissions are permanently denied', AppColors.error);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!context.mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        isFetchingLocation = false;
      });

      _showSnackBar('Current location fetched successfully!', AppColors.success);
    } catch (e) {
      if (!context.mounted) return;
      setState(() => isFetchingLocation = false);
      _showSnackBar('Error getting location: $e', AppColors.error);
    }
  }

  Future<void> updateDriverLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdating = true);

    try {
      double? latitude = double.tryParse(_latitudeController.text);
      double? longitude = double.tryParse(_longitudeController.text);

      final response = await UpdateDriverCall.call(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        latitude: latitude,
        longitude: longitude,
      );

      setState(() => isUpdating = false);

      if (!context.mounted) return;
      if (response.succeeded) {
        _showSnackBar('Location updated successfully!', AppColors.success);
        widget.onUpdate();
        if (context.mounted) Navigator.pop(context);
      } else {
        _showSnackBar('Failed to update location', AppColors.error);
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => isUpdating = false);
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCoordinates = _latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // Soft background color
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          elevation: 0,
          leading: FlutterFlowIconButton(
            borderRadius: 30.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26.0),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Address',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Current Address Card ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: AppColors.primary, size: 20.0),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Current Registered Address',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            getFullAddress(),
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700], height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- Action Section Header ---
                    Text(
                      'Update GPS Location',
                      style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap the button below to accurately pinpoint your current location for rides.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600], height: 1.4),
                    ),

                    const SizedBox(height: 20),

                    // --- Fetch Location Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isFetchingLocation || isUpdating ? null : getCurrentLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLightBg, // Soft orange background
                          foregroundColor: AppColors.primary, // Orange text/icon
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: isFetchingLocation
                            ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                        )
                            : const Icon(Icons.my_location, size: 22),
                        label: Text(
                          isFetchingLocation ? 'Fetching Location...' : 'Use Current Location',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- Animated Coordinates Display ---
                    AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuart,
                      child: hasCoordinates
                          ? Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 20.0),
                                const SizedBox(width: 10),
                                Text(
                                  'Location Detected',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCoordinateRow('Latitude', _latitudeController.text),
                            const SizedBox(height: 8),
                            _buildCoordinateRow('Longitude', _longitudeController.text),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 24),

                    // --- Bottom Action Buttons ---
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isUpdating || isFetchingLocation || !hasCoordinates ? null : updateDriverLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: isUpdating
                            ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                            : Text(
                          'Save Location',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: TextButton(
                        onPressed: isUpdating || isFetchingLocation ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for rendering coordinates cleanly
  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      children: [
        Icon(Icons.gps_fixed, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}