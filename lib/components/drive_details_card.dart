import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/constants/responsive.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'drive_details_card_model.dart';

export 'drive_details_card_model.dart';

class DriveDetailsCard extends StatefulWidget {
  const DriveDetailsCard({super.key});

  @override
  State<DriveDetailsCard> createState() => _DriveDetailsCardState();
}

class _DriveDetailsCardState extends State<DriveDetailsCard>
    with SingleTickerProviderStateMixin {
  late DriveDetailsCardModel _model;
  late AnimationController _shimmerController;

  bool _isLoading = true;
  String _vehicleNumber = '';
  String _vehicleName = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  String _verificationStatus = '';
  String _insuranceExpiry = '';
  String _pollutionExpiry = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriveDetailsCardModel());
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadVehicleDetails();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _loadVehicleDetails() async {
    final driverId = FFAppState().driverid;
    if (driverId <= 0) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _populateFromAppState();
      });
      return;
    }

    try {
      final response = await GetVehicleByDriverIdCall.call(driverId: driverId);

      if (!mounted) return;
      if (response.succeeded &&
          GetVehicleByDriverIdCall.success(response.jsonBody) == true) {
        final body = response.jsonBody;
        setState(() {
          _vehicleNumber =
              GetVehicleByDriverIdCall.licensePlate(body) ?? '';
          _vehicleName =
              GetVehicleByDriverIdCall.vehicleName(body) ?? '';
          _vehicleModel =
              GetVehicleByDriverIdCall.vehicleModel(body) ?? '';
          _vehicleColor =
              GetVehicleByDriverIdCall.vehicleColor(body) ?? '';
          _verificationStatus =
              GetVehicleByDriverIdCall.verificationStatus(body) ?? '';
          _insuranceExpiry =
              GetVehicleByDriverIdCall.insuranceExpiry(body) ?? '';
          _pollutionExpiry =
              GetVehicleByDriverIdCall.pollutionExpiry(body) ?? '';
          _isLoading = false;
        });
      } else {
        _populateFromAppState();
        setState(() => _isLoading = false);
      }
    } catch (_) {
      _populateFromAppState();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = _vehicleNumber.isEmpty;
      });
    }
  }

  void _populateFromAppState() {
    final appState = FFAppState();
    _vehicleNumber = appState.licensePlate.isNotEmpty
        ? appState.licensePlate
        : appState.registrationNumber;
    _vehicleName = appState.vehicleName;
    _vehicleModel = appState.vehicleModel;
    _vehicleColor = appState.vehicleColor;
  }

  String get _displayName {
    if (_vehicleName.isNotEmpty) return _vehicleName;
    final make = FFAppState().vehicleMake;
    if (make.isNotEmpty || _vehicleModel.isNotEmpty) {
      return '${make.trim()} ${_vehicleModel.trim()}'.trim();
    }
    return FFAppState().vehicleType.isNotEmpty
        ? FFAppState().vehicleType
        : 'My Vehicle';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'pending_verification':
        return AppColors.accentAmber;
      case 'rejected':
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.greyLight;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return 'Verified';
      case 'pending':
      case 'pending_verification':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'suspended':
        return 'Suspended';
      default:
        return status.isNotEmpty ? status : 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (_isLoading) return _buildShimmer(context);

    final hasVehicle = _vehicleNumber.isNotEmpty || _displayName != 'My Vehicle';
    if (!hasVehicle && _hasError) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drive Details',
                            style: GoogleFonts.inter(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_displayName != 'My Vehicle')
                            Text(
                              _displayName,
                              style: GoogleFonts.inter(
                                fontSize: Responsive.fontSize(context, 12),
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_verificationStatus.isNotEmpty)
                      _buildStatusBadge(_verificationStatus),
                  ],
                ),

                const SizedBox(height: 20),

                // Vehicle number plate
                if (_vehicleNumber.isNotEmpty) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1E293B),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'IND',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _vehicleNumber.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: Responsive.fontSize(context, 22),
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Info chips row
                _buildInfoRow(context),

                // Expiry info
                if (_insuranceExpiry.isNotEmpty ||
                    _pollutionExpiry.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_insuranceExpiry.isNotEmpty)
                          Expanded(
                            child: _buildExpiryItem(
                              icon: Icons.shield_outlined,
                              label: 'Insurance',
                              date: _insuranceExpiry,
                            ),
                          ),
                        if (_insuranceExpiry.isNotEmpty &&
                            _pollutionExpiry.isNotEmpty)
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        if (_pollutionExpiry.isNotEmpty)
                          Expanded(
                            child: _buildExpiryItem(
                              icon: Icons.eco_outlined,
                              label: 'Pollution',
                              date: _pollutionExpiry,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    final chips = <Widget>[];

    if (_vehicleColor.isNotEmpty) {
      chips.add(_buildInfoChip(
        icon: Icons.palette_outlined,
        label: _vehicleColor,
      ));
    }
    if (_vehicleModel.isNotEmpty) {
      chips.add(_buildInfoChip(
        icon: Icons.two_wheeler_rounded,
        label: _vehicleModel,
      ));
    }
    final year = FFAppState().vehicleYear;
    if (year.isNotEmpty) {
      chips.add(_buildInfoChip(
        icon: Icons.calendar_today_rounded,
        label: year,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryItem({
    required IconData icon,
    required String label,
    required String date,
  }) {
    final isExpired = _isDateExpired(date);
    final color = isExpired ? AppColors.error : AppColors.success;

    return Column(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatDate(date),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  bool _isDateExpired(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildShimmer(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2.0 * _shimmerController.value, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }
}
