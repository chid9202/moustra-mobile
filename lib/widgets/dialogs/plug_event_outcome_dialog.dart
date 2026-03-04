import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/record_outcome_dto.dart';
import 'package:moustra/widgets/shared/select_date.dart';

class PlugEventOutcomeDialog extends StatefulWidget {
  final PlugEventDto plugEvent;

  const PlugEventOutcomeDialog({super.key, required this.plugEvent});

  @override
  State<PlugEventOutcomeDialog> createState() => _PlugEventOutcomeDialogState();
}

class _PlugEventOutcomeDialogState extends State<PlugEventOutcomeDialog> {
  static const _outcomeOptions = [
    ('live_birth', 'Live Birth'),
    ('harvest', 'Harvest'),
    ('resorption', 'Resorption'),
    ('no_pregnancy', 'No Pregnancy'),
    ('cancelled', 'Cancelled'),
  ];

  String? _selectedOutcome;
  DateTime? _selectedDate = DateTime.now();
  final _embryosController = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    if (_selectedOutcome == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select outcome and date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dto = RecordOutcomeDto(
        outcome: _selectedOutcome!,
        outcomeDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        embryosCollected: _selectedOutcome == 'harvest' &&
                _embryosController.text.isNotEmpty
            ? int.tryParse(_embryosController.text)
            : null,
      );

      final result = await plugService.recordOutcome(
        widget.plugEvent.plugEventUuid,
        dto,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording outcome: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _embryosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Outcome'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedOutcome,
              decoration: const InputDecoration(
                labelText: 'Outcome *',
                border: OutlineInputBorder(),
              ),
              items: _outcomeOptions
                  .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedOutcome = value);
              },
            ),
            const SizedBox(height: 16),
            SelectDate(
              selectedDate: _selectedDate,
              onChanged: (date) {
                setState(() => _selectedDate = date);
              },
              labelText: 'Outcome Date *',
            ),
            if (_selectedOutcome == 'harvest') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _embryosController,
                decoration: const InputDecoration(
                  labelText: 'Embryos Collected',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
