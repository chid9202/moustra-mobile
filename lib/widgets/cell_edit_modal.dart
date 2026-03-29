import 'package:flutter/material.dart';
import 'package:moustra/models/cell_edit_state.dart';

/// Shows a bottom sheet modal for editing a single cell value.
/// Used on mobile instead of inline editing.
///
/// Returns the new value if committed, or null if cancelled.
Future<dynamic> showCellEditModal({
  required BuildContext context,
  required String fieldLabel,
  required EditFieldConfig config,
  required dynamic currentValue,
  String? expandRecordLabel,
  VoidCallback? onExpandRecord,
}) {
  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _CellEditModalContent(
      fieldLabel: fieldLabel,
      config: config,
      currentValue: currentValue,
      expandRecordLabel: expandRecordLabel,
      onExpandRecord: onExpandRecord,
    ),
  );
}

class _CellEditModalContent extends StatefulWidget {
  final String fieldLabel;
  final EditFieldConfig config;
  final dynamic currentValue;
  final String? expandRecordLabel;
  final VoidCallback? onExpandRecord;

  const _CellEditModalContent({
    required this.fieldLabel,
    required this.config,
    required this.currentValue,
    this.expandRecordLabel,
    this.onExpandRecord,
  });

  @override
  State<_CellEditModalContent> createState() => _CellEditModalContentState();
}

class _CellEditModalContentState extends State<_CellEditModalContent> {
  late TextEditingController _textController;
  late dynamic _value;
  String? _error;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
    _textController = TextEditingController(
      text: widget.currentValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _commit() {
    dynamic commitValue = _value;

    if (widget.config.type == EditFieldType.text) {
      commitValue = _textController.text;
    }

    // Validate
    if (widget.config.validate != null) {
      final error = widget.config.validate!(commitValue);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }

    Navigator.pop(context, commitValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header: field label + save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  widget.fieldLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _commit,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Edit widget
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildEditWidget(),
          ),

          // Expand record button (for foreign key fields)
          if (widget.expandRecordLabel != null && widget.onExpandRecord != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onExpandRecord!();
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(widget.expandRecordLabel!),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ),

          // Bottom padding
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEditWidget() {
    switch (widget.config.type) {
      case EditFieldType.text:
        return TextField(
          controller: _textController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.fieldLabel,
            border: const OutlineInputBorder(),
            errorText: _error,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _commit(),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        );

      case EditFieldType.boolean:
        return Row(
          children: [
            Text(
              widget.fieldLabel,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Switch(
              value: _value as bool? ?? false,
              onChanged: (newValue) {
                setState(() => _value = newValue);
              },
            ),
          ],
        );

      case EditFieldType.select:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (widget.config.options ?? []).map((option) {
            final isSelected = option.value == _value?.toString();
            return ListTile(
              title: Text(option.label),
              trailing: isSelected
                  ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() => _value = option.value);
              },
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        );

      case EditFieldType.date:
        return InkWell(
          onTap: () async {
            DateTime initial = DateTime.now();
            if (_value != null && _value.toString().isNotEmpty) {
              final parsed = DateTime.tryParse(_value.toString());
              if (parsed != null) initial = parsed;
            }

            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                _value =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.fieldLabel,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _value?.toString() ?? 'Select date',
              style: TextStyle(
                color: _value != null ? null : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        );

      case EditFieldType.autocomplete:
        // Handled externally via entity picker — shouldn't reach here
        return const SizedBox.shrink();
    }
  }
}
