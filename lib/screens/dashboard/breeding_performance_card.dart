import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

class BreedingPerformanceCard extends StatelessWidget {
  final BreedingPerformanceDto? breedingPerformance;

  const BreedingPerformanceCard({super.key, this.breedingPerformance});

  @override
  Widget build(BuildContext context) {
    final bp = breedingPerformance;

    final isEmpty =
        bp == null ||
        (bp.averageLitterSize == null &&
            bp.matingSuccessRate == null &&
            bp.medianTimeToFirstLitter == null &&
            bp.pupSurvivalRate == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Breeding Performance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (isEmpty) _buildEmptyState() else _buildContent(bp),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.pets, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No breeding data yet',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BreedingPerformanceDto bp) {
    return Column(
      children: [
        _buildStatGrid(bp),
        const SizedBox(height: 16),
        _buildChart(bp.littersPerMonth),
      ],
    );
  }

  Widget _buildStatGrid(BreedingPerformanceDto bp) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _buildStatTile(
          label: 'Avg Litter Size',
          value: bp.averageLitterSize != null
              ? bp.averageLitterSize!.toStringAsFixed(1)
              : '—',
          icon: Icons.pets,
          valueColor: Colors.blue.shade700,
        ),
        _buildStatTile(
          label: 'Mating Success',
          value: bp.matingSuccessRate != null
              ? '${bp.matingSuccessRate!.toStringAsFixed(0)}%'
              : '—',
          icon: Icons.favorite,
          valueColor: Colors.blue.shade700,
        ),
        _buildStatTile(
          label: 'Time to Litter',
          value: bp.medianTimeToFirstLitter != null
              ? '${bp.medianTimeToFirstLitter!.round()}d'
              : '—',
          icon: Icons.access_time,
          valueColor: Colors.blue.shade700,
        ),
        _buildStatTile(
          label: 'Pup Survival',
          value: bp.pupSurvivalRate != null
              ? '${bp.pupSurvivalRate!.toStringAsFixed(0)}%'
              : '—',
          icon: Icons.shield,
          valueColor: _getSurvivalColor(bp.pupSurvivalRate),
        ),
      ],
    );
  }

  Color _getSurvivalColor(double? rate) {
    if (rate == null) return Colors.grey;
    if (rate > 90) return Colors.green.shade700;
    if (rate >= 70) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    final monthNum = int.tryParse(parts[1]);
    if (monthNum == null || monthNum < 1 || monthNum > 12) return month;
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[monthNum - 1];
  }

  Widget _buildChart(List<LittersPerMonthDto> littersPerMonth) {
    if (littersPerMonth.isEmpty) return const SizedBox.shrink();

    final maxCount = littersPerMonth
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount + 2).toDouble();

    final spots = littersPerMonth.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < littersPerMonth.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatMonth(littersPerMonth[idx].month),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final idx = spot.x.toInt();
                  final month = idx >= 0 && idx < littersPerMonth.length
                      ? _formatMonth(littersPerMonth[idx].month)
                      : '';
                  return LineTooltipItem(
                    '$month: ${spot.y.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF4AAFCA),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFDCF0F4).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
