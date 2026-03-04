import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_plug_event_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/services/dtos/record_outcome_dto.dart';

void main() {
  group('PostPlugEventDto Tests', () {
    test('should create PostPlugEventDto from JSON with all fields', () {
      // Arrange
      final json = {
        'female': 'female-uuid-1',
        'male': 'male-uuid-1',
        'mating': 'mating-uuid-1',
        'plugDate': '2024-03-01',
        'targetEday': 14,
        'comment': 'Test plug event comment',
      };

      // Act
      final dto = PostPlugEventDto.fromJson(json);

      // Assert
      expect(dto.female, 'female-uuid-1');
      expect(dto.male, 'male-uuid-1');
      expect(dto.mating, 'mating-uuid-1');
      expect(dto.plugDate, '2024-03-01');
      expect(dto.targetEday, 14);
      expect(dto.comment, 'Test plug event comment');
    });

    test('should create PostPlugEventDto with minimal required fields', () {
      // Arrange
      final json = {
        'female': 'female-uuid-1',
        'plugDate': '2024-03-01',
      };

      // Act
      final dto = PostPlugEventDto.fromJson(json);

      // Assert
      expect(dto.female, 'female-uuid-1');
      expect(dto.plugDate, '2024-03-01');
      expect(dto.male, null);
      expect(dto.mating, null);
      expect(dto.targetEday, null);
      expect(dto.comment, null);
    });

    test('should convert PostPlugEventDto to JSON', () {
      // Arrange
      final dto = PostPlugEventDto(
        female: 'female-uuid-1',
        male: 'male-uuid-1',
        mating: 'mating-uuid-1',
        plugDate: '2024-03-01',
        targetEday: 14,
        comment: 'Test plug event comment',
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['female'], 'female-uuid-1');
      expect(json['male'], 'male-uuid-1');
      expect(json['mating'], 'mating-uuid-1');
      expect(json['plugDate'], '2024-03-01');
      expect(json['targetEday'], 14);
      expect(json['comment'], 'Test plug event comment');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'female': 'female-uuid-1',
        'plugDate': '2024-03-01',
        'male': null,
        'mating': null,
        'targetEday': null,
        'comment': null,
      };

      // Act
      final dto = PostPlugEventDto.fromJson(json);

      // Assert
      expect(dto.female, 'female-uuid-1');
      expect(dto.plugDate, '2024-03-01');
      expect(dto.male, null);
      expect(dto.mating, null);
      expect(dto.targetEday, null);
      expect(dto.comment, null);
    });
  });

  group('PutPlugEventDto Tests', () {
    test('should create PutPlugEventDto from JSON with all fields', () {
      // Arrange
      final json = {
        'plugDate': '2024-03-15',
        'targetEday': 18,
        'comment': 'Updated plug event comment',
        'male': 'male-uuid-2',
      };

      // Act
      final dto = PutPlugEventDto.fromJson(json);

      // Assert
      expect(dto.plugDate, '2024-03-15');
      expect(dto.targetEday, 18);
      expect(dto.comment, 'Updated plug event comment');
      expect(dto.male, 'male-uuid-2');
    });

    test('should create PutPlugEventDto with minimal fields', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final dto = PutPlugEventDto.fromJson(json);

      // Assert
      expect(dto.plugDate, null);
      expect(dto.targetEday, null);
      expect(dto.comment, null);
      expect(dto.male, null);
    });

    test('should convert PutPlugEventDto to JSON', () {
      // Arrange
      final dto = PutPlugEventDto(
        plugDate: '2024-03-15',
        targetEday: 18,
        comment: 'Updated plug event comment',
        male: 'male-uuid-2',
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['plugDate'], '2024-03-15');
      expect(json['targetEday'], 18);
      expect(json['comment'], 'Updated plug event comment');
      expect(json['male'], 'male-uuid-2');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'plugDate': null,
        'targetEday': null,
        'comment': null,
        'male': null,
      };

      // Act
      final dto = PutPlugEventDto.fromJson(json);

      // Assert
      expect(dto.plugDate, null);
      expect(dto.targetEday, null);
      expect(dto.comment, null);
      expect(dto.male, null);
    });
  });

  group('RecordOutcomeDto Tests', () {
    test('should create RecordOutcomeDto from JSON with all fields', () {
      // Arrange
      final json = {
        'outcome': 'live_birth',
        'outcomeDate': '2024-03-20',
        'embryosCollected': 8,
        'litter': 'litter-uuid-1',
      };

      // Act
      final dto = RecordOutcomeDto.fromJson(json);

      // Assert
      expect(dto.outcome, 'live_birth');
      expect(dto.outcomeDate, '2024-03-20');
      expect(dto.embryosCollected, 8);
      expect(dto.litter, 'litter-uuid-1');
    });

    test('should create RecordOutcomeDto with minimal required fields', () {
      // Arrange
      final json = {
        'outcome': 'resorption',
        'outcomeDate': '2024-03-20',
      };

      // Act
      final dto = RecordOutcomeDto.fromJson(json);

      // Assert
      expect(dto.outcome, 'resorption');
      expect(dto.outcomeDate, '2024-03-20');
      expect(dto.embryosCollected, null);
      expect(dto.litter, null);
    });

    test('should convert RecordOutcomeDto to JSON', () {
      // Arrange
      final dto = RecordOutcomeDto(
        outcome: 'live_birth',
        outcomeDate: '2024-03-20',
        embryosCollected: 8,
        litter: 'litter-uuid-1',
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['outcome'], 'live_birth');
      expect(json['outcomeDate'], '2024-03-20');
      expect(json['embryosCollected'], 8);
      expect(json['litter'], 'litter-uuid-1');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'outcome': 'live_birth',
        'outcomeDate': '2024-03-20',
        'embryosCollected': null,
        'litter': null,
      };

      // Act
      final dto = RecordOutcomeDto.fromJson(json);

      // Assert
      expect(dto.outcome, 'live_birth');
      expect(dto.outcomeDate, '2024-03-20');
      expect(dto.embryosCollected, null);
      expect(dto.litter, null);
    });
  });
}
