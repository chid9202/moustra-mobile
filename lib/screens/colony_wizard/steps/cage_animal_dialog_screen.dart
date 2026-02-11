import 'package:flutter/material.dart';

import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/stores/account_store.dart';

import '../colony_wizard_constants.dart';
import '../state/wizard_state.dart';
import '../widgets/animal_list_item.dart';
import '../widgets/mating_section.dart';
import '../widgets/strain_picker.dart';

/// Temporary animal data for the dialog
class TempAnimalData {
  String id;
  String physicalTag;
  String sex;
  DateTime dateOfBirth;
  StrainStoreDto? strain;
  String comment;
  List<Map<String, String>> genotypes;
  bool isLitterPup;
  String? animalUuid; // null for new animals

  TempAnimalData({
    String? id,
    required this.physicalTag,
    required this.sex,
    required this.dateOfBirth,
    this.strain,
    this.comment = '',
    List<Map<String, String>>? genotypes,
    this.isLitterPup = false,
    this.animalUuid,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        genotypes = genotypes ?? [];

  bool get isMature {
    final threshold = DateTime.now().subtract(
      const Duration(days: ColonyWizardConstants.defaultWeanDays),
    );
    return dateOfBirth.isBefore(threshold) || dateOfBirth.isAtSameMomentAs(threshold);
  }
}

class CageAnimalDialogScreen extends StatefulWidget {
  final String rackUuid;
  final String rackName;
  final int xPosition;
  final int yPosition;
  final RackCageDto? existingCage;
  final VoidCallback onSaved;

  const CageAnimalDialogScreen({
    super.key,
    required this.rackUuid,
    required this.rackName,
    required this.xPosition,
    required this.yPosition,
    this.existingCage,
    required this.onSaved,
  });

  @override
  State<CageAnimalDialogScreen> createState() => _CageAnimalDialogScreenState();
}

class _CageAnimalDialogScreenState extends State<CageAnimalDialogScreen> {
  final _cageTagController = TextEditingController();
  final _matingTagController = TextEditingController();

  List<StrainStoreDto> _strains = [];
  StrainStoreDto? _cageStrain;
  StrainStoreDto? _litterStrain;
  List<TempAnimalData> _animals = [];
  
  int _maleCount = 0;
  int _femaleCount = 0;
  int _unknownCount = 0;
  
  int _pupMaleCount = 0;
  int _pupFemaleCount = 0;
  int _pupUnknownCount = 0;

  bool _isSaving = false;
  bool _matingTagTouched = false;
  bool _matingExpanded = false;
  int _animalCounter = 1;

  bool get isEditMode => widget.existingCage != null;

  String get positionLabel {
    final rowLetter = String.fromCharCode(65 + widget.yPosition);
    final colNumber = widget.xPosition + 1;
    return '$rowLetter$colNumber';
  }

  @override
  void initState() {
    super.initState();
    _loadDataAndInitialize();
  }

  @override
  void dispose() {
    _cageTagController.dispose();
    _matingTagController.dispose();
    super.dispose();
  }

  Future<void> _loadDataAndInitialize() async {
    final strains = await getStrainsHook();
    if (mounted) {
      setState(() {
        _strains = strains;
        _initializeFromExisting();
      });
    }
  }

  StrainStoreDto? _findStrain(String? strainUuid) {
    if (strainUuid == null || _strains.isEmpty) return null;
    return _strains.cast<StrainStoreDto?>().firstWhere(
      (s) => s?.strainUuid == strainUuid,
      orElse: () => null,
    );
  }

  void _initializeFromExisting() {
    if (widget.existingCage != null) {
      final cage = widget.existingCage!;
      _cageTagController.text = cage.cageTag ?? positionLabel;

      // Load cage strain
      if (cage.strain != null) {
        _cageStrain = _findStrain(cage.strain!.strainUuid);
      }

      // Load animals (excluding pups)
      if (cage.animals != null) {
        debugPrint('=== Loading animals from existing cage ===');
        debugPrint('Cage has ${cage.animals!.length} animals');
        for (final animal in cage.animals!) {
          final isLitterPup = animal.litter != null;
          debugPrint('Loading animal: ${animal.physicalTag}, UUID: ${animal.animalUuid}, isLitterPup: $isLitterPup');
          _animals.add(TempAnimalData(
            animalUuid: animal.animalUuid,
            physicalTag: animal.physicalTag ?? '',
            sex: animal.sex ?? 'U',
            dateOfBirth: animal.dateOfBirth ?? DateTime.now(),
            strain: animal.strain != null
                ? _findStrain(animal.strain!.strainUuid)
                : null,
            comment: animal.comment ?? '',
            isLitterPup: isLitterPup,
          ));
          _animalCounter++;
        }
        debugPrint('Loaded ${_animals.length} animals into _animals list');
      }

      // Load mating info
      if (cage.mating != null) {
        _matingTagController.text = cage.mating!.matingTag ?? '';
        _matingTagTouched = true;
        _matingExpanded = true;
        if (cage.mating!.litterStrain != null) {
          _litterStrain = _findStrain(cage.mating!.litterStrain!.strainUuid);
        }
      }

      // Count existing animals by sex
      _updateCounts();
    } else {
      _cageTagController.text = positionLabel;
    }
  }

  void _updateCounts() {
    final parentAnimals = _animals.where((a) => !a.isLitterPup).toList();
    _maleCount = parentAnimals.where((a) => a.sex == 'M').length;
    _femaleCount = parentAnimals.where((a) => a.sex == 'F').length;
    _unknownCount = parentAnimals.where((a) => a.sex == 'U').length;
  }

  void _updateMatingTag() {
    // Skip if user manually edited the tag, or if editing a cage that already has a mating
    final hasExistingMating = isEditMode && widget.existingCage?.mating != null;
    if (_matingTagTouched || hasExistingMating) return;

    final males = _animals
        .where((a) => a.sex == 'M' && !a.isLitterPup)
        .map((a) => a.physicalTag)
        .toList();
    final females = _animals
        .where((a) => a.sex == 'F' && !a.isLitterPup)
        .map((a) => a.physicalTag)
        .toList();

    final tags = [...males, ...females].join(' / ');
    _matingTagController.text = tags;
  }

  void _addAnimal(String sex) {
    final prefix = sex == 'M' ? 'M' : sex == 'F' ? 'F' : 'U';
    final defaultDob = DateTime.now().subtract(
      const Duration(days: ColonyWizardConstants.defaultWeanDays),
    );

    setState(() {
      _animals.add(TempAnimalData(
        physicalTag: '$prefix$_animalCounter',
        sex: sex,
        dateOfBirth: defaultDob,
        strain: _cageStrain,
      ));
      _animalCounter++;
      _updateCounts();
      _updateMatingTag();

      // Auto-expand mating section and pre-select litter strain when mating becomes possible
      if (_hasBothSexes && !_matingExpanded) {
        _matingExpanded = true;
        // Pre-select litter strain from cage strain if not already set
        _litterStrain ??= _cageStrain;
      }
    });
  }

  void _removeAnimal(TempAnimalData animal) {
    setState(() {
      _animals.removeWhere((a) => a.id == animal.id);
      _updateCounts();
      _updateMatingTag();
    });
  }

  void _updateAnimal(TempAnimalData animal) {
    setState(() {
      final index = _animals.indexWhere((a) => a.id == animal.id);
      if (index != -1) {
        _animals[index] = animal;
        _updateCounts();
        _updateMatingTag();
      }
    });
  }

  bool get _hasMaturePair {
    final matureMales = _animals
        .where((a) => a.sex == 'M' && !a.isLitterPup && a.isMature)
        .isNotEmpty;
    final matureFemales = _animals
        .where((a) => a.sex == 'F' && !a.isLitterPup && a.isMature)
        .isNotEmpty;
    return matureMales && matureFemales;
  }

  bool get _hasBothSexes {
    return _maleCount > 0 && _femaleCount > 0;
  }

  bool get _exceedsCapacity {
    final parentCount = _animals.where((a) => !a.isLitterPup).length;
    return parentCount > ColonyWizardConstants.maxMicePerCage;
  }

  int get _totalPups => _pupMaleCount + _pupFemaleCount + _pupUnknownCount;

  Future<void> _save() async {
    final cageTag = _cageTagController.text.trim();
    if (cageTag.isEmpty) {
      _showError('Cage tag is required');
      return;
    }

    if (_exceedsCapacity) {
      _showError('Exceeds maximum capacity (${ColonyWizardConstants.maxMicePerCage} mice)');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (isEditMode) {
        await _updateExistingCage();
      } else {
        await _createNewCage();
      }

      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
        _showSuccess(isEditMode ? 'Cage updated' : 'Cage created');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Failed to save: $e');
      }
    }
  }

  Future<void> _createNewCage() async {
    final parentAnimals = _animals.where((a) => !a.isLitterPup).toList();

    // Build new animals payload
    List<Map<String, dynamic>>? newAnimalsData;
    if (parentAnimals.isNotEmpty) {
      newAnimalsData = parentAnimals.map((animal) {
        final animalData = <String, dynamic>{
          'sex': animal.sex,
          'physicalTag': animal.physicalTag,
          'dateOfBirth': _formatDate(animal.dateOfBirth),
          'weanDate': _formatDate(
            animal.dateOfBirth.add(
              const Duration(days: ColonyWizardConstants.defaultWeanDays),
            ),
          ),
          'genotypes': animal.genotypes
              .map((g) => {'gene': g['gene'], 'allele': g['allele']})
              .toList(),
        };
        if (animal.strain != null) {
          animalData['strain'] = animal.strain!.strainUuid;
        }
        if (animal.comment.isNotEmpty) {
          animalData['comment'] = animal.comment;
        }
        return animalData;
      }).toList();
    }

    // Build litter payload if pups exist
    Map<String, int>? litterData;
    if (_totalPups > 0) {
      litterData = {
        'numberOfMale': _pupMaleCount,
        'numberOfFemale': _pupFemaleCount,
        'numberOfUnknown': _pupUnknownCount,
      };
    }

    // Create cage with all data via API
    await cageApi.createCageWithAnimals(
      cageTag: _cageTagController.text.trim(),
      rackUuid: widget.rackUuid,
      xPosition: widget.xPosition,
      yPosition: widget.yPosition,
      strainUuid: _cageStrain?.strainUuid,
      newAnimals: newAnimalsData,
      matingTag: _hasBothSexes ? _matingTagController.text : null,
      litterStrainUuid: _litterStrain?.strainUuid,
      litter: litterData,
    );

    // Update wizard state
    wizardState.incrementCagesAdded();
    if (parentAnimals.isNotEmpty) {
      wizardState.incrementAnimalsAdded(parentAnimals.length);
    }
  }

  Future<void> _updateExistingCage() async {
    final cage = widget.existingCage!;
    final account = await getAccountHook();
    
    if (account == null) {
      throw Exception('Could not get account');
    }

    // 1. Update the cage (tag, strain)
    final cagePayload = PutCageDto(
      cageId: cage.cageId ?? 0,
      cageUuid: cage.cageUuid,
      cageTag: _cageTagController.text.trim(),
      owner: account,
      strain: _cageStrain?.toStrainSummaryDto(),
    );
    await cageApi.putCage(cage.cageUuid, cagePayload);

    // 2. Handle animal changes - diff the arrays
    final originalAnimalUuids = (cage.animals ?? [])
        .where((a) => a.litter == null) // Exclude pups
        .map((a) => a.animalUuid)
        .toSet();
    
    final currentAnimalUuids = _animals
        .where((a) => !a.isLitterPup && a.animalUuid != null)
        .map((a) => a.animalUuid!)
        .toSet();

    // Debug logging
    debugPrint('=== Animal Update Debug ===');
    debugPrint('Original animals from cage: ${cage.animals?.length ?? 0}');
    debugPrint('Original UUIDs (non-pups): $originalAnimalUuids');
    debugPrint('Current _animals count: ${_animals.length}');
    debugPrint('Current _animals UUIDs: ${_animals.map((a) => "${a.physicalTag}:${a.animalUuid}").toList()}');
    debugPrint('Current UUIDs (non-pups with UUID): $currentAnimalUuids');

    // Animals to delete (in original but not in current)
    final animalsToDelete = originalAnimalUuids.difference(currentAnimalUuids);
    debugPrint('Animals to delete: $animalsToDelete');
    
    // Animals to add (no animalUuid means new)
    final animalsToAdd = _animals
        .where((a) => !a.isLitterPup && a.animalUuid == null)
        .toList();
    
    // Animals to update (in both, check if changed)
    final animalsToUpdate = _animals
        .where((a) => !a.isLitterPup && a.animalUuid != null && currentAnimalUuids.contains(a.animalUuid))
        .toList();

    // Delete removed animals
    if (animalsToDelete.isNotEmpty) {
      await animalService.endAnimals(animalsToDelete.toList());
    }

    // Build cage reference for animal updates
    final cageRef = CageSummaryDto(
      cageId: cage.cageId ?? 0,
      cageUuid: cage.cageUuid,
      cageTag: _cageTagController.text.trim(),
    );

    // Update existing animals
    for (final animal in animalsToUpdate) {
      final originalAnimal = cage.animals?.firstWhere(
        (a) => a.animalUuid == animal.animalUuid,
      );
      if (originalAnimal == null) continue;

      // Build update payload with owner and cage reference
      final animalPayload = AnimalDto(
        eid: originalAnimal.animalId ?? 0,
        animalId: originalAnimal.animalId ?? 0,
        animalUuid: animal.animalUuid!,
        physicalTag: animal.physicalTag,
        sex: animal.sex,
        dateOfBirth: animal.dateOfBirth,
        weanDate: animal.dateOfBirth.add(
          const Duration(days: ColonyWizardConstants.defaultWeanDays),
        ),
        owner: account.toAccountDto(),
        cage: cageRef, // Include cage reference to maintain association
        strain: animal.strain?.toStrainSummaryDto(),
        comment: animal.comment.isNotEmpty ? animal.comment : null,
        genotypes: [],
      );
      await animalService.putAnimal(animal.animalUuid!, animalPayload);
    }

    // Add new animals
    if (animalsToAdd.isNotEmpty) {
      final cageStore = CageStoreDto(
        cageId: cage.cageId ?? 0,
        cageUuid: cage.cageUuid,
        cageTag: cage.cageTag ?? '',
      );
      
      final newAnimalsPayload = PostAnimalDto(
        animals: animalsToAdd.map((animal) {
          return PostAnimalData(
            idx: animal.id,
            physicalTag: animal.physicalTag,
            sex: animal.sex,
            dateOfBirth: animal.dateOfBirth,
            weanDate: animal.dateOfBirth.add(
              const Duration(days: ColonyWizardConstants.defaultWeanDays),
            ),
            strain: animal.strain,
            cage: cageStore,
            genotypes: [],
            comment: animal.comment.isNotEmpty ? animal.comment : null,
          );
        }).toList(),
      );
      await animalService.postAnimal(newAnimalsPayload);
    }

    // 3. Update mating if exists
    if (cage.mating != null && _hasBothSexes) {
      final matingPayload = PutMatingDto(
        matingId: cage.mating!.matingId ?? 0,
        matingUuid: cage.mating!.matingUuid,
        matingTag: _matingTagController.text,
        litterStrain: _litterStrain,
        setUpDate: cage.mating!.setUpDate ?? DateTime.now(),
        owner: account,
        comment: cage.mating!.comment,
      );
      await matingService.putMating(cage.mating!.matingUuid, matingPayload);
    }

    // 4. Create litter if pups added
    if (_totalPups > 0 && cage.mating != null) {
      final litterPayload = PostLitterDto(
        mating: cage.mating!.matingUuid,
        numberOfMale: _pupMaleCount,
        numberOfFemale: _pupFemaleCount,
        numberOfUnknown: _pupUnknownCount,
        litterTag: '',
        dateOfBirth: DateTime.now(),
        weanDate: DateTime.now().add(
          const Duration(days: ColonyWizardConstants.defaultWeanDays),
        ),
        owner: account,
        strain: _litterStrain ?? _cageStrain,
      );
      await litterService.createLitter(litterPayload);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parentAnimals = _animals.where((a) => !a.isLitterPup).toList();
    final litterPups = _animals.where((a) => a.isLitterPup).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? 'Edit Cage ${widget.existingCage!.cageTag}'
              : 'Add Cage at $positionLabel - ${widget.rackName}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cage Details Section
            _buildSectionHeader(theme, 'CAGE DETAILS'),
            const SizedBox(height: 12),
            _buildCageDetailsSection(theme),
            const SizedBox(height: 24),

            // Animals Section
            _buildSectionHeader(theme, 'ANIMALS'),
            const SizedBox(height: 12),
            _buildAnimalButtons(theme),
            const SizedBox(height: 12),

            // Capacity warning
            if (_exceedsCapacity)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exceeds maximum capacity (${ColonyWizardConstants.maxMicePerCage} mice). Consider splitting into multiple cages.',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Animal list
            if (parentAnimals.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No animals added. Use the buttons above to add animals.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...parentAnimals.map((animal) => AnimalListItem(
                    animal: animal,
                    strains: _strains,
                    onUpdate: _updateAnimal,
                    onDelete: () => _removeAnimal(animal),
                  )),

            // Mating Section (conditional)
            if (_hasBothSexes) ...[
              const SizedBox(height: 24),
              MatingSection(
                expanded: _matingExpanded || _hasMaturePair,
                hasMaturePair: _hasMaturePair,
                matingTagController: _matingTagController,
                litterStrain: _litterStrain,
                strains: _strains,
                pupMaleCount: _pupMaleCount,
                pupFemaleCount: _pupFemaleCount,
                pupUnknownCount: _pupUnknownCount,
                onExpandedChanged: (expanded) {
                  setState(() => _matingExpanded = expanded);
                },
                onMatingTagChanged: () {
                  setState(() => _matingTagTouched = true);
                },
                onLitterStrainChanged: (strain) {
                  setState(() => _litterStrain = strain);
                },
                onPupCountChanged: (male, female, unknown) {
                  setState(() {
                    _pupMaleCount = male;
                    _pupFemaleCount = female;
                    _pupUnknownCount = unknown;
                  });
                },
              ),
            ],

            // Existing pups (edit mode only)
            if (litterPups.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(theme, 'EXISTING PUPS'),
              const SizedBox(height: 12),
              ...litterPups.map((pup) => ListTile(
                    leading: _getSexIcon(pup.sex),
                    title: Text(pup.physicalTag),
                    subtitle: Text(
                      '${pup.strain?.strainName ?? "No strain"} | ${_formatDate(pup.dateOfBirth)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeAnimal(pup),
                    ),
                  )),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildCageDetailsSection(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cageTagController,
            decoration: const InputDecoration(
              labelText: 'Cage Tag *',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StrainPicker(
            label: 'Strain',
            value: _cageStrain,
            strains: _strains,
            onChanged: (strain) {
              setState(() => _cageStrain = strain);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalButtons(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _addAnimal('M'),
          icon: Icon(Icons.male, color: Colors.blue),
          label: const Text('Add Male'),
        ),
        OutlinedButton.icon(
          onPressed: () => _addAnimal('F'),
          icon: Icon(Icons.female, color: Colors.pink),
          label: const Text('Add Female'),
        ),
        OutlinedButton.icon(
          onPressed: () => _addAnimal('U'),
          icon: Icon(Icons.question_mark, color: Colors.grey),
          label: const Text('Add Unknown'),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _isSaving ||
                      _cageTagController.text.trim().isEmpty ||
                      _exceedsCapacity
                  ? null
                  : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditMode ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSexIcon(String sex) {
    switch (sex) {
      case 'M':
        return Icon(Icons.male, color: Colors.blue);
      case 'F':
        return Icon(Icons.female, color: Colors.pink);
      default:
        return Icon(Icons.question_mark, color: Colors.grey);
    }
  }
}
