import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';

void main() {
  group('AnimalHelper', () {
    group('getAge', () {
      test('returns empty string when dateOfBirth is null', () {
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: null,
        );
        expect(AnimalHelper.getAge(animal), '');
      });

      test('returns days only when less than 7 days old', () {
        final dob = DateTime.now().subtract(const Duration(days: 3));
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAge(animal), '3d');
      });

      test('returns 0d for animal born today', () {
        final dob = DateTime.now();
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAge(animal), '0d');
      });

      test('returns weeks only when days remainder is 0', () {
        final dob = DateTime.now().subtract(const Duration(days: 14));
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAge(animal), '2w');
      });

      test('returns weeks and days combination', () {
        final dob = DateTime.now().subtract(const Duration(days: 17));
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAge(animal), '2w3d');
      });

      test('handles future dateOfBirth by clamping to 0', () {
        final dob = DateTime.now().add(const Duration(days: 5));
        final animal = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAge(animal), '0d');
      });
    });

    group('getAnimalOptionLabel', () {
      test('formats with all fields present', () {
        final dob = DateTime(2024, 3, 15);
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          physicalTag: 'TAG-001',
          sex: 'Male',
          dateOfBirth: dob,
        );
        expect(AnimalHelper.getAnimalOptionLabel(animal),
            'TAG-001 / Male / 03/15/2024');
      });

      test('uses N/A for missing physicalTag', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          physicalTag: null,
          sex: 'Female',
          dateOfBirth: DateTime(2024, 1, 1),
        );
        final result = AnimalHelper.getAnimalOptionLabel(animal);
        expect(result, startsWith('N/A / Female'));
      });

      test('uses N/A for missing sex', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          physicalTag: 'TAG-001',
          sex: null,
          dateOfBirth: DateTime(2024, 1, 1),
        );
        final result = AnimalHelper.getAnimalOptionLabel(animal);
        expect(result, contains('N/A'));
        expect(result, startsWith('TAG-001 / N/A'));
      });

      test('uses N/A for missing dateOfBirth', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          physicalTag: 'TAG-001',
          sex: 'Male',
          dateOfBirth: null,
        );
        expect(AnimalHelper.getAnimalOptionLabel(animal),
            'TAG-001 / Male / N/A');
      });

      test('all fields missing returns N/A for each', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
        );
        expect(AnimalHelper.getAnimalOptionLabel(animal), 'N/A / N/A / N/A');
      });
    });

    group('isMature', () {
      test('returns true when weanDate is in the past', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          weanDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(AnimalHelper.isMature(animal), true);
      });

      test('returns false when weanDate is in the future', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          weanDate: DateTime.now().add(const Duration(days: 5)),
        );
        expect(AnimalHelper.isMature(animal), false);
      });

      test('returns true when dateOfBirth + 21 days is in the past', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(AnimalHelper.isMature(animal), true);
      });

      test('returns false when dateOfBirth + 21 days is in the future', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          dateOfBirth: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(AnimalHelper.isMature(animal), false);
      });

      test('returns false when both weanDate and dateOfBirth are null', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
        );
        expect(AnimalHelper.isMature(animal), false);
      });

      test('weanDate takes priority over dateOfBirth', () {
        // weanDate in the past, but dateOfBirth would say not mature
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          weanDate: DateTime.now().subtract(const Duration(days: 1)),
          dateOfBirth: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(AnimalHelper.isMature(animal), true);
      });

      test('weanDate in future takes priority over old dateOfBirth', () {
        final animal = AnimalStoreDto(
          eid: 1,
          animalId: 1,
          animalUuid: 'uuid1',
          weanDate: DateTime.now().add(const Duration(days: 5)),
          dateOfBirth: DateTime.now().subtract(const Duration(days: 60)),
        );
        expect(AnimalHelper.isMature(animal), false);
      });
    });
  });
}
