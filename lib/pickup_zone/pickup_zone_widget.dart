
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:ugo_driver/otp_verification/otp_verification_widget.dart'; // Import OTP screen
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For chat icon

class PickupZoneWidget extends StatefulWidget {
  const PickupZoneWidget({Key? key}) : super(key: key);

  @override
  State<PickupZoneWidget> createState() => _PickupZoneWidgetState();
}

class _PickupZoneWidgetState extends State<PickupZoneWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _currentPosition;
  late BitmapDescriptor pickupPinIcon;
  late BitmapDescriptor currentLocIcon;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Dummy data for pickup location and customer
  static const LatLng _pickupLocation =
      LatLng(17.4399, 78.4347); // Example: KBR Park, Hyderabad
  final String _customerName = "Siddhu";
  final String _pickupAddress =
      "200, L.V Prasad Marg, Venkat Nagar, Banjara Hills, Hyderabad, Telangana 500004, India";

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _getCurrentLocation();
    _listenToLocationChanges();
  }

  Future<void> _loadCustomMarkers() async {
    pickupPinIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/pickup_pin.png', // You'll need to add a custom green pin image here
    );
    currentLocIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/current_location_arrow.png', // You'll need to add a custom blue arrow image here
    );
    setState(() {}); // Rebuild to apply markers
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _animateCameraToCurrentLocation();
  }

  void _listenToLocationChanges() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _animateCameraToCurrentLocation();
      }
    });
  }

  Future<void> _animateCameraToCurrentLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24,
          ),
          onPressed: () {
            // Handle hamburger menu press
          },
        ),
        title: Text(
          'Go to Pickup Zone',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 22,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
            child: IconButton(
              icon: Icon(
                Icons.call,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              onPressed: () {
                // Handle call button press
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _pickupLocation,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('pickup_location'),
                position: _pickupLocation,
                icon: pickupPinIcon, // Green pin
                infoWindow: const InfoWindow(title: 'Pick up here'),
              ),
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: _currentPosition!,
                  icon: currentLocIcon, // Blue navigation arrow
                  infoWindow: const InfoWindow(title: 'Your Location'),
                ),
            },
          ),
          // "Pick up here" label on map
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2, // Adjust as needed
            left: MediaQuery.of(context).size.width * 0.3, // Adjust as needed
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pick up here',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          // Yellow "Go to pickup" floating action button
          Align(
            alignment: const AlignmentDirectional(0, 0.7),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 200), // Adjusted to be above the bottom sheet
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle "Go to pickup" action (e.g., open external map, start in-app navigation)
                  print('Go to pickup button pressed');
                },
                icon: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                label: Text(
                  'Go to pickup',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).tertiary, // Yellow color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 4,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35, // Adjust height as needed
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x33000000),
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: FlutterFlowTheme.of(context).success, // Green checkmark
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Customer Verified Location',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _customerName,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Outfit',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickupAddress,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                    const Spacer(),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle message customer
                                print('Message customer pressed');
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.solidCommentDots,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20,
                              ),
                              label: Text(
                                'Message customer',
                                style: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground, // White button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate, // Light grey border
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to OTP Verification Screen
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtpVerificationWidget(),
                            ),
                          );
                          if (result == true) {
                            // OTP successfully verified, proceed to "Go to Drop Screen"
                            print('OTP Verified! Navigating to Go to Drop Screen');
                            // You would navigate to GoToDropScreen here
                            // For now, let's just show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('OTP Verified! Proceeding to drop.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary, // Blue button
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Arrived',
                          style: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 18,
                              ),
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
