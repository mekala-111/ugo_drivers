import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'home_model.dart';
export 'home_model.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import './ride_request_overlay.dart';

const String BASE_URL = "http://192.168.1.14:5001";
String DRIVER_TOKEN = FFAppState().accessToken;
int DRIVER_ID = FFAppState().driverid;

const double LOCATION_UPDATE_THRESHOLD = 50.0;

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;
  final GlobalKey<RideRequestOverlayState> _overlayKey =
  GlobalKey<RideRequestOverlayState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  late IO.Socket socket;
  LatLng? acceptedPickupLocation;
  bool showNavigateButton = false;

  StreamSubscription<Position>? _locationSubscription;
  Position? _lastSavedPosition;
  bool _isTrackingLocation = false;
  DateTime? _lastBackPressed;
  bool _isDataLoaded = false;

  bool _isPanelExpanded = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Future(() async {
          _model.userDetails = await DriverIdfetchCall.call(
            token: FFAppState().accessToken,
            id: FFAppState().driverid,
          );
        }),
        Future(() async {
          _model.postQR = await PostQRcodeCall.call(
            token: FFAppState().accessToken,
            driverId: FFAppState().driverid,
          );
        }),
      ]);

      print(
          '✅ accessToken: ${FFAppState().accessToken}, driverId: ${FFAppState().driverid}');

      String kycStatus = getJsonField(
        (_model.userDetails?.jsonBody ?? ''),
        r'''$.data.kyc_status''',
      ).toString();

      FFAppState().kycStatus = kycStatus.trim();

      print('🔍 KYC Status Retrieved: "${FFAppState().kycStatus}"');
      print('🔍 KYC Status Length: ${FFAppState().kycStatus.length}');

      FFAppState().qrImage = getJsonField(
        (_model.postQR?.jsonBody ?? ''),
        r'''$.data.qr_code_image''',
      ).toString();

      bool? isOnline = DriverIdfetchCall.isonline(_model.userDetails?.jsonBody);
      if (isOnline == true) {
        _model.switchValue = true;
        safeSetState(() {});
        _startLocationTracking();
      } else {
        _model.switchValue = false;
        safeSetState(() {});
      }

      setState(() {
        _isDataLoaded = true;
      });

      _initSocket();
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  Future<void> _startLocationTracking() async {
    if (_isTrackingLocation) {
      print("⚠️ Location tracking already active");
      return;
    }

    print("📍 Starting location tracking...");
    _isTrackingLocation = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled");
      _isTrackingLocation = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Location permissions denied");
        _isTrackingLocation = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ Location permissions permanently denied");
      _isTrackingLocation = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permission permanently denied. Please enable in settings.'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
      return;
    }

    try {
      print("📡 Getting initial position...");
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastSavedPosition = initialPosition;
      print(
          "✅ Initial position: ${initialPosition.latitude}, ${initialPosition.longitude}");

      await _updateLocationToServer(initialPosition);
    } catch (e) {
      print("❌ Error getting initial position: $e");
    }

    print("🎧 Starting position stream listener...");
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _handleLocationUpdate(position);
    });

    print("✅ Location tracking started successfully");
  }

  Future<void> _handleLocationUpdate(Position newPosition) async {
    if (_lastSavedPosition == null) {
      print("📍 First location update, saving to server...");
      _lastSavedPosition = newPosition;
      await _updateLocationToServer(newPosition);
      return;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      _lastSavedPosition!.latitude,
      _lastSavedPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    print(
        "📏 Distance moved: ${distanceInMeters.toStringAsFixed(2)}m (Threshold: ${LOCATION_UPDATE_THRESHOLD}m)");

    if (distanceInMeters >= LOCATION_UPDATE_THRESHOLD) {
      print("🚀 ✅ Threshold crossed! Updating location to server...");
      await _updateLocationToServer(newPosition);
      _lastSavedPosition = newPosition;
    } else {
      print("⏳ Distance < 50m, skipping server update");
    }

    if (mounted) {
      setState(() {
        currentUserLocationValue = LatLng(
          newPosition.latitude,
          newPosition.longitude,
        );
      });
    }
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      print("📤 Updating location to server:");
      print("   Latitude: ${position.latitude}");
      print("   Longitude: ${position.longitude}");

      final response = await UpdateDriverCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (response.succeeded) {
        print("✅ Location updated successfully to server");
        String? message = UpdateDriverCall.message(response.jsonBody);
        if (message != null) {
          print("   Server message: $message");
        }
      } else {
        print("❌ Failed to update location: ${response.statusCode}");
        print("   Response: ${response.jsonBody}");
      }
    } catch (e) {
      print("❌ Error updating location: $e");
    }
  }

  Future<void> _goOnlineAsync() async {
    if (FFAppState().kycStatus.trim().toLowerCase() != 'approved') {
      safeSetState(() => _model.switchValue = false);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('KYC Not Approved'),
          content: Text(
            'Your KYC status is "${FFAppState().kycStatus}". '
                'Please complete KYC to go online.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("❌ Location error: $e");
    }

    final res = await UpdateDriverCall.call(
      id: FFAppState().driverid,
      token: FFAppState().accessToken,
      isonline: true,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    if (res.succeeded) {
      _startLocationTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UpdateDriverCall.message(res.jsonBody) ?? 'You are online',
          ),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    } else {
      safeSetState(() => _model.switchValue = false);
    }
  }

  Future<void> _goOfflineAsync() async {
    _stopLocationTracking();

    final res = await UpdateDriverCall.call(
      id: FFAppState().driverid,
      token: FFAppState().accessToken,
      isonline: false,
      latitude: null,
      longitude: null,
    );

    if (!res.succeeded) {
      safeSetState(() => _model.switchValue = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to go offline'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  void _stopLocationTracking() {
    if (!_isTrackingLocation) {
      print("⚠️ Location tracking already stopped");
      return;
    }

    print("🛑 Stopping location tracking...");
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTrackingLocation = false;
    _lastSavedPosition = null;
    print("✅ Location tracking stopped successfully");
  }

  void _initSocket() {
    print("🔌 Initializing Socket...");

    socket = IO.io(
      'https://ugotaxi.icacorp.org',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': DRIVER_TOKEN})
          .build(),
    );

    socket.onConnecting((data) => print("⏳ Connecting..."));
    socket.onConnectError((data) => print("❌ Connection Error: $data"));
    socket.onError((data) => print("❌ General Error: $data"));
    socket.onDisconnect((data) => print("🔌 Disconnected: $data"));

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit("watch_entity", {"type": "driver", "id": DRIVER_ID});
    });

    socket.on('driver_rides', (data) {
      print('📦 Initial Rides: $data');
      _passDataToOverlay(data);
    });

    socket.on('ride_updated', (data) {
      print('🔔 Ride Update: $data');
      _passDataToOverlay(data);
    });

    socket.connect();
  }

  void _passDataToOverlay(dynamic data) {
    if (_overlayKey.currentState == null) return;

    void processSingleRide(Map<String, dynamic> rideData) {
      String status = rideData['ride_status'] ?? 'SEARCHING';
      int rideId = rideData['id'];
      _overlayKey.currentState!.handleNewRide(rideData);
      print("Processing ride ID: $rideId with status: $status");
    }

    if (data is List) {
      for (var ride in data) {
        processSingleRide(ride);
      }
    } else {
      processSingleRide(data);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _stopLocationTracking();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    if (currentUserLocationValue == null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6600),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
            _lastBackPressed = now;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          }
          return true;
        },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: isSmallScreen ? 20 : 32),
              // ✅ TOP ORANGE APP BAR
              _buildTopAppBar(screenWidth, isSmallScreen),
              // ✅ GOOGLE MAP (takes remaining space)
              Expanded(
                child: Stack(
                  children: [
                    // Google Map
                    FlutterFlowGoogleMap(
                      controller: _model.googleMapsController,
                      onCameraIdle: (latLng) =>
                      _model.googleMapsCenter = latLng,
                      initialLocation: _model.googleMapsCenter ??=
                      currentUserLocationValue!,
                      markerColor: GoogleMarkerColor.violet,
                      mapType: MapType.normal,
                      style: GoogleMapStyle.standard,
                      initialZoom: 14,
                      allowInteraction: true,
                      allowZoom: true,
                      showZoomControls: false,
                      showLocation: true,
                      showCompass: false,
                      showMapToolbar: false,
                      showTraffic: false,
                      centerMapOnMarkerTap: true,
                    ),

                    // Ride Request Overlay
                    RideRequestOverlay(key: _overlayKey),

                    // ✅ My Location Button (responsive position)

                  ],
                ),
              ),

              // ✅ COLLAPSIBLE BOTTOM PANEL
              _buildCollapsibleBottomPanel(screenWidth, isSmallScreen),

              // ✅ PROGRESS BAR AT VERY BOTTOM
              _buildBottomProgressBar(screenWidth, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ RESPONSIVE TOP APP BAR WIDGET
  Widget _buildTopAppBar(double screenWidth, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 45 : 60,
      decoration: BoxDecoration(
        color: Color(0xFFFF7B10),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hamburger Menu
              InkWell(
                onTap: () async {
                  context.pushNamed(AccountManagementWidget.routeName);
                },
                child: Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isSmallScreen ? 24 : 28,
                        height: isSmallScreen ? 2.5 : 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 5),
                      Container(
                        width: isSmallScreen ? 24 : 28,
                        height: isSmallScreen ? 2.5 : 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 5),
                      Container(
                        width: isSmallScreen ? 24 : 28,
                        height: isSmallScreen ? 2.5 : 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // QR Code Button
              Container(
                width: isSmallScreen ? 30 :30,
                height: isSmallScreen ? 30 : 30,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
                child: InkWell(
                  onTap: () async {
                    context.pushNamed(ScanToBookWidget.routeName);
                  },
                  child: Center(
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.black,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                ),
              ),

              // ON/OFF Toggle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(30),),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (_model.switchValue ?? false) ? 'ON' : 'OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Transform.scale(
                      scale: isSmallScreen ? 0.9 : 1.0,
                      child: Switch(
                        value: _model.switchValue ?? false,
                        onChanged: _isDataLoaded
                            ? (newValue) {
                          safeSetState(
                                  () => _model.switchValue = newValue);
                          if (newValue) {
                            _goOnlineAsync();
                          } else {
                            _goOfflineAsync();
                          }
                        }
                            : null,
                        activeColor: Colors.black,
                        activeTrackColor: Colors.grey.shade300,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.grey.shade400,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              // Team Icon + Label
              InkWell(
                onTap: () async {
                  context.pushNamed(TeampageWidget.routeName);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isSmallScreen ? 25 : 30,
                      height: isSmallScreen ? 20 : 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.people,
                          color: Color(0xFFFF6600),
                          size: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'TEAM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ RESPONSIVE COLLAPSIBLE BOTTOM PANEL
  Widget _buildCollapsibleBottomPanel(double screenWidth, bool isSmallScreen) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row (Today Total + Arrow)
          InkWell(
            onTap: () {
              setState(() {
                _isPanelExpanded = !_isPanelExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today Total',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '500.00',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Icon(
                        _isPanelExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Content (Orange Cards)
          if (_isPanelExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                0,
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _buildOrangeCard(
                          'Ride Count', '13', screenWidth, isSmallScreen)),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                      child: _buildOrangeCard(
                          'Wallet', '600.00', screenWidth, isSmallScreen)),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                      child: _buildOrangeCard(
                          'Last Ride', '100', screenWidth, isSmallScreen)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ✅ RESPONSIVE ORANGE METRIC CARD
  Widget _buildOrangeCard(
      String title, String value, double screenWidth, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 8 : 12,
        horizontal: isSmallScreen ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFB785),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ RESPONSIVE BOTTOM PROGRESS BAR
  Widget _buildBottomProgressBar(double screenWidth, bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 20 : 40,
      color: Colors.grey.shade200,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      child: Row(
        children: [
          // Progress Bar
          Expanded(
            child: Container(
              height: isSmallScreen ? 32 : 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                child: Stack(
                  children: [
                    // Tire Track Watermark Pattern
                    FractionallySizedBox(
                      widthFactor: 0.3, // 30% progress (replace dynamically)
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius:
                          BorderRadius.circular(isSmallScreen ? 16 : 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ CUSTOM PAINTER FOR BIKE TIRE TRACK WATERMARK
