import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/stores/profile_store.dart';

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
    print('GET uri $uri');
    final res = await httpClient.get(uri, headers: await _headers());
    print('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(path, withoutAccountPrefix: withoutAccountPrefix);
    print('POST path $uri');
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    final res = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    print('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> postWithoutAuth(
    String path, {
    Object? body,
    bool withoutAccountPrefix = false,
  }) async {
    final uri = _buildUri(path, withoutAccountPrefix: withoutAccountPrefix);
    print('POST (no auth) path $uri');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final res = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    print('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query: query);
    print('PUT path $uri');
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';
    final res = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    print('res ${res.statusCode}');
    return res;
  }

  Future<http.Response> delete(String path) async {
    print('DELETE path $path');
    final uri = _buildUri(path);
    final res = await httpClient.delete(uri, headers: await _headers());
    print('res ${res.statusCode}');
    return res;
  }
}

final ApiClient apiClient = ApiClient();
