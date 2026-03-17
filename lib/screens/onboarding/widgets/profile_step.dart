import 'package:flutter/material.dart';

const List<String> positionOptions = [
  'Principal Investigator',
  'Professor',
  'Lab Manager',
  'Scientist',
  'Technician',
  'Student',
  'Other',
];

class ProfileStep extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String position;
  final String otherPosition;
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onOtherPositionChanged;
  final bool showNameFields;
  final String? firstNameError;
  final String? lastNameError;

  const ProfileStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.otherPosition,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onPositionChanged,
    required this.onOtherPositionChanged,
    this.showNameFields = true,
    this.firstNameError,
    this.lastNameError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us who you are',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (showNameFields) ...[
          TextField(
            decoration: InputDecoration(
              labelText: 'First Name',
              errorText: firstNameError,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: firstName)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: firstName.length),
              ),
            onChanged: onFirstNameChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Last Name',
              errorText: lastNameError,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: lastName)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: lastName.length),
              ),
            onChanged: onLastNameChanged,
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Position',
            border: OutlineInputBorder(),
          ),
          initialValue: position.isEmpty ? null : position,
          items: positionOptions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onPositionChanged(value);
              if (value != 'Other') {
                onOtherPositionChanged(value);
              } else {
                onOtherPositionChanged('');
              }
            }
          },
        ),
        if (position == 'Other') ...[
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Other',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: otherPosition)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: otherPosition.length),
              ),
            onChanged: onOtherPositionChanged,
          ),
        ],
      ],
    );
  }
}
