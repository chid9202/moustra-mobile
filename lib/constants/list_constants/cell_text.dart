import 'package:flutter/material.dart';
import 'package:moustra/widgets/safe_text.dart';

Padding cellText(String? value, {Alignment? textAlign}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Align(
      alignment: textAlign ?? Alignment.centerLeft,
      child: SafeText(value),
    ),
  );
}

Padding cellTextList(List<String> value, {Alignment? textAlign}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Align(
      alignment: textAlign ?? Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: value.map((v) => SafeText(v)).toList(),
      ),
    ),
  );
}
