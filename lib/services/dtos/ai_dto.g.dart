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
      action: json['action'] == null
          ? null
          : AiActionProposalDto.fromJson(
              json['action'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AiChatMessageDtoToJson(AiChatMessageDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'chatUuid': instance.chatUuid,
      'action': instance.action?.toJson(),
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

AiActionProposalDto _$AiActionProposalDtoFromJson(Map<String, dynamic> json) =>
    AiActionProposalDto(
      id: json['id'] as String,
      type: json['type'] as String,
      entity: json['entity'] as String,
      description: json['description'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AiActionProposalDtoToJson(
  AiActionProposalDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'entity': instance.entity,
  'description': instance.description,
  'endpoint': instance.endpoint,
  'method': instance.method,
  'payload': instance.payload,
};
