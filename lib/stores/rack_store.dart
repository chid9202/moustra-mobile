import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/services/clients/rack_api.dart';

final rackStore = ValueNotifier<RackStoreDto?>(null);

Future<RackStoreDto> useRackStore() async {
  if (rackStore.value == null) {
    rackApi.getRack().then((value) {
      rackStore.value = RackStoreDto(rackData: value);
    });
  }
  return rackStore.value ?? RackStoreDto(rackData: RackDto());
}

void removeAnimalFromCage(String cageUuid, String animalUuid) {
  final rackData = rackStore.value?.rackData;
  if (rackData == null) return;
  rackData.cages
      ?.firstWhere((cage) => cage.cageUuid == cageUuid)
      .animals
      ?.removeWhere((animal) => animal.animalUuid == animalUuid);
  rackStore.value = RackStoreDto(rackData: rackData);
}
