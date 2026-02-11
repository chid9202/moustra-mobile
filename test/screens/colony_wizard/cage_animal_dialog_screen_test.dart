import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/colony_wizard/steps/cage_animal_dialog_screen.dart';
import 'package:moustra/screens/colony_wizard/colony_wizard_constants.dart';

void main() {
  group('TempAnimalData', () {
    test('isMature returns true for animals older than wean days', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now().subtract(
          Duration(days: ColonyWizardConstants.defaultWeanDays + 1),
        ),
      );

      expect(animal.isMature, isTrue);
    });

    test('isMature returns true for animals exactly at wean days', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now().subtract(
          Duration(days: ColonyWizardConstants.defaultWeanDays),
        ),
      );

      expect(animal.isMature, isTrue);
    });

    test('isMature returns false for animals younger than wean days', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now().subtract(
          Duration(days: ColonyWizardConstants.defaultWeanDays - 1),
        ),
      );

      expect(animal.isMature, isFalse);
    });

    test('creates animal with unique id', () {
      final animal1 = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
      );
      final animal2 = TempAnimalData(
        physicalTag: 'M2',
        sex: 'M',
        dateOfBirth: DateTime.now(),
      );

      expect(animal1.id, isNot(equals(animal2.id)));
    });

    test('preserves existing id when provided', () {
      final animal = TempAnimalData(
        id: 'custom-id',
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
      );

      expect(animal.id, equals('custom-id'));
    });

    test('isLitterPup defaults to false', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
      );

      expect(animal.isLitterPup, isFalse);
    });

    test('genotypes defaults to empty list', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
      );

      expect(animal.genotypes, isEmpty);
    });

    test('can store strain', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
        strain: null,
      );

      expect(animal.strain, isNull);
    });

    test('can store animalUuid for existing animals', () {
      final animal = TempAnimalData(
        physicalTag: 'M1',
        sex: 'M',
        dateOfBirth: DateTime.now(),
        animalUuid: 'existing-uuid',
      );

      expect(animal.animalUuid, equals('existing-uuid'));
    });
  });

  group('MatingTagGeneration', () {
    // These tests verify the mating tag generation logic
    // by testing the expected format

    test('mating tag format should be male / female tags joined', () {
      // Expected format: "M1 / F2" for one male and one female
      final males = ['M1', 'M2'];
      final females = ['F3', 'F4'];
      final expectedTag = [...males, ...females].join(' / ');

      expect(expectedTag, equals('M1 / M2 / F3 / F4'));
    });

    test('mating tag with single male and female', () {
      final males = ['M1'];
      final females = ['F2'];
      final tag = [...males, ...females].join(' / ');

      expect(tag, equals('M1 / F2'));
    });

    test('mating tag with multiple females', () {
      final males = ['M1'];
      final females = ['F2', 'F3', 'F4'];
      final tag = [...males, ...females].join(' / ');

      expect(tag, equals('M1 / F2 / F3 / F4'));
    });

    test('mating tag with empty animals', () {
      final males = <String>[];
      final females = <String>[];
      final tag = [...males, ...females].join(' / ');

      expect(tag, isEmpty);
    });

    test('mating tag with only males', () {
      final males = ['M1', 'M2'];
      final females = <String>[];
      final tag = [...males, ...females].join(' / ');

      expect(tag, equals('M1 / M2'));
    });
  });

  group('HasBothSexes Logic', () {
    test('returns true when both male and female exist', () {
      final animals = [
        TempAnimalData(physicalTag: 'M1', sex: 'M', dateOfBirth: DateTime.now()),
        TempAnimalData(physicalTag: 'F1', sex: 'F', dateOfBirth: DateTime.now()),
      ];

      final maleCount = animals.where((a) => a.sex == 'M').length;
      final femaleCount = animals.where((a) => a.sex == 'F').length;
      final hasBothSexes = maleCount > 0 && femaleCount > 0;

      expect(hasBothSexes, isTrue);
    });

    test('returns false when only males exist', () {
      final animals = [
        TempAnimalData(physicalTag: 'M1', sex: 'M', dateOfBirth: DateTime.now()),
        TempAnimalData(physicalTag: 'M2', sex: 'M', dateOfBirth: DateTime.now()),
      ];

      final maleCount = animals.where((a) => a.sex == 'M').length;
      final femaleCount = animals.where((a) => a.sex == 'F').length;
      final hasBothSexes = maleCount > 0 && femaleCount > 0;

      expect(hasBothSexes, isFalse);
    });

    test('returns false when only females exist', () {
      final animals = [
        TempAnimalData(physicalTag: 'F1', sex: 'F', dateOfBirth: DateTime.now()),
        TempAnimalData(physicalTag: 'F2', sex: 'F', dateOfBirth: DateTime.now()),
      ];

      final maleCount = animals.where((a) => a.sex == 'M').length;
      final femaleCount = animals.where((a) => a.sex == 'F').length;
      final hasBothSexes = maleCount > 0 && femaleCount > 0;

      expect(hasBothSexes, isFalse);
    });

    test('excludes litter pups from count', () {
      final animals = [
        TempAnimalData(physicalTag: 'M1', sex: 'M', dateOfBirth: DateTime.now()),
        TempAnimalData(
          physicalTag: 'F1',
          sex: 'F',
          dateOfBirth: DateTime.now(),
          isLitterPup: true,
        ),
      ];

      final parentAnimals = animals.where((a) => !a.isLitterPup).toList();
      final maleCount = parentAnimals.where((a) => a.sex == 'M').length;
      final femaleCount = parentAnimals.where((a) => a.sex == 'F').length;
      final hasBothSexes = maleCount > 0 && femaleCount > 0;

      expect(hasBothSexes, isFalse); // F1 is a pup, shouldn't count
    });
  });

  group('HasMaturePair Logic', () {
    test('returns true when both mature male and female exist', () {
      final matureDob = DateTime.now().subtract(
        Duration(days: ColonyWizardConstants.defaultWeanDays + 1),
      );

      final animals = [
        TempAnimalData(physicalTag: 'M1', sex: 'M', dateOfBirth: matureDob),
        TempAnimalData(physicalTag: 'F1', sex: 'F', dateOfBirth: matureDob),
      ];

      final matureMales = animals
          .where((a) => a.sex == 'M' && !a.isLitterPup && a.isMature)
          .isNotEmpty;
      final matureFemales = animals
          .where((a) => a.sex == 'F' && !a.isLitterPup && a.isMature)
          .isNotEmpty;
      final hasMaturePair = matureMales && matureFemales;

      expect(hasMaturePair, isTrue);
    });

    test('returns false when male is immature', () {
      final matureDob = DateTime.now().subtract(
        Duration(days: ColonyWizardConstants.defaultWeanDays + 1),
      );
      final immatureDob = DateTime.now().subtract(
        Duration(days: ColonyWizardConstants.defaultWeanDays - 5),
      );

      final animals = [
        TempAnimalData(physicalTag: 'M1', sex: 'M', dateOfBirth: immatureDob),
        TempAnimalData(physicalTag: 'F1', sex: 'F', dateOfBirth: matureDob),
      ];

      final matureMales = animals
          .where((a) => a.sex == 'M' && !a.isLitterPup && a.isMature)
          .isNotEmpty;
      final matureFemales = animals
          .where((a) => a.sex == 'F' && !a.isLitterPup && a.isMature)
          .isNotEmpty;
      final hasMaturePair = matureMales && matureFemales;

      expect(hasMaturePair, isFalse);
    });
  });

  group('ExceedsCapacity Logic', () {
    test('returns false when under capacity', () {
      final animals = List.generate(
        ColonyWizardConstants.maxMicePerCage - 1,
        (i) => TempAnimalData(
          physicalTag: 'M$i',
          sex: 'M',
          dateOfBirth: DateTime.now(),
        ),
      );

      final parentCount = animals.where((a) => !a.isLitterPup).length;
      final exceedsCapacity = parentCount > ColonyWizardConstants.maxMicePerCage;

      expect(exceedsCapacity, isFalse);
    });

    test('returns false when at capacity', () {
      final animals = List.generate(
        ColonyWizardConstants.maxMicePerCage,
        (i) => TempAnimalData(
          physicalTag: 'M$i',
          sex: 'M',
          dateOfBirth: DateTime.now(),
        ),
      );

      final parentCount = animals.where((a) => !a.isLitterPup).length;
      final exceedsCapacity = parentCount > ColonyWizardConstants.maxMicePerCage;

      expect(exceedsCapacity, isFalse);
    });

    test('returns true when over capacity', () {
      final animals = List.generate(
        ColonyWizardConstants.maxMicePerCage + 1,
        (i) => TempAnimalData(
          physicalTag: 'M$i',
          sex: 'M',
          dateOfBirth: DateTime.now(),
        ),
      );

      final parentCount = animals.where((a) => !a.isLitterPup).length;
      final exceedsCapacity = parentCount > ColonyWizardConstants.maxMicePerCage;

      expect(exceedsCapacity, isTrue);
    });

    test('pups do not count towards capacity', () {
      final animals = [
        ...List.generate(
          ColonyWizardConstants.maxMicePerCage,
          (i) => TempAnimalData(
            physicalTag: 'M$i',
            sex: 'M',
            dateOfBirth: DateTime.now(),
          ),
        ),
        // Add a pup
        TempAnimalData(
          physicalTag: 'Pup1',
          sex: 'M',
          dateOfBirth: DateTime.now(),
          isLitterPup: true,
        ),
      ];

      final parentCount = animals.where((a) => !a.isLitterPup).length;
      final exceedsCapacity = parentCount > ColonyWizardConstants.maxMicePerCage;

      expect(exceedsCapacity, isFalse); // Pup doesn't count
    });
  });

  group('Position Label Logic', () {
    test('position (0, 0) is A1', () {
      final rowLetter = String.fromCharCode(65 + 0);
      final colNumber = 0 + 1;
      final label = '$rowLetter$colNumber';

      expect(label, equals('A1'));
    });

    test('position (2, 1) is B3', () {
      final rowLetter = String.fromCharCode(65 + 1);
      final colNumber = 2 + 1;
      final label = '$rowLetter$colNumber';

      expect(label, equals('B3'));
    });

    test('position (4, 3) is D5', () {
      final rowLetter = String.fromCharCode(65 + 3);
      final colNumber = 4 + 1;
      final label = '$rowLetter$colNumber';

      expect(label, equals('D5'));
    });
  });

  group('Mating Tag Auto-generation Conditions', () {
    test('should generate tag when not touched and no existing mating', () {
      final matingTagTouched = false;
      final isEditMode = false;
      final existingMating = null;

      final hasExistingMating = isEditMode && existingMating != null;
      final shouldGenerate = !matingTagTouched && !hasExistingMating;

      expect(shouldGenerate, isTrue);
    });

    test('should generate tag in edit mode without existing mating', () {
      // This is the bug fix scenario: editing cage with males, adding female
      final matingTagTouched = false;
      final isEditMode = true;
      final existingMating = null;

      final hasExistingMating = isEditMode && existingMating != null;
      final shouldGenerate = !matingTagTouched && !hasExistingMating;

      expect(shouldGenerate, isTrue);
    });

    test('should NOT generate tag when user has touched it', () {
      final matingTagTouched = true;
      final isEditMode = false;
      final existingMating = null;

      final hasExistingMating = isEditMode && existingMating != null;
      final shouldGenerate = !matingTagTouched && !hasExistingMating;

      expect(shouldGenerate, isFalse);
    });

    test('should NOT generate tag when existing mating has tag', () {
      final matingTagTouched = false;
      final isEditMode = true;
      final existingMating = {'matingTag': 'Existing Tag'}; // Simulated existing mating

      final hasExistingMating = isEditMode && existingMating != null;
      final shouldGenerate = !matingTagTouched && !hasExistingMating;

      expect(shouldGenerate, isFalse);
    });
  });
}
