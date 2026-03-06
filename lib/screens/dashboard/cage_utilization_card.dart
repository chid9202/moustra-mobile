import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CageUtilizationCard extends StatelessWidget {
  const CageUtilizationCard(this.cageUtilization, {super.key});

  final Map<String, dynamic>? cageUtilization;

  Color _utilizationColor(double percentage) {
    if (percentage >= 80) return Colors.red;
    if (percentage >= 60) return Colors.orange;
    return Colors.green;
  }

  String _formatUtilization(dynamic utilization) {
    if (utilization == null) return '0%';
    final val = (utilization is int)
        ? utilization.toDouble()
        : (utilization as num).toDouble();
    return '${(val * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (cageUtilization == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cage Utilization',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No cage utilization data available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    final labUtilization =
        (cageUtilization!['labUtilizationPercentage'] as num?)?.toDouble() ??
            0.0;
    final cagesAtRisk =
        (cageUtilization!['cagesAtRisk'] as List<dynamic>?) ?? [];
    final cagesAtRiskCount =
        (cageUtilization!['cagesAtRiskCount'] as int?) ?? cagesAtRisk.length;
    final cagesInViolation =
        (cageUtilization!['cagesInViolation'] as List<dynamic>?) ?? [];
    final cagesInViolationCount =
        (cageUtilization!['cagesInViolationCount'] as int?) ??
            cagesInViolation.length;

    final color = _utilizationColor(labUtilization);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cage Utilization',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Lab utilization percentage
        Center(
          child: Column(
            children: [
              Text(
                'Lab Utilization',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '${labUtilization.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cages At Risk
        if (cagesAtRiskCount > 0) ...[
          Row(
            children: [
              const Icon(Icons.warning, size: 18, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                'Cages At Risk ($cagesAtRiskCount)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...cagesAtRisk.map((cage) => _buildCageRow(context, cage)),
          const SizedBox(height: 12),
        ],

        // Cages In Violation
        if (cagesInViolationCount > 0) ...[
          Row(
            children: [
              const Icon(Icons.error, size: 18, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Cages In Violation ($cagesInViolationCount)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...cagesInViolation.map((cage) => _buildCageRow(context, cage)),
        ],

        // Empty state
        if (cagesAtRiskCount == 0 && cagesInViolationCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No cages at risk or in violation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCageRow(BuildContext context, dynamic cage) {
    final cageTag = (cage['cageTag'] ?? '').toString();
    final cageUuid = (cage['cageUuid'] ?? '').toString();
    final utilization = cage['utilization'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: cageUuid.isNotEmpty
            ? () => context.go('/cage/$cageUuid')
            : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cageTag.isEmpty ? '(no tag)' : cageTag,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Utilization: ${_formatUtilization(utilization)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
