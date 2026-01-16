// import 'dart:developer';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();

//   IO.Socket? socket;

//   void connect({
//     required String jwtToken,
//     required void Function() onConnected,
//     required void Function(dynamic error) onError,
//   }) {
//     log('🔌 Initializing Socket.IO');

//     socket = IO.io(
//       'https://ugotaxi.com',
//       IO.OptionBuilder()
//           .setTransports(['polling'])
//           .setAuth({'token': jwtToken})
//           .disableAutoConnect()
//           .build(),
//     );

//     socket!.onConnect((_) {
//       log('✅ Socket connected: ${socket!.id}');
//       onConnected();
//     });

//     socket!.onConnectError((err) {
//       log('🚫 Connect error: $err');
//       onError(err);
//     });

//     socket!.onDisconnect((_) {
//       log('❌ Socket disconnected');
//     });

//     socket!.connect();
//   }

//   /// EXACT MATCH WITH HTML:
//   /// socket.on("ride_data", (ride) => { ... })
//   void onDriverRide(void Function(dynamic id) callback) {
//     socket?.on('driver_rides', callback);
//   }

//   void dispose() {
//     socket?.disconnect();
//     socket?.dispose();
//     socket = null;
//   }
// }
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect({
    required String jwtToken,
    required void Function() onConnected,
    required void Function(dynamic error) onError,
  }) {
    log('🔌 Initializing Socket.IO');

    // Clean token if it has "Bearer " prefix
    final cleanToken = jwtToken.replaceFirst('Bearer ', '').trim();

    socket = IO.io(
      'https://ugotaxi.com',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // ✅ Try websocket first
          .setAuth({'token': cleanToken}) // ✅ Clean token
          .setPath('/socket.io/') // ✅ Explicit path
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      log('✅ Socket connected: ${socket!.id}');
      onConnected();
    });

    socket!.onConnectError((err) {
      log('🚫 Connect error: $err');
      onError(err);
    });

    socket!.onError((err) {
      log('🚫 Socket error: $err');
      onError(err);
    });

    socket!.onDisconnect((reason) {
      log('❌ Socket disconnected: $reason');
    });

    // Connect after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      socket!.connect();
      log('🔄 Connection initiated...');
    });
  }

  void onDriverRide(void Function(dynamic data) callback) {
    socket?.on('driver_rides', (data) {
      log('📦 Received driver_rides event: $data');
      callback(data);
    });
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}