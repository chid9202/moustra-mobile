import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageCompactView extends StatelessWidget {
  final RackCageDto cage;

  const CageCompactView({super.key, required this.cage});

  @override
  Widget build(BuildContext context) {
    final animals = cage.animals ?? [];
    final males = animals.where((e) => e.sex == 'M').length;
    final females = animals.where((e) => e.sex == 'F').length;
    final status = cage.status ?? 'Unknown';

    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge at the top
          Center(
            child: Chip(
              label: Text(
                status,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getStatusColor(status),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 20),
          // Male count with icon chips
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              males,
              (index) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Female count with icon chips
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              females,
              (index) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'F',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('active') || lowerStatus.contains('ok')) {
      return Colors.green.shade100;
    } else if (lowerStatus.contains('error') ||
        lowerStatus.contains('issue') ||
        lowerStatus.contains('problem')) {
      return Colors.red.shade100;
    } else if (lowerStatus.contains('warning') ||
        lowerStatus.contains('caution')) {
      return Colors.orange.shade100;
    }
    return Colors.grey.shade200;
  }
}
