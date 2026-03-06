import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/task_dto.dart';

class TaskApi {
  static const String taskPath = '/task';

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
    if (res.statusCode >= 400) {
      throw Exception('Failed to load tasks: ${res.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return TaskListResponseDto.fromJson(data);
  }

  Future<TaskDto> getTask(String uuid) async {
    final res = await apiClient.get('$taskPath/$uuid');
    return TaskDto.fromJson(jsonDecode(res.body));
  }

  Future<TaskDto> createTask(PostTaskDto dto) async {
    final res = await apiClient.post(taskPath, body: dto.toJson());
    if (res.statusCode == 404) {
      throw Exception('Task feature is not yet available on this server');
    }
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create task (${res.statusCode})');
    }
    return TaskDto.fromJson(jsonDecode(res.body));
  }

  Future<TaskDto> updateTask(String uuid, Map<String, dynamic> data) async {
    final res = await apiClient.patch('$taskPath/$uuid', body: data);
    if (res.statusCode >= 400) {
      throw Exception('Failed to update task: ${res.body}');
    }
    return TaskDto.fromJson(jsonDecode(res.body));
  }

  Future<void> completeTask(String uuid) async {
    final res = await apiClient.post('$taskPath/$uuid/complete', body: {});
    if (res.statusCode >= 400) {
      throw Exception('Failed to complete task: ${res.body}');
    }
  }

  Future<void> dismissTask(String uuid) async {
    final res = await apiClient.post('$taskPath/$uuid/dismiss', body: {});
    if (res.statusCode >= 400) {
      throw Exception('Failed to dismiss task: ${res.body}');
    }
  }

  Future<void> snoozeTask(String uuid, String snoozeUntil) async {
    final res = await apiClient.post(
      '$taskPath/$uuid/snooze',
      body: {'snoozeUntil': snoozeUntil},
    );
    if (res.statusCode >= 400) {
      throw Exception('Failed to snooze task: ${res.body}');
    }
  }

  Future<TaskSummaryDto> getTaskSummary() async {
    final res = await apiClient.get('$taskPath/summary');
    if (res.statusCode == 404) {
      return TaskSummaryDto(pending: 0, due: 0, overdue: 0, completedToday: 0);
    }
    if (res.statusCode >= 400) {
      throw Exception('Failed to load task summary: ${res.statusCode}');
    }
    return TaskSummaryDto.fromJson(jsonDecode(res.body));
  }
}

final TaskApi taskService = TaskApi();
