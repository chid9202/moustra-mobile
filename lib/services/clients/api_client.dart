import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/stores/profile_store.dart';

/// Creates an HTTP client that allows self-signed certificates for localhost
/// This is only for development purposes when connecting to local backend
http.Client _createHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
        // Allow self-signed certificates for localhost only
        return host == 'localhost' || host == '127.0.0.1';
      };
  return IOClient(client);
}

class ApiClient {
  final http.Client? _providedHttpClient;
  http.Client? _httpClient;

  ApiClient({http.Client? httpClient}) : _providedHttpClient = httpClient;

  /// Lazily creates the HTTP client, checking baseUrl at runtime
  /// This ensures dotenv is loaded before we check if we need a custom client
  http.Client get httpClient {
    final provided = _providedHttpClient;
    if (provided != null) {
      return provided;
    }
    _httpClient ??= _isLocalhost(ApiConfig.baseUrl)
        ? _createHttpClient()
        : http.Client();
    return _httpClient as http.Client;
  }

  static bool _isLocalhost(String url) {
    final uri = Uri.parse(url);
    return uri.host == 'localhost' || uri.host == '127.0.0.1';
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? query,
    bool withoutAccountPrefix = false,
  }) {
    final Uri base = Uri.parse(ApiConfig.baseUrl);
    // Remap localhost only on Android; keep localhost for web/iOS/desktop
    final String host = base.host;
    var basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;

    if (!withoutAccountPrefix) {
      basePath = '$basePath/account/${profileState.value?.accountUuid}';
    }
    final String addPath = path.startsWith('/') ? path : '/$path';
    final String combinedPath = '$basePath$addPath';
    return base.replace(host: host, path: combinedPath, queryParameters: query);
  }

  /// Build URI with raw query string (for repeated parameters)
  Uri _buildUriWithQueryString(
    String path, {
    required String queryString,
    bool withoutAccountPrefix = false,
  }) {
    final Uri base = Uri.parse(ApiConfig.baseUrl);
    final String host = base.host;
    var basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;

    if (!withoutAccountPrefix) {
      basePath = '$basePath/account/${profileState.value?.accountUuid}';
    }
    final String addPath = path.startsWith('/') ? path : '/$path';
    final String combinedPath = '$basePath$addPath';

    // Build URI with query string manually
    final baseUri = base.replace(host: host, path: combinedPath);
    final uriString = queryString.isNotEmpty
        ? '$baseUri?$queryString'
        : baseUri.toString();
    return Uri.parse(uriString);
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Accept': 'application/json'};
    final token = authService.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(
      path,
      query: query,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    debugPrint('GET uri $uri');
    final res = await httpClient.get(uri, headers: await _headers());
    debugPrint('res ${res.statusCode}');
    return res;
  }

  /// GET request with raw query string for repeated parameters support
  /// Use this when you need to pass multiple values for the same key
  /// (e.g., filter=a&filter=b&filter=c)
  Future<http.Response> getWithQueryString(
    String path, {
    required String queryString,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUriWithQueryString(
      path,
      queryString: queryString,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    debugPrint('GET uri $uri');
    final res = await httpClient.get(uri, headers: await _headers());
    debugPrint('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? query,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(
      path,
      query: query,
      withoutAccountPrefix: withoutAccountPrefix,
    );
    debugPrint('POST path $uri');
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    final res = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> postWithoutAuth(
    String path, {
    Object? body,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(path, withoutAccountPrefix: withoutAccountPrefix);
    debugPrint('POST (no auth) path $uri');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final res = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query: query);
    debugPrint('PUT path $uri');
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    final res = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> delete(String path) async {
    debugPrint('DELETE path $path');
    final uri = _buildUri(path);
    final res = await httpClient.delete(uri, headers: await _headers());
    debugPrint('res ${res.statusCode}');
    return res;
  }

  /// Upload a file using multipart/form-data
  Future<http.StreamedResponse> uploadFile(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final uri = _buildUri(path);
    debugPrint('UPLOAD path $uri');

    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    final token = authService.accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add the file
    request.files.add(
      await http.MultipartFile.fromPath(fileFieldName, file.path),
    );

    // Add any additional fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final res = await request.send();
    debugPrint('res ${res.statusCode}');
    return res;
  }
}

final ApiClient apiClient = ApiClient();
