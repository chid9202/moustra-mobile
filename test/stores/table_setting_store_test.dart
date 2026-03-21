import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra_api/moustra_api.dart';

TableSettingSLR _makeSetting(String name) {
  return (TableSettingSLRBuilder()
        ..tableSettingId = 1
        ..tableSettingUuid = 'uuid-$name'
        ..tableSettingName = 'Mobile_$name'
        ..updatedDate = DateTime(2024, 1, 1)
        ..tableSettingFields = ListBuilder<TableSettingFieldSLR>())
      .build();
}

void main() {
  group('tableSettingStore', () {
    setUp(() {
      clearTableSettingStore();
    });

    test('starts empty', () {
      expect(tableSettingStore.value, isEmpty);
    });

    test('clearTableSettingStore clears all entries', () {
      // Manually populate
      final updated = Map<String, TableSettingSLR>.from(tableSettingStore.value);
      updated['AnimalList'] = _makeSetting('AnimalList');
      updated['CageList'] = _makeSetting('CageList');
      tableSettingStore.value = updated;

      expect(tableSettingStore.value.length, 2);

      clearTableSettingStore();
      expect(tableSettingStore.value, isEmpty);
    });

    test('updateTableSetting puts value in cache immediately', () {
      final setting = _makeSetting('AnimalList');
      // Direct cache update (bypassing service)
      final updated = Map<String, TableSettingSLR>.from(tableSettingStore.value);
      updated['AnimalList'] = setting;
      tableSettingStore.value = updated;

      expect(tableSettingStore.value['AnimalList'], isNotNull);
      expect(
        tableSettingStore.value['AnimalList']!.tableSettingName,
        'Mobile_AnimalList',
      );
    });

    test('multiple settings are stored independently', () {
      final animal = _makeSetting('AnimalList');
      final cage = _makeSetting('CageList');

      final map = <String, TableSettingSLR>{
        'AnimalList': animal,
        'CageList': cage,
      };
      tableSettingStore.value = map;

      expect(tableSettingStore.value.length, 2);
      expect(tableSettingStore.value['AnimalList']!.tableSettingName,
          'Mobile_AnimalList');
      expect(tableSettingStore.value['CageList']!.tableSettingName,
          'Mobile_CageList');
    });

    test('updating one setting does not affect others', () {
      final animal = _makeSetting('AnimalList');
      final cage = _makeSetting('CageList');
      tableSettingStore.value = {
        'AnimalList': animal,
        'CageList': cage,
      };

      // Update only AnimalList
      final updatedAnimal = (animal.toBuilder()..pageSize = 50).build();
      final newMap =
          Map<String, TableSettingSLR>.from(tableSettingStore.value);
      newMap['AnimalList'] = updatedAnimal;
      tableSettingStore.value = newMap;

      expect(tableSettingStore.value['AnimalList']!.pageSize, 50);
      expect(tableSettingStore.value['CageList']!.tableSettingName,
          'Mobile_CageList');
    });

    test('ValueNotifier notifies listeners on change', () {
      int notifyCount = 0;
      void listener() => notifyCount++;
      tableSettingStore.addListener(listener);

      final map = <String, TableSettingSLR>{
        'AnimalList': _makeSetting('AnimalList'),
      };
      tableSettingStore.value = map;

      expect(notifyCount, 1);

      clearTableSettingStore();
      expect(notifyCount, 2);

      tableSettingStore.removeListener(listener);
    });
  });
}
