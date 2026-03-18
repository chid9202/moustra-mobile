import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class LitterApi {
  static const String basePath = '/litter';

  Future<PaginatedResponseDto<LitterDto>> getLittersPage({
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
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }

  /// Get litters page with advanced filtering and sorting support
  Future<PaginatedResponseDto<LitterDto>> getLittersPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await dioApiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }

  Future<LitterDto> getLitter(String litterUuid) async {
    final res = await dioApiClient.get('$basePath/$litterUuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get litter: ${res.data}');
    }
    return LitterDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future createLitter(PostLitterDto payload) async {
    final res = await dioApiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create litter: ${res.data}');
    }
    return;
  }

  Future putLitter(String litterUuid, PutLitterDto payload) async {
    final res = await dioApiClient.put('$basePath/$litterUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update litter: ${res.data}');
    }
    return;
  }

  Future<LitterDto> addPubsToLitter(
    String litterUuid, {
    int numberOfMale = 0,
    int numberOfFemale = 0,
    int numberOfUnknown = 0,
  }) async {
    final res = await dioApiClient.post(
      '$basePath/$litterUuid/pub',
      body: {
        'number_of_male': numberOfMale,
        'number_of_female': numberOfFemale,
        'number_of_unknown': numberOfUnknown,
      },
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to add pups: ${res.data}');
    }
    return LitterDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future endLitters(List<String> litterUuids, DateTime endDate) async {
    final res = await dioApiClient.put(
      '$basePath/end',
      query: {'litters': litterUuids.join(',')},
      body: {
        'litters': litterUuids,
        'end_date': endDate.toIso8601String().split('T')[0],
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to end litters: ${res.data}');
    }
  }
}

final LitterApi litterService = LitterApi();
