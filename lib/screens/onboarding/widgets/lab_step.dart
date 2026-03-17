import 'package:flutter/material.dart';
import 'package:grid_view/models/account.dart';

class LabStep extends StatelessWidget {
  final String labName;
  final ValueChanged<String> onLabNameChanged;
  final AccountDetail? account;
  final String? error;

  const LabStep({
    super.key,
    required this.labName,
    required this.onLabNameChanged,
    this.account,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final hasInvited = account?.hasInvited ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasInvited
              ? "You're invited to join the lab ${account?.lab?.labName ?? ''}"
              : 'Tell us about your lab',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (hasInvited)
          Text(
            'Click Next to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
          )
        else ...[
          Text(
            'Enter your lab name to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Lab Name',
              errorText: error,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: labName)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: labName.length),
              ),
            onChanged: onLabNameChanged,
          ),
        ],
      ],
    );
  }
}
