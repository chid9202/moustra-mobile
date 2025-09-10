import 'package:auth0_flutter/auth0_flutter.dart';

// Auth0 configuration sourced from compile-time environment variables.
// Provide values with --dart-define when running/building the app.
// Example:
// flutter run \
//   --dart-define=AUTH0_DOMAIN=login-dev.moustra.com \
//   --dart-define=AUTH0_CLIENT_ID=YOUR_DEV_CLIENT_ID

const String auth0Domain = String.fromEnvironment(
  'AUTH0_DOMAIN',
  defaultValue: 'login-dev.moustra.com',
);

const String auth0ClientId = String.fromEnvironment(
  'AUTH0_CLIENT_ID',
  defaultValue: 'q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K',
);

final Auth0 auth0 = Auth0(auth0Domain, auth0ClientId);


