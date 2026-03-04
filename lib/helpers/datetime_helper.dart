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

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('M/d/y').format(dateTime.toLocal());
  }
}
