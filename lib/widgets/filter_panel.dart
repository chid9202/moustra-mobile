import 'package:flutter/material.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';

/// A reusable filter panel widget for list pages
class FilterPanel extends StatefulWidget {
  final List<FilterFieldDefinition> filterFields;
  final List<SortFieldDefinition> sortFields;
  final List<FilterParam> initialFilters;
  final SortParam? initialSort;
  final void Function(List<FilterParam> filters, SortParam? sort) onApply;
  final VoidCallback? onClear;
  final List<PreparedFilter> preparedFilters;
  final int selectedPresetIndex;
  final ValueChanged<int>? onPresetSelected;
  final VoidCallback? onColumnSettingsTap;
  final String? searchPlaceholder;
  final void Function(String term)? onSearchSubmitted;

  const FilterPanel({
    super.key,
    required this.filterFields,
    required this.sortFields,
    required this.onApply,
    this.initialFilters = const [],
    this.initialSort,
    this.onClear,
    this.preparedFilters = const [],
    this.selectedPresetIndex = -1,
    this.onPresetSelected,
    this.onColumnSettingsTap,
    this.searchPlaceholder,
    this.onSearchSubmitted,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late List<_FilterRow> _filterRows;
  String? _sortField;
  SortOrder _sortOrder = SortOrder.desc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFromProps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPresetIndex != oldWidget.selectedPresetIndex &&
        widget.selectedPresetIndex >= 0) {
      _initializeFromProps();
    }
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Search bar
          if (widget.onSearchSubmitted != null)
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) =>
                    widget.onSearchSubmitted!(_searchController.text),
                decoration: InputDecoration(
                  hintText: widget.searchPlaceholder ?? 'Search',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                ),
              ),
            ),
          if (widget.onSearchSubmitted != null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () =>
                  widget.onSearchSubmitted!(_searchController.text),
              tooltip: 'Search',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          const SizedBox(width: 4),
          // Filter toggle button — opens bottom sheet
          InkWell(
            onTap: () => _showFilterSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 20,
                    color: hasFilters ? theme.colorScheme.primary : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters & Sort',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: hasFilters ? theme.colorScheme.primary : null,
                    ),
                  ),
                  if (hasFilters) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_filterRows.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasFilters = _filterRows.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Column settings
                      if (widget.onColumnSettingsTap != null) ...[
                        ActionChip(
                          avatar: const Icon(Icons.view_column, size: 16),
                          label: const Text(
                            'Columns',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onColumnSettingsTap!();
                          },
                          visualDensity: VisualDensity.compact,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Saved view presets
                      if (widget.preparedFilters.isNotEmpty) ...[
                        DropdownButtonFormField<int>(
                          initialValue: widget.selectedPresetIndex >= 0
                              ? widget.selectedPresetIndex
                              : null,
                          isDense: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                            labelText: 'Saved View',
                          ),
                          items: List.generate(
                            widget.preparedFilters.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                  widget.preparedFilters[index].name),
                            ),
                          ),
                          onChanged: (index) {
                            if (index != null) {
                              widget.onPresetSelected?.call(index);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Sort row
                      _buildSortRow(theme, setSheetState),

                      // Filter rows
                      if (_filterRows.isNotEmpty) ...[
                        Text('Filters',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        ..._filterRows.asMap().entries.map((entry) {
                          return _buildFilterRow(
                            entry.key,
                            entry.value,
                            theme,
                            setSheetState,
                          );
                        }),
                      ],

                      // Add filter and action buttons row
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed:
                                _getAvailableFields().isNotEmpty
                                    ? () {
                                        _addFilter();
                                        setSheetState(() {});
                                      }
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
                              onPressed: () {
                                _clearAll();
                                Navigator.pop(context);
                              },
                              child: const Text('Clear All'),
                            ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortRow(ThemeData theme, [StateSetter? setSheetState]) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _sortField,
            isDense: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
              labelText: 'Sort by',
            ),
            items: widget.sortFields.map((f) {
              return DropdownMenuItem(value: f.field, child: Text(f.label));
            }).toList(),
            onChanged: (value) {
              setState(() => _sortField = value);
              setSheetState?.call(() {});
            },
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<SortOrder>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: SortOrder.asc,
              icon: Icon(Icons.arrow_upward, size: 18),
            ),
            ButtonSegment(
              value: SortOrder.desc,
              icon: Icon(Icons.arrow_downward, size: 18),
            ),
          ],
          selected: {_sortOrder},
          onSelectionChanged: (selection) {
            setState(() => _sortOrder = selection.first);
            setSheetState?.call(() {});
          },
        ),
      ],
    );
  }

  Widget _buildFilterRow(int index, _FilterRow row, ThemeData theme, [StateSetter? setSheetState]) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Field + Operator + Remove button
          Row(
            children: [
              Expanded(
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
                  onChanged: (value) {
                    _updateFilterField(index, value);
                    setSheetState?.call(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
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
                  onChanged: (value) {
                    _updateFilterOperator(index, value);
                    setSheetState?.call(() {});
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  _removeFilter(index);
                  setSheetState?.call(() {});
                },
                tooltip: 'Remove filter',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          // Row 2: Value input (full width, only if operator requires a value)
          if (requiresValue)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: isSelectType && fieldDef?.selectOptions != null
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
                          setSheetState?.call(() {});
                        }
                      },
                    )
                  : isDateType
                  ? _DatePickerField(
                      value: row.value,
                      onChanged: (value) {
                        _updateFilterValue(index, value);
                        setSheetState?.call(() {});
                      },
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
                      onChanged: (value) {
                        _updateFilterValue(index, value);
                        setSheetState?.call(() {});
                      },
                    ),
            ),
          if (index < _filterRows.length - 1)
            const Divider(height: 16),
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
