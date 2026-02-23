import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RateCardWidget extends StatefulWidget {
  const RateCardWidget({super.key});

  @override
  State<RateCardWidget> createState() => _RateCardWidgetState();
}

class _RateCardWidgetState extends State<RateCardWidget> {
  bool isLoading = true;
  String selectedPlan = 'normal'; // normal, pro

  dynamic normal;
  dynamic pro;
  String? vehicleName;
  String? vehicleImage;

  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.successAlt;
  static const Color sectionGreen = AppColors.sectionGreen;

  @override
  void initState() {
    super.initState();
    fetchPricing();
  }

  Future<void> fetchPricing() async {
    final response = await VehiclePricingCall.call(
      driverId: FFAppState().driverid,
      token: FFAppState().accessToken,
    );

    if (response.succeeded) {
      final n = VehiclePricingCall.normal(response.jsonBody);
      final pr = VehiclePricingCall.pro(response.jsonBody);
      setState(() {
        normal = n;
        pro = pr;
        vehicleName = VehiclePricingCall.vehicleName(response.jsonBody);
        vehicleImage = VehiclePricingCall.vehicleImage(response.jsonBody);
        if (n == null && pr != null) selectedPlan = 'pro';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  dynamic get pricing => selectedPlan == 'normal' ? normal : pro;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPricingContent(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Rate Card',
        style: GoogleFonts.inter(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[100],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headset_mic_outlined, size: 16, color: Colors.grey[800]),
              const SizedBox(width: 6),
              Text(
                'Help',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingContent() {
    if (pricing == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No pricing data available',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle header + Normal/Pro toggle
          if (vehicleName != null || vehicleImage != null) ...[
            _buildVehicleHeader(),
            const SizedBox(height: 16),
          ],
          if (normal != null && pro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  _buildPlanChip('Normal', 'normal'),
                  const SizedBox(width: 12),
                  _buildPlanChip('Pro', 'pro'),
                ],
              ),
            ),
          _buildPricingSection(),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (vehicleImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vehicleImage!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: Icon(Icons.directions_car, color: Colors.grey[400]),
                ),
              ),
            ),
          if (vehicleImage != null) const SizedBox(width: 16),
          Text(
            (vehicleName ?? 'Vehicle').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanChip(String label, String value) {
    final isSelected = selectedPlan == value;
    return GestureDetector(
      onTap: () => setState(() => selectedPlan = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ugoOrange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    final p = pricing;
    if (p == null || p is! Map) return const SizedBox.shrink();

    final baseKmStart = p['base_km_start'];
    final baseKmEnd = p['base_km_end'];
    final baseFare = p['base_fare'];
    final pricePerKm = p['price_per_km'];

    final List<Widget> children = [];

    if (baseFare != null) {
      children.add(_buildFareRow('Base Fare', 'For completing an order', '₹$baseFare'));
      if (baseKmStart != null || baseKmEnd != null) children.add(_buildDivider());
    }
    if (baseKmStart != null || baseKmEnd != null) {
      children.add(_buildFareRow(
        'Base Distance',
        'Included in base fare',
        '${baseKmStart ?? 0} to ${baseKmEnd ?? 0} km',
      ));
      if (pricePerKm != null) children.add(_buildDivider());
    }
    if (pricePerKm != null) {
      children.add(_buildFareRow(
        'After base distance',
        'Per kilometer charge',
        '₹$pricePerKm per km',
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Pricing',
      bgColor: sectionGreen,
      titleColor: ugoGreen,
      children: children,
    );
  }

  Widget _buildSection({
    required String title,
    required Color bgColor,
    required Color titleColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String description, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }
}
