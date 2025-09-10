import 'package:flutter/material.dart';
import 'package:grid_view/app/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}

// Auth state handled in app/router.dart
