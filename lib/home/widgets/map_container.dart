import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_google_map.dart';
import 'package:ugo_driver/flutter_flow/lat_lng.dart' as latlng;
import 'ride_status_panel.dart';

/// Map display with optional "captains nearby" overlay.
class MapContainer extends StatelessWidget {
  const MapContainer({
    super.key,
    required this.mapKey,
    required this.controller,
    required this.initialLocation,
    required this.onCameraIdle,
    required this.mapCenter,
    required this.availableDriversCount,
    required this.showCaptainsPanel,
    this.onCenterCurrentLocation,
    this.markers,
  });

  final GlobalKey<FlutterFlowGoogleMapState> mapKey;
  final Completer<GoogleMapController> controller;
  final latlng.LatLng initialLocation;
  final void Function(latlng.LatLng) onCameraIdle;
  final latlng.LatLng? mapCenter;
  final int availableDriversCount;
  final bool showCaptainsPanel;
  final Future<void> Function()? onCenterCurrentLocation;
  final List<FlutterFlowMarker>? markers;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterFlowGoogleMap(
          key: mapKey,
          controller: controller,
          onCameraIdle: onCameraIdle,
          initialLocation: mapCenter ?? initialLocation,
          markerColor: GoogleMarkerColor.orange,
          markers: markers ?? [],
          mapType: MapType.normal,
          style: GoogleMapStyle.standard, // Back to regular style
          initialZoom: 16,
          allowInteraction: true,
          allowZoom: true,
          showZoomControls: false,
          showLocation: false, // Turn off Google's blue dot
          showCompass: true,
          showMapToolbar: true,
          showTraffic: false,
          centerMapOnMarkerTap: true,
        ),
        if (showCaptainsPanel)
          RideStatusPanel(availableDriversCount: availableDriversCount),
        if (onCenterCurrentLocation != null)
          Positioned(
            top: showCaptainsPanel ? 88.0 : 16.0,
            right: 16.0,
            child: Material(
              color: Colors.white,
              elevation: 6.0,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Current location',
                onPressed: onCenterCurrentLocation,
                icon: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
