import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/colony_wizard/state/wizard_state.dart';
import 'package:moustra/screens/colony_wizard/colony_wizard_constants.dart';

void main() {
  late WizardState state;

  setUp(() {
    state = WizardState();
  });

  group('WizardState initial state', () {
    test('all counters start at zero', () {
      expect(state.strainsAdded, equals(0));
      expect(state.racksAdded, equals(0));
      expect(state.cagesAdded, equals(0));
      expect(state.animalsAdded, equals(0));
      expect(state.totalExpectedCages, equals(0));
      expect(state.activeStep, equals(0));
    });

    test('undo stack is empty', () {
      expect(state.undoStack, isEmpty);
      expect(state.lastUndoAction, isNull);
    });

    test('progress percentage is 0', () {
      expect(state.progressPercentage, equals(0));
    });

    test('completion percentage is 0 when totalExpectedCages is 0', () {
      expect(state.completionPercentage, equals(0));
    });
  });

  group('Step navigation', () {
    test('nextStep increments activeStep', () {
      state.nextStep();
      expect(state.activeStep, equals(1));
    });

    test('nextStep does not exceed 4', () {
      for (var i = 0; i < 10; i++) {
        state.nextStep();
      }
      expect(state.activeStep, equals(4));
    });

    test('previousStep decrements activeStep', () {
      state.nextStep();
      state.nextStep();
      state.previousStep();
      expect(state.activeStep, equals(1));
    });

    test('previousStep does not go below 0', () {
      state.previousStep();
      expect(state.activeStep, equals(0));
    });

    test('goToStep sets step clamped to 0-4', () {
      state.goToStep(3);
      expect(state.activeStep, equals(3));

      state.goToStep(-1);
      expect(state.activeStep, equals(0));

      state.goToStep(99);
      expect(state.activeStep, equals(4));
    });

    test('setActiveStep clamps to 0-4', () {
      state.setActiveStep(2);
      expect(state.activeStep, equals(2));

      state.setActiveStep(-5);
      expect(state.activeStep, equals(0));

      state.setActiveStep(10);
      expect(state.activeStep, equals(4));
    });
  });

  group('Progress percentage', () {
    test('calculates based on active step / 4', () {
      state.goToStep(0);
      expect(state.progressPercentage, equals(0));

      state.goToStep(1);
      expect(state.progressPercentage, equals(25));

      state.goToStep(2);
      expect(state.progressPercentage, equals(50));

      state.goToStep(3);
      expect(state.progressPercentage, equals(75));

      state.goToStep(4);
      expect(state.progressPercentage, equals(100));
    });
  });

  group('Completion percentage', () {
    test('returns 0 when totalExpectedCages is 0', () {
      state.incrementCagesAdded(5);
      expect(state.completionPercentage, equals(0));
    });

    test('calculates percentage correctly', () {
      state.setTotalExpectedCages(10);
      state.incrementCagesAdded(5);
      expect(state.completionPercentage, equals(50));
    });

    test('clamps to 100', () {
      state.setTotalExpectedCages(2);
      state.incrementCagesAdded(5);
      expect(state.completionPercentage, equals(100));
    });
  });

  group('Increment counters', () {
    test('incrementStrainsAdded defaults to 1', () {
      state.incrementStrainsAdded();
      expect(state.strainsAdded, equals(1));
    });

    test('incrementStrainsAdded with count', () {
      state.incrementStrainsAdded(3);
      expect(state.strainsAdded, equals(3));
    });

    test('incrementRacksAdded', () {
      state.incrementRacksAdded(2);
      expect(state.racksAdded, equals(2));
    });

    test('incrementCagesAdded', () {
      state.incrementCagesAdded(4);
      expect(state.cagesAdded, equals(4));
    });

    test('incrementAnimalsAdded', () {
      state.incrementAnimalsAdded(10);
      expect(state.animalsAdded, equals(10));
    });
  });

  group('Decrement counters', () {
    test('decrementStrainsAdded does not go below 0', () {
      state.incrementStrainsAdded(2);
      state.decrementStrainsAdded(5);
      expect(state.strainsAdded, equals(0));
    });

    test('decrementRacksAdded does not go below 0', () {
      state.decrementRacksAdded();
      expect(state.racksAdded, equals(0));
    });

    test('decrementCagesAdded', () {
      state.incrementCagesAdded(3);
      state.decrementCagesAdded(2);
      expect(state.cagesAdded, equals(1));
    });

    test('decrementAnimalsAdded', () {
      state.incrementAnimalsAdded(5);
      state.decrementAnimalsAdded(3);
      expect(state.animalsAdded, equals(2));
    });
  });

  group('Undo system', () {
    test('pushUndoAction adds to stack', () {
      state.pushUndoAction(UndoAction(
        type: UndoActionType.addStrain,
        description: 'Added strain',
        undo: () async {},
      ));
      expect(state.undoStack.length, equals(1));
      expect(state.lastUndoAction, isNotNull);
      expect(state.lastUndoAction!.type, equals(UndoActionType.addStrain));
    });

    test('pushUndoAction trims stack beyond maxUndoStackSize', () {
      for (var i = 0; i < ColonyWizardConstants.maxUndoStackSize + 5; i++) {
        state.pushUndoAction(UndoAction(
          type: UndoActionType.addStrain,
          description: 'Action $i',
          undo: () async {},
        ));
      }
      expect(
        state.undoStack.length,
        equals(ColonyWizardConstants.maxUndoStackSize),
      );
    });

    test('executeUndo pops last action and calls undo', () async {
      var undoCalled = false;
      state.pushUndoAction(UndoAction(
        type: UndoActionType.addRack,
        description: 'Added rack',
        undo: () async {
          undoCalled = true;
        },
      ));
      await state.executeUndo();
      expect(undoCalled, isTrue);
      expect(state.undoStack, isEmpty);
    });

    test('executeUndo on empty stack does nothing', () async {
      await state.executeUndo(); // should not throw
      expect(state.undoStack, isEmpty);
    });

    test('clearUndoStack empties the stack', () {
      state.pushUndoAction(UndoAction(
        type: UndoActionType.addCage,
        description: 'Added cage',
        undo: () async {},
      ));
      state.clearUndoStack();
      expect(state.undoStack, isEmpty);
      expect(state.lastUndoAction, isNull);
    });
  });

  group('UndoAction', () {
    test('timestamp defaults to now', () {
      final before = DateTime.now();
      final action = UndoAction(
        type: UndoActionType.addAnimals,
        description: 'Added animals',
        undo: () async {},
      );
      final after = DateTime.now();
      expect(action.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(action.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('timestamp can be explicitly set', () {
      final ts = DateTime(2024, 1, 1);
      final action = UndoAction(
        type: UndoActionType.deleteStrain,
        description: 'Deleted strain',
        undo: () async {},
        timestamp: ts,
      );
      expect(action.timestamp, equals(ts));
    });
  });

  group('Notifies listeners', () {
    test('nextStep notifies listeners', () {
      var notified = false;
      state.addListener(() => notified = true);
      state.nextStep();
      expect(notified, isTrue);
    });

    test('previousStep does not notify when already at 0', () {
      var notified = false;
      state.addListener(() => notified = true);
      state.previousStep();
      expect(notified, isFalse);
    });

    test('incrementStrainsAdded notifies listeners', () {
      var notified = false;
      state.addListener(() => notified = true);
      state.incrementStrainsAdded();
      expect(notified, isTrue);
    });

    test('reset notifies listeners', () {
      var notified = false;
      state.goToStep(3);
      state.addListener(() => notified = true);
      state.reset();
      expect(notified, isTrue);
    });
  });

  group('Reset', () {
    test('reset clears all state', () {
      state.incrementStrainsAdded(5);
      state.incrementRacksAdded(3);
      state.incrementCagesAdded(10);
      state.incrementAnimalsAdded(20);
      state.setTotalExpectedCages(15);
      state.goToStep(3);
      state.pushUndoAction(UndoAction(
        type: UndoActionType.addStrain,
        description: 'test',
        undo: () async {},
      ));

      state.reset();

      expect(state.strainsAdded, equals(0));
      expect(state.racksAdded, equals(0));
      expect(state.cagesAdded, equals(0));
      expect(state.animalsAdded, equals(0));
      expect(state.totalExpectedCages, equals(0));
      expect(state.activeStep, equals(0));
      expect(state.undoStack, isEmpty);
    });
  });

  group('UndoActionType constants', () {
    test('all constants are defined', () {
      expect(UndoActionType.addStrain, equals('ADD_STRAIN'));
      expect(UndoActionType.deleteStrain, equals('DELETE_STRAIN'));
      expect(UndoActionType.addGene, equals('ADD_GENE'));
      expect(UndoActionType.deleteGene, equals('DELETE_GENE'));
      expect(UndoActionType.addAllele, equals('ADD_ALLELE'));
      expect(UndoActionType.deleteAllele, equals('DELETE_ALLELE'));
      expect(UndoActionType.addRack, equals('ADD_RACK'));
      expect(UndoActionType.editRack, equals('EDIT_RACK'));
      expect(UndoActionType.deleteRack, equals('DELETE_RACK'));
      expect(UndoActionType.addCage, equals('ADD_CAGE'));
      expect(UndoActionType.editCage, equals('EDIT_CAGE'));
      expect(UndoActionType.addAnimals, equals('ADD_ANIMALS'));
    });
  });
}
