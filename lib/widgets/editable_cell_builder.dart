import 'package:flutter/material.dart';
import 'package:moustra/models/cell_edit_state.dart';

/// Builds the appropriate edit widget for a cell based on its [EditFieldType].
class EditableCellBuilder {
  /// Returns an edit widget for the given field config and current value.
  static Widget build({
    required EditFieldConfig config,
    required dynamic value,
    required ValueChanged<dynamic> onCommit,
    required VoidCallback onCancel,
    String? error,
  }) {
    switch (config.type) {
      case EditFieldType.text:
        return _TextEditCell(
          value: value?.toString() ?? '',
          onCommit: onCommit,
          onCancel: onCancel,
          error: error,
        );
      case EditFieldType.boolean:
        return _BooleanEditCell(
          value: value as bool? ?? false,
          onCommit: onCommit,
        );
      case EditFieldType.select:
        return _SelectEditCell(
          value: value?.toString() ?? '',
          options: config.options ?? [],
          onCommit: onCommit,
          error: error,
        );
      case EditFieldType.date:
        return _DateEditCell(
          value: value?.toString(),
          onCommit: onCommit,
          onCancel: onCancel,
        );
      case EditFieldType.autocomplete:
        // Autocomplete uses entity_picker_sheet — handled at screen level
        return const SizedBox.shrink();
    }
  }
}

/// Inline text edit cell with auto-focus.
class _TextEditCell extends StatefulWidget {
  final String value;
  final ValueChanged<dynamic> onCommit;
  final VoidCallback onCancel;
  final String? error;

  const _TextEditCell({
    required this.value,
    required this.onCommit,
    required this.onCancel,
    this.error,
  });

  @override
  State<_TextEditCell> createState() => _TextEditCellState();
}

class _TextEditCellState extends State<_TextEditCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    // Auto-focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    widget.onCommit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: widget.error != null
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorText: widget.error,
          errorStyle: const TextStyle(fontSize: 10, height: 0.8),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _commit(),
        onTapOutside: (_) => _commit(),
      ),
    );
  }
}

/// Inline boolean toggle cell.
class _BooleanEditCell extends StatelessWidget {
  final bool value;
  final ValueChanged<dynamic> onCommit;

  const _BooleanEditCell({
    required this.value,
    required this.onCommit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Switch(
        value: value,
        onChanged: (newValue) => onCommit(newValue),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Inline select dropdown cell.
class _SelectEditCell extends StatelessWidget {
  final String value;
  final List<SelectOption> options;
  final ValueChanged<dynamic> onCommit;
  final String? error;

  const _SelectEditCell({
    required this.value,
    required this.options,
    required this.onCommit,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        initialValue: options.any((o) => o.value == value) ? value : null,
        items: options
            .map((o) => DropdownMenuItem(
                  value: o.value,
                  child: Text(o.label, style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) onCommit(newValue);
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          errorText: error,
        ),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

/// Date picker cell — taps open the date picker dialog.
class _DateEditCell extends StatelessWidget {
  final String? value;
  final ValueChanged<dynamic> onCommit;
  final VoidCallback onCancel;

  const _DateEditCell({
    required this.value,
    required this.onCommit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Immediately open date picker
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DateTime initial = DateTime.now();
      if (value != null && value!.isNotEmpty) {
        final parsed = DateTime.tryParse(value!);
        if (parsed != null) initial = parsed;
      }

      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        onCommit(
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
        );
      } else {
        onCancel();
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value ?? '',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
