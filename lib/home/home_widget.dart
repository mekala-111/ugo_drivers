import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart'; // Ensure this exists
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'home_model.dart';
export 'home_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'ride_request_overlay.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  late HomeModel model;
  final GlobalKey<RideRequestOverlayState> overlayKey =
      GlobalKey<RideRequestOverlayState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // --- STATE VARIABLES ---
  LatLng? currentUserLocationValue;
  late IO.Socket socket;
  StreamSubscription<Position>? locationSubscription;
  Position? lastSavedPosition;
  bool isTrackingLocation = false;
  DateTime? lastBackPressed;
  bool isDataLoaded = false;

  // CONSTANTS
  static const String BASE_URL = "https://ugotaxi.icacorp.org";
  static const double LOCATION_UPDATE_THRESHOLD = 50.0;

  @override
  void initState() {
    super.initState();
    model = createModel(context, () => HomeModel());

    // Initialize Data after build
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
      _initSocket();
    });
  }

  @override
  void dispose() {
    model.dispose();
    _stopLocationTracking();
    if (socket.connected) socket.dispose();
    super.dispose();
  }

  // --- INITIALIZATION LOGIC ---

  Future<void> _loadInitialData() async {
    // 1. Fetch Driver Details & QR
    await Future.wait([
      (() async {
        model.userDetails = await DriverIdfetchCall.call(
          token: FFAppState().accessToken,
          id: FFAppState().driverid,
        );
      })(),
      (() async {
        model.postQR = await PostQRcodeCall.call(
          token: FFAppState().accessToken,
          driverId: FFAppState().driverid,
        );
      })(),
    ]);

    // 2. Set KYC Status
    String kycStatus =
        getJsonField(model.userDetails?.jsonBody, r'''$.data.kyc_status''')
            .toString();
    FFAppState().kycStatus = kycStatus.trim();

    // 3. Set QR Image
    FFAppState().qrImage =
        getJsonField(model.postQR?.jsonBody, r'''$.data.qrcode_image''')
            .toString();

    // 4. Check if Online
    bool isOnline =
        DriverIdfetchCall.isonline(model.userDetails?.jsonBody) ?? false;

    if (isOnline) {
      model.switchValue = true;
      _startLocationTracking();
    } else {
      model.switchValue = false;
    }

    // 5. Get Initial Location
    final loc = await getCurrentUserLocation(
        defaultLocation: const LatLng(0.0, 0.0), cached: true);

    safeSetState(() {
      currentUserLocationValue = loc;
      isDataLoaded = true;
    });
  }

  // --- SOCKET LOGIC ---

  void _initSocket() {
    print("Initializing Socket...");

    socket = IO.io(
        BASE_URL,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .setAuth({'token': FFAppState().accessToken}) // Send Token
            .build());

    socket.onConnect((_) {
      print("Socket Connected");
      socket.emit(
          'watch-entity', {'type': 'driver', 'id': FFAppState().driverid});
    });

    socket.on('driver-rides', (data) {
      print("Received Rides: $data");
      _passDataToOverlay(data);
    });

    socket.on('ride-updated', (data) {
      print("Ride Update: $data");
      _passDataToOverlay(data);
    });

    socket.connect();
  }

  void _passDataToOverlay(dynamic data) {
    if (overlayKey.currentState == null) return;

    if (data is List) {
      for (var ride in data) {
        overlayKey.currentState!.handleNewRide(ride);
      }
    } else if (data is Map<String, dynamic>) {
      overlayKey.currentState!.handleNewRide(data);
    }
  }

  // --- LOCATION LOGIC ---

  Future<void> _startLocationTracking() async {
    if (isTrackingLocation) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enable Location Services"),
          backgroundColor: Colors.red));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    isTrackingLocation = true;

    // Initial Update
    Position initialPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lastSavedPosition = initialPos;
    await _updateLocationToServer(initialPos);

    // Stream Updates
    locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      _handleLocationUpdate(position);
    });

    print("Location Tracking Started");
  }

  void _stopLocationTracking() {
    locationSubscription?.cancel();
    locationSubscription = null;
    isTrackingLocation = false;
    lastSavedPosition = null;
    print("Location Tracking Stopped");
  }

  Future<void> _handleLocationUpdate(Position newPos) async {
    if (lastSavedPosition == null) {
      lastSavedPosition = newPos;
      await _updateLocationToServer(newPos);
      return;
    }

    double distance = Geolocator.distanceBetween(lastSavedPosition!.latitude,
        lastSavedPosition!.longitude, newPos.latitude, newPos.longitude);

    // Only update server if moved > 50m
    if (distance > LOCATION_UPDATE_THRESHOLD) {
      print("Moved ${distance.toStringAsFixed(0)}m - Updating Server");
      await _updateLocationToServer(newPos);
      lastSavedPosition = newPos;
    }

    // Always update local UI map
    if (mounted) {
      setState(() {
        currentUserLocationValue = LatLng(newPos.latitude, newPos.longitude);
      });
    }
  }

  Future<void> _updateLocationToServer(Position pos) async {
    try {
      await UpdateDriverCall.call(
        token: FFAppState().accessToken,
        id: FFAppState().driverid,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } catch (e) {
      print("Location Upload Failed: $e");
    }
  }

  // --- ONLINE / OFFLINE TOGGLE ---

  Future<void> goOnlineAsync() async {
    // KYC Check
    if (FFAppState().kycStatus.trim().toLowerCase() != 'approved') {
      safeSetState(() => model.switchValue = false);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("KYC Not Approved"),
          content: Text("Status: ${FFAppState().kycStatus}. Contact admin."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      final res = await UpdateDriverCall.call(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        isonline: true,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (res.succeeded) {
        _startLocationTracking();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("You are ONLINE"), backgroundColor: Colors.green));
      } else {
        safeSetState(() => model.switchValue = false);
      }
    } catch (e) {
      safeSetState(() => model.switchValue = false);
    }
  }

  Future<void> goOfflineAsync() async {
    _stopLocationTracking();
    final res = await UpdateDriverCall.call(
      id: FFAppState().driverid,
      token: FFAppState().accessToken,
      isonline: false,
    );

    if (!res.succeeded) {
      // If failed, revert switch visually (optional)
      safeSetState(() => model.switchValue = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to go offline"), backgroundColor: Colors.red));
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          body: Column(
            children: [
              // 1. TOP BAR (Orange)
              Container(
                height: 100,
                color: const Color(0xFFFF6600),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu Button
                    FlutterFlowIconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () =>
                          context.pushNamed(AccountManagementWidget.routeName),
                      buttonSize: 40,
                    ),

                    // QR Code Button
                    InkWell(
                      onTap: () =>
                          context.pushNamed(ScanToBookWidget.routeName),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child:
                            const Icon(Icons.qr_code, color: Color(0xFFFF6600)),
                      ),
                    ),

                    // ONLINE/OFFLINE Switch
                    Row(
                      children: [
                        Text(
                          (model.switchValue ?? false) ? "ON DUTY" : "OFF DUTY",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: model.switchValue ?? false,
                          onChanged: (newValue) async {
                            safeSetState(() => model.switchValue = newValue);
                            if (newValue) {
                              await goOnlineAsync();
                            } else {
                              await goOfflineAsync();
                            }
                          },
                          activeColor: const Color(0xFF0D3072),
                          activeTrackColor: const Color(0xFF1C6EAB),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. MAP AREA with OVERLAY
              Expanded(
                child: Stack(
                  children: [
                    FlutterFlowGoogleMap(
                      controller: model.googleMapsController,
                      onCameraIdle: (latLng) => model.googleMapsCenter = latLng,
                      initialLocation:
                          model.googleMapsCenter ?? currentUserLocationValue!,
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

                    // THE RIDE REQUEST OVERLAY
                    RideRequestOverlay(key: overlayKey),

                    // "My Location" Button
                    Align(
                      alignment: const AlignmentDirectional(0.9, 0.6),
                      child: PointerInterceptor(
                        intercepting: isWeb,
                        child: FlutterFlowIconButton(
                          borderRadius: 25,
                          buttonSize: 50,
                          fillColor: Colors.white,
                          icon: const Icon(Icons.my_location,
                              color: Colors.black),
                          onPressed: () async {
                            if (currentUserLocationValue != null) {
                              await model.googleMapsController.future.then(
                                (c) => c.animateCamera(CameraUpdate.newLatLng(
                                    currentUserLocationValue!.toGoogleMaps())),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. BOTTOM STATS BAR
              Container(
                height: 70,
                color: const Color(0xF357636C),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LinearPercentIndicator(
                      percent: 0.5,
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      lineHeight: 30,
                      progressColor: const Color(0xFF329556),
                      backgroundColor: FlutterFlowTheme.of(context).accent4,
                      center: const Text("Today's Goal",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      barRadius: const Radius.circular(50),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/Group_2994.png',
                          width: 50, height: 50, fit: BoxFit.cover),
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
}
