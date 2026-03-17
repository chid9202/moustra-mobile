import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moustra/services/clients/retry_client.dart';

void main() {
  group('RetryClient', () {
    test('should return response on first success', () async {
      final inner = MockClient((_) async => http.Response('ok', 200));
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 200);
      expect(response.body, 'ok');
    });

    test('should retry on SocketException and succeed', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        if (callCount < 3) throw const SocketException('connection refused');
        return http.Response('ok', 200);
      });
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 200);
      expect(callCount, 3);
    });

    test('should retry on TimeoutException and succeed', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        if (callCount < 2) throw TimeoutException('timed out');
        return http.Response('ok', 200);
      });
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test('should retry on HTTP 503 and succeed', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        if (callCount < 2) return http.Response('service unavailable', 503);
        return http.Response('ok', 200);
      });
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test('should retry on HTTP 429 and succeed', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        if (callCount < 2) return http.Response('rate limited', 429);
        return http.Response('ok', 200);
      });
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test('should not retry on non-retryable status codes', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        return http.Response('not found', 404);
      });
      final client = RetryClient(inner, maxRetries: 3, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 404);
      expect(callCount, 1);
    });

    test('should throw after max retries on SocketException', () async {
      final inner = MockClient((_) async {
        throw const SocketException('connection refused');
      });
      final client = RetryClient(inner, maxRetries: 2, baseDelay: Duration.zero);

      await expectLater(
        () => client.get(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should return 503 response after max retries exhausted', () async {
      var callCount = 0;
      final inner = MockClient((_) async {
        callCount++;
        return http.Response('service unavailable', 503);
      });
      final client = RetryClient(inner, maxRetries: 2, baseDelay: Duration.zero);

      final response = await client.get(Uri.parse('https://example.com'));
      expect(response.statusCode, 503);
      expect(callCount, 3); // initial + 2 retries
    });
  });
}
