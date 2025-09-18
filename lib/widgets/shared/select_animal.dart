import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/stores/animal_store.dart';

class SelectAnimal extends StatefulWidget {
  const SelectAnimal({
    super.key,
    required this.selectedAnimal,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.filter,
    this.disabled = false,
  });
  final AnimalStoreDto? selectedAnimal;
  final Function(AnimalStoreDto?) onChanged;
  final String label;
  final String placeholderText;
  final List<AnimalStoreDto> Function(List<AnimalStoreDto>)? filter;
  final bool disabled;
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
    final filteredAnimals = widget.filter != null
        ? widget.filter!(animals ?? [])
        : animals;
    void showAnimalPicker() {
      AnimalStoreDto? tempSelectedAnimal = widget.selectedAnimal;

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
                      return RadioListTile<AnimalStoreDto?>(
                        title: Text(AnimalHelper.getAnimalOptionLabel(animal!)),
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
              child: Text(
                widget.selectedAnimal?.physicalTag ?? widget.placeholderText,
                style: TextStyle(
                  color: widget.selectedAnimal != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedAnimal != null && !widget.disabled) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              widget.onChanged(null);
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            tooltip: 'Clear selection',
          ),
        ],
      ],
    );
  }
}
