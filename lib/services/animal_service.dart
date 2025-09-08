import 'dart:convert';

import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/services/api_client.dart';

class AnimalService {
  Future<List<dynamic>> getAnimals({Map<String, String>? query}) async {
    final res = await apiClient.get(ApiConfig.animals, query: query);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAnimal(String id) async {
    final res = await apiClient.get('${ApiConfig.animals}/$id');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAnimal(
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.post(ApiConfig.animals, body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAnimal(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.put('${ApiConfig.animals}/$id', body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteAnimal(String id) async {
    await apiClient.delete('${ApiConfig.animals}/$id');
  }
}

final AnimalService animalService = AnimalService();
