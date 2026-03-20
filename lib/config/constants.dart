import 'package:flutter/material.dart';

class AppConstants {
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  static const double radiusDefault = 6;
  static const double radiusCard = 8;
  static const double radiusDialog = 10;
  static const double radiusTooltip = 4;

  static const String strainAllUuid = '00000000-0000-0000-0000-000000000000';

  /// Subtle shadow for cards and containers.
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated shadow for popovers, dropdowns, and dialogs.
  static const List<BoxShadow> shadowPopover = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
