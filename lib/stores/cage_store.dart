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
  final cages = cageStore.value;
  if (cages == null) return null;
  for (final cage in cages) {
    if (cage.cageUuid == uuid) return cage;
  }
  return null;
}

Future<void> refreshCageStore() async {
  // Fetch full list to maintain integrity
  final value = await StoreApi<CageStoreDto>().getStore(StoreKeys.cage);
  cageStore.value = value;
}
