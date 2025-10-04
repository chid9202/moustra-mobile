import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/shared/select_rack_cage.dart';

class AnimalCard extends StatefulWidget {
  final RackCageDto cage;
  final RackCageAnimalDto animal;
  final bool hasMating;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.hasMating,
    required this.cage,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  bool _moving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          // Left: Gender with large font
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                widget.animal.sex ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Middle: Physical tag and genotypes
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Physical tag with bold font and heart icon if has mating
                Row(
                  children: [
                    Text(
                      _getCardTitle(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.animal.litter != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // Genotypes using formatGenotypes method
                Text(
                  _formatGenotypes(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Right: Menu icon
          Expanded(
            flex: 1,
            child: Center(
              child: _moving
                  ? CircularProgressIndicator()
                  : PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (_) {
                        return menu(
                          context,
                          (bool value) => setState(() {
                            _moving = value;
                          }),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGenotypes() {
    if (widget.animal.genotypes == null || widget.animal.genotypes!.isEmpty) {
      return 'No genotypes';
    }

    return widget.animal.genotypes!
        .map((g) {
          final String gene = (g.gene?.geneName ?? '').toString();
          final String allele = (g.allele?.alleleName ?? '').toString();
          if (gene.isNotEmpty && allele.isNotEmpty) {
            return '$gene/$allele';
          }
          if (gene.isNotEmpty) {
            return gene;
          }
          if (allele.isNotEmpty) {
            return allele;
          }
          return '';
        })
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  String _getCardTitle() {
    var physicalTag = widget.animal.physicalTag ?? 'No tag';
    if (widget.hasMating) {
      physicalTag += ' 💕';
    }
    return physicalTag;
  }

  List<PopupMenuItem> menu(
    BuildContext buildContext,
    Function(bool) setMoving,
  ) => [
    PopupMenuItem(
      value: 'move',
      child: Text('Move'),
      onTap: () {
        showDialog(
          context: buildContext,
          builder: (context) {
            return SelectRackCage(
              selectedCage: widget.cage,
              onSubmit: (submittedCage) async {
                debugPrint('submitted cage: ${submittedCage?.cageId}');
                if (submittedCage == null ||
                    submittedCage.cageId == widget.cage.cageId) {
                  return;
                }
                setMoving(true);
                try {
                  await moveAnimal(
                    widget.animal.animalUuid,
                    submittedCage.cageUuid,
                  );
                } catch (e) {
                  if (buildContext.mounted) {
                    await showDialog(
                      context: buildContext,
                      builder: (buildContext) {
                        return AlertDialog(
                          title: Text('Error while moving animal'),
                          content: SingleChildScrollView(child: Text('$e')),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(buildContext).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } finally {
                  setMoving(false);
                }
              },
            );
          },
        );
      },
    ),
    PopupMenuItem(
      value: 'open',
      child: Text('Open'),
      onTap: () => buildContext.go(
        '/animals/${widget.animal.animalUuid}?fromCageGrid=true',
      ),
    ),
    PopupMenuItem(
      value: 'end',
      child: Text('End'),
      onTap: () {
        removeAnimalFromCage(widget.cage.cageUuid, widget.animal.animalUuid);
        animalService.endAnimals([widget.animal.animalUuid]);
      },
    ),
  ];
}
