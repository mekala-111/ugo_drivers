
import 'dart:async';
import 'package:flutter/material.';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_theme.dart';

class DropZoneWidget extends StatefulWidget {
  final String customerName;
  final String pickupAddress;
  final String dropAddress;

  const DropZoneWidget({
    Key? key,
    required this.customerName,
    required this.pickupAddress,
    required this.dropAddress,
  }) : super(key: key);

  @override
  State<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _currentPosition;
  late BitmapDescriptor dropPinIcon;
  late BitmapDescriptor currentLocIcon;
  StreamSubscription<Position>? _positionStreamSubscription;
  double _currentSpeed = 0.0; // In km/h

  // Dummy data for drop location
  static const LatLng _dropLocation =
      LatLng(17.4475, 78.3917); // Example: Jubilee Hills, Hyderabad

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _getCurrentLocation();
    _listenToLocationChanges();
    _showPickupSuccessBanner();
  }

  Future<void> _loadCustomMarkers() async {
    dropPinIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/drop_pin.png', // You'll need to add a custom red pin image here
    );
    currentLocIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/current_location_arrow.png', // Reusing blue arrow
    );
    setState(() {}); // Rebuild to apply markers
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _currentSpeed = position.speed * 3.6; // m/s to km/h
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
          _currentSpeed = position.speed * 3.6; // m/s to km/h
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

  void _showPickupSuccessBanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.star, color: FlutterFlowTheme.of(context).tertiary),
              const SizedBox(width: 8),
              Text(
                'Perfect Pick-up! ✨ You started the ride at the right location',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          backgroundColor: FlutterFlowTheme.of(context).success, // Green banner
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating, // Makes it a banner at the top/bottom
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150, // Position at the top
            left: 10, // Add some left margin
            right: 10, // Add some right margin
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners for the banner
          ),
          elevation: 4,
        ),
      );
    });
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
          'Go to drop',
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
              target: _dropLocation,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('drop_location'),
                position: _dropLocation,
                icon: dropPinIcon, // Red pin
                infoWindow: const InfoWindow(title: 'Drop location'),
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
          // "Drop location" label on map
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2, // Adjust as needed
            left: MediaQuery.of(context).size.width * 0.3, // Adjust as needed
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error, // Red color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Drop location',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
              ),
            ),
          ),

          // Speed indicator
          if (_currentSpeed > 0)
            Positioned(
              top: 100, // Adjust position as needed
              right: 20, // Adjust position as needed
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).tertiary, // Yellow color
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\${_currentSpeed.toStringAsFixed(0)}',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Outfit',
                            color: Colors.black,
                            fontSize: 18,
                          ),
                    ),
                    Text(
                      'km/h',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.black,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Yellow "Go to drop" floating action button
          Align(
            alignment: const AlignmentDirectional(0, 0.7),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 200), // Adjusted to be above the bottom sheet
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle "Go to drop" action (e.g., open external map, start in-app navigation)
                  print('Go to drop button pressed');
                },
                icon: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                label: Text(
                  'Go to drop',
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
              height: MediaQuery.of(context).size.height * 0.25, // Adjust height as needed
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
                    Text(
                      widget.customerName,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Outfit',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.dropAddress,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Payment Collection Screen
                          print('Complete Ride button pressed');
                          // You would navigate to the PaymentCollectionScreen here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).error, // Red button
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Complete Ride',
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
