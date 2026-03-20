import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moustra/app/mui_color.dart';
import 'package:moustra/config/constants.dart';

// ---- Typography ----

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  final base = GoogleFonts.ibmPlexSansTextTheme();
  final defaultColor = colorScheme.onSurface;

  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: defaultColor,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: defaultColor,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: defaultColor,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: defaultColor,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: defaultColor,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    ),
  );
}

// ---- Component Themes ----

ThemeData _applyComponentThemes(ThemeData base) {
  final cs = base.colorScheme;
  final textTheme = _buildTextTheme(cs);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory,
    highlightColor: brand50.withAlpha(77), // ~30% opacity

    // Shape
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        borderSide: BorderSide(color: cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      labelStyle: textTheme.bodySmall?.copyWith(color: neutral600),
      hintStyle: textTheme.bodyMedium?.copyWith(color: neutral500),
      floatingLabelStyle: textTheme.bodySmall?.copyWith(color: cs.primary),
    ),

    // Chip
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
      ),
      side: BorderSide(color: cs.outlineVariant),
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),

    // Filled Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        side: BorderSide(color: cs.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusDialog),
      ),
      elevation: 4,
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: neutral900,
        borderRadius: BorderRadius.circular(AppConstants.radiusTooltip),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
    ),

    // Popup Menu
    popupMenuTheme: PopupMenuThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    // TabBar
    tabBarTheme: TabBarThemeData(
      labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      unselectedLabelStyle: textTheme.titleSmall,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: cs.primary),
      ),
    ),
  );
}

// ---- Public Themes ----

final ThemeData appTheme = _applyComponentThemes(lightTheme);

final ThemeData appDarkTheme = _applyComponentThemes(darkTheme);
