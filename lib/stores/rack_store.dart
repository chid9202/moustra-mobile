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

void saveTransformationMatrix(Matrix4 matrix) {
  final currentStore = rackStore.value;
  if (currentStore != null) {
    // Convert Matrix4 to List<double> for serialization
    final matrixList = <double>[];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        matrixList.add(matrix.entry(i, j));
      }
    }

    rackStore.value = RackStoreDto(
      rackData: currentStore.rackData,
      transformationMatrix: matrixList,
    );
  }
}

Matrix4? getSavedTransformationMatrix() {
  final matrixList = rackStore.value?.transformationMatrix;
  if (matrixList == null || matrixList.length != 16) return null;

  // Convert List<double> back to Matrix4
  final matrix = Matrix4.identity();
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      matrix.setEntry(i, j, matrixList[i * 4 + j]);
    }
  }
  return matrix;
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

void removeCageFromRack(String cageUuid) {
  final rackData = rackStore.value?.rackData;
  if (rackData == null) return;
  rackData.cages?.removeWhere((cage) => cage.cageUuid == cageUuid);
  rackStore.value = RackStoreDto(rackData: rackData);
}
