import 'package:moustra/services/dtos/strain_dto.dart';

class StrainHelper {
  static String getBackgroundNames(List<StrainBackgroundDto>? backgrounds) {
    final List<dynamic> bgs = (backgrounds ?? []);
    if (bgs.isEmpty) return '';
    final List<String> names = bgs
        .map((e) => (e.name ?? '').toString())
        .toList();
    return names.join(', ');
  }
}
