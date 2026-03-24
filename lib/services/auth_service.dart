import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:moustra/config/env.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/services/log_service.dart';
import 'package:moustra/services/secure_store.dart';
import 'package:moustra/stores/auth_store.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class AppCredentials {
  final String accessToken;
  final String idToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final AppUserProfile? user;

  AppCredentials({
    required this.accessToken,
    required this.idToken,
    this.refreshToken,
    required this.expiresAt,
    this.user,
  });

  factory AppCredentials.fromTokenResponse(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    AppUserProfile? user;
    if (json['id_token'] != null) {
      user = AppUserProfile.fromIdToken(json['id_token'] as String);
    }

    return AppCredentials(
      accessToken: json['access_token'] as String,
      idToken: json['id_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresAt: expiresAt,
      user: user,
    );
  }
}

/// User profile parsed from ID token
class AppUserProfile {
  final String? email;
  final String? givenName;
  final String? familyName;
  final String? name;
  final String? picture;
  final String? sub;

  AppUserProfile({
    this.email,
    this.givenName,
    this.familyName,
    this.name,
    this.picture,
    this.sub,
  });

  factory AppUserProfile.fromIdToken(String idToken) {
    try {
      // Decode JWT payload (middle part)
      final parts = idToken.split('.');
      if (parts.length != 3) {
        return AppUserProfile();
      }

      // Add padding if needed for base64 decoding
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      return AppUserProfile(
        email: claims['email'] as String?,
        givenName: claims['given_name'] as String?,
        familyName: claims['family_name'] as String?,
        name: claims['name'] as String?,
        picture: claims['picture'] as String?,
        sub: claims['sub'] as String?,
      );
    } catch (e) {
      log.w('[AuthService] Error parsing ID token: $e');
      return AppUserProfile();
    }
  }
}

class AuthService {
  AppCredentials? _credentials;
  late final Auth0 _auth0;

  /// Lock to prevent concurrent token refreshes.
  Future<AppCredentials?>? _refreshLock;

  AuthService() {
    _auth0 = Auth0(Env.auth0Domain, Env.auth0ClientId);
  }

  bool get isLoggedIn => _credentials != null;
  AppUserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;
  AppCredentials? get credentials => _credentials;

  Future<void> init() async {
    // Attempt silent token refresh using stored refresh token
    debugPrint('[AuthService.init] Checking for refresh token...');
    final hasRefreshToken = await SecureStore.hasRefreshToken();
    debugPrint('[AuthService.init] hasRefreshToken=$hasRefreshToken');
    if (hasRefreshToken) {
      debugPrint('[AuthService.init] Attempting token refresh...');
      final creds = await _refreshTokens();
      debugPrint('[AuthService.init] refreshTokens result: ${creds != null ? "SUCCESS" : "FAILED"}');
      if (creds != null) {
        // Session restored silently
        debugPrint('[AuthService.init] Session restored silently!');
        return;
      }
    }
    // No refresh token or refresh failed — require login
    debugPrint('[AuthService.init] No session to restore, showing login');
    _credentials = null;
    authState.value = false;
  }

  /// Login with social provider (Google or Microsoft) using webAuthentication
  /// Returns true on success, throws exception on failure
  Future<bool> loginWithSocial(String connection) async {
    try {
      final credentials = await _auth0
          .webAuthentication(scheme: Env.auth0Scheme)
          .login(
            parameters: {
              'connection': connection,
              'audience': Env.auth0Audience,
              'scope': 'openid profile email offline_access',
            },
          );

      // Convert auth0_flutter credentials to AppCredentials
      // Use default expiration of 3600 seconds (1 hour) if not available
      final expiresAt = DateTime.now().add(const Duration(seconds: 3600));

      final idToken = credentials.idToken;
      final user = idToken.isNotEmpty
          ? AppUserProfile.fromIdToken(idToken)
          : null;

      final creds = AppCredentials(
        accessToken: credentials.accessToken,
        idToken: idToken,
        refreshToken: credentials.refreshToken,
        expiresAt: expiresAt,
        user: user,
      );

      _credentials = creds;

      // Store tokens securely
      if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
        await SecureStore.saveRefreshToken(creds.refreshToken!);
      } else {
        log.w(
          'Refresh token not available. Biometric unlock will not work. '
          'Check Auth0 settings and offline_access scope.',
          tag: 'Auth',
        );
      }

      await SecureStore.saveAccessToken(creds.accessToken);
      await SecureStore.saveIdToken(creds.idToken);
      await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

      authState.value = true;
      return true;
    } catch (e) {
      log.w('[AuthService] Social login error: $e');
      // Convert auth0_flutter exceptions to user-friendly messages
      String errorMessage = e.toString();
      if (errorMessage.contains('user_cancelled') ||
          errorMessage.contains('User cancelled')) {
        throw Exception('Login cancelled');
      } else if (errorMessage.contains('network')) {
        throw Exception('Network error. Please check your connection.');
      } else if (errorMessage.contains('access_denied')) {
        throw Exception('Access denied. Please try again.');
      }
      rethrow;
    }
  }

  /// Sign up with email and password, then auto-login
  /// Returns true on success, throws exception on failure
  Future<bool> signUpWithPassword(String email, String password) async {
    try {
      // 1. Create user via /dbconnections/signup
      final signupResponse = await http.post(
        Uri.parse('https://${Env.auth0Domain}/dbconnections/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_id': Env.auth0ClientId,
          'email': email,
          'password': password,
          'connection': Env.auth0Connection,
        }),
      );
      if (signupResponse.statusCode != 200) {
        // Parse error response
        final Map<String, dynamic> errorData = jsonDecode(signupResponse.body);
        final errorCode = errorData['code']?.toString() ?? '';

        // Map Auth0 error codes to user-friendly messages
        if (errorCode == 'user_exists') {
          throw Exception('An account with this email already exists');
        } else if (errorCode == 'invalid_password' ||
            errorCode == 'password_strength_error') {
          // Use the pre-formatted policy string from Auth0
          final policy = errorData['policy'] as String?;
          if (policy != null && policy.isNotEmpty) {
            throw Exception('Password requirements:\n$policy');
          }
          throw Exception(
            errorData['message'] as String? ?? 'Password is too weak',
          );
        } else if (errorCode == 'invalid_signup') {
          throw Exception('Sign up is not available. Please contact support.');
        }

        // Generic error handling
        String errorDescription = 'Sign up failed';
        final desc = errorData['description'];
        if (desc is String) {
          errorDescription = desc;
        } else if (errorData['message'] is String) {
          errorDescription = errorData['message'] as String;
        } else if (errorData['error'] is String) {
          errorDescription = errorData['error'] as String;
        }
        throw Exception(errorDescription);
      }

      // 2. Auto-login after successful signup
      return await loginWithPassword(email, password);
    } catch (e) {
      log.w('[AuthService] Sign up error: $e');
      rethrow;
    }
  }

  /// Login with email and password using ROPG flow
  /// Returns true on success, throws exception on failure
  Future<bool> loginWithPassword(String email, String password) async {
    try {
      debugPrint('[AuthService] loginWithPassword called for $email');
      debugPrint('[AuthService] Posting to https://${Env.auth0Domain}/oauth/token');
      final response = await http.post(
        Uri.parse('https://${Env.auth0Domain}/oauth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
          'client_id': Env.auth0ClientId,
          'username': email,
          'password': password,
          'audience': Env.auth0Audience,
          'scope': 'openid profile email offline_access',
          'realm': Env.auth0Connection,
        }),
      );
      debugPrint('[AuthService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body);
        final creds = AppCredentials.fromTokenResponse(tokenData);

        _credentials = creds;

        // Store tokens securely
        if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
          await SecureStore.saveRefreshToken(creds.refreshToken!);
        } else {
          log.w(
            'Refresh token not available. Biometric unlock will not work. '
            'Check Auth0 settings and offline_access scope.',
            tag: 'Auth',
          );
        }

        await SecureStore.saveAccessToken(creds.accessToken);
        await SecureStore.saveIdToken(creds.idToken);
        await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

        authState.value = true;
        return true;
      } else {
        // Parse error response
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorDescription =
            errorData['error_description'] as String? ??
            errorData['error'] as String? ??
            'Login failed';
        throw Exception(errorDescription);
      }
    } catch (e) {
      log.w('[AuthService] Login error: $e');
      rethrow;
    }
  }

  /// Logout - clears all stored credentials
  Future<void> logout() async {
    try {
      await SecureStore.clearAll();
    } catch (e) {
      log.e('Error clearing secure storage: $e', tag: 'Auth');
    }
    _credentials = null;
    authState.value = false;
    // Clear error context to prevent stale user data in error reports
    errorContextService.clear();
    // Clear table settings cache
    clearTableSettingStore();
  }

  Future<void> clearAll() async {
    try {
      await SecureStore.clearAll();
    } catch (e) {
      log.e('Error clearing secure storage: $e', tag: 'Auth');
    }
    _credentials = null;
    authState.value = false;
    // Clear error context to prevent stale user data in error reports
    errorContextService.clear();
  }

  /// Public refresh that coalesces concurrent callers.
  /// Returns non-null credentials on success, null on failure (user must re-login).
  Future<AppCredentials?> refreshTokensIfNeeded() async {
    // If a refresh is already in-flight, piggyback on it.
    if (_refreshLock != null) return _refreshLock!;

    _refreshLock = _refreshTokens();
    try {
      return await _refreshLock!;
    } finally {
      _refreshLock = null;
    }
  }

  /// Refresh tokens using stored refresh token
  Future<AppCredentials?> _refreshTokens() async {
    try {
      final refreshToken = await SecureStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        // No refresh token, clear storage and force full login
        await SecureStore.clearAll();
        return null;
      }

      // Call Auth0 token endpoint with refresh_token grant
      final response = await http.post(
        Uri.parse('https://${Env.auth0Domain}/oauth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grant_type': 'refresh_token',
          'client_id': Env.auth0ClientId,
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body);
        final creds = AppCredentials.fromTokenResponse(tokenData);

        _credentials = creds;

        // Update stored tokens (refresh token rotation may provide new token)
        if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
          await SecureStore.saveRefreshToken(creds.refreshToken!);
        }
        await SecureStore.saveAccessToken(creds.accessToken);
        await SecureStore.saveIdToken(creds.idToken);
        await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

        authState.value = true;
        return _credentials;
      } else {
        // Refresh failed, clear tokens
        log.w('[AuthService] Token refresh failed: ${response.body}');
        await SecureStore.clearAll();
        return null;
      }
    } catch (e) {
      log.w('[AuthService] Token refresh error: $e');
      // Clear tokens on error to force full login
      await SecureStore.clearAll();
      return null;
    }
  }
}

final AuthService authService = AuthService();
