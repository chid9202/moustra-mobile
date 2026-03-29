import 'package:flutter/material.dart';
import 'package:moustra/widgets/safe_text.dart';

const String emptyCellPlaceholder = '\u2014';

bool _isEmptyValue(String? value) =>
    value == null || value.trim().isEmpty;

Widget _emptyCellWidget(BuildContext context) {
  return Text(
    emptyCellPlaceholder,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
    ),
  );
}

Widget cellText(String? value, {Alignment? textAlign}) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: textAlign ?? Alignment.centerLeft,
        child: _isEmptyValue(value)
            ? _emptyCellWidget(context)
            : SafeText(value),
      ),
    );
  });
}

Widget cellTextList(List<String> value, {Alignment? textAlign}) {
  return Builder(builder: (context) {
    final nonEmpty = value.where((v) => v.trim().isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: textAlign ?? Alignment.centerLeft,
        child: nonEmpty.isEmpty
            ? _emptyCellWidget(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: nonEmpty.map((v) => SafeText(v)).toList(),
              ),
      ),
    );
  });
}
