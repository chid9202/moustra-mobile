import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

import 'cage_api_test.mocks.dart';

// Testable version of CageApi that accepts a client
class TestableCageApi {
  final ApiClient apiClient;
  static const String basePath = '/cage';

  TestableCageApi(this.apiClient);

  Future<RackDto> moveCage(String cageUuid, int order) async {
    final res = await apiClient.put(
      '$basePath/$cageUuid/order',
      body: {'order': order},
    );
    return RackDto.fromJson(jsonDecode(res.body));
  }

  /// Move cage to a specific x,y position (sparse grid positioning)
  Future<RackDto> moveCageByPosition(String cageUuid, int x, int y) async {
    final res = await apiClient.put(
      '$basePath/$cageUuid/order',
      body: {'x': x, 'y': y},
    );
    return RackDto.fromJson(jsonDecode(res.body));
  }
}

@GenerateMocks([ApiClient])
void main() {
  group('CageApi Tests', () {
    late MockApiClient mockApiClient;
    late TestableCageApi cageApi;

    setUp(() {
      mockApiClient = MockApiClient();
      cageApi = TestableCageApi(mockApiClient);
    });

    group('moveCage', () {
      test('should send order-based move request', () async {
        // Arrange
        const cageUuid = 'test-cage-uuid';
        const order = 100;
        final rackData = {
          'rackUuid': 'test-rack-uuid',
          'rackName': 'Test Rack',
          'rackWidth': 5,
          'rackHeight': 3,
          'cages': [],
        };

        when(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'order': order},
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(rackData), 200),
        );

        // Act
        final result = await cageApi.moveCage(cageUuid, order);

        // Assert
        expect(result.rackUuid, equals('test-rack-uuid'));
        expect(result.rackName, equals('Test Rack'));
        verify(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'order': order},
          ),
        ).called(1);
      });
    });

    group('moveCageByPosition', () {
      test('should send x,y position-based move request', () async {
        // Arrange
        const cageUuid = 'test-cage-uuid';
        const x = 3;
        const y = 2;
        final rackData = {
          'rackUuid': 'test-rack-uuid',
          'rackName': 'Test Rack',
          'rackWidth': 5,
          'rackHeight': 3,
          'cages': [
            {
              'cageUuid': cageUuid,
              'cageTag': 'Test Cage',
              'xPosition': x,
              'yPosition': y,
            },
          ],
        };

        when(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': x, 'y': y},
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(rackData), 200),
        );

        // Act
        final result = await cageApi.moveCageByPosition(cageUuid, x, y);

        // Assert
        expect(result.rackUuid, equals('test-rack-uuid'));
        expect(result.cages, isNotEmpty);
        expect(result.cages!.first.xPosition, equals(x));
        expect(result.cages!.first.yPosition, equals(y));
        verify(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': x, 'y': y},
          ),
        ).called(1);
      });

      test('should handle position at origin (0, 0)', () async {
        // Arrange
        const cageUuid = 'test-cage-uuid';
        const x = 0;
        const y = 0;
        final rackData = {
          'rackUuid': 'test-rack-uuid',
          'rackName': 'Test Rack',
          'rackWidth': 5,
          'rackHeight': 3,
          'cages': [
            {
              'cageUuid': cageUuid,
              'cageTag': 'Test Cage',
              'xPosition': x,
              'yPosition': y,
            },
          ],
        };

        when(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': x, 'y': y},
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(rackData), 200),
        );

        // Act
        final result = await cageApi.moveCageByPosition(cageUuid, x, y);

        // Assert
        expect(result.cages!.first.xPosition, equals(0));
        expect(result.cages!.first.yPosition, equals(0));
      });

      test('should handle large position values', () async {
        // Arrange
        const cageUuid = 'test-cage-uuid';
        const x = 99;
        const y = 49;
        final rackData = {
          'rackUuid': 'test-rack-uuid',
          'rackName': 'Large Rack',
          'rackWidth': 100,
          'rackHeight': 50,
          'cages': [
            {
              'cageUuid': cageUuid,
              'cageTag': 'Test Cage',
              'xPosition': x,
              'yPosition': y,
            },
          ],
        };

        when(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': x, 'y': y},
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(rackData), 200),
        );

        // Act
        final result = await cageApi.moveCageByPosition(cageUuid, x, y);

        // Assert
        expect(result.cages!.first.xPosition, equals(x));
        expect(result.cages!.first.yPosition, equals(y));
      });
    });
  });
}
