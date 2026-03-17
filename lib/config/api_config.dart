import 'package:grid_view/config/env.dart';

class ApiConfig {
  static String? accountUuid;

  static String get accountBaseUrl =>
      '${Env.apiBaseUrl}/account/$accountUuid';

  static String get authCallbackUrl => '${Env.apiBaseUrl}/auth/callback';

  static const String animals = '/animals';
  static const String strains = '/strain';
  static const String cages = '/cages';
  static const String litters = '/litters';
}
