import '/backend/api_requests/api_calls.dart';
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
  String selected = "normal";

  dynamic normal;
  dynamic pro;

  String? vehicleName;
  String? vehicleImage;

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
      setState(() {
        normal = VehiclePricingCall.normal(response.jsonBody);
        pro = VehiclePricingCall.pro(response.jsonBody);
        vehicleName = VehiclePricingCall.vehicleName(response.jsonBody);
        vehicleImage = VehiclePricingCall.vehicleImage(response.jsonBody);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFFF7B10);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = selected == "normal" ? normal : pro;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Card"),
        elevation: 0,
        backgroundColor: Color(0xFFFF7B10),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// HERO HEADER
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: .15),
                    Colors.orange.withValues(alpha: .05),
                  ],
                ),
              ),
              child: Column(
                children: [

                  /// Image + Name
                  Row(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: vehicleImage != null
                            ? Padding(
                          padding: const EdgeInsets.all(10),

                          child: Image.network(
                            vehicleImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.directions_bike),
                          ),
                        )
                            : const Icon(Icons.directions_bike),
                      ),

                      const SizedBox(width: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleName ?? "",
                            style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Pricing Details",
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                ],
              ),
            ),


            /// PRICING CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NORMAL / PRO TOGGLE (inside card)
                  Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selected = "normal"),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected == "normal"
                                    ? const Color(0xFFFF7B10)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Normal",
                                  style: GoogleFonts.inter(
                                    color: selected == "normal"
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selected = "pro"),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected == "pro"
                                    ? const Color(0xFFFF7B10)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Pro",
                                  style: GoogleFonts.inter(
                                    color: selected == "pro"
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      const Icon(Icons.route, color: brand),
                      const SizedBox(width: 8),
                      Text(
                        "${data['base_km_start']}km – ${data['base_km_end']}km",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text("Base distance ride",
                      style: GoogleFonts.inter(color: Colors.grey)),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Base Fare",
                            style: GoogleFonts.inter(fontSize: 15)),
                        Text(
                          "₹${data['base_fare']}",
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("After ${data['base_km_end']}km",
                          style: GoogleFonts.inter(color: Colors.grey)),
                      Text(
                        "₹${data['price_per_km']} / km",
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Extra distance will be charged per kilometer.",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
