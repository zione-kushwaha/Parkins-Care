import 'package:flutter/material.dart';

/// Extension on BuildContext to provide device dimension utilities
extension DeviceDimension on BuildContext {
  /// Returns true if the device is a mobile device (width < 600)
  bool get isMobile => MediaQuery.of(this).size.width < 600;

  /// Returns true if the device is a tablet (width between 600 and 900)
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 900;

  /// Returns true if the device is a desktop or web (width >= 900)
  bool get isDesktop => MediaQuery.of(this).size.width >= 900;

  /// Returns screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns responsive value based on device type
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}