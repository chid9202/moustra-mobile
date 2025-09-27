import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/cage/cage_view_1.dart';
import 'package:moustra/screens/cage/cage_view_2.dart';
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
        childWidget = CageView1(cage: cage);
      case 2:
        childWidget = CageView2(cage: cage);
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
              context.go('/cages/${cage.cageUuid}');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [Expanded(child: childWidget)],
          ),
        ),
      ),
    );
  }
}
