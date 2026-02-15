import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:moustra/services/clients/api_client.dart';

class EventApi {
  /// Fire-and-forget event tracking.
  /// Never interrupts UX — errors are silently ignored.
  void trackEvent(String eventName) {
    final source = Platform.isIOS ? 'iOS' : 'Android';
    try {
      apiClient.post(
        '/event',
        body: {
          'eventName': eventName,
          'source': source,
        },
      );
    } catch (e) {
      debugPrint('Event tracking error: $e');
    }
  }
}

final EventApi eventApi = EventApi();
