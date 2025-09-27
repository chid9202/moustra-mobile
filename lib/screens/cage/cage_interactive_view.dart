import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageInteractiveView extends StatelessWidget {
  final RackCageDto cage;
  final int detailLevel;
  final RackDto rackData;

  const CageInteractiveView({
    super.key,
    required this.cage,
    required this.detailLevel,
    required this.rackData,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget childWidget;

    switch (detailLevel) {
      case 0:
      case 1:
        childWidget = _buildMiceView();
      case 2:
        childWidget = _buildSummaryView();
        break;
    }

    return Card(
      elevation: 12.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            if (cage.cageUuid != null) {
              context.go('/cage/${cage.cageUuid}');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cage.cageTag ?? 'Unknown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  cage.cageUuid ?? 'No UUID',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: childWidget),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiceView() {
    final animals = cage.animals ?? [];
    return Column(
      children: [
        Text('Animals: ${animals.length}'),
        if (animals.isNotEmpty)
          ...animals
              .take(3)
              .map(
                (animal) => Text(
                  animal.physicalTag ?? 'No tag',
                  style: TextStyle(fontSize: 12),
                ),
              ),
        if (animals.length > 3) Text('... and ${animals.length - 3} more'),
      ],
    );
  }

  Widget _buildSummaryView() {
    final animals = cage.animals ?? [];
    final males = animals.where((e) => e.sex == 'M').length;
    final females = animals.where((e) => e.sex == 'F').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status: ${cage.status ?? 'Unknown'}'),
        Text('Animals: ${animals.length}'),
        Text('Males: $males'),
        Text('Females: $females'),
        if (cage.strain != null)
          Text('Strain: ${cage.strain!.strainName ?? 'Unknown'}'),
      ],
    );
  }
}
