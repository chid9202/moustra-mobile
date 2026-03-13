import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';

void main() {
  group('PlugEventDto Tests', () {
    test('should create PlugEventDto from JSON with all fields', () {
      // Arrange
      final json = {
        'eid': 100,
        'plugEventId': 1,
        'plugEventUuid': 'plug-event-uuid-1',
        'female': {
          'animalId': 1,
          'animalUuid': 'female-uuid-1',
          'physicalTag': 'F001',
          'dateOfBirth': '2023-06-01T00:00:00Z',
          'sex': 'female',
        },
        'male': {
          'animalId': 2,
          'animalUuid': 'male-uuid-1',
          'physicalTag': 'M001',
          'dateOfBirth': '2023-05-15T00:00:00Z',
          'sex': 'male',
        },
        'mating': {'matingUuid': 'mating-uuid-1', 'matingTag': 'MT001'},
        'plugDate': '2024-03-01T00:00:00Z',
        'plugTime': '09:30',
        'checkedBy': {
          'accountId': 1,
          'accountUuid': 'account-uuid-1',
          'user': {
            'email': 'checker@test.com',
            'firstName': 'John',
            'lastName': 'Doe',
          },
        },
        'currentEday': 12.5,
        'targetEday': 14.0,
        'targetDate': '2024-03-15T00:00:00Z',
        'expectedDeliveryStart': '2024-03-20T00:00:00Z',
        'expectedDeliveryEnd': '2024-03-22T00:00:00Z',
        'outcome': 'live_birth',
        'outcomeDate': '2024-03-21T00:00:00Z',
        'outcomeEday': 20.0,
        'embryosCollected': 8,
        'notes': 'Test plug event notes',
        'owner': {
          'accountId': 2,
          'accountUuid': 'account-uuid-2',
          'user': {
            'email': 'owner@test.com',
            'firstName': 'Jane',
            'lastName': 'Smith',
          },
        },
        'createdDate': '2024-03-01T00:00:00Z',
        'updatedDate': '2024-03-02T00:00:00Z',
      };

      // Act
      final dto = PlugEventDto.fromJson(json);

      // Assert
      expect(dto.eid, 100);
      expect(dto.plugEventId, 1);
      expect(dto.plugEventUuid, 'plug-event-uuid-1');
      expect(dto.female?.animalId, 1);
      expect(dto.female?.physicalTag, 'F001');
      expect(dto.male?.animalId, 2);
      expect(dto.male?.physicalTag, 'M001');
      expect(dto.mating?.matingUuid, 'mating-uuid-1');
      expect(dto.mating?.matingTag, 'MT001');
      expect(dto.plugDate, DateTime.parse('2024-03-01T00:00:00Z'));
      expect(dto.plugTime, '09:30');
      expect(dto.checkedBy?.accountId, 1);
      expect(dto.checkedBy?.user?.email, 'checker@test.com');
      expect(dto.currentEday, 12.5);
      expect(dto.targetEday, 14.0);
      expect(dto.targetDate, DateTime.parse('2024-03-15T00:00:00Z'));
      expect(dto.expectedDeliveryStart, DateTime.parse('2024-03-20T00:00:00Z'));
      expect(dto.expectedDeliveryEnd, DateTime.parse('2024-03-22T00:00:00Z'));
      expect(dto.outcome, 'live_birth');
      expect(dto.outcomeDate, DateTime.parse('2024-03-21T00:00:00Z'));
      expect(dto.outcomeEday, 20.0);
      expect(dto.embryosCollected, 8);
      expect(dto.owner?.accountId, 2);
      expect(dto.owner?.user?.firstName, 'Jane');
      expect(dto.createdDate, DateTime.parse('2024-03-01T00:00:00Z'));
      expect(dto.updatedDate, DateTime.parse('2024-03-02T00:00:00Z'));
      // expect(dto.notes, 'Test plug event notes');
    });

    test('should create PlugEventDto with minimal required fields', () {
      // Arrange
      final json = {
        'plugEventId': 1,
        'plugEventUuid': 'plug-event-uuid-1',
        'plugDate': '2024-03-01T00:00:00Z',
      };

      // Act
      final dto = PlugEventDto.fromJson(json);

      // Assert
      expect(dto.plugEventId, 1);
      expect(dto.plugEventUuid, 'plug-event-uuid-1');
      expect(dto.plugDate, DateTime.parse('2024-03-01T00:00:00Z'));
      expect(dto.eid, null);
      expect(dto.female, null);
      expect(dto.male, null);
      expect(dto.mating, null);
      expect(dto.plugTime, null);
      expect(dto.checkedBy, null);
      expect(dto.currentEday, null);
      expect(dto.targetEday, null);
      expect(dto.targetDate, null);
      expect(dto.expectedDeliveryStart, null);
      expect(dto.expectedDeliveryEnd, null);
      expect(dto.outcome, null);
      expect(dto.outcomeDate, null);
      expect(dto.outcomeEday, null);
      expect(dto.embryosCollected, null);
      expect(dto.owner, null);
      expect(dto.createdDate, null);
      expect(dto.updatedDate, null);
      // expect(dto.notes, null);
    });

    test('should convert PlugEventDto to JSON', () {
      // Arrange
      final dto = PlugEventDto(
        eid: 100,
        plugEventId: 1,
        plugEventUuid: 'plug-event-uuid-1',
        plugDate: '${DateTime(2024, 3, 1)}',
        plugTime: '09:30',
        currentEday: 12.5,
        targetEday: 14.0,
        targetDate: '${DateTime(2024, 3, 15)}',
        outcome: 'live_birth',
        outcomeDate: '${DateTime(2024, 3, 21)}',
        outcomeEday: 20.0,
        embryosCollected: 8,
        // notes: 'Test notes',
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['eid'], 100);
      expect(json['plugEventId'], 1);
      expect(json['plugEventUuid'], 'plug-event-uuid-1');
      expect(json['plugDate'], '2024-03-01T00:00:00.000');
      expect(json['plugTime'], '09:30');
      expect(json['currentEday'], 12.5);
      expect(json['targetEday'], 14.0);
      expect(json['targetDate'], '2024-03-15T00:00:00.000');
      expect(json['outcome'], 'live_birth');
      expect(json['outcomeDate'], '2024-03-21T00:00:00.000');
      expect(json['outcomeEday'], 20.0);
      expect(json['embryosCollected'], 8);
      expect(json['notes'], 'Test notes');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'eid': null,
        'plugEventId': 1,
        'plugEventUuid': 'plug-event-uuid-1',
        'female': null,
        'male': null,
        'mating': null,
        'plugDate': '2024-03-01T00:00:00Z',
        'plugTime': null,
        'checkedBy': null,
        'currentEday': null,
        'targetEday': null,
        'targetDate': null,
        'expectedDeliveryStart': null,
        'expectedDeliveryEnd': null,
        'outcome': null,
        'outcomeDate': null,
        'outcomeEday': null,
        'embryosCollected': null,
        'notes': null,
        'owner': null,
        'createdDate': null,
        'updatedDate': null,
      };

      // Act
      final dto = PlugEventDto.fromJson(json);

      // Assert
      expect(dto.plugEventId, 1);
      expect(dto.plugEventUuid, 'plug-event-uuid-1');
      expect(dto.plugDate, DateTime.parse('2024-03-01T00:00:00Z'));
      expect(dto.eid, null);
      expect(dto.female, null);
      expect(dto.male, null);
      expect(dto.mating, null);
      expect(dto.plugTime, null);
      expect(dto.checkedBy, null);
      expect(dto.currentEday, null);
      expect(dto.targetEday, null);
      expect(dto.targetDate, null);
      expect(dto.expectedDeliveryStart, null);
      expect(dto.expectedDeliveryEnd, null);
      expect(dto.outcome, null);
      expect(dto.outcomeDate, null);
      expect(dto.outcomeEday, null);
      expect(dto.embryosCollected, null);
      expect(dto.owner, null);
      expect(dto.createdDate, null);
      expect(dto.updatedDate, null);
      // expect(dto.notes, null);
    });

    test('should handle nested DTOs correctly', () {
      // Arrange
      final json = {
        'plugEventId': 1,
        'plugEventUuid': 'plug-event-uuid-1',
        'plugDate': '2024-03-01T00:00:00Z',
        'female': {
          'animalId': 10,
          'animalUuid': 'female-uuid-10',
          'physicalTag': 'F010',
          'sex': 'female',
        },
        'mating': {
          'matingUuid': 'mating-uuid-5',
          'matingTag': 'MT005',
          'animals': [
            {
              'animalId': 10,
              'animalUuid': 'female-uuid-10',
              'physicalTag': 'F010',
              'sex': 'female',
            },
          ],
        },
        'owner': {
          'accountId': 3,
          'accountUuid': 'account-uuid-3',
          'user': {
            'email': 'lab@test.com',
            'firstName': 'Lab',
            'lastName': 'Manager',
          },
        },
      };

      // Act
      final dto = PlugEventDto.fromJson(json);

      // Assert
      expect(dto.female?.animalId, 10);
      expect(dto.female?.animalUuid, 'female-uuid-10');
      expect(dto.female?.physicalTag, 'F010');
      expect(dto.mating?.matingUuid, 'mating-uuid-5');
      expect(dto.mating?.matingTag, 'MT005');
      expect(dto.mating?.animals?.length, 1);
      expect(dto.mating?.animals?.first.physicalTag, 'F010');
      expect(dto.owner?.accountId, 3);
      expect(dto.owner?.user?.email, 'lab@test.com');
      expect(dto.owner?.user?.firstName, 'Lab');
      expect(dto.owner?.user?.lastName, 'Manager');
    });
  });
}
