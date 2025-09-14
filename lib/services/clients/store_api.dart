import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

enum StoreKeys {
  account('Account', AccountStoreDto.fromJson),
  background('Background', BackgroundStoreDto.fromJson);

  const StoreKeys(this.path, this.fromJson);
  final String path;
  final Function(dynamic) fromJson;
}

class StoreApi<T> {
  static const String basePath = '/store';

  Future<List<T>> getStore(StoreKeys key) async {
    final res = await apiClient.get('$basePath/${key.path}');
    final List<dynamic> data = jsonDecode(res.body);
    final List<T> result = [];
    for (var e in data) {
      result.add(key.fromJson(e));
    }
    return result;
  }
}

final StoreApi storeService = StoreApi();
