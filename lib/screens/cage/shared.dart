import 'package:flutter/material.dart';

class CageListItem extends StatelessWidget {
  const CageListItem({
    required this.label,
    required this.content,
    this.fontSize = 18,
    super.key,
  });
  final String label;
  final String content;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Text(content),
      ],
    );
  }
}
