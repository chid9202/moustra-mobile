import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimalsToWean extends StatelessWidget {
  const AnimalsToWean(this.animalsToWean, {super.key});

  final List<dynamic> animalsToWean;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animals To Wean',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...animalsToWean.take(10).map((a) {
          final tag = (a['physicalTag'] ?? '').toString();
          final wean = (a['weanDate'] ?? '').toString();
          final cageTag = (a['cage']?['cageTag'] ?? '').toString();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    child: Text(
                      tag.isEmpty ? '(no tag)' : tag,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                  child: Text('→', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 120,
                  child: Align(
                    child: Text(cageTag, overflow: TextOverflow.ellipsis),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Align(
                    child: Text(_formatDate(wean), textAlign: TextAlign.right),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y').format(dt);
  }
}
