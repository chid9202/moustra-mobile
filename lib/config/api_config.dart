import 'package:moustra/config/env.dart';

class ApiConfig {
  static const String baseUrl = Env.apiBaseUrl;

  static const String animals = '/animals';
  static const String strains = '/strain';
  static const String cages = '/cages';
  static const String litters = '/litters';
}
