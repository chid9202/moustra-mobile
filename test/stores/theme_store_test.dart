import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/stores/theme_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    themeStore.value = ThemeMode.system;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    themeStore.value = ThemeMode.system;
  });

  group('themeStore defaults', () {
    test('defaults to ThemeMode.system', () {
      expect(themeStore.value, ThemeMode.system);
    });
  });

  group('setThemeMode', () {
    test('sets theme to dark and persists', () async {
      await setThemeMode(ThemeMode.dark);
      expect(themeStore.value, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('sets theme to light and persists', () async {
      await setThemeMode(ThemeMode.light);
      expect(themeStore.value, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('sets theme to system and persists', () async {
      // First set to dark, then back to system
      await setThemeMode(ThemeMode.dark);
      await setThemeMode(ThemeMode.system);
      expect(themeStore.value, ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
    });
  });

  group('initThemeStore', () {
    test('loads saved dark theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      await initThemeStore();
      expect(themeStore.value, ThemeMode.dark);
    });

    test('loads saved light theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

      await initThemeStore();
      expect(themeStore.value, ThemeMode.light);
    });

    test('defaults to system when no saved value', () async {
      SharedPreferences.setMockInitialValues({});

      await initThemeStore();
      expect(themeStore.value, ThemeMode.system);
    });

    test('defaults to system for unknown saved value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'unknown'});

      await initThemeStore();
      expect(themeStore.value, ThemeMode.system);
    });
  });

  group('theme toggling round-trip', () {
    test('set dark, init, verify dark', () async {
      await setThemeMode(ThemeMode.dark);

      // Reset in-memory store to simulate app restart
      themeStore.value = ThemeMode.system;
      expect(themeStore.value, ThemeMode.system);

      // Re-init from SharedPreferences
      await initThemeStore();
      expect(themeStore.value, ThemeMode.dark);
    });
  });
}
