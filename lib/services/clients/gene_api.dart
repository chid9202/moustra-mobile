import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';

class GeneApi {
  static const String basePath = '/gene';

  Future<GeneStoreDto> postGene(String geneName) async {
    final path = basePath;
    final res = await dioApiClient.post(path, body: {'geneName': geneName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post gene: ${res.data}');
    }
    return GeneStoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteGene(String geneUuid) async {
    final path = basePath;
    final res = await dioApiClient.delete('$path/$geneUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete gene: ${res.data}');
    }
  }
}

final GeneApi geneApi = GeneApi();
