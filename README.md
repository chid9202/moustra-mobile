# Moustra Mobile

A Flutter application for managing laboratory animal colonies and research workflows.

## Getting Started

### Quick Start (Development)

The app is pre-configured with development/staging environment variables. Simply run:

```bash
flutter run
```

### Auth0 Setup

#### Development Environment

The app loads environment variables from `.env` automatically:

```bash
# Simply run the app
flutter run

# Or use the run script
./run_app.sh staging debug
```

**Android:**

```
https://login-dev.moustra.com/android/com.moustra.app/callback
```

**iOS:**

```
https://login-dev.moustra.com/ios/com.moustra.app/callback
```

### Production Builds

#### iOS Build

```bash
flutter build ios --release --dart-define=ENV_FILENAME=.env.production
```

#### Android Build

**App Bundle (for Google Play Store):**

```bash
# Use the build script (recommended - works around ARM Mac symbol stripping issue)
./build_android.sh
```

**APK (for direct distribution):**

```bash
flutter build apk --release --dart-define=ENV_FILENAME=.env.production
```

**Note:** The `flutter build appbundle` command may show a symbol stripping error on ARM Macs, but the app bundle is still created successfully. The `build_android.sh` script handles this automatically.

#### Using the Build Script (All Platforms)

```bash
./build_production.sh android
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Development Commands

### Clean Build

Clean everything and run:

```bash
flutter clean
adb uninstall com.moustra.app
flutter pub get
flutter run
```

### Code Generation

Run build runner for JSON serialization:

```bash
dart run build_runner build -d
```

### Testing

Run all tests:

```bash
./run_tests.sh
```

Or run specific test file:

```bash
flutter test test/path/to/test_file.dart
```

## VS Code Launch Configurations

The project includes pre-configured launch configurations. All use the current `.env` file:

- **Flutter (debug)** - Development with hot reload
- **Flutter (profile)** - Performance profiling
- **Flutter (release)** - Fully optimized build
- **Flutter tests** - Run test suite

**Switch environments:** Copy the desired `.env.production` or use default `.env`

Select from the dropdown in the Run and Debug panel or press `F5`.

## Project Structure

```
lib/
├── app/              # App initialization and routing
├── config/           # Environment and configuration
├── screens/          # UI screens
├── widgets/          # Reusable UI components
├── services/         # API clients and business logic
├── stores/           # State management (MobX)
├── helpers/          # Utility functions
└── constants/        # App constants
```

## Resources

- [ENV_CONFIG.md](ENV_CONFIG.md) - Environment configuration guide
- [Flutter Documentation](https://docs.flutter.dev/)
- [Auth0 Flutter SDK](https://github.com/auth0/auth0-flutter)
