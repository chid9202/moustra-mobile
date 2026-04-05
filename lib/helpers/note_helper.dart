import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';

class NoteHelper {
  static String getCreatorName(AccountDto? account) {
    if (account?.user == null) {
      return 'System';
    }
    final user = account!.user!;
    if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'Unknown';
  }

  static String getInitials(AccountDto? account) {
    if (account?.user == null) {
      return 'SY';
    }
    final user = account!.user!;
    if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
      final first = user.firstName[0].toUpperCase();
      final last = user.lastName[0].toUpperCase();
      return '$first$last';
    }
    return '?';
  }

  static Color stringToColor(String string) {
    int hash = 0;
    for (int i = 0; i < string.length; i++) {
      hash = string.codeUnitAt(i) + ((hash << 5) - hash);
    }
    String color = '#';
    for (int i = 0; i < 3; i++) {
      int value = (hash >> (i * 8)) & 0xFF;
      color += value.toRadixString(16).padLeft(2, '0');
    }
    return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
  }

  static String formatNoteDate(DateTime date) {
    return DateFormat('MMM d, yyyy, hh:mm a').format(date);
  }

  static final _mentionRegex = RegExp(
    r'@\[([^\]]+)\]\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)',
    caseSensitive: false,
  );

  /// Extract unique account UUIDs from @[Name](uuid) mentions in content.
  static List<String> extractMentionUuids(String content) {
    final uuids = <String>{};
    for (final match in _mentionRegex.allMatches(content)) {
      uuids.add(match.group(2)!);
    }
    return uuids.toList();
  }

  /// Build metadata map with mentions if any exist in the content.
  static Map<String, dynamic>? buildMentionMetadata(String content) {
    final uuids = extractMentionUuids(content);
    if (uuids.isEmpty) return null;
    return {'mentions': uuids};
  }

  /// Look up an account by UUID from the account store.
  static AccountStoreDto? getAccountByUuid(String uuid) {
    return accountStore.value
        ?.where((a) => a.accountUuid == uuid)
        .firstOrNull;
  }

  static String extractErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Try to extract error from response body if it's a structured error
    if (errorString.contains('Exception:')) {
      final message = errorString.replaceFirst('Exception: ', '');

      // Try to parse JSON error if present
      if (message.contains('{') && message.contains('}')) {
        try {
          final jsonStart = message.indexOf('{');
          final jsonEnd = message.lastIndexOf('}') + 1;
          if (jsonStart >= jsonEnd) {
            return message;
          }
          final jsonStr = message.substring(jsonStart, jsonEnd);
          final json = jsonDecode(jsonStr);

          // Try content validation error first
          if (json is Map<String, dynamic>) {
            if (json['content'] != null && json['content'] is List) {
              final contentErrors = json['content'] as List;
              if (contentErrors.isNotEmpty) {
                return contentErrors[0].toString();
              }
            }
            // Try general error message
            if (json['error'] != null) {
              return json['error'].toString();
            }
            if (json['message'] != null) {
              return json['message'].toString();
            }
          }
        } catch (e) {
          // If JSON parsing fails, continue with string extraction
        }
      }

      return message;
    }

    return errorString;
  }
}
