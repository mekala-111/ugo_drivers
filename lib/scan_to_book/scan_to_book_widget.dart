import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'scan_to_book_model.dart';
export 'scan_to_book_model.dart';

class ScanToBookWidget extends StatefulWidget {
  const ScanToBookWidget({super.key});

  static String routeName = 'scan_to_book';
  static String routePath = '/scanToBook';

  @override
  State<ScanToBookWidget> createState() => _ScanToBookWidgetState();
}

class _ScanToBookWidgetState extends State<ScanToBookWidget>
    with SingleTickerProviderStateMixin {
  late ScanToBookModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Driver Data State
  String _driverName = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScanToBookModel());

    // 1️⃣ Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2️⃣ Fetch Driver Data
    _fetchDriverData();
  }

  /// 🚀 Fetch Driver Data from API
  /// 🚀 Fetch Driver Data from API
  Future<void> _fetchDriverData() async {
    try {
      final driverId = FFAppState().driverid;
      final token = FFAppState().accessToken;

      if (driverId == 0 || token.isEmpty) {
        setState(() {
          _driverName = 'Guest Driver';
          _isLoading = false;
        });
        return;
      }

      final response = await DriverIdfetchCall.call(
        id: driverId,
        token: token,
      );

      if (response.succeeded == true || response.statusCode == 200) {
        // ✅ Correctly extract First & Last Name
        final firstName = getJsonField(response.jsonBody, r'$.data.first_name')?.toString() ?? '';
        final lastName = getJsonField(response.jsonBody, r'$.data.last_name')?.toString() ?? '';

        // Combine them
        final fullName = '$firstName $lastName'.trim();

        setState(() {
          _driverName = fullName.isNotEmpty ? fullName : 'Driver';
          _isLoading = false;
        });
      } else {
        setState(() {
          _driverName = 'Driver'; // Fallback
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching driver data: $e');
      setState(() {
        _driverName = 'Driver';
        _isLoading = false;
      });
    }
  }
  @override
  void dispose() {
    _model.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1️⃣ Orange Background Gradient
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandGradientStart, brandPrimary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),

            // 3️⃣ Main Content
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Instruction Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'd5nsxfra' /* Scan the QR Code to Book Your Ride */,
                        ),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.white,
                          fontSize: 28.0,
                          lineHeight: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Show this code to the passenger',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha:0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 60.0),

                    // Animated QR Card
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 280.0,
                        height: 280.0,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: brandPrimary.withValues(alpha:0.3),
                              blurRadius: 30.0,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // The QR Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                'https://ugo-api.icacorp.org/${FFAppState().qrImage}',
                                width: 220.0,
                                height: 220.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_2_rounded,
                                            size: 60, color: Colors.grey.shade300),
                                        const SizedBox(height: 8),
                                        Text(
                                          'QR not available',
                                          style: TextStyle(color: Colors.grey.shade400),
                                        )
                                      ],
                                    ),
                              ),
                            ),

                            // Corner Accents
                            _buildCornerCorners(brandPrimary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // ✅ User Info / Footer (Dynamic Name)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: brandPrimary)
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              color: brandPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'NAME : $_driverName', // ✅ Dynamic Name
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to draw scanner corners
  Widget _buildCornerCorners(Color color) {
    double length = 30.0;
    double thickness = 4.0;
    double offset = -5.0;

    return Stack(
      children: [
        // Top Left
        Positioned(
          top: offset,
          left: offset,
          child: Container(
            width: length,
            height: length,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
            ),
          ),
        ),
        // Top Right
        Positioned(
          top: offset,
          right: offset,
          child: Container(
            width: length,
            height: length,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
            ),
          ),
        ),
        // Bottom Left
        Positioned(
          bottom: offset,
          left: offset,
          child: Container(
            width: length,
            height: length,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
            ),
          ),
        ),
        // Bottom Right
        Positioned(
          bottom: offset,
          right: offset,
          child: Container(
            width: length,
            height: length,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}