import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/ai_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class AiApi {
  Future<List<AiChatHistoryItemDto>> getChatHistory() async {
    final res = await dioApiClient.get('/ai/chat/history');
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
    final res = await dioApiClient.put(
      '/ai/chat/$chatUuid/feedback',
      body: {
        'feedback': feedback,
        'feedback_detail': feedbackDetail,
      },
    );
    return AiChatHistoryItemDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Execute an action proposal by calling the specified endpoint.
  Future<Map<String, dynamic>> executeAction(
      AiActionProposalDto action) async {
    final method = action.method.toUpperCase();
    final endpoint = action.endpoint;

    switch (method) {
      case 'POST':
        final res = await dioApiClient.post(endpoint, body: action.payload);
        return res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : {};
      case 'PUT':
        final res = await dioApiClient.put(endpoint, body: action.payload);
        return res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : {};
      case 'PATCH':
        final res = await dioApiClient.patch(endpoint, body: action.payload);
        return res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : {};
      case 'DELETE':
        final res = await dioApiClient.delete(endpoint);
        return res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : {};
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Send action result back to AI for multi-step workflow continuation.
  Future<void> sendActionResult({
    required String actionId,
    required bool success,
    Map<String, dynamic>? result,
    String? error,
    String? sessionId,
  }) async {
    await dioApiClient.post('/ai/action-result', body: {
      'action_id': actionId,
      'success': success,
      'result': result,
      'error': error,
      'session_id': sessionId,
    });
  }

  /// SSE streaming — returns typed events instead of raw strings.
  Stream<AiStreamEvent> streamChat(String prompt) async* {
    final token = authService.accessToken;
    final accountUuid = profileState.value?.accountUuid;
    if (token == null || accountUuid == null) {
      throw Exception('Not authenticated');
    }

    final encodedPrompt = Uri.encodeComponent(prompt);
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/account/$accountUuid/ai/stream?prompt=$encodedPrompt&token=$token',
    );

    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('SSE connection failed: ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (!line.startsWith('data: ')) continue;
          try {
            final data =
                jsonDecode(line.substring(6)) as Map<String, dynamic>;

            if (data['status'] == 'connected') continue;
            if (data['status'] == 'done') return;
            if (data['error'] != null) {
              throw Exception(data['error'].toString());
            }

            // Action proposal
            final action = data['action'];
            if (action != null) {
              yield AiActionEvent(
                AiActionProposalDto.fromJson(action as Map<String, dynamic>),
              );
              continue;
            }

            // Tool status
            final toolStatus = data['tool_status'];
            if (toolStatus != null) {
              yield AiToolStatusEvent(toolStatus as String);
              continue;
            }

            // V2: token-by-token streaming
            final tokenValue = data['token'];
            if (tokenValue != null) {
              yield AiTokenEvent(tokenValue as String);
              continue;
            }

            // V1 legacy: full content in one event
            final content = data['content'];
            if (content != null) {
              yield AiTokenEvent(content as String);
            }
          } on FormatException {
            // Partial SSE line, not valid JSON yet — skip
            continue;
          }
        }
      }
    } finally {
      client.close();
    }
  }
}

final AiApi aiApi = AiApi();
