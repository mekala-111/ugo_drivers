import 'package:flutter/material.dart';

import 'device_type.dart';

/// Responsive utilities for UGO Drivers app.
/// Designed for driver-friendly UX: large touch targets, readable text,
/// one-handed use, and support for mobile, 7", and 10" tablets.
///
/// Use [screenWidth]/[screenHeight] for direct media queries.
/// Prefer [responsiveWidth], [responsiveHeight], [responsiveFontSize], [spacing].
class Responsive {
  Responsive._();

  // ── Reference design size (used for scaling) ──
  static const double refWidth = 375.0;
  static const double refHeight = 812.0;
  static const double refDiagonal = 828.0;

  // ── Breakpoints (mobile < 600, tablet7 600–900, tablet10 ≥ 900) ──
  static const double breakpointSmall = 360.0;   // Small phones
  static const double breakpointMedium = 480.0;  // Regular phones
  static const double breakpointLarge = 600.0;   // 7" tablet start
  static const double breakpointXLarge = 900.0;  // 10" tablet start

  // ── Height breakpoints (for tall/short screens) ──
  static const double heightShort = 600.0;   // Short screens (e.g. landscape, small devices)
  static const double heightMedium = 700.0;  // Average phone height
  static const double heightTall = 800.0;    // Tall phones

  /// Screen width from MediaQuery (use MediaQuery.sizeOf for performance).
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Screen height from MediaQuery.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Device type based on screen width.
  static DeviceType getDeviceType(BuildContext context) {
    final w = screenWidth(context);
    if (w >= breakpointXLarge) return DeviceType.tablet10;
    if (w >= breakpointLarge) return DeviceType.tablet7;
    return DeviceType.mobile;
  }

  // ── Responsive scaling (replace hardcoded pixels) ──

  /// Scales [value] by screen width / reference width.
  static double responsiveWidth(BuildContext context, double value) {
    final w = screenWidth(context);
    final scale = w / refWidth;
    return value * scale.clamp(0.5, 1.5);
  }

  /// Scales [value] by screen height / reference height.
  static double responsiveHeight(BuildContext context, double value) {
    final h = screenHeight(context);
    final scale = h / refHeight;
    return value * scale.clamp(0.5, 1.5);
  }

  /// Scales font size; capped per device (mobile max 24, tablet10 max 28).
  static double responsiveFontSize(BuildContext context, double value) {
    final scaleFactor = scale(context);
    final dt = getDeviceType(context);
    final scaled = value * scaleFactor;
    if (dt.isMobile) return scaled.clamp(10.0, 24.0);
    if (dt.isTablet7) return scaled.clamp(11.0, 26.0);
    return scaled.clamp(12.0, 28.0);
  }

  /// Standard spacing scale: 8, 16, 24, 32 (scaled).
  static double spacing(BuildContext context, {int scale = 1}) {
    final base = 8.0 * scale;
    return responsiveWidth(context, base);
  }

  /// Predefined spacing: xs=8, sm=16, md=24, lg=32, xl=40.
  static double spacingXl(BuildContext context) =>
      spacing(context, scale: 5);
  static double spacingLg(BuildContext context) =>
      spacing(context, scale: 4);
  static double spacingMd(BuildContext context) =>
      spacing(context, scale: 3);
  static double spacingSm(BuildContext context) =>
      spacing(context, scale: 2);
  static double spacingXs(BuildContext context) =>
      spacing(context, scale: 1);

  /// Returns a value based on screen width (media-query style).
  /// Uses min-width logic: picks the smallest breakpoint that the width satisfies.
  static T valueByWidth<T>(BuildContext context, {
    T? at360,
    T? at480,
    T? at600,
    T? at900,
    required T defaultVal,
  }) {
    final w = screenWidth(context);
    if (w >= breakpointXLarge && at900 != null) return at900;
    if (w >= breakpointLarge && at600 != null) return at600;
    if (w >= breakpointMedium && at480 != null) return at480;
    if (w >= breakpointSmall && at360 != null) return at360;
    return defaultVal;
  }

  /// Returns a value based on screen height (media-query style).
  static T valueByHeight<T>(BuildContext context, {
    T? at600,
    T? at700,
    T? at800,
    required T defaultVal,
  }) {
    final h = screenHeight(context);
    if (h >= heightTall && at800 != null) return at800;
    if (h >= heightMedium && at700 != null) return at700;
    if (h >= heightShort && at600 != null) return at600;
    return defaultVal;
  }

  /// True when width >= [breakpoint]. Use for min-width media queries.
  static bool widthGte(BuildContext context, double breakpoint) =>
      screenWidth(context) >= breakpoint;

  /// True when width < [breakpoint]. Use for max-width media queries.
  static bool widthLt(BuildContext context, double breakpoint) =>
      screenWidth(context) < breakpoint;

  /// True when height >= [breakpoint].
  static bool heightGte(BuildContext context, double breakpoint) =>
      screenHeight(context) >= breakpoint;

  /// True when height < [breakpoint].
  static bool heightLt(BuildContext context, double breakpoint) =>
      screenHeight(context) < breakpoint;

  /// Minimum touch target size (Material: 48dp). Drivers need easy taps.
  static const double minTouchTarget = 48.0;

  /// Base scale for small screens (width < 360)
  static const double smallScreenScale = 0.92;

  /// Base scale for medium screens (360–480)
  static const double mediumScreenScale = 1.0;

  /// Base scale for large screens (480–600+)
  static const double largeScreenScale = 1.08;

  /// Returns true if width is considered a small phone.
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < breakpointSmall;

  /// Returns true if width is medium phone (360–480).
  static bool isMediumPhone(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= breakpointSmall && w < breakpointMedium;
  }

  /// Returns true if width is large phone or tablet.
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= breakpointLarge;

  /// Returns true if in landscape orientation.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Get responsive scale factor for sizing.
  static double scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < breakpointSmall) return smallScreenScale;
    if (w < breakpointMedium) return mediumScreenScale;
    return largeScreenScale;
  }

  /// Responsive horizontal padding (content margins).
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < breakpointSmall) return 12;
    if (w < breakpointMedium) return 16;
    if (w < breakpointLarge) return 20;
    return 24;
  }

  /// Responsive vertical spacing.
  static double verticalSpacing(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < breakpointSmall) return 8;
    if (w < breakpointMedium) return 12;
    return 16;
  }

  /// Responsive font size (base size scaled).
  static double fontSize(BuildContext context, double base) {
    return base * scale(context);
  }

  /// Responsive icon size (minimum 24 for readability).
  static double iconSize(BuildContext context, {double base = 24}) {
    final s = base * scale(context);
    return s.clamp(22.0, 32.0);
  }

  /// Responsive button height (min 48dp for touch).
  static double buttonHeight(BuildContext context, {double base = 48}) {
    final s = base * scale(context);
    return s.clamp(minTouchTarget, 56.0);
  }

  /// Responsive value: returns [small] if small screen, [medium] if medium, else [large].
  static T value<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < breakpointSmall) return small;
    if (w < breakpointLarge) return (medium ?? small);
    return (large ?? medium ?? small);
  }

  /// Max content width for tablets (centered layout).
  static double? maxContentWidth(BuildContext context) {
    if (!isLargeScreen(context)) return null;
    final w = MediaQuery.sizeOf(context).width;
    return w > breakpointXLarge ? 600 : w * 0.85;
  }

  /// EdgeInsets for horizontal padding.
  static EdgeInsets horizontalPaddingInsets(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: horizontalPadding(context));

  /// EdgeInsets for all sides with responsive values.
  static EdgeInsets padding(BuildContext context, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final h = horizontalPadding(context);
    final v = verticalSpacing(context);
    return EdgeInsets.fromLTRB(
      left ?? h,
      top ?? v,
      right ?? h,
      bottom ?? v,
    );
  }
}
