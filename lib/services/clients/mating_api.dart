import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/post_mating_dto.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class MatingApi {
  static const String basePath = '/mating';

  Future<PaginatedResponseDto<MatingDto>> getMatingsPage({
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
    return PaginatedResponseDto<MatingDto>.fromJson(
      data,
      (j) => MatingDto.fromJson(j),
    );
  }

  /// Get matings page with advanced filtering and sorting support
  Future<PaginatedResponseDto<MatingDto>> getMatingsPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await apiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<MatingDto>.fromJson(
      data,
      (j) => MatingDto.fromJson(j),
    );
  }

  Future<MatingDto> getMating(String matingUuid) async {
    final res = await apiClient.get('$basePath/$matingUuid');
    return MatingDto.fromJson(jsonDecode(res.body));
  }

  Future<MatingDto> createMating(PostMatingDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create mating ${res.body}');
    }
    return MatingDto.fromJson(jsonDecode(res.body));
  }

  Future<MatingDto> putMating(String matingUuid, PutMatingDto payload) async {
    final res = await apiClient.put('$basePath/$matingUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update mating ${res.body}');
    }
    return MatingDto.fromJson(jsonDecode(res.body));
  }
}

final MatingApi matingService = MatingApi();
