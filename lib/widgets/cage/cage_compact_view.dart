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

