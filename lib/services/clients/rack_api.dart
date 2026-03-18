import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';

class RackApi {
  static const String basePath = '/rack';

  Future<RackDto> getRack({String? rackUuid}) async {
    final path = rackUuid != null ? '$basePath/$rackUuid' : '$basePath/default';
    final res = await dioApiClient.get(path);
    if (res.statusCode != 200) {
      throw Exception('Failed to get rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RackDto> createRack(PostRackDto payload) async {
    final res = await dioApiClient.post('$basePath/new', body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RackDto> updateRack(String rackUuid, PutRackDto payload) async {
    final res = await dioApiClient.put('$basePath/$rackUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }
}

final RackApi rackApi = RackApi();
