import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

class BackgroundApi {
  static const String basePath = '/background';

  Future<BackgroundStoreDto> postBackground(String backgroundName) async {
    final path = basePath;
    final res = await dioApiClient.post(path, body: {'name': backgroundName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post background: ${res.data}');
    }
    return BackgroundStoreDto.fromJson(res.data as Map<String, dynamic>);
  }
}

final BackgroundApi backgroundApi = BackgroundApi();
