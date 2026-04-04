import 'dart:io';

import 'package:dio/dio.dart';
import 'package:moustra/services/clients/api_exceptions.dart';
import 'package:moustra/services/clients/dio_client.dart';
import 'package:moustra/stores/profile_store.dart';

/// Bridge class that mirrors [ApiClient]'s public interface but uses Dio
/// internally. Drop-in replacement for the hand-written service clients.
class DioApiClient {
  Dio? _dio;

  DioApiClient();

  /// Lazily creates the Dio instance on first use, matching the old
  /// ApiClient's lazy HTTP client pattern. This prevents test-breaking
  /// timers from being created at import time.
  Dio get dio {
    if (_dio == null) {
      _dio = createDio();
      // Allow all status codes through so callers can inspect them,
      // just like the old http-based ApiClient.
      _dio!.options.validateStatus = (status) => true;
    }
    return _dio!;
  }

  /// Build the request path, optionally prefixing with /account/{uuid}.
  String _buildPath(String path, {bool withoutAccountPrefix = false}) {
    final prefix = withoutAccountPrefix
        ? ''
        : '/account/${profileState.value?.accountUuid}';
    final addPath = path.startsWith('/') ? path : '/$path';
    return '$prefix$addPath';
  }

  /// Mirror ApiClient._processResponse: throw on 401 and >= 500.
  Response<dynamic> _processResponse(Response<dynamic> response) {
    if (response.statusCode == 401) {
      throw ApiUnauthorizedException(body: response.data?.toString());
    }
    if (response.statusCode != null && response.statusCode! >= 500) {
      throw ApiException(
        statusCode: response.statusCode,
        body: response.data?.toString(),
        message: 'Server error (${response.statusCode})',
      );
    }
    return response;
  }

  /// Wrap a Dio call with error mapping that matches ApiClient behaviour.
  Future<Response<dynamic>> _wrap(
    Future<Response<dynamic>> Function() fn,
  ) async {
    try {
      final response = await fn();
      return _processResponse(response);
    } on DioException catch (e) {
      // If the interceptor already wrapped a typed exception, re-throw it.
      if (e.error is ApiException) throw e.error!;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw ApiTimeoutException();
        case DioExceptionType.connectionError:
          throw ApiNetworkException(
            message: 'Network error: unable to connect',
          );
        default:
          throw ApiNetworkException(
            message: e.message ?? 'Network error',
          );
      }
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool withoutAccountPrefix = false,
  }) {
    final fullPath = _buildPath(
      path,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    return _wrap(() => dio.get(fullPath, queryParameters: query));
  }

  /// GET with a raw query string (for repeated parameters like filters).
  Future<Response<dynamic>> getWithQueryString(
    String path, {
    required String queryString,
    bool withoutAccountPrefix = false,
  }) {
    final fullPath = _buildPath(
      path,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    final uri = queryString.isNotEmpty ? '$fullPath?$queryString' : fullPath;
    return _wrap(() => dio.get(uri));
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? query,
    bool withoutAccountPrefix = false,
  }) {
    final fullPath = _buildPath(
      path,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    return _wrap(
      () => dio.post(
        fullPath,
        data: body,
        queryParameters: query,
        options: Options(contentType: 'application/json'),
      ),
    );
  }

  Future<Response<dynamic>> postWithoutAuth(
    String path, {
    Object? body,
    bool withoutAccountPrefix = false,
  }) {
    final fullPath = _buildPath(
      path,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    return _wrap(
      () => dio.post(
        fullPath,
        data: body,
        options: Options(
          contentType: 'application/json',
          // Remove the Authorization header for this request
          headers: {'Authorization': null},
        ),
      ),
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? query,
    Duration? receiveTimeout,
  }) {
    final fullPath = _buildPath(path);
    return _wrap(
      () => dio.put(
        fullPath,
        data: body,
        queryParameters: query,
        options: Options(
          contentType: 'application/json',
          receiveTimeout: receiveTimeout,
        ),
      ),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) {
    final fullPath = _buildPath(path);
    return _wrap(
      () => dio.patch(
        fullPath,
        data: body,
        queryParameters: query,
        options: Options(contentType: 'application/json'),
      ),
    );
  }

  Future<Response<dynamic>> delete(String path) {
    final fullPath = _buildPath(path);
    return _wrap(() => dio.delete(fullPath));
  }

  /// Upload a file using multipart/form-data.
  Future<Response<dynamic>> uploadFile(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, String>? fields,
  }) {
    final fullPath = _buildPath(path);
    return _wrap(() async {
      final formData = FormData.fromMap({
        fileFieldName: await MultipartFile.fromFile(file.path),
        if (fields != null) ...fields,
      });
      return dio.post(
        fullPath,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
    });
  }
}

DioApiClient dioApiClient = DioApiClient();
