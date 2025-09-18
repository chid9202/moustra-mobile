import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DataByAccount extends StatelessWidget {
  const DataByAccount(this.accounts, {super.key});
  final Map<String, dynamic> accounts;

  @override
  Widget build(BuildContext context) {
    final maxWidth = max(
      MediaQuery.of(context).size.width * 0.85,
      accounts.length * 40.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            const Text(
              'Data by Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                // BarChartRodData(toY: animals, color: Colors.blue),
                // BarChartRodData(toY: cages, color: Colors.orange),
                // BarChartRodData(toY: matings, color: Colors.green),
                // BarChartRodData(toY: litters, color: Colors.purple),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.square, color: Colors.blue),
                    Expanded(flex: 5, child: Text('Animals')),
                    Icon(Icons.square, color: Colors.orange),
                    Expanded(flex: 5, child: Text('Cages')),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.square, color: Colors.green),
                    Expanded(flex: 5, child: Text('Matings')),
                    Icon(Icons.square, color: Colors.purple),
                    Expanded(flex: 5, child: Text('Litters')),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: InteractiveViewer(
            panAxis: PanAxis.horizontal,
            child: SizedBox(
              height: 300,
              width: maxWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: true),
                    borderData: borderData,
                    titlesData: titlesData,
                    barTouchData: barTouchData,
                    barGroups: barGroups,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      fitInsideVertically: true,
      fitInsideHorizontally: true,
      getTooltipColor: (group) => Colors.blueGrey,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem:
          (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.toStringAsFixed(0),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
    ),
  );

  FlTitlesData get titlesData => FlTitlesData(
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        getTitlesWidget: (value, meta) {
          final keys = accounts.keys.toList();
          if (value.toInt() < 0) {
            return Container();
          }
          final key = keys[value.toInt()];
          final name = (accounts[key]?['name'] ?? '').toString();
          return Transform.rotate(
            origin: Offset.fromDirection(0, 20),
            // alignment: AlignmentGeometry.bottomCenter,
            angle: -0.6,
            child: Text(name, style: const TextStyle(fontSize: 9)),
          );
        },
      ),
    ),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: const Border(bottom: BorderSide(color: Colors.black, width: 1)),
  );

  List<BarChartGroupData> get barGroups => List.generate(accounts.length, (i) {
    final key = accounts.keys.elementAt(i);
    final a = accounts[key] as Map<String, dynamic>? ?? <String, dynamic>{};
    final animals = (a['animalsCount'] as int? ?? 0).toDouble();
    final cages = (a['cagesCount'] as int? ?? 0).toDouble();
    final matings = (a['matingsCount'] as int? ?? 0).toDouble();
    final litters = (a['littersCount'] as int? ?? 0).toDouble();
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(toY: animals, color: Colors.blue),
        BarChartRodData(toY: cages, color: Colors.orange),
        BarChartRodData(toY: matings, color: Colors.green),
        BarChartRodData(toY: litters, color: Colors.purple),
      ],
    );
  });
}
