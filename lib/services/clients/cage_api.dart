import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageApi {
  static const String basePath = '/cage';

  Future<PaginatedResponseDto<CageDto>> getCagesPage({
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
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<CageDto>> searchCagesWithAi({
    required String prompt,
  }) async {
    final query = {'prompt': prompt};
    final res = await apiClient.get('$basePath/ai/search', query: query);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  Future<CageDto> getCage(String cageUuid) async {
    final res = await apiClient.get('$basePath/$cageUuid');
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<CageDto> createCage(PostCageDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create cage ${res.body}');
    }
    print(jsonDecode(res.body));
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<CageDto> putCage(String cageUuid, PutCageDto payload) async {
    final res = await apiClient.put('$basePath/$cageUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update cage ${res.body}');
    }
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<void> endCage(String cageUuid) async {
    final res = await apiClient.post('$basePath/$cageUuid/end');
    if (res.statusCode != 204) {
      throw Exception('Failed to end cage ${res.body}');
    }
  }

  Future<RackDto> moveCage(String cageUuid, int order) async {
    final res = await apiClient.put(
      '$basePath/$cageUuid/order',
      body: {'order': order},
    );
    return RackDto.fromJson(jsonDecode(res.body));
  }
}

final CageApi cageApi = CageApi();
