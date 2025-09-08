import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/services/auth_service.dart';

class ApiClient {
  final http.Client httpClient;

  ApiClient({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final Uri base = Uri.parse(ApiConfig.baseUrl);
    // Remap localhost only on Android; keep localhost for web/iOS/desktop
    final String host =
        (!kIsWeb && Platform.isAndroid && base.host == 'localhost')
        ? '10.0.2.2'
        : base.host;
    final String basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
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

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query);
    return httpClient.get(uri, headers: await _headers());
  }

  Future<http.Response> getAbsolute(
    String url, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    return httpClient.get(uri, headers: await _headers());
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final uri = _buildUri(path);
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
