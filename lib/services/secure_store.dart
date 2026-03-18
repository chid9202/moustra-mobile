import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moustra/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage wrapper for authentication tokens.
/// Uses platform-specific secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).
/// In debug mode, falls back to SharedPreferences when Keychain is unavailable
/// (e.g. iOS simulator error -34018).
class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _debugPrefix = '_debug_secure_';

  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyAccessToken = 'access_token';
  static const String _keyIdToken = 'id_token';
  static const String _keyExpiresAt = 'expires_at';
  static const String _keySavedEmail = 'saved_email';
  static const String _keySavedPassword = 'saved_password';

  // ---------------------------------------------------------------------------
  // Private helpers with SharedPreferences fallback for debug/simulator builds
  // ---------------------------------------------------------------------------

  static Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        log.w(
          'Keychain write failed for "$key", using SharedPreferences fallback: $e',
          tag: 'SecureStore',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_debugPrefix$key', value);
      } else {
        rethrow;
      }
    }
  }

  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        log.w(
          'Keychain read failed for "$key", using SharedPreferences fallback: $e',
          tag: 'SecureStore',
        );
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('$_debugPrefix$key');
      }
      rethrow;
    }
  }

  static Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kDebugMode) {
        log.w(
          'Keychain delete failed for "$key", using SharedPreferences fallback: $e',
          tag: 'SecureStore',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('$_debugPrefix$key');
      } else {
        rethrow;
      }
    }
  }

  static Future<void> _deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        log.w(
          'Keychain deleteAll failed, using SharedPreferences fallback: $e',
          tag: 'SecureStore',
        );
        final prefs = await SharedPreferences.getInstance();
        final keys =
            prefs.getKeys().where((k) => k.startsWith(_debugPrefix)).toList();
        for (final key in keys) {
          await prefs.remove(key);
        }
      } else {
        rethrow;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _write(_keyRefreshToken, token);
    } catch (e) {
      log.e('Error saving refresh token: $e', tag: 'SecureStore');
      rethrow;
    }
  }

  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _read(_keyRefreshToken);
  }

  /// Save access token securely
  static Future<void> saveAccessToken(String token) async {
    await _write(_keyAccessToken, token);
  }

  /// Retrieve access token
  static Future<String?> getAccessToken() async {
    return await _read(_keyAccessToken);
  }

  /// Save ID token securely
  static Future<void> saveIdToken(String token) async {
    await _write(_keyIdToken, token);
  }

  /// Retrieve ID token
  static Future<String?> getIdToken() async {
    return await _read(_keyIdToken);
  }

  /// Save token expiration timestamp
  static Future<void> saveExpiresAt(String expiresAt) async {
    await _write(_keyExpiresAt, expiresAt);
  }

  /// Retrieve token expiration timestamp
  static Future<String?> getExpiresAt() async {
    return await _read(_keyExpiresAt);
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    try {
      final token = await getRefreshToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      log.e('Error checking refresh token: $e', tag: 'SecureStore');
      return false;
    }
  }

  /// Clear all stored tokens
  static Future<void> clearAll() async {
    await _deleteAll();
  }

  /// Save login credentials (email and password) for "Remember Me" feature
  static Future<void> saveLoginCredentials(
    String email,
    String password,
  ) async {
    await _write(_keySavedEmail, email);
    await _write(_keySavedPassword, password);
  }

  /// Get saved email
  static Future<String?> getSavedEmail() async {
    return await _read(_keySavedEmail);
  }

  /// Get saved password
  static Future<String?> getSavedPassword() async {
    return await _read(_keySavedPassword);
  }

  /// Clear saved login credentials
  static Future<void> clearSavedCredentials() async {
    await _delete(_keySavedEmail);
    await _delete(_keySavedPassword);
  }
}
