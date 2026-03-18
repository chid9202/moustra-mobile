import 'package:moustra/services/clients/dio_api_client.dart';
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
    final res = await dioApiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
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
    final res = await dioApiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<MatingDto>.fromJson(
      data,
      (j) => MatingDto.fromJson(j),
    );
  }

  Future<MatingDto> getMating(String matingUuid) async {
    final res = await dioApiClient.get('$basePath/$matingUuid');
    return MatingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MatingDto> createMating(PostMatingDto payload) async {
    final res = await dioApiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create mating ${res.data}');
    }
    return MatingDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MatingDto> putMating(String matingUuid, PutMatingDto payload) async {
    final res = await dioApiClient.put('$basePath/$matingUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update mating ${res.data}');
    }
    return MatingDto.fromJson(res.data as Map<String, dynamic>);
  }
}

final MatingApi matingService = MatingApi();
