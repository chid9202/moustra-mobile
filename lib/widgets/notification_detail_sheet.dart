import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/notification_dto.dart';
import 'package:moustra/widgets/changes_diff.dart';

class NotificationDetailSheet extends StatelessWidget {
  final NotificationDto notification;

  const NotificationDetailSheet({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final changes = notification.changes;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                notification.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                DateTimeHelper.formatRelativeTime(notification.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const Divider(height: 24),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (changes.isNotEmpty) ...[
                const SizedBox(height: 16),
                ChangesDiff(changes: changes),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (notification.link != null) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(notification.link!);
                      },
                      child: const Text('Open'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
