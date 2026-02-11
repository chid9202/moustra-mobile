import 'package:flutter/foundation.dart';
import '../colony_wizard_constants.dart';

/// Represents a single undo action in the wizard
class UndoAction {
  final String type;
  final DateTime timestamp;
  final String description;
  final Future<void> Function() undo;

  UndoAction({
    required this.type,
    required this.description,
    required this.undo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Types of undo actions
class UndoActionType {
  static const String addStrain = 'ADD_STRAIN';
  static const String deleteStrain = 'DELETE_STRAIN';
  static const String addGene = 'ADD_GENE';
  static const String deleteGene = 'DELETE_GENE';
  static const String addAllele = 'ADD_ALLELE';
  static const String deleteAllele = 'DELETE_ALLELE';
  static const String addRack = 'ADD_RACK';
  static const String editRack = 'EDIT_RACK';
  static const String deleteRack = 'DELETE_RACK';
  static const String addCage = 'ADD_CAGE';
  static const String editCage = 'EDIT_CAGE';
  static const String addAnimals = 'ADD_ANIMALS';
}

/// Global wizard state
class WizardState extends ChangeNotifier {
  int _strainsAdded = 0;
  int _racksAdded = 0;
  int _cagesAdded = 0;
  int _animalsAdded = 0;
  int _totalExpectedCages = 0;
  int _activeStep = 0;

  final List<UndoAction> _undoStack = [];

  // Getters
  int get strainsAdded => _strainsAdded;
  int get racksAdded => _racksAdded;
  int get cagesAdded => _cagesAdded;
  int get animalsAdded => _animalsAdded;
  int get totalExpectedCages => _totalExpectedCages;
  int get activeStep => _activeStep;
  List<UndoAction> get undoStack => List.unmodifiable(_undoStack);
  UndoAction? get lastUndoAction => _undoStack.isEmpty ? null : _undoStack.last;

  /// Progress percentage based on step index
  int get progressPercentage => ((_activeStep / 4) * 100).round();

  /// Completion percentage based on cages added vs expected
  int get completionPercentage {
    if (_totalExpectedCages <= 0) return 0;
    return ((_cagesAdded / _totalExpectedCages) * 100).round().clamp(0, 100);
  }

  // Setters
  void setActiveStep(int step) {
    _activeStep = step.clamp(0, 4);
    notifyListeners();
  }

  void setTotalExpectedCages(int count) {
    _totalExpectedCages = count;
    notifyListeners();
  }

  void incrementStrainsAdded([int count = 1]) {
    _strainsAdded += count;
    notifyListeners();
  }

  void incrementRacksAdded([int count = 1]) {
    _racksAdded += count;
    notifyListeners();
  }

  void incrementCagesAdded([int count = 1]) {
    _cagesAdded += count;
    notifyListeners();
  }

  void incrementAnimalsAdded([int count = 1]) {
    _animalsAdded += count;
    notifyListeners();
  }

  void decrementStrainsAdded([int count = 1]) {
    _strainsAdded = (_strainsAdded - count).clamp(0, _strainsAdded);
    notifyListeners();
  }

  void decrementRacksAdded([int count = 1]) {
    _racksAdded = (_racksAdded - count).clamp(0, _racksAdded);
    notifyListeners();
  }

  void decrementCagesAdded([int count = 1]) {
    _cagesAdded = (_cagesAdded - count).clamp(0, _cagesAdded);
    notifyListeners();
  }

  void decrementAnimalsAdded([int count = 1]) {
    _animalsAdded = (_animalsAdded - count).clamp(0, _animalsAdded);
    notifyListeners();
  }

  // Undo system
  void pushUndoAction(UndoAction action) {
    _undoStack.add(action);
    // Trim stack if too large
    while (_undoStack.length > ColonyWizardConstants.maxUndoStackSize) {
      _undoStack.removeAt(0);
    }
    notifyListeners();
  }

  Future<void> executeUndo() async {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    await action.undo();
    notifyListeners();
  }

  void clearUndoStack() {
    _undoStack.clear();
    notifyListeners();
  }

  // Navigation helpers
  void nextStep() {
    if (_activeStep < 4) {
      _activeStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_activeStep > 0) {
      _activeStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _activeStep = step.clamp(0, 4);
    notifyListeners();
  }

  // Reset state
  void reset() {
    _strainsAdded = 0;
    _racksAdded = 0;
    _cagesAdded = 0;
    _animalsAdded = 0;
    _totalExpectedCages = 0;
    _activeStep = 0;
    _undoStack.clear();
    notifyListeners();
  }
}

/// Global wizard state instance
final wizardState = WizardState();
