import 'package:flutter/material.dart';
import 'package:moustra/constants/account_constants.dart';
import 'package:moustra/screens/settings/lab_settings_tab.dart';
import 'package:moustra/screens/settings/subscription_tab.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileResponseDto?>(
      valueListenable: profileState,
      builder: (context, profile, _) {
        final isAdmin = profile?.role == AccountRole.admin.value;
        final tabCount = isAdmin ? 2 : 1;

        return DefaultTabController(
          length: tabCount,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  const Tab(text: 'Lab'),
                  if (isAdmin) const Tab(text: 'Subscription'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Lab tab content
                    const LabSettingsTab(),
                    // Subscription tab content - only shown for admins
                    if (isAdmin) SubscriptionTab(profile: profile),
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
