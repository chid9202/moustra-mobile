import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';

class GeneApi {
  static const String basePath = '/gene';

  Future<GeneStoreDto> postGene(String geneName) async {
    final path = basePath;
    final res = await apiClient.post(path, body: {'geneName': geneName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post gene: ${res.body}');
    }
    return GeneStoreDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteGene(String geneUuid) async {
    final path = basePath;
    final res = await apiClient.delete('$path/$geneUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete gene: ${res.body}');
    }
  }
}

final GeneApi geneApi = GeneApi();
