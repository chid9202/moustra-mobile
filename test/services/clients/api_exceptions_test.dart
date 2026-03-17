import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/clients/api_exceptions.dart';

void main() {
  group('ApiException', () {
    test('should store statusCode, body, and message', () {
      final e = ApiException(statusCode: 500, body: '{"error":"oops"}', message: 'Server error');
      expect(e.statusCode, 500);
      expect(e.body, '{"error":"oops"}');
      expect(e.message, 'Server error');
      expect(e.toString(), contains('500'));
    });
  });

  group('ApiTimeoutException', () {
    test('should have default message', () {
      final e = ApiTimeoutException();
      expect(e.message, 'Request timed out');
    });

    test('should accept custom message', () {
      final e = ApiTimeoutException(message: 'Upload timed out');
      expect(e.message, 'Upload timed out');
    });

    test('should be an ApiException', () {
      expect(ApiTimeoutException(), isA<ApiException>());
    });
  });

  group('ApiNetworkException', () {
    test('should have default message', () {
      final e = ApiNetworkException();
      expect(e.message, 'No network connection');
    });

    test('should be an ApiException', () {
      expect(ApiNetworkException(), isA<ApiException>());
    });
  });

  group('ApiUnauthorizedException', () {
    test('should have statusCode 401', () {
      final e = ApiUnauthorizedException();
      expect(e.statusCode, 401);
      expect(e.message, 'Unauthorized');
    });

    test('should store response body', () {
      final e = ApiUnauthorizedException(body: '{"error":"invalid token"}');
      expect(e.body, '{"error":"invalid token"}');
    });

    test('should be an ApiException', () {
      expect(ApiUnauthorizedException(), isA<ApiException>());
    });
  });
}
