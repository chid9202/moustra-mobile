import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

enum StoreKeys {
  account('Account', AccountStoreDto.fromJson),
  background('Background', BackgroundStoreDto.fromJson),
  animal('Animal', AnimalStoreDto.fromJson),
  cage('Cage', CageStoreDto.fromJson),
  strain('Strain', StrainStoreDto.fromJson),
  allele('Allele', AlleleStoreDto.fromJson),
  gene('Gene', GeneStoreDto.fromJson);

  const StoreKeys(this.path, this.fromJson);
  final String path;
  final Function(dynamic) fromJson;
}

class StoreApi<T> {
  static const String basePath = '/store';

  Future<List<T>> getStore(StoreKeys key) async {
    final res = await dioApiClient.get('$basePath/${key.path}');
    if (res.statusCode != 200) {
      throw Exception('Failed to get ${key.path} store: ${res.statusCode}');
    }
    final responseData = res.data;
    if (responseData is! List) {
      throw Exception(
        'Unexpected response type for ${key.path} store: '
        '${responseData.runtimeType}',
      );
    }
    final List<T> result = [];
    for (var e in responseData) {
      result.add(key.fromJson(e));
    }
    return result;
  }
}

final StoreApi storeService = StoreApi();
