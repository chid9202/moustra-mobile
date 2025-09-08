class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://localhost:8000/api/v1/account/fa15446d-f8ca-4d25-8400-14bb18b71fc8',
  );

  static const String animals = '/animals';
  static const String strains = '/strain';
  static const String cages = '/cages';
  static const String litters = '/litters';
}
