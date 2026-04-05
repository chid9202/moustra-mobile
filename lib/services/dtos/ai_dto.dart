import 'package:json_annotation/json_annotation.dart';

part 'ai_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AiChatMessageDto {
  final String role;
  final String content;
  final String? createdAt;
  final String? chatUuid;
  final AiActionProposalDto? action;

  AiChatMessageDto({
    required this.role,
    required this.content,
    this.createdAt,
    this.chatUuid,
    this.action,
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

@JsonSerializable(explicitToJson: true)
class AiActionProposalDto {
  final String id;
  final String type;
  final String entity;
  final String description;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;

  AiActionProposalDto({
    required this.id,
    required this.type,
    required this.entity,
    required this.description,
    required this.endpoint,
    required this.method,
    required this.payload,
  });

  factory AiActionProposalDto.fromJson(Map<String, dynamic> json) =>
      _$AiActionProposalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AiActionProposalDtoToJson(this);
}

/// Typed SSE stream events from the AI backend.
sealed class AiStreamEvent {}

class AiTokenEvent extends AiStreamEvent {
  final String token;
  AiTokenEvent(this.token);
}

class AiActionEvent extends AiStreamEvent {
  final AiActionProposalDto action;
  AiActionEvent(this.action);
}

class AiToolStatusEvent extends AiStreamEvent {
  final String status;
  AiToolStatusEvent(this.status);
}
