import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:moustra/config/auth0.dart';
import 'package:moustra/config/env.dart';
import 'package:moustra/stores/auth_store.dart';

class AuthService {
  Credentials? _credentials;
  CredentialsManager? _credentialsManager;

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;
  Credentials? get credentials => _credentials;

  String get _logoutUrl => '${Env.auth0Scheme}://${Env.auth0Domain}/logout';

  Future<void> init() async {
    _credentialsManager = auth0.credentialsManager;
    // Don't auto-restore credentials to avoid network errors on startup
    // User will need to login each time the app starts
    _credentials = null;
    authState.value = false;
  }

  Future<Credentials?> login() async {
    try {
      final creds = await auth0
          .webAuthentication(scheme: Env.auth0Scheme)
          .login(
            parameters: {
              'scope': 'openid profile email',
              if (Env.auth0Audience.isNotEmpty) 'audience': Env.auth0Audience,
              if (Env.auth0Connection.isNotEmpty)
                'connection': Env.auth0Connection,
            },
          );

      _credentials = creds;
      await _credentialsManager?.storeCredentials(creds);
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
    _credentials = null;
    authState.value = false;
  }
}

final AuthService authService = AuthService();
