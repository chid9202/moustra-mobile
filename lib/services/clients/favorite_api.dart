import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/favorite_dto.dart';

class FavoriteApi {
  static const String basePath = '/favorites';

  Future<List<FavoriteDto>> getAll({String? type}) async {
    final query = <String, String>{};
    if (type != null) {
      query['type'] = type;
    }
    final res = await dioApiClient.get(basePath, query: query);
    if (res.statusCode != 200) {
      throw Exception('Failed to get favorites: ${res.data}');
    }
    final list = res.data as List<dynamic>;
    return list
        .map((item) => FavoriteDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> toggle(
    String objectType,
    String objectUuid,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/toggle/',
      body: {
        'object_type': objectType,
        'object_uuid': objectUuid,
      },
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to toggle favorite: ${res.data}');
    }
    return res.data as Map<String, dynamic>;
  }
}

final FavoriteApi favoriteApi = FavoriteApi();
