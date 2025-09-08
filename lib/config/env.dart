class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://localhost:8000/api/v1/account/fa15446d-f8ca-4d25-8400-14bb18b71fc8',
  );

  static const String auth0Domain = String.fromEnvironment(
    'AUTH0_DOMAIN',
    defaultValue: 'login-dev.moustra.com',
  );

  static const String auth0ClientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: 'q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K',
  );
}
