import 'package:flutter/material.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra_api/moustra_api.dart';

/// Shows a bottom sheet for toggling column visibility and reordering columns.
void showColumnSettingsSheet({
  required BuildContext context,
  required String baseName,
  required TableSettingSLR tableSetting,
  required VoidCallback onSettingsChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _ColumnSettingsSheet(
      baseName: baseName,
      tableSetting: tableSetting,
      onSettingsChanged: onSettingsChanged,
    ),
  );
}

class _ColumnSettingsSheet extends StatefulWidget {
  final String baseName;
  final TableSettingSLR tableSetting;
  final VoidCallback onSettingsChanged;

  const _ColumnSettingsSheet({
    required this.baseName,
    required this.tableSetting,
    required this.onSettingsChanged,
  });

  @override
  State<_ColumnSettingsSheet> createState() => _ColumnSettingsSheetState();
}

class _ColumnSettingsSheetState extends State<_ColumnSettingsSheet> {
  late List<TableSettingFieldSLR> _fields;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _fields = widget.tableSetting.tableSettingFields.toList()
      ..sort((a, b) => a.fieldOrder.compareTo(b.fieldOrder));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
    });
    _saveSettings();
  }

  void _onToggleVisibility(int index, bool visible) {
    setState(() {
      final field = _fields[index];
      _fields[index] = (field.toBuilder()..fieldVisible = visible).build();
    });
    _saveSettings();
  }

  void _saveSettings() {
    // Rebuild fields with updated fieldOrder
    final updatedFields = <TableSettingFieldSLR>[];
    for (int i = 0; i < _fields.length; i++) {
      updatedFields.add(
        (_fields[i].toBuilder()..fieldOrder = i).build(),
      );
    }
    _fields = updatedFields;

    final builder = widget.tableSetting.toBuilder();
    builder.tableSettingFields.replace(updatedFields);
    final updatedSetting = builder.build();

    updateTableSetting(widget.baseName, updatedSetting);
    widget.onSettingsChanged();
  }

  Future<void> _resetToDefaults() async {
    setState(() => _isResetting = true);
    final result = await refreshTableSetting(widget.baseName);
    if (result != null && mounted) {
      setState(() {
        _fields = result.tableSettingFields.toList()
          ..sort((a, b) => a.fieldOrder.compareTo(b.fieldOrder));
        _isResetting = false;
      });
      widget.onSettingsChanged();
    } else if (mounted) {
      setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.view_column, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Column Settings', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  if (_isResetting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: _resetToDefaults,
                      child: const Text('Reset to Defaults'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Reorderable column list
            Expanded(
              child: ReorderableListView.builder(
                scrollController: scrollController,
                itemCount: _fields.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final field = _fields[index];
                  return ListTile(
                    key: ValueKey(field.tableSettingFieldUuid),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Text(field.fieldLabel),
                    subtitle: Text(
                      field.fieldName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Switch(
                      value: field.fieldVisible,
                      onChanged: (value) => _onToggleVisibility(index, value),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
