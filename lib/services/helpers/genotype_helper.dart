import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';

class GenotypeHelper {
  static String formatGenotypes(List<GenotypeDto>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final String gene = (g.gene?.geneName ?? '').toString();
          final String allele = (g.allele?.alleleName ?? '').toString();
          if (gene.isNotEmpty && allele.isNotEmpty) {
            return '$gene/$allele';
          }
          if (gene.isNotEmpty) {
            return gene;
          }
          if (allele.isNotEmpty) {
            return allele;
          }
          return '';
        })
        .join(', ');
  }

  static String getDamNames(List<AnimalSummaryDto>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((d) => (d.physicalTag ?? '').toString())
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}
