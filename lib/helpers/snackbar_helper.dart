import 'package:flutter/material.dart';
import 'package:moustra/app/mui_color.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
  Duration? duration,
}) {
  debugPrint(
      '[SnackBar${isError ? " ERROR" : isSuccess ? " SUCCESS" : ""}] $message');

  final mui = Theme.of(context).extension<MUIExtraColors>();
  Color? backgroundColor;
  if (isError) backgroundColor = Theme.of(context).colorScheme.error;
  if (isSuccess) backgroundColor = mui?.success;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
    ),
  );
}
