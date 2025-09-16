import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';

final cageStore = ValueNotifier<List<CageStoreDto>?>(null);

Future<List<CageStoreDto>> useCageStore() async {
  if (cageStore.value == null) {
    StoreApi<CageStoreDto>().getStore(StoreKeys.cage).then((value) {
      cageStore.value = value;
    });
  }
  return cageStore.value ?? [];
}

Future<List<CageStoreDto>> getCagesHook() async {
  await useCageStore();
  return cageStore.value ?? [];
}

Future<CageStoreDto?> getCageHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useCageStore();
  return cageStore.value?.firstWhere((cage) => cage.cageUuid == uuid);
}
