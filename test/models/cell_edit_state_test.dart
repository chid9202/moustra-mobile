import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/models/cell_edit_state.dart';

void main() {
  group('CellEditState', () {
    test('copyWith updates currentValue and error', () {
      const state = CellEditState(
        rowId: 'r1',
        field: 'name',
        originalValue: 'a',
        currentValue: 'a',
      );
      final next = state.copyWith(currentValue: 'b', error: 'bad');
      expect(next.rowId, 'r1');
      expect(next.field, 'name');
      expect(next.originalValue, 'a');
      expect(next.currentValue, 'b');
      expect(next.error, 'bad');
    });

    test('copyWith preserves currentValue when omitted', () {
      const state = CellEditState(
        rowId: 'r1',
        field: 'f',
        originalValue: 1,
        currentValue: 2,
      );
      final next = state.copyWith(error: 'e');
      expect(next.currentValue, 2);
      expect(next.error, 'e');
    });
  });

  group('EditFieldConfig', () {
    test('validate can reject values', () {
      final config = EditFieldConfig(
        field: 'name',
        type: EditFieldType.text,
        validate: (v) => (v as String).isEmpty ? 'required' : null,
      );
      expect(config.validate!(''), 'required');
      expect(config.validate!('ok'), isNull);
    });
  });

  group('SelectOption', () {
    test('holds value and label', () {
      const o = SelectOption(value: 'v', label: 'L');
      expect(o.value, 'v');
      expect(o.label, 'L');
    });
  });
}
