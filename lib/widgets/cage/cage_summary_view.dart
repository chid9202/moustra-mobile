import 'package:flutter/material.dart';
import 'package:moustra/widgets/cage/shared.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

class CageSummaryView extends StatelessWidget {
  const CageSummaryView(this.cage, {super.key});

  final CageDto cage;

  @override
  Widget build(BuildContext context) {
    final males = cage.animals.where((e) => e.sex == 'M');
    final females = cage.animals.where((e) => e.sex == 'F');
    final widgets = [
      ExpansionTile(
        title: CageListItem(label: 'Male', content: '${males.length}'),
        tilePadding: EdgeInsets.all(0.0),
        childrenPadding: EdgeInsets.all(0.0),
        children: [
          for (final male in males)
            Row(
              children: [
                Expanded(child: Text(male.animalUuid)),
                Expanded(child: Text('${male.animalId}')),
                Expanded(child: Text('${male.dateOfBirth}')),
                Expanded(child: Text('${male.strain?.strainName}')),
              ],
            ),
        ],
      ),
      ExpansionTile(
        title: CageListItem(label: 'Female', content: '${females.length}'),
        tilePadding: EdgeInsets.all(0.0),
        childrenPadding: EdgeInsets.all(0.0),
        children: [
          for (final female in females)
            Row(
              children: [
                Expanded(child: Text(female.animalUuid)),
                Expanded(child: Text('${female.animalId}')),
                Expanded(child: Text('${female.dateOfBirth}')),
                Expanded(child: Text('${female.strain?.strainName}')),
              ],
            ),
        ],
      ),
      CageListItem(label: 'Total', content: '${cage.animals.length}'),
    ];
    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return widgets[index];
      },
    );
  }
}

