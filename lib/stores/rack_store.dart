import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/clients/animal_api.dart';

final rackStore = ValueNotifier<RackStoreDto?>(null);

const String _transformationMatrixKey = 'rack_transformation_matrix';

Future<RackStoreDto> useRackStore() async {
  if (rackStore.value == null) {
    // Try to load transformation matrix from SharedPreferences first
    final savedMatrix = await _loadTransformationMatrixFromStorage();
    final savedMatrixList = savedMatrix != null
        ? _matrix4ToList(savedMatrix)
        : null;

    rackApi.getRack().then((value) {
      rackStore.value = RackStoreDto(
        rackData: value,
        transformationMatrix: savedMatrixList,
      );
    });
  } else {
    // If store exists, preserve existing transformation matrix when reloading
    final existingMatrix = rackStore.value?.transformationMatrix;
    if (existingMatrix == null) {
      // If no in-memory matrix, try loading from SharedPreferences
      final savedMatrix = await _loadTransformationMatrixFromStorage();
      if (savedMatrix != null && rackStore.value != null) {
        final matrixList = _matrix4ToList(savedMatrix);
        rackStore.value = RackStoreDto(
          rackData: rackStore.value!.rackData,
          transformationMatrix: matrixList,
        );
      }
    }
  }
  return rackStore.value ?? RackStoreDto(rackData: RackDto());
}

void saveTransformationMatrix(Matrix4 matrix) {
  final currentStore = rackStore.value;
  if (currentStore != null) {
    // Convert Matrix4 to List<double> for serialization
    final matrixList = _matrix4ToList(matrix);

    // Save to in-memory store
    rackStore.value = RackStoreDto(
      rackData: currentStore.rackData,
      transformationMatrix: matrixList,
    );

    // Save to SharedPreferences for persistence across app restarts
    _saveTransformationMatrixToStorage(matrix);
  }
}

List<double> _matrix4ToList(Matrix4 matrix) {
  final matrixList = <double>[];
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      matrixList.add(matrix.entry(i, j));
    }
  }
  return matrixList;
}

Future<void> _saveTransformationMatrixToStorage(Matrix4 matrix) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final matrixList = _matrix4ToList(matrix);
    await prefs.setString(_transformationMatrixKey, jsonEncode(matrixList));
  } on PlatformException catch (e) {
    // Silently handle platform channel errors (common during hot reload/startup)
    // In-memory storage still works as fallback
    if (e.code != 'channel-error' &&
        !(e.message?.contains('channel') ?? false)) {
      debugPrint(
        '[rack_store] Error saving transformation matrix to storage: $e',
      );
    }
  } catch (e) {
    // Only log unexpected errors
    debugPrint(
      '[rack_store] Unexpected error saving transformation matrix: $e',
    );
  }
}

Future<Matrix4?> _loadTransformationMatrixFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final matrixString = prefs.getString(_transformationMatrixKey);
    if (matrixString == null) return null;

    final List<dynamic> matrixList = jsonDecode(matrixString);
    if (matrixList.length != 16) return null;

    // Convert List<double> back to Matrix4
    final matrix = Matrix4.identity();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        matrix.setEntry(i, j, (matrixList[i * 4 + j] as num).toDouble());
      }
    }
    return matrix;
  } on PlatformException catch (e) {
    // Silently handle platform channel errors (common during hot reload/startup)
    // In-memory storage still works as fallback
    if (e.code != 'channel-error' &&
        !(e.message?.contains('channel') ?? false)) {
      debugPrint(
        '[rack_store] Error loading transformation matrix from storage: $e',
      );
    }
    return null;
  } catch (e) {
    // Only log unexpected errors
    debugPrint(
      '[rack_store] Unexpected error loading transformation matrix: $e',
    );
    return null;
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

Future<Matrix4?> getSavedTransformationMatrixFromStorage() async {
  return await _loadTransformationMatrixFromStorage();
}

void removeAnimalFromCage(String cageUuid, String animalUuid) {
  final currentStore = rackStore.value;
  if (currentStore == null) return;
  final rackData = currentStore.rackData;
  rackData.cages
      ?.firstWhere((cage) => cage.cageUuid == cageUuid)
      .animals
      ?.removeWhere((animal) => animal.animalUuid == animalUuid);
  rackStore.value = RackStoreDto(
    rackData: rackData,
    transformationMatrix: currentStore.transformationMatrix,
  );
}

void removeCageFromRack(String cageUuid) {
  final currentStore = rackStore.value;
  if (currentStore == null) return;
  final rackData = currentStore.rackData;
  rackData.cages?.removeWhere((cage) => cage.cageUuid == cageUuid);
  rackStore.value = RackStoreDto(
    rackData: rackData,
    transformationMatrix: currentStore.transformationMatrix,
  );
}

Future<void> moveCage(String cageUuid, int order) async {
  final currentStore = rackStore.value;
  if (currentStore == null) return;
  final newRack = await cageApi.moveCage(cageUuid, order);
  rackStore.value = RackStoreDto(
    rackData: newRack,
    transformationMatrix: currentStore.transformationMatrix,
  );
}

Future<void> moveAnimal(String animalUuid, String cageUuid) async {
  final currentStore = rackStore.value;
  if (currentStore == null) return;
  final newRack = await animalService.moveAnimal(animalUuid, cageUuid);
  rackStore.value = RackStoreDto(
    rackData: newRack,
    transformationMatrix: currentStore.transformationMatrix,
  );
}
