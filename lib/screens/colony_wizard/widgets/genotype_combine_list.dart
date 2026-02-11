import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

/// Two-panel gene/allele manager for genotype definition
class GenotypeCombineList extends StatefulWidget {
  final List<GeneStoreDto> genes;
  final List<AlleleStoreDto> alleles;
  final Future<void> Function(String geneName) onAddGene;
  final Future<void> Function(GeneStoreDto gene) onDeleteGene;
  final Future<void> Function(String alleleName) onAddAllele;
  final Future<void> Function(AlleleStoreDto allele) onDeleteAllele;

  const GenotypeCombineList({
    super.key,
    required this.genes,
    required this.alleles,
    required this.onAddGene,
    required this.onDeleteGene,
    required this.onAddAllele,
    required this.onDeleteAllele,
  });

  @override
  State<GenotypeCombineList> createState() => _GenotypeCombineListState();
}

class _GenotypeCombineListState extends State<GenotypeCombineList> {
  final _geneController = TextEditingController();
  final _alleleController = TextEditingController();

  bool _showGeneInput = false;
  bool _showAlleleInput = false;
  bool _isAddingGene = false;
  bool _isAddingAllele = false;

  GeneStoreDto? _selectedGene;

  @override
  void dispose() {
    _geneController.dispose();
    _alleleController.dispose();
    super.dispose();
  }

  Future<void> _addGene() async {
    final name = _geneController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAddingGene = true);
    try {
      await widget.onAddGene(name);
      _geneController.clear();
      setState(() => _showGeneInput = false);
    } finally {
      if (mounted) setState(() => _isAddingGene = false);
    }
  }

  Future<void> _addAllele() async {
    final name = _alleleController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAddingAllele = true);
    try {
      await widget.onAddAllele(name);
      _alleleController.clear();
      setState(() => _showAlleleInput = false);
    } finally {
      if (mounted) setState(() => _isAddingAllele = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildGenePanel(theme)),
          const SizedBox(width: 16),
          Expanded(child: _buildAllelePanel(theme)),
        ],
      );
    }

    return Column(
      children: [
        _buildGenePanel(theme),
        const SizedBox(height: 16),
        _buildAllelePanel(theme),
      ],
    );
  }

  Widget _buildGenePanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Genes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showGeneInput = !_showGeneInput);
                  },
                  icon: Icon(_showGeneInput ? Icons.close : Icons.add),
                  label: Text(_showGeneInput ? 'Cancel' : 'Add Gene'),
                ),
              ],
            ),
          ),

          // Add gene input
          if (_showGeneInput)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _geneController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Gene name',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _addGene(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isAddingGene ? null : _addGene,
                    icon: _isAddingGene
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                  ),
                ],
              ),
            ),

          // Gene list
          if (widget.genes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No genes added yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.genes.length,
                itemBuilder: (context, index) {
                  final gene = widget.genes[index];
                  final isSelected = _selectedGene?.geneUuid == gene.geneUuid;

                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                    title: Text(gene.geneName),
                    onTap: () {
                      setState(() => _selectedGene = gene);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => widget.onDeleteGene(gene),
                      tooltip: 'Delete gene',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllelePanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Alleles',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showAlleleInput = !_showAlleleInput);
                  },
                  icon: Icon(_showAlleleInput ? Icons.close : Icons.add),
                  label: Text(_showAlleleInput ? 'Cancel' : 'Add Allele'),
                ),
              ],
            ),
          ),

          // Add allele input
          if (_showAlleleInput)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _alleleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Allele name',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _addAllele(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isAddingAllele ? null : _addAllele,
                    icon: _isAddingAllele
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                  ),
                ],
              ),
            ),

          // Allele list
          if (widget.alleles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No alleles added yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.alleles.length,
                itemBuilder: (context, index) {
                  final allele = widget.alleles[index];
                  return ListTile(
                    dense: true,
                    title: Text(allele.alleleName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => widget.onDeleteAllele(allele),
                      tooltip: 'Delete allele',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
