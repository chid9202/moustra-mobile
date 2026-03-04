import 'package:flutter/material.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/notification_dto.dart';
import 'package:moustra/widgets/changes_diff.dart';

class NotificationItem extends StatelessWidget {
  final NotificationDto notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'product_update':
        return Icons.new_releases;
      case 'item_update':
        return Icons.edit_notifications;
      case 'wean_reminder':
        return Icons.event_note;
      case 'protocol_alert':
        return Icons.warning;
      case 'task_alert':
        return Icons.assignment_turned_in;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changes = notification.changes;

    return ListTile(
      leading: Icon(_iconForType(notification.notificationType)),
      title: Text(
        notification.title,
        style: notification.isRead
            ? null
            : const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (changes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ChangesDiff(changes: changes, compact: true),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateTimeHelper.formatRelativeTime(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (!notification.isRead)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
