import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';

class ActivePregnanciesCard extends StatefulWidget {
  const ActivePregnanciesCard({super.key});

  @override
  State<ActivePregnanciesCard> createState() => _ActivePregnanciesCardState();
}

class _ActivePregnanciesCardState extends State<ActivePregnanciesCard> {
  List<PlugEventDto> _activeEvents = [];
  int _dueSoonCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final activeResponse = await plugService.getActivePlugEvents(pageSize: 10);
      final dueSoonResponse =
          await plugService.getDueSoonPlugEvents(days: 3, pageSize: 1);
      if (mounted) {
        setState(() {
          _activeEvents = activeResponse.results.cast<PlugEventDto>();
          _dueSoonCount = dueSoonResponse.count;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active pregnancies: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Pregnancies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_dueSoonCount > 0)
              Chip(
                label: Text(
                  '$_dueSoonCount due soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
                backgroundColor: Colors.orange.shade50,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_activeEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No active pregnancies',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ..._activeEvents.take(10).map((event) {
            final tag = event.female?.physicalTag ?? '(no tag)';
            final eday = event.currentEday;
            final daysUntil = _daysUntilDelivery(event);

            return InkWell(
              onTap: () => context.go('/plug-event/${event.plugEventUuid}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tag,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        eday != null ? 'E${eday.toStringAsFixed(1)}' : '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _edayColor(eday, event.targetEday),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        daysUntil != null ? '$daysUntil days' : '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: daysUntil != null && daysUntil <= 3
                              ? Colors.orange
                              : Colors.grey.shade600,
                        ),
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

  int? _daysUntilDelivery(PlugEventDto event) {
    final start = event.expectedDeliveryStart;
    if (start == null) return null;
    return start.difference(DateTime.now()).inDays;
  }

  Color _edayColor(double? current, double? target) {
    if (current == null || target == null) return Colors.grey;
    if (current > target) return Colors.red;
    if (current >= target - 1) return Colors.orange;
    return Colors.green;
  }
}
