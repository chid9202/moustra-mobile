import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/clients/store_api.dart';

final animalStore = ValueNotifier<List<AnimalStoreDto>?>(null);

Future<List<AnimalStoreDto>> useAnimalStore() async {
  if (animalStore.value == null) {
    StoreApi<AnimalStoreDto>().getStore(StoreKeys.animal).then((value) {
      animalStore.value = value;
    });
  }
  return animalStore.value ?? [];
}

Future<List<AnimalStoreDto>> getAnimalsHook() async {
  await useAnimalStore();
  return animalStore.value ?? [];
}

Future<AnimalStoreDto?> getAnimalHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useAnimalStore();
  return animalStore.value?.firstWhere((animal) => animal.animalUuid == uuid);
}

Future<List<AnimalStoreDto>> getAnimalsHookByUuids(List<String> uuids) async {
  if (uuids.isEmpty) {
    return [];
  }
  await useAnimalStore();
  return animalStore.value
          ?.where((animal) => uuids.contains(animal.animalUuid))
          .toList() ??
      [];
}
