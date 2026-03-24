import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// TODO: Subscription tab temporarily disabled
// import 'package:moustra/constants/account_constants.dart';
import 'package:moustra/screens/settings/account_settings_tab.dart';
import 'package:moustra/screens/settings/lab_settings_tab.dart';
import 'package:moustra/screens/settings/cage_card_tab.dart';
import 'package:moustra/screens/settings/debug_tab.dart';
import 'package:moustra/screens/protocols_screen.dart';
import 'package:moustra/screens/feedback_screen.dart';
// import 'package:moustra/screens/settings/subscription_tab.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/services/clients/event_api.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    eventApi.trackEvent('view_settings');
    return ValueListenableBuilder<ProfileResponseDto?>(
      valueListenable: profileState,
      builder: (context, profile, _) {
        // Show Debug tab only in debug mode
        final showDebug = kDebugMode;
        final tabCount = showDebug ? 6 : 5;

        return DefaultTabController(
          length: tabCount,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Lab'),
                  const Tab(text: 'Account'),
                  const Tab(text: 'Cage Cards'),
                  const Tab(text: 'Protocols'),
                  const Tab(text: 'Feedback'),
                  if (showDebug) const Tab(text: 'Debug'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const LabSettingsTab(),
                    const AccountSettingsTab(),
                    const CageCardTab(),
                    const ProtocolsScreen(),
                    const FeedbackScreen(),
                    if (showDebug) const DebugTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
