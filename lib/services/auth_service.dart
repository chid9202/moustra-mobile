import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:moustra/config/auth0.dart';
import 'package:moustra/config/env.dart';
import 'package:moustra/services/secure_store.dart';
import 'package:moustra/stores/auth_store.dart';
import 'dart:io' show Platform;

class AuthService {
  Credentials? _credentials;
  CredentialsManager? _credentialsManager;
  final local_auth.LocalAuthentication _localAuth =
      local_auth.LocalAuthentication();

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;
  Credentials? get credentials => _credentials;

  String get _logoutUrl => '${Env.auth0Scheme}://${Env.auth0Domain}/logout';

  // Note: True passwordless Face ID is possible via Auth0 Universal Login with WebAuthn.
  // This implementation uses biometrics as an unlock mechanism for stored credentials.

  Future<void> init() async {
    _credentialsManager = auth0.credentialsManager;
    // Check for stored refresh token but don't auto-refresh on init
    // Biometric unlock will be required for security
    final hasRefreshToken = await SecureStore.hasRefreshToken();
    if (hasRefreshToken) {
      // Optionally check if credentialsManager has valid credentials
      // but we'll require biometric unlock for security
      try {
        final hasValidCreds = await _credentialsManager?.hasValidCredentials();
        if (hasValidCreds == true) {
          // Credentials exist but we'll require biometric unlock
          // Don't set _credentials here - unlockWithBiometrics() will handle it
        }
      } catch (e) {
        // Ignore errors, will require full login
      }
    }
    _credentials = null;
    authState.value = false;
  }

  Future<Credentials?> login() async {
    try {
      final creds = await auth0
          .webAuthentication(scheme: Env.auth0Scheme)
          .login(
            parameters: {
              'scope': 'openid profile email offline_access',
              if (Env.auth0Audience.isNotEmpty) 'audience': Env.auth0Audience,
              if (Env.auth0Connection.isNotEmpty)
                'connection': Env.auth0Connection,
            },
          );

      _credentials = creds;

      // Store credentials first
      await _credentialsManager?.storeCredentials(creds);

      // Store refresh token securely
      String? refreshTokenToStore;

      // First, try to get from the Credentials object directly
      if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
        refreshTokenToStore = creds.refreshToken!;
      } else {
        // Wait a brief moment for CredentialsManager to finish storing
        await Future.delayed(const Duration(milliseconds: 100));

        // Try to get refresh token from credentials manager's stored credentials
        // The refresh token might only be stored internally by CredentialsManager
        try {
          final storedCreds = await _credentialsManager?.credentials();
          if (storedCreds?.refreshToken != null &&
              storedCreds!.refreshToken!.isNotEmpty) {
            refreshTokenToStore = storedCreds.refreshToken!;
          } else {
            // Last resort: try to inspect the credentials object more deeply
            // Some SDKs store refresh token in a map representation
            try {
              final credsMap = creds.toMap();
              if (credsMap.containsKey('refreshToken')) {
                final tokenValue = credsMap['refreshToken'];
                if (tokenValue is String && tokenValue.isNotEmpty) {
                  refreshTokenToStore = tokenValue;
                } else if (tokenValue != null) {
                  refreshTokenToStore = tokenValue.toString();
                }
              }
            } catch (e) {
              print('[Face Login] Error extracting refresh token: $e');
            }
          }
        } catch (e) {
          print('[Face Login] Error getting stored credentials: $e');
        }
      }

      if (refreshTokenToStore != null && refreshTokenToStore.isNotEmpty) {
        await SecureStore.saveRefreshToken(refreshTokenToStore);
      } else {
        print(
          '[Face Login] WARNING: Refresh token not available. Biometric unlock will not work. '
          'Check Auth0 settings and offline_access scope.',
        );
      }

      // Also store other tokens for reference
      await SecureStore.saveAccessToken(creds.accessToken);
      await SecureStore.saveIdToken(creds.idToken);
      await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

      authState.value = isLoggedIn;
      return _credentials;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await auth0
          .webAuthentication(scheme: Env.auth0Scheme)
          .logout(returnTo: _logoutUrl);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      try {
        await _credentialsManager?.clearCredentials();
      } catch (e) {
        print('Error clearing credentials: $e');
      }
      try {
        await SecureStore.clearAll();
      } catch (e) {
        print('Error clearing secure storage: $e');
      }
      _credentials = null;
      authState.value = false;
    }
  }

  Future<void> clearAll() async {
    try {
      await _credentialsManager?.clearCredentials();
    } catch (e) {
      print('Error clearing credentials: $e');
    }
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
  /// Returns Credentials on success, null on failure/cancel
  Future<Credentials?> unlockWithBiometrics() async {
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
        options: const local_auth.AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        // User cancelled or failed authentication
        return null;
      }

      // Biometric authentication successful, refresh tokens
      return await _refreshTokens();
    } catch (e) {
      // Handle any authentication errors (user cancelled, failed, etc.)
      print('[Face Login] Biometric unlock error: $e');
      return null;
    }
  }

  /// Refresh tokens using stored refresh token
  /// Assumes Auth0 tenant has Refresh Token Rotation enabled
  Future<Credentials?> _refreshTokens() async {
    try {
      final refreshToken = await SecureStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        // No refresh token, clear storage and force full login
        await SecureStore.clearAll();
        await _credentialsManager?.clearCredentials();
        return null;
      }

      // Use Auth0 credentials manager to refresh
      // This handles token refresh and rotation automatically
      final hasValidCreds = await _credentialsManager?.hasValidCredentials();
      if (hasValidCreds == true) {
        // Get refreshed credentials
        final creds = await _credentialsManager?.credentials();
        if (creds != null) {
          _credentials = creds;

          // Update stored tokens
          if (creds.refreshToken != null && creds.refreshToken!.isNotEmpty) {
            await SecureStore.saveRefreshToken(creds.refreshToken!);
          }
          await SecureStore.saveAccessToken(creds.accessToken);
          await SecureStore.saveIdToken(creds.idToken);
          await SecureStore.saveExpiresAt(creds.expiresAt.toIso8601String());

          authState.value = true;
          return _credentials;
        }
      }

      // If credentials manager doesn't have valid credentials,
      // we need to manually refresh using the refresh token
      // This would require making an HTTP call to Auth0's token endpoint
      // For now, return null to force full login if refresh fails

      // Clear invalid tokens
      await SecureStore.clearAll();
      await _credentialsManager?.clearCredentials();
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      // Clear tokens on error to force full login
      await SecureStore.clearAll();
      await _credentialsManager?.clearCredentials();
      return null;
    }
  }
}

final AuthService authService = AuthService();
