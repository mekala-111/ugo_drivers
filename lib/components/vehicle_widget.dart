import '/config.dart' as app_config;
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vehicle_model.dart';
export 'vehicle_model.dart';

/// Displays driver's vehicle info from FFAppState (aligned with vehicles table).
class VehicleWidget extends StatefulWidget {
  const VehicleWidget({
    super.key,
    this.onEditTap,
  });

  final VoidCallback? onEditTap;

  @override
  State<VehicleWidget> createState() => _VehicleWidgetState();
}

class _VehicleWidgetState extends State<VehicleWidget> {
  late VehicleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehicleModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _vehicleDisplayName() {
    final name = FFAppState().vehicleName;
    if (name.isNotEmpty) return name;
    final make = FFAppState().vehicleMake;
    final model = FFAppState().vehicleModel;
    if (make.isNotEmpty || model.isNotEmpty) {
      return '${make.trim()} ${model.trim()}'.trim();
    }
    return FFAppState().vehicleType.isNotEmpty
        ? FFAppState().vehicleType
        : 'My Vehicle';
  }

  String _vehicleSubtitle() {
    final parts = <String>[];
    if (FFAppState().vehicleColor.isNotEmpty) parts.add(FFAppState().vehicleColor);
    if (FFAppState().vehicleYear.isNotEmpty) parts.add(FFAppState().vehicleYear);
    if (FFAppState().licensePlate.isNotEmpty) parts.add(FFAppState().licensePlate);
    return parts.join(' • ');
  }

  String? _vehicleImageUrl() {
    final url = FFAppState().vehicleImageUrl;
    if (url.isNotEmpty) return app_config.Config.fullImageUrl(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final hasVehicleData = FFAppState().vehicleType.isNotEmpty ||
        FFAppState().vehicleName.isNotEmpty ||
        FFAppState().vehicleMake.isNotEmpty ||
        FFAppState().vehicleImage?.bytes != null ||
        FFAppState().vehicleImageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Vehicle Details',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasVehicleData) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _vehicleImageUrl() != null
                          ? Image.network(
                              _vehicleImageUrl()!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                            )
                          : FFAppState().vehicleImage?.bytes != null
                              ? Image.memory(
                                  FFAppState().vehicleImage!.bytes!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : _buildPlaceholderIcon(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _vehicleDisplayName(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (_vehicleSubtitle().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _vehicleSubtitle(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          if (FFAppState().registrationNumber.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'RC: ${FFAppState().registrationNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.onEditTap != null)
                      IconButton(
                        onPressed: widget.onEditTap,
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      ),
                  ],
                ),
              ),
            ] else
              GestureDetector(
                onTap: widget.onEditTap ?? () => context.pushNamed(VehicleImageUpdateWidget.routeName),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_circle_outline, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Add Vehicle Details',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
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

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.backgroundAlt,
      child: Icon(Icons.directions_car, size: 32, color: Colors.grey[400]),
    );
  }
}
