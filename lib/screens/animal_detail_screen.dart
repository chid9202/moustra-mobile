import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/widgets/shared/multi_select_animal.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_cage.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_gene/select_gene.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/shared/select_sex.dart';
import 'package:moustra/widgets/shared/select_strain.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/widgets/attachment/attachment_list.dart';
import 'package:moustra/widgets/family_tree_widget.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

class AnimalDetailScreen extends StatefulWidget {
  final bool fromCageGrid;
  final String? fromProtocol;

  const AnimalDetailScreen({
    super.key,
    this.fromCageGrid = false,
    this.fromProtocol,
  });

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _physicalTagController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedSex;
  StrainStoreDto? _selectedStrain;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedWeanDate;
  AccountStoreDto? _selectedOwner;
  CageStoreDto? _selectedCage;
  AnimalStoreDto? _selectedSire;
  List<AnimalStoreDto> _selectedDam = [];
  AnimalDto? _animalData;
  bool _animalDataLoaded = false;
  List<GenotypeDto> _selectedGenotypes = [];

  // Get the animal UUID from the route parameters
  String? get _animalUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['animalUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animalDataLoaded) {
      _loadAnimalData();
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

  void _loadAnimalData() async {
    final animalUuid = _animalUuid;
    if (animalUuid == null || animalUuid == 'new') {
      _animalDataLoaded = true;
      return;
    }
    try {
      // Load existing animal data for editing
      final animal = await AnimalApi().getAnimal(animalUuid);
      if (mounted) {
        final loadedStrain = await getStrainHook(animal.strain?.strainUuid);
        final loadedOwner = await getAccountHook(
          animal.owner?.accountUuid ?? '',
        );
        final loadedCage = await getCageHook(animal.cage?.cageUuid);
        final loadedSire = await getAnimalHook(animal.sire?.animalUuid ?? '');
        final loadedDam = await getAnimalsHookByUuids(
          animal.dam?.map((dam) => dam.animalUuid).toList() ?? [],
        );
        setState(() {
          _physicalTagController.text = animal.physicalTag ?? '';
          _commentController.text = animal.comment ?? '';
          _selectedSex = animal.sex;
          _selectedStrain = loadedStrain;
          _selectedDateOfBirth = animal.dateOfBirth;
          _selectedWeanDate = animal.weanDate;
          _selectedOwner = loadedOwner;
          _selectedCage = loadedCage;
          _selectedSire = loadedSire;
          _selectedDam = loadedDam;
          _animalData = animal;
          _animalDataLoaded = true;
          _selectedGenotypes = animal.genotypes ?? [];
          eventApi.trackEvent('view_animal');
        });
      }
    } catch (e) {
      debugPrint('Error loading animal: $e');
      if (mounted) {
        showAppSnackBar(context, 'Error loading animal: $e', isError: true);
      }
      _animalDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _physicalTagController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveAnimal() async {
    if (_formKey.currentState!.validate() && _animalData != null) {
      try {
        final animalUuid = _animalUuid;
        if (animalUuid == null) {
          return;
        }
        debugPrint(
          _selectedGenotypes.map((e) => jsonEncode(e.toJson())).toString(),
        );
        // return;
        // Update existing animal
        final previousCage = _animalData?.cage?.cageUuid;
        final previousStrain = _animalData?.strain?.strainUuid;

        await AnimalApi().putAnimal(
          animalUuid,
          AnimalDto(
            eid: 0,
            animalId: 0,
            animalUuid: animalUuid,
            physicalTag: _physicalTagController.text,
            sex: _selectedSex,
            strain: _selectedStrain?.toStrainSummaryDto(),
            dateOfBirth: _selectedDateOfBirth,
            weanDate: _selectedWeanDate,
            cage: _selectedCage?.toCageSummaryDto(),
            owner: _selectedOwner?.toAccountDto(),
            sire: _selectedSire?.toAnimalSummaryDto(),
            dam: _selectedDam.map((dam) => dam.toAnimalSummaryDto()).toList(),
            comment: _commentController.text,
            genotypes: _selectedGenotypes,
          ),
        );
        eventApi.trackEvent('update_animal');
        // Refresh related stores
        await refreshAnimalStore();
        // Refresh cage store if cage changed
        if (previousCage != _selectedCage?.cageUuid) {
          await refreshCageStore();
        }
        // Refresh strain store if strain changed
        if (previousStrain != _selectedStrain?.strainUuid) {
          await refreshStrainStore();
        }
        if (!mounted) {
          return;
        }
        showAppSnackBar(
          context,
          'Animal updated successfully!',
          isSuccess: true,
        );
        // Navigate back to the appropriate page based on where we came from
        if (widget.fromProtocol != null) {
          context.pop();
        } else if (widget.fromCageGrid) {
          context.go('/cage/grid');
        } else {
          context.go('/animal');
        }
      } catch (e) {
        debugPrint('Error saving animal: $e - ${e.toString()}');
        showAppSnackBar(context, 'Error saving animal: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_animalUuid != null && !_animalDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromProtocol != null) {
              context.pop();
            } else if (widget.fromCageGrid) {
              context.go('/cage/grid');
            } else {
              context.go('/animal');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _animalUuid == null || _animalUuid == 'new'
              ? 'Create Animal'
              : 'Edit Animal',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Physical Tag Field
              Semantics(
                label: 'Physical Tag',
                textField: true,
                child: TextFormField(
                  controller: _physicalTagController,
                  decoration: const InputDecoration(
                    labelText: 'Physical Tag',
                    hintText: 'Enter physical tag',
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

              const SizedBox(height: 16),

              // Sex Selection
              SelectSex(
                selectedSex: _selectedSex,
                onChanged: (sex) {
                  setState(() {
                    _selectedSex = sex;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Strain Selection
              SelectStrain(
                selectedStrain: _selectedStrain,
                onChanged: (strain) {
                  setState(() {
                    _selectedStrain = strain;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Date of Birth
              SelectDate(
                selectedDate: _selectedDateOfBirth,
                onChanged: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                },
                labelText: 'Date of Birth',
              ),

              const SizedBox(height: 16),

              // Wean Date
              SelectDate(
                selectedDate: _selectedWeanDate,
                onChanged: (date) {
                  setState(() {
                    _selectedWeanDate = date;
                  });
                },
                labelText: 'Wean Date',
              ),

              const SizedBox(height: 16),

              // Genotype Selection
              SelectGene(
                selectedGenotypes: _selectedGenotypes,
                onGenotypesChanged: (genotypes) {
                  setState(() {
                    _selectedGenotypes = genotypes;
                  });
                },
                label: 'Genotype',
                placeholderText: 'Select Genotype',
              ),

              const SizedBox(height: 16),

              // Owner Select Field
              SelectOwner(
                selectedOwner: _selectedOwner,
                onChanged: (owner) {
                  setState(() {
                    _selectedOwner = owner;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Cage Selection
              SelectCage(
                selectedCage: _selectedCage,
                onChanged: (cage) {
                  setState(() {
                    _selectedCage = cage;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Sire Selection
              SelectAnimal(
                selectedAnimal: _selectedSire,
                onChanged: (animal) {
                  setState(() {
                    _selectedSire = animal;
                  });
                },
                label: 'Sire',
                placeholderText: 'Select Sire',
              ),

              const SizedBox(height: 16),

              // Dam Selection
              MultiSelectAnimal(
                selectedAnimals: _selectedDam,
                onChanged: (items) {
                  setState(() {
                    _selectedDam = items;
                  });
                },
                label: 'Dam',
                placeholderText: 'Select Dam',
              ),

              const SizedBox(height: 16),

              // Comment Field
              Semantics(
                label: 'Comment',
                textField: true,
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    hintText: 'Enter any additional comments',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),

              // End Information (read-only, shown only for ended animals)
              if (_animalData?.endDate != null) ...[
                const Divider(height: 32),
                const Text(
                  'End Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _readOnlyField('End Date', _formatDate(_animalData!.endDate)),
                if (_animalData!.endType != null)
                  _readOnlyField('End Type', _animalData!.endType!.endTypeName),
                if (_animalData!.endReason != null)
                  _readOnlyField(
                    'End Reason',
                    _animalData!.endReason!.endReasonName,
                  ),
                if (_animalData!.endComment != null &&
                    _animalData!.endComment!.isNotEmpty)
                  _readOnlyField('End Comment', _animalData!.endComment!),
              ],

              const SizedBox(height: 32),

              // Notes Section
              if (_animalUuid != null && _animalUuid != 'new')
                NoteList(
                  entityUuid: _animalUuid,
                  entityType: NoteEntityType.animal,
                  initialNotes: _animalData?.notes,
                ),

              const SizedBox(height: 16),

              // Attachments Section
              if (_animalUuid != null && _animalUuid != 'new')
                AttachmentList(animalUuid: _animalUuid),

              const SizedBox(height: 16),

              // Family Tree Button
              if (_animalUuid != null && _animalUuid != 'new')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFamilyTree(context),
                    icon: const Icon(Icons.account_tree),
                    label: const Text('View Family Tree'),
                  ),
                ),

              const SizedBox(height: 16),

              // Related data sections (only for existing animals)
              if (_animalUuid != null && _animalUuid != 'new') ...[
                _buildMatingHistorySection(),
                const SizedBox(height: 16),
                if (_animalData?.sex == 'F') _buildPlugEventHistorySection(),
                if (_animalData?.sex == 'F') const SizedBox(height: 16),
              ],

              // Save Button
              Semantics(
                label: 'Save Animal',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  child: MoustraButtonPrimary(
                    onPressed: _saveAnimal,
                    label: 'Save Animal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFamilyTree(BuildContext context) {
    final uuid = _animalUuid;
    if (uuid == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family Tree',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: FamilyTreeWidget(animalUuid: uuid)),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        child: Text(value),
      ),
    );
  }

  String _formatDate(DateTime? d) => d != null
      ? '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}'
      : '';

  Color _edayColor(double? currentEday, double? targetEday) {
    if (currentEday == null || targetEday == null) return Colors.grey;
    if (currentEday > targetEday) return Colors.red;
    if (currentEday >= targetEday - 1) return Colors.orange;
    return Colors.green;
  }

  Widget _buildSectionHeader(String title, int count, {Widget? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing],
      ],
    );
  }

  Widget _buildMatingHistorySection() {
    final matings = _animalData?.matings ?? [];
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Mating History', matings.length),
            const SizedBox(height: 8),
            if (matings.isEmpty)
              const Text(
                'No matings recorded',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...matings.map((mating) {
                final isActive = mating.disbandedDate == null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mating.matingTag ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Disbanded',
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${mating.litterStrain?.strainName ?? ''}'
                        '${mating.setUpDate != null ? ' • Set up: ${DateFormat('yyyy-MM-dd').format(mating.setUpDate!)}' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => context.go('/mating/${mating.matingUuid}'),
                    ),
                    // Sub-list of litters
                    if (mating.litters != null && mating.litters!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: mating.litters!
                              .map(
                                (litter) => InkWell(
                                  onTap: () => context.go(
                                    '/litter/${litter.litterUuid}',
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.pets,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          litter.litterTag ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (litter.dateOfBirth != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(litter.dateOfBirth!),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlugEventHistorySection() {
    final plugEvents = _animalData?.plugEvents ?? [];
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Plug Events',
              plugEvents.length,
              trailing: OutlinedButton.icon(
                onPressed: () =>
                    context.go('/plug-event/new?female=$_animalUuid'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Plug'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (plugEvents.isEmpty)
              const Text(
                'No plug events recorded',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...plugEvents.map((pe) {
                final edayColor = _edayColor(pe.currentEday, pe.targetEday);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    pe.plugDate.length >= 10
                        ? pe.plugDate.substring(0, 10)
                        : pe.plugDate,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      if (pe.currentEday != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: edayColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'E${pe.currentEday!.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: edayColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (pe.outcome != null && pe.outcome!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pe.outcome!
                                .split('_')
                                .map((w) => w[0].toUpperCase() + w.substring(1))
                                .join(' '),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.go('/plug-event/${pe.plugEventUuid}'),
                );
              }),
          ],
        ),
      ),
    );
  }
}
