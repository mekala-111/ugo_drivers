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
import '/login/login_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  await WakelockPlus.enable();
  await initFirebase();

  await RideNotificationService().initialize();
  await VoiceService().initFromStorage();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  await FFLocalizations.initialize();

  await initializeFirebaseAppCheck();

  // Error handling: present + report to Crashlytics
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };
  if (!kIsWeb) {
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runZonedGuarded(
    () => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => RideState()),
      ],
      child: const MyApp(),
    )),
    (Object error, StackTrace stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      }
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }
    },
  );
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

  // ✅ GLOBAL MESSENGER KEY FOR SNACKBARS
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
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    _loadStoredLocale();
    userStream = ugoDriverFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // ✅ REGISTER GLOBAL LOGOUT LISTENER
    ApiManager.onUnauthenticated = () {
      if (FFAppState().isLoggedIn) {
        // 1. Clear Local State
        FFAppState().update(() {
          FFAppState().accessToken = '';
          FFAppState().isLoggedIn = false;
          // You might keep isRegistered true to avoid full re-registration flow if they login again
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
      }
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
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      WakelockPlus.disable();
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
      title: 'UGO-DRIVER',
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
