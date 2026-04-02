import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '/config.dart';

/// Singleton Socket.IO client for driver home: dispatch rooms, ride updates, chat banners.
///
/// Survives the same lifecycle as the logged-in session. [dispose] when HomeController
/// disposes (logout / leave home). On access-token refresh, call [reconnectWithLatestToken]
/// so the handshake uses the new JWT (session id / expiry).
class DriverRealtimeSocketService {
  DriverRealtimeSocketService._();
  static final DriverRealtimeSocketService instance =
      DriverRealtimeSocketService._();

  io.Socket? _socket;
  DriverSocketCallbacks? _callbacks;
  String _authToken = '';
  Timer? _deferredWatchTimer;

  io.Socket? get rawSocket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  void _log(String msg) {
    if (kDebugMode) debugPrint('[DriverSocket] $msg');
  }

  static String _stripBearer(String t) {
    var s = t.trim();
    if (s.toLowerCase().startsWith('bearer ')) {
      s = s.substring(7).trim();
    }
    return s;
  }

  /// Connect with current JWT, attach listeners once per socket instance, join driver room.
  void connect(DriverSocketCallbacks callbacks) {
    _callbacks = callbacks;
    final token = _stripBearer(callbacks.accessTokenProvider());
    if (token.isEmpty) {
      _log('connect skipped: empty token');
      return;
    }
    _authToken = token;

    _disposeSocketInternal(clearCallbacks: false);

    _socket = io.io(
      Config.baseUrl,
      io.OptionBuilder()
          .setPath('/socket.io/')
          .setTransports(['websocket', 'polling'])
          .setTimeout(20000)
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': _authToken})
          .build(),
    );

    _attachCoreListeners();
    _attachRideListeners();

    _socket!.connect();
    _log('connect() issued');
  }

  void _attachCoreListeners() {
    final s = _socket!;

    s.onConnect((_) {
      _log('CONNECTED id=${s.id}');
      _emitWatchEntityWithRetry(reason: 'onConnect');
    });

    s.onReconnect((_) {
      _log('RECONNECTED id=${s.id}');
      _emitWatchEntityWithRetry(reason: 'onReconnect');
    });

    s.io.on('reconnect_attempt', (data) {
      _log('reconnect_attempt $data');
    });
    s.io.on('reconnect', (data) {
      _log('io.reconnect $data');
    });
    s.io.on('reconnect_error', (data) {
      _log('reconnect_error $data');
    });

    s.onConnectError((dynamic e) {
      _log('connect_error $e');
    });

    s.onDisconnect((dynamic reason) {
      _log('DISCONNECT reason=$reason');
    });

    s.on('connect_timeout', (dynamic d) {
      _log('connect_timeout $d');
    });
  }

  void _emitWatchEntityWithRetry({required String reason}) {
    _deferredWatchTimer?.cancel();
    _emitWatchEntityOnce(reason: reason);
    // Same pattern as ride chat: server sometimes misses the first join right after connect.
    _deferredWatchTimer = Timer(const Duration(milliseconds: 450), () {
      if (_socket?.connected == true) {
        _emitWatchEntityOnce(reason: '$reason+delayed');
      }
    });
  }

  void _emitWatchEntityOnce({required String reason}) {
    final cb = _callbacks;
    if (cb == null || cb.isDisposed()) return;
    final s = _socket;
    if (s == null || !s.connected) {
      _log('watch_entity skip (not connected) $reason');
      return;
    }
    var token = _stripBearer(cb.accessTokenProvider());
    if (token.isEmpty) {
      _log('watch_entity skip (no token) $reason');
      return;
    }
    final driverId = cb.driverIdProvider();
    if (driverId <= 0) {
      _log('watch_entity skip (driverId=$driverId) $reason');
      return;
    }
    try {
      s.emit('watch_entity', {'type': 'driver', 'id': driverId});
      s.emit('driver_socket_ready', {
        'driver_id': driverId,
        'driverId': driverId,
        'reason': reason,
      });
      _log('watch_entity + driver_socket_ready driver=$driverId ($reason)');
    } catch (e) {
      _log('watch_entity error: $e');
    }
  }

  /// Re-register with server (app resume, token refresh, manual).
  void emitWatchEntity({String reason = 'manual'}) {
    _emitWatchEntityWithRetry(reason: reason);
  }

  void _attachRideListeners() {
    final s = _socket!;
    final cb = _callbacks!;

    void Function(dynamic) guard(void Function(dynamic) fn) {
      return (dynamic data) {
        if (cb.isDisposed()) return;
        fn(data);
      };
    }

    s.off('driver_rides');
    s.off('ride_updated');
    s.off('ride_expired');
    s.off('ride_location_updated');
    s.off('ride_taken');
    s.off('ride_assigned');
    s.off('driver_updated');
    s.off('driver_profile_updated');
    s.off('kyc_status_updated');
    s.off('receive_ride_message');
    s.off('chat_message');
    s.off('watch_entity_ack');

    s.on('driver_rides', guard(cb.onSocketRideData));
    s.on(
      'ride_updated',
      guard((data) {
        if (kDebugMode) debugPrint('🔔 Socket ride_updated event: $data');
        cb.onSocketRideData(data);
      }),
    );

    s.on('ride_expired', guard((data) {
      if (kDebugMode) debugPrint('🔔 Socket ride_expired event: $data');
      if (data is! Map) return;
      final d = Map<String, dynamic>.from(Map.from(data));
      final rideId = d['ride_id'] ?? d['rideId'];
      if (rideId != null) {
        cb.onSocketRideData({
          'id': rideId,
          'ride_status': 'EXPIRED',
          'replaced_by_ride_id': d['replaced_by_ride_id'],
        });
      }
    }));

    s.on('ride_location_updated', guard(_wrapRideLocationUpdated(cb)));

    s.on('ride_taken', guard(_wrapRideTaken(cb)));
    s.on('ride_assigned', guard(_wrapRideTaken(cb)));

    s.on('driver_updated', guard(_wrapDriverUpdate(cb)));
    s.on('driver_profile_updated', guard(_wrapDriverUpdate(cb)));
    s.on('kyc_status_updated', guard(_wrapDriverUpdate(cb)));

    s.on('receive_ride_message', guard(cb.onRideChatMessage));
    s.on('chat_message', guard(cb.onRideChatMessage));

    s.on('watch_entity_ack', guard((dynamic d) => _log('watch_entity_ack $d')));
  }

  void Function(dynamic) _wrapRideLocationUpdated(DriverSocketCallbacks cb) {
    return (dynamic data) {
      if (data is! Map) return;
      cb.onRideLocationUpdated(Map<String, dynamic>.from(Map.from(data)));
    };
  }

  void Function(dynamic) _wrapRideTaken(DriverSocketCallbacks cb) {
    return (dynamic data) {
      if (data is! Map) return;
      final d = Map<String, dynamic>.from(Map.from(data));
      final rideId = d['ride_id'] ?? d['rideId'];
      final otherDriverId = d['driver_id'];
      final myId = cb.driverIdProvider();
      if (rideId != null && otherDriverId != null && otherDriverId != myId) {
        cb.onSocketRideData({
          'id': rideId,
          'driver_id': otherDriverId,
          'ride_status': 'ACCEPTED',
        });
      }
    };
  }

  void Function(dynamic) _wrapDriverUpdate(DriverSocketCallbacks cb) {
    return (dynamic data) {
      if (data is! Map) return;
      cb.onDriverProfileSocketUpdate(Map<String, dynamic>.from(Map.from(data)));
    };
  }

  /// Live GPS during active ride (same payload as HomeController).
  void emitDriverLocation(Map<String, dynamic> payload) {
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('driver_location', payload);
      }
    } catch (e) {
      _log('emitDriverLocation error: $e');
    }
  }

  void emitSubscribeRideChat(int rideId) {
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('subscribe_ride_chat', {
          'rideId': rideId,
          'ride_id': rideId,
        });
      }
    } catch (e) {
      _log('subscribe_ride_chat error: $e');
    }
  }

  void emitUnsubscribeRideChat(int rideId) {
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('unsubscribe_ride_chat', {
          'rideId': rideId,
          'ride_id': rideId,
        });
      }
    } catch (e) {
      _log('unsubscribe_ride_chat error: $e');
    }
  }

  /// After silent JWT refresh — old handshake auth is stale for the next reconnect.
  void reconnectWithLatestToken() {
    final cb = _callbacks;
    if (cb == null || cb.isDisposed()) return;
    final t = _stripBearer(cb.accessTokenProvider());
    if (t.isEmpty) return;
    _authToken = t;
    _log('reconnectWithLatestToken: recycling socket');
    connect(cb);
  }

  void reconnectIfDisconnected() {
    final s = _socket;
    if (s == null) return;
    if (!s.connected) {
      _log('reconnectIfDisconnected: calling connect()');
      s.connect();
    } else {
      emitWatchEntity(reason: 'reconnectIfDisconnected');
    }
  }

  void _disposeSocketInternal({required bool clearCallbacks}) {
    _deferredWatchTimer?.cancel();
    _deferredWatchTimer = null;
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    if (clearCallbacks) _callbacks = null;
  }

  /// Home disposed or logout.
  void dispose() {
    _disposeSocketInternal(clearCallbacks: true);
    _log('dispose()');
  }
}

/// Callback bundle from [HomeController] (must stay in sync with token / driver id).
class DriverSocketCallbacks {
  DriverSocketCallbacks({
    required this.accessTokenProvider,
    required this.driverIdProvider,
    required this.isDisposed,
    required this.onSocketRideData,
    required this.onRideLocationUpdated,
    required this.onRideChatMessage,
    required this.onDriverProfileSocketUpdate,
  });

  final String Function() accessTokenProvider;
  final int Function() driverIdProvider;
  final bool Function() isDisposed;
  final void Function(dynamic data) onSocketRideData;
  final void Function(Map<String, dynamic> data) onRideLocationUpdated;
  final void Function(dynamic raw) onRideChatMessage;
  final void Function(Map<String, dynamic> data) onDriverProfileSocketUpdate;
}
