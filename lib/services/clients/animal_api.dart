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
    print('1111111111111111111111111111');
    final res = await apiClient.put('$basePath/$animalUuid', body: payload);
    print('222222222222222222222222222 ${jsonDecode(res.body)}');

    if (res.statusCode != 200) {
      throw Exception('Failed to update animal ${res.body}');
    }
    return AnimalDto.fromJson(jsonDecode(res.body));
  }
}

final AnimalApi animalService = AnimalApi();
