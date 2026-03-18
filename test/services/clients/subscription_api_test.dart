import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/subscription_api.dart';
import 'package:moustra/services/dtos/subscription_dto.dart';

import 'subscription_api_test.mocks.dart';

Map<String, dynamic> _samplePaymentIntentJson() => {
      'clientSecret': 'pi_secret_123',
      'ephemeralKeySecret': 'ek_secret_456',
      'customerId': 'cus_789',
    };

Map<String, dynamic> _sampleSubscriptionJson() => {
      'seats': 5,
      'price': '\$29.99',
      'status': 'active',
      'renewalDate': '2025-07-01',
      'billingHistory': [
        {
          'id': 'inv_1',
          'total': '\$29.99',
          'periodStart': '2025-06-01',
          'periodEnd': '2025-07-01',
          'status': 'paid',
          'hostedInvoiceUrl': 'https://example.com/invoice/1',
          'invoicePdf': 'https://example.com/invoice/1.pdf',
        },
      ],
    };

@GenerateMocks([DioApiClient])
void main() {
  group('SubscriptionApi Tests', () {
    late MockDioApiClient mockApiClient;
    late SubscriptionApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = SubscriptionApi(mockApiClient);
    });

    group('createPaymentIntent', () {
      test('should return PaymentIntentResponse on 200', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _samplePaymentIntentJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createPaymentIntent('price_123');

        expect(result.clientSecret, 'pi_secret_123');
        expect(result.ephemeralKeySecret, 'ek_secret_456');
        expect(result.customerId, 'cus_789');
        verify(mockApiClient.post(
          '/subscription/payment-intent',
          body: {'price_id': 'price_123'},
          query: anyNamed('query'),
        )).called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.createPaymentIntent('bad'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createSubscription', () {
      test('should complete on 200', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.createSubscription('price_123');

        verify(mockApiClient.post(
          '/subscription',
          body: {},
          query: {'priceId': 'price_123'},
        )).called(1);
      });

      test('should throw on error status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 500,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.createSubscription('bad'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('confirmSubscription', () {
      test('should complete on 200', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.confirmSubscription();

        verify(mockApiClient.post('/subscription/confirm',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.confirmSubscription(), throwsA(isA<Exception>()));
      });
    });

    group('getSubscription', () {
      test('should return SubscriptionResponseDto on 200', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleSubscriptionJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getSubscription();

        expect(result.seats, 5);
        expect(result.status, 'active');
        expect(result.billingHistory.length, 1);
        expect(result.billingHistory.first.id, 'inv_1');
        verify(mockApiClient.get('/subscription',
                query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 403,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.getSubscription(), throwsA(isA<Exception>()));
      });
    });

    group('cancelSubscription', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.cancelSubscription();

        verify(mockApiClient.delete('/subscription')).called(1);
      });

      test('should throw on error status', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 400,
              requestOptions: RequestOptions(),
            ));

        expect(() => api.cancelSubscription(), throwsA(isA<Exception>()));
      });
    });
  });
}
