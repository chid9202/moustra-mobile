import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/stores/animal_store.dart';

class MultiSelectAnimal extends StatefulWidget {
  const MultiSelectAnimal({
    super.key,
    required this.selectedAnimals,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.filter,
    this.disabled = false,
  });
  final List<AnimalStoreDto> selectedAnimals;
  final Function(List<AnimalStoreDto>) onChanged;
  final String label;
  final String placeholderText;
  final List<AnimalStoreDto> Function(List<AnimalStoreDto>)? filter;
  final bool disabled;
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
    final filteredAnimals = widget.filter != null
        ? widget.filter!(animals ?? [])
        : animals;
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
                    itemCount: filteredAnimals?.length ?? 0,
                    itemBuilder: (context, index) {
                      final animal = filteredAnimals?[index];
                      final isSelected = tempSelectedAnimals.any(
                        (a) => a.animalUuid == animal?.animalUuid,
                      );

                      return CheckboxListTile(
                        title: Text(AnimalHelper.getAnimalOptionLabel(animal!)),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelectedAnimals.add(animal);
                            } else {
                              tempSelectedAnimals.removeWhere(
                                (a) => a.animalUuid == animal.animalUuid,
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

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: widget.disabled != true ? showAnimalPicker : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                border: OutlineInputBorder(),
                enabled: !widget.disabled,
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: widget.selectedAnimals.isEmpty
                  ? Text(
                      widget.placeholderText,
                      style: TextStyle(color: Colors.grey),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.selectedAnimals.map((bg) {
                        return Chip(
                          label: Text(AnimalHelper.getAnimalOptionLabel(bg)),
                          onDeleted: () {
                            widget.onChanged(
                              widget.selectedAnimals
                                  .where(
                                    (animal) =>
                                        animal.animalUuid != bg.animalUuid,
                                  )
                                  .toList(),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
        if (widget.selectedAnimals.isNotEmpty && !widget.disabled) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              widget.onChanged([]);
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            tooltip: 'Clear all selections',
          ),
        ],
      ],
    );
  }
}
