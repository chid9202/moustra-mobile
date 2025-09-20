import 'package:flutter/material.dart';
import 'package:moustra/app/mui_color.dart';

final ThemeData appTheme = lightTheme.copyWith(
  scaffoldBackgroundColor: lightColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.surface,
    foregroundColor: lightColorScheme.onSurface,
    elevation: 0,
  ),
);
