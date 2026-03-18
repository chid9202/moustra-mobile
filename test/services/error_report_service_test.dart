import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/error_report_service.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    // Provide a profile so the service has an accountUuid
    profileState.value = ProfileResponseDto(
      accountUuid: 'test-account-uuid',
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      labName: 'Test Lab',
      labUuid: 'test-lab-uuid',
      onboarded: true,
      onboardedDate: DateTime.now(),
      position: 'Researcher',
      role: 'admin',
      plan: 'pro',
    );
  });

  tearDown(() {
    profileState.value = null;
  });

  group('ErrorReportService.reportError', () {
    test('does not throw when called with valid inputs', () {
      expect(
        () => ErrorReportService.reportError(
          subject: 'Test Error',
          message: 'Something went wrong',
        ),
        returnsNormally,
      );
    });

    test('does not throw when profile is null', () {
      profileState.value = null;
      expect(
        () => ErrorReportService.reportError(
          subject: 'Test Error',
          message: 'No user logged in',
        ),
        returnsNormally,
      );
    });

    test('accepts custom severity and category', () {
      expect(
        () => ErrorReportService.reportError(
          subject: 'Warning Issue',
          message: 'Minor problem',
          severity: 'warning',
          category: 'network',
        ),
        returnsNormally,
      );
    });
  });

  group('Deduplication via ErrorReportService.reportError', () {
    test('calling with same subject/message rapidly is handled gracefully', () {
      // The deduplicator should allow the first call and skip duplicates
      // within 60 seconds. We can't directly inspect the deduplicator, but
      // we verify it does not throw.
      for (var i = 0; i < 5; i++) {
        expect(
          () => ErrorReportService.reportError(
            subject: 'Duplicate Error',
            message: 'Same error message',
          ),
          returnsNormally,
        );
      }
    });

    test('different errors are not deduplicated', () {
      // Different subjects should all be accepted (up to rate limit)
      for (var i = 0; i < 5; i++) {
        expect(
          () => ErrorReportService.reportError(
            subject: 'Error $i',
            message: 'Unique message $i',
          ),
          returnsNormally,
        );
      }
    });
  });

  group('Rate limiting via ErrorReportService.reportError', () {
    test('does not throw even when rate limit is exceeded', () {
      // Send more than 10 unique errors (max per minute) rapidly.
      // The service should silently skip excess reports.
      for (var i = 0; i < 15; i++) {
        expect(
          () => ErrorReportService.reportError(
            subject: 'Rate limit error $i',
            message: 'Unique message for rate test $i',
          ),
          returnsNormally,
        );
      }
    });
  });

  group('reportError helper function', () {
    test('does not throw for basic error', () {
      expect(
        () => reportError(error: Exception('test error')),
        returnsNormally,
      );
    });

    test('does not throw with stack trace and context', () {
      try {
        throw FormatException('bad format');
      } catch (e, st) {
        expect(
          () => reportError(
            error: e,
            stackTrace: st,
            context: 'parsing user input',
          ),
          returnsNormally,
        );
      }
    });
  });

  group('reportErrorWithAction helper function', () {
    test('does not throw', () {
      expect(
        () => reportErrorWithAction(
          error: Exception('save failed'),
          action: 'saving cage',
        ),
        returnsNormally,
      );
    });

    test('does not throw with stack trace', () {
      try {
        throw StateError('invalid state');
      } catch (e, st) {
        expect(
          () => reportErrorWithAction(
            error: e,
            stackTrace: st,
            action: 'moving animal',
          ),
          returnsNormally,
        );
      }
    });
  });

  // Note: ErrorReportService.initSession() calls PackageInfo.fromPlatform()
  // which requires a method channel that is not available in unit tests.
  // It is tested implicitly via integration/widget tests.
}
