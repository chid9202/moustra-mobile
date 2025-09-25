import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/cage/cage_summary_view.dart';
import 'package:moustra/screens/cage/cage_mice_view.dart';
import 'package:moustra/screens/cage/shared.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class CageInteractiveView extends StatelessWidget {
  final CageDto cage;
  final int detailLevel;
  final PaginatedResponseDto<CageDto> allCagesData;

  const CageInteractiveView({
    super.key,
    required this.cage,
    required this.detailLevel,
    required this.allCagesData,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget childWidget;

    switch (detailLevel) {
      case 0:
      case 1:
        childWidget = CageMiceView(cage);
      case 2:
        childWidget = CageSummaryView(cage);
        break;
    }

    return Card(
      elevation: 12.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            context.go('/cage/${cage.cageUuid}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cage.cageTag,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  cage.cageUuid,
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
}
