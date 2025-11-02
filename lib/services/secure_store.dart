import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for authentication tokens.
/// Uses platform-specific secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).
class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyAccessToken = 'access_token';
  static const String _keyIdToken = 'id_token';
  static const String _keyExpiresAt = 'expires_at';

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      print('[SecureStore] ERROR saving refresh token: $e');
      rethrow;
    }
  }

  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Save access token securely
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Retrieve access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Save ID token securely
  static Future<void> saveIdToken(String token) async {
    await _storage.write(key: _keyIdToken, value: token);
  }

  /// Retrieve ID token
  static Future<String?> getIdToken() async {
    return await _storage.read(key: _keyIdToken);
  }

  /// Save token expiration timestamp
  static Future<void> saveExpiresAt(String expiresAt) async {
    await _storage.write(key: _keyExpiresAt, value: expiresAt);
  }

  /// Retrieve token expiration timestamp
  static Future<String?> getExpiresAt() async {
    return await _storage.read(key: _keyExpiresAt);
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    try {
      final token = await getRefreshToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('[SecureStore] Error checking refresh token: $e');
      return false;
    }
  }

  /// Clear all stored tokens
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
