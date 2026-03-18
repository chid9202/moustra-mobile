import 'dart:io';

import 'package:moustra/services/clients/dio_api_client.dart';

class EventApi {
  /// Fire-and-forget event tracking.
  /// Never interrupts UX — errors are silently ignored.
  void trackEvent(String eventName) {
    final source = Platform.isIOS ? 'iOS' : 'Android';
    try {
      dioApiClient.post(
        '/event',
        body: {
          'eventName': 'mobile_$eventName',
          'source': source,
        },
      );
    } catch (_) {
      // Fire-and-forget: silently ignore tracking errors
    }
  }
}

final EventApi eventApi = EventApi();
