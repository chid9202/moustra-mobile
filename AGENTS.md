# AGENTS.md - AI Agent Development Guide

This document is the single source of truth for AI agents working on the Moustra mobile application.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Domain Knowledge](#domain-knowledge)
3. [Project Structure](#project-structure)
4. [Development Commands](#development-commands)
5. [Code Conventions](#code-conventions)
6. [State Management](#state-management)
7. [API Patterns](#api-patterns)
8. [Testing Guidelines](#testing-guidelines)
9. [Environment Configuration](#environment-configuration)
10. [Common Tasks](#common-tasks)
11. [Troubleshooting](#troubleshooting)
12. [Related Documentation](#related-documentation)
13. [Advanced Patterns](#advanced-patterns)
14. [Mobile vs Web Feature Gaps](#mobile-vs-web-feature-gaps)

---

## Project Overview

**Moustra** is a Flutter mobile application for managing laboratory animal colonies and research workflows. It helps researchers track animals, cages, strains, matings, litters, and related data in laboratory settings.

### Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter (Dart) |
| State Management | MobX (ValueNotifier pattern) |
| Routing | go_router |
| Authentication | Auth0 |
| HTTP Client | http package |
| Storage | flutter_secure_storage, shared_preferences |
| Code Generation | build_runner, json_serializable |
| Testing | flutter_test, integration_test, mockito |
| Deployment | Fastlane, GitHub Actions |

### Key Features

- **Animal Management** - Track individual animals with genotypes, lineage, and health records
- **Cage Management** - Organize animals in cages with rack visualization (2D/3D grid view)
- **Strain Management** - Define and manage genetic strains with color coding
- **Mating & Litter Tracking** - Record breeding pairs and offspring
- **Dashboard Analytics** - View colony statistics and metrics
- **Barcode Scanning** - Quickly identify animals and cages

---

## Domain Knowledge

### Terminology

| Term | Description |
|------|-------------|
| Animal | Individual lab animal (mouse/rat) with unique ID |
| Cage | Housing unit containing one or more animals |
| Rack | Physical structure holding multiple cages |
| Strain | Genetic lineage/breed of animals |
| Mating | Breeding pair (1 sire + 1-2 dams) |
| Litter | Offspring from a mating event |
| Genotype | Genetic makeup of an animal |
| Allele | Variant of a gene |
| EID | Electronic ID (ear tag number) |
| Physical Tag | Visible tag on animal |
| Wean | Separate young animals from parents |

### Business Rules

1. Animals belong to exactly one cage at a time
2. Animals can have multiple genotypes (one per gene)
3. Matings consist of one sire (male) and one or more dams (female)
4. Litters belong to exactly one mating
5. Cages can be "ended" (soft delete) but animals must be moved first
6. Animals can be "ended" with a date and reason

---

## Project Structure

```
lib/
├── main.dart                 # App entry point with error handling
├── app/                      # App configuration
│   ├── app.dart              # Root MaterialApp widget
│   ├── router.dart           # go_router configuration (ALL ROUTES HERE)
│   ├── theme.dart            # Light/dark theme definitions
│   └── mui_color.dart        # Color scheme definitions
├── config/                   # Environment configuration
│   └── env.dart              # Environment variable access
├── screens/                  # UI screens (one per route)
│   ├── dashboard/            # Dashboard feature screens
│   ├── settings/             # Settings feature screens
│   └── *_screen.dart         # Individual screen widgets
├── widgets/                  # Reusable UI components
│   ├── shared/               # Common shared widgets
│   ├── cage/                 # Cage-specific widgets
│   ├── dialogs/              # Dialog components
│   └── *.dart                # Individual widget files
├── services/                 # API and business logic
│   ├── clients/              # API client classes (*_api.dart)
│   ├── dtos/                 # Data Transfer Objects
│   │   ├── stores/           # Store-specific DTOs
│   │   └── *.dart            # Entity DTOs
│   ├── models/               # Domain models
│   └── utils/                # Service utilities
├── stores/                   # State management (ValueNotifier)
│   └── *_store.dart          # State stores
├── helpers/                  # Utility functions
│   └── *_helper.dart         # Helper utilities
└── constants/                # App constants
    └── list_constants/       # List/table configuration

test/
├── dtos/                     # DTO unit tests
├── screens/                  # Screen widget tests
├── services/                 # Service/API tests
│   └── clients/              # API client tests
├── widgets/                  # Widget unit tests
│   ├── shared/               # Shared widget tests
│   └── attachment/           # Feature-specific widget tests
└── test_helpers/             # Test utilities and mock data

integration_test/
├── app_test.dart             # Integration test entry point
└── robots/                   # Page object pattern robots
```

### Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, error handling setup |
| `lib/app/router.dart` | All routes defined here |
| `lib/services/clients/api_client.dart` | Base HTTP client |
| `openapi.yaml` | Full API specification |
| `pubspec.yaml` | Dependencies and app version |

---

## Development Commands

### Setup & Running

```bash
# Install dependencies
flutter pub get

# Run app (development)
flutter run

# Run app (production)
flutter run --release --dart-define=ENV_FILENAME=.env.production

# Clean build
flutter clean && flutter pub get && flutter run
```

### Code Generation

**Required after modifying DTOs with @JsonSerializable:**

```bash
dart run build_runner build -d
```

### Testing

```bash
# Run all tests
./run_tests.sh all

# Run with coverage
./run_tests.sh coverage

# Run specific test file
flutter test test/path/to/test_file.dart

# Run integration tests (requires device/emulator)
flutter test integration_test/app_test.dart
```

### Linting & Analysis

```bash
# Run static analysis
flutter analyze

# Auto-fix lint issues
dart fix --apply
```

---

## Code Conventions

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | snake_case | `animal_detail_screen.dart` |
| Classes | PascalCase | `AnimalDetailScreen` |
| Functions | camelCase | `fetchAnimalData()` |
| Variables | camelCase | `animalList` |
| Constants | camelCase | `defaultPageSize` |
| DTOs | PascalCase + Dto suffix | `AnimalDto` |
| Stores | PascalCase + Store suffix | `AnimalStore` |
| API Clients | snake_case + _api suffix | `animal_api.dart` |

### File Organization

**Screens:**
- One screen per file: `*_screen.dart`
- Screens handle routing and high-level layout
- Extract reusable logic to widgets/helpers

**Widgets:**
- Reusable components in `widgets/`
- Feature-specific widgets in feature subdirectories
- Shared widgets in `widgets/shared/`

**DTOs:**
- All DTOs in `services/dtos/`
- Use `@JsonSerializable()` annotation
- Generated files: `*.g.dart`
- Store DTOs in `services/dtos/stores/`

### Widget Structure

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.param});

  final String param;

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
```

### Import Order

1. Dart SDK imports (`dart:*`)
2. Flutter imports (`package:flutter/*`)
3. Package imports (third-party)
4. Project imports (`package:moustra/*`)

### Error Handling

```dart
try {
  final result = await api.fetchData();
  // handle success
} catch (e) {
  debugPrint('Error: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to load data')),
  );
}
```

---

## State Management

The app uses ValueNotifier-based state management:

### Store Definition

```dart
// lib/stores/animal_store.dart
final animalStore = ValueNotifier<List<AnimalStoreDto>?>(null);
```

### Usage in Widgets

```dart
ValueListenableBuilder<List<AnimalStoreDto>?>(
  valueListenable: animalStore,
  builder: (context, animals, _) {
    if (animals == null) return const CircularProgressIndicator();
    return ListView.builder(
      itemCount: animals.length,
      itemBuilder: (context, index) => AnimalTile(animal: animals[index]),
    );
  },
);
```

---

## API Patterns

### DTO Structure

All DTOs must use json_serializable:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'entity_dto.g.dart';

@JsonSerializable()
class EntityDto {
  final int entityId;
  final String entityUuid;
  final String? optionalField;

  EntityDto({
    required this.entityId,
    required this.entityUuid,
    this.optionalField,
  });

  factory EntityDto.fromJson(Map<String, dynamic> json) =>
      _$EntityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EntityDtoToJson(this);
}
```

### API Client Pattern

```dart
class EntityApi {
  // GET single item
  Future<EntityDto> getEntity(String uuid) async {
    final response = await apiClient.get('/entities/$uuid');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch entity');
    }
    return EntityDto.fromJson(json.decode(response.body));
  }

  // GET list with pagination
  Future<PaginatedResponse<EntityDto>> getEntities({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      '/entities?page=$page&pageSize=$pageSize',
    );
    // ...
  }

  // POST create
  Future<EntityDto> createEntity(PostEntityDto dto) async {
    final response = await apiClient.post(
      '/entities',
      body: json.encode(dto.toJson()),
    );
    // ...
  }

  // PUT update
  Future<EntityDto> updateEntity(String uuid, PutEntityDto dto) async {
    final response = await apiClient.put(
      '/entities/$uuid',
      body: json.encode(dto.toJson()),
    );
    // ...
  }
}

// Singleton instance
final entityApi = EntityApi();
```

### JSON Field Naming

Use `@JsonKey` for field name mapping:

```dart
@JsonSerializable()
class EntityDto {
  @JsonKey(name: 'entity_id')
  final int entityId;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
}
```

---

## Testing Guidelines

### Test File Naming

- Unit tests: `*_test.dart`
- Mock files: `*_test.mocks.dart`
- Test helpers: `test_helpers/*.dart`

### Widget Tests

```dart
testWidgets('widget should render correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MyWidget(param: 'value'),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('Expected Text'), findsOneWidget);
  
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  expect(find.text('Updated Text'), findsOneWidget);
});
```

### API Client Tests (with Mockito)

```dart
@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  
  setUp(() {
    mockClient = MockClient();
  });
  
  test('fetches entity', () async {
    when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response('{"entityId": 1}', 200));
    
    final result = await entityApi.getEntity('uuid');
    expect(result.entityId, 1);
  });
}
```

### Integration Tests (Robot Pattern)

```dart
// robots/login_robot.dart
class LoginRobot {
  LoginRobot(this.tester);
  final WidgetTester tester;
  
  Finder get emailField => find.widgetWithText(TextFormField, 'Email');
  Finder get signInButton => find.text('Sign In');
  
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pump();
  }
  
  Future<void> tapSignIn() async {
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }
}
```

### Mock Data Factory

Use `test_helpers/mock_data.dart` for consistent test data:

```dart
final mockAnimal = MockDataFactory.createAnimalStoreDto(
  animalUuid: 'test-uuid',
  physicalTag: 'A001',
);
```

---

## Environment Configuration

### Environment Files

| File | Purpose |
|------|---------|
| `.env` | Development environment (default) |
| `.env.production` | Production environment |
| `.env.test` | Test environment |
| `.env.example` | Template with required variables |

### Required Variables

```bash
API_BASE_URL=https://api.example.com/api/v1
AUTH0_DOMAIN=your-domain.auth0.com
AUTH0_CLIENT_ID=your_client_id
AUTH0_SCHEME=com.moustra.app
AUTH0_AUDIENCE=https://api.moustra.com
AUTH0_CONNECTION=Username-Password-Authentication
```

---

## Common Tasks

### Adding a New Screen

1. Create screen file: `lib/screens/new_feature_screen.dart`
2. Add route in `lib/app/router.dart`
3. Create widget test: `test/screens/new_feature_screen_test.dart`

### Adding a New API Endpoint

1. Add/update DTO: `lib/services/dtos/entity_dto.dart`
2. Run code generation: `dart run build_runner build -d`
3. Add API method: `lib/services/clients/entity_api.dart`
4. Create API test: `test/services/clients/entity_api_test.dart`

### Adding a New Widget

1. Create widget: `lib/widgets/new_widget.dart`
2. Create widget test: `test/widgets/new_widget_test.dart`

### Modifying State

1. Update store: `lib/stores/entity_store.dart`
2. Update any dependent widgets
3. Test state changes in widget tests

---

## Troubleshooting

### Build Failures

```bash
flutter clean
flutter pub get
dart run build_runner build -d
flutter run
```

### Code Generation Issues

```bash
find . -name "*.g.dart" -delete
dart run build_runner build -d
```

### Test Failures

```bash
flutter test test/path/to/test.dart --reporter expanded
```

---

## Feature Implementation Checklist

When implementing a new feature:

- [ ] Create/update DTOs with `@JsonSerializable`
- [ ] Run `dart run build_runner build -d`
- [ ] Implement API client methods
- [ ] Create/update stores
- [ ] Implement screen/widget UI
- [ ] Add route in router.dart
- [ ] Write unit tests for DTOs
- [ ] Write unit tests for API clients
- [ ] Write widget tests for screens
- [ ] Run `flutter analyze` and fix issues
- [ ] Run all tests with `./run_tests.sh all`
- [ ] Test on device/emulator manually

---

## Related Documentation

- [FEATURES.md](FEATURES.md) - Complete feature list
- [MISSING-FEATURES.md](MISSING-FEATURES.md) - Features not yet implemented
- [docs/MOBILE-FLOWS.md](docs/MOBILE-FLOWS.md) - Authentication and mobile-specific flows
- [docs/FEATURE-PARITY.md](docs/FEATURE-PARITY.md) - Mobile vs web feature comparison
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [TESTING.md](TESTING.md) - Detailed testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution workflow

---

## Advanced Patterns

### Authentication Architecture

The app uses a layered authentication approach:

```
┌─────────────────────────────────────────────────────┐
│                   UI Layer                          │
│  LoginScreen / SignupScreen                         │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                AuthService                          │
│  - loginWithPassword()                              │
│  - loginWithSocial()                                │
│  - signUpWithPassword()                             │
│  - unlockWithBiometrics()                           │
│  - logout()                                         │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                SecureStore                          │
│  - Access/Refresh/ID tokens                         │
│  - flutter_secure_storage (encrypted)               │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│             Auth0 (External)                        │
│  - ROPG for password login                          │
│  - webAuthentication for social                     │
└─────────────────────────────────────────────────────┘
```

### Global Store Initialization

After login, stores are initialized in parallel for performance:

```dart
// In login_screen.dart _postLogin()
useAccountStore();    // Fire and forget
useAnimalStore();     // All run in parallel
useCageStore();
useStrainStore();
// ...
```

Each store follows the lazy-init pattern:
```dart
Future<void> useStrainStore() async {
  if (strainStore.value != null) return; // Already loaded
  strainStore.value = await storeApi.getStrains();
}
```

### Error Context Service

The app automatically collects error context for debugging:

```dart
// lib/services/error_context_service.dart
- Current route tracking via ErrorContextNavigationObserver
- Navigation breadcrumbs (last 10 routes)
- User profile snapshot
- App state at time of error
```

Usage:
```dart
reportError(
  error: e,
  stackTrace: stackTrace,
  context: 'User action: saving animal',
);
```

### File Upload Pattern

Multipart file uploads use a dedicated method:

```dart
// ApiClient.uploadFile()
Future<http.StreamedResponse> uploadFile(
  String path, {
  required File file,
  String fileFieldName = 'file',
  Map<String, String>? fields,
}) async {
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));
  return await request.send();
}
```

### Platform-Specific Configuration

**iOS Info.plist keys:**
- `NSFaceIDUsageDescription` - Biometric auth
- `NSCameraUsageDescription` - Barcode scanning
- `NSPhotoLibraryUsageDescription` - File uploads
- `CFBundleURLSchemes` - Auth0 callback + deep links

**Android AndroidManifest.xml:**
- `USE_BIOMETRIC` / `USE_FINGERPRINT` - Biometric auth
- `CAMERA` - Barcode scanning
- Intent filters for Auth0 callback and app links

### Deep Link Configuration

Android supports App Links for `app.moustra.com`:
```xml
<intent-filter android:autoVerify="true">
    <data android:scheme="https" android:host="app.moustra.com"/>
</intent-filter>
```

iOS uses custom URL scheme:
```xml
<string>com.moustra.app</string>
```

### Screen Navigation Pattern

All screens use consistent back navigation handling:

```dart
// For screens accessed from cage grid
GoRoute(
  path: '/cage/:cageUuid',
  pageBuilder: (context, state) {
    final fromCageGrid = state.uri.queryParameters['fromCageGrid'] == 'true';
    return MaterialPage(
      child: CageDetailScreen(fromCageGrid: fromCageGrid),
    );
  },
),
```

This allows conditional "return to grid" behavior after edits.

### Barcode Scanner Integration

The scanner returns scanned value via Navigator.pop:

```dart
// Opening scanner
final barcode = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
);
if (barcode != null) {
  // Use barcode
}

// In scanner, on detection
Navigator.of(context).pop(code);
```

### Widget Reuse Strategy

Common patterns are extracted to `lib/widgets/shared/`:

| Widget | Purpose |
|--------|---------|
| `select_animal.dart` | Animal picker dropdown |
| `select_cage.dart` | Cage picker dropdown |
| `select_strain.dart` | Strain picker with color |
| `select_date.dart` | Date picker with formatting |
| `select_mating.dart` | Mating picker for litters |
| `multi_select_animal.dart` | Multi-animal selection |
| `button.dart` | Styled button variants |

### Syncfusion DataGrid Usage

List screens use Syncfusion DataGrid for tables:

```dart
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// Common pattern in animals_screen.dart, cages_list_screen.dart, etc.
SfDataGrid(
  source: _dataSource,
  columns: [
    GridColumn(columnName: 'tag', label: Text('Tag')),
    // ...
  ],
  allowSorting: true,
  allowFiltering: true,
)
```

### Form Validation Pattern

Forms use AutofillGroup for credential saving:

```dart
AutofillGroup(
  child: Form(
    key: _formKey,
    child: Column(
      children: [
        TextFormField(
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
        ),
        TextFormField(
          autofillHints: const [AutofillHints.password],
          validator: _validatePassword,
        ),
      ],
    ),
  ),
)

// On successful submit:
TextInput.finishAutofillContext(shouldSave: true);
```

---

## Mobile vs Web Feature Gaps

Key features missing from mobile (see [docs/FEATURE-PARITY.md](docs/FEATURE-PARITY.md)):

**High Priority:**
- Create animals from litter (wean flow)
- End litter(s) batch operation
- User invitation acceptance via deep link

**Medium Priority:**
- Cage utilization metrics
- Password reset flow
- Animal family tree visualization

**Not Planned for Mobile:**
- CSV import/data migration
- AI Chat
- Advanced table customization
