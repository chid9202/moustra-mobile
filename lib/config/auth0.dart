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

final Auth0 auth0 = Auth0(
  "login-dev.moustra.com",
  "q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K",
);

// Custom redirect scheme used by native (Android/iOS) login flows
// Provide with: --dart-define=AUTH0_SCHEME=moustra
const String auth0Scheme = String.fromEnvironment(
  'AUTH0_SCHEME',
  defaultValue: 'moustra',
);

// Where Auth0 should return after logout (must be in Allowed Logout URLs)
final String auth0LogoutReturnTo = '$auth0Scheme://$auth0Domain/logout';

// Optional API audience for issuing access tokens to your backend.
// Provide with: --dart-define=AUTH0_AUDIENCE=https://api.moustra.com
const String auth0Audience = String.fromEnvironment(
  'AUTH0_AUDIENCE',
  defaultValue: 'https://api.moustra.com',
);

// Space-separated scopes. Include offline_access to get refresh tokens (native only).
// Provide with: --dart-define=AUTH0_SCOPE="openid profile email offline_access"
const String auth0Scope = String.fromEnvironment(
  'AUTH0_SCOPE',
  defaultValue: 'openid profile email offline_access',
);

// Optional connection to force (e.g., Moustra-Dev). Leave empty to let Auth0 pick.
// Provide with: --dart-define=AUTH0_CONNECTION=Moustra-Dev
const String auth0Connection = String.fromEnvironment(
  'AUTH0_CONNECTION',
  defaultValue: 'Moustra-Dev',
);
