import 'package:flutter/material.dart';
import 'package:moustra/stores/profile_store.dart';

/// Breadcrumb entry for navigation history
class NavigationBreadcrumb {
  final String route;
  final String? screenName;
  final Map<String, String> params;
  final DateTime timestamp;

  NavigationBreadcrumb({
    required this.route,
    this.screenName,
    this.params = const {},
    required this.timestamp,
  });

  @override
  String toString() {
    final paramsStr = params.isNotEmpty ? ' (${params.entries.map((e) => '${e.key}=${e.value}').join(', ')})' : '';
    return '${screenName ?? route}$paramsStr';
  }
}

/// Service that tracks error context: user info, navigation, app state
class ErrorContextService {
  static final ErrorContextService _instance = ErrorContextService._internal();
  factory ErrorContextService() => _instance;
  ErrorContextService._internal();

  // Navigation breadcrumbs (last N screens visited)
  static const int maxBreadcrumbs = 10;
  final List<NavigationBreadcrumb> _breadcrumbs = [];

  // Current route info
  String? _currentRoute;
  Map<String, String> _currentParams = {};

  // Optional app state context (selected items)
  String? _selectedColonyUuid;
  String? _selectedCageUuid;
  String? _selectedAnimalUuid;
  Map<String, dynamic> _extraContext = {};

  /// Get navigation breadcrumbs
  List<NavigationBreadcrumb> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  /// Get current route
  String? get currentRoute => _currentRoute;

  /// Record a navigation event
  void recordNavigation({
    required String route,
    String? screenName,
    Map<String, String> params = const {},
  }) {
    _currentRoute = route;
    _currentParams = Map.unmodifiable(params);

    final breadcrumb = NavigationBreadcrumb(
      route: route,
      screenName: screenName,
      params: params,
      timestamp: DateTime.now(),
    );

    _breadcrumbs.add(breadcrumb);

    // Keep only last N breadcrumbs
    while (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }

    // Auto-detect selected items from route params
    _updateSelectedItemsFromParams(params);
  }

  /// Update selected items based on route parameters
  void _updateSelectedItemsFromParams(Map<String, String> params) {
    if (params.containsKey('colonyUuid')) {
      _selectedColonyUuid = params['colonyUuid'];
    }
    if (params.containsKey('cageUuid')) {
      _selectedCageUuid = params['cageUuid'];
    }
    if (params.containsKey('animalUuid')) {
      _selectedAnimalUuid = params['animalUuid'];
    }
  }

  /// Manually set selected colony (for use outside of navigation)
  void setSelectedColony(String? uuid) => _selectedColonyUuid = uuid;

  /// Manually set selected cage
  void setSelectedCage(String? uuid) => _selectedCageUuid = uuid;

  /// Manually set selected animal
  void setSelectedAnimal(String? uuid) => _selectedAnimalUuid = uuid;

  /// Set extra context (e.g., current filters, view state)
  void setExtraContext(Map<String, dynamic> context) {
    _extraContext = Map.unmodifiable(context);
  }

  /// Clear extra context
  void clearExtraContext() {
    _extraContext = {};
  }

  /// Clear all context (call on logout)
  void clear() {
    _breadcrumbs.clear();
    _currentRoute = null;
    _currentParams = {};
    _selectedColonyUuid = null;
    _selectedCageUuid = null;
    _selectedAnimalUuid = null;
    _extraContext = {};
  }

  /// Build user context string (respects privacy - no tokens/passwords)
  String buildUserContext() {
    final profile = profileState.value;
    if (profile == null) {
      return 'User: Not logged in';
    }

    final buffer = StringBuffer();
    buffer.writeln('User: ${profile.accountUuid} (${profile.email})');
    buffer.writeln('Lab: ${profile.labName}');
    buffer.writeln('Role: ${profile.role}');
    if (profile.position != null && profile.position!.isNotEmpty) {
      buffer.writeln('Position: ${profile.position}');
    }
    return buffer.toString().trimRight();
  }

  /// Build navigation context string
  String buildNavigationContext() {
    final buffer = StringBuffer();

    // Current route
    if (_currentRoute != null) {
      buffer.writeln('Route: $_currentRoute');
      if (_currentParams.isNotEmpty) {
        buffer.writeln('Params: ${_currentParams.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
      }
    } else {
      buffer.writeln('Route: Unknown');
    }

    // Breadcrumbs
    if (_breadcrumbs.isNotEmpty) {
      buffer.writeln('Breadcrumbs: ${_breadcrumbs.map((b) => b.screenName ?? b.route).join(' → ')}');
    }

    return buffer.toString().trimRight();
  }

  /// Build app state context string
  String buildAppStateContext() {
    final parts = <String>[];

    if (_selectedColonyUuid != null) {
      parts.add('Colony: $_selectedColonyUuid');
    }
    if (_selectedCageUuid != null) {
      parts.add('Cage: $_selectedCageUuid');
    }
    if (_selectedAnimalUuid != null) {
      parts.add('Animal: $_selectedAnimalUuid');
    }

    if (_extraContext.isNotEmpty) {
      for (final entry in _extraContext.entries) {
        // Skip sensitive keys
        if (_isSensitiveKey(entry.key)) continue;
        parts.add('${entry.key}: ${entry.value}');
      }
    }

    return parts.isEmpty ? '' : parts.join('\n');
  }

  /// Check if a key might contain sensitive data
  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    // Use word boundary patterns to avoid false positives
    // (e.g., "normalKey" should not be filtered, but "apiKey" should)
    return lower.contains('password') ||
        lower.contains('token') ||
        lower.contains('secret') ||
        lower.contains('apikey') ||
        lower.contains('api_key') ||
        lower.contains('authtoken') ||
        lower.contains('auth_token') ||
        lower.contains('accesstoken') ||
        lower.contains('access_token') ||
        lower.contains('refreshtoken') ||
        lower.contains('refresh_token') ||
        lower.contains('credential') ||
        lower.contains('privatekey') ||
        lower.contains('private_key');
  }

  /// Build complete error context
  String buildFullContext() {
    final buffer = StringBuffer();

    // User context
    buffer.writeln(buildUserContext());
    buffer.writeln();

    // Navigation context
    buffer.writeln(buildNavigationContext());

    // App state context (only if non-empty)
    final appState = buildAppStateContext();
    if (appState.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('App State:');
      buffer.writeln(appState);
    }

    return buffer.toString().trimRight();
  }
}

/// Global singleton instance
final errorContextService = ErrorContextService();

/// GoRouter observer that tracks navigation for error context
class ErrorContextNavigationObserver extends NavigatorObserver {
  /// Extract a human-readable screen name from a route
  String? _screenNameFromRoute(String? route) {
    if (route == null) return null;

    // Remove leading slash and query params
    final path = route.split('?').first;
    if (path.isEmpty || path == '/') return 'Home';

    // Extract the main route segment
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return 'Home';

    // Handle parameterized routes (e.g., /cage/abc123 → Cage Detail)
    final mainSegment = segments.first;

    // Map route segments to human-readable names
    final screenNames = {
      'dashboard': 'Dashboard',
      'login': 'Login',
      'signup': 'Sign Up',
      'strain': segments.length > 1 ? 'Strain Detail' : 'Strains',
      'cage': _cageScreenName(segments),
      'animal': segments.length > 1 ? 'Animal Detail' : 'Animals',
      'litter': segments.length > 1 ? 'Litter Detail' : 'Litters',
      'mating': segments.length > 1 ? 'Mating Detail' : 'Matings',
      'user': segments.length > 1 ? 'User Detail' : 'Users',
      'settings': 'Settings',
    };

    return screenNames[mainSegment] ?? _capitalize(mainSegment);
  }

  String _cageScreenName(List<String> segments) {
    if (segments.length == 1) return 'Cages';
    if (segments.length > 1) {
      if (segments[1] == 'list') return 'Cage List';
      if (segments[1] == 'grid') return 'Cage Grid';
      if (segments[1] == 'new') return 'New Cage';
      return 'Cage Detail';
    }
    return 'Cages';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  /// Extract route parameters from a Route
  Map<String, String> _extractParams(Route<dynamic>? route) {
    if (route == null) return {};

    final settings = route.settings;
    if (settings is Page) {
      // For MaterialPage, try to get arguments
      final args = settings.arguments;
      if (args is Map<String, String>) {
        return args;
      }
    }

    // Try to extract from route name
    final name = settings.name;
    if (name != null && name.contains('?')) {
      final uri = Uri.parse(name);
      return uri.queryParameters;
    }

    return {};
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _recordRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _recordRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _recordRoute(newRoute);
    }
  }

  void _recordRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName == null) return;

    final screenName = _screenNameFromRoute(routeName);
    final params = _extractParams(route);

    // Extract path parameters from the route name
    final uri = Uri.parse(routeName);
    final pathParams = <String, String>{};

    // Parse path segments to extract UUIDs
    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      final nextSegment = segments[i + 1];
      // If current segment is a known entity type and next looks like a UUID
      if (['cage', 'animal', 'strain', 'litter', 'mating', 'user'].contains(segment) &&
          nextSegment != 'new' &&
          nextSegment != 'list' &&
          nextSegment != 'grid') {
        pathParams['${segment}Uuid'] = nextSegment;
      }
    }

    errorContextService.recordNavigation(
      route: routeName,
      screenName: screenName,
      params: {...params, ...pathParams},
    );
  }
}
