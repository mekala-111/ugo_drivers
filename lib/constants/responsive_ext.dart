import 'package:flutter/material.dart';

import 'device_type.dart';
import 'responsive.dart';

/// Extension on [BuildContext] for convenient responsive helpers.
/// Usage: context.rW(20), context.rH(100), context.rF(16), context.spacing(2).
extension ResponsiveContext on BuildContext {
  /// Responsive width: scales value by screen width.
  double rW(double value) => Responsive.responsiveWidth(this, value);

  /// Responsive height: scales value by screen height.
  double rH(double value) => Responsive.responsiveHeight(this, value);

  /// Responsive font size: scales and caps per device.
  double rF(double value) => Responsive.responsiveFontSize(this, value);

  /// Responsive spacing: scale 1≈8, 2≈16, 3≈24, 4≈32.
  double rS([int scale = 1]) => Responsive.spacing(this, scale: scale);

  /// Responsive horizontal padding.
  double rHPad() => Responsive.horizontalPadding(this);

  /// Responsive vertical spacing.
  double rVSpace() => Responsive.verticalSpacing(this);

  /// Device type for layout adaptation.
  DeviceType get deviceType => Responsive.getDeviceType(this);

  /// True if tablet (7" or 10").
  bool get isTablet => Responsive.isLargeScreen(this);

  /// True if landscape.
  bool get isLandscape => Responsive.isLandscape(this);
}
