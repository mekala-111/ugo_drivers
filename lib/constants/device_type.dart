/// Device size categories for adaptive layouts.
/// Used to switch between single-column, two-column, and multi-pane layouts.
enum DeviceType {
  /// Mobile phones: width < 600 dp
  mobile,

  /// 7-inch tablets: 600 ≤ width < 900 dp
  tablet7,

  /// 10-inch tablets and large screens: width ≥ 900 dp
  tablet10,
}

extension DeviceTypeX on DeviceType {
  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet7 => this == DeviceType.tablet7;
  bool get isTablet10 => this == DeviceType.tablet10;
  bool get isTablet => isTablet7 || isTablet10;
}
