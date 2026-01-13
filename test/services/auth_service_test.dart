import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/services/auth_service.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist or can't be loaded, initialize with empty values
      // Env class will use fallback values
      dotenv.env.clear();
    }
  });

  group('AppCredentials', () {
    test('should parse token response correctly', () {
      // Arrange
      final tokenResponse = {
        'access_token': 'test-access-token',
        'id_token': _createTestIdToken(),
        'refresh_token': 'test-refresh-token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      };

      // Act
      final credentials = AppCredentials.fromTokenResponse(tokenResponse);

      // Assert
      expect(credentials.accessToken, 'test-access-token');
      expect(credentials.refreshToken, 'test-refresh-token');
      expect(credentials.idToken, isNotEmpty);
      expect(credentials.expiresAt.isAfter(DateTime.now()), true);
    });

    test('should handle missing refresh token', () {
      // Arrange
      final tokenResponse = {
        'access_token': 'test-access-token',
        'id_token': _createTestIdToken(),
        'expires_in': 3600,
      };

      // Act
      final credentials = AppCredentials.fromTokenResponse(tokenResponse);

      // Assert
      expect(credentials.accessToken, 'test-access-token');
      expect(credentials.refreshToken, isNull);
    });
  });

  group('AppUserProfile', () {
    test('should parse user from ID token', () {
      // Arrange
      final idToken = _createTestIdToken(
        email: 'test@example.com',
        givenName: 'Test',
        familyName: 'User',
      );

      // Act
      final user = AppUserProfile.fromIdToken(idToken);

      // Assert
      expect(user.email, 'test@example.com');
      expect(user.givenName, 'Test');
      expect(user.familyName, 'User');
    });

    test('should handle invalid ID token gracefully', () {
      // Act
      final user = AppUserProfile.fromIdToken('invalid-token');

      // Assert
      expect(user.email, isNull);
      expect(user.givenName, isNull);
    });

    test('should handle malformed JWT gracefully', () {
      // Act
      final user = AppUserProfile.fromIdToken('part1.part2');

      // Assert
      expect(user.email, isNull);
    });
  });

  group('AuthService', () {
    test('should initialize with isLoggedIn false', () async {
      // Arrange
      final authService = AuthService();

      // Act
      await authService.init();

      // Assert
      expect(authService.isLoggedIn, false);
      expect(authService.user, isNull);
      expect(authService.accessToken, isNull);
    });

    test('should return null user when not logged in', () {
      // Arrange
      final authService = AuthService();

      // Assert
      expect(authService.user, isNull);
    });

    test('should return null accessToken when not logged in', () {
      // Arrange
      final authService = AuthService();

      // Assert
      expect(authService.accessToken, isNull);
    });
  });
}

/// Creates a test ID token with the given claims
String _createTestIdToken({
  String? email,
  String? givenName,
  String? familyName,
  String? name,
  String? sub,
}) {
  final header = {'alg': 'HS256', 'typ': 'JWT'};
  final payload = {
    if (email != null) 'email': email,
    if (givenName != null) 'given_name': givenName,
    if (familyName != null) 'family_name': familyName,
    if (name != null) 'name': name,
    if (sub != null) 'sub': sub,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000,
  };

  final headerB64 = base64Url.encode(utf8.encode(jsonEncode(header)));
  final payloadB64 = base64Url.encode(utf8.encode(jsonEncode(payload)));
  final signature = 'test-signature';

  return '$headerB64.$payloadB64.$signature';
}
