import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moustra/app/router.dart';
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';

class ApiClient {
  final http.Client httpClient;

  ApiClient({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

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
    print('uri $uri');
    return httpClient.get(uri, headers: await _headers());
  }

  Future<http.Response> getAbsolute(
    String url, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    return httpClient.get(uri, headers: await _headers());
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(path, withoutAccountPrefix: withoutAccountPrefix);
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    return httpClient.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    return httpClient.put(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final uri = _buildUri(path);
    return httpClient.delete(uri, headers: await _headers());
  }
}

final ApiClient apiClient = ApiClient();
