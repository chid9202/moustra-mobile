import 'package:moustra/services/dtos/animal_dto.dart';

class AnimalHelper {
  static String getAge(AnimalDto animal) {
    final dob = DateTime.tryParse(animal.dateOfBirth?.toString() ?? '');
    if (dob == null) return '';
    final now = DateTime.now();
    int totalDays = now.difference(dob).inDays;
    if (totalDays < 0) totalDays = 0;
    final int weeks = totalDays ~/ 7;
    final int days = totalDays % 7;
    if (weeks == 0) return '${days}d';
    if (days == 0) return '${weeks}w';
    return '${weeks}w${days}d';
  }
}
