import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/ai_dto.dart';

void main() {
  group('AiChatMessageDto', () {
    test('fromJson with complete data', () {
      final json = {
        'role': 'user',
        'content': 'How many animals do I have?',
        'createdAt': '2024-01-01T00:00:00Z',
        'chatUuid': 'chat-uuid-1',
      };

      final dto = AiChatMessageDto.fromJson(json);

      expect(dto.role, equals('user'));
      expect(dto.content, equals('How many animals do I have?'));
      expect(dto.createdAt, equals('2024-01-01T00:00:00Z'));
      expect(dto.chatUuid, equals('chat-uuid-1'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'role': 'assistant',
        'content': 'You have 42 animals.',
      };

      final dto = AiChatMessageDto.fromJson(json);

      expect(dto.role, equals('assistant'));
      expect(dto.content, equals('You have 42 animals.'));
      expect(dto.createdAt, isNull);
      expect(dto.chatUuid, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'role': 'user',
        'content': 'Test message',
        'createdAt': '2024-01-01T00:00:00Z',
        'chatUuid': 'chat-uuid-1',
      };

      final dto = AiChatMessageDto.fromJson(json);
      final output = dto.toJson();

      expect(output['role'], equals(json['role']));
      expect(output['content'], equals(json['content']));
      expect(output['createdAt'], equals(json['createdAt']));
      expect(output['chatUuid'], equals(json['chatUuid']));
    });
  });

  group('AiChatHistoryItemDto', () {
    test('fromJson with complete data', () {
      final json = {
        'uuid': 'history-uuid-1',
        'userMessage': 'How many cages?',
        'aiResponse': 'You have 10 cages.',
        'threadId': 'thread-1',
        'runId': 'run-1',
        'assistantId': 'assistant-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:01:00Z',
      };

      final dto = AiChatHistoryItemDto.fromJson(json);

      expect(dto.uuid, equals('history-uuid-1'));
      expect(dto.userMessage, equals('How many cages?'));
      expect(dto.aiResponse, equals('You have 10 cages.'));
      expect(dto.threadId, equals('thread-1'));
      expect(dto.runId, equals('run-1'));
      expect(dto.assistantId, equals('assistant-1'));
      expect(dto.createdAt, equals('2024-01-01T00:00:00Z'));
      expect(dto.updatedAt, equals('2024-01-01T00:01:00Z'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'uuid': 'history-uuid-1',
      };

      final dto = AiChatHistoryItemDto.fromJson(json);

      expect(dto.uuid, equals('history-uuid-1'));
      expect(dto.userMessage, isNull);
      expect(dto.aiResponse, isNull);
      expect(dto.threadId, isNull);
      expect(dto.runId, isNull);
      expect(dto.assistantId, isNull);
      expect(dto.createdAt, isNull);
      expect(dto.updatedAt, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'uuid': 'history-uuid-1',
        'userMessage': 'Test',
        'aiResponse': 'Response',
        'threadId': 'thread-1',
        'runId': 'run-1',
        'assistantId': 'assistant-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:01:00Z',
      };

      final dto = AiChatHistoryItemDto.fromJson(json);
      final output = dto.toJson();

      expect(output['uuid'], equals(json['uuid']));
      expect(output['userMessage'], equals(json['userMessage']));
      expect(output['aiResponse'], equals(json['aiResponse']));
    });
  });
}
