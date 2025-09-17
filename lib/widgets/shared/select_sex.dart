import 'package:flutter/material.dart';
import 'package:moustra/constants/animal_constants.dart';

class SelectSex extends StatelessWidget {
  const SelectSex({
    super.key,
    required this.selectedSex,
    required this.onChanged,
  });
  final String? selectedSex;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedSex,
            decoration: InputDecoration(
              labelText: 'Sex',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String>(
                value: SexConstants.male,
                child: Text(SexConstants.male),
              ),
              DropdownMenuItem<String>(
                value: SexConstants.female,
                child: Text(SexConstants.female),
              ),
              DropdownMenuItem<String>(
                value: SexConstants.unknown,
                child: Text(SexConstants.unknown),
              ),
            ],
            onChanged: (String? value) {
              onChanged(value);
            },
          ),
        ),
        if (selectedSex != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              onChanged(null);
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            tooltip: 'Clear selection',
          ),
        ],
      ],
    );
  }
}
