import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:ugo_driver/config.dart';
import 'package:ugo_driver/home/incentive_model.dart';
import 'package:ugo_driver/repositories/driver_repository.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart'
    show DriverIdfetchCall, GetAllDriversCall;

import '../flutter_flow/flutter_flow_util.dart';

const double _locationUpdateThreshold = 50.0;
const double _notifyDistanceThreshold = 100.0;
const Duration _notifyTimeThreshold = Duration(seconds: 2);

/// Holds all Home screen logic: fetch, socket, location, earnings.
/// HomeWidget listens and delegates UI via callbacks.
class HomeController extends ChangeNotifier {
  HomeController({
    required this.onShowKycDialog,
    required this.onShowLocationDisclosure,
    required this.onShowPermissionDialog,
    required this.onShowSnackBar,
    required this.onSocketRideData,
    required this.onFetchRideById,
  });

  final Future<void> Function() onShowKycDialog;
  final Future<bool> Function() onShowLocationDisclosure;
  final Future<void> Function() onShowPermissionDialog;
  final void Function(String messageKey, {bool isError}) onShowSnackBar;
  final void Function(dynamic data) onSocketRideData;
  final void Function(int rideId) onFetchRideById;

  late io.Socket _socket;
  StreamSubscription<Position>? _locationSub;
  Position? _lastSavedPosition;
  DateTime? _lastNotifyTime;
  Position? _lastNotifyPosition;
  bool _isTrackingLocation = false;
  Timer? _availableDriversTimer;
  bool _socketInitialized = false;
  bool _disposed = false;

  // ── State ───────────────────────────────────────────────────────────────────

  LatLng? currentUserLocation;
  bool isDataLoaded = false;
  String driverName = '';
  String profileImageUrl = '';
  bool isOnline = false;
  String currentRideStatus = 'IDLE';

  int currentRides = 0;
  double totalIncentiveEarned = 0.0;
  List<IncentiveTier> incentiveTiers = [];
  bool isLoadingIncentives = true;

  double todayTotal = 0.0;
  int todayRideCount = 0;
  double todayWallet = 0.0;
  double lastRideAmount = 0.0;
  bool isLoadingEarnings = true;

  int availableDriversCount = 0;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    driverName = '${FFAppState().firstName} ${FFAppState().lastName}';
    _fetchInitialRideStatus();
    await Future.wait([
      _fetchDriverProfile(),
      _fetchIncentiveData(),
      _fetchTodayEarnings(),
    ]);
    isDataLoaded = true;
    _notify();
    _initSocket();
  }

  void handlePendingRideFromNotification(int rideId) {
    if (rideId <= 0) return;
    onFetchRideById(rideId);
  }

  Future<void> _fetchDriverProfile() async {
    final userDetails = await DriverRepository.instance.fetchDriverProfile(
      token: FFAppState().accessToken,
      driverId: FFAppState().driverid,
    );
    final postQR = await DriverRepository.instance.fetchPostQR(
      token: FFAppState().accessToken,
      driverId: FFAppState().driverid,
    );

    if (_disposed) return;

    if (kDebugMode) {
      debugPrint('🔍 === Driver Profile Response ===');
      debugPrint('Response Succeeded: ${userDetails.succeeded}');
      debugPrint('Response JSON: ${userDetails.jsonBody}');
    }

    if (userDetails.jsonBody != null) {
      final fetchedName = getJsonField(
        userDetails.jsonBody,
        r'''$.data.first_name''',
      ).toString();
      if (fetchedName != 'null' && fetchedName.isNotEmpty) {
        driverName = fetchedName;
      }

      final img = DriverIdfetchCall.profileImage(userDetails.jsonBody);

      if (kDebugMode) {
        debugPrint('🖼️ Raw img value from API: $img');
        debugPrint('🖼️ img is null: ${img == null}');
        debugPrint('🖼️ img is empty: ${img?.isEmpty ?? true}');
      }

      if (img != null && img.isNotEmpty) {
        profileImageUrl =
            img.startsWith('http') ? img : '${Config.baseUrl}/$img';
        if (kDebugMode) {
          debugPrint('✅ Final profileImageUrl: $profileImageUrl');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ No profile image found in response');
        }
      }
    }

    final preferredCityId = getJsonField(
      (userDetails.jsonBody ?? ''),
      r'''$.data.preferred_city_id''',
    );
    if (preferredCityId != null) {
      final parsed = int.tryParse(preferredCityId.toString());
      if (parsed != null && parsed > 0) {
        FFAppState().preferredCityId = parsed;
      }
    }

    FFAppState().kycStatus = getJsonField(
      (userDetails.jsonBody ?? ''),
      r'''$.data.kyc_status''',
    ).toString().trim();
    FFAppState().qrImage = getJsonField(
      (postQR.jsonBody ?? ''),
      r'''$.data.qr_code_image''',
    ).toString();

    final isOnlineFromApi = DriverIdfetchCall.isonline(userDetails.jsonBody);
    isOnline = isOnlineFromApi == true;

    if (isOnline) {
      _startLocationTracking();
      _fetchAvailableDrivers();
      _availableDriversTimer?.cancel();
      _availableDriversTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _fetchAvailableDrivers(),
      );
    }
    _notify();
  }

  void _fetchInitialRideStatus() {
    if (FFAppState().activeRideId != 0) {
      currentRideStatus = 'FETCHING';
      _notify();
    }
  }

  Future<void> _fetchAvailableDrivers() async {
    if (!isOnline || _disposed) return;
    try {
      final res = await DriverRepository.instance.getAllDrivers(
        token: FFAppState().accessToken,
      );
      if (_disposed) return;
      if (res.succeeded && res.jsonBody != null) {
        availableDriversCount =
            GetAllDriversCall.availableDrivers(res.jsonBody).length;
        _notify();
      }
    } catch (_) {}
  }

  // ── Online/Offline ─────────────────────────────────────────────────────────

  Future<void> goOnline() async {
    if (FFAppState().kycStatus.trim().toLowerCase() != 'approved') {
      isOnline = false;
      _notify();
      await onShowKycDialog();
      return;
    }

    if (FFAppState().preferredCityId <= 0) {
      isOnline = false;
      _notify();
      onShowSnackBar('drv_select_preferred_city', isError: true);
      return;
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Geolocator error: $e');
    }

    await DriverRepository.instance.updateDriver(
      id: FFAppState().driverid,
      token: FFAppState().accessToken,
      isonline: null,
      latitude: position?.latitude,
      longitude: position?.longitude,
      fcmToken: FFAppState().fcmToken.isNotEmpty ? FFAppState().fcmToken : null,
    );

    final res = await DriverRepository.instance.setOnlineStatus(
      token: FFAppState().accessToken,
      isOnline: true,
    );

    if (_disposed) return;
    if (res.succeeded) {
      isOnline = true;
      _startLocationTracking();
      _fetchAvailableDrivers();
      _availableDriversTimer?.cancel();
      _availableDriversTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _fetchAvailableDrivers(),
      );
      onShowSnackBar('drv_you_online', isError: false);
    } else {
      isOnline = false;
      final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
      if (msg != null && msg.isNotEmpty) {
        onShowSnackBar(msg, isError: true);
      } else {
        onShowSnackBar('drv_go_online_failed', isError: true);
      }
    }
    _notify();
  }

  Future<void> goOffline() async {
    _stopLocationTracking();
    final res = await DriverRepository.instance.setOnlineStatus(
      token: FFAppState().accessToken,
      isOnline: false,
    );

    if (!res.succeeded) {
      isOnline = true;
      final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
      if (msg != null && msg.isNotEmpty) {
        onShowSnackBar(msg, isError: true);
      } else {
        onShowSnackBar('drv_failed_offline', isError: true);
      }
    } else {
      await DriverRepository.instance.updateDriver(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        isonline: false,
        latitude: null,
        longitude: null,
      );
    }
    if (_disposed) return;
    _notify();
  }

  Future<void> toggleOnlineStatus() async {
    final intendedValue = !isOnline;

    if (!intendedValue) {
      final status = currentRideStatus.toUpperCase();
      if (['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP'].contains(status)) {
        onShowSnackBar('drv_cannot_offline', isError: true);
        return;
      }
    }

    isOnline = intendedValue;
    _notify();

    if (intendedValue) {
      await goOnline();
    } else {
      await goOffline();
    }
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _startLocationTracking() async {
    if (_isTrackingLocation) return;
    _isTrackingLocation = true;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isTrackingLocation = false;
      return;
    }

    final agreed = await onShowLocationDisclosure();
    if (!agreed) {
      _isTrackingLocation = false;
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isTrackingLocation = false;
        await onShowPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isTrackingLocation = false;
      await onShowPermissionDialog();
      return;
    }

    if (Platform.isAndroid && permission == LocationPermission.whileInUse) {
      final upgraded = await Geolocator.requestPermission();
      if (upgraded == LocationPermission.denied ||
          upgraded == LocationPermission.deniedForever) {
        _isTrackingLocation = false;
        await onShowPermissionDialog();
        return;
      }
    }

    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _lastSavedPosition = initialPosition;
      await _updateLocationToServer(initialPosition);
      if (_disposed) return;
      currentUserLocation =
          LatLng(initialPosition.latitude, initialPosition.longitude);
      _notify();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting position: $e');
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_handleLocationUpdate);
  }

  Future<void> _handleLocationUpdate(Position newPosition) async {
    final hasActiveRide = ['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP']
        .contains(currentRideStatus.toUpperCase());

    if (_lastSavedPosition == null) {
      _lastSavedPosition = newPosition;
      await _updateLocationToServer(newPosition);
      if (_disposed) return;
      currentUserLocation = LatLng(newPosition.latitude, newPosition.longitude);
      _lastNotifyTime = DateTime.now();
      _lastNotifyPosition = newPosition;
      _notify();
      return;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      _lastSavedPosition!.latitude,
      _lastSavedPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distanceInMeters >= _locationUpdateThreshold) {
      await _updateLocationToServer(newPosition);
      _lastSavedPosition = newPosition;
    }

    if (_disposed) return;
    currentUserLocation = LatLng(newPosition.latitude, newPosition.longitude);

    if (hasActiveRide) {
      _notify();
    } else {
      final shouldNotify = _lastNotifyTime == null ||
          _lastNotifyPosition == null ||
          DateTime.now().difference(_lastNotifyTime!) >= _notifyTimeThreshold ||
          Geolocator.distanceBetween(
            _lastNotifyPosition!.latitude,
            _lastNotifyPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          ) >= _notifyDistanceThreshold;
      if (shouldNotify) {
        _lastNotifyTime = DateTime.now();
        _lastNotifyPosition = newPosition;
        _notify();
      }
    }
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      await DriverRepository.instance.updateDriver(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        isonline: true,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating location: $e');
    }
  }

  void _stopLocationTracking() {
    _locationSub?.cancel();
    _locationSub = null;
    _isTrackingLocation = false;
    _lastSavedPosition = null;
    _lastNotifyTime = null;
    _lastNotifyPosition = null;
    _availableDriversTimer?.cancel();
    _availableDriversTimer = null;
  }

  void setUserLocation(LatLng? loc) {
    currentUserLocation = loc;
    _notify();
  }

  // ── Socket ─────────────────────────────────────────────────────────────────

  void _initSocket() {
    if (_socketInitialized) return;
    _socketInitialized = true;

    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;
    _socket = io.io(
      Config.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );

    _socket.onConnect((_) {
      if (kDebugMode) debugPrint('Socket CONNECTED');
      _socket.emit('watch_entity', {'type': 'driver', 'id': driverId});
    });

    _socket.onReconnect((_) {
      _socket.emit('watch_entity', {'type': 'driver', 'id': driverId});
    });

    _socket.off('driver_rides');
    _socket.off('ride_updated');
    _socket.off('ride_taken');
    _socket.off('ride_assigned');
    _socket.on('driver_rides', (data) {
      if (!_disposed) onSocketRideData(data);
    });
    _socket.on('ride_updated', (data) {
      if (!_disposed) onSocketRideData(data);
    });
    // Rapido-style: when another driver accepts, backend may emit ride_taken/ride_assigned
    void onRideTaken(dynamic data) {
      if (_disposed) return;
      final d = data is Map ? Map<String, dynamic>.from(Map.from(data)) : null;
      if (d == null) return;
      final rideId = d['ride_id'] ?? d['rideId'];
      final driverId = d['driver_id'];
      final myId = FFAppState().driverid;
      if (rideId != null && driverId != null && driverId != myId) {
        onSocketRideData(
            {'id': rideId, 'driver_id': driverId, 'ride_status': 'ACCEPTED'});
      }
    }

    _socket.on('ride_taken', onRideTaken);
    _socket.on('ride_assigned', onRideTaken);

    _socket.connect();
  }

  // ── Incentives & Earnings ──────────────────────────────────────────────────

  /// Fetches driver's active incentives from API and filters to show ONLY currently running ones.
  /// Running incentives have progress_status == 'ongoing'.
  /// The ride count is incremented automatically when rides are completed.
  /// This is called:
  /// 1. On app initialization
  /// 2. After each ride completion via onRideComplete()
  Future<void> _fetchIncentiveData() async {
    try {
      isLoadingIncentives = true;
      _notify();

      final response = await DriverRepository.instance.getDriverIncentives(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (_disposed) return;
      if (response.succeeded) {
        final incentivesArray =
            getJsonField(response.jsonBody, r'''$.data''', true);

        if (incentivesArray != null && incentivesArray is List) {
          // 🎯 Filter to show ONLY currently running incentives
          // Completed or locked incentives are hidden from the main panel
          final runningIncentives = incentivesArray
              .where((item) => item['progress_status'] == 'ongoing')
              .toList();

          if (kDebugMode) {
            debugPrint(
                '📊 Incentives: Total=${incentivesArray.length}, Running=${runningIncentives.length}');
            for (var i in runningIncentives) {
              debugPrint(
                  '  ✅ ${i['incentive']?['name']} - Progress: ${i['completed_rides']}/${i['target_rides']} rides');
            }
          }

          // Calculate current rides count from running incentives
          currentRides = 0;
          for (final item in runningIncentives) {
            final completed = item['completed_rides'] ?? 0;
            if (completed > currentRides) currentRides = completed;
          }

          // Calculate total earned from all running incentives
          totalIncentiveEarned = 0.0;
          for (final item in runningIncentives) {
            if (item['progress_status'] == 'completed') {
              final rewardStr = item['reward_amount'] ?? '0';
              totalIncentiveEarned += double.tryParse(rewardStr) ?? 0.0;
            }
          }

          // Convert to IncentiveTier objects for UI display
          incentiveTiers = runningIncentives.map<IncentiveTier>((item) {
            return IncentiveTier(
              id: item['id'] ?? 0,
              targetRides: item['target_rides'] ?? 0,
              rewardAmount:
                  double.tryParse(item['reward_amount'] ?? '0') ?? 0.0,
              isLocked: false, // Running incentives are never locked
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
      if (kDebugMode) debugPrint('Error fetching incentive data: $e');
      incentiveTiers = [];
    } finally {
      if (!_disposed) {
        isLoadingIncentives = false;
        _notify();
      }
    }
  }

  Future<void> _fetchTodayEarnings() async {
    try {
      isLoadingEarnings = true;
      _notify();

      final response = await DriverRepository.instance.getTodayEarnings(
        driverId: FFAppState().driverid,
        token: FFAppState().accessToken,
        period: 'daily',
      );

      if (_disposed) return;
      if (response.succeeded) {
        final data = response.jsonBody['data'];
        todayTotal = (data['totalEarnings'] ?? 0).toDouble();
        todayRideCount = data['totalRides'] ?? 0;
        todayWallet = (data['walletEarnings'] ?? 0).toDouble();
        final rides = data['rides'] as List? ?? [];
        if (rides.isNotEmpty) {
          lastRideAmount = (rides.first['amount'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Earnings error: $e');
    } finally {
      if (!_disposed) {
        isLoadingEarnings = false;
        _notify();
      }
    }
  }

  Future<void> fetchTodayEarnings() => _fetchTodayEarnings();
  Future<void> fetchIncentiveData() => _fetchIncentiveData();

  void setRideStatus(String status) {
    currentRideStatus = status;
    _notify();
  }

  void onRideComplete() {
    if (_disposed) return;
    currentRideStatus = 'IDLE';
    _notify();
    _fetchTodayEarnings();
    _fetchIncentiveData();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopLocationTracking();
    _socket.disconnect();
    super.dispose();
  }
}
