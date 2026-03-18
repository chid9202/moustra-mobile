import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

class AlleleApi {
  static const String basePath = '/allele';

  Future<AlleleStoreDto> postAllele(String alleleName) async {
    final path = basePath;
    final res = await dioApiClient.post(path, body: {'alleleName': alleleName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post allele: ${res.data}');
    }
    return AlleleStoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteAllele(String alleleUuid) async {
    final path = basePath;
    final res = await dioApiClient.delete('$path/$alleleUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete allele: ${res.data}');
    }
  }
}

final AlleleApi alleleApi = AlleleApi();
