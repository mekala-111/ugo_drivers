import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';

/// Shown when location is unavailable (loading or permission denied).
class LocationUnavailableView extends StatelessWidget {
  const LocationUnavailableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                FFLocalizations.of(context)
                    .getText('drv_location_unavailable')
                    .replaceAll('\\n', '\n'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: Text(
                  FFLocalizations.of(context).getText('drv_open_settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
