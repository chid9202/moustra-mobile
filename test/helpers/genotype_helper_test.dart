import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';

void main() {
  group('GenotypeHelper', () {
    group('formatGenotypes', () {
      test('returns empty string for null list', () {
        expect(GenotypeHelper.formatGenotypes(null), '');
      });

      test('returns empty string for empty list', () {
        expect(GenotypeHelper.formatGenotypes([]), '');
      });

      test('formats gene/allele pair', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: 'Cre'),
            allele: AlleleDto(
                alleleId: 1, alleleUuid: 'u2', alleleName: 'Tg(Cre)'),
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), 'Cre/Tg(Cre)');
      });

      test('formats gene only when allele is null', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: 'Sox2'),
            allele: null,
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), 'Sox2');
      });

      test('formats allele only when gene is null', () {
        final list = [
          GenotypeDto(
            gene: null,
            allele:
                AlleleDto(alleleId: 1, alleleUuid: 'u2', alleleName: 'fl/fl'),
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), 'fl/fl');
      });

      test('filters out entries with both gene and allele null', () {
        final list = [
          GenotypeDto(gene: null, allele: null),
        ];
        expect(GenotypeHelper.formatGenotypes(list), '');
      });

      test('filters out entries with empty gene and allele names', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: ''),
            allele: AlleleDto(alleleId: 1, alleleUuid: 'u2', alleleName: ''),
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), '');
      });

      test('joins multiple genotypes with comma', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: 'Cre'),
            allele:
                AlleleDto(alleleId: 1, alleleUuid: 'u2', alleleName: 'Tg(Cre)'),
          ),
          GenotypeDto(
            gene: GeneDto(geneId: 2, geneUuid: 'u3', geneName: 'Rosa26'),
            allele:
                AlleleDto(alleleId: 2, alleleUuid: 'u4', alleleName: 'tdTomato'),
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list),
            'Cre/Tg(Cre), Rosa26/tdTomato');
      });

      test('filters empty entries from mixed list (bug fix verification)', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: 'Cre'),
            allele:
                AlleleDto(alleleId: 1, alleleUuid: 'u2', alleleName: 'Tg(Cre)'),
          ),
          GenotypeDto(gene: null, allele: null), // empty entry
          GenotypeDto(
            gene: GeneDto(geneId: 2, geneUuid: 'u3', geneName: ''),
            allele: AlleleDto(alleleId: 2, alleleUuid: 'u4', alleleName: ''),
          ), // empty names
          GenotypeDto(
            gene: GeneDto(geneId: 3, geneUuid: 'u5', geneName: 'Sox2'),
            allele: null,
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), 'Cre/Tg(Cre), Sox2');
      });

      test('gene with empty name but allele with name returns allele only', () {
        final list = [
          GenotypeDto(
            gene: GeneDto(geneId: 1, geneUuid: 'u1', geneName: ''),
            allele: AlleleDto(
                alleleId: 1, alleleUuid: 'u2', alleleName: 'SomeAllele'),
          ),
        ];
        expect(GenotypeHelper.formatGenotypes(list), 'SomeAllele');
      });
    });

    group('getDamNames', () {
      test('returns empty string for null list', () {
        expect(GenotypeHelper.getDamNames(null), '');
      });

      test('returns empty string for empty list', () {
        expect(GenotypeHelper.getDamNames([]), '');
      });

      test('returns single dam name', () {
        final list = [
          AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'uuid1',
            physicalTag: 'DAM-001',
          ),
        ];
        expect(GenotypeHelper.getDamNames(list), 'DAM-001');
      });

      test('joins multiple dam names with comma', () {
        final list = [
          AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'uuid1',
            physicalTag: 'DAM-001',
          ),
          AnimalSummaryDto(
            animalId: 2,
            animalUuid: 'uuid2',
            physicalTag: 'DAM-002',
          ),
        ];
        expect(GenotypeHelper.getDamNames(list), 'DAM-001, DAM-002');
      });

      test('filters out null physicalTags', () {
        final list = [
          AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'uuid1',
            physicalTag: null,
          ),
          AnimalSummaryDto(
            animalId: 2,
            animalUuid: 'uuid2',
            physicalTag: 'DAM-002',
          ),
        ];
        expect(GenotypeHelper.getDamNames(list), 'DAM-002');
      });

      test('filters out empty physicalTags', () {
        final list = [
          AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'uuid1',
            physicalTag: '',
          ),
        ];
        expect(GenotypeHelper.getDamNames(list), '');
      });
    });
  });
}
