import 'package:json_annotation/json_annotation.dart';

part 'ai_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AiChatMessageDto {
  final String role;
  final String content;
  final String? createdAt;
  final String? chatUuid;

  AiChatMessageDto({
    required this.role,
    required this.content,
    this.createdAt,
    this.chatUuid,
  });

  factory AiChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatMessageDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AiChatHistoryItemDto {
  final String uuid;
  final String? userMessage;
  final String? aiResponse;
  final String? threadId;
  final String? runId;
  final String? assistantId;
  final String? createdAt;
  final String? updatedAt;

  AiChatHistoryItemDto({
    required this.uuid,
    this.userMessage,
    this.aiResponse,
    this.threadId,
    this.runId,
    this.assistantId,
    this.createdAt,
    this.updatedAt,
  });

  factory AiChatHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatHistoryItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatHistoryItemDtoToJson(this);
}
