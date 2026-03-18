import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/connectivity_service.dart';
import 'package:moustra/services/clients/api_exceptions.dart';

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
      return handler.next(options);
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
