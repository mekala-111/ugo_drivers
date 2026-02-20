import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_google_map.dart';
import 'package:ugo_driver/flutter_flow/lat_lng.dart' as latlng;
import 'package:ugo_driver/home/widgets/map_container.dart';

/// Google Maps widget + overlay container.
/// Handles map controller, markers, and captains panel.
class RideMapContainer extends StatelessWidget {
  const RideMapContainer({
    super.key,
    required this.mapKey,
    required this.controller,
    required this.initialLocation,
    required this.onCameraIdle,
    required this.mapCenter,
    required this.availableDriversCount,
    required this.showCaptainsPanel,
  });

  final GlobalKey<FlutterFlowGoogleMapState> mapKey;
  final Completer<GoogleMapController> controller;
  final latlng.LatLng initialLocation;
  final void Function(latlng.LatLng) onCameraIdle;
  final latlng.LatLng? mapCenter;
  final int availableDriversCount;
  final bool showCaptainsPanel;

  @override
  Widget build(BuildContext context) {
    return MapContainer(
      mapKey: mapKey,
      controller: controller,
      initialLocation: initialLocation,
      onCameraIdle: onCameraIdle,
      mapCenter: mapCenter,
      availableDriversCount: availableDriversCount,
      showCaptainsPanel: showCaptainsPanel,
    );
  }
}
