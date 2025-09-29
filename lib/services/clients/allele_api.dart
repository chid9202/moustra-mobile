import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

class AlleleApi {
  static const String basePath = '/allele';

  Future<AlleleStoreDto> postAllele(String alleleName) async {
    final path = basePath;
    final res = await apiClient.post(path, body: {'alleleName': alleleName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post allele: ${res.body}');
    }
    return AlleleStoreDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteAllele(String alleleUuid) async {
    final path = basePath;
    final res = await apiClient.delete('$path/$alleleUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete allele: ${res.body}');
    }
  }
}

final AlleleApi alleleApi = AlleleApi();
