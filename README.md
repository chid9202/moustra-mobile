# Moustra

## Getting Started

### Auth0

Run with dart-defines:

```bash
flutter run --dart-define=AUTH0_DOMAIN=login-dev.moustra.com --dart-define=AUTH0_CLIENT_ID=q9MiH8vXt6H5yXZ96BcW16qVuKPXXO6K
```

Android callback URL to configure in Auth0:

```
https://login-dev.moustra.com/android/com.example.grid_view/callback
```

iOS callback URL to configure in Auth0:

```
https://login-dev.moustra.com/ios/com.example.grid-view/callback
```

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Commands

- clean everything and run

```
flutter clean
adb uninstall com.moustra.app.dev
flutter pub get
flutter run -d emulator-5556
```

- to run a build runner for json serializer

```
dart run build_runner build -d
```
