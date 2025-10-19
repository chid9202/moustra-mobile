import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class MiceBySex extends StatefulWidget {
  const MiceBySex(this.animalsSexRatio, {super.key});
  final List<dynamic> animalsSexRatio;

  @override
  State<StatefulWidget> createState() => MiceBySexState();
}

class MiceBySexState extends State<MiceBySex> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Indicator(
                color: Colors.blue,
                text: 'Male',
                isSquare: false,
                size: touchedIndex == 0 ? 18 : 16,
                textColor: touchedIndex == 0 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Colors.pink,
                text: 'Female',
                isSquare: false,
                size: touchedIndex == 1 ? 18 : 16,
                textColor: touchedIndex == 1 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Colors.grey,
                text: 'Unknown',
                isSquare: false,
                size: touchedIndex == 2 ? 18 : 16,
                textColor: touchedIndex == 2 ? Colors.black : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1,
                  centerSpaceRadius: 40,
                  sections: _sexSections(widget.animalsSexRatio),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  String titleFor(String? label) {
    switch (label) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'U':
      default:
        return 'Unknown';
    }
  }

  List<PieChartSectionData> _sexSections(List<dynamic> sexData) {
    final total = sexData.fold<int>(
      0,
      (sum, e) => sum + ((e['count'] as int?) ?? 0),
    );

    final updatedSexData = [];

    for (final data in sexData) {
      final updatedMap = {};
      data.forEach((key, value) {
        if (key == 'sex' && value == null) {
          updatedMap['sex'] = 'U';
        } else {
          updatedMap[key] = value;
        }
      });
      updatedSexData.add(updatedMap);
    }

    final combinedMap = <String, dynamic>{};

    for (final item in updatedSexData) {
      final type = item['sex'] as String;
      final count = item['count'] as int;

      // Add the count to the existing type, or initialize if it's a new type
      combinedMap[type] = (combinedMap[type] ?? 0) + count;
    }

    final finalMap = {
      'M': combinedMap['M'] ?? 0,
      'F': combinedMap['F'] ?? 0,
      'U': combinedMap['U'] ?? 0,
    };

    return List.generate(finalMap.length, (i) {
      final isTouched = i == touchedIndex;
      final entry = finalMap.entries.toList()[i];

      final sex = entry.key;
      final c = entry.value ?? 0;

      final pct = total == 0 ? 0.0 : (c / total * 100);

      return PieChartSectionData(
        color: colorFor(sex),
        value: c.toDouble(),
        title: '${titleFor(sex)}\n${pct.toStringAsFixed(1)}%',
        titlePositionPercentageOffset: 0.55,
        radius: 60,
        borderSide: isTouched
            ? const BorderSide(color: Colors.white, width: 6)
            : BorderSide(color: Colors.white.withValues(alpha: 0)),
      );
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
