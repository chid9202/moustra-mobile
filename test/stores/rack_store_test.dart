import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    rackStore.value = null;
  });

  tearDown(() {
    rackStore.value = null;
  });

  group('removeAnimalFromCage', () {
    test('removes the specified animal from a cage', () {
      final animal1 = RackCageAnimalDto(animalUuid: 'animal-1');
      final animal2 = RackCageAnimalDto(animalUuid: 'animal-2');
      final cage = RackCageDto(
        cageUuid: 'cage-1',
        animals: [animal1, animal2],
      );
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
      );

      removeAnimalFromCage('cage-1', 'animal-1');

      final updatedCage = rackStore.value!.rackData.cages!.first;
      expect(updatedCage.animals!.length, 1);
      expect(updatedCage.animals!.first.animalUuid, 'animal-2');
    });

    test('does NOT throw when cage UUID is not found (bug fix)', () {
      final cage = RackCageDto(
        cageUuid: 'cage-1',
        animals: [RackCageAnimalDto(animalUuid: 'animal-1')],
      );
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
      );

      // Previously crashed with StateError: No element. Now should not throw.
      expect(
        () => removeAnimalFromCage('non-existent-cage', 'animal-1'),
        returnsNormally,
      );
      // Original cage should be unchanged
      expect(rackStore.value!.rackData.cages!.first.animals!.length, 1);
    });

    test('does nothing when rackStore is null', () {
      rackStore.value = null;
      expect(
        () => removeAnimalFromCage('cage-1', 'animal-1'),
        returnsNormally,
      );
      expect(rackStore.value, isNull);
    });

    test('does nothing when animal UUID is not found in cage', () {
      final animal = RackCageAnimalDto(animalUuid: 'animal-1');
      final cage = RackCageDto(cageUuid: 'cage-1', animals: [animal]);
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
      );

      removeAnimalFromCage('cage-1', 'non-existent-animal');

      expect(rackStore.value!.rackData.cages!.first.animals!.length, 1);
    });

    test('preserves transformationMatrix after removal', () {
      final matrix = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        5.0, 10.0, 0.0, 1.0,
      ];
      final cage = RackCageDto(
        cageUuid: 'cage-1',
        animals: [RackCageAnimalDto(animalUuid: 'animal-1')],
      );
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
        transformationMatrix: matrix,
      );

      removeAnimalFromCage('cage-1', 'animal-1');

      expect(rackStore.value!.transformationMatrix, matrix);
    });
  });

  group('removeCageFromRack', () {
    test('removes the specified cage from the rack', () {
      final cage1 = RackCageDto(cageUuid: 'cage-1');
      final cage2 = RackCageDto(cageUuid: 'cage-2');
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage1, cage2]),
      );

      removeCageFromRack('cage-1');

      final cages = rackStore.value!.rackData.cages!;
      expect(cages.length, 1);
      expect(cages.first.cageUuid, 'cage-2');
    });

    test('does nothing when rackStore is null', () {
      rackStore.value = null;
      expect(() => removeCageFromRack('cage-1'), returnsNormally);
      expect(rackStore.value, isNull);
    });

    test('does nothing when cage UUID is not found', () {
      final cage = RackCageDto(cageUuid: 'cage-1');
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
      );

      removeCageFromRack('non-existent');

      expect(rackStore.value!.rackData.cages!.length, 1);
    });

    test('preserves transformationMatrix after removal', () {
      final matrix = List<double>.generate(16, (i) => i.toDouble());
      final cage = RackCageDto(cageUuid: 'cage-1');
      rackStore.value = RackStoreDto(
        rackData: RackDto(cages: [cage]),
        transformationMatrix: matrix,
      );

      removeCageFromRack('cage-1');

      expect(rackStore.value!.transformationMatrix, matrix);
    });
  });

  group('useRackStore', () {
    test('returns existing store value when already populated', () async {
      final existingStore = RackStoreDto(
        rackData: RackDto(rackName: 'Test Rack'),
      );
      rackStore.value = existingStore;

      final result = await useRackStore();

      expect(result.rackData.rackName, 'Test Rack');
    });
  });

  group('matrix serialization (getSavedTransformationMatrix)', () {
    test('returns null when store is null', () {
      rackStore.value = null;
      expect(getSavedTransformationMatrix(), isNull);
    });

    test('returns null when transformationMatrix is null', () {
      rackStore.value = RackStoreDto(rackData: RackDto());
      expect(getSavedTransformationMatrix(), isNull);
    });

    test('returns null when transformationMatrix has wrong length', () {
      rackStore.value = RackStoreDto(
        rackData: RackDto(),
        transformationMatrix: [1.0, 2.0, 3.0], // not 16 elements
      );
      expect(getSavedTransformationMatrix(), isNull);
    });

    test('correctly reconstructs Matrix4 from list', () {
      // Identity matrix as a list
      final identityList = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ];
      rackStore.value = RackStoreDto(
        rackData: RackDto(),
        transformationMatrix: identityList,
      );

      final matrix = getSavedTransformationMatrix();

      expect(matrix, isNotNull);
      // Check diagonal entries are 1.0
      expect(matrix!.entry(0, 0), 1.0);
      expect(matrix.entry(1, 1), 1.0);
      expect(matrix.entry(2, 2), 1.0);
      expect(matrix.entry(3, 3), 1.0);
      // Check off-diagonal entries are 0.0
      expect(matrix.entry(0, 1), 0.0);
      expect(matrix.entry(1, 0), 0.0);
    });

    test('correctly reconstructs a translated matrix', () {
      // Translation matrix (translate by x=5, y=10)
      final matrixList = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        5.0, 10.0, 0.0, 1.0,
      ];
      rackStore.value = RackStoreDto(
        rackData: RackDto(),
        transformationMatrix: matrixList,
      );

      final matrix = getSavedTransformationMatrix();

      expect(matrix, isNotNull);
      expect(matrix!.entry(3, 0), 5.0);
      expect(matrix.entry(3, 1), 10.0);
    });
  });

  group('saveTransformationMatrix', () {
    test('does nothing when store is null', () {
      rackStore.value = null;
      // Should not throw
      expect(
        () => saveTransformationMatrix(Matrix4.identity()),
        returnsNormally,
      );
      expect(rackStore.value, isNull);
    });

    test('saves matrix to in-memory store', () {
      rackStore.value = RackStoreDto(rackData: RackDto());

      final matrix = Matrix4.identity();
      matrix.setEntry(3, 0, 42.0);
      saveTransformationMatrix(matrix);

      final saved = rackStore.value!.transformationMatrix;
      expect(saved, isNotNull);
      expect(saved!.length, 16);
      // The matrix stores row-major: entry(3,0) is index 12
      expect(saved[12], 42.0);
    });
  });
}
