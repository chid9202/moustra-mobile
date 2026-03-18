import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/ai_dto.dart';

import 'ai_api_test.mocks.dart';

class TestableAiApi {
  final DioApiClient apiClient;

  TestableAiApi(this.apiClient);

  Future<List<AiChatHistoryItemDto>> getChatHistory() async {
    final res = await apiClient.get('/ai/chat/history');
    final decoded = res.data;

    List<dynamic> results;
    if (decoded is List) {
      results = decoded;
    } else if (decoded is Map<String, dynamic>) {
      results = decoded['results'] ?? [];
    } else {
      results = [];
    }
    return results
        .map((j) => AiChatHistoryItemDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<AiChatHistoryItemDto> submitFeedback(
    String chatUuid,
    bool? feedback,
    String? feedbackDetail,
  ) async {
    final res = await apiClient.put(
      '/ai/chat/$chatUuid/feedback',
      body: {
        'feedback': feedback,
        'feedback_detail': feedbackDetail,
      },
    );
    return AiChatHistoryItemDto.fromJson(res.data as Map<String, dynamic>);
  }
}

Map<String, dynamic> _sampleChatHistoryItem({
  String uuid = 'chat-uuid-1',
  String? userMessage = 'Hello',
  String? aiResponse = 'Hi there!',
}) =>
    {
      'uuid': uuid,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'threadId': 'thread-1',
      'runId': 'run-1',
      'assistantId': 'asst-1',
      'createdAt': '2025-06-01T10:00:00Z',
      'updatedAt': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('AiApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableAiApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableAiApi(mockApiClient);
    });

    group('getChatHistory', () {
      test('should return list when response is a List', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    _sampleChatHistoryItem(uuid: 'c1'),
                    _sampleChatHistoryItem(uuid: 'c2'),
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getChatHistory();

        expect(result.length, 2);
        expect(result.first.uuid, 'c1');
        expect(result.first.userMessage, 'Hello');
        verify(mockApiClient.get('/ai/chat/history',
                query: anyNamed('query')))
            .called(1);
      });

      test('should return list when response is a Map with results', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [
                      _sampleChatHistoryItem(uuid: 'c1'),
                    ],
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getChatHistory();

        expect(result.length, 1);
        expect(result.first.uuid, 'c1');
      });

      test('should return empty list for unexpected data type', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'unexpected',
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getChatHistory();

        expect(result, isEmpty);
      });
    });

    group('submitFeedback', () {
      test('should return updated chat history item', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleChatHistoryItem(uuid: 'chat-uuid-1'),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.submitFeedback(
          'chat-uuid-1',
          true,
          'Very helpful',
        );

        expect(result.uuid, 'chat-uuid-1');
        verify(mockApiClient.put(
          '/ai/chat/chat-uuid-1/feedback',
          body: {
            'feedback': true,
            'feedback_detail': 'Very helpful',
          },
          query: anyNamed('query'),
        )).called(1);
      });

      test('should handle null feedback values', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleChatHistoryItem(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.submitFeedback('chat-uuid-1', null, null);

        expect(result, isA<AiChatHistoryItemDto>());
        verify(mockApiClient.put(
          '/ai/chat/chat-uuid-1/feedback',
          body: {
            'feedback': null,
            'feedback_detail': null,
          },
          query: anyNamed('query'),
        )).called(1);
      });
    });
  });
}
