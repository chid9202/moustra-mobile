import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';

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
    animalStore.value = null;
  });

  tearDown(() {
    animalStore.value = null;
  });

  group('getAnimalHook', () {
    test('returns null for null uuid', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];

      final result = await getAnimalHook(null);
      expect(result, isNull);
    });

    test('returns null for empty uuid', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];

      final result = await getAnimalHook('');
      expect(result, isNull);
    });

    test('returns matching animal when uuid exists', () async {
      animalStore.value = [
        AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid-1',
          physicalTag: 'A001',
        ),
        AnimalStoreDto(
          eid: 2,
          animalId: 2,
          animalUuid: 'uuid-2',
          physicalTag: 'A002',
        ),
      ];

      final result = await getAnimalHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.animalUuid, 'uuid-2');
      expect(result.physicalTag, 'A002');
    });

    test('returns null when uuid does not match any animal', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];

      final result = await getAnimalHook('non-existent-uuid');
      expect(result, isNull);
    });

    test('returns null when store has empty list', () async {
      animalStore.value = [];

      final result = await getAnimalHook('uuid-1');
      expect(result, isNull);
    });

    // Note: testing with null store value is not feasible in unit tests because
    // useAnimalStore triggers an API call with fire-and-forget .then() that
    // produces unhandled async errors when the API client is a no-op mock.
  });

  group('getAnimalsHookByUuids', () {
    test('returns empty list for empty uuids', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];

      final result = await getAnimalsHookByUuids([]);
      expect(result, isEmpty);
    });

    test('returns matching animals for given uuids', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
        AnimalStoreDto(eid: 2, animalId: 2, animalUuid: 'uuid-2'),
        AnimalStoreDto(eid: 3, animalId: 3, animalUuid: 'uuid-3'),
      ];

      final result = await getAnimalsHookByUuids(['uuid-1', 'uuid-3']);
      expect(result.length, 2);
      expect(result.map((a) => a.animalUuid).toList(), ['uuid-1', 'uuid-3']);
    });

    test('returns empty list when no uuids match', () async {
      animalStore.value = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];

      final result = await getAnimalsHookByUuids(['non-existent']);
      expect(result, isEmpty);
    });
  });

  group('useAnimalStore', () {
    test('returns existing list when store is populated', () async {
      final animals = [
        AnimalStoreDto(eid: 1, animalId: 1, animalUuid: 'uuid-1'),
      ];
      animalStore.value = animals;

      final result = await useAnimalStore();
      expect(result.length, 1);
      expect(result.first.animalUuid, 'uuid-1');
    });

    // Note: testing with null store is not feasible because useAnimalStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });
}
