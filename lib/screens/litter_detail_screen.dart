import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_mating.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/shared/select_strain.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';

class LitterDetailScreen extends StatefulWidget {
  final String? matingUuid;
  final bool fromCageGrid;

  const LitterDetailScreen({
    super.key,
    this.matingUuid,
    this.fromCageGrid = false,
  });

  @override
  State<LitterDetailScreen> createState() => _LitterDetailScreenState();
}

class _LitterDetailScreenState extends State<LitterDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litterTagController = TextEditingController();
  final _numberOfMalesController = TextEditingController(text: '0');
  final _numberOfFemalesController = TextEditingController(text: '0');
  final _numberOfUnknownController = TextEditingController(text: '0');
  final _commentController = TextEditingController();

  MatingDto? _selectedMating;
  DateTime? _selectedDateOfBirth = DateTime.now();
  DateTime? _selectedWeanDate = DateTime.now().add(const Duration(days: 21));
  AccountStoreDto? _selectedOwner;
  StrainStoreDto? _selectedStrain;
  StrainStoreDto? _originalStrain; // Track original strain to detect changes
  LitterDto? _litterData;
  bool _litterDataLoaded = false;

  String? get _litterUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['litterUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
    _loadMatingIfProvided();
  }

  void _loadMatingIfProvided() async {
    if (widget.matingUuid != null) {
      try {
        final mating = await MatingApi().getMating(widget.matingUuid!);
        if (mounted) {
          setState(() {
            _selectedMating = mating;
          });
        }
      } catch (e) {
        debugPrint('Error loading mating: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_litterDataLoaded && _litterUuid != null) {
      _loadLitterData();
    }
  }

  void _loadDefaultOwner() async {
    final owner = await AccountHelper.getDefaultOwner();
    if (mounted) {
      setState(() {
        _selectedOwner = owner;
      });
    }
  }

  void _loadLitterData() async {
    final litter = await litterService.getLitter(_litterUuid!);
    if (mounted) {
      // Convert strain from StrainSummaryDto to StrainStoreDto if available
      StrainStoreDto? strainStoreDto;
      if (litter.strain != null) {
        strainStoreDto = StrainStoreDto(
          strainId: litter.strain!.strainId,
          strainUuid: litter.strain!.strainUuid,
          strainName: litter.strain!.strainName,
          weanAge: litter.strain!.weanAge,
          genotypes: [],
        );
      }
      
      setState(() {
        _litterData = litter;
        _litterDataLoaded = true;
        _selectedMating = MatingDto(
          matingId: litter.mating?.matingId ?? 0,
          matingUuid: litter.mating?.matingUuid ?? '',
          matingTag: litter.mating?.matingTag ?? '',
          litterStrain: litter.strain,
        );
        _litterTagController.text = litter.litterTag ?? '';
        _selectedDateOfBirth = litter.dateOfBirth;
        _selectedWeanDate = litter.weanDate;
        _selectedOwner = litter.owner?.toAccountStoreDto();
        _selectedStrain = strainStoreDto;
        _originalStrain = strainStoreDto;
      });
    }
  }

  @override
  void dispose() {
    _litterTagController.dispose();
    _numberOfMalesController.dispose();
    _numberOfFemalesController.dispose();
    _numberOfUnknownController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  int _parseIntOrDefault(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    return int.tryParse(trimmed) ?? 0;
  }

  /// Check if the strain has changed from the original
  bool _strainChanged() {
    final oldUuid = _originalStrain?.strainUuid;
    final newUuid = _selectedStrain?.strainUuid;
    return oldUuid != newUuid;
  }

  /// Show dialog asking if user wants to update all pups' strains
  Future<bool?> _showUpdatePupsStrainDialog() async {
    final pupCount = _litterData?.animals.length ?? 0;
    if (pupCount == 0) return null;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Animal Strains?'),
        content: Text(
          'You changed the litter strain to "${_selectedStrain?.strainName}". '
          'Would you like to update all $pupCount pubs in this litter to the same strain?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Keep Current'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Update All'),
          ),
        ],
      ),
    );
  }

  /// Update all pups' strains to match the litter strain
  Future<void> _updatePupsStrain() async {
    if (_litterData?.animals == null || _litterData!.animals.isEmpty) return;
    if (_selectedStrain == null) return;

    try {
      final updates = _litterData!.animals.map((animal) => {
        'animalUuid': animal.animalUuid,
        'strain': {
          'strainId': _selectedStrain!.strainId,
          'strainUuid': _selectedStrain!.strainUuid,
          'strainName': _selectedStrain!.strainName,
        },
      }).toList();
      
      await animalService.patchAnimals(updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated strain for ${_litterData!.animals.length} pubs'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating pup strains: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update pub strains')),
        );
      }
    }
  }

  void _saveLitter() async {
    if (_formKey.currentState!.validate()) {
      try {
        final litter = PostLitterDto(
          mating: _selectedMating!.matingUuid,
          numberOfMale: _parseIntOrDefault(_numberOfMalesController.text),
          numberOfFemale: _parseIntOrDefault(_numberOfFemalesController.text),
          numberOfUnknown: _parseIntOrDefault(_numberOfUnknownController.text),
          litterTag: _litterTagController.text,
          dateOfBirth: _selectedDateOfBirth!,
          weanDate: _selectedWeanDate,
          owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
          comment: _commentController.text.isEmpty
              ? null
              : _commentController.text,
          strain: _selectedStrain,
        );

        final isNew = _litterUuid == null || _litterUuid == 'new';
        
        if (isNew) {
          await litterService.createLitter(litter);
        } else {
          await litterService.putLitter(
            _litterUuid!,
            PutLitterDto(
              comment: _commentController.text.isEmpty
                  ? null
                  : _commentController.text,
              dateOfBirth: _selectedDateOfBirth,
              weanDate: _selectedWeanDate,
              owner: _selectedOwner,
              litterTag: _litterTagController.text,
              strain: _selectedStrain,
            ),
          );
          
          // Check if strain changed and there are pups to update
          if (_strainChanged() && 
              _litterData?.animals != null && 
              _litterData!.animals.isNotEmpty &&
              _selectedStrain != null) {
            final shouldUpdate = await _showUpdatePupsStrainDialog();
            if (shouldUpdate == true) {
              await _updatePupsStrain();
            }
          }
        }
        
        // Refresh related stores
        await refreshAnimalStore();
        await refreshStrainStore();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isNew ? 'Litter created successfully!' : 'Litter updated successfully!')),
          );

          // Navigate back to the appropriate page based on where we came from
          if (widget.fromCageGrid) {
            context.go('/cage/grid');
          } else {
            context.go('/litter');
          }
        }
      } catch (e) {
        debugPrint('Error saving litter: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving litter: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_litterUuid != null && !_litterDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final isNew = _litterUuid == null || _litterUuid == 'new';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromCageGrid) {
              context.go('/cage/grid');
            } else {
              context.go('/litter');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isNew ? 'Create Litter' : 'Update Litter'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectMating(
                selectedMating: _selectedMating,
                onChanged: (mating) {
                  setState(() {
                    _selectedMating = mating;
                    // Inherit strain from mating if available
                    if (mating?.litterStrain != null) {
                      _selectedStrain = StrainStoreDto(
                        strainId: mating!.litterStrain!.strainId,
                        strainUuid: mating.litterStrain!.strainUuid,
                        strainName: mating.litterStrain!.strainName,
                        weanAge: mating.litterStrain!.weanAge,
                        genotypes: [],
                      );
                      // Also update wean date based on strain's weanAge
                      if (mating.litterStrain!.weanAge != null) {
                        _selectedWeanDate = DateTime.now().add(
                          Duration(days: mating.litterStrain!.weanAge!),
                        );
                      }
                    }
                  });
                },
                label: 'Mating',
                placeholderText: 'Select mating',
                disabled: _litterDataLoaded,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litterTagController,
                decoration: const InputDecoration(
                  labelText: 'Litter Tag',
                  hintText: 'Enter litter tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a litter tag';
                  }
                  return null;
                },
              ),
              if (isNew) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfMalesController,
                        decoration: const InputDecoration(
                          labelText: '# Males',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onEditingComplete: () {
                          if (_numberOfMalesController.text.trim().isEmpty) {
                            _numberOfMalesController.text = '0';
                          }
                        },
                        onTapOutside: (_) {
                          if (_numberOfMalesController.text.trim().isEmpty) {
                            _numberOfMalesController.text = '0';
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfFemalesController,
                        decoration: const InputDecoration(
                          labelText: '# Females',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onEditingComplete: () {
                          if (_numberOfFemalesController.text.trim().isEmpty) {
                            _numberOfFemalesController.text = '0';
                          }
                        },
                        onTapOutside: (_) {
                          if (_numberOfFemalesController.text.trim().isEmpty) {
                            _numberOfFemalesController.text = '0';
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfUnknownController,
                        decoration: const InputDecoration(
                          labelText: '# Unknown',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onEditingComplete: () {
                          if (_numberOfUnknownController.text.trim().isEmpty) {
                            _numberOfUnknownController.text = '0';
                          }
                        },
                        onTapOutside: (_) {
                          if (_numberOfUnknownController.text.trim().isEmpty) {
                            _numberOfUnknownController.text = '0';
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedDateOfBirth,
                onChanged: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                },
                labelText: 'Date of Birth',
                hintText: 'Select date of birth',
                validator: (date) {
                  if (date == null) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedWeanDate,
                onChanged: (date) {
                  setState(() {
                    _selectedWeanDate = date;
                  });
                },
                labelText: 'Wean Date (Optional)',
                hintText: 'Select wean date',
                validator: (date) {
                  // Optional field, no validation needed
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SelectOwner(
                selectedOwner: _selectedOwner,
                onChanged: (owner) {
                  setState(() {
                    _selectedOwner = owner;
                  });
                },
              ),
              const SizedBox(height: 16),
              SelectStrain(
                selectedStrain: _selectedStrain,
                onChanged: (strain) {
                  setState(() {
                    _selectedStrain = strain;
                    // If strain has weanAge and we're creating new, update wean date
                    if (strain?.weanAge != null && (_litterUuid == null || _litterUuid == 'new')) {
                      _selectedWeanDate = DateTime.now().add(Duration(days: strain!.weanAge!));
                    }
                  });
                },
                label: 'Strain',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (Optional)',
                  hintText: 'Enter any additional comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Pubs Section
              if (_litterUuid != null && _litterUuid != 'new' && _litterData?.animals != null && _litterData!.animals.isNotEmpty) ...[
                Text(
                  'Pubs (${_litterData!.animals.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _litterData!.animals.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final animal = _litterData!.animals[index];
                      final dobText = animal.dateOfBirth != null 
                          ? 'DOB: ${animal.dateOfBirth!.month}/${animal.dateOfBirth!.day}/${animal.dateOfBirth!.year}'
                          : '';
                      final strainText = animal.strain?.strainName ?? '';
                      final subtitleParts = [dobText, strainText].where((s) => s.isNotEmpty).toList();
                      return ListTile(
                        leading: Icon(
                          animal.sex == 'M' ? Icons.male : 
                          animal.sex == 'F' ? Icons.female : Icons.question_mark,
                          color: animal.sex == 'M' ? Colors.blue : 
                                 animal.sex == 'F' ? Colors.pink : Colors.grey,
                        ),
                        title: Text(animal.physicalTag ?? 'No tag'),
                        subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts.join(' • ')) : null,
                        onTap: () {
                          context.go('/animal/${animal.animalUuid}');
                        },
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes Section
              if (_litterUuid != null && _litterUuid != 'new')
                NoteList(
                  entityUuid: _litterUuid,
                  entityType: NoteEntityType.litter,
                  initialNotes: _litterData?.notes,
                ),

              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  onPressed: _selectedMating == null ? null : _saveLitter,
                  label: isNew ? 'Create Litter' : 'Update Litter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
