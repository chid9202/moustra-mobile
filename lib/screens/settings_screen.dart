import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/services/session_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Restart Onboarding'),
            subtitle: const Text('Go through the setup flow again'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restart Onboarding?'),
                  content: const Text(
                    'This will take you back to the onboarding flow. '
                    'Your existing data will not be deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              await sessionService.setOnboarded(false);
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
          ),
        ),
      ],
    );
  }
}
