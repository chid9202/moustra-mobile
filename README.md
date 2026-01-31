# Moustra Mobile

A Flutter application for managing laboratory animal colonies and research workflows. Moustra helps researchers track animals, cages, strains, matings, litters, and related data in laboratory settings.

## Features

- **Animal Management** - Track individual animals with genotypes, lineage, and health records
- **Cage Management** - Organize animals in cages with rack visualization (2D/3D grid view)
- **Strain Management** - Define and manage genetic strains with color coding
- **Mating & Litter Tracking** - Record breeding pairs and offspring
- **Dashboard Analytics** - View colony statistics and metrics
- **Barcode Scanning** - Quickly identify animals and cages
- **Multi-platform** - iOS, Android, and Web support

See [FEATURES.md](FEATURES.md) for the complete feature list.

## Quick Start

### Prerequisites

- Flutter SDK ^3.9.0
- Dart SDK ^3.9.0
- iOS: Xcode with command line tools
- Android: Android SDK

### Development Setup

```bash
# Clone and install dependencies
git clone <repository-url>
cd moustra-mobile
flutter pub get

# Copy environment template
cp .env.example .env
# Edit .env with your configuration

# Run the app
flutter run
```

### Environment Configuration

The app uses environment files for configuration:

| File | Purpose |
|------|---------|
| `.env` | Development (default) |
| `.env.production` | Production builds |
| `.env.test` | Test environment |

Required variables (see `.env.example`):
- `API_BASE_URL` - Backend API endpoint
- `AUTH0_DOMAIN` - Auth0 tenant domain
- `AUTH0_CLIENT_ID` - Auth0 application client ID
- `AUTH0_SCHEME` - OAuth callback scheme
- `AUTH0_AUDIENCE` - API audience identifier

## Development

### Running the App

```bash
# Development mode
flutter run

# With specific environment
flutter run --dart-define=ENV_FILENAME=.env.production

# Production release
flutter run --release --dart-define=ENV_FILENAME=.env.production
```

### Code Generation

Run after modifying DTOs with `@JsonSerializable`:

```bash
dart run build_runner build -d
```

### Testing

```bash
# Run all tests
./run_tests.sh all

# Run with coverage
./run_tests.sh coverage

# Run specific test
flutter test test/path/to/test_file.dart

# Integration tests (requires device/emulator)
flutter test integration_test/app_test.dart
```

### Linting

```bash
flutter analyze
dart fix --apply
```

### Clean Build

```bash
flutter clean
flutter pub get
dart run build_runner build -d
flutter run
```

## Project Structure

```
lib/
├── app/              # App initialization, routing, theming
├── config/           # Environment configuration
├── screens/          # UI screens (one per route)
├── widgets/          # Reusable UI components
├── services/         # API clients and DTOs
│   ├── clients/      # API client classes
│   └── dtos/         # Data Transfer Objects
├── stores/           # State management (ValueNotifier)
├── helpers/          # Utility functions
└── constants/        # App constants

test/                 # Unit and widget tests
integration_test/     # Integration tests
```

## Building for Release

### iOS

```bash
flutter build ios --release --dart-define-from-file=.env.production
cd ios && bundle exec fastlane beta  # TestFlight
```

### Android

```bash
flutter build appbundle --release --dart-define-from-file=.env.production
cd android && bundle exec fastlane internal  # Internal testing
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions and CI/CD setup.

## VS Code Configuration

Pre-configured launch configurations are available:

- **Flutter (debug)** - Development with hot reload
- **Flutter (profile)** - Performance profiling
- **Flutter (release)** - Optimized build
- **Flutter tests** - Run test suite

Select from the Run and Debug panel or press `F5`.

## Documentation

| Document | Description |
|----------|-------------|
| [AGENTS.md](AGENTS.md) | AI agent development guide |
| [FEATURES.md](FEATURES.md) | Complete feature list |
| [MISSING-FEATURES.md](MISSING-FEATURES.md) | Features not yet implemented |
| [DEPLOYMENT.md](DEPLOYMENT.md) | App store deployment guide |
| [TESTING.md](TESTING.md) | Testing strategy and guidelines |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution workflow |

## Tech Stack

- **Framework**: Flutter / Dart
- **State Management**: MobX (ValueNotifier pattern)
- **Routing**: go_router
- **Authentication**: Auth0
- **UI Components**: Syncfusion DataGrid, FL Chart
- **Storage**: flutter_secure_storage, shared_preferences
- **Deployment**: Fastlane, GitHub Actions

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and guidelines.

## License

Proprietary - All rights reserved.
