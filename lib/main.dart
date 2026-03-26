import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'providers/ride_provider.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import '/services/voice_service.dart';
import 'flutter_flow/firebase_app_check_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// ✅ IMPORT API MANAGER & LOGIN
import '/backend/api_requests/api_manager.dart';
import '/services/ride_notification_service.dart';
import '/services/firebase_remote_config_service.dart';
import '/services/install_referrer_service.dart';
import '/services/ride_alert_audio_service.dart';
import '/services/floating_bubble_service.dart';
import '/auth/login_timestamp.dart';
import '/login/login_widget.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    GoRouter.optionURLReflectsImperativeAPIs = true;
    usePathUrlStrategy();

    // ✅ Initialize AppState immediately so it is guaranteed to exist for runApp
    final appState = FFAppState();

    // ✅ Wrap all pre-flight async calls in a try-catch.
    // This guarantees that if a background service or plugin crashes,
    // it won't skip runApp() and cause a permanent white screen.
    try {
      debugPrint('UGO_STARTUP: Cleaning up orphaned floating bubble...');
      try { await FloatingBubbleService.stopFloatingBubble(); } catch (_) {}

      debugPrint('UGO_STARTUP: Stopping lingering audio...');
      await RideAlertAudioService.stopLingeringAlertAudio();

      debugPrint('UGO_STARTUP: Initializing Firebase...');
      await initFirebase();

      debugPrint('UGO_STARTUP: Initializing Remote Config...');
      // Initialize Firebase Remote Config (for secure Razorpay keys) with a timeout
      await FirebaseRemoteConfigService().initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint('UGO_STARTUP: Remote Config Timeout'),
      );

      debugPrint('UGO_STARTUP: Initializing Notifications...');
      await RideNotificationService().initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint('UGO_STARTUP: Notifications Timeout'),
      );

      await RideNotificationService().cancelRideNotification();

      debugPrint('UGO_STARTUP: Initializing Voice Service...');
      await VoiceService().initFromStorage();
      await VoiceService().stop();

      debugPrint('UGO_STARTUP: Initializing Theme...');
      await FlutterFlowTheme.initialize();

      debugPrint('UGO_STARTUP: Loading App State...');
      await appState.initializePersistedState();

      debugPrint('UGO_STARTUP: Finalizing localizations...');
      await InstallReferrerService.captureReferralCodeIfAvailable();
      await FFLocalizations.initialize();
      await initializeFirebaseAppCheck();
    } catch (e, stack) {
      debugPrint('UGO_STARTUP_ERROR: Initialization failed before runApp: $e');
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      }
    }

    // Error handling: present + report to Crashlytics
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (!kIsWeb) {
        final isOverflow = details.exceptionAsString().contains('RenderFlex overflowed');
        if (details.silent || isOverflow) {
          FirebaseCrashlytics.instance.recordFlutterError(details);
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      }
    };
    if (!kIsWeb) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // ✅ runApp is now 100% guaranteed to fire, preventing the white screen of death.
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => RideState()),
      ],
      child: const MyApp(),
    ));
  }, (Object error, StackTrace stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
    if (kDebugMode) {
      debugPrint('Uncaught error: $error\n$stack');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  // ✅ GLOBAL MESSENGER KEY FOR SNACK BARS
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Safe place to enable Wakelock (Activity is fully attached to the view)
    WakelockPlus.enable().catchError((e) => debugPrint('Wakelock error: $e'));

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    debugPrint('UGO_STARTUP: Checking stored locale...');
    _loadStoredLocale();

    debugPrint('UGO_STARTUP: Starting User Stream...');
    userStream = ugoDriverFirebaseUserStream()
      ..listen((user) {
        debugPrint('UGO_STARTUP: User state changed: ${user.uid != null ? "Logged In" : "Logged Out"}');
        _appStateNotifier.update(user);
      });
    // Dismiss splash after 200ms; re-check at 1.5s as a hard safety net
    // in case the first notify didn't trigger a GoRouter rebuild.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_appStateNotifier.showSplashImage) {
        debugPrint('UGO_STARTUP: Safety stop of Splash Image (200ms)');
        _appStateNotifier.stopShowingSplashImage();
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_appStateNotifier.showSplashImage) {
        debugPrint('UGO_STARTUP: Hard safety stop of Splash Image (1.5s)');
        _appStateNotifier.stopShowingSplashImage();
      }
    });

    // ✅ REGISTER GLOBAL LOGOUT LISTENER
    ApiManager.onUnauthenticated = () {
      if (!FFAppState().isLoggedIn) return;

      // Grace period: avoid logout on 401 within 10s of login (handles race with first API calls)
      final now = DateTime.now();
      if (lastLoginTime != null &&
          now.difference(lastLoginTime!).inSeconds < 10) {
        if (kDebugMode) {
          debugPrint('API 401: Ignoring during login grace period');
        }
        return;
      }

      // 1. Clear Local State
      FFAppState().update(() {
        FFAppState().accessToken = '';
        FFAppState().isLoggedIn = false;
      });

      // 2. Redirect to Login
      _router.goNamed(LoginWidget.routeName);

      // 3. Show Alert
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Session expired. You have been logged in on another device.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    };
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
    VoiceService().setLanguage(language);
  }

  void _loadStoredLocale() {
    final stored = FFLocalizations.getStoredLocale();
    if (stored != null) {
      safeSetState(() => _locale = stored);
      VoiceService().setLanguage(stored.languageCode);
    }
  }

  void setThemeMode(ThemeMode mode) {
    safeSetState(() {
      FlutterFlowTheme.saveThemeMode(mode);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WakelockPlus.enable();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      WakelockPlus.disable();
    } else if (state == AppLifecycleState.detached) {
      WakelockPlus.disable();
      try { FloatingBubbleService.stopFloatingBubble(); } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey, // ✅ Attach Global Key
      debugShowCheckedModeBanner: false,
      title: 'ugo_driver',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('te'),
        Locale('hi'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   useMaterial3: false,
      // ),
      themeMode: FlutterFlowTheme.themeMode,
      routerConfig: _router,
    );
  }
}