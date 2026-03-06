import 'package:flutter/material.dart';
import 'package:moustra/screens/protocol_compliance_screen.dart';

/// Compliance tab for the dashboard - reuses the existing ProtocolComplianceScreen.
class ComplianceTab extends StatelessWidget {
  const ComplianceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProtocolComplianceScreen();
  }
}
