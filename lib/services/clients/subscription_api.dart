import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:moustra/services/clients/api_client.dart';
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
  final ApiClient apiClient;

  SubscriptionApi(this.apiClient);

  /// Creates a payment intent for a subscription
  /// Returns PaymentIntentResponse with clientSecret, ephemeralKeySecret, and customerId
  Future<PaymentIntentResponse> createPaymentIntent(String priceId) async {
    final res = await apiClient.post(
      '/subscription/payment-intent',
      body: {'price_id': priceId},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${res.body}');
    }
    debugPrint('Payment intent response body: ${res.body}');
    try {
      final Map<String, dynamic> data = jsonDecode(res.body);
      debugPrint('Parsed payment intent data: $data');
      final paymentIntent = PaymentIntentResponse.fromJson(data);
      debugPrint('PaymentIntentResponse created successfully');
      return paymentIntent;
    } catch (e, stackTrace) {
      debugPrint('Error parsing payment intent response: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Response body: ${res.body}');
      rethrow;
    }
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
      throw Exception('Failed to create subscription: ${res.body}');
    }
  }

  /// Confirms subscription after successful payment
  /// Calls POST account/<uuid:account_uuid>/subscription/confirm
  Future<void> confirmSubscription() async {
    final res = await apiClient.post('/subscription/confirm');
    if (res.statusCode != 200) {
      throw Exception('Failed to confirm subscription: ${res.body}');
    }
  }

  /// Gets subscription details for the current account
  /// Returns SubscriptionResponseDto with seats, price, status, renewalDate, and billingHistory
  Future<SubscriptionResponseDto> getSubscription() async {
    final res = await apiClient.get('/subscription');
    if (res.statusCode != 200) {
      throw Exception('Failed to get subscription: ${res.body}');
    }
    try {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return SubscriptionResponseDto.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('Error parsing subscription response: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Response body: ${res.body}');
      rethrow;
    }
  }

  /// Cancels the subscription for the current account
  /// Calls DELETE account/<uuid:account_uuid>/subscription
  Future<void> cancelSubscription() async {
    final res = await apiClient.delete('/subscription');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to cancel subscription: ${res.body}');
    }
  }
}

final SubscriptionApi subscriptionApi = SubscriptionApi(apiClient);
