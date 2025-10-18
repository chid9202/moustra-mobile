import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl => dotenv.get(
    'API_BASE_URL',
    fallback: 'https://core-staging-dot-upphish.uc.r.appspot.com/api/v1',
  );

  static String get auth0Domain =>
      dotenv.get('AUTH0_DOMAIN', fallback: 'login-dev.moustra.com');

  static String get auth0ClientId => dotenv.get(
    'AUTH0_CLIENT_ID',
    fallback: 'q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K',
  );

  static String get auth0Scheme =>
      dotenv.get('AUTH0_SCHEME', fallback: 'com.moustra.app');

  static String get auth0Audience =>
      dotenv.get('AUTH0_AUDIENCE', fallback: 'https://api.moustra.com');

  static String get auth0Connection =>
      dotenv.get('AUTH0_CONNECTION', fallback: 'Moustra-Dev');
}
