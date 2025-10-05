import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

import 'auth_service_test.mocks.dart';

// Testable version of AuthService that accepts dependencies
class TestableAuthService {
  Credentials? _credentials;
  final CredentialsManager credentialsManager;
  final WebAuthentication webAuthentication;

  TestableAuthService({
    required this.credentialsManager,
    required this.webAuthentication,
  });

  bool get isLoggedIn => _credentials != null;
  UserProfile? get user => _credentials?.user;
  String? get accessToken => _credentials?.accessToken;

  Future<void> init() async {
    try {
      final has = await credentialsManager.hasValidCredentials();

      if (has) {
        _credentials = await credentialsManager.credentials();
      } else {
        _credentials = null; // first run / logged out
      }
    } catch (e) {
      // Treat as logged-out; the "no credentials" case is expected on first run
      _credentials = null;
    }
  }

  Future<Credentials?> login() async {
    final params = <String, String>{'scope': 'openid profile email'};
    params['audience'] = 'test-audience';
    params['connection'] = 'test-connection';
    params['prompt'] = 'login';

    final credentials = await webAuthentication.login(parameters: params);
    _credentials = credentials;
    await credentialsManager.storeCredentials(credentials);
    return _credentials;
  }

  Future<void> logout() async {
    await webAuthentication.logout();
    credentialsManager.clearCredentials();
    _credentials = null;
  }
}

@GenerateMocks([CredentialsManager, WebAuthentication, Credentials])
void main() {
  group('AuthService Tests', () {
    late TestableAuthService authService;
    late MockCredentialsManager mockCredentialsManager;
    late MockWebAuthentication mockWebAuthentication;
    late MockCredentials mockCredentials;

    setUp(() {
      mockCredentialsManager = MockCredentialsManager();
      mockWebAuthentication = MockWebAuthentication();
      mockCredentials = MockCredentials();
      authService = TestableAuthService(
        credentialsManager: mockCredentialsManager,
        webAuthentication: mockWebAuthentication,
      );
    });

    group('isLoggedIn', () {
      test('should return false when credentials are null', () {
        // Act & Assert
        expect(authService.isLoggedIn, false);
      });

      test('should return true when credentials are not null', () async {
        // Arrange
        when(
          mockCredentialsManager.hasValidCredentials(),
        ).thenAnswer((_) async => true);
        when(
          mockCredentialsManager.credentials(),
        ).thenAnswer((_) async => mockCredentials);
        await authService.init();

        // Act & Assert
        expect(authService.isLoggedIn, true);
      });
    });

    group('user', () {
      test('should return null when credentials are null', () {
        // Act & Assert
        expect(authService.user, null);
      });

      test('should return user when credentials are not null', () async {
        // Arrange
        final mockUser = UserProfile(
          sub: 'test-sub',
          name: 'Test User',
          email: 'test@example.com',
        );
        when(mockCredentials.user).thenReturn(mockUser);
        when(
          mockCredentialsManager.hasValidCredentials(),
        ).thenAnswer((_) async => true);
        when(
          mockCredentialsManager.credentials(),
        ).thenAnswer((_) async => mockCredentials);
        await authService.init();

        // Act & Assert
        expect(authService.user, mockUser);
      });
    });

    group('accessToken', () {
      test('should return null when credentials are null', () {
        // Act & Assert
        expect(authService.accessToken, null);
      });

      test(
        'should return access token when credentials are not null',
        () async {
          // Arrange
          when(mockCredentials.accessToken).thenReturn('test-token');
          when(
            mockCredentialsManager.hasValidCredentials(),
          ).thenAnswer((_) async => true);
          when(
            mockCredentialsManager.credentials(),
          ).thenAnswer((_) async => mockCredentials);
          await authService.init();

          // Act & Assert
          expect(authService.accessToken, 'test-token');
        },
      );
    });

    group('init', () {
      test('should initialize with valid credentials', () async {
        // Arrange
        when(
          mockCredentialsManager.hasValidCredentials(),
        ).thenAnswer((_) async => true);
        when(
          mockCredentialsManager.credentials(),
        ).thenAnswer((_) async => mockCredentials);

        // Act
        await authService.init();

        // Assert
        expect(authService.isLoggedIn, true);
        verify(mockCredentialsManager.hasValidCredentials()).called(1);
        verify(mockCredentialsManager.credentials()).called(1);
      });

      test('should initialize without credentials when invalid', () async {
        // Arrange
        when(
          mockCredentialsManager.hasValidCredentials(),
        ).thenAnswer((_) async => false);

        // Act
        await authService.init();

        // Assert
        expect(authService.isLoggedIn, false);
        verify(mockCredentialsManager.hasValidCredentials()).called(1);
        verifyNever(mockCredentialsManager.credentials());
      });

      test('should handle exceptions during initialization', () async {
        // Arrange
        when(
          mockCredentialsManager.hasValidCredentials(),
        ).thenThrow(Exception('Test exception'));

        // Act
        await authService.init();

        // Assert
        expect(authService.isLoggedIn, false);
        verify(mockCredentialsManager.hasValidCredentials()).called(1);
      });
    });

    group('login', () {
      test('should perform login and store credentials', () async {
        // Arrange
        when(
          mockWebAuthentication.login(parameters: anyNamed('parameters')),
        ).thenAnswer((_) async => mockCredentials);
        when(
          mockCredentialsManager.storeCredentials(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await authService.login();

        // Assert
        expect(result, mockCredentials);
        expect(authService.isLoggedIn, true);
        verify(
          mockWebAuthentication.login(parameters: anyNamed('parameters')),
        ).called(1);
        verify(
          mockCredentialsManager.storeCredentials(mockCredentials),
        ).called(1);
      });
    });

    group('logout', () {
      test('should perform logout and clear credentials', () async {
        // Arrange
        when(mockWebAuthentication.logout()).thenAnswer((_) async {});
        when(
          mockCredentialsManager.clearCredentials(),
        ).thenAnswer((_) async => true);

        // Act
        await authService.logout();

        // Assert
        expect(authService.isLoggedIn, false);
        verify(mockWebAuthentication.logout()).called(1);
        verify(mockCredentialsManager.clearCredentials()).called(1);
      });
    });
  });
}
