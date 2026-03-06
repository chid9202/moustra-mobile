import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/family_tree_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

class FamilyTreeWidget extends StatefulWidget {
  final String animalUuid;

  const FamilyTreeWidget({super.key, required this.animalUuid});

  @override
  State<FamilyTreeWidget> createState() => _FamilyTreeWidgetState();
}

class _FamilyTreeWidgetState extends State<FamilyTreeWidget> {
  late Future<FamilyTreeDto> _future;

  @override
  void initState() {
    super.initState();
    _future = animalService.getAnimalFamilyTree(widget.animalUuid);
  }

  List<LitterAnimalDto> _toLitterAnimals(List<MatingSummaryAnimalDto>? animals) {
    if (animals == null) return [];
    return animals
        .map((a) => LitterAnimalDto(
              animalId: a.animalId,
              animalUuid: a.animalUuid,
              physicalTag: a.physicalTag,
              sex: a.sex,
              dateOfBirth: a.dateOfBirth,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FamilyTreeDto>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load family tree: ${snapshot.error}'),
          );
        }
        final tree = snapshot.data;
        if (tree == null) {
          return const Center(child: Text('No family tree data'));
        }

        final hasParent = tree.parent?.litterUuid != null;
        final hasChildren = tree.children?.litterUuid != null;

        if (!hasParent && !hasChildren) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No family tree is found',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        final parents = _toLitterAnimals(tree.parent?.mating?.animals);
        final currentGeneration = tree.parent?.animals ??
            _toLitterAnimals(tree.children?.mating?.animals);
        final children = tree.children?.animals ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Parents'),
              const SizedBox(height: 8),
              if (parents.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No parents found'),
                )
              else
                _buildAnimalRow(context, parents),

              const Divider(),
              _buildSectionHeader(context, 'Current Generation'),
              const SizedBox(height: 8),
              _buildAnimalRow(context, currentGeneration),

              const Divider(),
              _buildSectionHeader(context, 'Children'),
              const SizedBox(height: 8),
              if (children.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No children found'),
                )
              else
                _buildAnimalRow(context, children),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildAnimalRow(BuildContext context, List<LitterAnimalDto> animals) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: animals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final animal = animals[index];
          final isSelected = animal.animalUuid == widget.animalUuid;
          return _buildAnimalCard(context, animal, isSelected);
        },
      ),
    );
  }

  Widget _buildAnimalCard(
    BuildContext context,
    LitterAnimalDto animal,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.go('/animal/${animal.animalUuid}');
        }
      },
      child: Card(
        elevation: isSelected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    animal.sex == 'M' ? Icons.male : Icons.female,
                    size: 18,
                    color: animal.sex == 'M' ? Colors.blue : Colors.pink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    animal.physicalTag ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (animal.strain?.strainName != null)
                Text(
                  animal.strain!.strainName,
                  style: theme.textTheme.bodySmall,
                ),
              if (animal.dateOfBirth != null)
                Text(
                  'DOB: ${_formatDate(animal.dateOfBirth!)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
}
