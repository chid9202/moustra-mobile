import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

final strainStore = ValueNotifier<List<StrainStoreDto>?>(null);

Future<List<StrainStoreDto>> useStrainStore() async {
  if (strainStore.value == null) {
    StoreApi<StrainStoreDto>().getStore(StoreKeys.strain).then((value) {
      strainStore.value = value;
    });
  }

  return strainStore.value ?? [];
}

Future<List<StrainStoreDto>> getStrainsHook() async {
  await useStrainStore();
  return strainStore.value ?? [];
}

Future<StrainStoreDto?> getStrainHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useStrainStore();
  return strainStore.value?.firstWhere((strain) => strain.strainUuid == uuid);
}

Future<void> refreshStrainStore() async {
  // Fetch full list to maintain integrity
  final value = await StoreApi<StrainStoreDto>().getStore(StoreKeys.strain);
  strainStore.value = value;
}
