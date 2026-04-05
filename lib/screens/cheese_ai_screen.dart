import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/ai_api.dart';
import 'package:moustra/services/dtos/ai_dto.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/event_api.dart';

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
  bool _isLoadingHistory = true;
  String? _toolStatus;
  StreamSubscription<AiStreamEvent>? _streamSubscription;

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

  Future<void> _loadHistory({bool showEmptyNotice = false}) async {
    setState(() => _isLoadingHistory = true);
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
        if (messages.isEmpty && showEmptyNotice) {
          showAppSnackBar(context, 'No previous chat found');
          return;
        }
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      if (mounted) {
        showAppSnackBar(context, 'Failed to load chat history', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _inputController.clear();
      _toolStatus = null;
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
    eventApi.trackEvent('cheese_ai_send');

    _inputController.clear();

    setState(() {
      _messages.add(AiChatMessageDto(
        role: 'user',
        content: text,
        createdAt: DateTime.now().toIso8601String(),
      ));
      _isLoading = true;
      _isStreaming = true;
      _toolStatus = null;
    });
    _scrollToBottom();

    try {
      final stream = aiApi.streamChat(text);
      final buffer = StringBuffer();

      _streamSubscription = stream.listen(
        (event) {
          switch (event) {
            case AiTokenEvent():
              buffer.write(event.token);
              setState(() {
                _isLoading = false;
                _toolStatus = null;
                // Replace last assistant message or add new one
                if (_messages.isNotEmpty &&
                    _messages.last.role == 'assistant' &&
                    _messages.last.chatUuid == null &&
                    _messages.last.action == null) {
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

            case AiActionEvent():
              setState(() {
                _isLoading = false;
                _toolStatus = null;
                _messages.add(AiChatMessageDto(
                  role: 'assistant',
                  content: event.action.description,
                  createdAt: DateTime.now().toIso8601String(),
                  action: event.action,
                ));
              });
              _scrollToBottom();

            case AiToolStatusEvent():
              setState(() {
                _toolStatus = event.status;
              });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isStreaming = false;
              _toolStatus = null;
            });
          }
        },
        onError: (error) {
          debugPrint('Stream error: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isStreaming = false;
              _toolStatus = null;
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
          _toolStatus = null;
        });
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _handleConfirmAction(int messageIndex) async {
    final message = _messages[messageIndex];
    final action = message.action;
    if (action == null) return;

    // Update to loading state
    setState(() {
      _messages[messageIndex] = AiChatMessageDto(
        role: 'assistant',
        content: '${action.description}\n\nExecuting...',
        createdAt: message.createdAt,
        action: action,
      );
    });

    try {
      final result = await aiApi.executeAction(action);

      if (mounted) {
        setState(() {
          _messages[messageIndex] = AiChatMessageDto(
            role: 'assistant',
            content: '${action.description}\n\nAction completed successfully.',
            createdAt: message.createdAt,
            chatUuid: message.chatUuid,
          );
        });
      }

      // Send result back to AI for continuation
      try {
        await aiApi.sendActionResult(
          actionId: action.id,
          success: true,
          result: result,
        );
      } catch (e) {
        debugPrint('Error sending action result: $e');
      }
    } catch (e) {
      debugPrint('Error executing action: $e');
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        setState(() {
          _messages[messageIndex] = AiChatMessageDto(
            role: 'assistant',
            content: '${action.description}\n\nFailed: $errorMsg',
            createdAt: message.createdAt,
            action: action,
          );
        });
        showAppSnackBar(context, 'Action failed', isError: true);
      }
    }
  }

  void _handleCancelAction(int messageIndex) {
    final message = _messages[messageIndex];
    final action = message.action;
    if (action == null) return;

    setState(() {
      _messages[messageIndex] = AiChatMessageDto(
        role: 'assistant',
        content: '${action.description}\n\nCancelled.',
        createdAt: message.createdAt,
        chatUuid: message.chatUuid,
      );
    });
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
          child: _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : isEmpty
              ? _buildSuggestionPresets()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length +
                      (_isLoading ? 1 : 0) +
                      (_toolStatus != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Tool status indicator
                    if (_toolStatus != null && index == _messages.length) {
                      return _buildToolStatus(_toolStatus!);
                    }
                    // Loading spinner
                    if (index >= _messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final message = _messages[index];
                    if (message.action != null) {
                      return _buildActionCard(message, index);
                    }
                    return _buildMessage(message);
                  },
                ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildToolStatus(String status) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(AiChatMessageDto message, int index) {
    final action = message.action!;
    final theme = Theme.of(context);
    final isCompleted = message.content.contains('completed successfully');
    final isCancelled = message.content.contains('Cancelled');
    final isFailed = message.content.contains('Failed:');
    final isExecuting = message.content.contains('Executing...');
    final isPending = !isCompleted && !isCancelled && !isFailed && !isExecuting;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? Colors.green
              : isFailed
                  ? Colors.red
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + entity chips
            Row(
              children: [
                _buildChip(
                  action.type,
                  action.type == 'create'
                      ? Colors.green
                      : action.type == 'update'
                          ? Colors.blue
                          : Colors.red,
                ),
                const SizedBox(width: 6),
                _buildChip(action.entity, theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              action.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            // Payload preview (only when pending)
            if (isPending && action.payload.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _getDisplayPayload(action).entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              e.value is Map || e.value is List
                                  ? jsonEncode(e.value)
                                  : '${e.value}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            // Status messages
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Action completed successfully',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.green),
                    ),
                  ],
                ),
              ),
            if (isFailed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        message.content
                            .split('Failed: ')
                            .last,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Action cancelled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            if (isExecuting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            // Confirm / Cancel buttons
            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _handleCancelAction(index),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _handleConfirmAction(index),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDisplayPayload(AiActionProposalDto action) {
    // Unwrap animals array for display
    if (action.entity == 'animal' && action.payload.containsKey('animals')) {
      final animals = action.payload['animals'];
      if (animals is List && animals.isNotEmpty) {
        return Map<String, dynamic>.from(animals[0] as Map);
      }
    }
    return action.payload;
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
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
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _loadHistory(showEmptyNotice: true),
              icon: Icon(
                Icons.history,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              label: Text(
                'Load previous chat',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
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
