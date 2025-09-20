import 'package:flutter/material.dart';

/// Extra MUI-like roles that aren't in Flutter's ColorScheme.
@immutable
class MUIExtraColors extends ThemeExtension<MUIExtraColors> {
  final Color success;
  final Color info;
  final Color warning;

  const MUIExtraColors({
    required this.success,
    required this.info,
    required this.warning,
  });

  @override
  MUIExtraColors copyWith({Color? success, Color? info, Color? warning}) {
    return MUIExtraColors(
      success: success ?? this.success,
      info: info ?? this.info,
      warning: warning ?? this.warning,
    );
  }

  @override
  MUIExtraColors lerp(ThemeExtension<MUIExtraColors>? other, double t) {
    if (other is! MUIExtraColors) return this;
    return MUIExtraColors(
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

// ---- MUI v5 default palette (main colors) ----
// primary:  #1976D2
// secondary:#9C27B0
// error:    #D32F2F
// warning:  #ED6C02
// info:     #0288D1
// success:  #2E7D32

const _primary = Color(0xFF1976D2);
const _secondary = Color(0xFF9C27B0);
const _error = Color(0xFFD32F2F);
const _warning = Color(0xFFED6C02);
const _info = Color(0xFF0288D1);
const _success = Color(0xFF2E7D32);

/// Light scheme approximating MUI default.
final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _primary,
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFBBDEFB), // ~blue100 for subtle containers
  onPrimaryContainer: const Color(0xFF0D47A1),

  secondary: _secondary,
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFE1BEE7), // ~purple100
  onSecondaryContainer: const Color(0xFF4A0072),

  tertiary: _info, // use "info" as tertiary hint
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFFB3E5FC),
  onTertiaryContainer: const Color(0xFF01579B),

  error: _error,
  onError: Colors.white,
  errorContainer: const Color(0xFFFFCDD2),
  onErrorContainer: const Color(0xFFB71C1C),

  surface: Colors.white,
  onSurface: const Color(0xFF1A1A1A),
  surfaceContainerHighest: const Color(0xFFF5F5F5),

  surfaceVariant: const Color(0xFFEDEDED),
  onSurfaceVariant: const Color(0xFF444444),

  outline: const Color(0xFFBDBDBD),
  outlineVariant: const Color(0xFFE0E0E0),

  shadow: Colors.black12,
  scrim: Colors.black54,

  inverseSurface: const Color(0xFF303030),
  onInverseSurface: Colors.white,

  // Not used by Material2; included for completeness.
  background: Colors.white,
  onBackground: const Color(0xFF1A1A1A),
);

/// Dark scheme tuned for contrast while keeping MUI feel.
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: const Color(0xFF90CAF9), // lighter blue for dark fg
  onPrimary: const Color(0xFF0B2A46),
  primaryContainer: const Color(0xFF1565C0),
  onPrimaryContainer: Colors.white,

  secondary: const Color(0xFFCE93D8),
  onSecondary: const Color(0xFF3E0A47),
  secondaryContainer: const Color(0xFF7B1FA2),
  onSecondaryContainer: Colors.white,

  tertiary: const Color(0xFF81D4FA), // info
  onTertiary: const Color(0xFF07364F),
  tertiaryContainer: const Color(0xFF0277BD),
  onTertiaryContainer: Colors.white,

  error: const Color(0xFFEF5350),
  onError: const Color(0xFF4A0B0B),
  errorContainer: const Color(0xFFB71C1C),
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

  background: const Color(0xFF121212),
  onBackground: Colors.white,
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  // Buttons/Chips/etc pick up from ColorScheme automatically in M3.
  extensions: const [
    MUIExtraColors(success: _success, info: _info, warning: _warning),
  ],
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  extensions: const [
    MUIExtraColors(
      success: Color(0xFFA5D6A7), // success.light-ish for dark mode
      info: Color(0xFF81D4FA),
      warning: Color(0xFFFFB74D),
    ),
  ],
);

/// Convenience getters, similar to theme.palette.* in MUI.
extension MUIX on BuildContext {
  MUIExtraColors get mui =>
      Theme.of(this).extension<MUIExtraColors>() ??
      const MUIExtraColors(success: _success, info: _info, warning: _warning);
}
