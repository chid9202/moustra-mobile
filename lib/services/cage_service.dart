import 'dart:convert';

import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/services/api_client.dart';

class CageService {
  Future<List<dynamic>> getCages({Map<String, String>? query}) async {
    final res = await apiClient.get(ApiConfig.cages, query: query);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getCage(String id) async {
    final res = await apiClient.get('${ApiConfig.cages}/$id');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCage(Map<String, dynamic> payload) async {
    final res = await apiClient.post(ApiConfig.cages, body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCage(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.put('${ApiConfig.cages}/$id', body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteCage(String id) async {
    await apiClient.delete('${ApiConfig.cages}/$id');
  }
}

final CageService cageService = CageService();
