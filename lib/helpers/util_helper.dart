import 'dart:math' as math;
import 'package:flutter/material.dart';

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

  /// Extracts the scale (zoom level) from a Matrix4 transformation matrix.
  ///
  /// Calculates scale using the length of the basis vectors (X and Y axis scales).
  /// For InteractiveViewer, which uses uniform scaling without rotation,
  /// this extracts the scale from the diagonal entries and basis vector lengths.
  ///
  /// This method works correctly even when the matrix includes translation,
  /// as translation doesn't affect the scale values in the matrix.
  ///
  /// Returns the scale factor (1.0 = no zoom, >1.0 = zoomed in, <1.0 = zoomed out).
  static double getScaleFromMatrix(Matrix4 matrix) {
    // For a 2D transformation matrix, extract scale from the basis vectors
    // X-axis scale: length of column 0 (X-axis basis vector)
    final xAxisX = matrix.entry(0, 0);
    final xAxisY = matrix.entry(1, 0);
    final xScale = math.sqrt(xAxisX * xAxisX + xAxisY * xAxisY);

    // Y-axis scale: length of column 1 (Y-axis basis vector)
    final yAxisX = matrix.entry(0, 1);
    final yAxisY = matrix.entry(1, 1);
    final yScale = math.sqrt(yAxisX * yAxisX + yAxisY * yAxisY);

    // Return average of X and Y scales for overall scale
    // Since InteractiveViewer typically uses uniform scaling, they should be equal,
    // but averaging handles any minor discrepancies
    return (xScale + yScale) / 2.0;
  }
}
