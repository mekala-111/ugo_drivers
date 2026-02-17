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

  double todayTotal = 0.0;
int todayRideCount = 0;
double todayWallet = 0.0;
double lastRideAmount = 0.0;
bool isLoadingEarnings = true;


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
        _fetchTodayEarnings(),
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
    final isSmallScreen = screenWidth < 360;

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
              SizedBox(height: isSmallScreen ? 20 : 32),
              _buildTopAppBar(screenWidth, isSmallScreen),

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
                                fontSize: 22,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              driverName,
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30),
                            Icon(
                              Icons.location_off_rounded,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "You are currently Offline",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 40),
                            GestureDetector(
                              onTap: _isDataLoaded ? _toggleOnlineStatus : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
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
                                        color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "GO ONLINE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                _buildCollapsibleBottomIncentive(screenWidth, isSmallScreen),
              if (shouldShowPanels)
                _buildCollapsibleBottomPanel(screenWidth, isSmallScreen),

              SizedBox(height: isSmallScreen ? 10 : 15),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopAppBar(double screenWidth, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 45 : 60,
      decoration: BoxDecoration(color: Color(0xFFFF7B10)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              InkWell(
                onTap: () => context.pushNamed(ScanToBookWidget.routeName),
                child: Icon(Icons.qr_code, color: Colors.black, size: 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(
                      (_model.switchValue ?? false) ? 'ON' : 'OFF',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _model.switchValue ?? false,
                      onChanged:
                          _isDataLoaded ? (val) => _toggleOnlineStatus() : null,
                      // ✅ FIXED: Use activeTrackColor instead of activeColor
                      activeTrackColor: Colors.green,
                      activeThumbColor: Colors.white, // Thumb color
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  context.pushNamed(TeampageWidget.routeName);
                },
                child: Icon(Icons.people, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleBottomIncentive(
      double screenWidth, bool isSmallScreen) {
    bool hasIncentives = incentiveTiers.isNotEmpty;

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
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incentives',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
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
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: hasIncentives ? Colors.black : Colors.grey,
                          ),
                        ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Icon(
                        _isIncentivePanelExpanded
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
          if (_isIncentivePanelExpanded)
            isLoadingIncentives
                ? _buildLoadingIndicator(isSmallScreen)
                : hasIncentives
                    ? _buildIncentiveProgressBars(screenWidth, isSmallScreen)
                    : _buildComingSoonMessage(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7B10)),
      ),
    );
  }

  Widget _buildIncentiveProgressBars(double screenWidth, bool isSmallScreen) {
    int totalRequiredRides = incentiveTiers.isNotEmpty
        ? incentiveTiers
            .map((t) => t.targetRides)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16,
        0,
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 12 : 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentRides/$totalRequiredRides',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalIncentiveEarned.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7B10),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...incentiveTiers
              .map((tier) => _buildIncentiveTierBar(
                    tier: tier,
                    currentRides: currentRides,
                    isSmallScreen: isSmallScreen,
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
  }) {
    double progress = (currentRides / tier.targetRides).clamp(0.0, 1.0);
    bool isCompleted = currentRides >= tier.targetRides;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
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
                    size: isSmallScreen ? 16 : 18,
                    color: tier.isLocked ? Colors.grey : Color(0xFFFF7B10),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${tier.targetRides} rides',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: tier.isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '+₹${tier.rewardAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Color(0xFFFF7B10),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: isSmallScreen ? 28 : 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
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

  Widget _buildComingSoonMessage(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      child: Column(
        children: [
          Icon(
            Icons.star_border_rounded,
            size: isSmallScreen ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Coming Soon or Please Complete first ride to view Incentives',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Exciting incentive programs will be available soon!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

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
                        isLoadingEarnings ? '...' : todayTotal.toStringAsFixed(0),
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
                      child: 
                     _buildOrangeCard(
                      'Ride Count',
                      isLoadingEarnings ? '...' : todayRideCount.toString(),
                      screenWidth,
                      isSmallScreen,
                    ),
                    ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                      child: 
                     _buildOrangeCard(
                      'Wallet',
                      isLoadingEarnings ? '...' : todayWallet.toStringAsFixed(0),
                      screenWidth,
                      isSmallScreen,
                    ),

                          ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                      child: 
                     _buildOrangeCard(
                    'Last Ride',
                    isLoadingEarnings ? '...' : lastRideAmount.toStringAsFixed(0),
                    screenWidth,
                    isSmallScreen,
                  ),

                          ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  Future<void> _fetchTodayEarnings() async {
  try {
    setState(() => isLoadingEarnings = true);

    final response = await DriverEarningsCall.call(
      driverId: FFAppState().driverid,
      token: FFAppState().accessToken,
      period: "daily",
    );

    if (response.succeeded) {
      final data = response.jsonBody['data'];

      todayTotal = (data['totalEarnings'] ?? 0).toDouble();
      todayRideCount = data['totalRides'] ?? 0;
      todayWallet = (data['walletEarnings'] ?? 0).toDouble();

      List rides = data['rides'] ?? [];
      if (rides.isNotEmpty) {
        lastRideAmount =
            (rides.first['amount'] ?? 0).toDouble(); // latest ride
      }
    }
  } catch (e) {
    print("❌ Earnings error: $e");
  } finally {
    setState(() => isLoadingEarnings = false);
  }
}


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
}