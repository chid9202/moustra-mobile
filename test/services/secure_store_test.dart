import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:moustra/services/secure_store.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('SecureStore Tests', () {
    test('hasRefreshToken returns false when no token exists', () async {
      // This test requires actual secure storage
      // In a real unit test, we would mock FlutterSecureStorage
      // For now, this is a placeholder test structure

      // Clear any existing tokens
      await SecureStore.clearAll();

      // Check that no refresh token exists
      final hasToken = await SecureStore.hasRefreshToken();
      expect(hasToken, isFalse);
    });

    test('saveRefreshToken and getRefreshToken work correctly', () async {
      const testToken = 'test_refresh_token_123';

      // Save token
      await SecureStore.saveRefreshToken(testToken);

      // Retrieve token
      final retrievedToken = await SecureStore.getRefreshToken();
      expect(retrievedToken, equals(testToken));

      // Verify hasRefreshToken returns true
      final hasToken = await SecureStore.hasRefreshToken();
      expect(hasToken, isTrue);

      // Clean up
      await SecureStore.clearAll();
    });

    test('clearAll removes all stored tokens', () async {
      // Store tokens
      await SecureStore.saveRefreshToken('test_refresh');
      await SecureStore.saveAccessToken('test_access');

      // Verify they exist
      expect(await SecureStore.hasRefreshToken(), isTrue);
      expect(await SecureStore.getAccessToken(), isNotNull);

      // Clear all
      await SecureStore.clearAll();

      // Verify they're gone
      expect(await SecureStore.hasRefreshToken(), isFalse);
      expect(await SecureStore.getAccessToken(), isNull);
    });
  });
}
