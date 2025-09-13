import 'dart:convert';

import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class CagePage {
  final int count;
  final List<dynamic> results;

  CagePage({required this.count, required this.results});
}

class CageService {
  static const String basePath = '/cage';

  Future<PaginatedResponseDto<CageDto>> getCagesPage({
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
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }
}

final CageService cageService = CageService();
