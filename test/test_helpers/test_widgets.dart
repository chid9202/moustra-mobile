import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'mock_data.dart';

/// Test version of SelectAnimal that doesn't make HTTP calls
class TestSelectAnimal extends StatefulWidget {
  const TestSelectAnimal({
    super.key,
    required this.selectedAnimal,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.filter,
    this.disabled = false,
    this.mockAnimals,
  });

  final AnimalStoreDto? selectedAnimal;
  final Function(AnimalStoreDto?) onChanged;
  final String label;
  final String placeholderText;
  final List<AnimalStoreDto> Function(List<AnimalStoreDto>)? filter;
  final bool disabled;
  final List<AnimalStoreDto>? mockAnimals;

  @override
  State<TestSelectAnimal> createState() => _TestSelectAnimalState();
}

class _TestSelectAnimalState extends State<TestSelectAnimal> {
  List<AnimalStoreDto>? animals;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() {
    if (animals == null && mounted) {
      setState(() {
        animals =
            widget.mockAnimals ?? MockDataFactory.createAnimalStoreDtoList(5);
      });
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedAnimal);
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: widget.disabled != true ? showAnimalPicker : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
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

/// Test version of SelectCage that doesn't make HTTP calls
class TestSelectCage extends StatefulWidget {
  const TestSelectCage({
    super.key,
    required this.selectedCage,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.mockCages,
  });

  final CageStoreDto? selectedCage;
  final Function(CageStoreDto?) onChanged;
  final String? label;
  final bool disabled;
  final List<CageStoreDto>? mockCages;

  @override
  State<TestSelectCage> createState() => _TestSelectCageState();
}

class _TestSelectCageState extends State<TestSelectCage> {
  List<CageStoreDto>? cages;

  String _getCageOptionLabel(CageStoreDto cage) {
    return cage.cageTag ?? 'N/A';
  }

  @override
  void initState() {
    super.initState();
    _loadCages();
  }

  void _loadCages() {
    if (cages == null && mounted) {
      setState(() {
        cages = widget.mockCages ?? MockDataFactory.createCageStoreDtoList(3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showCagePicker() {
      CageStoreDto? tempSelectedCage = widget.selectedCage;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Cages'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final cage = cages?[index];
                      return RadioListTile<CageStoreDto?>(
                        title: Text(_getCageOptionLabel(cage!)),
                        value: cage,
                        // ignore: deprecated_member_use
                        groupValue: tempSelectedCage,
                        // ignore: deprecated_member_use
                        onChanged: (CageStoreDto? value) {
                          setDialogState(() {
                            tempSelectedCage = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedCage);
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: widget.disabled != true ? showCagePicker : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label ?? 'Cages',
                border: const OutlineInputBorder(),
                enabled: !widget.disabled,
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                widget.selectedCage?.cageTag ??
                    (widget.selectedCage != null ? 'N/A' : 'Select cage'),
                style: TextStyle(
                  color: widget.selectedCage != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedCage != null && !widget.disabled) ...[
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

/// Test version of MultiSelectAnimal that doesn't make HTTP calls
class TestMultiSelectAnimal extends StatefulWidget {
  const TestMultiSelectAnimal({
    super.key,
    required this.selectedAnimals,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.filter,
    this.disabled = false,
    this.mockAnimals,
  });

  final List<AnimalStoreDto> selectedAnimals;
  final Function(List<AnimalStoreDto>) onChanged;
  final String label;
  final String placeholderText;
  final List<AnimalStoreDto> Function(List<AnimalStoreDto>)? filter;
  final bool disabled;
  final List<AnimalStoreDto>? mockAnimals;

  @override
  State<TestMultiSelectAnimal> createState() => _TestMultiSelectAnimalState();
}

class _TestMultiSelectAnimalState extends State<TestMultiSelectAnimal> {
  List<AnimalStoreDto>? animals;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() {
    if (animals == null && mounted) {
      setState(() {
        animals =
            widget.mockAnimals ?? MockDataFactory.createAnimalStoreDtoList(5);
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
                title: const Text('Select Multiple Animals'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredAnimals?.length ?? 0,
                    itemBuilder: (context, index) {
                      final animal = filteredAnimals?[index];
                      final isSelected = tempSelectedAnimals.any(
                        (selected) => selected.animalUuid == animal?.animalUuid,
                      );

                      return CheckboxListTile(
                        title: Text(AnimalHelper.getAnimalOptionLabel(animal!)),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelectedAnimals.add(animal);
                            } else {
                              tempSelectedAnimals.removeWhere(
                                (selected) =>
                                    selected.animalUuid == animal.animalUuid,
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedAnimals);
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: widget.disabled != true ? showAnimalPicker : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: const OutlineInputBorder(),
                    enabled: !widget.disabled,
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    widget.selectedAnimals.isEmpty
                        ? widget.placeholderText
                        : '${widget.selectedAnimals.length} animals selected',
                    style: TextStyle(
                      color: widget.selectedAnimals.isNotEmpty
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor,
                    ),
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
        ),
        if (widget.selectedAnimals.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedAnimals.map((animal) {
              return Chip(
                label: Text(AnimalHelper.getAnimalOptionLabel(animal)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: widget.disabled
                    ? null
                    : () {
                        final updatedAnimals = List<AnimalStoreDto>.from(
                          widget.selectedAnimals,
                        );
                        updatedAnimals.removeWhere(
                          (selected) =>
                              selected.animalUuid == animal.animalUuid,
                        );
                        widget.onChanged(updatedAnimals);
                      },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Test version of SelectStrain that doesn't make HTTP calls
class TestSelectStrain extends StatefulWidget {
  const TestSelectStrain({
    super.key,
    required this.selectedStrain,
    required this.onChanged,
    this.label,
    this.mockStrains,
  });

  final StrainStoreDto? selectedStrain;
  final Function(StrainStoreDto?) onChanged;
  final String? label;
  final List<StrainStoreDto>? mockStrains;

  @override
  State<TestSelectStrain> createState() => _TestSelectStrainState();
}

class _TestSelectStrainState extends State<TestSelectStrain> {
  @override
  Widget build(BuildContext context) {
    void showStrainPicker() {
      StrainStoreDto? tempSelectedStrain = widget.selectedStrain;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Strains'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.mockStrains?.length ?? 0,
                    itemBuilder: (context, index) {
                      final strain = widget.mockStrains?[index];
                      return RadioListTile<StrainStoreDto?>(
                        title: Text(strain?.strainName ?? ''),
                        value: strain,
                        groupValue: tempSelectedStrain,
                        onChanged: (StrainStoreDto? value) {
                          setDialogState(() {
                            tempSelectedStrain = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedStrain);
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
          widget.onChanged(widget.selectedStrain);
        }
      });
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: showStrainPicker,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label ?? 'Strains',
                border: const OutlineInputBorder(),
              ),
              child: Text(
                widget.selectedStrain?.strainName ?? 'Select strain',
                style: TextStyle(
                  color: widget.selectedStrain != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedStrain != null) ...[
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

/// Test version of SelectBackground that doesn't make HTTP calls
class TestSelectBackground extends StatefulWidget {
  const TestSelectBackground({
    super.key,
    required this.selectedBackgrounds,
    required this.onChanged,
    this.mockBackgrounds,
  });

  final List<BackgroundStoreDto> selectedBackgrounds;
  final Function(List<BackgroundStoreDto>) onChanged;
  final List<BackgroundStoreDto>? mockBackgrounds;

  @override
  State<TestSelectBackground> createState() => _TestSelectBackgroundState();
}

class _TestSelectBackgroundState extends State<TestSelectBackground> {
  List<BackgroundStoreDto>? backgrounds;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  void _loadBackgrounds() {
    if (backgrounds == null && mounted) {
      setState(() {
        backgrounds =
            widget.mockBackgrounds ??
            MockDataFactory.createBackgroundStoreDtoList(3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showBackgroundPicker() {
      List<BackgroundStoreDto> tempSelectedBackgrounds = List.from(
        widget.selectedBackgrounds,
      );

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Backgrounds'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: backgrounds?.length ?? 0,
                          itemBuilder: (context, index) {
                            final background = backgrounds?[index];
                            final isSelected = tempSelectedBackgrounds.any(
                              (bg) => bg.uuid == background?.uuid,
                            );

                            return CheckboxListTile(
                              title: Text(background?.name ?? ''),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelectedBackgrounds.add(background!);
                                  } else {
                                    tempSelectedBackgrounds.removeWhere(
                                      (bg) => bg.uuid == background?.uuid,
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      TextButton.icon(
                        onPressed: () {
                          _showAddBackgroundDialog(
                              setDialogState, tempSelectedBackgrounds);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Background'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedBackgrounds);
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
          widget.onChanged(List.from(widget.selectedBackgrounds));
        }
      });
    }

    return InkWell(
      onTap: showBackgroundPicker,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Backgrounds',
          border: OutlineInputBorder(),
        ),
        child: widget.selectedBackgrounds.isEmpty
            ? const Text(
                'Select backgrounds',
                style: TextStyle(color: Colors.grey),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.selectedBackgrounds.map((bg) {
                  return Chip(
                    label: Text(bg.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      widget.onChanged(
                        widget.selectedBackgrounds
                            .where((background) => background.uuid != bg.uuid)
                            .toList(),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }

  void _showAddBackgroundDialog(
    StateSetter setDialogState,
    List<BackgroundStoreDto> tempSelectedBackgrounds,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Background'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Background Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final newBg = BackgroundStoreDto(
                    id: (backgrounds?.length ?? 0) + 1,
                    uuid: 'new-background-uuid-${(backgrounds?.length ?? 0) + 1}',
                    name: controller.text.trim(),
                  );
                  Navigator.of(context).pop();
                  setState(() {
                    backgrounds = [...(backgrounds ?? []), newBg];
                  });
                  setDialogState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

/// Test version of SelectMating that doesn't make HTTP calls
class TestSelectMating extends StatefulWidget {
  const TestSelectMating({
    super.key,
    required this.selectedMating,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.disabled = false,
    this.mockMatings,
  });

  final MatingDto? selectedMating;
  final Function(MatingDto?) onChanged;
  final String label;
  final String placeholderText;
  final bool disabled;
  final List<MatingDto>? mockMatings;

  @override
  State<TestSelectMating> createState() => _TestSelectMatingState();
}

class _TestSelectMatingState extends State<TestSelectMating> {
  List<MatingDto>? matings;

  @override
  void initState() {
    super.initState();
    _loadMatings();
  }

  void _loadMatings() {
    if (matings == null && mounted) {
      setState(() {
        matings = widget.mockMatings ?? MockDataFactory.createMatingDtoList(3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showMatingPicker() {
      if (widget.disabled) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select ${widget.label}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: matings?.length ?? 0,
              itemBuilder: (context, index) {
                final mating = matings![index];
                final isSelected =
                    widget.selectedMating?.matingUuid == mating.matingUuid;

                return ListTile(
                  title: Text(mating.matingTag ?? 'Mating ${mating.matingId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mating.setUpDate != null)
                        Text(
                          'Set up: ${mating.setUpDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      Text('Animals: ${mating.animals?.length ?? 0}'),
                      if (mating.litterStrain != null)
                        Text('Strain: ${mating.litterStrain!.strainName}'),
                    ],
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  selected: isSelected,
                  onTap: () {
                    widget.onChanged(mating);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.onChanged(null);
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: widget.disabled ? null : showMatingPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          enabled: !widget.disabled,
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: widget.selectedMating == null
            ? Text(widget.placeholderText, style: TextStyle(color: Colors.grey))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedMating!.matingTag ??
                        'Mating ${widget.selectedMating!.matingId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (widget.selectedMating!.setUpDate != null)
                    Text(
                      'Set up: ${widget.selectedMating!.setUpDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Text(
                    'Animals: ${widget.selectedMating!.animals?.length ?? 0}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (widget.selectedMating!.litterStrain != null)
                    Text(
                      'Strain: ${widget.selectedMating!.litterStrain!.strainName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
      ),
    );
  }
}
