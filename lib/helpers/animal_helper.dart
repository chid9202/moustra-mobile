import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:intl/intl.dart';

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

  static String getAnimalOptionLabel(AnimalStoreDto animal) {
    final w1 = animal.physicalTag ?? 'N/A';
    final w2 = animal.sex ?? 'N/A';
    final w3 = animal.dateOfBirth != null
        ? DateFormat('MM/dd/yyyy').format(animal.dateOfBirth!)
        : 'N/A';
    return '$w1 / $w2 / $w3';
  }

  static bool isMature(AnimalStoreDto animal) {
    if (animal.weanDate != null) {
      return animal.weanDate!.isBefore(DateTime.now());
    }
    if (animal.dateOfBirth != null) {
      return animal.dateOfBirth!
          .add(const Duration(days: 21))
          .isBefore(DateTime.now());
    }
    return false;
  }
}
