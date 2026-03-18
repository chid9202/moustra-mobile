import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/subscription_dto.dart';

class PaymentIntentResponse {
  final String clientSecret;
  final String ephemeralKeySecret;
  final String customerId;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.ephemeralKeySecret,
    required this.customerId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'] as String,
      ephemeralKeySecret: json['ephemeralKeySecret'] as String,
      customerId: json['customerId'] as String,
    );
  }
}

class SubscriptionApi {
  final DioApiClient apiClient;

  SubscriptionApi(this.apiClient);

  /// Creates a payment intent for a subscription
  /// Returns PaymentIntentResponse with clientSecret, ephemeralKeySecret, and customerId
  Future<PaymentIntentResponse> createPaymentIntent(String priceId) async {
    final res = await apiClient.post(
      '/subscription/payment-intent',
      body: {'price_id': priceId},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaymentIntentResponse.fromJson(data);
  }

  /// Creates/activates subscription after successful payment
  /// priceId should be passed as query parameter
  Future<void> createSubscription(String priceId) async {
    final res = await apiClient.post(
      '/subscription',
      body: {},
      query: {'priceId': priceId},
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create subscription: ${res.data}');
    }
  }

  /// Confirms subscription after successful payment
  /// Calls POST account/<uuid:account_uuid>/subscription/confirm
  Future<void> confirmSubscription() async {
    final res = await apiClient.post('/subscription/confirm');
    if (res.statusCode != 200) {
      throw Exception('Failed to confirm subscription: ${res.data}');
    }
  }

  /// Gets subscription details for the current account
  /// Returns SubscriptionResponseDto with seats, price, status, renewalDate, and billingHistory
  Future<SubscriptionResponseDto> getSubscription() async {
    final res = await apiClient.get('/subscription');
    if (res.statusCode != 200) {
      throw Exception('Failed to get subscription: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SubscriptionResponseDto.fromJson(data);
  }

  /// Cancels the subscription for the current account
  /// Calls DELETE account/<uuid:account_uuid>/subscription
  Future<void> cancelSubscription() async {
    final res = await apiClient.delete('/subscription');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to cancel subscription: ${res.data}');
    }
  }
}

final SubscriptionApi subscriptionApi = SubscriptionApi(dioApiClient);
