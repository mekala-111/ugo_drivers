import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/home/ride_request_overlay.dart';

/// Ride request history / pending rides overlay.
/// Integrates RideRequestOverlay for bottom-sheet style ride flow.
class BottomRidePanel extends StatelessWidget {
  const BottomRidePanel({
    super.key,
    required this.overlayKey,
    required this.onRideComplete,
    required this.driverLocation,
  });

  final GlobalKey<RideRequestOverlayState> overlayKey;
  final VoidCallback onRideComplete;
  final LatLng? driverLocation;

  @override
  Widget build(BuildContext context) {
    return RideRequestOverlay(
      key: overlayKey,
      onRideComplete: onRideComplete,
      driverLocation: driverLocation,
    );
  }
}
