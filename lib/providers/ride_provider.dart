import 'package:flutter/material.dart';
import '../home/ride_request_model.dart';
import '../models/ride_status.dart';

/// Central ride state holder. Widgets can listen to this provider
/// instead of managing their own status strings.
class RideState extends ChangeNotifier {
  RideRequest? _currentRide;
  RideStatus _status = RideStatus.unknown;

  RideRequest? get currentRide => _currentRide;
  RideStatus get status => _status;

  bool get hasActiveRide => _currentRide != null &&
      _status != RideStatus.completed &&
      _status != RideStatus.cancelled &&
      _status != RideStatus.rejected;

  void updateRide(RideRequest ride) {
    _currentRide = ride;
    _status = ride.status;
    notifyListeners();
  }

  void clearRide() {
    _currentRide = null;
    _status = RideStatus.unknown;
    notifyListeners();
  }

  void updateStatus(RideStatus status) {
    _status = status;
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: status);
    }
    notifyListeners();
  }
}
