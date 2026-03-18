import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/task_dto.dart';

import 'task_api_test.mocks.dart';

/// Testable TaskApi that accepts DioApiClient for testing.
class TestableTaskApi {
  final DioApiClient apiClient;
  static const String taskPath = '/task';

  TestableTaskApi(this.apiClient);

  Future<TaskListResponseDto> getTasks({
    String? status,
    String? taskType,
    String? assignedTo,
    String? priority,
    String? ordering,
    int limit = 200,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (status != null) query['status'] = status;
    if (taskType != null) query['task_type'] = taskType;
    if (assignedTo != null) query['assigned_to'] = assignedTo;
    if (priority != null) query['priority'] = priority;
    if (ordering != null) query['ordering'] = ordering;

    final res = await apiClient.get(taskPath, query: query);
    if (res.statusCode == 404) {
      return TaskListResponseDto(tasks: []);
    }
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load tasks: ${res.statusCode}');
    }
    final Map<String, dynamic> data = res.data;
    return TaskListResponseDto.fromJson(data);
  }

  Future<TaskDto> getTask(String uuid) async {
    final res = await apiClient.get('$taskPath/$uuid');
    return TaskDto.fromJson(res.data);
  }

  Future<TaskSummaryDto> getTaskSummary() async {
    final res = await apiClient.get('$taskPath/summary');
    if (res.statusCode == 404) {
      return TaskSummaryDto(pending: 0, due: 0, overdue: 0, completedToday: 0);
    }
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load task summary: ${res.statusCode}');
    }
    return TaskSummaryDto.fromJson(res.data);
  }
}

@GenerateMocks([DioApiClient])
void main() {
  group('TaskApi', () {
    late MockDioApiClient mockApiClient;
    late TestableTaskApi taskApi;

    final sampleTask = {
      'taskUuid': 'task-uuid-1',
      'taskType': 'wean',
      'status': 'pending',
      'priority': 'high',
      'title': 'Wean litter',
      'createdDate': '2026-03-01T00:00:00.000',
    };

    final sampleTasksResponse = {
      'tasks': [sampleTask],
      'total': 1,
    };

    final sampleSummaryResponse = {
      'pending': 5,
      'due': 2,
      'overdue': 1,
      'completedToday': 3,
      'byType': [],
    };

    setUp(() {
      mockApiClient = MockDioApiClient();
      taskApi = TestableTaskApi(mockApiClient);
    });

    group('getTasks', () {
      test('should return task list', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => Response(data: sampleTasksResponse, statusCode: 200, requestOptions: RequestOptions()));

        final result = await taskApi.getTasks();

        expect(result.tasks.length, 1);
        expect(result.tasks.first.title, 'Wean litter');
        expect(result.total, 1);
      });

      test('should pass query params', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => Response(data: sampleTasksResponse, statusCode: 200, requestOptions: RequestOptions()));

        await taskApi.getTasks(status: 'pending', taskType: 'wean', limit: 50);

        verify(
          mockApiClient.get(
            TestableTaskApi.taskPath,
            query: argThat(
              allOf([
                containsPair('status', 'pending'),
                containsPair('task_type', 'wean'),
                containsPair('limit', '50'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });

      test('should return empty list on 404', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => Response(data: '', statusCode: 404, requestOptions: RequestOptions()));

        final result = await taskApi.getTasks();

        expect(result.tasks, isEmpty);
        expect(result.total, 0);
      });

      test('should throw on 400', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions()));

        expect(() => taskApi.getTasks(), throwsA(isA<Exception>()));
      });
    });

    group('getTask', () {
      test('should return single task', () async {
        when(mockApiClient.get(any))
            .thenAnswer((_) async => Response(data: sampleTask, statusCode: 200, requestOptions: RequestOptions()));

        final result = await taskApi.getTask('task-uuid-1');

        expect(result.taskUuid, 'task-uuid-1');
        expect(result.title, 'Wean litter');
        verify(mockApiClient.get('${TestableTaskApi.taskPath}/task-uuid-1')).called(1);
      });
    });

    group('getTaskSummary', () {
      test('should return summary', () async {
        when(mockApiClient.get(any)).thenAnswer(
            (_) async => Response(data: sampleSummaryResponse, statusCode: 200, requestOptions: RequestOptions()));

        final result = await taskApi.getTaskSummary();

        expect(result.pending, 5);
        expect(result.due, 2);
        expect(result.overdue, 1);
        expect(result.completedToday, 3);
      });

      test('should return zero summary on 404', () async {
        when(mockApiClient.get(any))
            .thenAnswer((_) async => Response(data: '', statusCode: 404, requestOptions: RequestOptions()));

        final result = await taskApi.getTaskSummary();

        expect(result.pending, 0);
        expect(result.due, 0);
        expect(result.overdue, 0);
        expect(result.completedToday, 0);
      });

      test('should throw on 400', () async {
        when(mockApiClient.get(any))
            .thenAnswer((_) async => Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions()));

        expect(() => taskApi.getTaskSummary(), throwsA(isA<Exception>()));
      });
    });
  });
}
