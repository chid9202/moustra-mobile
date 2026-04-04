import 'package:moustra/config/env.dart';
import 'package:moustra/services/clients/api_exceptions.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/end_animals_dto.dart';
import 'package:moustra/services/dtos/family_tree_dto.dart';
import 'package:moustra/services/dtos/family_tree_v2_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/utils/safe_json_converter.dart';
import 'package:moustra/stores/profile_store.dart';

class AnimalApi {
  static const String basePath = '/animal';

  Future<PaginatedResponseDto<AnimalDto>> getAnimalsPage({
    int page = 1,
    int pageSize = 1000,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await dioApiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  /// Get animals page with advanced filtering and sorting support
  Future<PaginatedResponseDto<AnimalDto>> getAnimalsPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await dioApiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<AnimalDto>> searchAnimalsWithAi({
    required String prompt,
  }) async {
    final query = {'prompt': prompt};
    final res = await dioApiClient.get('$basePath/ai/search', query: query);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  Future<AnimalDto> getAnimal(String animalUuid) async {
    final res = await dioApiClient.get('$basePath/$animalUuid');
    final json = res.data as Map<String, dynamic>;
    return safeFromJson(
      json: json,
      fromJson: AnimalDto.fromJson,
      dtoName: 'AnimalDto',
    );
  }

  Future<AnimalDto> putAnimal(String animalUuid, AnimalDto payload) async {
    final res = await dioApiClient.put(
      '$basePath/$animalUuid',
      body: payload,
      receiveTimeout: const Duration(seconds: 90),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update animal ${res.data}');
    }
    return AnimalDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<AnimalDto>> postAnimal(PostAnimalDto payload) async {
    final res = await dioApiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create animal ${res.data}');
    }

    final animalsData = (res.data as Map<String, dynamic>)['animals'] as List<dynamic>;
    return animalsData.map((e) => AnimalDto.fromDynamicJson(e)).toList();
  }

  Future<EndAnimalsResponseDto> getEndAnimalsData(
    List<String> animalUuids,
  ) async {
    final res = await dioApiClient.get(
      '$basePath/end',
      query: {'animals': animalUuids.join(',')},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to get end animals data ${res.data}');
    }
    return EndAnimalsResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future endAnimals(
    List<String> animalUuids,
    EndAnimalFormDto form,
  ) async {
    final res = await dioApiClient.put(
      '$basePath/end',
      query: {'animals': animalUuids.join(',')},
      body: form,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to end animals ${res.data}');
    }
  }

  Future<EndTypeSummaryDto> createEndType(String name) async {
    final res = await dioApiClient.post(
      '/end-type',
      body: {'endTypeName': name},
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create end type ${res.data}');
    }
    return EndTypeSummaryDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EndReasonSummaryDto> createEndReason(String name) async {
    final res = await dioApiClient.post(
      '/end-reason',
      body: {'endReasonName': name},
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create end reason ${res.data}');
    }
    return EndReasonSummaryDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RackDto> moveAnimal(String animalUuid, String cageUuid) async {
    final res = await dioApiClient.post(
      '$basePath/$animalUuid/move',
      body: {'animal': animalUuid, 'cage': cageUuid},
    );
    if (res.statusCode == 200) {
      return RackDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(
      'Status code ${res.statusCode} while moving animal.\n'
      '${res.data}',
    );
  }

  /// Get animals filtered by strain UUID
  Future<PaginatedResponseDto<AnimalDto>> getAnimalsByStrain(
    String strainUuid,
  ) async {
    final params = ListQueryParams(
      page: 1,
      pageSize: 100,
      filters: [
        FilterParam(
          field: 'strain',
          operator: FilterOperators.equals,
          value: strainUuid,
        ),
      ],
      sorts: [
        const SortParam(field: 'created_date', order: SortOrder.desc),
      ],
    );
    final queryString = params.buildQueryString();
    final res = await dioApiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  /// Get the family tree (parent litter + children litter) for an animal
  Future<FamilyTreeDto> getAnimalFamilyTree(String animalUuid) async {
    final res = await dioApiClient.get('$basePath/$animalUuid/family-tree');
    final json = res.data as Map<String, dynamic>;
    return FamilyTreeDto.fromJson(json);
  }

  /// Get the V2 recursive family tree for an animal
  Future<FamilyTreeNodeDto> getAnimalFamilyTreeV2(String animalUuid) async {
    final accountUuid = profileState.value?.accountUuid;
    final v2Base = Env.apiBaseUrlV2;
    final url = '$v2Base/account/$accountUuid/animal/$animalUuid/family-tree';
    final res = await dioApiClient.dio.get(url);
    if (res.statusCode == 404) {
      throw ApiException(statusCode: 404, message: 'Animal not found');
    }
    final json = res.data as Map<String, dynamic>;
    return FamilyTreeNodeDto.fromJson(json);
  }

  /// Batch update animals with a PATCH request.
  /// Used to update strain on multiple animals at once.
  Future<void> patchAnimals(List<Map<String, dynamic>> updates) async {
    final res = await dioApiClient.patch(basePath, body: updates);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to patch animals: ${res.data}');
    }
  }
}

final AnimalApi animalService = AnimalApi();
