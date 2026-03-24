import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

class RecentActivityCard extends StatelessWidget {
  final List<RecentActivityDto> activities;

  const RecentActivityCard({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 32, color: Colors.grey.shade400),
                  const SizedBox(height: 4),
                  Text(
                    'No recent activity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...activities.take(15).map((activity) {
            final config = _activityConfig(activity.type);
            final navPath = _getNavigationPath(activity);

            return InkWell(
              onTap: navPath != null ? () => context.go(navPath) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(config.icon, size: 20, color: config.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.description,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (activity.detail != null)
                            Text(
                              activity.detail!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeDate(activity.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  String? _getNavigationPath(RecentActivityDto activity) {
    if (activity.linkUuid == null) return null;
    switch (activity.type) {
      case 'litter_born':
        return '/litter/${activity.linkUuid}';
      case 'mating_setup':
      case 'mating_disbanded':
        return '/mating/${activity.linkUuid}';
      default:
        return null;
    }
  }

  String _relativeDate(String dateStr) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (dateStr == todayStr) return 'Today';
    if (dateStr == yesterdayStr) return 'Yesterday';

    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    final diff = now.difference(parsed).inDays;
    if (diff <= 7) return '$diff days ago';
    return dateStr;
  }

  _ActivityConfig _activityConfig(String type) {
    switch (type) {
      case 'litter_born':
        return _ActivityConfig(Icons.child_care, Colors.green);
      case 'animals_weaned':
        return _ActivityConfig(Icons.check_circle, Colors.blue);
      case 'mating_setup':
        return _ActivityConfig(Icons.favorite, Colors.pink);
      case 'mating_disbanded':
        return _ActivityConfig(Icons.heart_broken, Colors.grey);
      case 'animals_ended':
        return _ActivityConfig(Icons.remove_circle, Colors.red);
      default:
        return _ActivityConfig(Icons.circle, Colors.grey);
    }
  }
}

class _ActivityConfig {
  final IconData icon;
  final Color color;

  _ActivityConfig(this.icon, this.color);
}
