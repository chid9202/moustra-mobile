import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';

class MultiSelectAnimal extends StatefulWidget {
  const MultiSelectAnimal({
    super.key,
    required this.selectedAnimals,
    required this.onChanged,
  });
  final List<AnimalStoreDto> selectedAnimals;
  final Function(List<AnimalStoreDto>) onChanged;

  @override
  State<MultiSelectAnimal> createState() => _MultiSelectAnimalState();
}

class _MultiSelectAnimalState extends State<MultiSelectAnimal> {
  List<AnimalStoreDto>? animals;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() async {
    if (animals == null && mounted) {
      final loadedAnimals = await getAnimalsHook();
      setState(() {
        animals = loadedAnimals;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showAnimalPicker() {
      List<AnimalStoreDto> tempSelectedAnimals = List.from(
        widget.selectedAnimals,
      );

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Animals'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: animals?.length ?? 0,
                    itemBuilder: (context, index) {
                      final animal = animals?[index];
                      final isSelected = tempSelectedAnimals.any(
                        (a) => a.animalUuid == animal?.animalUuid,
                      );

                      return CheckboxListTile(
                        title: Text(animal?.physicalTag ?? ''),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelectedAnimals.add(animal!);
                            } else {
                              tempSelectedAnimals.removeWhere(
                                (a) => a.animalUuid == animal?.animalUuid,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedAnimals);
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      ).then((saved) {
        if (saved != true) {
          // Dialog was closed without saving, reset to original values
          widget.onChanged(List.from(widget.selectedAnimals));
        }
      });
    }

    return InkWell(
      onTap: showAnimalPicker,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Animals',
          border: OutlineInputBorder(),
        ),
        child: widget.selectedAnimals.isEmpty
            ? const Text('Select animals', style: TextStyle(color: Colors.grey))
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.selectedAnimals.map((bg) {
                  return Chip(
                    label: Text(bg.physicalTag ?? ''),
                    onDeleted: () {
                      widget.onChanged(
                        widget.selectedAnimals
                            .where(
                              (animal) => animal.animalUuid != bg.animalUuid,
                            )
                            .toList(),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
