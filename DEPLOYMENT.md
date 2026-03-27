# Moustra Mobile Deployment Guide

This guide describes the supported release flow for Moustra mobile.

## Release Model

The release process is split into three actions:

1. `prepare`
   - Bumps the version in `pubspec.yaml`
   - Commits the bump on `main`
   - Optionally tags the release commit
2. `candidate`
   - Builds the app from the current working tree using the version in `pubspec.yaml`
   - Uploads iOS to TestFlight
   - Uploads Android to the selected Google Play track
3. `promote`
   - Reuses an existing uploaded build
   - Submits iOS for App Store review
   - Promotes Android between Play tracks without rebuilding

This is simpler than the previous flow because deployment no longer creates `release/*` branches or mutates git state while uploading to the stores.

```mermaid
flowchart TD
    A["main branch"] --> B["prepare<br/>bump pubspec.yaml<br/>commit and optional tag"]
    B --> C["candidate<br/>build from committed version"]
    C --> D["iOS: upload to TestFlight"]
    C --> E["Android: upload to internal/beta/production"]
    D --> F["promote<br/>submit existing iOS build for App Store review"]
    E --> G["promote<br/>advance existing Android release between Play tracks"]
```

## Entry Points

### Unified Script

Run all release actions from the project root:

```bash
./scripts/deploy.sh prepare --bump patch --push --tag
./scripts/deploy.sh candidate --platform both --android-track internal
./scripts/deploy.sh promote --platform both --android-to production --ios-build 47
```

### Platform Scripts

Use these when you only need one platform:

```bash
./scripts/deploy-ios.sh candidate
./scripts/deploy-ios.sh promote --build 47

./scripts/deploy-android.sh candidate --track internal
./scripts/deploy-android.sh promote --to production
```

## Version Management

The app version is stored in `pubspec.yaml`:

```yaml
version: 1.0.23+47
```

- `1.0.23` is the marketing version.
- `47` is the build number.

`./scripts/deploy.sh prepare` always reads the current version from a clean checkout of `main`, increments the build number, and commits only `pubspec.yaml`.

### Prepare Options

```bash
./scripts/deploy.sh prepare --bump build|patch|minor|major [--push] [--tag] [--skip-tests]
./scripts/deploy.sh prepare --version x.y.z [--push] [--tag] [--skip-tests]
```

Examples:

```bash
# 1.0.23+47 -> 1.0.24+48
./scripts/deploy.sh prepare --bump patch --push --tag

# 1.0.23+47 -> 1.0.23+48
./scripts/deploy.sh prepare --bump build --push --tag

# 1.0.23+47 -> 2.0.0+48
./scripts/deploy.sh prepare --version 2.0.0 --push --tag
```

## Candidate Uploads

Candidate uploads build from the current working tree using the version already set in `pubspec.yaml`.

### iOS

```bash
./scripts/deploy.sh candidate --platform ios
```

This will:

1. Verify `.env.production`
2. Build Flutter iOS in release mode
3. Archive the IPA with Fastlane
4. Upload the IPA to TestFlight

### Android

```bash
./scripts/deploy.sh candidate --platform android --android-track internal
```

Supported Android upload tracks:

- `internal`
- `beta`
- `production`

This will:

1. Verify `.env.production`
2. Build the AAB
3. Verify the AAB includes `.env.production`
4. Upload the AAB to the selected Play track

### Both Platforms

```bash
./scripts/deploy.sh candidate --platform both --android-track internal
```

By default, `candidate` runs `flutter test` first. Use `--skip-tests` only when CI has already validated the commit.

## Promotions

Promotions do not rebuild the app and do not bump the version.

### iOS

```bash
./scripts/deploy.sh promote --platform ios --ios-build 47
```

If `--ios-build` is omitted, Fastlane uses the build number from `pubspec.yaml`.

### Android

```bash
./scripts/deploy.sh promote --platform android --android-to beta
./scripts/deploy.sh promote --platform android --android-to production
```

- `beta` promotes `internal -> beta`
- `production` promotes `beta -> production`

### Both Platforms

```bash
./scripts/deploy.sh promote --platform both --android-to production --ios-build 47
```

## Local Prerequisites

### iOS

- Xcode with command line tools
- Apple Developer account access
- Valid signing configuration on the machine

### Android

- Android SDK
- `android/android-secret.json`
- `android/key.properties`
- `android/upload-keystore.jks`

### Ruby / Fastlane

```bash
cd ios && bundle install
cd android && bundle install
```

## Troubleshooting

### Dirty Working Tree

`prepare` refuses to run if git has tracked or untracked changes. `candidate` and `promote` do not require a clean tree.

### iOS Version Rejected

If App Store Connect says the version train is closed or the version must be higher, run a new `prepare` with `patch`, `minor`, or `major` instead of another build-only bump.

### iOS Upload Is Slow Or Fails

The upload script retries Fastlane uploads and falls back to `xcrun altool`. Network instability to Apple’s CDN is the common cause.

### Android Uploaded The Wrong Artifact

The Android candidate script now deletes any previous release AAB before building, so stale artifacts are not reused.

## Metadata

- iOS metadata: `ios/fastlane/metadata/`
- Android metadata: `android/fastlane/metadata/`
