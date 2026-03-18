import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/subscription_dto.dart';

void main() {
  group('SubscriptionResponseDto', () {
    test('fromJson with complete data', () {
      final json = {
        'seats': 5,
        'price': '\$49.99',
        'status': 'active',
        'renewalDate': '2025-01-01',
        'billingHistory': [
          {
            'id': 'inv_001',
            'total': '\$49.99',
            'periodStart': '2024-01-01',
            'periodEnd': '2024-02-01',
            'status': 'paid',
            'hostedInvoiceUrl': 'https://stripe.com/invoice/1',
            'invoicePdf': 'https://stripe.com/invoice/1.pdf',
          },
        ],
      };

      final dto = SubscriptionResponseDto.fromJson(json);

      expect(dto.seats, equals(5));
      expect(dto.price, equals('\$49.99'));
      expect(dto.status, equals('active'));
      expect(dto.renewalDate, equals('2025-01-01'));
      expect(dto.billingHistory.length, equals(1));
      expect(dto.billingHistory[0].id, equals('inv_001'));
      expect(dto.billingHistory[0].total, equals('\$49.99'));
      expect(dto.billingHistory[0].periodStart, equals('2024-01-01'));
      expect(dto.billingHistory[0].periodEnd, equals('2024-02-01'));
      expect(dto.billingHistory[0].status, equals('paid'));
      expect(
        dto.billingHistory[0].hostedInvoiceUrl,
        equals('https://stripe.com/invoice/1'),
      );
      expect(
        dto.billingHistory[0].invoicePdf,
        equals('https://stripe.com/invoice/1.pdf'),
      );
    });

    test('fromJson with empty billing history', () {
      final json = {
        'seats': 1,
        'price': '\$9.99',
        'status': 'active',
        'renewalDate': '2025-01-01',
        'billingHistory': <Map<String, dynamic>>[],
      };

      final dto = SubscriptionResponseDto.fromJson(json);

      expect(dto.billingHistory, isEmpty);
    });

    test('toJson round-trip', () {
      final json = {
        'seats': 5,
        'price': '\$49.99',
        'status': 'active',
        'renewalDate': '2025-01-01',
        'billingHistory': [
          {
            'id': 'inv_001',
            'total': '\$49.99',
            'periodStart': '2024-01-01',
            'periodEnd': '2024-02-01',
            'status': 'paid',
            'hostedInvoiceUrl': 'https://stripe.com/invoice/1',
            'invoicePdf': 'https://stripe.com/invoice/1.pdf',
          },
        ],
      };

      final dto = SubscriptionResponseDto.fromJson(json);
      final output = dto.toJson();

      expect(output['seats'], equals(json['seats']));
      expect(output['price'], equals(json['price']));
      expect(output['status'], equals(json['status']));
      expect((output['billingHistory'] as List).length, equals(1));
    });
  });

  group('BillingHistoryItemDto', () {
    test('fromJson with complete data', () {
      final json = {
        'id': 'inv_001',
        'total': '\$49.99',
        'periodStart': '2024-01-01',
        'periodEnd': '2024-02-01',
        'status': 'paid',
        'hostedInvoiceUrl': 'https://stripe.com/invoice/1',
        'invoicePdf': 'https://stripe.com/invoice/1.pdf',
      };

      final dto = BillingHistoryItemDto.fromJson(json);

      expect(dto.id, equals('inv_001'));
      expect(dto.total, equals('\$49.99'));
    });

    test('toJson round-trip', () {
      final json = {
        'id': 'inv_001',
        'total': '\$49.99',
        'periodStart': '2024-01-01',
        'periodEnd': '2024-02-01',
        'status': 'paid',
        'hostedInvoiceUrl': 'https://stripe.com/invoice/1',
        'invoicePdf': 'https://stripe.com/invoice/1.pdf',
      };

      final dto = BillingHistoryItemDto.fromJson(json);
      final output = dto.toJson();

      expect(output['id'], equals(json['id']));
      expect(output['total'], equals(json['total']));
      expect(output['periodStart'], equals(json['periodStart']));
    });
  });
}
