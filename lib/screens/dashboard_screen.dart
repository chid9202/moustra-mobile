import 'package:flutter/material.dart';

import 'package:grid_view/screens/dashboard/animals_to_wean.dart';
import 'package:grid_view/screens/dashboard/data_by_account.dart';
import 'package:grid_view/screens/dashboard/mice_by_sex.dart';
import 'package:grid_view/screens/dashboard/mice_count_by_age.dart';
import 'package:grid_view/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = dashboardService.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load dashboard: ${snapshot.error}'),
          );
        }
        final data = snapshot.data ?? <String, dynamic>{};
        final Map<String, dynamic> accounts =
            (data['accounts'] as Map<String, dynamic>? ?? <String, dynamic>{});
        final List<dynamic> animalsSexRatio =
            (data['animalsSexRatio'] as List<dynamic>? ?? <dynamic>[]);
        final List<dynamic> animalsToWean =
            (data['animalsToWean'] as List<dynamic>? ?? <dynamic>[]);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: MouseCountByAge(data),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimalsToWean(animalsToWean),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DataByAccount(accounts),
                ),
              ),

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: MiceBySex(animalsSexRatio),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
