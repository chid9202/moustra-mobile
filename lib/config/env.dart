class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://core-staging-dot-upphish.uc.r.appspot.com/api/v1', // TODO: Move this to env
  );

  static const String auth0Domain = String.fromEnvironment(
    'AUTH0_DOMAIN',
    defaultValue: 'login-dev.moustra.com',
  );

  static const String auth0ClientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: 'q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K',
  );

  static const String auth0Scheme = String.fromEnvironment(
    'AUTH0_SCHEME',
    defaultValue: 'com.moustra.app',
  );

  static const String auth0Audience = String.fromEnvironment(
    'AUTH0_AUDIENCE',
    defaultValue: 'https://api.moustra.com',
  );

  static const String auth0Connection = String.fromEnvironment(
    'AUTH0_CONNECTION',
    defaultValue: 'Moustra-Dev',
  );
}
