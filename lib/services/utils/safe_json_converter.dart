import 'package:moustra/services/error_report_service.dart';

/// Safely converts JSON to a DTO with detailed error reporting.
///
/// On failure, identifies problematic fields and reports the error
/// via ErrorReportService before re-throwing with enriched context.
T safeFromJson<T>({
  required Map<String, dynamic> json,
  required T Function(Map<String, dynamic>) fromJson,
  required String dtoName,
}) {
  try {
    return fromJson(json);
  } catch (e, stackTrace) {
    // Identify problematic fields by listing null/empty values
    final problematicFields = <String>[];
    for (final key in json.keys) {
      final value = json[key];
      if (value == null) {
        problematicFields.add('$key: null');
      } else if (value is Map && value.isEmpty) {
        problematicFields.add('$key: empty map');
      }
    }

    // Build error report
    final buffer = StringBuffer();
    buffer.writeln('Failed to parse $dtoName');
    buffer.writeln('Error: $e');
    buffer.writeln('Null/Empty fields: ${problematicFields.join(", ")}');
    buffer.writeln('JSON keys: ${json.keys.toList()}');
    buffer.writeln('Raw JSON: $json');
    buffer.writeln('Stack trace: $stackTrace');

    // Report error to backend
    ErrorReportService.reportError(
      subject: 'JSON Parse Error: $dtoName',
      message: buffer.toString(),
    );

    // Re-throw with enriched message for local debugging
    throw FormatException(
      'Failed to parse $dtoName. Null fields: $problematicFields. Original: $e',
    );
  }
}
