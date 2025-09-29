import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/widgets/shared/multi_select_animal.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_cage.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_gene/select_gene.dart';
import 'package:moustra/widgets/shared/select_sex.dart';
import 'package:moustra/widgets/shared/select_strain.dart';
import 'package:moustra/widgets/shared/button.dart';

class AnimalNewScreen extends StatefulWidget {
  final String? cageUuid;
  final bool fromCageGrid;

  const AnimalNewScreen({super.key, this.cageUuid, this.fromCageGrid = false});

  @override
  State<AnimalNewScreen> createState() => _AnimalNewScreenState();
}

class _AnimalNewScreenState extends State<AnimalNewScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shared fields
  CageStoreDto? _selectedCage;
  StrainStoreDto? _selectedStrain;

  // List of animals to create
  List<AnimalCardData> _animals = [];

  @override
  void initState() {
    super.initState();
    _addNewAnimal();
    _loadCageIfProvided();
  }

  void _loadCageIfProvided() async {
    if (widget.cageUuid != null) {
      try {
        final cage = await getCageHook(widget.cageUuid);
        if (cage != null && mounted) {
          setState(() {
            _selectedCage = cage;
          });
        }
      } catch (e) {
        print('Error loading cage: $e');
      }
    }
  }

  void _addNewAnimal() {
    setState(() {
      _animals.add(AnimalCardData());
    });
  }

  void _cloneAnimal(int index) {
    setState(() {
      final original = _animals[index];
      _animals.insert(index + 1, AnimalCardData.cloneFrom(original));
    });
  }

  void _deleteAnimal(int index) {
    setState(() {
      _animals.removeAt(index);
      if (_animals.isEmpty) {
        _addNewAnimal();
      }
    });
  }

  void _saveAnimals() async {
    if (_formKey.currentState!.validate()) {
      try {
        final postAnimalData = _animals.map((animal) {
          return PostAnimalData(
            idx: DateTime.now().millisecondsSinceEpoch.toString(),
            dateOfBirth: animal.dateOfBirth!,
            genotypes: animal.genotypes
                .map(
                  (g) => PostGenotype(
                    gene: g.gene?.geneUuid ?? '',
                    allele: g.allele?.alleleUuid ?? '',
                  ),
                )
                .toList(),
            physicalTag: animal.physicalTagController.text,
            sex: animal.sex,
            strain: _selectedStrain,
            sire: animal.sire,
            dam: animal.dam,
            cage: _selectedCage,
            weanDate: animal.weanDate,
            comment: animal.commentController.text,
          );
        }).toList();

        final postAnimalDto = PostAnimalDto(animals: postAnimalData);

        await AnimalApi().postAnimal(postAnimalDto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animals created successfully!')),
          );
          // Navigate back to the appropriate page based on where we came from
          if (widget.fromCageGrid) {
            context.go('/cages/grid');
          } else {
            context.go('/animals');
          }
        }
      } catch (e) {
        print('Error saving animals: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving animals: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromCageGrid) {
              context.go('/cages/grid');
            } else {
              context.go('/animals');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Create Animals'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shared Fields Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shared Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectCage(
                        selectedCage: _selectedCage,
                        onChanged: (cage) {
                          setState(() {
                            _selectedCage = cage;
                          });
                        },
                        label: 'Target Cage',
                      ),
                      const SizedBox(height: 16),
                      SelectStrain(
                        selectedStrain: _selectedStrain,
                        onChanged: (strain) {
                          setState(() {
                            _selectedStrain = strain;
                          });
                        },
                        label: 'Primary Strain',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Animals List Section
              const Text(
                'Animals to Create',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Animals Cards
              ...List.generate(_animals.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildAnimalCard(index),
                );
              }),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  onPressed: _saveAnimals,
                  label:
                      'Create ${_animals.length} Animal${_animals.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalCard(int index) {
    final animal = _animals[index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Animal ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _cloneAnimal(index),
                      icon: const Icon(Icons.copy),
                      tooltip: 'Clone Animal',
                    ),
                    IconButton(
                      onPressed: () => _deleteAnimal(index),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete Animal',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animal Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: animal.physicalTagController,
                    decoration: const InputDecoration(
                      labelText: 'Physical Tag',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a physical tag';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SelectSex(
                    selectedSex: animal.sex,
                    onChanged: (sex) {
                      setState(() {
                        animal.sex = sex;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SelectDate(
                    selectedDate: animal.dateOfBirth,
                    onChanged: (date) {
                      setState(() {
                        animal.dateOfBirth = date;
                      });
                    },
                    labelText: 'Date of Birth',
                    hintText: 'Select date of birth',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SelectDate(
                    selectedDate: animal.weanDate,
                    onChanged: (date) {
                      setState(() {
                        animal.weanDate = date;
                      });
                    },
                    labelText: 'Wean Date',
                    hintText: 'Select wean date (optional)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SelectGene(
              selectedGenotypes: animal.genotypes,
              onGenotypesChanged: (genotypes) {
                setState(() {
                  animal.genotypes = genotypes;
                });
              },
              label: 'Genotypes',
              placeholderText: 'Select genotypes',
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SelectAnimal(
                    selectedAnimal: animal.sire,
                    onChanged: (sire) {
                      setState(() {
                        animal.sire = sire;
                      });
                    },
                    label: 'Sire',
                    placeholderText: 'Select sire',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MultiSelectAnimal(
                    selectedAnimals: animal.dam,
                    onChanged: (dam) {
                      setState(() {
                        animal.dam = dam;
                      });
                    },
                    label: 'Dam',
                    placeholderText: 'Select dam',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: animal.commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
                hintText: 'Enter any additional comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimalCardData {
  final TextEditingController physicalTagController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  String? sex;
  DateTime? dateOfBirth = DateTime.now();
  DateTime? weanDate = DateTime.now().add(const Duration(days: 21));
  List<GenotypeDto> genotypes = [];
  AnimalStoreDto? sire;
  List<AnimalStoreDto> dam = [];

  AnimalCardData();

  AnimalCardData.cloneFrom(AnimalCardData other) {
    physicalTagController.text = '';
    commentController.text = other.commentController.text;
    sex = other.sex;
    dateOfBirth = other.dateOfBirth;
    weanDate = other.weanDate;
    genotypes = List.from(other.genotypes);
    sire = other.sire;
    dam = List.from(other.dam);
  }

  void dispose() {
    physicalTagController.dispose();
    commentController.dispose();
  }
}
