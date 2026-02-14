import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

class BackgroundApi {
  static const String basePath = '/background';

  Future<BackgroundStoreDto> postBackground(String backgroundName) async {
    final path = basePath;
    final res = await apiClient.post(path, body: {'name': backgroundName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post background: ${res.body}');
    }
    return BackgroundStoreDto.fromJson(jsonDecode(res.body));
  }
}

final BackgroundApi backgroundApi = BackgroundApi();
