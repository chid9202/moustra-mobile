# Moustra Mobile Test Suite

This directory contains comprehensive unit tests for the Moustra mobile application, focusing on widget testing, screen testing, and component validation.

## Test Structure

```
test/
├── test_helpers/           # Test utilities and mock data
│   ├── test_helpers.dart   # Common test utilities
│   ├── mock_data.dart      # Mock data factories
│   └── simple_mock_data.dart # Simplified mock data
├── widgets/                # Widget-specific tests
│   └── shared/            # Shared widget tests
│       ├── button_test.dart
│       ├── select_animal_test.dart
│       ├── select_cage_test.dart
│       ├── select_date_test.dart
│       └── multi_select_animal_test.dart
├── screens/                # Screen-specific tests
│   ├── animal_new_screen_test.dart
│   ├── animals_screen_test.dart
│   ├── login_screen_test.dart
│   ├── dashboard_screen_test.dart
│   └── test_runner.dart
├── services/               # Service and API tests
│   ├── clients/           # API client tests
│   └── auth_service_test.dart
├── dtos/                   # DTO tests
│   ├── animal_dto_test.dart
│   └── mating_dto_test.dart
├── test_runner.dart        # Main test runner and configuration
└── README.md              # This file
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test Files

```bash
# Run button tests
flutter test test/widgets/shared/button_test.dart

# Run select widget tests
flutter test test/widgets/shared/select_animal_test.dart
flutter test test/widgets/shared/select_cage_test.dart
flutter test test/widgets/shared/select_date_test.dart

# Run multi-select tests
flutter test test/widgets/shared/multi_select_animal_test.dart

# Run screen tests
flutter test test/screens/animal_new_screen_test.dart
flutter test test/screens/animals_screen_test.dart
flutter test test/screens/login_screen_test.dart
flutter test test/screens/dashboard_screen_test.dart

# Run service tests
flutter test test/services/auth_service_test.dart
flutter test test/services/clients/

# Run DTO tests
flutter test test/dtos/animal_dto_test.dart
flutter test test/dtos/mating_dto_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Categories

### 1. Button Widget Tests (`button_test.dart`)

- Basic rendering and properties
- Button variants (primary, secondary, success, warning, error, info)
- Button sizes (small, medium, large)
- Loading states
- Icon integration
- Theme integration
- Accessibility
- Edge cases

### 2. Select Widget Tests

- **SelectAnimal** (`select_animal_test.dart`)
- **SelectCage** (`select_cage_test.dart`)
- **SelectDate** (`select_date_test.dart`)

Each select widget test covers:

- Basic rendering and properties
- Selection state management
- Dialog interactions
- Clear functionality
- Disabled states
- Edge cases
- Accessibility

### 3. Multi-Select Widget Tests (`multi_select_animal_test.dart`)

- Multiple selection handling
- Chip display and interactions
- Clear all functionality
- Dialog interactions
- Filtering capabilities
- Edge cases

### 4. Screen Tests

- **AnimalNewScreen** (`animal_new_screen_test.dart`)

  - Form rendering and validation
  - Animal card management (add, delete, clone)
  - Navigation handling
  - Shared settings integration

- **AnimalsScreen** (`animals_screen_test.dart`)

  - Data grid rendering
  - Button interactions
  - Selection state management
  - Bulk operations

- **LoginScreen** (`login_screen_test.dart`)

  - Authentication flow
  - Error handling
  - Loading states
  - Navigation

- **DashboardScreen** (`dashboard_screen_test.dart`)
  - Data loading states
  - Error handling
  - Component rendering
  - Layout structure

### 5. Service Tests

- **AuthService** (`auth_service_test.dart`)

  - Authentication flow
  - Credential management
  - Error handling

- **API Clients** (`services/clients/`)
  - HTTP request handling
  - Response parsing
  - Error handling
  - Authentication integration

### 6. DTO Tests

- **AnimalDto** (`animal_dto_test.dart`)

  - JSON serialization/deserialization
  - Data validation
  - Edge cases

- **MatingDto** (`mating_dto_test.dart`)
  - JSON serialization/deserialization
  - Data validation
  - Edge cases

## Test Helpers

### TestHelpers Class

Located in `test_helpers/test_helpers.dart`, provides:

- `createTestApp()` - Creates test app with proper theme
- `pumpWidgetWithTheme()` - Pumps widget with theme support
- `tapAndWait()` - Taps widget and waits for animations
- `expectEnabled()` / `expectDisabled()` - Widget state validation
- Theme creation utilities

### MockDataFactory Class

Located in `test_helpers/mock_data.dart`, provides:

- `createAnimalStoreDto()` - Mock animal data
- `createCageStoreDto()` - Mock cage data
- `createStrainStoreDto()` - Mock strain data
- `createGeneStoreDto()` - Mock gene data
- `createAlleleStoreDto()` - Mock allele data
- List generators for multiple items

## Test Patterns

### Widget Testing Pattern

```dart
testWidgets('test description', (WidgetTester tester) async {
  // Arrange
  await TestHelpers.pumpWidgetWithTheme(tester, widget);

  // Act
  await TestHelpers.tapAndWait(tester, finder);

  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Dialog Testing Pattern

```dart
testWidgets('opens dialog when tapped', (WidgetTester tester) async {
  await TestHelpers.pumpWidgetWithTheme(tester, widget);

  await TestHelpers.tapAndWait(tester, find.byType(InkWell));
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('Dialog Title'), findsOneWidget);
});
```

### State Change Testing Pattern

```dart
testWidgets('calls onChanged when button is tapped', (WidgetTester tester) async {
  bool wasCalled = false;

  await TestHelpers.pumpWidgetWithTheme(
    tester,
    Widget(onChanged: () => wasCalled = true),
  );

  await TestHelpers.tapAndWait(tester, find.byType(Button));
  expect(wasCalled, isTrue);
});
```

## Best Practices

1. **Use TestHelpers**: Always use the provided test helpers for consistency
2. **Mock Data**: Use MockDataFactory for creating test data
3. **Async Handling**: Properly handle async operations with `pump()` and `pumpAndSettle()`
4. **Edge Cases**: Test null values, empty strings, and boundary conditions
5. **Accessibility**: Include accessibility tests where applicable
6. **Theme Integration**: Test with different themes (light, dark, custom)
7. **Error Handling**: Test error states and edge cases

## Dependencies

The test suite uses the following testing dependencies:

- `flutter_test` - Core Flutter testing framework
- `mockito` - Mocking framework for unit tests
- `fake_async` - Async testing utilities

## Coverage Goals

- **Widget Tests**: 90%+ coverage for shared widgets
- **Edge Cases**: All edge cases and error conditions tested
- **Accessibility**: All accessibility features tested
- **Theme Integration**: All theme variants tested

## Contributing

When adding new tests:

1. Follow the existing test structure and patterns
2. Use the provided test helpers and mock data
3. Include comprehensive edge case testing
4. Add accessibility tests where applicable
5. Update this README with new test categories

## Troubleshooting

### Common Issues

1. **Test Timeout**: Increase timeout for complex widget tests
2. **Async Issues**: Use `pump()` and `pumpAndSettle()` appropriately
3. **Theme Issues**: Ensure proper theme setup in test helpers
4. **Mock Data**: Verify mock data matches actual DTOs

### Debug Tips

1. Use `debugDumpApp()` to inspect widget tree
2. Use `tester.printToConsole()` for debugging output
3. Use `tester.binding.debugAssertNoTransientCallbacks()` to catch async issues
