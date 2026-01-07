import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/dtos/account_dto.dart';

class NoteHelper {
  static String getCreatorName(AccountDto account) {
    if (account.user.firstName.isNotEmpty &&
        account.user.lastName.isNotEmpty) {
      return '${account.user.firstName} ${account.user.lastName}';
    }
    return 'Unknown';
  }

  static String getInitials(AccountDto account) {
    if (account.user.firstName.isNotEmpty &&
        account.user.lastName.isNotEmpty) {
      final first = account.user.firstName[0].toUpperCase();
      final last = account.user.lastName[0].toUpperCase();
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

