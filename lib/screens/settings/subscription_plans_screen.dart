import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:moustra/constants/account_constants.dart';
import 'package:moustra/services/clients/subscription_api.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/clients/profile_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/services/clients/api_client.dart';

final usersApi = UsersApi(apiClient);

class SubscriptionPlansScreen extends StatefulWidget {
  final ProfileResponseDto? profile;
  final VoidCallback? onSubscriptionSuccess;

  const SubscriptionPlansScreen({
    super.key,
    this.profile,
    this.onSubscriptionSuccess,
  });

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int? _userCount;
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUserCount();
  }

  Future<void> _loadUserCount() async {
    try {
      final users = await usersApi.getUsers();
      if (mounted) {
        setState(() {
          _userCount = users.length;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user count: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _subscribeToPlan(String priceId, String planName) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify Stripe is initialized
      final publishableKey = Stripe.publishableKey;
      if (publishableKey.isEmpty) {
        throw Exception(
          'Stripe is not initialized. Publishable key is missing.',
        );
      }

      // Get payment intent from backend
      final paymentIntent = await subscriptionApi.createPaymentIntent(priceId);

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          customerId: paymentIntent.customerId,
          customerEphemeralKeySecret: paymentIntent.ephemeralKeySecret,
          merchantDisplayName: 'Moustra',
        ),
      );

      // Present Stripe payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - confirm subscription on backend
      print('Confirming subscription');
      await subscriptionApi.confirmSubscription();
      print('Subscription confirmed successfully');

      // If subscription confirmation is successful (200), update plan to Professional in store
      final profile = widget.profile;
      if (profile != null) {
        final profileWithProfessionalPlan = ProfileResponseDto(
          accountUuid: profile.accountUuid,
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          labName: profile.labName,
          labUuid: profile.labUuid,
          onboarded: profile.onboarded,
          onboardedDate: profile.onboardedDate,
          position: profile.position,
          role: profile.role,
          plan: AccountPlan.professional.value,
        );
        profileState.value = profileWithProfessionalPlan;
      }

      // Refresh profile and subscription details
      if (profile != null) {
        final updatedProfile = await profileService.getProfile(
          ProfileRequestDto(
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
          ),
        );
        // Update with latest profile data but keep Professional plan
        final profileWithLatestData = ProfileResponseDto(
          accountUuid: updatedProfile.accountUuid,
          firstName: updatedProfile.firstName,
          lastName: updatedProfile.lastName,
          email: updatedProfile.email,
          labName: updatedProfile.labName,
          labUuid: updatedProfile.labUuid,
          onboarded: updatedProfile.onboarded,
          onboardedDate: updatedProfile.onboardedDate,
          position: updatedProfile.position,
          role: updatedProfile.role,
          plan: AccountPlan.professional.value,
        );
        profileState.value = profileWithLatestData;
      }

      // Notify parent that subscription was successful
      if (mounted) {
        widget.onSubscriptionSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Subscription error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');

      if (mounted) {
        String errorMessage = 'Payment failed';
        if (e is StripeException) {
          errorMessage = e.error.message ?? 'Payment failed';
          print('Stripe error code: ${e.error.code}');
          print('Stripe error type: ${e.error.type}');
        } else if (e.toString().contains('StripeConfigException') ||
            e.toString().contains('Stripe configuration')) {
          errorMessage = 'Stripe configuration error: ${e.toString()}';
        } else {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingUsers)
            const Center(child: CircularProgressIndicator())
          else if (_userCount != null) ...[
            Text(
              'Current Users: $_userCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
          ],
          _buildPlanCard(
            context,
            title: '1 Month',
            pricePerUser: 10.0,
            priceId: '1m',
            savings: null,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            title: '3 Months',
            pricePerUser: 28.50,
            priceId: '3m',
            savings: '5%',
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            title: '6 Months',
            pricePerUser: 54.0,
            priceId: '6m',
            savings: '10%',
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            title: '12 Months',
            pricePerUser: 96.0,
            priceId: '12m',
            savings: '20%',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required double pricePerUser,
    required String priceId,
    String? savings,
  }) {
    final totalPrice = _userCount != null ? pricePerUser * _userCount! : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (savings != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Save $savings',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_userCount != null) ...[
              Text(
                '\$${pricePerUser.toStringAsFixed(2)} per user',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ] else
              const Text('Loading pricing...'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _userCount == null
                    ? null
                    : () => _subscribeToPlan(priceId, title),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

