import 'package:flutter/material.dart';

import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

class CageMiceView extends StatefulWidget {
  const CageMiceView(this.cage, {super.key});

  final CageDto cage;

  @override
  State<CageMiceView> createState() => _CageMiceViewState();
}

class _CageMiceViewState extends State<CageMiceView> {
  late List<AnimalSummaryDto> animalsList;

  @override
  void initState() {
    super.initState();
    animalsList = widget.cage.animals;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<AnimalSummaryDto>(
      builder: (context, candidateData, rejectedData) {
        return ListView.builder(
          itemCount: animalsList.length,
          itemBuilder: (context, index) {
            final animal = animalsList[index];
            return Draggable<AnimalSummaryDto>(
              data: animal,
              feedback: Material(
                child: Card(
                  child: SizedBox(
                    width: 200,
                    child: ListTile(title: Text(animal.physicalTag ?? '')),
                  ),
                ),
              ),
              childWhenDragging: Container(color: Colors.grey),
              child: Card(
                child: ListTile(title: Text(animal.physicalTag ?? '')),
              ), // What to show in the old spot
            );
          },
        );
      },
      onAcceptWithDetails: (details) {
        debugPrint('details data tag: ${details.data.physicalTag}');
        debugPrint('details offset: ${details.offset}');
        debugPrint('cage animals length: ${widget.cage.animals.length}');
        if (!animalsList.contains(details.data)) {
          animalsList.add(details.data);
        }
        debugPrint('cage animals length: ${widget.cage.animals.length}');
      },
      onLeave: (data) {
        debugPrint('leaving data: ${data?.physicalTag}');
        if (data == null) {
          return;
        }
        animalsList.remove(data);
      },
    );
  }
}

