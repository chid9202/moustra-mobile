import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/stores/background_store.dart';

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
    backgroundStore.value = null;
  });

  tearDown(() {
    backgroundStore.value = null;
  });

  group('useBackgroundStore', () {
    test('returns existing list when store is populated', () async {
      final backgrounds = [
        BackgroundStoreDto(id: 1, uuid: 'uuid-1', name: 'C57BL/6'),
      ];
      backgroundStore.value = backgrounds;

      final result = await useBackgroundStore();
      expect(result.length, 1);
      expect(result.first.uuid, 'uuid-1');
    });

    // Note: testing with null store is not feasible because useBackgroundStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('getBackgroundsHook', () {
    test('returns all backgrounds when store is populated', () async {
      backgroundStore.value = [
        BackgroundStoreDto(id: 1, uuid: 'uuid-1', name: 'C57BL/6'),
        BackgroundStoreDto(id: 2, uuid: 'uuid-2', name: 'BALB/c'),
      ];

      final result = await getBackgroundsHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      backgroundStore.value = [];
      final result = await getBackgroundsHook();
      expect(result, isEmpty);
    });
  });

  group('getBackgroundHook', () {
    test('returns matching background when uuid exists', () async {
      backgroundStore.value = [
        BackgroundStoreDto(id: 1, uuid: 'uuid-1', name: 'C57BL/6'),
        BackgroundStoreDto(id: 2, uuid: 'uuid-2', name: 'BALB/c'),
      ];

      final result = await getBackgroundHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.uuid, 'uuid-2');
      expect(result.name, 'BALB/c');
    });

    test('returns first match from populated store', () async {
      backgroundStore.value = [
        BackgroundStoreDto(id: 1, uuid: 'uuid-1', name: 'C57BL/6'),
      ];

      final result = await getBackgroundHook('uuid-1');
      expect(result, isNotNull);
      expect(result!.name, 'C57BL/6');
    });
  });

  group('backgroundStore value', () {
    test('can be set and read', () {
      final backgrounds = [
        BackgroundStoreDto(id: 1, uuid: 'uuid-1', name: 'C57BL/6'),
      ];
      backgroundStore.value = backgrounds;

      expect(backgroundStore.value, isNotNull);
      expect(backgroundStore.value!.length, 1);
      expect(backgroundStore.value!.first.name, 'C57BL/6');
    });

    test('defaults to null', () {
      expect(backgroundStore.value, isNull);
    });
  });
}
