import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/recent_activity_card.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

void main() {
  group('RecentActivityCard', () {
    testWidgets('renders list of activities', (tester) async {
      final activities = [
        RecentActivityDto(
          type: 'litter_born',
          date: '2026-03-24',
          description: 'New litter born (5 pups)',
          detail: 'C57BL/6',
          linkUuid: 'litter-uuid-1',
        ),
        RecentActivityDto(
          type: 'animals_weaned',
          date: '2026-03-23',
          description: '3 animal(s) weaned',
          detail: 'BALB/c',
        ),
        RecentActivityDto(
          type: 'mating_setup',
          date: '2026-03-22',
          description: 'Mating set up: Pair A',
          detail: 'C57BL/6',
          linkUuid: 'mating-uuid-1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(activities: activities),
            ),
          ),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('New litter born (5 pups)'), findsOneWidget);
      expect(find.text('3 animal(s) weaned'), findsOneWidget);
      expect(find.text('Mating set up: Pair A'), findsOneWidget);
      expect(find.text('C57BL/6'), findsWidgets);
      expect(find.text('BALB/c'), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(activities: const []),
            ),
          ),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('No recent activity'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('renders correct icons per activity type', (tester) async {
      final activities = [
        RecentActivityDto(
          type: 'litter_born',
          date: '2026-03-24',
          description: 'Litter born',
        ),
        RecentActivityDto(
          type: 'animals_weaned',
          date: '2026-03-24',
          description: 'Animals weaned',
        ),
        RecentActivityDto(
          type: 'mating_setup',
          date: '2026-03-24',
          description: 'Mating setup',
        ),
        RecentActivityDto(
          type: 'mating_disbanded',
          date: '2026-03-24',
          description: 'Mating disbanded',
        ),
        RecentActivityDto(
          type: 'animals_ended',
          date: '2026-03-24',
          description: 'Animals ended',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(activities: activities),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.child_care), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.heart_broken), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });
  });
}
