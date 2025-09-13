import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';

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
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }
}

final LitterApi litterService = LitterApi();
