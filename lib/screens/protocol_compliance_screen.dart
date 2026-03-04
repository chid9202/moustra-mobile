import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/protocol_api.dart';
import 'package:moustra/services/dtos/compliance_summary_dto.dart';
import 'package:moustra/services/dtos/protocol_alert_dto.dart';

class ProtocolComplianceScreen extends StatefulWidget {
  const ProtocolComplianceScreen({super.key});

  @override
  State<ProtocolComplianceScreen> createState() =>
      _ProtocolComplianceScreenState();
}

class _ProtocolComplianceScreenState extends State<ProtocolComplianceScreen> {
  ComplianceSummaryDto? _summary;
  List<ProtocolAlertDto> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        protocolApi.getComplianceSummary(),
        protocolApi.getAlerts(),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as ComplianceSummaryDto;
          _alerts = results[1] as List<ProtocolAlertDto>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int _computeComplianceScore(ComplianceSummaryDto summary) {
    // Simple compliance score: penalize for issues
    if (summary.totalActive == 0) return 100;
    int score = 100;
    score -= summary.expiredUnresolved * 15;
    score -= summary.overAnimalLimit * 10;
    score -= summary.animalsWithoutProtocol > 0 ? 10 : 0;
    score -= summary.expiring30d * 5;
    score -= summary.nearAnimalLimit * 3;
    score -= summary.unacknowledgedAlerts * 2;
    return score.clamp(0, 100);
  }

  Color _scoreColor(int score) {
    if (score >= 95) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }

  Color _alertTypeColor(String alertType) {
    if (alertType.contains('expired') || alertType.contains('exceeded')) {
      return Colors.red;
    }
    if (alertType.contains('30d') || alertType.contains('warning')) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  IconData _alertTypeIcon(String alertType) {
    if (alertType.contains('expired') || alertType.contains('exceeded')) {
      return Icons.error;
    }
    if (alertType.contains('30d') || alertType.contains('warning')) {
      return Icons.warning_amber;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading compliance data',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final summary = _summary!;
    final score = _computeComplianceScore(summary);
    final color = _scoreColor(score);
    final criticalAlerts = _alerts
        .where((a) => !a.isResolved && a.acknowledgedAt == null)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Compliance Score
            _buildScoreCard(score, color),
            const SizedBox(height: 16),

            // 2. Critical Alerts
            if (criticalAlerts.isNotEmpty) ...[
              Text(
                'Active Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...criticalAlerts.map((alert) => _buildAlertCard(alert)),
              const SizedBox(height: 16),
            ],

            // 3. Quick Stats
            _buildQuickStats(summary),
            const SizedBox(height: 16),

            // 4. Fix Issues Button
            if (summary.animalsWithoutProtocol > 0 ||
                summary.expiredUnresolved > 0 ||
                summary.overAnimalLimit > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to protocols list filtered by issues
                    context.go('/protocol');
                  },
                  icon: const Icon(Icons.build),
                  label: const Text('Fix Issues'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Compliance Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              score >= 95
                  ? 'Fully Compliant'
                  : score >= 80
                      ? 'Attention Needed'
                      : 'Action Required',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(ProtocolAlertDto alert) {
    final color = _alertTypeColor(alert.alertType);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        leading: Icon(_alertTypeIcon(alert.alertType), color: color),
        title: Text(
          alert.alertType.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
        subtitle: Text(
          alert.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message),
                const SizedBox(height: 8),
                Text(
                  'Triggered: ${alert.triggeredAt}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (alert.alertUuid != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _acknowledgeAlert(alert),
                      child: const Text('Acknowledge'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledgeAlert(ProtocolAlertDto alert) async {
    if (alert.alertUuid == null) return;
    try {
      await protocolApi.acknowledgeAlert(alert.alertUuid!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert acknowledged')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildQuickStats(ComplianceSummaryDto summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(
              label: 'Active\nProtocols',
              value: '${summary.totalActive}',
              color: Colors.green,
              icon: Icons.assignment,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              label: 'Expiring\n<30 days',
              value: '${summary.expiring30d}',
              color: summary.expiring30d > 0 ? Colors.orange : Colors.green,
              icon: Icons.timer,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(
              label: 'Expired\nUnresolved',
              value: '${summary.expiredUnresolved}',
              color:
                  summary.expiredUnresolved > 0 ? Colors.red : Colors.green,
              icon: Icons.error_outline,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              label: 'Uncovered\nAnimals',
              value: '${summary.animalsWithoutProtocol}',
              color: summary.animalsWithoutProtocol > 0
                  ? Colors.red
                  : Colors.green,
              icon: Icons.pets,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(
              label: 'Over Animal\nLimit',
              value: '${summary.overAnimalLimit}',
              color:
                  summary.overAnimalLimit > 0 ? Colors.red : Colors.green,
              icon: Icons.trending_up,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              label: 'Near Animal\nLimit',
              value: '${summary.nearAnimalLimit}',
              color:
                  summary.nearAnimalLimit > 0 ? Colors.orange : Colors.green,
              icon: Icons.warning_amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
