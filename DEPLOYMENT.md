# Moustra Mobile Deployment Guide

This guide covers how to deploy Moustra to the App Store (iOS) and Google Play Store (Android) using Fastlane.

## Prerequisites

### iOS
- Xcode installed with command line tools
- Valid Apple Developer account
- App Store Connect access
- Certificates and provisioning profiles configured

### Android
- Android SDK installed
- `android-secret.json` - Google Play service account key (place in `android/`)
- `key.properties` - Signing configuration (place in `android/`)
- `upload-keystore.jks` - Upload keystore file

### Ruby & Fastlane
```bash
# Install Ruby (recommended via rbenv or asdf)
# Install bundler
gem install bundler

# Install Fastlane dependencies (run in ios/ and android/ directories)
cd ios && bundle install
cd android && bundle install
```

## Version Management

The app version is managed in `pubspec.yaml`:
```yaml
version: 1.0.7+26  # format: VERSION_NAME+BUILD_NUMBER
```

Update this before each release. Fastlane lanes automatically sync this version to native projects.

## iOS Deployment

Navigate to the `ios/` directory first:
```bash
cd ios
```

### Available Lanes

| Lane | Description |
|------|-------------|
| `bundle exec fastlane build` | Build the app for App Store |
| `bundle exec fastlane beta` | Build and upload to TestFlight |
| `bundle exec fastlane release` | Build and upload to App Store Connect |
| `bundle exec fastlane sync_metadata` | Download metadata from App Store Connect |
| `bundle exec fastlane upload_metadata` | Upload metadata and screenshots only |

### Common Workflows

**TestFlight Release:**
```bash
# 1. Update version in pubspec.yaml
# 2. Build Flutter app with production environment
flutter build ios --release --dart-define-from-file=.env.production

# 3. Upload to TestFlight
cd ios
bundle exec fastlane beta
```

**App Store Release:**
```bash
# 1. Update version in pubspec.yaml
# 2. Build Flutter app
flutter build ios --release --dart-define-from-file=.env.production

# 3. Upload to App Store Connect
cd ios
bundle exec fastlane release
```

## Android Deployment

Navigate to the `android/` directory first:
```bash
cd android
```

### Available Lanes

| Lane | Description |
|------|-------------|
| `bundle exec fastlane build` | Build release AAB |
| `bundle exec fastlane build_apk` | Build release APK |
| `bundle exec fastlane internal` | Upload to Internal Testing track |
| `bundle exec fastlane beta` | Upload to Beta (Closed Testing) track |
| `bundle exec fastlane deploy` | Upload to Production track |
| `bundle exec fastlane promote_to_beta` | Promote Internal to Beta |
| `bundle exec fastlane promote_to_production` | Promote Beta to Production |
| `bundle exec fastlane sync_metadata` | Download metadata from Google Play |
| `bundle exec fastlane upload_metadata` | Upload metadata only |

### Common Workflows

**Internal Testing Release:**
```bash
# 1. Update version in pubspec.yaml
# 2. Build Flutter app
flutter build appbundle --release --dart-define-from-file=.env.production

# 3. Upload to Internal Testing
cd android
bundle exec fastlane internal
```

**Production Release:**
```bash
# 1. Update version in pubspec.yaml
# 2. Build Flutter app
flutter build appbundle --release --dart-define-from-file=.env.production

# 3. Upload to Production (or promote from beta)
cd android
bundle exec fastlane deploy
# OR
bundle exec fastlane promote_to_production
```

## Quick Release Commands

For convenience, you can run these from the project root:

```bash
# iOS TestFlight
flutter build ios --release --dart-define-from-file=.env.production && cd ios && bundle exec fastlane beta

# Android Internal
flutter build appbundle --release --dart-define-from-file=.env.production && cd android && bundle exec fastlane internal
```

## Environment Files

- `.env` - Development environment
- `.env.production` - Production environment (used for releases)
- `.env.test` - Test environment

## Troubleshooting

### iOS: "No profiles matching" error
Ensure your provisioning profiles are up to date in Apple Developer Portal and downloaded to your Mac.

### Android: "Unauthorized" error
Verify that `android-secret.json` contains valid service account credentials with Google Play Developer API access.

### Build fails with version mismatch
Make sure to build the Flutter app before running Fastlane:
```bash
flutter build ios --release  # or flutter build appbundle --release
```

## Metadata Locations

- iOS: `ios/fastlane/metadata/`
- Android: `android/fastlane/metadata/`

Update these files to change app descriptions, keywords, screenshots, etc.

---

## GitHub Actions CI/CD

The project includes automated deployment via GitHub Actions. The workflow automatically handles version bumping and deploying to both platforms.

### Setting Up GitHub Secrets

Go to your repository's **Settings > Secrets and variables > Actions** and add the following secrets:

#### Required for iOS

| Secret | Description |
|--------|-------------|
| `APPSTORE_API_KEY_ID` | App Store Connect API Key ID (e.g., `ABC123XYZ`) |
| `APPSTORE_API_ISSUER_ID` | App Store Connect API Issuer ID (UUID format) |
| `APPSTORE_API_PRIVATE_KEY` | Contents of the `.p8` private key file |

**To get App Store Connect API credentials:**
1. Go to [App Store Connect > Users and Access > Keys](https://appstoreconnect.apple.com/access/api)
2. Click "+" to generate a new key with "App Manager" access
3. Download the `.p8` file (you can only download once!)
4. Copy the Key ID and Issuer ID from the page

#### Required for Android

| Secret | Description |
|--------|-------------|
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Full contents of `android-secret.json` |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file |
| `ANDROID_KEY_ALIAS` | Keystore key alias (e.g., `upload`) |
| `ANDROID_KEY_PASSWORD` | Password for the key |
| `ANDROID_STORE_PASSWORD` | Password for the keystore |

**To encode keystore as base64:**
```bash
base64 -i android/upload-keystore.jks | pbcopy  # macOS (copies to clipboard)
# OR
base64 android/upload-keystore.jks > keystore.txt  # Linux (saves to file)
```

#### Required for Both

| Secret | Description |
|--------|-------------|
| `ENV_PRODUCTION` | Full contents of `.env.production` file |

### Running a Deployment

1. Go to **Actions** tab in your GitHub repository
2. Select **"Deploy to App Stores"** workflow
3. Click **"Run workflow"**
4. Choose your options:
   - **Platform**: `ios`, `android`, or `both`
   - **Version bump**: `build`, `patch`, `minor`, or `major`
   - **Track**: `internal`, `beta`, or `production`
5. Click **"Run workflow"**

### Version Bump Options

| Option | Before | After | Use Case |
|--------|--------|-------|----------|
| `build` | 1.0.7+26 | 1.0.7+27 | Bug fixes, minor updates |
| `patch` | 1.0.7+26 | 1.0.8+27 | Bug fixes for release |
| `minor` | 1.0.7+26 | 1.1.0+27 | New features |
| `major` | 1.0.7+26 | 2.0.0+27 | Breaking changes |

### What the Workflow Does

1. **Bumps version** in `pubspec.yaml` and commits it
2. **Builds Flutter app** with production environment
3. **Deploys to selected platforms** via Fastlane
4. **Creates a git tag** (e.g., `v1.0.8+27`)

### Workflow File Location

`.github/workflows/deploy.yml`

### Typical Release Flow

```
1. Merge your feature branch to main
2. Go to Actions > Deploy to App Stores > Run workflow
3. Select: platform=both, version_bump=patch, track=internal
4. Wait for deployment to complete
5. Test on internal/TestFlight
6. Run again with track=production when ready
```
