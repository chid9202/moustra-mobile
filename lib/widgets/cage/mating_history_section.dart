import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/dtos/mating_history_dto.dart';

class MatingHistorySection extends StatelessWidget {
  final List<MatingHistoryDto> matings;

  const MatingHistorySection({super.key, required this.matings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mating History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${matings.length}'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(),
            ...matings.map((m) => _buildMatingItem(context, m)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatingItem(BuildContext context, MatingHistoryDto m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/mating/${m.matingUuid}'),
                child: Text(
                  m.matingTag ?? '(no tag)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  m.disbandedDate != null ? 'Disbanded' : 'Active',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: m.disbandedDate != null
                    ? Colors.grey.shade200
                    : Colors.green.shade100,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          Text(
            [
              m.litterStrain?.strainName,
              if (m.setUpDate != null) 'Set up: ${_formatDate(m.setUpDate)}',
              if (m.disbandedDate != null)
                'Disbanded: ${_formatDate(m.disbandedDate)}',
            ].whereType<String>().join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          // Litters
          if (m.litters != null)
            ...m.litters!.map(
              (l) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Text('Litter: ', style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      onTap: () => context.push('/litter/${l.litterUuid}'),
                      child: Text(
                        l.litterTag ?? '(no tag)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      ' · DOB: ${_formatDate(l.dateOfBirth)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    ..._buildSexChips(l.animals),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSexChips(dynamic animals) {
    if (animals == null || (animals as List).isEmpty) return [];
    int males = 0;
    int females = 0;
    int unknown = 0;
    for (final a in animals) {
      final sex = (a.sex ?? '').toString().toLowerCase();
      if (sex == 'm' || sex == 'male') {
        males++;
      } else if (sex == 'f' || sex == 'female') {
        females++;
      } else {
        unknown++;
      }
    }
    final chips = <Widget>[];
    if (males > 0) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Chip(
            label: Text('$males M', style: const TextStyle(fontSize: 10)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.blue.shade50,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }
    if (females > 0) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Chip(
            label: Text('$females F', style: const TextStyle(fontSize: 10)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.pink.shade50,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }
    if (unknown > 0) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Chip(
            label: Text('$unknown ?', style: const TextStyle(fontSize: 10)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }
    return chips;
  }

  String _formatDate(DateTime? d) => d != null
      ? '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}'
      : '';
}
