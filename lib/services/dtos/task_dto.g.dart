// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDto _$TaskDtoFromJson(Map<String, dynamic> json) => TaskDto(
  taskUuid: json['taskUuid'] as String,
  taskType: json['taskType'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  snoozeUntil: json['snoozeUntil'] == null
      ? null
      : DateTime.parse(json['snoozeUntil'] as String),
  assignedToUuid: json['assignedToUuid'] as String?,
  assignedToName: json['assignedToName'] as String?,
  entityType: json['entityType'] as String?,
  entityUuid: json['entityUuid'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdDate: DateTime.parse(json['createdDate'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$TaskDtoToJson(TaskDto instance) => <String, dynamic>{
  'taskUuid': instance.taskUuid,
  'taskType': instance.taskType,
  'status': instance.status,
  'priority': instance.priority,
  'title': instance.title,
  'description': instance.description,
  'dueDate': instance.dueDate?.toIso8601String(),
  'snoozeUntil': instance.snoozeUntil?.toIso8601String(),
  'assignedToUuid': instance.assignedToUuid,
  'assignedToName': instance.assignedToName,
  'entityType': instance.entityType,
  'entityUuid': instance.entityUuid,
  'metadata': instance.metadata,
  'createdDate': instance.createdDate.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

TaskListResponseDto _$TaskListResponseDtoFromJson(Map<String, dynamic> json) =>
    TaskListResponseDto(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TaskListResponseDtoToJson(
  TaskListResponseDto instance,
) => <String, dynamic>{
  'tasks': instance.tasks.map((e) => e.toJson()).toList(),
  'total': instance.total,
};

TaskSummaryDto _$TaskSummaryDtoFromJson(Map<String, dynamic> json) =>
    TaskSummaryDto(
      pending: (json['pending'] as num).toInt(),
      due: (json['due'] as num).toInt(),
      overdue: (json['overdue'] as num).toInt(),
      completedToday: (json['completedToday'] as num).toInt(),
      byType:
          (json['byType'] as List<dynamic>?)
              ?.map((e) => TaskTypeCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TaskSummaryDtoToJson(TaskSummaryDto instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'due': instance.due,
      'overdue': instance.overdue,
      'completedToday': instance.completedToday,
      'byType': instance.byType.map((e) => e.toJson()).toList(),
    };

TaskTypeCountDto _$TaskTypeCountDtoFromJson(Map<String, dynamic> json) =>
    TaskTypeCountDto(
      type: json['type'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$TaskTypeCountDtoToJson(TaskTypeCountDto instance) =>
    <String, dynamic>{'type': instance.type, 'count': instance.count};

PostTaskDto _$PostTaskDtoFromJson(Map<String, dynamic> json) => PostTaskDto(
  title: json['title'] as String,
  description: json['description'] as String?,
  taskType: json['taskType'] as String?,
  priority: json['priority'] as String?,
  dueDate: json['dueDate'] as String?,
  assignedTo: json['assignedTo'] as String?,
  litterUuid: json['litterUuid'] as String?,
  matingUuid: json['matingUuid'] as String?,
  animalUuid: json['animalUuid'] as String?,
  cageUuid: json['cageUuid'] as String?,
  protocolUuid: json['protocolUuid'] as String?,
);

Map<String, dynamic> _$PostTaskDtoToJson(PostTaskDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': ?instance.description,
      'taskType': ?instance.taskType,
      'priority': ?instance.priority,
      'dueDate': ?instance.dueDate,
      'assignedTo': ?instance.assignedTo,
      'litterUuid': ?instance.litterUuid,
      'matingUuid': ?instance.matingUuid,
      'animalUuid': ?instance.animalUuid,
      'cageUuid': ?instance.cageUuid,
      'protocolUuid': ?instance.protocolUuid,
    };
