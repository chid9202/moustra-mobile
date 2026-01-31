# Contributing to Moustra Mobile

This document outlines the development workflow and contribution guidelines for the Moustra mobile application.

## Development Workflow

### 1. Setup Development Environment

```bash
# Clone repository
git clone <repository-url>
cd moustra-mobile

# Install Flutter dependencies
flutter pub get

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Verify setup
flutter doctor
flutter analyze
```

### 2. Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch for features |
| `feature/*` | New feature development |
| `bugfix/*` | Bug fixes |
| `hotfix/*` | Urgent production fixes |

### 3. Creating a Feature Branch

```bash
# Start from latest main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 4. Development Cycle

1. **Write Code** - Implement your feature/fix
2. **Generate Code** - Run `dart run build_runner build -d` if modifying DTOs
3. **Lint** - Run `flutter analyze` and fix issues
4. **Test** - Write and run tests
5. **Commit** - Make atomic commits with clear messages

### 5. Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code formatting
- `refactor` - Code restructuring
- `test` - Adding/updating tests
- `chore` - Build/tooling changes

Examples:
```
feat(animals): add genotype display to animal detail screen

fix(auth): resolve token refresh race condition

test(cages): add unit tests for cage API client
```

### 6. Pull Request Process

1. **Push Branch**
   ```bash
   git push -u origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Clear title describing the change
   - Description with context and testing steps
   - Link related issues

3. **Code Review**
   - Address review feedback
   - Keep PR focused and reasonable size
   - Ensure CI passes

4. **Merge**
   - Squash and merge to keep history clean
   - Delete feature branch after merge

## Code Quality

### Pre-commit Checklist

- [ ] Code compiles without errors
- [ ] `flutter analyze` passes with no issues
- [ ] All tests pass (`./run_tests.sh all`)
- [ ] New code has appropriate test coverage
- [ ] Documentation updated if needed
- [ ] No console.log/print statements in production code

### Linting

The project uses `flutter_lints` for static analysis. Configuration is in `analysis_options.yaml`.

```bash
# Check for lint issues
flutter analyze

# Auto-fix issues
dart fix --apply
```

### Code Formatting

```bash
# Format all Dart files
dart format lib test integration_test
```

## Testing Requirements

### Minimum Coverage

- **DTOs**: Unit tests for serialization/deserialization
- **API Clients**: Unit tests with mocked HTTP responses
- **Screens**: Widget tests for key user flows
- **Widgets**: Unit tests for reusable components

### Running Tests

```bash
# All tests
./run_tests.sh all

# With coverage
./run_tests.sh coverage

# Specific file
flutter test test/path/to/test_file.dart
```

See [TESTING.md](TESTING.md) for detailed testing guidelines.

## Feature Implementation Guide

### Adding a New Entity

1. **Define DTOs** (`lib/services/dtos/`)
   ```dart
   // entity_dto.dart
   @JsonSerializable()
   class EntityDto { ... }
   
   // post_entity_dto.dart (for creating)
   @JsonSerializable()
   class PostEntityDto { ... }
   
   // put_entity_dto.dart (for updating)
   @JsonSerializable()
   class PutEntityDto { ... }
   ```

2. **Generate Code**
   ```bash
   dart run build_runner build -d
   ```

3. **Create API Client** (`lib/services/clients/entity_api.dart`)
   ```dart
   class EntityApi {
     Future<EntityDto> getEntity(String uuid) async { ... }
     Future<List<EntityDto>> getEntities() async { ... }
     Future<EntityDto> createEntity(PostEntityDto dto) async { ... }
     Future<EntityDto> updateEntity(String uuid, PutEntityDto dto) async { ... }
     Future<void> deleteEntity(String uuid) async { ... }
   }
   
   final entityApi = EntityApi();
   ```

4. **Create Store** (`lib/stores/entity_store.dart`)
   ```dart
   final entityStore = ValueNotifier<List<EntityStoreDto>?>(null);
   ```

5. **Create Screen** (`lib/screens/entity_screen.dart`)

6. **Add Route** (`lib/app/router.dart`)

7. **Write Tests**
   - DTO tests
   - API client tests
   - Widget tests

### Adding a New Screen

1. Create screen file: `lib/screens/new_screen.dart`
2. Add route in `lib/app/router.dart`
3. Create widget test: `test/screens/new_screen_test.dart`
4. Add integration test robot if needed

## Troubleshooting

### Common Issues

**Build Failures**
```bash
flutter clean
flutter pub get
dart run build_runner build -d
flutter run
```

**Generated Code Out of Sync**
```bash
find . -name "*.g.dart" -delete
dart run build_runner build -d
```

**Dependency Conflicts**
```bash
flutter pub upgrade
```

**Test Failures**
```bash
# Run with verbose output
flutter test --reporter expanded test/path/to/test.dart
```

## Getting Help

- Check existing documentation in the repo
- Review similar implementations in the codebase
- Ask in team chat/discussion channels
