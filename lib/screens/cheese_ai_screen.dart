import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/ai_api.dart';
import 'package:moustra/services/dtos/ai_dto.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

class CheeseAiScreen extends StatefulWidget {
  const CheeseAiScreen({super.key});

  @override
  State<CheeseAiScreen> createState() => _CheeseAiScreenState();
}

const _suggestionPresets = [
  (icon: '\u{1F4CA}', label: 'Show my colony overview', message: 'Show me my colony overview'),
  (icon: '\u{1F42D}', label: 'Animals due for weaning', message: 'Show animals that are due for weaning'),
  (icon: '\u{1F9EC}', label: 'Colony breakdown by strain', message: 'Break down my colony by strain'),
  (icon: '\u{1F4CB}', label: 'Cages with low occupancy', message: 'Show cages with low occupancy'),
  (icon: '\u{1F9F9}', label: 'Cage consolidation plan', message: 'Generate a cage consolidation plan'),
  (icon: '\u{1F930}', label: 'Active pregnancies', message: 'Show active pregnancies and expected delivery dates'),
];

class _CheeseAiScreenState extends State<CheeseAiScreen> {
  final List<AiChatMessageDto> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isStreaming = false;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final items = await aiApi.getChatHistory();
      // Sort by createdAt ascending
      items.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));

      final messages = <AiChatMessageDto>[];
      for (final item in items) {
        if (item.userMessage != null && item.userMessage!.isNotEmpty) {
          messages.add(AiChatMessageDto(
            role: 'user',
            content: item.userMessage!,
            createdAt: item.createdAt,
            chatUuid: item.uuid,
          ));
        }
        if (item.aiResponse != null && item.aiResponse!.isNotEmpty) {
          messages.add(AiChatMessageDto(
            role: 'assistant',
            content: item.aiResponse!,
            createdAt: item.createdAt,
            chatUuid: item.uuid,
          ));
        }
      }

      if (mounted) {
        setState(() => _messages.addAll(messages));
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      if (mounted) {
        showAppSnackBar(context, 'Failed to load chat history', isError: true);
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _inputController.clear();
    });
  }

  void _handlePresetTap(String message) {
    _inputController.text = message;
    _handleSubmit();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _inputController.clear();

    setState(() {
      _messages.add(AiChatMessageDto(
        role: 'user',
        content: text,
        createdAt: DateTime.now().toIso8601String(),
      ));
      _isLoading = true;
      _isStreaming = true;
    });
    _scrollToBottom();

    try {
      final stream = aiApi.streamChat(text);
      final buffer = StringBuffer();

      _streamSubscription = stream.listen(
        (chunk) {
          buffer.write(chunk);
          setState(() {
            _isLoading = false;
            // Replace last assistant message or add new one
            if (_messages.isNotEmpty && _messages.last.role == 'assistant' &&
                _messages.last.chatUuid == null) {
              _messages[_messages.length - 1] = AiChatMessageDto(
                role: 'assistant',
                content: buffer.toString(),
                createdAt: DateTime.now().toIso8601String(),
              );
            } else {
              _messages.add(AiChatMessageDto(
                role: 'assistant',
                content: buffer.toString(),
                createdAt: DateTime.now().toIso8601String(),
              ));
            }
          });
          _scrollToBottom();
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isStreaming = false;
            });
          }
        },
        onError: (error) {
          debugPrint('Stream error: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isStreaming = false;
            });
            showAppSnackBar(context, 'Error: $error', isError: true);
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting stream: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isStreaming = false;
        });
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _submitFeedback(String chatUuid, bool isPositive) async {
    try {
      await aiApi.submitFeedback(chatUuid, isPositive, null);
      if (mounted) {
        showAppSnackBar(context, 'Feedback submitted');
      }
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      if (mounted) {
        showAppSnackBar(context, 'Error submitting feedback: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _messages.isEmpty && !_isLoading;

    return Column(
      children: [
        if (_messages.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: TextButton.icon(
                onPressed: _isStreaming ? null : _clearChat,
                icon: const Icon(Icons.add_comment_outlined, size: 18),
                label: const Text('New Chat'),
              ),
            ),
          ),
        Expanded(
          child: isEmpty
              ? _buildSuggestionPresets()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildMessage(_messages[index]);
                  },
                ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildSuggestionPresets() {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi! I\'m Cheese \u{1F9C0} \u2014 what can I help you with?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestionPresets.map((preset) {
                return ActionChip(
                  avatar: Text(preset.icon, style: const TextStyle(fontSize: 16)),
                  label: Text(preset.label),
                  onPressed: () => _handlePresetTap(preset.message),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(AiChatMessageDto message) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _formatTimestamp(message.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            if (!isUser && message.chatUuid != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _submitFeedback(message.chatUuid!, true),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.thumb_up_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _submitFeedback(message.chatUuid!, false),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.thumb_down_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: 'Ask something...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isStreaming ? null : _handleSubmit,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, h:mm a').format(date.toLocal());
    } catch (_) {
      return '';
    }
  }
}
