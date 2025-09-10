import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:grid_view/config/auth0.dart';

class AuthService {
  Credentials? _credentials;

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;

  Future<Credentials?> login() async {
    try {
      final credentials = await auth0.webAuthentication().login();
      _credentials = credentials;
      return _credentials;
    } on Exception {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication().logout();
      _credentials = null;
    } on Exception {
      rethrow;
    }
  }
}

final AuthService authService = AuthService();
