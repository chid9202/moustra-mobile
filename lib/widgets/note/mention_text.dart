import 'package:flutter/material.dart';
import 'package:moustra/stores/account_store.dart';

/// Regex to match @[Display Name](account_uuid) mention format.
final _mentionRegex = RegExp(
  r'@\[([^\]]+)\]\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)',
  caseSensitive: false,
);

/// Renders note content with @mentions highlighted as tappable blue text.
/// Tapping a mention shows a tooltip with the user's full name and email.
class MentionText extends StatelessWidget {
  final String content;
  final TextStyle? style;

  const MentionText({
    super.key,
    required this.content,
    this.style,
  });

  String _getAccountTooltip(String uuid, String displayName) {
    final accounts = accountStore.value;
    if (accounts == null) return displayName;

    final account = accounts
        .where((a) => a.accountUuid == uuid)
        .firstOrNull;

    if (account == null) return displayName;

    final name =
        '${account.user.firstName} ${account.user.lastName}'.trim();
    final email = account.user.email ?? '';
    if (email.isNotEmpty) return '$name\n$email';
    return name.isNotEmpty ? name : displayName;
  }

  List<InlineSpan> _buildSpans(BuildContext context) {
    final spans = <InlineSpan>[];
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final mentionStyle = baseStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    int lastIndex = 0;

    for (final match in _mentionRegex.allMatches(content)) {
      // Add plain text before this mention
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final displayName = match.group(1)!;
      final uuid = match.group(2)!;
      final tooltipText = _getAccountTooltip(uuid, displayName);

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Tooltip(
          message: tooltipText,
          preferBelow: true,
          child: Text(
            '@$displayName',
            style: mentionStyle,
          ),
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastIndex),
        style: baseStyle,
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: content, style: baseStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (!_mentionRegex.hasMatch(content)) {
      return Text(content, style: style);
    }

    return Text.rich(
      TextSpan(children: _buildSpans(context)),
    );
  }
}
