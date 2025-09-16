import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';

class SelectAnimal extends StatefulWidget {
  const SelectAnimal({
    super.key,
    required this.selectedAnimal,
    required this.onChanged,
  });
  final AnimalStoreDto? selectedAnimal;
  final Function(AnimalStoreDto?) onChanged;

  @override
  State<SelectAnimal> createState() => _SelectAnimalState();
}

class _SelectAnimalState extends State<SelectAnimal> {
  List<AnimalStoreDto>? animals;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() async {
    if (animals == null && mounted) {
      final loadedAnimals = await getAnimalsHook();
      if (mounted) {
        setState(() {
          animals = loadedAnimals;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void showAnimalPicker() {
      AnimalStoreDto? tempSelectedAnimal = widget.selectedAnimal;

      print('---------- animals: $animals');

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
                      return RadioListTile<AnimalStoreDto?>(
                        title: Text(animal?.physicalTag ?? ''),
                        value: animal,
                        // ignore: deprecated_member_use
                        groupValue: tempSelectedAnimal,
                        // ignore: deprecated_member_use
                        onChanged: (AnimalStoreDto? value) {
                          setDialogState(() {
                            tempSelectedAnimal = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedAnimal);
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
          widget.onChanged(widget.selectedAnimal);
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
        child: Text(
          widget.selectedAnimal?.physicalTag ?? 'Select animal',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
