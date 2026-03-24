import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

void main() {
  group('ColonySummaryDto', () {
    test('fromJson with complete data', () {
      final json = {
        'totalAnimals': 42,
        'activeCages': 15,
        'activeMatings': 8,
        'totalLitters': 5,
      };
      final dto = ColonySummaryDto.fromJson(json);

      expect(dto.totalAnimals, equals(42));
      expect(dto.activeCages, equals(15));
      expect(dto.activeMatings, equals(8));
      expect(dto.totalLitters, equals(5));
    });

    test('fromJson with null values defaults to zero', () {
      final json = <String, dynamic>{};
      final dto = ColonySummaryDto.fromJson(json);

      expect(dto.totalAnimals, equals(0));
      expect(dto.activeCages, equals(0));
      expect(dto.activeMatings, equals(0));
      expect(dto.totalLitters, equals(0));
    });

    test('toJson round-trip', () {
      final dto = ColonySummaryDto(
        totalAnimals: 10,
        activeCages: 5,
        activeMatings: 3,
        totalLitters: 2,
      );
      final json = dto.toJson();

      expect(json['totalAnimals'], equals(10));
      expect(json['activeCages'], equals(5));
      expect(json['activeMatings'], equals(3));
      expect(json['totalLitters'], equals(2));
    });
  });

  group('DashboardResponseDto', () {
    test('fromJson with complete data', () {
      final json = {
        'colonySummary': {
          'totalAnimals': 42,
          'activeCages': 15,
          'activeMatings': 8,
          'totalLitters': 5,
        },
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
              {'ageBucket': '0-4 wk', 'count': 12, 'sortOrder': 0},
              {'ageBucket': '4-8 wk', 'count': 5, 'sortOrder': 1},
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

      expect(dto.colonySummary, isNotNull);
      expect(dto.colonySummary!.totalAnimals, equals(42));
      expect(dto.colonySummary!.activeCages, equals(15));
      expect(dto.colonySummary!.activeMatings, equals(8));
      expect(dto.colonySummary!.totalLitters, equals(5));
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
      expect(dto.animalByAge[0].ageData[0].ageBucket, equals('0-4 wk'));
      expect(dto.animalByAge[0].ageData[0].count, equals(12));
      expect(dto.animalByAge[0].ageData[0].sortOrder, equals(0));
      expect(dto.animalByAge[0].ageData[1].ageBucket, equals('4-8 wk'));
      expect(dto.animalByAge[0].ageData[1].sortOrder, equals(1));
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

      expect(dto.colonySummary, isNull);
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

  group('AgeDataPointDto', () {
    test('fromJson parses ageBucket and sortOrder', () {
      final json = {'ageBucket': '4-8 wk', 'count': 7, 'sortOrder': 1};
      final dto = AgeDataPointDto.fromJson(json);

      expect(dto.ageBucket, equals('4-8 wk'));
      expect(dto.count, equals(7));
      expect(dto.sortOrder, equals(1));
    });

    test('fromJson with null values defaults correctly', () {
      final json = <String, dynamic>{};
      final dto = AgeDataPointDto.fromJson(json);

      expect(dto.ageBucket, equals(''));
      expect(dto.count, equals(0));
      expect(dto.sortOrder, equals(0));
    });

    test('toJson round-trip', () {
      final dto = AgeDataPointDto(ageBucket: '52+ wk', count: 3, sortOrder: 5);
      final json = dto.toJson();

      expect(json['ageBucket'], equals('52+ wk'));
      expect(json['count'], equals(3));
      expect(json['sortOrder'], equals(5));
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

  group('LittersPerMonthDto', () {
    test('fromJson with complete data', () {
      final json = {'month': '2026-03', 'count': 5};
      final dto = LittersPerMonthDto.fromJson(json);

      expect(dto.month, equals('2026-03'));
      expect(dto.count, equals(5));
    });

    test('fromJson with null values defaults correctly', () {
      final json = <String, dynamic>{};
      final dto = LittersPerMonthDto.fromJson(json);

      expect(dto.month, equals(''));
      expect(dto.count, equals(0));
    });

    test('toJson round-trip', () {
      final dto = LittersPerMonthDto(month: '2026-01', count: 3);
      final json = dto.toJson();

      expect(json['month'], equals('2026-01'));
      expect(json['count'], equals(3));
    });
  });

  group('BreedingPerformanceDto', () {
    test('fromJson with complete data', () {
      final json = {
        'averageLitterSize': 7.2,
        'matingSuccessRate': 85.5,
        'medianTimeToFirstLitter': 28.0,
        'pupSurvivalRate': 92.3,
        'activeBreedingPairs': 12,
        'littersPerMonth': [
          {'month': '2025-10', 'count': 2},
          {'month': '2025-11', 'count': 5},
        ],
      };
      final dto = BreedingPerformanceDto.fromJson(json);

      expect(dto.averageLitterSize, equals(7.2));
      expect(dto.matingSuccessRate, equals(85.5));
      expect(dto.medianTimeToFirstLitter, equals(28.0));
      expect(dto.pupSurvivalRate, equals(92.3));
      expect(dto.activeBreedingPairs, equals(12));
      expect(dto.littersPerMonth.length, equals(2));
      expect(dto.littersPerMonth[0].month, equals('2025-10'));
      expect(dto.littersPerMonth[0].count, equals(2));
    });

    test('fromJson with null metrics', () {
      final json = {
        'averageLitterSize': null,
        'matingSuccessRate': null,
        'medianTimeToFirstLitter': null,
        'pupSurvivalRate': null,
        'activeBreedingPairs': 0,
        'littersPerMonth': <Map<String, dynamic>>[],
      };
      final dto = BreedingPerformanceDto.fromJson(json);

      expect(dto.averageLitterSize, isNull);
      expect(dto.matingSuccessRate, isNull);
      expect(dto.medianTimeToFirstLitter, isNull);
      expect(dto.pupSurvivalRate, isNull);
      expect(dto.activeBreedingPairs, equals(0));
      expect(dto.littersPerMonth, isEmpty);
    });

    test('toJson round-trip', () {
      final dto = BreedingPerformanceDto(
        averageLitterSize: 5.5,
        matingSuccessRate: 70.0,
        medianTimeToFirstLitter: 30.0,
        pupSurvivalRate: 88.0,
        activeBreedingPairs: 8,
        littersPerMonth: [
          LittersPerMonthDto(month: '2026-01', count: 3),
        ],
      );
      final json = dto.toJson();

      expect(json['averageLitterSize'], equals(5.5));
      expect(json['matingSuccessRate'], equals(70.0));
      expect(json['activeBreedingPairs'], equals(8));
      expect((json['littersPerMonth'] as List).length, equals(1));
    });
  });

  group('RecentActivityDto', () {
    test('fromJson with complete data', () {
      final json = {
        'type': 'litter_born',
        'date': '2026-03-24',
        'description': 'New litter born (5 pups)',
        'detail': 'C57BL/6',
        'linkUuid': 'litter-uuid-1',
      };
      final dto = RecentActivityDto.fromJson(json);

      expect(dto.type, equals('litter_born'));
      expect(dto.date, equals('2026-03-24'));
      expect(dto.description, equals('New litter born (5 pups)'));
      expect(dto.detail, equals('C57BL/6'));
      expect(dto.linkUuid, equals('litter-uuid-1'));
    });

    test('fromJson with null optional fields', () {
      final json = {
        'type': 'animals_weaned',
        'date': '2026-03-23',
        'description': '3 animal(s) weaned',
        'detail': null,
        'linkUuid': null,
      };
      final dto = RecentActivityDto.fromJson(json);

      expect(dto.type, equals('animals_weaned'));
      expect(dto.detail, isNull);
      expect(dto.linkUuid, isNull);
    });

    test('fromJson with empty json defaults', () {
      final json = <String, dynamic>{};
      final dto = RecentActivityDto.fromJson(json);

      expect(dto.type, equals(''));
      expect(dto.date, equals(''));
      expect(dto.description, equals(''));
      expect(dto.detail, isNull);
      expect(dto.linkUuid, isNull);
    });

    test('toJson round-trip', () {
      final dto = RecentActivityDto(
        type: 'mating_setup',
        date: '2026-03-24',
        description: 'Mating set up: Pair A',
        detail: 'C57BL/6',
        linkUuid: 'mating-uuid-1',
      );
      final json = dto.toJson();

      expect(json['type'], equals('mating_setup'));
      expect(json['date'], equals('2026-03-24'));
      expect(json['description'], equals('Mating set up: Pair A'));
      expect(json['detail'], equals('C57BL/6'));
      expect(json['linkUuid'], equals('mating-uuid-1'));
    });
  });

  group('DashboardResponseDto with breedingPerformance', () {
    test('fromJson includes breedingPerformance', () {
      final json = {
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
        'breedingPerformance': {
          'averageLitterSize': 6.0,
          'matingSuccessRate': 80.0,
          'medianTimeToFirstLitter': 25.0,
          'pupSurvivalRate': 95.0,
          'activeBreedingPairs': 5,
          'littersPerMonth': [
            {'month': '2026-03', 'count': 4},
          ],
        },
      };

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.breedingPerformance, isNotNull);
      expect(dto.breedingPerformance!.averageLitterSize, equals(6.0));
      expect(dto.breedingPerformance!.activeBreedingPairs, equals(5));
      expect(dto.breedingPerformance!.littersPerMonth.length, equals(1));
    });

    test('fromJson without breedingPerformance', () {
      final json = {
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
      };

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.breedingPerformance, isNull);
    });
  });

  group('DashboardResponseDto with recentActivity', () {
    test('fromJson includes recentActivity', () {
      final json = {
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
        'recentActivity': [
          {
            'type': 'litter_born',
            'date': '2026-03-24',
            'description': 'New litter born (5 pups)',
            'detail': 'C57BL/6',
            'linkUuid': 'litter-uuid-1',
          },
          {
            'type': 'animals_weaned',
            'date': '2026-03-23',
            'description': '3 animal(s) weaned',
            'detail': null,
            'linkUuid': null,
          },
        ],
      };

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.recentActivity.length, equals(2));
      expect(dto.recentActivity[0].type, equals('litter_born'));
      expect(dto.recentActivity[0].description, equals('New litter born (5 pups)'));
      expect(dto.recentActivity[0].detail, equals('C57BL/6'));
      expect(dto.recentActivity[0].linkUuid, equals('litter-uuid-1'));
      expect(dto.recentActivity[1].type, equals('animals_weaned'));
      expect(dto.recentActivity[1].detail, isNull);
    });

    test('fromJson without recentActivity defaults to empty list', () {
      final json = {
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
      };

      final dto = DashboardResponseDto.fromJson(json);

      expect(dto.recentActivity, isEmpty);
    });
  });
}
