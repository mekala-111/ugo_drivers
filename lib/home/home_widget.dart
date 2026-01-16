

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
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
import './ride_request_overlay.dart';

const String BASE_URL = "http://192.168.1.14:5001";
String DRIVER_TOKEN = FFAppState().accessToken;
int DRIVER_ID = FFAppState().driverid;

// 🎯 DISTANCE THRESHOLD 
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
  final GlobalKey<RideRequestOverlayState> _overlayKey = GlobalKey<RideRequestOverlayState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  late IO.Socket socket;
  LatLng? acceptedPickupLocation;
bool showNavigateButton = false;

  
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastSavedPosition;
  bool _isTrackingLocation = false;
  DateTime? _lastBackPressed;
  bool _isDataLoaded = false; // ✅ Track if data is loaded

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
      
      print('✅ accessToken: ${FFAppState().accessToken}, driverId: ${FFAppState().driverid}');
      
      // ✅ SET KYC STATUS WITH PROPER ERROR HANDLING
      String kycStatus = getJsonField(
        (_model.userDetails?.jsonBody ?? ''),
        r'''$.data.kyc_status''',
      ).toString();
      
      // Remove any extra whitespace and convert to lowercase for comparison
      FFAppState().kycStatus = kycStatus.trim();
      
      print('🔍 KYC Status Retrieved: "${FFAppState().kycStatus}"');
      print('🔍 KYC Status Length: ${FFAppState().kycStatus.length}');
      
      FFAppState().qrImage = getJsonField(
        (_model.postQR?.jsonBody ?? ''),
        r'''$.data.qr_code_image''',
      ).toString();
      
      // Check if driver is already online and start tracking
      bool? isOnline = DriverIdfetchCall.isonline(_model.userDetails?.jsonBody);
      if (isOnline == true) {
        _model.switchValue = true;
        safeSetState(() {});
        _startLocationTracking();
      } else {
        _model.switchValue = false;
        safeSetState(() {});
      }
      
      // ✅ Mark data as loaded
      setState(() {
        _isDataLoaded = true;
      });
      
      _initSocket();
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }
//   void _onRideAccepted(RideRequest ride) async {
//   print("🚕 Ride accepted in HomeWidget");

//   final position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );

//   setState(() {
//     acceptedPickupLocation = LatLng(
//       ride.pickupLat,
//       ride.pickupLng,
//     );
//     showNavigateButton = true;
//   });
// }


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
            content: Text('Location permission permanently denied. Please enable in settings.'),
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
      print("✅ Initial position: ${initialPosition.latitude}, ${initialPosition.longitude}");
      
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

    print("📏 Distance moved: ${distanceInMeters.toStringAsFixed(2)}m (Threshold: ${LOCATION_UPDATE_THRESHOLD}m)");

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
      // if (status == 'accepted') {
      //   _overlayKey.currentState!.removeRideById(rideId);
      //   
      // }
      //  else {
      //   _overlayKey.currentState!.handleNewRide(rideData);
      // }
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
    context.watch<FFAppState>();
    
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
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
          body: 
          // Container(
            // decoration: BoxDecoration(),
            // child: 
            // SingleChildScrollView(
              // primary: false,
              // child: 
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6600),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            buttonSize: 40,
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed(AccountManagementWidget.routeName);
                            },
                          ),
                          Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(ScanToBookWidget.routeName);
                          },
                          child: Icon(
                            Icons.qr_code,
                            color: Color(0xFFFF6600),
                            size: 24,
                          ),
                        ),
                      ),
                      
                       Row(
                         children: [
                          Text(
                              (_model.switchValue ?? false)
                                ? FFLocalizations.of(context).getVariableText(
                                    enText: 'ON',
                                    teText: '',
                                    hiText: '',
                                  )
                                : FFLocalizations.of(context).getVariableText(
                                    enText: 'OFF',
                                    teText: '',
                                    hiText: '',
                                  ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                           Switch(
                            value: _model.switchValue ?? false,
                            onChanged: _isDataLoaded
                                ? (newValue) async {
                                    if (newValue!) {
                                      // ✅ GOING ONLINE - DEBUG KYC STATUS
                                      print("🔍 Attempting to go ONLINE");
                                      print(
                                          "🔍 Current KYC Status: '${FFAppState().kycStatus}'");
                                      print(
                                          "🔍 Status length: ${FFAppState().kycStatus.length}");
                                      print(
                                          "🔍 Status comparison: ${FFAppState().kycStatus.trim().toLowerCase() == 'approved'}");
                           
                                      // ✅ IMPROVED KYC CHECK - Trim and lowercase comparison
                                      if (FFAppState()
                                              .kycStatus
                                              .trim()
                                              .toLowerCase() ==
                                          'approved') {
                                        Position? currentPosition;
                                        try {
                                          print(
                                              "📡 Getting current location for going online...");
                                          currentPosition =
                                              await Geolocator.getCurrentPosition(
                                            desiredAccuracy: LocationAccuracy.high,
                                          );
                                          print(
                                              "✅ Got location: ${currentPosition.latitude}, ${currentPosition.longitude}");
                                        } catch (e) {
                                          print("❌ Error getting location: $e");
                                        }
                           
                                        print(
                                            "🔄 Calling UpdateDriver API to go ONLINE...");
                                        _model.updatedriver =
                                            await UpdateDriverCall.call(
                                          id: FFAppState().driverid,
                                          token: FFAppState().accessToken,
                                          isonline: true,
                                          latitude: currentPosition?.latitude,
                                          longitude: currentPosition?.longitude,
                                        );
                           
                                        if ((_model.updatedriver?.succeeded ??
                                            false)) {
                                          safeSetState(() {
                                            _model.switchValue = true;
                                          });
                           
                                          print("✅ Successfully went ONLINE");
                                          _startLocationTracking();
                           
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                UpdateDriverCall.message(_model
                                                        .updatedriver?.jsonBody) ??
                                                    'Driver is now online',
                                                style: TextStyle(
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primaryText,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .success,
                                            ),
                                          );
                                        } else {
                                          safeSetState(() {
                                            _model.switchValue = false;
                                          });
                           
                                          print("❌ Failed to go ONLINE");
                           
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                UpdateDriverCall.message(_model
                                                        .updatedriver?.jsonBody) ??
                                                    'Failed to go online',
                                                style: TextStyle(
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primaryText,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                          );
                                        }
                                      } else {
                                        // ❌ KYC NOT APPROVED
                                        print(
                                            "❌ KYC Status is NOT approved: '${FFAppState().kycStatus}'");
                           
                                        safeSetState(() {
                                          _model.switchValue = false;
                                        });
                           
                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              title:
                                                  Text('KYC Status Not Approved'),
                                              content: Text(
                                                  'Your KYC status is "${FFAppState().kycStatus}". '
                                                  'Please complete your KYC verification to go online.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                      alertDialogContext),
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      safeSetState(() {});
                                    } else {
                                      // ✅ GOING OFFLINE
                                      print("🛑 Driver going offline...");
                                      _stopLocationTracking();
                           
                                      print(
                                          "🔄 Calling UpdateDriver API to go OFFLINE...");
                                      _model.apiResultrv8 =
                                          await UpdateDriverCall.call(
                                        id: FFAppState().driverid,
                                        token: FFAppState().accessToken,
                                        isonline: false,
                                        latitude: null,
                                        longitude: null,
                                      );
                           
                                      if (_model.apiResultrv8?.succeeded ?? false) {
                                        safeSetState(() {
                                          _model.switchValue = false;
                                        });
                           
                                        print("✅ Successfully went OFFLINE");
                           
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              UpdateDriverCall.message(_model
                                                      .apiResultrv8?.jsonBody) ??
                                                  'Driver is now offline',
                                              style: TextStyle(
                                                color: FlutterFlowTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                            duration: Duration(milliseconds: 2000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      } else {
                                        safeSetState(() {
                                          _model.switchValue = true;
                                        });
                           
                                        print(
                                            "❌ Failed to go OFFLINE, restarting tracking...");
                                        _startLocationTracking();
                           
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to go offline. Please try again.',
                                              style: TextStyle(
                                                color: FlutterFlowTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                            duration: Duration(milliseconds: 2000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context).error,
                                          ),
                                        );
                                      }
                           
                                      safeSetState(() {});
                                    }
                                  }
                                : null, // ✅ Disable switch until data loads
                            activeColor: Color(0xFF0D3072),
                            activeTrackColor: Color(0xFF1C6EAB),
                            inactiveTrackColor: Color(0xFF13181B),
                            inactiveThumbColor:
                                FlutterFlowTheme.of(context).secondaryText,
                                                 ),
                         ],
                       ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              
                            
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(TeampageWidget.routeName);
                                  },
                                  child: Icon(
                                    Icons.group,
                                    color: Color(0xFFFF6600),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText('nrjzvb2s'),
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                    ),
                              ),
                              Text(
                                FFLocalizations.of(context).getText('od11ng7s'),
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8)),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      // height: 600,
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F2FF),
                      ),
                      child: Stack(
                        children: [
                          FlutterFlowGoogleMap(
                            controller: _model.googleMapsController,
                            onCameraIdle: (latLng) => _model.googleMapsCenter = latLng,
                            initialLocation: _model.googleMapsCenter ??= currentUserLocationValue!,
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
                            mapTakesGesturePreference: false,
                          ),
                          RideRequestOverlay(key: _overlayKey),
                          Align(
                            alignment: AlignmentDirectional(0.9, 0.9),
                            child: PointerInterceptor(
                              intercepting: isWeb,
                              child: FlutterFlowIconButton(
                                borderRadius: 25,
                                buttonSize: 50,
                                fillColor: Colors.white,
                                icon: Icon(
                                  Icons.my_location,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 24,
                                ),
                                onPressed: () async {
                                  if (currentUserLocationValue != null) {
                                    await _model.googleMapsController.future.then(
                                      (c) => c.animateCamera(
                                        CameraUpdate.newLatLng(currentUserLocationValue!.toGoogleMaps()),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Color(0xF357636C),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LinearPercentIndicator(
                          percent: 0.5,
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          lineHeight: 30,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: Color(0xFF329556),
                          backgroundColor: FlutterFlowTheme.of(context).accent4,
                          center: Text(
                            FFLocalizations.of(context).getText('lvps3bvl'),
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  // fontWeight: Flutt
                                  fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                                ),
                          ),
                          barRadius: Radius.circular(50),
                          padding: EdgeInsets.zero,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/Group_2994.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ].divide(SizedBox(height: 0)),
              ),
            // ),
          // ),
        ),
      ),
    );
  }
}