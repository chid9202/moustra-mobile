import 'package:flutter/material.dart';
import 'package:moustra/services/clients/report_api.dart';
import 'package:moustra/services/dtos/report_dto.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  late Future<List<WeeklyReportSummaryDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = reportApi.getWeeklyReports();
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final d = DateTime(year, month, day);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeeklyReportSummaryDto>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load reports: ${snapshot.error}'),
          );
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Text(
                'No weekly reports yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                title: Text(
                  'Weekly Report — ${_formatDate(report.date)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  'View Report',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  // TODO: Navigate to report detail when route is available
                },
              ),
            );
          },
        );
      },
    );
  }
}
