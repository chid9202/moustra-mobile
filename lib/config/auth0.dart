import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:moustra/config/env.dart';

final Auth0 auth0 = Auth0("login-dev.moustra.com", Env.auth0ClientId);
