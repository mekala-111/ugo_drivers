import 'package:ugo_driver/account_support/documents.dart';
import 'package:ugo_driver/account_support/editg_address.dart';
import 'package:ugo_driver/app_settings/app_setting_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geocoding/geocoding.dart';
import 'account_support_model.dart';
export 'account_support_model.dart';

class AccountSupportWidget extends StatefulWidget {
  const AccountSupportWidget({super.key});

  static String routeName = 'Account_support';
  static String routePath = '/accountSupport';

  @override
  State<AccountSupportWidget> createState() => _AccountSupportWidgetState();
}

class _AccountSupportWidgetState extends State<AccountSupportWidget>
    with SingleTickerProviderStateMixin {
  late AccountSupportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? driverData;
  bool isLoading = true;
  String currentLocationAddress = 'Fetching location...';
  bool isLoadingAddress = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountSupportModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    fetchDriverDetails();
    _animationController.forward();
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    const String baseUrl = 'https://ugotaxi.icacorp.org';
    String cleanPath = imagePath;
    if (imagePath.startsWith('uploads/')) {
      cleanPath = imagePath.substring('uploads/'.length);
    }

    return '$baseUrl/$cleanPath';
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDriverDetails() async {
    setState(() => isLoading = true);

    try {
      final response = await DriverIdfetchCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
      );

      if (response.succeeded) {
        setState(() {
          driverData = DriverIdfetchCall.driverData(response.jsonBody);
          isLoading = false;
        });

        // Fetch current location address from coordinates
        _fetchCurrentLocationAddress();
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Failed to load profile', isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // 🔥 NEW: Fetch address from lat/long using reverse geocoding
  Future<void> _fetchCurrentLocationAddress() async {
    if (driverData == null) return;

    final lat = driverData!['current_location_latitude'];
    final lon = driverData!['current_location_longitude'];

    if (lat == null || lon == null) {
      setState(() {
        currentLocationAddress = 'Location not available';
      });
      return;
    }

    setState(() {
      isLoadingAddress = true;
      currentLocationAddress = 'Fetching address...';
    });

    try {
      // Convert to double if needed
      double latitude = lat is String ? double.parse(lat) : lat.toDouble();
      double longitude = lon is String ? double.parse(lon) : lon.toDouble();

      // Reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build readable address
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        setState(() {
          currentLocationAddress = addressParts.isEmpty
              ? 'Address not found'
              : addressParts.join(', ');
          isLoadingAddress = false;
        });
      } else {
        setState(() {
          currentLocationAddress = 'Address not found';
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        currentLocationAddress = 'Unable to fetch address';
        isLoadingAddress = false;
      });
    }
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
            SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[400] : Colors.green[500],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String getFullAddress() {
    if (driverData == null) return 'No address available';

    final address = driverData!['address'] ?? '';
    final city = driverData!['city'] ?? '';
    final state = driverData!['state'] ?? '';
    final postalCode = driverData!['postal_code'] ?? '';

    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (postalCode.isNotEmpty) parts.add(postalCode);

    return parts.isEmpty ? 'No address available' : parts.join(', ');
  }

  String getDriverName() {
    if (driverData == null) return 'Driver Name';

    final firstName = driverData!['first_name'] ?? '';
    final lastName = driverData!['last_name'] ?? '';

    return '${firstName} ${lastName}'.trim().isEmpty
        ? 'Driver Name'
        : '${firstName} ${lastName}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B00), Color(0xFFFF8C00), Color(0xFFFFA726)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 12.0,
              buttonSize: 50.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          title: Text(
            FFLocalizations.of(context).getText('ysdtmrd0' /* Account */),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: fetchDriverDetails,
            color: Color(0xFFFF8C00),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    SizedBox(height: 16),
                    if (driverData != null) _buildCurrentLocationCard(),
                    SizedBox(height: 20),
                    _buildMenuItems(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF8C00).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: driverData?['profile_image'] != null &&
                    driverData!['profile_image'].toString().isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: getFullImageUrl(driverData!['profile_image']),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                  ),
                )
                    : Container(
                  color: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                ),
              ),
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getDriverName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          driverData?['mobile_number'] ?? 'No number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 NEW: Current Location Card with Real Address
  Widget _buildCurrentLocationCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live GPS location',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoadingAddress)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                  ),
                )
              else
                Icon(Icons.refresh, color: Colors.grey[400], size: 20),
            ],
          ),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentLocationAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.description_rounded,
        'title': FFLocalizations.of(context).getText('9bn2wxvo' /* Documents */),
        'color': Color(0xFF6366F1),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DocumentsScreen()),
        ),
      },
      {
        'icon': Icons.payment_rounded,
        'title': FFLocalizations.of(context).getText('34o7vjtz' /* Payment */),
        'color': Color(0xFF10B981),
        'onTap': () {},
      },
      {
        'icon': Icons.edit_location_rounded,
        'title': FFLocalizations.of(context).getText('d1egk9by' /* Edit Address */),
        'color': Color(0xFFF59E0B),
        'onTap': () {
          if (driverData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditAddressScreen(
                  driverData: driverData!,
                  onUpdate: () => fetchDriverDetails(),
                ),
              ),
            );
          }
        },
      },
      {
        'icon': Icons.info_rounded,
        'title': FFLocalizations.of(context).getText('huk3perd' /* About */),
        'color': Color(0xFF8B5CF6),
        'onTap': () {},
      },
      {
        'icon': Icons.security_rounded,
        'title': FFLocalizations.of(context).getText('1gepgp40' /* Security */),
        'color': Color(0xFFEC4899),
        'onTap': () {},
      },
      {
        'icon': Icons.settings_rounded,
        'title': FFLocalizations.of(context).getText('glh63usn' /* App Settings */),
        'color': Color(0xFF64748B),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppSettingsWidget()),
        ),
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? Radius.circular(16) : Radius.zero,
                  bottom: isLast ? Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 60,
                  color: Colors.grey[200],
                ),
            ],
          );
        }),
      ),
    );
  }
}
