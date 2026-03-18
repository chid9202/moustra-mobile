import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

final themeStore = ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> initThemeStore() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_themeModeKey);
  if (saved != null) {
    themeStore.value = _themeModeFromString(saved);
  }
}

Future<void> setThemeMode(ThemeMode mode) async {
  themeStore.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_themeModeKey, _themeModeToString(mode));
}

ThemeMode _themeModeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}
