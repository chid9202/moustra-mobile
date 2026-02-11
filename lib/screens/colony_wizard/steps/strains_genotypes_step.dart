import 'package:flutter/material.dart';

import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/stores/gene_store.dart';
import 'package:moustra/stores/allele_store.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

import '../state/wizard_state.dart';
import '../colony_wizard_constants.dart';
import '../widgets/genotype_combine_list.dart';

class StrainsGenotypesStep extends StatefulWidget {
  const StrainsGenotypesStep({super.key});

  @override
  State<StrainsGenotypesStep> createState() => _StrainsGenotypesStepState();
}

class _StrainsGenotypesStepState extends State<StrainsGenotypesStep> {
  final _strainNameController = TextEditingController();
  final _strainFocusNode = FocusNode();

  List<StrainStoreDto> _strains = [];
  List<GeneStoreDto> _genes = [];
  List<AlleleStoreDto> _alleles = [];

  bool _isLoadingStrains = true;
  bool _isLoadingGenes = true;
  bool _isLoadingAlleles = true;
  bool _isAddingStrain = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _strainNameController.dispose();
    _strainFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStrains(),
      _loadGenes(),
      _loadAlleles(),
    ]);
  }

  Future<void> _loadStrains() async {
    setState(() => _isLoadingStrains = true);
    try {
      final strains = await getStrainsHook();
      if (mounted) {
        setState(() {
          _strains = strains;
          _isLoadingStrains = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStrains = false);
        _showError('Failed to load strains: $e');
      }
    }
  }

  Future<void> _loadGenes() async {
    setState(() => _isLoadingGenes = true);
    try {
      final genes = await getGenesHook();
      if (mounted) {
        setState(() {
          _genes = genes;
          _isLoadingGenes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGenes = false);
        _showError('Failed to load genes: $e');
      }
    }
  }

  Future<void> _loadAlleles() async {
    setState(() => _isLoadingAlleles = true);
    try {
      final alleles = await getAllelesHook();
      if (mounted) {
        setState(() {
          _alleles = alleles;
          _isLoadingAlleles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAlleles = false);
        _showError('Failed to load alleles: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: ColonyWizardConstants.snackbarDuration,
      ),
    );
  }

  Future<void> _addStrain() async {
    final name = _strainNameController.text.trim();
    if (name.isEmpty) return;

    // Check for duplicates
    final exists = _strains.any(
      (s) => s.strainName.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      _showError('Strain "$name" already exists');
      return;
    }

    setState(() => _isAddingStrain = true);

    try {
      final account = await getAccountHook();
      if (account == null) {
        _showError('Could not get account');
        setState(() => _isAddingStrain = false);
        return;
      }
      
      final payload = PostStrainDto(
        strainName: name,
        owner: account,
        color: '#808080', // Default gray color
        backgrounds: [],
      );
      final newStrain = await strainService.createStrain(payload);

      // Refresh the store
      await refreshStrainStore();
      final strains = await getStrainsHook();

      if (mounted) {
        setState(() {
          _strains = strains;
          _isAddingStrain = false;
        });

        _strainNameController.clear();
        _strainFocusNode.requestFocus();

        wizardState.incrementStrainsAdded();
        _showSuccess('Strain "$name" created');

        // Push undo action
        wizardState.pushUndoAction(
          UndoAction(
            type: UndoActionType.addStrain,
            description: 'Added strain "$name"',
            undo: () async {
              await strainService.deleteStrain(newStrain.strainUuid);
              await refreshStrainStore();
              final updatedStrains = await getStrainsHook();
              if (mounted) {
                setState(() => _strains = updatedStrains);
              }
              wizardState.decrementStrainsAdded();
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingStrain = false);
        _showError('Failed to add strain: $e');
      }
    }
  }

  Future<void> _deleteStrain(StrainStoreDto strain) async {
    // Optimistic update
    final previousStrains = List<StrainStoreDto>.from(_strains);
    setState(() {
      _strains.removeWhere((s) => s.strainUuid == strain.strainUuid);
    });

    try {
      await strainService.deleteStrain(strain.strainUuid);
      await refreshStrainStore();
      _showSuccess('Strain "${strain.strainName}" deleted');

      // Push undo action (would need to re-create, but API might not support that easily)
      // For now, just refresh
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() => _strains = previousStrains);
        _showError('Failed to delete strain: $e');
      }
    }
  }

  Future<void> _addGene(String geneName) async {
    try {
      await postGeneHook(geneName);
      final genes = await getGenesHook();
      if (mounted) {
        setState(() => _genes = genes);
        _showSuccess('Gene "$geneName" created');
      }
    } catch (e) {
      _showError('Failed to add gene: $e');
    }
  }

  Future<void> _deleteGene(GeneStoreDto gene) async {
    try {
      await deleteGeneHook(gene.geneUuid);
      final genes = await getGenesHook();
      if (mounted) {
        setState(() => _genes = genes);
        _showSuccess('Gene "${gene.geneName}" deleted');
      }
    } catch (e) {
      _showError('Failed to delete gene: $e');
    }
  }

  Future<void> _addAllele(String alleleName) async {
    try {
      await postAlleleHook(alleleName);
      final alleles = await getAllelesHook();
      if (mounted) {
        setState(() => _alleles = alleles);
        _showSuccess('Allele "$alleleName" created');
      }
    } catch (e) {
      _showError('Failed to add allele: $e');
    }
  }

  Future<void> _deleteAllele(AlleleStoreDto allele) async {
    try {
      await deleteAlleleHook(allele.alleleUuid);
      final alleles = await getAllelesHook();
      if (mounted) {
        setState(() => _alleles = alleles);
        _showSuccess('Allele "${allele.alleleName}" deleted');
      }
    } catch (e) {
      _showError('Failed to delete allele: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Strains & Genotypes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add the mouse strains and genotypes you\'ll be working with',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Strains section
              _buildStrainsSection(theme),
              const SizedBox(height: 24),

              // Genotypes section
              _buildGenotypesSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrainsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STRAINS',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Add strain input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _strainNameController,
                    focusNode: _strainFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Strain Name',
                      hintText: 'e.g., Lab-specific strain',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addStrain(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isAddingStrain ||
                          _strainNameController.text.trim().isEmpty
                      ? null
                      : _addStrain,
                  child: _isAddingStrain
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Strains list
            Text(
              'Added Strains (${_strains.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            if (_isLoadingStrains)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_strains.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No strains added yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _strains.length,
                  itemBuilder: (context, index) {
                    final strain = _strains[index];
                    return ListTile(
                      dense: true,
                      title: Text(strain.strainName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteStrain(strain),
                        tooltip: 'Delete strain',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenotypesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GENOTYPES',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoadingGenes || _isLoadingAlleles)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              GenotypeCombineList(
                genes: _genes,
                alleles: _alleles,
                onAddGene: _addGene,
                onDeleteGene: _deleteGene,
                onAddAllele: _addAllele,
                onDeleteAllele: _deleteAllele,
              ),
          ],
        ),
      ),
    );
  }
}
