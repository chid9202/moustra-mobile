import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

/// HTTP client wrapper that retries failed requests with exponential backoff.
/// Only retries on transient errors: SocketException, TimeoutException, HTTP 429/503.
class RetryClient extends http.BaseClient {
  final http.Client _inner;
  final int maxRetries;
  final Duration baseDelay;
  final Random _random = Random();

  RetryClient(
    this._inner, {
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    http.StreamedResponse? lastResponse;
    Object? lastError;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // We need to copy the request for retries since BaseRequest can only be sent once
        final requestToSend = attempt == 0 ? request : _copyRequest(request);
        lastResponse = await _inner.send(requestToSend);

        if (!_shouldRetryStatus(lastResponse.statusCode) || attempt == maxRetries) {
          return lastResponse;
        }

        // Drain the response body before retrying
        await lastResponse.stream.drain<void>();
      } on SocketException catch (e) {
        lastError = e;
        if (attempt == maxRetries) break;
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt == maxRetries) break;
      }

      // Exponential backoff with jitter
      final delay = baseDelay * pow(2, attempt);
      final jitter = Duration(
        milliseconds: _random.nextInt(delay.inMilliseconds ~/ 2 + 1),
      );
      await Future<void>.delayed(delay + jitter);
    }

    if (lastResponse != null) return lastResponse;
    throw lastError ?? Exception('Request failed after $maxRetries retries');
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 429 || statusCode == 503;
  }

  http.Request _copyRequest(http.BaseRequest original) {
    final request = http.Request(original.method, original.url);
    request.headers.addAll(original.headers);
    if (original is http.Request) {
      request.body = original.body;
      request.encoding = original.encoding;
    }
    return request;
  }

  @override
  void close() {
    _inner.close();
  }
}
