import 'dart:convert';

import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/services/api_client.dart';

class StrainService {
  Future<List<dynamic>> getStrains({Map<String, String>? query}) async {
    final mergedQuery = {'page_size': '1000', if (query != null) ...query};
    final res = await apiClient.get(ApiConfig.strains, query: mergedQuery);
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    final List<dynamic> results =
        (data['results'] as List<dynamic>? ?? <dynamic>[]);
    return results;
  }

  Future<Map<String, dynamic>> getStrain(String id) async {
    final res = await apiClient.get('${ApiConfig.strains}/$id');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createStrain(
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.post(ApiConfig.strains, body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStrain(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.put('${ApiConfig.strains}/$id', body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteStrain(String id) async {
    await apiClient.delete('${ApiConfig.strains}/$id');
  }
}

final StrainService strainService = StrainService();
