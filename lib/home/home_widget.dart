import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'home_model.dart';
export 'home_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import './ride_request_overlay.dart';
import './incentive_model.dart';
import '/components/menu_widget.dart';

const String BASE_URL = "https://ugo-api.icacorp.org";
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

  StreamSubscription<Position>? _locationSubscription;
  Position? _lastSavedPosition;
  bool _isTrackingLocation = false;
  DateTime? _lastBackPressed;
  bool _isDataLoaded = false;

  // Panel States
  bool _isIncentivePanelExpanded = false;
  bool _isPanelExpanded = false;

  // Driver Data
  String driverName = "${FFAppState().firstName} ${FFAppState().lastName}";

  // ✅ TRACK STATUS
  String _currentRideStatus = 'IDLE';

  // Incentive Data
  int currentRides = 0;
  double totalIncentiveEarned = 0.0;
  List<IncentiveTier> incentiveTiers = [];
  bool isLoadingIncentives = true;

  // 🗺️ UBER-LIKE MAP STYLE (Silver Theme)

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    // 1. Run Initial Checks immediately
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        _fetchDriverProfile(),
        _fetchInitialRideStatus(),
        _fetchIncentiveData(),
      ]);

      setState(() {
        _isDataLoaded = true;
      });

      _initSocket();
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  Future<void> _fetchInitialRideStatus() async {
    if (FFAppState().activeRideId != 0) {
      setState(() {
        _currentRideStatus = 'FETCHING';
      });
    }
  }

  Future<void> _fetchDriverProfile() async {
    _model.userDetails = await DriverIdfetchCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    _model.postQR = await PostQRcodeCall.call(
      token: FFAppState().accessToken,
      driverId: FFAppState().driverid,
    );

    // Extract Name
    if (_model.userDetails?.jsonBody != null) {
      String fetchedName = getJsonField(
        _model.userDetails?.jsonBody,
        r'''$.data.first_name''',
      ).toString();

      if (fetchedName != "null" && fetchedName.isNotEmpty) {
        setState(() => driverName = fetchedName);
      }
    }

    String kycStatus = getJsonField(
      (_model.userDetails?.jsonBody ?? ''),
      r'''$.data.kyc_status''',
    ).toString();
    FFAppState().kycStatus = kycStatus.trim();
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
  }

  // --- HELPER METHODS ---

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Future<void> _toggleOnlineStatus() async {
    bool intendedValue = !(_model.switchValue ?? false);

    if (intendedValue == false) {
      String status = _currentRideStatus.toUpperCase();
      if (['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP'].contains(status)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot go offline during an active ride!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    safeSetState(() => _model.switchValue = intendedValue);
    if (intendedValue) {
      await _goOnlineAsync();
    } else {
      await _goOfflineAsync();
    }
  }

  Future<void> _fetchIncentiveData() async {
    try {
      setState(() => isLoadingIncentives = true);

      final response = await GetDriverIncentivesCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (response.succeeded) {
        final incentivesArray = getJsonField(
          response.jsonBody,
          r'''$.data''',
          true,
        );

        if (incentivesArray != null && incentivesArray is List) {
          currentRides = 0;
          for (var item in incentivesArray) {
            int completedRides = item['completed_rides'] ?? 0;
            if (completedRides > currentRides) {
              currentRides = completedRides;
            }
          }

          totalIncentiveEarned = 0.0;
          for (var item in incentivesArray) {
            if (item['progress_status'] == 'completed') {
              String rewardStr = item['reward_amount'] ?? '0';
              totalIncentiveEarned += double.tryParse(rewardStr) ?? 0.0;
            }
          }

          incentiveTiers = incentivesArray.map<IncentiveTier>((item) {
            return IncentiveTier(
              id: item['id'] ?? 0,
              targetRides: item['target_rides'] ?? 0,
              rewardAmount:
                  double.tryParse(item['reward_amount'] ?? '0') ?? 0.0,
              isLocked: item['progress_status'] != 'ongoing' &&
                  item['progress_status'] != 'completed',
              description: item['incentive']?['name'],
            );
          }).toList();
        } else {
          incentiveTiers = [];
        }
      } else {
        incentiveTiers = [];
      }
    } catch (e) {
      print('❌ Error fetching incentive data: $e');
      incentiveTiers = [];
    } finally {
      setState(() => isLoadingIncentives = false);
    }
  }

  // ✅ FIXED: Using LocationSettings instead of desiredAccuracy
  Future<void> _startLocationTracking() async {
    if (_isTrackingLocation) return;
    _isTrackingLocation = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isTrackingLocation = false;
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isTrackingLocation = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isTrackingLocation = false;
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _lastSavedPosition = initialPosition;
      await _updateLocationToServer(initialPosition);
    } catch (e) {
      print("Error getting position: $e");
    }

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      _handleLocationUpdate(position);
    });
  }

  Future<void> _handleLocationUpdate(Position newPosition) async {
    if (_lastSavedPosition == null) {
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

    if (distanceInMeters >= LOCATION_UPDATE_THRESHOLD) {
      await _updateLocationToServer(newPosition);
      _lastSavedPosition = newPosition;
    }

    if (mounted) {
      setState(() {
        currentUserLocationValue =
            LatLng(newPosition.latitude, newPosition.longitude);
      });
    }
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      await UpdateDriverCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print("Error updating location: $e");
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
              'Your KYC status is "${FFAppState().kycStatus}". Please complete KYC.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
          ],
        ),
      );
      return;
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      print(e);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You are online'), backgroundColor: Colors.green));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to go offline'),
          backgroundColor: Colors.red));
    }
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTrackingLocation = false;
    _lastSavedPosition = null;
  }

  void _initSocket() {
    String token = FFAppState().accessToken;
    int driverId = FFAppState().driverid;
    socket = IO.io(
        'https://ugo-api.icacorp.org',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token})
            .build());

    socket.onConnect((_) {
      print('✅ Socket CONNECTED');
      socket.emit("watch_entity", {"type": "driver", "id": driverId});
    });

    socket.on('driver_rides', (data) {
      _passDataToOverlay(data);
    });
    socket.on('ride_updated', (data) {
      _passDataToOverlay(data);
    });

    socket.onDisconnect((_) => print('⚠️ Socket Disconnected'));

    socket.connect();
  }

  void _passDataToOverlay(dynamic data) {
    if (_overlayKey.currentState == null) return;

    void processSingleRide(Map<String, dynamic> rideData) {
      String status =
          (rideData['ride_status'] ?? 'SEARCHING').toString().toUpperCase();
      print("🔄 Processing Status: \"$status\"");

      if (mounted) {
        setState(() {
          _currentRideStatus = status;
        });
      }

      _overlayKey.currentState!.handleNewRide(rideData);
    }

    if (data is List) {
      for (var ride in data) processSingleRide(ride);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 900;
    final isLandscape = screenHeight < screenWidth;

    // Scale calculation for responsive sizing
    final scale = isLargeTablet
        ? 1.2
        : isTablet
            ? 1.1
            : isMediumScreen
                ? 1.0
                : 0.9;

    // Responsive spacing values
    final topPaddingSmall = isSmallScreen ? 16.0 : 20.0;
    final topPaddingLarge = isSmallScreen ? 20.0 : 32.0;
    final horizontalPadding =
        isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final cardPadding = isSmallScreen ? 8.0 : 12.0;
    final appBarHeight = isSmallScreen
        ? 45.0
        : isMediumScreen
            ? 55.0
            : isTablet
                ? 65.0
                : 60.0;

    // Check if Online
    bool isOnline = _model.switchValue ?? false;

    // FIXED LOGIC for Bottom Panels
    bool shouldShowPanels = true;
    String status = _currentRideStatus.toUpperCase();
    if (['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP', 'COMPLETED', 'FETCHING']
        .contains(status)) {
      shouldShowPanels = false;
    }

    if (currentUserLocationValue == null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6600))),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        // ✅ FIXED: Updated to onPopInvokedWithResult
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
            _lastBackPressed = now;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2)));
          } else {
            // Allow exit
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          drawer: Drawer(elevation: 16.0, child: MenuWidget()),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: isLandscape ? topPaddingSmall : topPaddingLarge),
              _buildTopAppBar(screenWidth, screenHeight, isSmallScreen,
                  isMediumScreen, isTablet, appBarHeight, scale),

              Expanded(
                child: Stack(
                  children: [
                    // 1. MAP (ONLY VISIBLE IF ONLINE)
                    if (isOnline)
                      FlutterFlowGoogleMap(
                        controller: _model.googleMapsController,
                        onCameraIdle: (latLng) =>
                            _model.googleMapsCenter = latLng,
                        initialLocation: _model.googleMapsCenter ??=
                            currentUserLocationValue!,
                        markerColor: GoogleMarkerColor.orange,
                        mapType: MapType.normal,
                        // ✅ FIXED: Pass style manually since setMapStyle is removed
                        // style: GoogleMapStyle.silver, // We can pass enum here if FF component supports it
                        initialZoom: 16,
                        allowInteraction: true,
                        allowZoom: true,
                        showZoomControls: false,
                        showLocation: true,
                        showCompass: true,
                        showMapToolbar: true,
                        showTraffic: false,
                        centerMapOnMarkerTap: true,
                      ),

                    // 2. OFFLINE DASHBOARD
                    if (!isOnline)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${_getGreeting()},",
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 18
                                    : isMediumScreen
                                        ? 22
                                        : 24,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Text(
                              driverName,
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 24
                                    : isMediumScreen
                                        ? 28
                                        : 32,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 30),
                            Icon(
                              Icons.location_off_rounded,
                              size: isSmallScreen
                                  ? 60
                                  : isMediumScreen
                                      ? 70
                                      : 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Text(
                              "You are currently Offline",
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 14
                                    : isMediumScreen
                                        ? 16
                                        : 18,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 30 : 40),
                            GestureDetector(
                              onTap: _isDataLoaded ? _toggleOnlineStatus : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 30 : 40,
                                    vertical: isSmallScreen ? 12 : 15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF7B10),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF7B10)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.power_settings_new,
                                        color: Colors.white,
                                        size: isSmallScreen ? 20 : 22),
                                    SizedBox(width: isSmallScreen ? 8 : 10),
                                    Text(
                                      "GO ONLINE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen
                                            ? 16
                                            : isMediumScreen
                                                ? 18
                                                : 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 3. RIDE REQUEST OVERLAY (Always active)
                    RideRequestOverlay(key: _overlayKey),
                  ],
                ),
              ),

              // CONDITIONALLY SHOW PANELS
              if (shouldShowPanels)
                _buildCollapsibleBottomIncentive(
                    screenWidth,
                    screenHeight,
                    isSmallScreen,
                    isMediumScreen,
                    isTablet,
                    isLandscape,
                    scale,
                    cardPadding,
                    horizontalPadding),
              if (shouldShowPanels)
                _buildCollapsibleBottomPanel(
                    screenWidth,
                    screenHeight,
                    isSmallScreen,
                    isMediumScreen,
                    isTablet,
                    isLandscape,
                    scale,
                    cardPadding,
                    horizontalPadding),

              SizedBox(height: isSmallScreen ? 8 : (isLandscape ? 10 : 15)),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopAppBar(
      double screenWidth,
      double screenHeight,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isTablet,
      double appBarHeight,
      double scale) {
    return Container(
      width: double.infinity,
      height: appBarHeight,
      decoration: BoxDecoration(color: Color(0xFFFF7B10)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : (isMediumScreen ? 12 : 16),
              vertical: isSmallScreen ? 6 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: Icon(Icons.menu,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : (isMediumScreen ? 26 : 28)),
              ),
              InkWell(
                onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                child: Icon(Icons.qr_code,
                    color: Colors.black,
                    size: isSmallScreen
                        ? 20
                        : isMediumScreen
                            ? 22
                            : 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 3 : 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (_model.switchValue ?? false) ? 'ON' : 'OFF',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 11 : 12),
                    ),
                    SizedBox(
                      width: isSmallScreen ? 30 : 40,
                      height: isSmallScreen ? 24 : 32,
                      child: Switch(
                        value: _model.switchValue ?? false,
                        onChanged: _isDataLoaded
                            ? (val) => _toggleOnlineStatus()
                            : null,
                        // ✅ FIXED: Use activeTrackColor instead of activeColor
                        activeTrackColor: Colors.green,
                        activeThumbColor: Colors.white, // Thumb color
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  context.pushNamed(TeampageWidget.routeName);
                },
                child: Icon(Icons.people,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : (isMediumScreen ? 26 : 28)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleBottomIncentive(
      double screenWidth,
      double screenHeight,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isTablet,
      bool isLandscape,
      double scale,
      double cardPadding,
      double horizontalPadding) {
    bool hasIncentives = incentiveTiers.isNotEmpty;
    final panelPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final titleFontSize = isSmallScreen
        ? 13.0
        : isMediumScreen
            ? 14.0
            : 16.0;
    final valueFontSize = isSmallScreen
        ? 15.0
        : isMediumScreen
            ? 16.0
            : 18.0;

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
          InkWell(
            onTap: () {
              setState(() {
                _isIncentivePanelExpanded = !_isIncentivePanelExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: panelPadding,
                vertical: isSmallScreen ? 9 : 11,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incentives',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (isLoadingIncentives)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF7B10),
                            ),
                          ),
                        )
                      else
                        Text(
                          hasIncentives
                              ? '₹${totalIncentiveEarned.toStringAsFixed(0)}'
                              : 'Coming Soon',
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            color: hasIncentives ? Colors.black : Colors.grey,
                          ),
                        ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Icon(
                        _isIncentivePanelExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: isSmallScreen
                            ? 18.0
                            : isMediumScreen
                                ? 20.0
                                : 24.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isIncentivePanelExpanded)
            isLoadingIncentives
                ? _buildLoadingIndicator(isSmallScreen, isMediumScreen)
                : hasIncentives
                    ? _buildIncentiveProgressBars(
                        screenWidth,
                        screenHeight,
                        isSmallScreen,
                        isMediumScreen,
                        isTablet,
                        isLandscape,
                        scale,
                        cardPadding,
                        horizontalPadding)
                    : _buildComingSoonMessage(isSmallScreen, isMediumScreen),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen
          ? 20.0
          : isMediumScreen
              ? 24.0
              : 32.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7B10)),
      ),
    );
  }

  Widget _buildIncentiveProgressBars(
      double screenWidth,
      double screenHeight,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isTablet,
      bool isLandscape,
      double scale,
      double cardPadding,
      double horizontalPadding) {
    int totalRequiredRides = incentiveTiers.isNotEmpty
        ? incentiveTiers
            .map((t) => t.targetRides)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    final contentPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 14.0
            : 16.0;
    final titleFontSize = isSmallScreen
        ? 15.0
        : isMediumScreen
            ? 16.0
            : 18.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        contentPadding,
        0,
        contentPadding,
        contentPadding,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentRides/$totalRequiredRides',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalIncentiveEarned.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7B10),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 14),
          ...incentiveTiers
              .map((tier) => _buildIncentiveTierBar(
                    tier: tier,
                    currentRides: currentRides,
                    isSmallScreen: isSmallScreen,
                    isMediumScreen: isMediumScreen,
                    isTablet: isTablet,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildIncentiveTierBar({
    required IncentiveTier tier,
    required int currentRides,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isTablet,
  }) {
    double progress = (currentRides / tier.targetRides).clamp(0.0, 1.0);
    bool isCompleted = currentRides >= tier.targetRides;

    final barHeight = isSmallScreen
        ? 24.0
        : isMediumScreen
            ? 28.0
            : 32.0;
    final iconSize = isSmallScreen
        ? 14.0
        : isMediumScreen
            ? 16.0
            : 18.0;
    final borderRadius = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 14.0
            : 16.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tier.isLocked ? Icons.lock : Icons.lock_open,
                    size: iconSize,
                    color: tier.isLocked ? Colors.grey : Color(0xFFFF7B10),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${tier.targetRides} rides',
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? 12.0
                          : isMediumScreen
                              ? 13.0
                              : 14.0,
                      fontWeight: FontWeight.w600,
                      color: tier.isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? 13.0
                      : isMediumScreen
                          ? 14.0
                          : 16.0,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Color(0xFFFF7B10),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: tier.isLocked
                              ? [Colors.grey.shade400, Colors.grey.shade500]
                              : isCompleted
                                  ? [Colors.green, Colors.green.shade700]
                                  : [Color(0xFFFFB785), Color(0xFFFF7B10)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonMessage(bool isSmallScreen, bool isMediumScreen) {
    final iconSize = isSmallScreen
        ? 44.0
        : isMediumScreen
            ? 56.0
            : 64.0;
    final titleFontSize = isSmallScreen
        ? 16.0
        : isMediumScreen
            ? 18.0
            : 20.0;
    final descFontSize = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 13.0
            : 14.0;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen
          ? 20.0
          : isMediumScreen
              ? 24.0
              : 32.0),
      child: Column(
        children: [
          Icon(
            Icons.star_border_rounded,
            size: iconSize,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isSmallScreen ? 10 : 14),
          Text(
            'Coming Soon or Please Complete first ride to view Incentives',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Exciting incentive programs will be available soon!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descFontSize,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleBottomPanel(
      double screenWidth,
      double screenHeight,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isTablet,
      bool isLandscape,
      double scale,
      double cardPadding,
      double horizontalPadding) {
    final panelPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final titleFontSize = isSmallScreen
        ? 13.0
        : isMediumScreen
            ? 14.0
            : 16.0;
    final valueFontSize = isSmallScreen
        ? 15.0
        : isMediumScreen
            ? 16.0
            : 18.0;

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
          InkWell(
            onTap: () {
              setState(() {
                _isPanelExpanded = !_isPanelExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: panelPadding,
                vertical: isSmallScreen ? 9 : 11,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today Total',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '500.00',
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Icon(
                        _isPanelExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: isSmallScreen
                            ? 18.0
                            : isMediumScreen
                                ? 20.0
                                : 24.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isPanelExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                panelPadding,
                0,
                panelPadding,
                panelPadding,
              ),
              child: isSmallScreen
                  ? Column(
                      children: [
                        _buildOrangeCard(
                            'Ride Count',
                            '13',
                            screenWidth,
                            screenHeight,
                            isSmallScreen,
                            isMediumScreen,
                            isTablet),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        _buildOrangeCard(
                            'Wallet',
                            '600.00',
                            screenWidth,
                            screenHeight,
                            isSmallScreen,
                            isMediumScreen,
                            isTablet),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        _buildOrangeCard(
                            'Last Ride',
                            '100',
                            screenWidth,
                            screenHeight,
                            isSmallScreen,
                            isMediumScreen,
                            isTablet),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: _buildOrangeCard(
                                'Ride Count',
                                '13',
                                screenWidth,
                                screenHeight,
                                isSmallScreen,
                                isMediumScreen,
                                isTablet)),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                            child: _buildOrangeCard(
                                'Wallet',
                                '600.00',
                                screenWidth,
                                screenHeight,
                                isSmallScreen,
                                isMediumScreen,
                                isTablet)),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                            child: _buildOrangeCard(
                                'Last Ride',
                                '100',
                                screenWidth,
                                screenHeight,
                                isSmallScreen,
                                isMediumScreen,
                                isTablet)),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrangeCard(
      String title,
      String value,
      double screenWidth,
      double screenHeight,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isTablet) {
    final cardPadding = isSmallScreen ? 6.0 : (isMediumScreen ? 8.0 : 10.0);
    final titleFontSize = isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);
    final valueFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final borderRadius = isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: cardPadding,
        horizontal: cardPadding * 0.75,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFB785),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
