import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/stores/gene_store.dart';
import 'package:moustra/stores/allele_store.dart';
import 'package:moustra/stores/rack_store.dart';

import '../state/wizard_state.dart';
import '../colony_wizard_constants.dart';

class ReviewStep extends StatefulWidget {
  const ReviewStep({super.key});

  @override
  State<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends State<ReviewStep> {
  List<StrainStoreDto> _strains = [];
  List<GeneStoreDto> _genes = [];
  List<AlleleStoreDto> _alleles = [];
  List<RackSimpleDto> _racks = [];
  List<CageDto> _cages = [];
  List<AnimalDto> _animals = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      await Future.wait([
        _loadStrains(),
        _loadGenes(),
        _loadAlleles(),
        _loadRacks(),
        _loadCages(),
        _loadAnimals(),
      ]);
    } catch (e) {
      debugPrint('Error loading review data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStrains() async {
    final strains = await getStrainsHook();
    if (mounted) {
      setState(() => _strains = strains);
    }
  }

  Future<void> _loadGenes() async {
    final genes = await getGenesHook();
    if (mounted) {
      setState(() => _genes = genes);
    }
  }

  Future<void> _loadAlleles() async {
    final alleles = await getAllelesHook();
    if (mounted) {
      setState(() => _alleles = alleles);
    }
  }

  Future<void> _loadRacks() async {
    await useRackStore();
    final rackData = rackStore.value?.rackData;
    if (mounted && rackData?.racks != null) {
      setState(() => _racks = rackData!.racks!);
    }
  }

  Future<void> _loadCages() async {
    try {
      final response = await cageApi.getCagesPage(pageSize: 100);
      if (mounted) {
        setState(() => _cages = response.results);
      }
    } catch (e) {
      debugPrint('Error loading cages: $e');
    }
  }

  Future<void> _loadAnimals() async {
    try {
      final response = await animalService.getAnimalsPage(pageSize: 1000);
      if (mounted) {
        setState(() => _animals = response.results);
      }
    } catch (e) {
      debugPrint('Error loading animals: $e');
    }
  }

  void _onFinish() {
    // Reset wizard state
    wizardState.reset();
    // Navigate to dashboard
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                'Review Your Colony Setup',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your colony setup below. You can edit any section by clicking the Edit button.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Summary cards grid
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildStrainsCard(theme),
                          const SizedBox(height: 16),
                          _buildRacksCard(theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildGenotypesCard(theme),
                          const SizedBox(height: 16),
                          _buildCagesAnimalsCard(theme),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildStrainsCard(theme),
                    const SizedBox(height: 16),
                    _buildGenotypesCard(theme),
                    const SizedBox(height: 16),
                    _buildRacksCard(theme),
                    const SizedBox(height: 16),
                    _buildCagesAnimalsCard(theme),
                  ],
                ),

              const SizedBox(height: 32),

              // Finish button
              Center(
                child: FilledButton.icon(
                  onPressed: _onFinish,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finish & Go to Dashboard'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrainsCard(ThemeData theme) {
    return _SummaryCard(
      title: 'Strains',
      count: _strains.length,
      icon: Icons.pets,
      onEdit: () => wizardState.goToStep(ColonyWizardConstants.stepStrainsGenotypes),
      isEmpty: _strains.isEmpty,
      emptyMessage: 'No strains added',
      children: _strains.take(5).map((s) => Text(s.strainName)).toList(),
      moreCount: _strains.length > 5 ? _strains.length - 5 : 0,
    );
  }

  Widget _buildGenotypesCard(ThemeData theme) {
    return _SummaryCard(
      title: 'Genotypes',
      count: _genes.length,
      icon: Icons.science,
      onEdit: () => wizardState.goToStep(ColonyWizardConstants.stepStrainsGenotypes),
      isEmpty: _genes.isEmpty && _alleles.isEmpty,
      emptyMessage: 'No genotypes added',
      children: _genes.take(5).map((g) {
        // Find alleles for this gene (in real app, would have proper association)
        final alleleText = _alleles.take(3).map((a) => a.alleleName).join(', ');
        return Text('${g.geneName}${alleleText.isNotEmpty ? " ($alleleText)" : ""}');
      }).toList(),
      moreCount: _genes.length > 5 ? _genes.length - 5 : 0,
    );
  }

  Widget _buildRacksCard(ThemeData theme) {
    return _SummaryCard(
      title: 'Racks',
      count: _racks.length,
      icon: Icons.grid_on,
      onEdit: () => wizardState.goToStep(ColonyWizardConstants.stepRacks),
      isEmpty: _racks.isEmpty,
      emptyMessage: 'No racks added',
      children: _racks.take(5).map((r) => Text(r.rackName ?? 'Unnamed')).toList(),
      moreCount: _racks.length > 5 ? _racks.length - 5 : 0,
    );
  }

  Widget _buildCagesAnimalsCard(ThemeData theme) {
    final maleCount = _animals.where((a) => a.sex == 'M').length;
    final femaleCount = _animals.where((a) => a.sex == 'F').length;

    return _SummaryCard(
      title: 'Cages & Animals',
      countLabel: '${_cages.length}/${_animals.length}',
      icon: Icons.home,
      onEdit: () => wizardState.goToStep(ColonyWizardConstants.stepCagesAnimals),
      isEmpty: _cages.isEmpty,
      emptyMessage: 'No cages or animals added',
      children: [
        if (_cages.isNotEmpty) ...[
          Text('${_cages.length} cages with ${_animals.length} total animals'),
          if (_animals.isNotEmpty)
            Text(
              '$maleCount males, $femaleCount females',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 8),
          ..._cages.take(5).map((c) => Text(c.cageTag ?? 'Unnamed')),
        ],
      ],
      moreCount: _cages.length > 5 ? _cages.length - 5 : 0,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int? count;
  final String? countLabel;
  final IconData icon;
  final VoidCallback onEdit;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;
  final int moreCount;

  const _SummaryCard({
    required this.title,
    this.count,
    this.countLabel,
    required this.icon,
    required this.onEdit,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
    this.moreCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 350),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      countLabel ?? count?.toString() ?? '0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isEmpty
                    ? Text(
                        emptyMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...children,
                          if (moreCount > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              '+$moreCount more',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
