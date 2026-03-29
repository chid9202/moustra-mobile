/// Types of edit widgets that can appear in a cell.
enum EditFieldType {
  text,
  select,
  date,
  autocomplete,
  boolean,
}

/// Configuration for an editable field.
class EditFieldConfig {
  /// The column/field name (e.g., 'name', 'owner', 'active').
  final String field;

  /// Which edit widget to render.
  final EditFieldType type;

  /// For [EditFieldType.select]: the available options as {value: label} pairs.
  final List<SelectOption>? options;

  /// Optional validation — return an error string or null if valid.
  final String? Function(dynamic value)? validate;

  const EditFieldConfig({
    required this.field,
    required this.type,
    this.options,
    this.validate,
  });
}

/// A selectable option for [EditFieldType.select] fields.
class SelectOption {
  final String value;
  final String label;
  const SelectOption({required this.value, required this.label});
}

/// Tracks the state of a cell currently being edited.
class CellEditState {
  /// UUID of the row being edited.
  final String rowId;

  /// Column/field name being edited.
  final String field;

  /// The value before editing started.
  final dynamic originalValue;

  /// The current value during editing.
  final dynamic currentValue;

  /// Validation error (null if valid).
  final String? error;

  const CellEditState({
    required this.rowId,
    required this.field,
    required this.originalValue,
    this.currentValue,
    this.error,
  });

  CellEditState copyWith({
    dynamic currentValue,
    String? error,
  }) {
    return CellEditState(
      rowId: rowId,
      field: field,
      originalValue: originalValue,
      currentValue: currentValue ?? this.currentValue,
      error: error,
    );
  }
}
