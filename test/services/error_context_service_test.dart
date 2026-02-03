import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

void main() {
  group('ErrorContextService', () {
    // Use the singleton instance for all tests
    final service = errorContextService;

    setUp(() {
      // Clear state before each test
      service.clear();
      profileState.value = null;
    });

    tearDown(() {
      service.clear();
      profileState.value = null;
    });

    group('Navigation tracking', () {
      test('records navigation breadcrumbs', () {
        service.recordNavigation(route: '/dashboard', screenName: 'Dashboard');
        service.recordNavigation(route: '/cage/list', screenName: 'Cage List');
        service.recordNavigation(
          route: '/cage/abc123',
          screenName: 'Cage Detail',
          params: {'cageUuid': 'abc123'},
        );

        expect(service.breadcrumbs.length, 3);
        expect(service.breadcrumbs[0].route, '/dashboard');
        expect(service.breadcrumbs[1].route, '/cage/list');
        expect(service.breadcrumbs[2].route, '/cage/abc123');
        expect(service.breadcrumbs[2].params['cageUuid'], 'abc123');
      });

      test('limits breadcrumbs to maxBreadcrumbs', () {
        // Add more than max breadcrumbs
        for (var i = 0; i < 15; i++) {
          service.recordNavigation(route: '/screen$i', screenName: 'Screen $i');
        }

        expect(service.breadcrumbs.length, ErrorContextService.maxBreadcrumbs);
        // Oldest should be removed
        expect(service.breadcrumbs.first.route, '/screen5');
        expect(service.breadcrumbs.last.route, '/screen14');
      });

      test('updates currentRoute on navigation', () {
        service.recordNavigation(route: '/dashboard', screenName: 'Dashboard');
        expect(service.currentRoute, '/dashboard');

        service.recordNavigation(route: '/cage/list', screenName: 'Cage List');
        expect(service.currentRoute, '/cage/list');
      });

      test('auto-detects selected items from route params', () {
        service.recordNavigation(
          route: '/cage/abc123',
          screenName: 'Cage Detail',
          params: {'cageUuid': 'abc123'},
        );

        final context = service.buildAppStateContext();
        expect(context, contains('Cage: abc123'));
      });
    });

    group('User context', () {
      test('handles logged out state', () {
        profileState.value = null;
        final context = service.buildUserContext();
        expect(context, 'User: Not logged in');
      });

      test('includes user info when logged in', () {
        profileState.value = ProfileResponseDto(
          accountUuid: 'user-123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          labName: 'Test Lab',
          labUuid: 'lab-456',
          onboarded: true,
          onboardedDate: DateTime.now(),
          position: 'Researcher',
          role: 'admin',
          plan: 'pro',
        );

        final context = service.buildUserContext();
        expect(context, contains('user-123'));
        expect(context, contains('john@example.com'));
        expect(context, contains('Test Lab'));
        expect(context, contains('admin'));
        expect(context, contains('Researcher'));
      });
    });

    group('Navigation context', () {
      test('builds navigation context with breadcrumbs', () {
        service.recordNavigation(route: '/dashboard', screenName: 'Dashboard');
        service.recordNavigation(route: '/cage/list', screenName: 'Cage List');
        service.recordNavigation(
          route: '/cage/abc123',
          screenName: 'Cage Detail',
        );

        final context = service.buildNavigationContext();
        expect(context, contains('Route: /cage/abc123'));
        expect(context, contains('Dashboard → Cage List → Cage Detail'));
      });

      test('handles empty navigation', () {
        final context = service.buildNavigationContext();
        expect(context, contains('Route: Unknown'));
      });
    });

    group('Extra context', () {
      test('includes extra context in app state', () {
        service.setExtraContext({
          'currentFilter': 'active',
          'viewMode': 'grid',
        });

        final context = service.buildAppStateContext();
        expect(context, contains('currentFilter: active'));
        expect(context, contains('viewMode: grid'));
      });

      test('filters sensitive keys from extra context', () {
        service.setExtraContext({
          'filterName': 'visible',
          'viewMode': 'list',
          'password': 'secret123',
          'authToken': 'bearer-xxx',
          'apiKey': 'key-xxx',
          'accessToken': 'access-xxx',
        });

        final context = service.buildAppStateContext();
        expect(context, contains('filterName: visible'));
        expect(context, contains('viewMode: list'));
        expect(context, isNot(contains('secret123')));
        expect(context, isNot(contains('bearer-xxx')));
        expect(context, isNot(contains('key-xxx')));
        expect(context, isNot(contains('access-xxx')));
      });
    });

    group('Full context', () {
      test('builds complete context with all sections', () {
        // Set up profile
        profileState.value = ProfileResponseDto(
          accountUuid: 'user-123',
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@lab.com',
          labName: 'Research Lab',
          labUuid: 'lab-789',
          onboarded: true,
          onboardedDate: null,
          position: null,
          role: 'researcher',
          plan: 'basic',
        );

        // Set up navigation
        service.recordNavigation(route: '/dashboard', screenName: 'Dashboard');
        service.recordNavigation(
          route: '/animal/xyz789',
          screenName: 'Animal Detail',
          params: {'animalUuid': 'xyz789'},
        );

        final context = service.buildFullContext();

        // User section
        expect(context, contains('user-123'));
        expect(context, contains('jane@lab.com'));
        expect(context, contains('Research Lab'));

        // Navigation section
        expect(context, contains('Route: /animal/xyz789'));
        expect(context, contains('Dashboard → Animal Detail'));

        // App state section
        expect(context, contains('Animal: xyz789'));
      });
    });

    group('Clear', () {
      test('clears all context', () {
        service.recordNavigation(route: '/test', screenName: 'Test');
        service.setSelectedCage('cage-123');
        service.setExtraContext({'key': 'value'});

        service.clear();

        expect(service.breadcrumbs, isEmpty);
        expect(service.currentRoute, isNull);
        expect(service.buildAppStateContext(), isEmpty);
      });
    });
  });

  group('NavigationBreadcrumb', () {
    test('toString without params', () {
      final crumb = NavigationBreadcrumb(
        route: '/dashboard',
        screenName: 'Dashboard',
        timestamp: DateTime.now(),
      );
      expect(crumb.toString(), 'Dashboard');
    });

    test('toString with params', () {
      final crumb = NavigationBreadcrumb(
        route: '/cage/abc123',
        screenName: 'Cage Detail',
        params: {'cageUuid': 'abc123'},
        timestamp: DateTime.now(),
      );
      expect(crumb.toString(), 'Cage Detail (cageUuid=abc123)');
    });

    test('toString falls back to route when no screenName', () {
      final crumb = NavigationBreadcrumb(
        route: '/unknown',
        timestamp: DateTime.now(),
      );
      expect(crumb.toString(), '/unknown');
    });
  });
}
