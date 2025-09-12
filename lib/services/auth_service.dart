import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:moustra/config/auth0.dart';
import 'package:moustra/app/router.dart';

class AuthService {
  Credentials? _credentials;
  CredentialsManager? _credentialsManager;

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;

  Future<void> init() async {
    _credentialsManager = auth0.credentialsManager;
    print('auth init(1) start ------>');

    try {
      final has = await _credentialsManager!.hasValidCredentials();
      print('auth init(2) hasValidCredentials=$has');

      if (has) {
        _credentials = await _credentialsManager!.credentials();
        print('auth init(3) restored ${_credentials!.user.email}');
      } else {
        _credentials = null; // first run / logged out
        print('auth init(3) no stored credentials');
      }
    } catch (e) {
      // Treat as logged-out; the "no credentials" case is expected on first run
      _credentials = null;
      print('auth init(3) error while restoring: $e');
    }

    authState.value = isLoggedIn; // or notifyListeners()
    print('auth init(4) isLoggedIn=$isLoggedIn');
  }

  Future<Credentials?> login() async {
    final params = <String, String>{'scope': 'openid profile email'};
    if (auth0Audience.isNotEmpty) params['audience'] = auth0Audience;
    if (auth0Connection.isNotEmpty) {
      params['connection'] = auth0Connection;
      params['prompt'] = 'login';
    }
    print('login 1 ------> $params');

    final credentials = await auth0
        .webAuthentication(scheme: auth0Scheme)
        .login(parameters: params);
    print('login 2 ------> $credentials');
    _credentials = credentials;
    if (_credentialsManager != null) {
      await _credentialsManager!.storeCredentials(credentials);
    }
    authState.value = isLoggedIn;
    return _credentials;
  }

  Future<void> logout() async {
    print('logout start ------>');
    await auth0
        .webAuthentication(scheme: auth0Scheme)
        .logout(
          // returnTo: 'moustra://login-dev.moustra.com/logout',
          // returnTo:
          //     'moustra://login-dev.moustra.com/android/com.moustra.app.dev/callback',
          // useHTTPS: true,
        );
    // .logout(returnTo: auth0LogoutReturnTo, useHTTPS: true);
    print('logout 2 ------>');
    _credentialsManager!.clearCredentials();
    _credentials = null;
    print('logout 3 ------> $auth0LogoutReturnTo');
    authState.value = false;
    print('logout end ------> $_credentials');
  }
}

final AuthService authService = AuthService();
