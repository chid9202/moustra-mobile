import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

void main() {
  group('DashboardResponseDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accounts': {
          'lab1': {
            'animalsCount': 10,
            'cagesCount': 5,
            'matingsCount': 3,
            'littersCount': 2,
            'name': 'Lab One',
          },
        },
        'animalByAge': [
          {
            'strainUuid': 'strain-uuid-1',
            'strainName': 'C57BL/6',
            'ageData': [
              {'ageInWeeks': 4, 'count': 12},
              {'ageInWeeks': 8, 'count': 5},
            ],
          },
        ],
        'animalsSexRatio': [
          {'sex': 'M', 'count': 15},
          {'sex': 'F', 'count': 20},
        ],
        'animalsToWean': [
          {
            'physicalTag': 'A001',
            'weanDate': '2024-01-15',
            'cage': {'cageTag': 'C001'},
          },
        ],
      };

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.accounts.length, equals(1));
      expect(dto.accounts['lab1']!.animalsCount, equals(10));
      expect(dto.accounts['lab1']!.cagesCount, equals(5));
      expect(dto.accounts['lab1']!.matingsCount, equals(3));
      expect(dto.accounts['lab1']!.littersCount, equals(2));
      expect(dto.accounts['lab1']!.name, equals('Lab One'));
      expect(dto.animalByAge.length, equals(1));
      expect(dto.animalByAge[0].strainUuid, equals('strain-uuid-1'));
      expect(dto.animalByAge[0].strainName, equals('C57BL/6'));
      expect(dto.animalByAge[0].ageData.length, equals(2));
      expect(dto.animalByAge[0].ageData[0].ageInWeeks, equals(4));
      expect(dto.animalByAge[0].ageData[0].count, equals(12));
      expect(dto.animalsSexRatio.length, equals(2));
      expect(dto.animalsSexRatio[0].sex, equals('M'));
      expect(dto.animalsSexRatio[0].count, equals(15));
      expect(dto.animalsToWean.length, equals(1));
      expect(dto.animalsToWean[0].physicalTag, equals('A001'));
      expect(dto.animalsToWean[0].weanDate, equals('2024-01-15'));
      expect(dto.animalsToWean[0].cageTag, equals('C001'));
    });

    test('fromJson with minimal/empty data', () {
      final json = <String, dynamic>{};

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.accounts, isEmpty);
      expect(dto.animalByAge, isEmpty);
      expect(dto.animalsSexRatio, isEmpty);
      expect(dto.animalsToWean, isEmpty);
    });

    test('toJson round-trip', () {
      final json = {
        'accounts': {
          'lab1': {
            'animalsCount': 10,
            'cagesCount': 5,
            'matingsCount': 3,
            'littersCount': 2,
            'name': 'Lab One',
          },
        },
        'animalByAge': <Map<String, dynamic>>[],
        'animalsSexRatio': <Map<String, dynamic>>[],
        'animalsToWean': <Map<String, dynamic>>[],
      };

      final dto = DashboardResponseDto.fromJson(json);
      final output = dto.toJson();

      expect(
        (output['accounts'] as Map)['lab1']['animalsCount'],
        equals(10),
      );
      expect(output['animalByAge'], isEmpty);
    });
  });

  group('AccountSummaryDto', () {
    test('fromJson with null values defaults to zero', () {
      final json = <String, dynamic>{};
      final dto = AccountSummaryDto.fromJson(json);

      expect(dto.animalsCount, equals(0));
      expect(dto.cagesCount, equals(0));
      expect(dto.matingsCount, equals(0));
      expect(dto.littersCount, equals(0));
      expect(dto.name, isNull);
    });
  });

  group('SexRatioDto', () {
    test('fromJson with null sex', () {
      final json = {'count': 5};
      final dto = SexRatioDto.fromJson(json);

      expect(dto.sex, isNull);
      expect(dto.count, equals(5));
    });
  });

  group('AnimalToWeanDto', () {
    test('fromJson without cage object', () {
      final json = {
        'physicalTag': 'A002',
        'weanDate': '2024-02-01',
      };
      final dto = AnimalToWeanDto.fromJson(json);

      expect(dto.physicalTag, equals('A002'));
      expect(dto.cageTag, equals(''));
    });
  });
}
