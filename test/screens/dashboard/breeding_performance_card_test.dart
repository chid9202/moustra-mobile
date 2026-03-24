import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/breeding_performance_card.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

void main() {
  group('BreedingPerformanceCard', () {
    final mockData = BreedingPerformanceDto(
      averageLitterSize: 7.2,
      matingSuccessRate: 85.0,
      medianTimeToFirstLitter: 28.0,
      pupSurvivalRate: 92.3,
      activeBreedingPairs: 12,
      littersPerMonth: [
        LittersPerMonthDto(month: '2025-10', count: 2),
        LittersPerMonthDto(month: '2025-11', count: 5),
        LittersPerMonthDto(month: '2025-12', count: 3),
        LittersPerMonthDto(month: '2026-01', count: 4),
        LittersPerMonthDto(month: '2026-02', count: 6),
        LittersPerMonthDto(month: '2026-03', count: 1),
      ],
    );

    testWidgets('renders with data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BreedingPerformanceCard(breedingPerformance: mockData),
            ),
          ),
        ),
      );

      expect(find.text('Breeding Performance'), findsOneWidget);
      expect(find.text('7.2'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('28d'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('Avg Litter Size'), findsOneWidget);
      expect(find.text('Mating Success'), findsOneWidget);
      expect(find.text('Time to Litter'), findsOneWidget);
      expect(find.text('Pup Survival'), findsOneWidget);
    });

    testWidgets('renders empty state when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BreedingPerformanceCard(breedingPerformance: null),
            ),
          ),
        ),
      );

      expect(find.text('Breeding Performance'), findsOneWidget);
      expect(find.text('No breeding data yet'), findsOneWidget);
    });

    testWidgets('renders empty state when all metrics null', (tester) async {
      final emptyData = BreedingPerformanceDto(
        averageLitterSize: null,
        matingSuccessRate: null,
        medianTimeToFirstLitter: null,
        pupSurvivalRate: null,
        activeBreedingPairs: 0,
        littersPerMonth: [
          LittersPerMonthDto(month: '2025-10', count: 0),
          LittersPerMonthDto(month: '2025-11', count: 0),
          LittersPerMonthDto(month: '2025-12', count: 0),
          LittersPerMonthDto(month: '2026-01', count: 0),
          LittersPerMonthDto(month: '2026-02', count: 0),
          LittersPerMonthDto(month: '2026-03', count: 0),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BreedingPerformanceCard(breedingPerformance: emptyData),
            ),
          ),
        ),
      );

      expect(find.text('Breeding Performance'), findsOneWidget);
      expect(find.text('No breeding data yet'), findsOneWidget);
    });
  });
}
