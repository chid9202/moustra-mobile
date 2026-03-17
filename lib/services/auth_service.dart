import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/config/auth0.dart';
import 'package:grid_view/models/login_response.dart';
import 'package:grid_view/services/api_client.dart';
import 'package:grid_view/services/session_service.dart';

class AuthService {
  Credentials? _credentials;

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;

  void restoreCredentials(Credentials credentials) {
    _credentials = credentials;
  }

  Future<LoginResponse> login() async {
    final credentials = await auth0.webAuthentication().login();
    _credentials = credentials;

    final userProfile = credentials.user;
    final response = await apiClient.postUnscoped('/auth/callback', body: {
      'email': userProfile.email,
      'firstName': userProfile.givenName ?? '',
      'lastName': userProfile.familyName ?? '',
    });

    if (response.statusCode != 200) {
      throw Exception('Auth callback failed: ${response.statusCode}');
    }

    final loginResponse =
        LoginResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    await sessionService.saveLoginResponse(loginResponse);
    ApiConfig.accountUuid = loginResponse.accountUuid;

    return loginResponse;
  }

  Future<void> logout() async {
    await auth0.webAuthentication().logout();
    _credentials = null;
    await sessionService.clearSession();
    ApiConfig.accountUuid = null;
  }
}

final AuthService authService = AuthService();
