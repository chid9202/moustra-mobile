class UtilHelper {
  /// Gets the display lab name by ensuring it ends with "Lab" (case insensitive)
  /// If the last word is not "lab", it adds "Lab" to the end
  static String getDisplayLabName(String labName) {
    if (labName.trim().isEmpty) {
      return 'Lab';
    }

    final trimmedName = labName.trim();
    final words = trimmedName.split(' ');

    if (words.isEmpty) {
      return 'Lab';
    }

    final lastWord = words.last.toLowerCase();

    // Check if the last word is "lab" (case insensitive)
    if (lastWord == 'lab') {
      return trimmedName;
    } else {
      // Add "Lab" to the end
      return '$trimmedName Lab';
    }
  }
}
