import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ugo_driver/SplashWidget/splashwidget.dart';

import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';
// import '/aadhaar/aadhaar_update.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      // initialLocation: '/',
      initialLocation: SplashWidget.routePath,
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? HomeWidget() : LoginWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? HomeWidget() : LoginWidget(),
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => LoginWidget(),
        ),
        FFRoute(
          name: OtpverificationWidget.routeName,
          path: OtpverificationWidget.routePath,
          builder: (context, params) => OtpverificationWidget(
            mobile: params.getParam(
              'mobile',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PrivacypolicyWidget.routeName,
          path: PrivacypolicyWidget.routePath,
          builder: (context, params) => PrivacypolicyWidget(),
        ),
        FFRoute(
          name: ServiceoptionsWidget.routeName,
          path: ServiceoptionsWidget.routePath,
          builder: (context, params) => ServiceoptionsWidget(),
        ),
        FFRoute(
          name: SplashWidget.routeName,
          path: SplashWidget.routePath,
          builder: (context, params) => const SplashWidget(),
        ),

        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          builder: (context, params) => HomeWidget(),
        ),
        FFRoute(
          name: AccountManagementWidget.routeName,
          path: AccountManagementWidget.routePath,
          builder: (context, params) => AccountManagementWidget(),
        ),
        FFRoute(
          name: SupportWidget.routeName,
          path: SupportWidget.routePath,
          builder: (context, params) => SupportWidget(),
        ),
        FFRoute(
          name: WalletWidget.routeName,
          path: WalletWidget.routePath,
          builder: (context, params) => WalletWidget(),
        ),
        FFRoute(
          name: AddBankAccountWidget.routeName,
          path: AddBankAccountWidget.routePath,
          builder: (context, params) => AddBankAccountWidget(),
        ),
        FFRoute(
          name: WithdrawWidget.routeName,
          path: WithdrawWidget.routePath,
          builder: (context, params) => WithdrawWidget(
            bankAccountNumber: params.getParam(
              'bankAccountNumber',
              ParamType.String,
            ),
            ifscCode: params.getParam(
              'ifscCode',
              ParamType.String,
            ),
            accountHolderName: params.getParam(
              'accountHolderName',
              ParamType.String,
            ),
            fundAccountId: params.getParam(
              'fundAccountId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PaymentsPageWidget.routeName,
          path: PaymentsPageWidget.routePath,
          builder: (context, params) => PaymentsPageWidget(),
        ),
        FFRoute(
          name: ScanToBookWidget.routeName,
          path: ScanToBookWidget.routePath,
          builder: (context, params) => ScanToBookWidget(),
        ),
        FFRoute(
          name: HistoryWidget.routeName,
          path: HistoryWidget.routePath,
          builder: (context, params) => HistoryWidget(),
        ),
        FFRoute(
          name: ProfileSettingWidget.routeName,
          path: ProfileSettingWidget.routePath,
          builder: (context, params) => ProfileSettingWidget(),
        ),

        FFRoute(
          name: SavedAddWidget.routeName,
          path: SavedAddWidget.routePath,
          builder: (context, params) => SavedAddWidget(),
        ),
        // FFRoute(
        //   name: AccessibilitySettingsWidget.routeName,
        //   path: AccessibilitySettingsWidget.routePath,
        //   builder: (context, params) => AccessibilitySettingsWidget(),
        // ),

        FFRoute(
          name: PushnotificationsWidget.routeName,
          path: PushnotificationsWidget.routePath,
          builder: (context, params) => PushnotificationsWidget(),
        ),

        FFRoute(
          name: TrustedcontactsWidget.routeName,
          path: TrustedcontactsWidget.routePath,
          builder: (context, params) => TrustedcontactsWidget(),
        ),
        FFRoute(
          name: RidecheckWidget.routeName,
          path: RidecheckWidget.routePath,
          builder: (context, params) => RidecheckWidget(),
        ),
        FFRoute(
          name: TipautomaticallyWidget.routeName,
          path: TipautomaticallyWidget.routePath,
          builder: (context, params) => TipautomaticallyWidget(),
        ),
        FFRoute(
          name: ReservematchingWidget.routeName,
          path: ReservematchingWidget.routePath,
          builder: (context, params) => ReservematchingWidget(),
        ),

        FFRoute(
          name: VoucherWidget.routeName,
          path: VoucherWidget.routePath,
          builder: (context, params) => VoucherWidget(),
        ),
        FFRoute(
          name: WalletPasswordWidget.routeName,
          path: WalletPasswordWidget.routePath,
          builder: (context, params) => WalletPasswordWidget(),
        ),

        FFRoute(
          name: MessagesWidget.routeName,
          path: MessagesWidget.routePath,
          builder: (context, params) => MessagesWidget(),
        ),
        FFRoute(
          name: AccountSupportWidget.routeName,
          path: AccountSupportWidget.routePath,
          builder: (context, params) => AccountSupportWidget(),
        ),
        FFRoute(
          name: SupportRideWidget.routeName,
          path: SupportRideWidget.routePath,
          builder: (context, params) => SupportRideWidget(),
        ),
        FFRoute(
          name: RideOverviewWidget.routeName,
          path: RideOverviewWidget.routePath,
          builder: (context, params) => RideOverviewWidget(),
        ),
        FFRoute(
          name: ReportIssuesWidget.routeName,
          path: ReportIssuesWidget.routePath,
          builder: (context, params) => ReportIssuesWidget(),
        ),
        FFRoute(
          name: CustomerSuportWidget.routeName,
          path: CustomerSuportWidget.routePath,
          builder: (context, params) => CustomerSuportWidget(),
        ),

        FFRoute(
          name: ChooseVehicleWidget.routeName,
          path: ChooseVehicleWidget.routePath,
          builder: (context, params) => ChooseVehicleWidget(
            mobile: params.getParam(
              'mobile',
              ParamType.int,
            ),
            firstname: params.getParam(
              'firstname',
              ParamType.String,
            ),
            lastname: params.getParam(
              'lastname',
              ParamType.String,
            ),
            email: params.getParam(
              'email',
              ParamType.String,
            ),
            referalcode: params.getParam(
              'referalcode',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: OnBoardingWidget.routeName,
          path: OnBoardingWidget.routePath,
          builder: (context, params) => OnBoardingWidget(
            mobile: params.getParam(
              'mobile',
              ParamType.int,
            ),
            firstname: params.getParam(
              'firstname',
              ParamType.String,
            ),
            lastname: params.getParam(
              'lastname',
              ParamType.String,
            ),
            email: params.getParam(
              'email',
              ParamType.String,
            ),
            referalcode: params.getParam(
              'referalcode',
              ParamType.int,
            ),
            vehicletype: params.getParam(
              'vehicletype',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DrivingDlWidget.routeName,
          path: DrivingDlWidget.routePath,
          builder: (context, params) => DrivingDlWidget(),
        ),
        FFRoute(
          name: FaceVerifyWidget.routeName,
          path: FaceVerifyWidget.routePath,
          builder: (context, params) => FaceVerifyWidget(),
        ),
        FFRoute(
          name: AdharUploadWidget.routeName,
          path: AdharUploadWidget.routePath,
          builder: (context, params) => AdharUploadWidget(),
        ),
        FFRoute(
          name: UploadRcWidget.routeName,
          path: UploadRcWidget.routePath,
          builder: (context, params) => UploadRcWidget(),
        ),
        FFRoute(
          name: VehicleImageUpdateWidget.routeName,
          path: VehicleImageUpdateWidget.routePath,
          builder: (context, params) => VehicleImageUpdateWidget(),
        ),
        
        FFRoute(
          name: DrivingDlUpdateWidget.routeName,
          path: DrivingDlUpdateWidget.routePath,
          builder: (context, params) => DrivingDlUpdateWidget(),
        ),
        FFRoute(
          name: AdharUploadUpdateWidget.routeName,
          path:AdharUploadUpdateWidget.routePath,
          builder: (context, params) => AdharUploadUpdateWidget(),
        ),
        FFRoute(
          name: RegistrationUpdateWidget.routeName,
          path: RegistrationUpdateWidget.routePath,
          builder: (context, params) => RegistrationUpdateWidget(),
        ),
        FFRoute(
          name: FaceVerifyupdateWidget.routeName,
          path: FaceVerifyupdateWidget.routePath,
          builder: (context, params) => FaceVerifyupdateWidget(),
        ),


        FFRoute(
          name: RCUploadWidget.routeName,
          path: RCUploadWidget.routePath,
          builder: (context, params) => RCUploadWidget(),
        ),
        FFRoute(
          name: InboxPageWidget.routeName,
          path: InboxPageWidget.routePath,
          builder: (context, params) => InboxPageWidget(),
        ),
        FFRoute(
          name: IncentivePageWidget.routeName,
          path: IncentivePageWidget.routePath,
          builder: (context, params) => IncentivePageWidget(),
        ),

        FFRoute(
          name: TeampageWidget.routeName,
          path: TeampageWidget.routePath,
          builder: (context, params) => TeampageWidget(),
        ),
        FFRoute(
          name: TeamridesWidget.routeName,
          path: TeamridesWidget.routePath,
          builder: (context, params) => TeamridesWidget(),
        ),
        FFRoute(
          name: TeamearningWidget.routeName,
          path: TeamearningWidget.routePath,
          builder: (context, params) => TeamearningWidget(),
        ),
        FFRoute(
          name: FirstdetailsWidget.routeName,
          path: FirstdetailsWidget.routePath,
          builder: (context, params) => FirstdetailsWidget(
            mobile: params.getParam(
              'mobile',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PanuploadScreenWidget.routeName,
          path: PanuploadScreenWidget.routePath,
          builder: (context, params) => PanuploadScreenWidget(),
        ),
        FFRoute(
          name: VehicleImageWidget.routeName,
          path: VehicleImageWidget.routePath,
          builder: (context, params) => VehicleImageWidget(),
        ),
        FFRoute(
          name: RegistrationImageWidget.routeName,
          path: RegistrationImageWidget.routePath,
          builder: (context, params) => RegistrationImageWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: Color(0xFFFF7B10),
                  child: Image.asset(
                    'assets/images/logo--_1.png',
                    fit: BoxFit.none,
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
