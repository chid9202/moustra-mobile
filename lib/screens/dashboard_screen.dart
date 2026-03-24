import 'package:flutter/material.dart';

import 'package:moustra/screens/dashboard/active_pregnancies_card.dart';
import 'package:moustra/screens/dashboard/recent_activity_card.dart';
import 'package:moustra/screens/dashboard/breeding_performance_card.dart';
import 'package:moustra/screens/dashboard/animals_to_wean.dart';
import 'package:moustra/screens/dashboard/cage_utilization_card.dart';
import 'package:moustra/screens/dashboard/compliance_tab.dart';
import 'package:moustra/screens/dashboard/data_by_account.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';
import 'package:moustra/screens/dashboard/mice_by_sex.dart';
import 'package:moustra/screens/dashboard/mice_count_by_age.dart';
import 'package:moustra/screens/dashboard/reports_tab.dart';
import 'package:moustra/services/clients/dashboard_api.dart';
import 'package:moustra/services/clients/event_api.dart';

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
    eventApi.trackEvent('view_dashboard');
    _future = dashboardService.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Semantics(label: 'Overview Tab', child: const Tab(text: 'Overview')),
              Semantics(label: 'Compliance Tab', child: const Tab(text: 'Compliance')),
              Semantics(label: 'Reports Tab', child: const Tab(text: 'Reports')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(),
                const ComplianceTab(),
                const ReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColonySummaryCard({
    required IconData icon,
    required String label,
    required int value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColonySummaryStrip(ColonySummaryDto summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: [
        _buildColonySummaryCard(
          icon: Icons.pets,
          label: 'Total Animals',
          value: summary.totalAnimals,
          bgColor: Colors.blue.shade50,
          textColor: Colors.blue.shade700,
        ),
        _buildColonySummaryCard(
          icon: Icons.grid_view,
          label: 'Active Cages',
          value: summary.activeCages,
          bgColor: Colors.orange.shade50,
          textColor: Colors.orange.shade700,
        ),
        _buildColonySummaryCard(
          icon: Icons.favorite,
          label: 'Active Matings',
          value: summary.activeMatings,
          bgColor: Colors.green.shade50,
          textColor: Colors.green.shade700,
        ),
        _buildColonySummaryCard(
          icon: Icons.child_care,
          label: 'Active Litters',
          value: summary.totalLitters,
          bgColor: Colors.purple.shade50,
          textColor: Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildViolationBanner(int violationCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            '$violationCount cage(s) in violation',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Moustra Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first animals and cages to start seeing colony analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
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
        final Map<String, dynamic>? cageUtilization =
            data['cageUtilization'] as Map<String, dynamic>?;
        final colonySummaryJson =
            data['colonySummary'] as Map<String, dynamic>?;
        final colonySummary = colonySummaryJson != null
            ? ColonySummaryDto.fromJson(colonySummaryJson)
            : null;

        // Empty state — no animals
        if (colonySummary == null || colonySummary.totalAnimals == 0) {
          return _buildEmptyState();
        }

        // Extract cage violation count from cageUtilization data
        final int cageViolationCount =
            (cageUtilization?['cagesInViolationCount'] as int?) ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Colony Summary strip
              _buildColonySummaryStrip(colonySummary),
              const SizedBox(height: 12),

              // 2. Alert banner (if violations)
              if (cageViolationCount > 0) ...[
                _buildViolationBanner(cageViolationCount),
                const SizedBox(height: 12),
              ],

              // 3. Mice Count By Age
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: MouseCountByAge(data),
                ),
              ),

              const SizedBox(height: 12),

              // 4. Animals To Wean
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimalsToWean(animalsToWean),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Breeding Performance
              Builder(
                builder: (context) {
                  final bpJson = data['breedingPerformance'] as Map<String, dynamic>?;
                  final bp = bpJson != null
                      ? BreedingPerformanceDto.fromJson(bpJson)
                      : null;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: BreedingPerformanceCard(breedingPerformance: bp),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 6. Cage Utilization (moved up, before Mice By Sex)
              if (cageUtilization != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CageUtilizationCard(cageUtilization),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 7. Mice By Sex
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: MiceBySex(animalsSexRatio),
                ),
              ),

              const SizedBox(height: 12),

              // 8. Active Pregnancies
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: ActivePregnanciesCard(),
                ),
              ),

              const SizedBox(height: 12),

              // 9. Recent Activity
              Builder(
                builder: (context) {
                  final raList = data['recentActivity'] as List<dynamic>? ?? [];
                  final activities = raList
                      .map((e) => RecentActivityDto.fromJson(e as Map<String, dynamic>))
                      .toList();
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: RecentActivityCard(activities: activities),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
