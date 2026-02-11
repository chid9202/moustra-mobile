/// Constants for the Colony Wizard feature
class ColonyWizardConstants {
  // Timing
  static const int defaultWeanDays = 21;

  // Capacity
  static const int maxMicePerCage = 5;
  static const int recommendedMicePerCage = 4;

  // Rack templates
  static const Map<String, Map<String, int>> rackTemplates = {
    'small': {'width': 6, 'height': 4},
    'medium': {'width': 8, 'height': 6},
    'large': {'width': 10, 'height': 8},
    'extraLarge': {'width': 12, 'height': 10},
  };

  // Custom rack limits
  static const int minRackDimension = 1;
  static const int maxRackDimension = 20;

  // Sex values
  static const String sexMale = 'M';
  static const String sexFemale = 'F';
  static const String sexUnknown = 'U';

  // Step indices
  static const int stepWelcome = 0;
  static const int stepStrainsGenotypes = 1;
  static const int stepRacks = 2;
  static const int stepCagesAnimals = 3;
  static const int stepReview = 4;

  // Step labels
  static const List<String> stepLabels = [
    'Welcome',
    'Strains & Genes',
    'Racks',
    'Cages & Animals',
    'Review',
  ];

  // Common strains for suggestions
  static const List<String> commonStrains = [
    'C57BL/6J',
    'C57BL/6N',
    'BALB/c',
    '129S1/SvImJ',
    'FVB/NJ',
    'DBA/2J',
    'CD-1',
    'Swiss Webster',
    'NOD/ShiLtJ',
    'A/J',
  ];

  // Animation durations
  static const Duration stepTransitionDuration = Duration(milliseconds: 250);

  // Undo stack max size
  static const int maxUndoStackSize = 10;

  // Grid cell size
  static const double gridCellSize = 60.0;
  static const double gridCellGap = 4.0;

  // Snackbar duration
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration undoSnackbarDuration = Duration(seconds: 5);
}
