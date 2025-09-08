import 'dart:convert';

import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/services/api_client.dart';

class LitterService {
  Future<List<dynamic>> getLitters({Map<String, String>? query}) async {
    final res = await apiClient.get(ApiConfig.litters, query: query);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getLitter(String id) async {
    final res = await apiClient.get('${ApiConfig.litters}/$id');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createLitter(
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.post(ApiConfig.litters, body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLitter(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.put('${ApiConfig.litters}/$id', body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteLitter(String id) async {
    await apiClient.delete('${ApiConfig.litters}/$id');
  }
}

final LitterService litterService = LitterService();
