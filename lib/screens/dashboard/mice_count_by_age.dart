import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class MouseCountByAge extends StatefulWidget {
  const MouseCountByAge(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<MouseCountByAge> createState() => _MouseCountByAgeState();
}

class _MouseCountByAgeState extends State<MouseCountByAge> {
  String _selectedStrainUuid = '00000000-0000-0000-0000-000000000000';

  late final Map<String, dynamic> accounts;
  late final List<dynamic> animalByAge;
  late final List<dynamic> animalsSexRatio;
  late final List<dynamic> animalsToWean;

  late final List<Map<String, dynamic>> strains;

  @override
  void initState() {
    super.initState();
    accounts =
        (widget.data['accounts'] as Map<String, dynamic>? ??
        <String, dynamic>{});
    animalByAge = (widget.data['animalByAge'] as List<dynamic>? ?? <dynamic>[]);
    animalsSexRatio =
        (widget.data['animalsSexRatio'] as List<dynamic>? ?? <dynamic>[]);
    animalsToWean =
        (widget.data['animalsToWean'] as List<dynamic>? ?? <dynamic>[]);

    strains = animalByAge.cast<Map<String, dynamic>>()
      ..sort((a, b) {
        const allUuid = '00000000-0000-0000-0000-000000000000';
        if ((a['strainUuid'] ?? '') == allUuid) return -1;
        if ((b['strainUuid'] ?? '') == allUuid) return 1;
        return 0;
      });
  }

  List<Map<String, dynamic>> get _sortedAgeData {
    final selected = strains.firstWhere(
      (s) => (s['strainUuid'] ?? '') == _selectedStrainUuid,
      orElse: () => strains.isNotEmpty ? strains.first : <String, dynamic>{},
    );
    final ageData = (selected['ageData'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final sorted = List<Map<String, dynamic>>.from(ageData)
      ..sort(
        (a, b) => ((a['sortOrder'] as int?) ?? 0).compareTo(
          (b['sortOrder'] as int?) ?? 0,
        ),
      );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final ageData = _sortedAgeData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mice Count by Age',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedStrainUuid,
                  items: strains
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: (s['strainUuid'] ?? '').toString(),
                          child: Text(
                            (s['strainName'] ?? 'All').toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedStrainUuid = v);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: true),
                borderData: borderData,
                titlesData: _buildTitlesData(ageData),
                barTouchData: _buildBarTouchData(ageData),
                barGroups: _buildBarGroups(ageData),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData _buildBarTouchData(List<Map<String, dynamic>> ageData) =>
      BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          fitInsideVertically: true,
          fitInsideHorizontally: true,
          getTooltipColor: (group) => const Color(0xFF2D3142),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipMargin: 8,
          getTooltipItem:
              (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                final count = rod.toY;
                final label = groupIndex < ageData.length
                    ? (ageData[groupIndex]['ageBucket'] ?? '').toString()
                    : '';
                return BarTooltipItem(
                  '${count.toStringAsFixed(0)}'
                  ' ${count == 1 ? 'mouse' : 'mice'}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
        ),
      );

  FlTitlesData _buildTitlesData(List<Map<String, dynamic>> ageData) =>
      FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (value, meta) {
              if (value != value.roundToDouble()) {
                return Container();
              }
              return Transform.rotate(
                angle: -0.5,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameSize: 20,
          axisNameWidget: Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
            child: Align(alignment: Alignment.centerLeft, child: Text('Age')),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= ageData.length) return const SizedBox();
              return Transform.rotate(
                angle: -0.4,
                child: Text(
                  (ageData[idx]['ageBucket'] ?? '').toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: const Border(bottom: BorderSide(color: Colors.black, width: 1)),
  );

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> ageData) {
    return List.generate(ageData.length, (i) {
      final count = (ageData[i]['count'] as int?) ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: count.toDouble())],
      );
    });
  }
}
