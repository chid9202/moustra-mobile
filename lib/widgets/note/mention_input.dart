import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';

/// Tracks a mention's position in the display text.
class _MentionData {
  final String displayName;
  final String uuid;
  int startIndex; // position of '@' in display text

  _MentionData({
    required this.displayName,
    required this.uuid,
    required this.startIndex,
  });

  int get length => displayName.length + 1; // +1 for '@'
  int get endIndex => startIndex + length;
}

final _mentionMarkupRegex = RegExp(
  r'@\[([^\]]+)\]\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)',
  caseSensitive: false,
);

/// A TextField with @mention typeahead support.
/// Displays `@Name` in the text field while storing `@[Name](uuid)` markup.
class MentionInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;
  final int maxLines;
  final bool autofocus;
  final bool enabled;
  final InputDecoration? decoration;

  const MentionInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Enter note content... Type @ to mention someone',
    this.maxLines = 4,
    this.autofocus = false,
    this.enabled = true,
    this.decoration,
  });

  @override
  State<MentionInput> createState() => _MentionInputState();
}

class _MentionInputState extends State<MentionInput> {
  late TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<AccountStoreDto> _suggestions = [];
  int _selectedIndex = 0;
  int? _mentionStartPos;
  List<_MentionData> _mentions = [];
  bool _ignoreNextChange = false;

  @override
  void initState() {
    super.initState();
    // Parse initial value: convert markup to display text
    final parsed = _parseMarkupToDisplay(widget.value);
    _mentions = parsed.mentions;
    _controller = TextEditingController(text: parsed.displayText);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(MentionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      // Only update if the markup value actually changed externally
      final currentMarkup = _buildMarkupFromDisplay();
      if (widget.value != currentMarkup) {
        _ignoreNextChange = true;
        final parsed = _parseMarkupToDisplay(widget.value);
        _mentions = parsed.mentions;
        _controller.text = parsed.displayText;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        _ignoreNextChange = false;
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Parse `@[Name](uuid)` markup into display text and mention data list.
  static _ParseResult _parseMarkupToDisplay(String markup) {
    final mentions = <_MentionData>[];
    final buffer = StringBuffer();
    int lastIndex = 0;

    for (final match in _mentionMarkupRegex.allMatches(markup)) {
      // Add text before this mention
      buffer.write(markup.substring(lastIndex, match.start));

      final displayName = match.group(1)!;
      final uuid = match.group(2)!;
      final startIndex = buffer.length;

      // Write display format: @Name
      buffer.write('@$displayName');

      mentions.add(_MentionData(
        displayName: displayName,
        uuid: uuid,
        startIndex: startIndex,
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    buffer.write(markup.substring(lastIndex));

    return _ParseResult(
      displayText: buffer.toString(),
      mentions: mentions,
    );
  }

  /// Convert display text + mention data back to markup format.
  String _buildMarkupFromDisplay() {
    if (_mentions.isEmpty) return _controller.text;

    final text = _controller.text;
    final buffer = StringBuffer();
    int lastIndex = 0;

    // Sort mentions by position
    final sorted = List<_MentionData>.from(_mentions)
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    for (final mention in sorted) {
      if (mention.startIndex < lastIndex || mention.endIndex > text.length) {
        continue;
      }
      buffer.write(text.substring(lastIndex, mention.startIndex));
      buffer.write('@[${mention.displayName}](${mention.uuid})');
      lastIndex = mention.endIndex;
    }

    buffer.write(text.substring(lastIndex));
    return buffer.toString();
  }

  void _onTextChanged() {
    if (_ignoreNextChange) return;

    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;

    // Remove mentions that were edited/broken
    _mentions.removeWhere((mention) {
      if (mention.startIndex >= text.length) return true;
      if (mention.endIndex > text.length) return true;
      final currentText =
          text.substring(mention.startIndex, mention.endIndex);
      return currentText != '@${mention.displayName}';
    });

    // Notify parent with markup value
    widget.onChanged(_buildMarkupFromDisplay());

    if (cursorPos < 0) return;

    // Detect @ trigger for mention dropdown
    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex >= 0) {
      // Check that @ is at start or preceded by space/newline
      final charBefore =
          lastAtIndex > 0 ? textBeforeCursor[lastAtIndex - 1] : ' ';
      if (charBefore == ' ' || charBefore == '\n' || lastAtIndex == 0) {
        final query = textBeforeCursor.substring(lastAtIndex + 1);
        if (!query.contains('\n')) {
          // Check this isn't inside an existing mention
          final inMention = _mentions.any((m) =>
              lastAtIndex >= m.startIndex && lastAtIndex < m.endIndex);
          if (!inMention) {
            _mentionStartPos = lastAtIndex;
            _filterSuggestions(query);
            return;
          }
        }
      }
    }

    _mentionStartPos = null;
    _removeOverlay();
  }

  void _filterSuggestions(String query) {
    final accounts = accountStore.value;
    if (accounts == null || accounts.isEmpty) {
      _removeOverlay();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = accounts.where((account) {
      final firstName = account.user.firstName.toLowerCase();
      final lastName = account.user.lastName.toLowerCase();
      final email = (account.user.email ?? '').toLowerCase();
      final fullName = '$firstName $lastName';
      return firstName.contains(lowerQuery) ||
          lastName.contains(lowerQuery) ||
          email.contains(lowerQuery) ||
          fullName.contains(lowerQuery);
    }).toList();

    if (filtered.isEmpty) {
      _removeOverlay();
      return;
    }

    _suggestions = filtered;
    _selectedIndex = 0;
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 280,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final account = _suggestions[index];
                  final name =
                      '${account.user.firstName} ${account.user.lastName}'
                          .trim();
                  final isSelected = index == _selectedIndex;

                  return InkWell(
                    onTap: () => _selectMention(account),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (account.user.email != null &&
                              account.user.email!.isNotEmpty)
                            Text(
                              account.user.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectMention(AccountStoreDto account) {
    if (_mentionStartPos == null) return;

    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    final displayName =
        '${account.user.firstName} ${account.user.lastName}'.trim();
    final mentionDisplay = '@$displayName ';

    final before = text.substring(0, _mentionStartPos!);
    final after = text.substring(cursorPos);
    final newText = '$before$mentionDisplay$after';

    // Calculate how much text shifted for existing mentions after this position
    final oldLength = cursorPos - _mentionStartPos!;
    final shift = mentionDisplay.length - oldLength;

    // Update positions of mentions that come after the insertion point
    for (final m in _mentions) {
      if (m.startIndex >= _mentionStartPos!) {
        m.startIndex += shift;
      }
    }

    // Add the new mention
    _mentions.add(_MentionData(
      displayName: displayName,
      uuid: account.accountUuid,
      startIndex: _mentionStartPos!,
    ));

    _ignoreNextChange = true;
    _controller.text = newText;
    final newCursorPos = _mentionStartPos! + mentionDisplay.length;
    _controller.selection = TextSelection.collapsed(offset: newCursorPos);
    _ignoreNextChange = false;

    // Notify parent with markup value
    widget.onChanged(_buildMarkupFromDisplay());

    _mentionStartPos = null;
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
            ),
        maxLines: widget.maxLines,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
      ),
    );
  }
}

class _ParseResult {
  final String displayText;
  final List<_MentionData> mentions;

  _ParseResult({required this.displayText, required this.mentions});
}
