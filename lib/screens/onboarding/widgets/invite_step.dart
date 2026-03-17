import 'package:flutter/material.dart';

final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

class InviteStep extends StatelessWidget {
  final List<String> emails;
  final ValueChanged<List<String>> onEmailsChanged;

  const InviteStep({
    super.key,
    required this.emails,
    required this.onEmailsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invite Users',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Invite users to your organization to get started.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ...List.generate(emails.length, (index) {
          final email = emails[index];
          final hasError = email.isNotEmpty && !_emailRegex.hasMatch(email);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: hasError ? 'Invalid email' : null,
                      border: const OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: email)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: email.length),
                      ),
                    onChanged: (value) {
                      final updated = List<String>.from(emails);
                      updated[index] = value;
                      onEmailsChanged(updated);
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: emails.length > 1
                      ? () {
                          final updated = List<String>.from(emails);
                          updated.removeAt(index);
                          onEmailsChanged(updated);
                        }
                      : null,
                ),
              ],
            ),
          );
        }),
        Center(
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              onEmailsChanged([...emails, '']);
            },
          ),
        ),
      ],
    );
  }
}
