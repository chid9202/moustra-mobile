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

  Future<void> init() async {
    _credentialsManager = auth0.credentialsManager;

    try {
      final has = await _credentialsManager!.hasValidCredentials();

      if (has) {
        _credentials = await _credentialsManager!.credentials();
      } else {
        _credentials = null; // first run / logged out
      }
    } catch (e) {
      // Treat as logged-out; the "no credentials" case is expected on first run
      _credentials = null;
    }

    authState.value = isLoggedIn; // or notifyListeners()
  }

  Future<Credentials?> login() async {
    final params = <String, String>{'scope': 'openid profile email'};
    params['audience'] = Env.auth0Audience;
    params['connection'] = Env.auth0Connection;
    params['prompt'] = 'login';

    final credentials = await auth0
        .webAuthentication(scheme: Env.auth0Scheme)
        .login(parameters: params);
    print('credentials $credentials');
    _credentials = credentials;
    if (_credentialsManager != null) {
      await _credentialsManager!.storeCredentials(credentials);
    }
    authState.value = isLoggedIn;
    return _credentials;
  }

  Future<void> logout() async {
    await auth0.webAuthentication(scheme: Env.auth0Scheme).logout();
    _credentialsManager!.clearCredentials();
    _credentials = null;
    authState.value = false;
  }
}

final AuthService authService = AuthService();
