import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
  Duration? duration,
}) {
  debugPrint(
      '[SnackBar${isError ? " ERROR" : isSuccess ? " SUCCESS" : ""}] $message');

  Color? backgroundColor;
  if (isError) backgroundColor = Colors.red;
  if (isSuccess) backgroundColor = Colors.green;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
    ),
  );
}
