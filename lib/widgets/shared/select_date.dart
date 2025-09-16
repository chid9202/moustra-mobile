import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDate extends StatelessWidget {
  const SelectDate({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? selectedDate;
  final Function(DateTime?) onChanged;
  final String labelText;
  final String? hintText;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : hintText ?? 'Select date',
              style: TextStyle(
                color: selectedDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).hintColor,
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
