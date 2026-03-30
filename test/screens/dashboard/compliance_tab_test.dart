import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/compliance_tab.dart';
import 'package:moustra/screens/protocol_compliance_screen.dart';

void main() {
  group('ComplianceTab', () {
    testWidgets('embeds ProtocolComplianceScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComplianceTab(),
          ),
        ),
      );
      expect(find.byType(ComplianceTab), findsOneWidget);
      expect(find.byType(ProtocolComplianceScreen), findsOneWidget);
    });
  });
}
