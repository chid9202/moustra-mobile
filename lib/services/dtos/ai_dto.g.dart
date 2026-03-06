// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatMessageDto _$AiChatMessageDtoFromJson(Map<String, dynamic> json) =>
    AiChatMessageDto(
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String?,
      chatUuid: json['chatUuid'] as String?,
    );

Map<String, dynamic> _$AiChatMessageDtoToJson(AiChatMessageDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'chatUuid': instance.chatUuid,
    };

AiChatHistoryItemDto _$AiChatHistoryItemDtoFromJson(
  Map<String, dynamic> json,
) => AiChatHistoryItemDto(
  uuid: json['uuid'] as String,
  userMessage: json['userMessage'] as String?,
  aiResponse: json['aiResponse'] as String?,
  threadId: json['threadId'] as String?,
  runId: json['runId'] as String?,
  assistantId: json['assistantId'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$AiChatHistoryItemDtoToJson(
  AiChatHistoryItemDto instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'userMessage': instance.userMessage,
  'aiResponse': instance.aiResponse,
  'threadId': instance.threadId,
  'runId': instance.runId,
  'assistantId': instance.assistantId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
