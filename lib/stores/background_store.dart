import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

final backgroundStore = ValueNotifier<List<BackgroundStoreDto>?>(null);

Future<List<BackgroundStoreDto>> useBackgroundStore() async {
  if (backgroundStore.value == null) {
    StoreApi<BackgroundStoreDto>().getStore(StoreKeys.background).then((value) {
      backgroundStore.value = value;
    });
  }
  return backgroundStore.value ?? [];
}

Future<List<BackgroundStoreDto>> getBackgroundsHook() async {
  await useBackgroundStore();
  return backgroundStore.value ?? [];
}

Future<BackgroundStoreDto?> getBackgroundHook(String uuid) async {
  await useBackgroundStore();
  return backgroundStore.value?.firstWhere(
    (background) => background.uuid == uuid,
  );
}
