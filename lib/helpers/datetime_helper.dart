import 'package:intl/intl.dart';

class DateTimeHelper {
  static String parseIsoToDateTime(String? iso) {
    if (iso == null) return "";
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }

  static String parseIsoToDate(String? iso) {
    if (iso == null) return "";
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y').format(dt);
  }

  static String formatDate(DateTime? datetime) {
    if (datetime == null) return '';
    final dt = datetime.toLocal();
    return DateFormat('M/d/y').format(dt);
  }

  static String formatDateTime(DateTime? datetime) {
    if (datetime == null) return '';
    final dt = datetime.toLocal();
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }
}
