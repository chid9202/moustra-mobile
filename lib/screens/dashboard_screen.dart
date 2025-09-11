import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _future;
  String _selectedStrainUuid = '00000000-0000-0000-0000-000000000000';

  @override
  void initState() {
    super.initState();
    _future = dashboardService.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load dashboard: ${snapshot.error}'),
          );
        }
        final data = snapshot.data ?? <String, dynamic>{};
        final Map<String, dynamic> accounts =
            (data['accounts'] as Map<String, dynamic>? ?? <String, dynamic>{});
        final List<dynamic> animalByAge =
            (data['animalByAge'] as List<dynamic>? ?? <dynamic>[]);
        final List<dynamic> animalsSexRatio =
            (data['animalsSexRatio'] as List<dynamic>? ?? <dynamic>[]);
        final List<dynamic> animalsToWean =
            (data['animalsToWean'] as List<dynamic>? ?? <dynamic>[]);

        final strains = animalByAge.cast<Map<String, dynamic>>();
        final selected = strains.firstWhere(
          (s) => (s['strainUuid'] ?? '') == _selectedStrainUuid,
          orElse: () =>
              strains.isNotEmpty ? strains.first : <String, dynamic>{},
        );
        final List<dynamic> ageData =
            (selected['ageData'] as List<dynamic>? ?? <dynamic>[]);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          const Text(
                            'Mice by Age',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) =>
                                      Transform.rotate(
                                        angle: -0.6,
                                        child: Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: true),
                            barGroups: ageData.map((e) {
                              final int week = (e['ageInWeeks'] as int? ?? 0);
                              final int count = (e['count'] as int? ?? 0);
                              return BarChartGroupData(
                                x: week,
                                barRods: [
                                  BarChartRodData(toY: count.toDouble()),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Animals To Wean',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...animalsToWean.take(10).map((a) {
                        final tag = (a['physicalTag'] ?? '').toString();
                        final wean = (a['weanDate'] ?? '').toString();
                        final cageTag = (a['cage']?['cageTag'] ?? '')
                            .toString();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tag.isEmpty ? '(no tag)' : tag,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 12,
                                child: Text('→', textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  cageTag,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  _formatDate(wean),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data by Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final keys = accounts.keys.toList();
                                    if (value.toInt() < 0 ||
                                        value.toInt() >= keys.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final key = keys[value.toInt()];
                                    final name = (accounts[key]?['name'] ?? '')
                                        .toString();
                                    return Transform.rotate(
                                      angle: -0.6,
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontSize: 9),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: List.generate(accounts.length, (i) {
                              final key = accounts.keys.elementAt(i);
                              final a =
                                  accounts[key] as Map<String, dynamic>? ??
                                  <String, dynamic>{};
                              final animals = (a['animalsCount'] as int? ?? 0)
                                  .toDouble();
                              final cages = (a['cagesCount'] as int? ?? 0)
                                  .toDouble();
                              final matings = (a['matingsCount'] as int? ?? 0)
                                  .toDouble();
                              final litters = (a['littersCount'] as int? ?? 0)
                                  .toDouble();
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: animals,
                                    color: Colors.blue,
                                  ),
                                  BarChartRodData(
                                    toY: cages,
                                    color: Colors.orange,
                                  ),
                                  BarChartRodData(
                                    toY: matings,
                                    color: Colors.green,
                                  ),
                                  BarChartRodData(
                                    toY: litters,
                                    color: Colors.purple,
                                  ),
                                ],
                              );
                            }),
                            groupsSpace: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mice by Sex',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: _sexSections(animalsSexRatio),
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _sexSections(List<dynamic> sexData) {
    final total = sexData.fold<int>(
      0,
      (sum, e) => sum + ((e['count'] as int?) ?? 0),
    );
    Color colorFor(String? sex) {
      switch (sex) {
        case 'M':
          return Colors.blue;
        case 'F':
          return Colors.pink;
        case 'U':
          return Colors.grey;
        default:
          return Colors.black26;
      }
    }

    return sexData.map((e) {
      final c = (e['count'] as int? ?? 0);
      final sex = e['sex']?.toString();
      final pct = total == 0 ? 0.0 : (c / total * 100);
      return PieChartSectionData(
        color: colorFor(sex),
        value: c.toDouble(),
        title: '${pct.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y').format(dt);
  }
}
