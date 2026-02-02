import 'package:flutter/material.dart';

class EmptyCageSlot extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyCageSlot({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      color: Colors.grey.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Center(
          child: Icon(
            Icons.add,
            size: 32,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
