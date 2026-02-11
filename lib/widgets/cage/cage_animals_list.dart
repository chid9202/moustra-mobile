import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

/// Displays a list of animals in a cage on the cage detail screen
class CageAnimalsList extends StatelessWidget {
  final List<AnimalSummaryDto> animals;
  final String cageUuid;
  final bool fromCageGrid;

  const CageAnimalsList({
    super.key,
    required this.animals,
    required this.cageUuid,
    this.fromCageGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Animals (${animals.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                context.push(
                  '/animal/new?cageUuid=$cageUuid${fromCageGrid ? '&fromCageGrid=true' : ''}',
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (animals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No animals in this cage',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return _AnimalListTile(
                animal: animal,
                fromCageGrid: fromCageGrid,
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AnimalListTile extends StatelessWidget {
  final AnimalSummaryDto animal;
  final bool fromCageGrid;

  const _AnimalListTile({
    required this.animal,
    required this.fromCageGrid,
  });

  @override
  Widget build(BuildContext context) {
    final sexColor = _getSexColor(animal.sex);
    final sexIcon = _getSexIcon(animal.sex);
    final age = _calculateAge(animal.dateOfBirth);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sexColor.withValues(alpha: 0.2),
          child: Icon(sexIcon, color: sexColor, size: 20),
        ),
        title: Text(
          animal.physicalTag ?? 'No tag',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _buildSubtitle(animal, age),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push(
            '/animal/${animal.animalUuid}${fromCageGrid ? '?fromCageGrid=true' : ''}',
          );
        },
      ),
    );
  }

  String _buildSubtitle(AnimalSummaryDto animal, String? age) {
    final parts = <String>[];
    
    if (animal.sex != null) {
      parts.add(animal.sex == 'M' ? 'Male' : animal.sex == 'F' ? 'Female' : animal.sex!);
    }
    
    if (age != null) {
      parts.add(age);
    }
    
    if (animal.strain?.strainName != null) {
      parts.add(animal.strain!.strainName);
    }
    
    return parts.join(' • ');
  }

  String? _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);
    final days = difference.inDays;
    
    if (days < 7) {
      return '${days}d old';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '${weeks}w old';
    } else {
      final months = (days / 30).floor();
      return '${months}mo old';
    }
  }

  IconData _getSexIcon(String? sex) {
    switch (sex) {
      case 'M':
        return Icons.male;
      case 'F':
        return Icons.female;
      default:
        return Icons.question_mark;
    }
  }

  Color _getSexColor(String? sex) {
    switch (sex) {
      case 'M':
        return Colors.blue;
      case 'F':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
