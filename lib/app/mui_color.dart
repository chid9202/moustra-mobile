import 'package:flutter/material.dart';

/// Extra MUI-like roles that aren't in Flutter's ColorScheme.
@immutable
class MUIExtraColors extends ThemeExtension<MUIExtraColors> {
  final Color success;
  final Color info;
  final Color warning;
  final Color successBg;
  final Color successDark;
  final Color warningBg;
  final Color warningDark;
  final Color dangerBg;
  final Color dangerDark;
  final Color infoBg;
  final Color infoDark;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  const MUIExtraColors({
    required this.success,
    required this.info,
    required this.warning,
    required this.successBg,
    required this.successDark,
    required this.warningBg,
    required this.warningDark,
    required this.dangerBg,
    required this.dangerDark,
    required this.infoBg,
    required this.infoDark,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
  });

  @override
  MUIExtraColors copyWith({
    Color? success,
    Color? info,
    Color? warning,
    Color? successBg,
    Color? successDark,
    Color? warningBg,
    Color? warningDark,
    Color? dangerBg,
    Color? dangerDark,
    Color? infoBg,
    Color? infoDark,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
  }) {
    return MUIExtraColors(
      success: success ?? this.success,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      successBg: successBg ?? this.successBg,
      successDark: successDark ?? this.successDark,
      warningBg: warningBg ?? this.warningBg,
      warningDark: warningDark ?? this.warningDark,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerDark: dangerDark ?? this.dangerDark,
      infoBg: infoBg ?? this.infoBg,
      infoDark: infoDark ?? this.infoDark,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
    );
  }

  @override
  MUIExtraColors lerp(ThemeExtension<MUIExtraColors>? other, double t) {
    if (other is! MUIExtraColors) return this;
    return MUIExtraColors(
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningDark: Color.lerp(warningDark, other.warningDark, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      dangerDark: Color.lerp(dangerDark, other.dangerDark, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoDark: Color.lerp(infoDark, other.infoDark, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    );
  }
}

// ---- Moustra Brand Palette ----
const brand50 = Color(0xFFEEF8FA);
const brand100 = Color(0xFFD0EAFA);
const brand200 = Color(0xFFA8D4F5);
const brand300 = Color(0xFF7BBDEF);
const brand400 = Color(0xFF54A7E8);
const brand500 = Color(0xFF3D96E0);
const brand600 = Color(0xFF348ADC); // primary
const brand700 = Color(0xFF2A73B8);
const brand800 = Color(0xFF1F5D98);

// ---- Neutral Palette ----
const neutral50 = Color(0xFFFBFCFC);
const neutral100 = Color(0xFFF4F6F7);
const neutral200 = Color(0xFFE8EBEE);
const neutral300 = Color(0xFFDADFE4);
const neutral400 = Color(0xFFB8C0C9);
const neutral500 = Color(0xFF8C96A3);
const neutral600 = Color(0xFF6B7785);
const neutral700 = Color(0xFF4E5B6A);
const neutral800 = Color(0xFF344152);
const neutral900 = Color(0xFF072741);

// ---- Semantic Colors ----
const _success = Color(0xFF52C41A);
const _warning = Color(0xFFFAAD14);
const _danger = Color(0xFFF5222D);
const _info = Color(0xFF348ADC); // same as brand600

/// Light scheme using Moustra brand palette.
final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: brand600,
  onPrimary: Colors.white,
  primaryContainer: brand100,
  onPrimaryContainer: brand800,

  secondary: brand700,
  onSecondary: Colors.white,
  secondaryContainer: brand100,
  onSecondaryContainer: brand800,

  tertiary: _info,
  onTertiary: Colors.white,
  tertiaryContainer: brand50,
  onTertiaryContainer: brand800,

  error: _danger,
  onError: Colors.white,
  errorContainer: const Color(0xFFFFF1F0),
  onErrorContainer: const Color(0xFFA8071A),

  surface: Colors.white,
  onSurface: neutral900,
  surfaceContainerHighest: neutral100,

  surfaceVariant: neutral100,
  onSurfaceVariant: neutral700,

  outline: neutral300,
  outlineVariant: neutral200,

  shadow: Colors.black12,
  scrim: Colors.black54,

  inverseSurface: neutral900,
  onInverseSurface: Colors.white,

  // ignore: deprecated_member_use
  background: Colors.white,
  // ignore: deprecated_member_use
  onBackground: neutral900,
);

/// Dark scheme — updated semantic colors, structure mostly unchanged.
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: brand300,
  onPrimary: const Color(0xFF0B2A46),
  primaryContainer: brand700,
  onPrimaryContainer: Colors.white,

  secondary: brand400,
  onSecondary: const Color(0xFF0B2A46),
  secondaryContainer: brand700,
  onSecondaryContainer: Colors.white,

  tertiary: brand300,
  onTertiary: const Color(0xFF07364F),
  tertiaryContainer: brand700,
  onTertiaryContainer: Colors.white,

  error: const Color(0xFFFF6B6B),
  onError: const Color(0xFF4A0B0B),
  errorContainer: const Color(0xFF6E1111),
  onErrorContainer: Colors.white,

  surface: const Color(0xFF121212),
  onSurface: Colors.white,
  surfaceContainerHighest: const Color(0xFF1E1E1E),

  surfaceVariant: const Color(0xFF2A2A2A),
  onSurfaceVariant: const Color(0xFFE0E0E0),

  outline: const Color(0xFF616161),
  outlineVariant: const Color(0xFF424242),

  shadow: Colors.black,
  scrim: Colors.black87,

  inverseSurface: Colors.white,
  onInverseSurface: const Color(0xFF1A1A1A),

  // ignore: deprecated_member_use
  background: const Color(0xFF121212),
  // ignore: deprecated_member_use
  onBackground: Colors.white,
);

const _lightExtraColors = MUIExtraColors(
  success: _success,
  info: _info,
  warning: _warning,
  successBg: Color(0xFFF6FFED),
  successDark: Color(0xFF389E0D),
  warningBg: Color(0xFFFFFBE6),
  warningDark: Color(0xFFD48806),
  dangerBg: Color(0xFFFFF1F0),
  dangerDark: Color(0xFFA8071A),
  infoBg: Color(0xFFEEF8FA),
  infoDark: Color(0xFF2A73B8),
  textSecondary: neutral800,
  textTertiary: neutral700,
  textDisabled: neutral500,
);

const _darkExtraColors = MUIExtraColors(
  success: Color(0xFF73D13D),
  info: Color(0xFF69B4F0),
  warning: Color(0xFFFFD666),
  successBg: Color(0xFF162312),
  successDark: Color(0xFF95DE64),
  warningBg: Color(0xFF2B2111),
  warningDark: Color(0xFFFFC53D),
  dangerBg: Color(0xFF2A1215),
  dangerDark: Color(0xFFFF7875),
  infoBg: Color(0xFF111D2C),
  infoDark: Color(0xFF91CAFF),
  textSecondary: Color(0xFFBFBFBF),
  textTertiary: Color(0xFF8C8C8C),
  textDisabled: Color(0xFF595959),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  extensions: const [_lightExtraColors],
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  extensions: const [_darkExtraColors],
);

/// Convenience getters, similar to theme.palette.* in MUI.
extension MUIX on BuildContext {
  MUIExtraColors get mui =>
      Theme.of(this).extension<MUIExtraColors>() ?? _lightExtraColors;
}
