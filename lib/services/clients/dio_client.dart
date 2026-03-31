import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/connectivity_service.dart';
import 'package:moustra/services/clients/api_exceptions.dart';

const int _kMaxLoggedBodyLength = 800;

/// Resolves [RequestOptions] to a single absolute `https://…/path?query` string
/// (Dio [RequestOptions.uri] is not always absolute before send).
String _fullAbsoluteRequestUrl(RequestOptions options) {
  final fromUri = options.uri.toString();
  if (fromUri.startsWith('http://') || fromUri.startsWith('https://')) {
    return fromUri;
  }
  final base = options.baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  var path = options.path.trim();
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  if (path.isNotEmpty && !path.startsWith('/')) {
    path = '/$path';
  }
  var url = '$base$path';
  if (!url.contains('?') && options.queryParameters.isNotEmpty) {
    final q = Uri(
      queryParameters: {
        for (final e in options.queryParameters.entries)
          e.key: e.value is Iterable
              ? (e.value as Iterable)
                  .map((x) => x.toString())
                  .toList()
              : e.value.toString(),
      },
    ).query;
    url = '$url?$q';
  }
  return url;
}

// Intentional debug console output via [debugPrint] so requests show in `flutter run`,
// Xcode, and Android Studio (unlike [developer.log], which is easy to miss in the terminal).
// Do not remove during refactors or "cleanup".
void _logOutgoingRequest(RequestOptions options) {
  final fullUrl = _fullAbsoluteRequestUrl(options);
  final buf = StringBuffer()
    ..writeln('[Dio] ${options.method} $fullUrl');
  final headers = Map<String, dynamic>.from(options.headers);
  if (headers.containsKey('Authorization')) {
    headers['Authorization'] = 'Bearer <redacted>';
  }
  buf.writeln('[Dio] headers: $headers');
  final data = options.data;
  if (data != null) {
    if (data is FormData) {
      buf.writeln(
        '[Dio] body: multipart/form-data '
        '(${data.fields.length} fields, ${data.files.length} files)',
      );
    } else {
      var preview = data.toString();
      if (preview.length > _kMaxLoggedBodyLength) {
        preview = '${preview.substring(0, _kMaxLoggedBodyLength)}…';
      }
      buf.writeln('[Dio] body: $preview');
    }
  }
  debugPrint(buf.toString().trimRight());
}

/// Creates a Dio instance configured to match the existing ApiClient behavior:
/// - Bearer JWT auth from authService
/// - Self-signed cert support for localhost
/// - Connectivity check before requests
/// - Timeout and error handling
Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  // Allow self-signed certs for localhost (matches _createHttpClient in api_client.dart)
  if (_isLocalhost(ApiConfig.baseUrl)) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return host == 'localhost' || host == '127.0.0.1';
      };
      return client;
    };
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Connectivity check
      if (!connectivityService.isOnline.value) {
        // Keep: offline reject logging for the debug console (same as _logOutgoingRequest).
        if (kDebugMode) {
          debugPrint(
            '[Dio] REJECTED (offline) ${options.method} ${_fullAbsoluteRequestUrl(options)}',
          );
        }
        return handler.reject(
          DioException(
            requestOptions: options,
            error: ApiNetworkException(),
            type: DioExceptionType.connectionError,
          ),
        );
      }

      // Auth token
      final token = authService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      // Keep: request logging for the debug console (see _logOutgoingRequest).
      if (kDebugMode) {
        _logOutgoingRequest(options);
      }
      return handler.next(options);
    },
    onResponse: (response, handler) async {
      // Intercept 401 responses (validateStatus lets all codes through).
      // Try to refresh the token and retry the original request once.
      if (response.statusCode == 401) {
        final creds = await authService.refreshTokensIfNeeded();
        if (creds != null) {
          // Retry the original request with the new token.
          final opts = response.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${creds.accessToken}';
          try {
            final retryResponse = await dio.fetch(opts);
            return handler.next(retryResponse);
          } on DioException catch (e) {
            // If the retry itself fails, fall through to normal handling.
            if (e.response != null) {
              return handler.next(e.response!);
            }
            return handler.reject(e);
          }
        }
        // Refresh failed — force logout so user re-authenticates.
        await authService.logout();
      }
      return handler.next(response);
    },
    onError: (error, handler) {
      // Map timeout / connection errors to typed API exceptions
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiTimeoutException(),
              type: error.type,
            ),
          );
        case DioExceptionType.connectionError:
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiNetworkException(
                message: 'Network error: unable to connect',
              ),
              type: error.type,
            ),
          );
        default:
          break;
      }

      // Map HTTP status codes to typed exceptions
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: ApiUnauthorizedException(
              body: error.response?.data?.toString(),
            ),
            type: error.type,
          ),
        );
      }
      if (statusCode != null && statusCode >= 500) {
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: ApiException(
              statusCode: statusCode,
              body: error.response?.data?.toString(),
              message: 'Server error ($statusCode)',
            ),
            type: error.type,
          ),
        );
      }
      return handler.next(error);
    },
  ));

  return dio;
}

bool _isLocalhost(String url) {
  final uri = Uri.parse(url);
  return uri.host == 'localhost' || uri.host == '127.0.0.1';
}
