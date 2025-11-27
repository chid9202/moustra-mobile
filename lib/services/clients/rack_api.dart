import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';

class RackApi {
  static const String basePath = '/rack';

  Future<RackDto> getRack({String? rackUuid}) async {
    final path = rackUuid != null ? '$basePath/$rackUuid' : '$basePath/default';
    final res = await apiClient.get(path);
    if (res.statusCode != 200) {
      throw Exception('Failed to get rack: ${res.body}');
    }
    return RackDto.fromJson(jsonDecode(res.body));
  }

  Future<RackDto> createRack(PostRackDto payload) async {
    final res = await apiClient.post('$basePath/new', body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create rack: ${res.body}');
    }
    return RackDto.fromJson(jsonDecode(res.body));
  }

  Future<RackDto> updateRack(String rackUuid, PutRackDto payload) async {
    final res = await apiClient.put('$basePath/$rackUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update rack: ${res.body}');
    }
    return RackDto.fromJson(jsonDecode(res.body));
  }
}

final RackApi rackApi = RackApi();
