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

  /// SSE streaming — kept on package:http because Dio doesn't natively
  /// support server-sent events with the same ease.
  Stream<String> streamChat(String prompt) async* {
    final token = authService.accessToken;
    final accountUuid = profileState.value?.accountUuid;
    if (token == null || accountUuid == null) {
      throw Exception('Not authenticated');
    }

    final encodedPrompt = Uri.encodeComponent(prompt);
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/account/$accountUuid/ai/stream?prompt=$encodedPrompt&token=$token',
    );

    final request = http.Request('GET', uri);
    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      throw Exception('SSE connection failed: ${response.statusCode}');
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        if (!line.startsWith('data: ')) continue;
        try {
          final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;

          if (data['status'] == 'connected') continue;
          if (data['status'] == 'done') return;
          if (data['error'] != null) {
            throw Exception(data['error'].toString());
          }

          // V2: token-by-token streaming
          final token = data['token'];
          if (token != null) {
            yield token as String;
            continue;
          }

          // V1 legacy: full content in one event
          final content = data['content'];
          if (content != null) {
            yield content as String;
          }
        } catch (e) {
          if (e is Exception &&
              e.toString().contains('SSE') == false &&
              e.toString().contains('Error') == false) {
            // JSON parse error on partial line, skip
            continue;
          }
          rethrow;
        }
      }
    }
  }
}

final AiApi aiApi = AiApi();
