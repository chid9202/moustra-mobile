import 'package:flutter/material.dart';

class AddCageButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCageButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey, width: 2.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Icon(Icons.add, size: 48, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}
