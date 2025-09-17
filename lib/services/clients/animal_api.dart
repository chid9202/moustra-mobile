import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class AnimalApi {
  static const String basePath = '/animal';

  Future<PaginatedResponseDto<AnimalDto>> getAnimalsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  Future<AnimalDto> getAnimal(String animalUuid) async {
    final res = await apiClient.get('$basePath/$animalUuid');
    return AnimalDto.fromJson(jsonDecode(res.body));
  }

  Future<AnimalDto> putAnimal(String animalUuid, AnimalDto payload) async {
    final res = await apiClient.put('$basePath/$animalUuid', body: payload);

    if (res.statusCode != 200) {
      throw Exception('Failed to update animal ${res.body}');
    }
    return AnimalDto.fromJson(jsonDecode(res.body));
  }

  Future<List<AnimalDto>> postAnimal(PostAnimalDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create animal ${res.body}');
    }

    final animalsData = jsonDecode(res.body)['animals'] as List<dynamic>;
    return animalsData.map((e) => AnimalDto.fromDynamicJson(e)).toList();
  }
}

final AnimalApi animalService = AnimalApi();
