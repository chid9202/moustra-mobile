import 'dart:convert';

import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

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
    final res = await apiClient.get(ApiConfig.strains, query: mergedQuery);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<StrainDto> getStrain(String uuid) async {
    final res = await apiClient.get('${ApiConfig.strains}/$uuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get strain ${res.body}');
    }
    return StrainDto.fromJson(jsonDecode(res.body));
  }

  Future<StrainDto> createStrain(PostStrainDto payload) async {
    final res = await apiClient.post(ApiConfig.strains, body: payload);
    return StrainDto.fromJson(jsonDecode(res.body));
  }

  Future<StrainDto> putStrain(String uuid, PutStrainDto payload) async {
    final res = await apiClient.put(
      '${ApiConfig.strains}/$uuid',
      body: payload,
    );
    return StrainDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteStrain(String id) async {
    await apiClient.delete('${ApiConfig.strains}/$id');
  }

  Future<void> mergeStrains(List<String> strainUuids) async {
    await apiClient.post(
      '${ApiConfig.strains}/merge',
      body: <String, dynamic>{'strains': strainUuids},
    );
  }
}

final StrainApi strainService = StrainApi();
