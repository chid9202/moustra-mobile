import 'package:json_annotation/json_annotation.dart';

part 'task_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskDto {
  final String taskUuid;
  final String taskType;
  final String status;
  final String priority;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? snoozeUntil;
  final String? assignedToUuid;
  final String? assignedToName;
  final String? entityType;
  final String? entityUuid;
  final Map<String, dynamic>? metadata;
  final DateTime createdDate;
  final DateTime? completedAt;

  TaskDto({
    required this.taskUuid,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.title,
    this.description,
    this.dueDate,
    this.snoozeUntil,
    this.assignedToUuid,
    this.assignedToName,
    this.entityType,
    this.entityUuid,
    this.metadata,
    required this.createdDate,
    this.completedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskListResponseDto {
  final List<TaskDto> tasks;
  final int total;

  TaskListResponseDto({
    required this.tasks,
    this.total = 0,
  });

  factory TaskListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TaskListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskListResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskSummaryDto {
  final int pending;
  final int due;
  final int overdue;
  final int completedToday;
  final List<TaskTypeCountDto> byType;

  TaskSummaryDto({
    required this.pending,
    required this.due,
    required this.overdue,
    required this.completedToday,
    this.byType = const [],
  });

  factory TaskSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TaskSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskSummaryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskTypeCountDto {
  final String type;
  final int count;

  TaskTypeCountDto({
    required this.type,
    required this.count,
  });

  factory TaskTypeCountDto.fromJson(Map<String, dynamic> json) =>
      _$TaskTypeCountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskTypeCountDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PostTaskDto {
  final String title;
  final String? description;
  final String? taskType;
  final String? priority;
  final String? dueDate;
  final String? assignedTo;
  final String? litterUuid;
  final String? matingUuid;
  final String? animalUuid;
  final String? cageUuid;
  final String? protocolUuid;

  PostTaskDto({
    required this.title,
    this.description,
    this.taskType,
    this.priority,
    this.dueDate,
    this.assignedTo,
    this.litterUuid,
    this.matingUuid,
    this.animalUuid,
    this.cageUuid,
    this.protocolUuid,
  });

  factory PostTaskDto.fromJson(Map<String, dynamic> json) =>
      _$PostTaskDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostTaskDtoToJson(this);
}
