import 'package:flutter/material.dart';
import 'package:moustra/constants/account_constants.dart';
import 'package:moustra/services/clients/subscription_api.dart';
import 'package:moustra/services/clients/profile_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/services/dtos/subscription_dto.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/screens/settings/subscription_plans_screen.dart';
import 'package:moustra/screens/settings/subscription_details_screen.dart';

class SubscriptionTab extends StatefulWidget {
  final ProfileResponseDto? profile;

  const SubscriptionTab({super.key, this.profile});

  @override
  State<SubscriptionTab> createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends State<SubscriptionTab> {
  SubscriptionResponseDto? _subscription;
  bool _isLoadingSubscription = true;

  @override
  void initState() {
    super.initState();
    // Don't call getSubscription to check if subscription exists
    // We use profile.plan to decide what to show
    // Only load subscription details when we need to display them
    final plan = widget.profile?.plan ?? '';
    if (plan == AccountPlan.professional.value) {
      _loadSubscription();
    } else {
      setState(() {
        _isLoadingSubscription = false;
      });
    }
  }

  @override
  void didUpdateWidget(SubscriptionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If profile changed, handle plan transitions
    final oldPlan = oldWidget.profile?.plan ?? '';
    final newPlan = widget.profile?.plan ?? '';

    // If plan changed from non-Professional to Professional, load subscription details
    if (oldPlan != AccountPlan.professional.value &&
        newPlan == AccountPlan.professional.value &&
        _subscription == null &&
        !_isLoadingSubscription) {
      _loadSubscription();
    }

    // If plan changed from Professional to non-Professional, clear subscription data
    if (oldPlan == AccountPlan.professional.value &&
        newPlan != AccountPlan.professional.value) {
      setState(() {
        _subscription = null;
        _isLoadingSubscription = false;
      });
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await subscriptionApi.getSubscription();
      if (mounted) {
        setState(() {
          _subscription = subscription;
          _isLoadingSubscription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubscription = false;
        });
        // Don't show error if subscription doesn't exist (404 or similar)
        // Only show error for unexpected failures
        if (e.toString().contains('404') == false) {
          print('Failed to load subscription: $e');
        }
      }
    }
  }

  void _onSubscriptionSuccess() {
    // Reload subscription details after successful subscription
    _loadSubscription();
  }

  Future<void> _onSubscriptionCanceled() async {
    // Refresh profile to get updated plan status after cancellation
    final profile = widget.profile;
    if (profile != null) {
      try {
        final updatedProfile = await profileService.getProfile(
          ProfileRequestDto(
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
          ),
        );
        // Update profile state with the latest data from backend
        // Backend should have updated the plan after cancellation
        profileState.value = updatedProfile;
      } catch (e) {
        print('Failed to refresh profile after cancellation: $e');
      }
    }
    // The existing logic in build() will automatically switch to plans screen
    // when plan is no longer Professional
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.profile?.plan ?? '';

    // If plan is Professional, show subscription details
    if (plan == AccountPlan.professional.value) {
      // If subscription is loading, show loading indicator
      if (_isLoadingSubscription) {
        return const Center(child: CircularProgressIndicator());
      }

      // If subscription data is loaded, show subscription details
      if (_subscription != null) {
        return SubscriptionDetailsScreen(
          subscription: _subscription!,
          onSubscriptionCanceled: _onSubscriptionCanceled,
        );
      }

      // If subscription data is not loaded yet, show loading
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading subscription details...',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show subscription plans
    return SubscriptionPlansScreen(
      profile: widget.profile,
      onSubscriptionSuccess: _onSubscriptionSuccess,
    );
  }
}
