import 'package:moustra/constants/list_constants/common.dart';

class ListHelper {
  static String? getListColumnByField<T extends ListColumn>(
    Iterable<T> values,
    String field,
  ) {
    for (final e in values) {
      if (e.field == field) return e.enumName;
    }
    return null;
  }
}
