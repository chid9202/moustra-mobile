import 'package:flutter/material.dart';

import 'detail_item.dart';

class DetailedItemWidget extends StatelessWidget {
  final DetailedItem item;
  final int detailLevel;

  const DetailedItemWidget({
    super.key,
    required this.item,
    required this.detailLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Conditional rendering based on detailLevel
            switch (detailLevel) {
              1 => Text(item.detailLevel1),
              2 => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(item.detailLevel1), Text(item.detailLevel2)],
              ),
              3 => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.detailLevel1),
                  Text(item.detailLevel2),
                  Text(item.detailLevel3),
                ],
              ),
              4 => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.detailLevel1),
                  Text(item.detailLevel2),
                  Text(item.detailLevel3),
                  Text(item.detailLevel4),
                ],
              ),
              5 => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.detailLevel1),
                  Text(item.detailLevel2),
                  Text(item.detailLevel3),
                  Text(item.detailLevel4),
                  Text(item.detailLevel5),
                ],
              ),
              _ => const Text('Invalid detail level specified.'),
            },
          ],
        ),
      ),
    );
  }
}
