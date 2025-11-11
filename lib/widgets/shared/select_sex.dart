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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text('Sex', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(value: SexConstants.male, label: Text('M')),
            ButtonSegment<String>(value: SexConstants.female, label: Text('F')),
            ButtonSegment<String>(
              value: SexConstants.unknown,
              label: Text('U'),
            ),
          ],
          selected: {if (selectedSex != null) selectedSex!},
          emptySelectionAllowed: true,
          onSelectionChanged: (newSelection) {
            if (newSelection.isEmpty) {
              onChanged(null);
            } else {
              onChanged(newSelection.first);
            }
          },
        ),
      ],
    );
  }
}
