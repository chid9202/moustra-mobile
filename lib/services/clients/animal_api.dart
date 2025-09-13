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
}

final AnimalApi animalService = AnimalApi();
