import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'choose_vehicle_model.dart';
export 'choose_vehicle_model.dart';

// ✅ Ensure OnBoardingWidget is accessible
import '/on_boarding/on_boarding_widget.dart';

class ChooseVehicleWidget extends StatefulWidget {
  const ChooseVehicleWidget({
    super.key,
    this.mobile,
    this.firstname,
    this.lastname,
    this.email,
    this.referalcode,
  });

  final int? mobile;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? referalcode;

  static String routeName = 'Choose_vehicle';
  static String routePath = '/chooseVehicle';

  @override
  State<ChooseVehicleWidget> createState() => _ChooseVehicleWidgetState();
}

class _ChooseVehicleWidgetState extends State<ChooseVehicleWidget> {
  late ChooseVehicleModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChooseVehicleModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 APP COLORS
    const Color brandPrimary = Color(0xFFFF7B10);
    const Color brandGradientStart = Color(0xFFFF8E32);
    const Color bgOffWhite = Color(0xFFF5F7FA);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: Column(
          children: [
            // ==========================================
            // 1️⃣ VIBRANT HEADER
            // ==========================================
            Container(
              height: 180, // Compact header
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandGradientStart, brandPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Spacer(),
                      Center(
                        child: const Text(
                          "Vehicle Type",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "How do you want to earn?",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 2️⃣ VEHICLE LIST (Floating)
            // ==========================================
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: FutureBuilder<ApiCallResponse>(
                    future: ChoosevehicleCall.call(),
                    builder: (context, snapshot) {
                      // LOADING
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(brandPrimary),
                          ),
                        );
                      }

                      // ERROR
                      if (snapshot.hasError ||
                          snapshot.data?.statusCode != 200) {
                        return _buildErrorState(brandPrimary);
                      }

                      final response = snapshot.data!;
                      return Builder(
                        builder: (context) {
                          final rawList = ChoosevehicleCall.data(response.jsonBody);
                          final vehicleList = (rawList is List) ? rawList : [];

                          if (vehicleList.isEmpty) {
                            return Center(
                              child: Text(
                                'No vehicles available',
                                style: GoogleFonts.inter(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: vehicleList.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = vehicleList[index];

                              // Safe Name Extraction
                              String vehicleName = '';
                              if (item is Map) {
                                vehicleName = item['name']?.toString() ?? '';
                              } else {
                                vehicleName = getJsonField(item, r'$["name"]')?.toString() ?? '';
                              }

                              if (vehicleName.isEmpty) vehicleName = "Unknown";

                              final isSelected =
                                  FFAppState().selectvehicle == vehicleName;

                              return _buildVehicleCard(
                                vehicleName,
                                isSelected,
                                brandPrimary,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // ==========================================
            // 3️⃣ CONTINUE BUTTON (Fixed Bottom)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: FFAppState().selectvehicle.isEmpty
                      ? null
                      : () {
                    context.pushNamed(
                      OnBoardingWidget.routeName,
                      queryParameters: {
                        'mobile': serializeParam(
                            widget.mobile, ParamType.int),
                        'firstname': serializeParam(
                            widget.firstname, ParamType.String),
                        'lastname': serializeParam(
                            widget.lastname, ParamType.String),
                        'email': serializeParam(
                            widget.email, ParamType.String),
                        'referalcode': serializeParam(
                            widget.referalcode, ParamType.String),
                        'vehicletype': serializeParam(
                            FFAppState().selectvehicle, ParamType.String),
                      }.withoutNulls,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.interTight(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Custom Vehicle Card Widget
  Widget _buildVehicleCard(String name, bool isSelected, Color brandColor) {
    return InkWell(
      onTap: () {
        setState(() {
          FFAppState().selectvehicle = name;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? brandColor.withValues(alpha:0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? brandColor.withValues(alpha:0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getVehicleIcon(name),
                size: 32,
                color: isSelected ? brandColor : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(
                name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
            ),

            // Checkmark
            if (isSelected)
              Icon(Icons.check_circle, color: brandColor, size: 28)
            else
              Icon(Icons.radio_button_unchecked, color: Colors.grey.shade300, size: 28),
          ],
        ),
      ),
    );
  }

  // 🔹 Error State Widget
  Widget _buildErrorState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Failed to load vehicles",
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {}),
            child: Text(
              "Retry",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // 🔹 Icon Mapping Logic
  IconData _getVehicleIcon(String vehicleName) {
    final name = vehicleName.toLowerCase();
    if (name.contains('auto')) return Icons.local_taxi; // Or use FontAwesomeIcons.taxi
    if (name.contains('bike') || name.contains('motorcycle')) return Icons.two_wheeler;
    if (name.contains('car') || name.contains('sedan') || name.contains('suv')) return Icons.directions_car;
    if (name.contains('truck')) return Icons.local_shipping;
    return Icons.directions_car_rounded;
  }
}