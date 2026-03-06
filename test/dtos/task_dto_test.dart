import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/task_dto.dart';

void main() {
  group('TaskDto', () {
    test('should create from JSON with all fields', () {
      final json = {
        'taskUuid': 'task-uuid-1',
        'taskType': 'wean',
        'status': 'pending',
        'priority': 'high',
        'title': 'Wean litter L001',
        'description': 'Move pups to new cage',
        'dueDate': '2026-03-10T00:00:00.000',
        'snoozeUntil': null,
        'assignedToUuid': 'user-uuid-1',
        'assignedToName': 'Jane Doe',
        'entityType': 'litter',
        'entityUuid': 'litter-uuid-1',
        'metadata': {'cageUuid': 'cage-1'},
        'createdDate': '2026-03-01T12:00:00.000',
        'completedAt': null,
      };

      final dto = TaskDto.fromJson(json);

      expect(dto.taskUuid, 'task-uuid-1');
      expect(dto.taskType, 'wean');
      expect(dto.status, 'pending');
      expect(dto.priority, 'high');
      expect(dto.title, 'Wean litter L001');
      expect(dto.description, 'Move pups to new cage');
      expect(dto.dueDate, DateTime(2026, 3, 10));
      expect(dto.snoozeUntil, isNull);
      expect(dto.assignedToUuid, 'user-uuid-1');
      expect(dto.assignedToName, 'Jane Doe');
      expect(dto.entityType, 'litter');
      expect(dto.entityUuid, 'litter-uuid-1');
      expect(dto.metadata, {'cageUuid': 'cage-1'});
      expect(dto.createdDate, DateTime(2026, 3, 1, 12, 0, 0));
      expect(dto.completedAt, isNull);
    });

    test('should create from JSON with minimal fields', () {
      final json = {
        'taskUuid': 'task-uuid-2',
        'taskType': 'custom',
        'status': 'completed',
        'priority': 'medium',
        'title': 'Quick task',
        'createdDate': '2026-03-05T00:00:00.000',
      };

      final dto = TaskDto.fromJson(json);

      expect(dto.taskUuid, 'task-uuid-2');
      expect(dto.title, 'Quick task');
      expect(dto.description, isNull);
      expect(dto.dueDate, isNull);
      expect(dto.assignedToUuid, isNull);
      expect(dto.entityType, isNull);
      expect(dto.metadata, isNull);
    });

    test('should convert to JSON', () {
      final dto = TaskDto(
        taskUuid: 'task-uuid-3',
        taskType: 'plug_check',
        status: 'pending',
        priority: 'low',
        title: 'Check plug',
        createdDate: DateTime(2026, 3, 1),
      );

      final json = dto.toJson();

      expect(json['taskUuid'], 'task-uuid-3');
      expect(json['taskType'], 'plug_check');
      expect(json['status'], 'pending');
      expect(json['priority'], 'low');
      expect(json['title'], 'Check plug');
      expect(json['createdDate'], isNotNull);
    });
  });

  group('TaskListResponseDto', () {
    test('should create from JSON', () {
      final json = {
        'tasks': [
          {
            'taskUuid': 't1',
            'taskType': 'wean',
            'status': 'pending',
            'priority': 'high',
            'title': 'Task 1',
            'createdDate': '2026-03-01T00:00:00.000',
          },
        ],
        'total': 1,
      };

      final dto = TaskListResponseDto.fromJson(json);

      expect(dto.tasks.length, 1);
      expect(dto.tasks.first.title, 'Task 1');
      expect(dto.total, 1);
    });

    test('should default total to 0 when missing', () {
      final json = {
        'tasks': [],
      };

      final dto = TaskListResponseDto.fromJson(json);

      expect(dto.tasks, isEmpty);
      expect(dto.total, 0);
    });
  });

  group('TaskSummaryDto', () {
    test('should create from JSON', () {
      final json = {
        'pending': 5,
        'due': 2,
        'overdue': 1,
        'completedToday': 3,
        'byType': [
          {'type': 'wean', 'count': 4},
          {'type': 'plug_check', 'count': 2},
        ],
      };

      final dto = TaskSummaryDto.fromJson(json);

      expect(dto.pending, 5);
      expect(dto.due, 2);
      expect(dto.overdue, 1);
      expect(dto.completedToday, 3);
      expect(dto.byType.length, 2);
      expect(dto.byType.first.type, 'wean');
      expect(dto.byType.first.count, 4);
    });

    test('should default byType to empty list when missing', () {
      final json = {
        'pending': 0,
        'due': 0,
        'overdue': 0,
        'completedToday': 0,
      };

      final dto = TaskSummaryDto.fromJson(json);

      expect(dto.byType, isEmpty);
    });
  });

  group('TaskTypeCountDto', () {
    test('should create from JSON', () {
      final json = {'type': 'wean', 'count': 10};

      final dto = TaskTypeCountDto.fromJson(json);

      expect(dto.type, 'wean');
      expect(dto.count, 10);
    });
  });

  group('PostTaskDto', () {
    test('should create from JSON with optional fields', () {
      final json = {
        'title': 'New task',
        'description': 'Details',
        'taskType': 'custom',
        'priority': 'high',
        'dueDate': '2026-03-15',
        'assignedTo': 'user-uuid',
        'litterUuid': 'litter-1',
      };

      final dto = PostTaskDto.fromJson(json);

      expect(dto.title, 'New task');
      expect(dto.description, 'Details');
      expect(dto.taskType, 'custom');
      expect(dto.priority, 'high');
      expect(dto.dueDate, '2026-03-15');
      expect(dto.assignedTo, 'user-uuid');
      expect(dto.litterUuid, 'litter-1');
    });

    test('should convert to JSON omitting nulls', () {
      final dto = PostTaskDto(title: 'Minimal task');

      final json = dto.toJson();

      expect(json['title'], 'Minimal task');
      expect(json.containsKey('description'), isFalse);
    });
  });
}
