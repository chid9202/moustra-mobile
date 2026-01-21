import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:moustra/config/env.dart';
import 'package:moustra/services/secure_store.dart';
import 'package:moustra/stores/auth_store.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'dart:io' show Platform;

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
      print('[AuthService] Error parsing ID token: $e');
      return AppUserProfile();
    }
  }
}

class AuthService {
  AppCredentials? _credentials;
  final local_auth.LocalAuthentication _localAuth =
      local_auth.LocalAuthentication();
  late final Auth0 _auth0;

  AuthService() {
    _auth0 = Auth0(Env.auth0Domain, Env.auth0ClientId);
  }

  bool get isLoggedIn => _credentials != null;
  AppUserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;
  AppCredentials? get credentials => _credentials;

  Future<void> init() async {
    // Check for stored tokens but don't auto-login
    // Biometric unlock will be required for security
    final hasRefreshToken = await SecureStore.hasRefreshToken();
    if (hasRefreshToken) {
      // Tokens exist but we'll require biometric unlock
      // Don't set _credentials here - unlockWithBiometrics() will handle it
    }
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
        print(
          '[AuthService] WARNING: Refresh token not available. Biometric unlock will not work. '
          'Check Auth0 settings and offline_access scope.',
        );
      }

      await SecureStore.saveAccessToken(creds.accessToken);
      await SecureStore.saveIdToken(creds.idToken);
      await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

      authState.value = isLoggedIn;
      return true;
    } catch (e) {
      print('[AuthService] Social login error: $e');
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
      print('[AuthService] Sign up error: $e');
      rethrow;
    }
  }

  /// Login with email and password using ROPG flow
  /// Returns true on success, throws exception on failure
  Future<bool> loginWithPassword(String email, String password) async {
    try {
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body);
        final creds = AppCredentials.fromTokenResponse(tokenData);

        _credentials = creds;

        // Store tokens securely
        if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
          await SecureStore.saveRefreshToken(creds.refreshToken!);
        } else {
          print(
            '[AuthService] WARNING: Refresh token not available. Biometric unlock will not work. '
            'Check Auth0 settings and offline_access scope.',
          );
        }

        await SecureStore.saveAccessToken(creds.accessToken);
        await SecureStore.saveIdToken(creds.idToken);
        await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

        authState.value = isLoggedIn;
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
      print('[AuthService] Login error: $e');
      rethrow;
    }
  }

  /// Logout - clears all stored credentials
  Future<void> logout() async {
    try {
      await SecureStore.clearAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
    _credentials = null;
    authState.value = false;
  }

  Future<void> clearAll() async {
    try {
      await SecureStore.clearAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
    _credentials = null;
    authState.value = false;
  }

  /// Check if device supports biometrics and if biometrics are enrolled
  Future<bool> canUseBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty &&
          (availableBiometrics.contains(local_auth.BiometricType.face) ||
              availableBiometrics.contains(
                local_auth.BiometricType.fingerprint,
              ) ||
              availableBiometrics.contains(local_auth.BiometricType.strong) ||
              availableBiometrics.contains(local_auth.BiometricType.weak));
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  /// Unlock stored credentials using biometric authentication
  /// Returns AppCredentials on success, null on failure/cancel
  Future<AppCredentials?> unlockWithBiometrics() async {
    try {
      // Check if biometrics are available
      if (!await canUseBiometrics()) {
        return null;
      }

      // Check if refresh token exists
      if (!await SecureStore.hasRefreshToken()) {
        return null;
      }

      // Determine biometric message based on platform
      String reason;
      if (Platform.isIOS) {
        reason = 'Authenticate with Face ID to unlock your account';
      } else {
        reason = 'Authenticate with biometrics to unlock your account';
      }

      // Show biometric prompt
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
      );

      if (!authenticated) {
        // User cancelled or failed authentication
        return null;
      }

      // Biometric authentication successful, refresh tokens
      return await _refreshTokens();
    } catch (e) {
      // Handle any authentication errors (user cancelled, failed, etc.)
      print('[AuthService] Biometric unlock error: $e');
      return null;
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
        print('[AuthService] Token refresh failed: ${response.body}');
        await SecureStore.clearAll();
        return null;
      }
    } catch (e) {
      print('[AuthService] Token refresh error: $e');
      // Clear tokens on error to force full login
      await SecureStore.clearAll();
      return null;
    }
  }
}

final AuthService authService = AuthService();
