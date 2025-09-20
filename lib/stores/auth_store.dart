import 'package:flutter/material.dart';
import 'package:moustra/services/auth_service.dart';

final ValueNotifier<bool> authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);
