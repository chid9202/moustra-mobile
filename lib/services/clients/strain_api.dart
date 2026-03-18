import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class StrainApi {
  Future<PaginatedResponseDto<StrainDto>> getStrainsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await dioApiClient.get(ApiConfig.strains, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  /// Get strains page with advanced filtering and sorting support
  Future<PaginatedResponseDto<StrainDto>> getStrainsPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await dioApiClient.getWithQueryString(
      ApiConfig.strains,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<StrainDto>> searchStrainsWithAi({
    required String prompt,
  }) async {
    final query = {'prompt': prompt};
    final res = await dioApiClient.get(
      '${ApiConfig.strains}/ai/search',
      query: query,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<StrainDto> getStrain(String uuid) async {
    final res = await dioApiClient.get('${ApiConfig.strains}/$uuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get strain ${res.data}');
    }
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StrainDto> createStrain(PostStrainDto payload) async {
    final res = await dioApiClient.post(ApiConfig.strains, body: payload);
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StrainDto> putStrain(String uuid, PutStrainDto payload) async {
    final res = await dioApiClient.put(
      '${ApiConfig.strains}/$uuid',
      body: payload,
    );
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteStrain(String id) async {
    await dioApiClient.delete('${ApiConfig.strains}/$id');
  }

  Future<void> mergeStrains(List<String> strainUuids) async {
    await dioApiClient.post(
      '${ApiConfig.strains}/merge',
      body: <String, dynamic>{'strains': strainUuids},
    );
  }
}

final StrainApi strainService = StrainApi();
