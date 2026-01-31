# Testing Guide for Moustra Mobile

This document provides comprehensive testing guidelines for the Moustra mobile application.

## Overview

The testing strategy consists of three layers:

1. **Unit Tests** - Test individual functions, classes, and DTOs
2. **Widget Tests** - Test UI components in isolation
3. **Integration Tests** - Test complete user flows on real devices/emulators

## Test Structure

```
test/
├── dtos/                     # DTO serialization tests
│   └── *_dto_test.dart
├── screens/                  # Screen widget tests
│   └── *_screen_test.dart
├── services/                 # Service and API tests
│   └── clients/              # API client tests
│       ├── *_api_test.dart
│       └── *_api_test.mocks.dart
├── widgets/                  # Widget unit tests
│   ├── shared/               # Shared widget tests
│   └── *_test.dart
└── test_helpers/             # Test utilities
    ├── mock_data.dart        # Mock data factory
    ├── mock_stores.dart      # Mock store implementations
    ├── test_helpers.dart     # Common test utilities
    └── test_widgets.dart     # Widget test wrappers

integration_test/
├── app_test.dart             # Main integration test file
└── robots/                   # Page object pattern
    ├── login_robot.dart
    └── dashboard_robot.dart
```

## Running Tests

### Quick Commands

```bash
# Run all tests
./run_tests.sh all

# Run with coverage
./run_tests.sh coverage

# Run shared widget tests
./run_tests.sh shared

# Run specific test file
./run_tests.sh file test/path/to/test.dart

# Generate coverage report (requires lcov)
./run_tests.sh report
```

### Direct Flutter Commands

```bash
# All tests
flutter test

# Specific file
flutter test test/dtos/animal_dto_test.dart

# With coverage
flutter test --coverage

# Verbose output
flutter test --reporter expanded

# Integration tests (requires device)
flutter test integration_test/app_test.dart
```

## Unit Testing

### DTO Tests

Test JSON serialization and deserialization:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

void main() {
  group('AnimalDto', () {
    test('should deserialize from JSON', () {
      final json = {
        'animal_id': 1,
        'animal_uuid': 'test-uuid',
        'physical_tag': 'A001',
        'sex': 'Male',
      };

      final dto = AnimalDto.fromJson(json);

      expect(dto.animalId, 1);
      expect(dto.animalUuid, 'test-uuid');
      expect(dto.physicalTag, 'A001');
    });

    test('should serialize to JSON', () {
      final dto = AnimalDto(
        animalId: 1,
        animalUuid: 'test-uuid',
        physicalTag: 'A001',
        sex: 'Male',
      );

      final json = dto.toJson();

      expect(json['animal_id'], 1);
      expect(json['animal_uuid'], 'test-uuid');
    });

    test('should handle null optional fields', () {
      final json = {
        'animal_id': 1,
        'animal_uuid': 'test-uuid',
      };

      final dto = AnimalDto.fromJson(json);

      expect(dto.physicalTag, isNull);
    });
  });
}
```

### API Client Tests

Test API clients with mocked HTTP:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'animal_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late AnimalApi animalApi;

  setUp(() {
    mockClient = MockClient();
    // Inject mock client
  });

  group('AnimalApi', () {
    test('getAnimal returns animal on success', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                '{"animal_id": 1, "animal_uuid": "test-uuid"}',
                200,
              ));

      final result = await animalApi.getAnimal('test-uuid');

      expect(result.animalId, 1);
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getAnimal throws on error', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not found', 404));

      expect(
        () => animalApi.getAnimal('invalid-uuid'),
        throwsException,
      );
    });
  });
}
```

## Widget Testing

### Basic Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/shared/button.dart';

void main() {
  group('MoustraButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoustraButton(
              label: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoustraButton(
              label: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoustraButton(
              label: 'Click Me',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Screen Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/animals_screen.dart';

import '../test_helpers/mock_stores.dart';
import '../test_helpers/test_widgets.dart';

void main() {
  setUp(() {
    // Reset stores to initial state
    resetMockStores();
  });

  group('AnimalsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: AnimalsScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows animal list when loaded', (tester) async {
      // Setup mock store with data
      animalStore.value = MockDataFactory.createAnimalStoreDtoList(3);

      await tester.pumpWidget(
        const TestApp(child: AnimalsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('A001'), findsOneWidget);
      expect(find.text('A002'), findsOneWidget);
      expect(find.text('A003'), findsOneWidget);
    });
  });
}
```

## Integration Testing

### Robot Pattern

The Robot pattern provides a clean abstraction for UI interactions:

```dart
// integration_test/robots/animal_robot.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AnimalRobot {
  AnimalRobot(this.tester);
  final WidgetTester tester;

  // Finders
  Finder get addButton => find.byIcon(Icons.add);
  Finder get animalList => find.byType(ListView);
  Finder get tagField => find.widgetWithText(TextFormField, 'Physical Tag');
  Finder get saveButton => find.text('Save');

  // Actions
  Future<void> tapAddAnimal() async {
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  Future<void> enterTag(String tag) async {
    await tester.enterText(tagField, tag);
    await tester.pump();
  }

  Future<void> tapSave() async {
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  // Assertions
  Future<void> verifyAnimalListDisplayed() async {
    expect(animalList, findsOneWidget);
  }

  Future<void> verifyAnimalInList(String tag) async {
    expect(find.text(tag), findsOneWidget);
  }
}
```

### Integration Test

```dart
// integration_test/app_test.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';

import 'robots/login_robot.dart';
import 'robots/dashboard_robot.dart';
import 'robots/animal_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env.test');
    await authService.init();
  });

  group('Animal Management Flow', () {
    testWidgets('can create new animal', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // Login
      final loginRobot = LoginRobot(tester);
      await loginRobot.login(
        dotenv.env['TEST_EMAIL']!,
        dotenv.env['TEST_PASSWORD']!,
      );
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to animals
      final dashboardRobot = DashboardRobot(tester);
      await dashboardRobot.navigateToAnimals();
      await tester.pumpAndSettle();

      // Create animal
      final animalRobot = AnimalRobot(tester);
      await animalRobot.verifyAnimalListDisplayed();
      await animalRobot.tapAddAnimal();
      await animalRobot.enterTag('TEST001');
      await animalRobot.tapSave();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify
      await animalRobot.verifyAnimalInList('TEST001');
    });
  });
}
```

## Test Helpers

### Mock Data Factory

```dart
// test/test_helpers/mock_data.dart
class MockDataFactory {
  static AnimalStoreDto createAnimalStoreDto({
    int? eid,
    int? animalId,
    String? animalUuid,
    String? physicalTag,
    String? sex,
  }) {
    return AnimalStoreDto(
      eid: eid ?? 1,
      animalId: animalId ?? 1,
      animalUuid: animalUuid ?? 'test-animal-uuid',
      physicalTag: physicalTag ?? 'A001',
      sex: sex ?? 'Male',
      dateOfBirth: DateTime.now(),
    );
  }

  static List<AnimalStoreDto> createAnimalStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createAnimalStoreDto(
        eid: index + 1,
        animalId: index + 1,
        animalUuid: 'test-animal-uuid-$index',
        physicalTag: 'A${(index + 1).toString().padLeft(3, '0')}',
      );
    });
  }
}
```

### Test App Wrapper

```dart
// test/test_helpers/test_widgets.dart
import 'package:flutter/material.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}
```

## Test Environment

### .env.test Configuration

```bash
# API Configuration
API_BASE_URL=https://api-test.moustra.com/api/v1
AUTH0_DOMAIN=moustra-test.auth0.com
AUTH0_CLIENT_ID=test_client_id
AUTH0_SCHEME=com.moustra.app.test
AUTH0_AUDIENCE=https://api-test.moustra.com

# Test Credentials
TEST_EMAIL=test@example.com
TEST_PASSWORD=test_password_123
```

## Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Coverage Targets

| Category | Target |
|----------|--------|
| DTOs | 100% |
| API Clients | 80% |
| Stores | 70% |
| Widgets | 60% |
| Screens | 50% |
| Overall | 70% |

## Best Practices

1. **Test One Thing** - Each test should verify a single behavior
2. **Clear Names** - Test names should describe expected behavior
3. **Arrange-Act-Assert** - Structure tests consistently
4. **Use Mock Data Factory** - Consistent test data across tests
5. **Avoid Flaky Tests** - Use `pumpAndSettle()` and appropriate timeouts
6. **Test Edge Cases** - Null values, empty lists, error states
7. **Keep Tests Fast** - Mock external dependencies
8. **Test in Isolation** - Reset state between tests

## Debugging Tests

```bash
# Verbose output
flutter test --reporter expanded test/path/to/test.dart

# Debug a specific test
flutter test test/path/to/test.dart --name "test name"

# Skip slow tests during development
flutter test --exclude-tags slow
```
