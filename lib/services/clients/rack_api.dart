import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

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
}

final RackApi rackApi = RackApi();
