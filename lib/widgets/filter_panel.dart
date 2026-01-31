import 'package:flutter/material.dart';
import 'package:moustra/services/models/list_query_params.dart';

/// A reusable filter panel widget for list pages
class FilterPanel extends StatefulWidget {
  final List<FilterFieldDefinition> filterFields;
  final List<SortFieldDefinition> sortFields;
  final List<FilterParam> initialFilters;
  final SortParam? initialSort;
  final void Function(List<FilterParam> filters, SortParam? sort) onApply;
  final VoidCallback? onClear;

  const FilterPanel({
    super.key,
    required this.filterFields,
    required this.sortFields,
    required this.onApply,
    this.initialFilters = const [],
    this.initialSort,
    this.onClear,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _isExpanded = false;
  late List<_FilterRow> _filterRows;
  String? _sortField;
  SortOrder _sortOrder = SortOrder.desc;

  @override
  void initState() {
    super.initState();
    _initializeFromProps();
  }

  void _initializeFromProps() {
    // Initialize filters
    if (widget.initialFilters.isEmpty) {
      _filterRows = [];
    } else {
      _filterRows = widget.initialFilters.map((f) {
        final fieldDef = widget.filterFields
            .where((fd) => fd.field == f.field)
            .firstOrNull;
        return _FilterRow(
          selectedField: fieldDef,
          selectedOperator: f.operator,
          value: f.value ?? '',
        );
      }).toList();
    }

    // Initialize sort
    if (widget.initialSort != null) {
      _sortField = widget.initialSort!.field;
      _sortOrder = widget.initialSort!.order;
    } else if (widget.sortFields.isNotEmpty) {
      _sortField = widget.sortFields.first.field;
    }
  }

  /// Get fields that are already used in other filter rows
  Set<String> _getUsedFields({int? excludeIndex}) {
    final used = <String>{};
    for (int i = 0; i < _filterRows.length; i++) {
      if (i != excludeIndex && _filterRows[i].selectedField != null) {
        used.add(_filterRows[i].selectedField!.field);
      }
    }
    return used;
  }

  /// Get available fields (not yet used in other filters)
  List<FilterFieldDefinition> _getAvailableFields({int? excludeIndex}) {
    final usedFields = _getUsedFields(excludeIndex: excludeIndex);
    return widget.filterFields
        .where((f) => !usedFields.contains(f.field))
        .toList();
  }

  void _addFilter() {
    final availableFields = _getAvailableFields();
    if (availableFields.isEmpty) return;

    setState(() {
      _filterRows.add(
        _FilterRow(
          selectedField: availableFields.first,
          selectedOperator: availableFields.first.operators.first,
          value: '',
        ),
      );
    });
  }

  void _removeFilter(int index) {
    setState(() {
      _filterRows.removeAt(index);
    });
  }

  void _updateFilterField(int index, FilterFieldDefinition? field) {
    setState(() {
      _filterRows[index] = _FilterRow(
        selectedField: field,
        selectedOperator: field?.operators.first,
        value: '',
      );
    });
  }

  void _updateFilterOperator(int index, String? operator) {
    setState(() {
      _filterRows[index] = _filterRows[index].copyWith(
        selectedOperator: operator,
      );
    });
  }

  void _updateFilterValue(int index, String value) {
    setState(() {
      _filterRows[index] = _filterRows[index].copyWith(value: value);
    });
  }

  void _applyFilters() {
    final filters = <FilterParam>[];
    for (final row in _filterRows) {
      if (row.selectedField != null && row.selectedOperator != null) {
        // Only add value if operator requires it
        final requiresValue = FilterOperators.requiresValue(
          row.selectedOperator!,
        );
        if (!requiresValue || row.value.isNotEmpty) {
          filters.add(
            FilterParam(
              field: row.selectedField!.field,
              operator: row.selectedOperator!,
              value: requiresValue ? row.value : 'true',
            ),
          );
        }
      }
    }

    SortParam? sort;
    if (_sortField != null) {
      sort = SortParam(field: _sortField!, order: _sortOrder);
    }

    widget.onApply(filters, sort);
  }

  void _clearAll() {
    setState(() {
      _filterRows = [];
      if (widget.sortFields.isNotEmpty) {
        _sortField = widget.sortFields.first.field;
      }
      _sortOrder = SortOrder.desc;
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = _filterRows.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with toggle
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.filter_list_off : Icons.filter_list,
                  size: 20,
                  color: hasFilters ? theme.colorScheme.primary : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filters & Sort',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: hasFilters ? theme.colorScheme.primary : null,
                  ),
                ),
                if (hasFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filterRows.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expandable filter content
        if (_isExpanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sort row
                _buildSortRow(theme),

                // Filter rows
                if (_filterRows.isNotEmpty) ...[
                  Text('Filters', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  ..._filterRows.asMap().entries.map((entry) {
                    return _buildFilterRow(entry.key, entry.value, theme);
                  }),
                ],

                // Add filter and action buttons row
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _getAvailableFields().isNotEmpty
                          ? _addFilter
                          : null,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        _getAvailableFields().isNotEmpty
                            ? 'Add Filter'
                            : 'All filters added',
                      ),
                    ),
                    const Spacer(),
                    if (hasFilters)
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text('Clear All'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSortRow(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort by: ', style: theme.textTheme.titleSmall),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: DropdownButtonFormField<String>(
                initialValue: _sortField,
                isDense: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                items: widget.sortFields.map((f) {
                  return DropdownMenuItem(value: f.field, child: Text(f.label));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sortField = value;
                  });
                },
              ),
            ),
          ],
        ),
        SegmentedButton<SortOrder>(
          segments: const [
            ButtonSegment(
              value: SortOrder.asc,
              icon: Icon(Icons.arrow_upward, size: 16),
              label: Text('Asc'),
            ),
            ButtonSegment(
              value: SortOrder.desc,
              icon: Icon(Icons.arrow_downward, size: 16),
              label: Text('Desc'),
            ),
          ],
          selected: {_sortOrder},
          onSelectionChanged: (selection) {
            setState(() {
              _sortOrder = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterRow(int index, _FilterRow row, ThemeData theme) {
    final fieldDef = row.selectedField;
    final operators = fieldDef?.operators ?? [];
    final isSelectType = fieldDef?.type == FilterFieldType.select;
    final isDateType = fieldDef?.type == FilterFieldType.date;
    final requiresValue =
        row.selectedOperator != null &&
        FilterOperators.requiresValue(row.selectedOperator!);

    // Get available fields for this row (excluding fields used in other rows)
    final availableFields = _getAvailableFields(excludeIndex: index);
    // Include current selection in the dropdown if it exists
    final dropdownFields = <FilterFieldDefinition>[
      if (row.selectedField != null &&
          !availableFields.any((f) => f.field == row.selectedField!.field))
        row.selectedField!,
      ...availableFields,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<FilterFieldDefinition>(
              initialValue: row.selectedField,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
                hintText: 'Field',
              ),
              items: dropdownFields.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f.label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) => _updateFilterField(index, value),
            ),
          ),
          const SizedBox(width: 8),

          // Operator dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: operators.contains(row.selectedOperator)
                  ? row.selectedOperator
                  : null,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
                hintText: 'Operator',
              ),
              items: operators.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Text(
                    FilterOperators.getLabel(op),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) => _updateFilterOperator(index, value),
            ),
          ),
          const SizedBox(width: 8),

          // Value input (varies by field type)
          Expanded(
            flex: 2,
            child: requiresValue
                ? isSelectType && fieldDef?.selectOptions != null
                      ? DropdownButtonFormField<String>(
                          initialValue:
                              fieldDef!.selectOptions!.any(
                                (o) => o.value == row.value,
                              )
                              ? row.value
                              : null,
                          isDense: true,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Value',
                          ),
                          items: fieldDef.selectOptions!.map((o) {
                            return DropdownMenuItem(
                              value: o.value,
                              child: Text(o.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateFilterValue(index, value);
                            }
                          },
                        )
                      : isDateType
                      ? _DatePickerField(
                          value: row.value,
                          onChanged: (value) =>
                              _updateFilterValue(index, value),
                        )
                      : TextFormField(
                          initialValue: row.value,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Value',
                          ),
                          onChanged: (value) =>
                              _updateFilterValue(index, value),
                        )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),

          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => _removeFilter(index),
            tooltip: 'Remove filter',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Internal class to track filter row state
class _FilterRow {
  final FilterFieldDefinition? selectedField;
  final String? selectedOperator;
  final String value;

  _FilterRow({this.selectedField, this.selectedOperator, this.value = ''});

  _FilterRow copyWith({
    FilterFieldDefinition? selectedField,
    String? selectedOperator,
    String? value,
  }) {
    return _FilterRow(
      selectedField: selectedField ?? this.selectedField,
      selectedOperator: selectedOperator ?? this.selectedOperator,
      value: value ?? this.value,
    );
  }
}

/// Date picker field for date-type filters
class _DatePickerField extends StatefulWidget {
  final String value;
  final void Function(String) onChanged;

  const _DatePickerField({required this.value, required this.onChanged});

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime? initial;
    try {
      if (widget.value.isNotEmpty) {
        initial = DateTime.parse(widget.value);
      }
    } catch (_) {}

    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final formatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _controller.text = formatted;
      widget.onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: _pickDate,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
        hintText: 'YYYY-MM-DD',
        suffixIcon: Icon(Icons.calendar_today, size: 18),
      ),
    );
  }
}
