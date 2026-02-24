import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ugo_driver/app_state.dart';
import 'package:ugo_driver/flutter_flow/nav/nav.dart';
import 'package:ugo_driver/home/home_widget.dart';

const String _kChannelId = 'ride_requests';
const String _kChannelName = 'New Ride Requests';
const String _kGeneralChannelId = 'general_notifications';
const String _kGeneralChannelName = 'General Updates';
const int _kRideRequestNotificationId = 9001;

/// Must be top-level for background isolate.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage msg) async {
  if (msg.data.containsKey('type') && msg.data['type'] == 'ride_request') {
    await _showRideNotificationInBackground(msg);
  }
}

/// Initialize plugin and show notification in background isolate.
/// Wrapped in try-catch to avoid "Future already completed" or other
/// isolate errors from affecting the app.
Future<void> _showRideNotificationInBackground(RemoteMessage msg) async {
  try {
    await _showRideNotificationInBackgroundImpl(msg);
  } catch (_) {
    // Background isolate: log but don't propagate to avoid app crash
  }
}

Future<void> _showRideNotificationInBackgroundImpl(RemoteMessage msg) async {
  final data = msg.data;
  final rideId = data['ride_id']?.toString() ?? data['rideId']?.toString() ?? '0';
  final title = msg.notification?.title ?? data['title'] ?? 'New Ride Request!';
  final body = msg.notification?.body ?? data['body'] ?? 'Tap to view ride details';
  final fare = data['fare'] ?? data['estimated_fare'];
  final dist = data['distance'] ?? data['ride_distance_km'];
  String displayBody = body;
  if (fare != null || dist != null) {
    final parts = <String>[];
    if (fare != null) parts.add('Fare: ₹$fare');
    if (dist != null) parts.add('$dist km');
    if (parts.isNotEmpty) displayBody = parts.join(' • ');
  }

  final plugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    if (Platform.isAndroid) {
    final channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: 'Incoming ride requests - don\'t miss!',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800]),
    );
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  const androidDetails = AndroidNotificationDetails(
    _kChannelId,
    _kChannelName,
    importance: Importance.max,
    priority: Priority.max,
    fullScreenIntent: false,
    category: AndroidNotificationCategory.event,
    largeIcon: DrawableResourceAndroidBitmap('ugo_notification'),
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
    interruptionLevel: InterruptionLevel.timeSensitive,
  );
  await plugin.show(
    _kRideRequestNotificationId,
    title,
    displayBody,
    const NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: rideId,
  );
}

/// Rapido Captain-style ride request notifications.
/// Shows heads-up when driver is in another app or app is backgrounded.
/// Supports FCM (backend push) + local notifications (socket when backgrounded).
///
/// Backend FCM payload for ride request (when driver is in other app or offline):
/// ```json
/// {
///   "data": {
///     "type": "ride_request",
///     "ride_id": "123",
///     "fare": "150",
///     "distance": "5.2"
///   }
/// }
/// ```
class RideNotificationService {
  static final RideNotificationService _instance = RideNotificationService._();
  factory RideNotificationService() => _instance;

  RideNotificationService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  void _parseAndShowLocalNotification(RemoteMessage msg) {
    final data = msg.data;
    final rideId = data['ride_id']?.toString() ?? data['rideId']?.toString() ?? '0';
    final title = msg.notification?.title ?? data['title'] ?? 'New Ride Request!';
    final body = msg.notification?.body ?? data['body'] ?? 'Tap to view ride details';
    final fare = data['fare'] ?? data['estimated_fare'];
    final dist = data['distance'] ?? data['ride_distance_km'];
    String displayBody = body;
    if (fare != null || dist != null) {
      final parts = <String>[];
      if (fare != null) parts.add('Fare: ₹$fare');
      if (dist != null) parts.add('$dist km');
      if (parts.isNotEmpty) displayBody = parts.join(' • ');
    }
    _showLocalRideNotification(rideId: rideId, title: title, body: displayBody);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Disable auto-request to avoid "Future already completed" when we request
    // in PreLoginLocationNotificationsScreen. Permission requested once before login.
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // Notification permission is requested once in PreLoginLocationNotificationsScreen (before login).
    // Do NOT request here to avoid asking twice.

    if (Platform.isAndroid) {
      final androidChannel = AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        description: 'Incoming ride requests - don\'t miss!',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800]),
        showBadge: true,
        enableLights: true,
        ledColor: AppColors.primary,
      );
      const generalChannel = AndroidNotificationChannel(
        _kGeneralChannelId,
        _kGeneralChannelName,
        description: 'Earnings, promotions, app updates',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(generalChannel);
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) _setPendingRideFromMessage(initialMsg);

    final launchDetails = await _local.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true && launchDetails?.notificationResponse?.payload != null) {
      final rideId = int.tryParse(launchDetails!.notificationResponse!.payload!);
      if (rideId != null && rideId > 0) {
        FFAppState().update(() => FFAppState().pendingRideIdFromNotification = rideId);
      }
    }

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      final rideId = int.tryParse(payload);
      if (rideId != null && rideId > 0) {
        FFAppState().update(() {
          FFAppState().pendingRideIdFromNotification = rideId;
        });
        _navigateToHome();
      }
    }
  }

  void _onForegroundMessage(RemoteMessage msg) {
    if (msg.data.containsKey('type') && msg.data['type'] == 'ride_request') {
      if (FFAppState().activeRideId != 0) return; // Driver on ride: no new requests
      _parseAndShowLocalNotification(msg);
    }
  }

  void _onMessageOpenedApp(RemoteMessage msg) {
    _setPendingRideFromMessage(msg);
    _navigateToHome();
  }

  void _setPendingRideFromMessage(RemoteMessage msg) {
    final data = msg.data;
    if (data['type'] != 'ride_request') return;
    final rideId = int.tryParse(data['ride_id']?.toString() ?? data['rideId']?.toString() ?? '0');
    if (rideId != null && rideId > 0) {
      FFAppState().update(() => FFAppState().pendingRideIdFromNotification = rideId);
    }
  }

  void _navigateToHome() {
    try {
      final context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.goNamed(HomeWidget.routeName);
      }
    } catch (_) {}
  }

  /// Show Rapido-style heads-up notification (when in other app or backgrounded).
  /// Call from overlay when socket delivers ride + app not in foreground,
  /// or FCM handles it when backend sends push.
  Future<void> showRideRequestNotification({
    required int rideId,
    String title = 'New Ride Request!',
    String body = 'Tap to view and accept',
    double? estimatedFare,
    double? distance,
  }) async {
    if (FFAppState().activeRideId != 0) return; // Driver on ride: no new requests
    String displayBody = body;
    if (estimatedFare != null || distance != null) {
      final parts = <String>[];
      if (estimatedFare != null) parts.add('Fare: ₹${estimatedFare.toStringAsFixed(0)}');
      if (distance != null) parts.add('${distance.toStringAsFixed(1)} km');
      if (parts.isNotEmpty) displayBody = parts.join(' • ');
    }
    await _showLocalRideNotification(
      rideId: rideId.toString(),
      title: title,
      body: displayBody,
    );
  }

  Future<void> _showLocalRideNotification({
    required String rideId,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    AndroidNotificationDetails androidDetails;
    if (Platform.isAndroid) {
      androidDetails = AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: 'Incoming ride requests - don\'t miss!',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800]),
        styleInformation: BigTextStyleInformation(body),
        category: AndroidNotificationCategory.event,
        fullScreenIntent: false,
        visibility: NotificationVisibility.public,
        color: AppColors.primary,
        largeIcon: const DrawableResourceAndroidBitmap('ugo_notification'),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(_kChannelId, _kChannelName);
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    const id = _kRideRequestNotificationId;
    await _local.show(id, title, body, details, payload: rideId);
  }

  /// Call from ride overlay when socket delivers new SEARCHING ride and app may be backgrounded.
  void onNewRideFromSocket({
    required int rideId,
    required bool isAppInForeground,
    double? estimatedFare,
    double? distance,
  }) {
    if (isAppInForeground) return;
    showRideRequestNotification(
      rideId: rideId,
      estimatedFare: estimatedFare,
      distance: distance,
    );
  }

  /// Cancel ride request notification.
  Future<void> cancelRideNotification() async {
    await _local.cancel(_kRideRequestNotificationId);
  }
}
