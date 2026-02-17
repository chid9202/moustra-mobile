import 'package:moustra/services/models/list_query_params.dart';

class PreparedFilter {
  final String name;
  final List<FilterParam> filters;
  final SortParam? sort;

  const PreparedFilter({
    required this.name,
    this.filters = const [],
    this.sort,
  });

  /// Returns the index of the preset whose filters and sort match the given
  /// values, or -1 if no preset matches.
  ///
  /// For operators that don't require a value (isEmpty / isNotEmpty), the
  /// value field is ignored during comparison because the FilterPanel
  /// normalizes those values to `'true'` while presets may use `''` or null.
  static int findMatchingPreset(
    List<PreparedFilter> presets,
    List<FilterParam> filters,
    SortParam? sort,
  ) {
    for (int i = 0; i < presets.length; i++) {
      final preset = presets[i];
      if (_filtersMatch(preset.filters, filters) && preset.sort == sort) {
        return i;
      }
    }
    return -1;
  }

  static bool _filtersMatch(
    List<FilterParam> presetFilters,
    List<FilterParam> appliedFilters,
  ) {
    if (presetFilters.length != appliedFilters.length) return false;
    for (int i = 0; i < presetFilters.length; i++) {
      final p = presetFilters[i];
      final a = appliedFilters[i];
      if (p.field != a.field || p.operator != a.operator) return false;
      // Skip value comparison for operators that don't require a value
      if (FilterOperators.requiresValue(p.operator) && p.value != a.value) {
        return false;
      }
    }
    return true;
  }
}
