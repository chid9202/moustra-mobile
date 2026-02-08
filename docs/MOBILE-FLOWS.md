# Mobile Flows - Moustra Flutter App

This document details the implementation of key user flows in the Moustra mobile app, focusing on authentication, deep linking, and mobile-specific features.

---

## Table of Contents

1. [Authentication Flow](#authentication-flow)
2. [Sign-Up Flow](#sign-up-flow)
3. [Invitation Acceptance](#invitation-acceptance)
4. [Data Migration](#data-migration)
5. [Mobile-Specific Features](#mobile-specific-features)

---

## Authentication Flow

### Overview

The app uses Auth0 for authentication with support for multiple login methods:
- Email/password login (Resource Owner Password Grant)
- Social login (Google, Microsoft via OAuth 2.0)
- Biometric unlock (Face ID, Touch ID, fingerprint)

### Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `AuthService` | `lib/services/auth_service.dart` | Core authentication logic |
| `SecureStore` | `lib/services/secure_store.dart` | Token storage |
| `LoginScreen` | `lib/screens/login_screen.dart` | Login UI |
| `authState` | `lib/stores/auth_store.dart` | Global auth state |

### Auth0 Configuration

Environment variables (`.env`):
```bash
AUTH0_DOMAIN=login-dev.moustra.com
AUTH0_CLIENT_ID=<client_id>
AUTH0_SCHEME=com.moustra.app
AUTH0_AUDIENCE=https://api.moustra.com
AUTH0_CONNECTION=Username-Password-Authentication
```

### Token Storage

Tokens are stored using `flutter_secure_storage` with platform-specific security:

**iOS:**
- Uses iOS Keychain
- Accessibility: `first_unlock_this_device` (tokens available after first device unlock)

**Android:**
- Uses EncryptedSharedPreferences
- Encryption via Android Keystore

```dart
// SecureStore configuration
static const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
```

### Login Flow Diagram

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ LoginScreen │────▶│ AuthService  │────▶│ Auth0 API    │
└─────────────┘     └──────────────┘     └──────────────┘
       │                   │                    │
       │                   │    Token Response  │
       │                   │◀───────────────────│
       │                   │
       │            ┌──────▼──────┐
       │            │ SecureStore │
       │            │ (save tokens)│
       │            └──────┬──────┘
       │                   │
       │            ┌──────▼──────┐
       │            │ authState   │
       │            │ .value=true │
       │            └──────┬──────┘
       │                   │
       │            ┌──────▼──────┐
       │            │ profileApi  │
       │            │ .getProfile │
       │            └──────┬──────┘
       │                   │
       ▼                   ▼
┌─────────────────────────────────┐
│         Dashboard               │
└─────────────────────────────────┘
```

### Email/Password Login

Uses Auth0's Resource Owner Password Grant (ROPG):

```dart
// AuthService.loginWithPassword()
final response = await http.post(
  Uri.parse('https://${Env.auth0Domain}/oauth/token'),
  body: jsonEncode({
    'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
    'client_id': Env.auth0ClientId,
    'username': email,
    'password': password,
    'audience': Env.auth0Audience,
    'scope': 'openid profile email offline_access',
    'realm': Env.auth0Connection,
  }),
);
```

### Social Login (Google/Microsoft)

Uses Auth0 Flutter SDK's `webAuthentication`:

```dart
// AuthService.loginWithSocial()
final credentials = await _auth0
    .webAuthentication(scheme: Env.auth0Scheme)
    .login(
      parameters: {
        'connection': connection, // 'google-oauth2' or 'windowslive'
        'audience': Env.auth0Audience,
        'scope': 'openid profile email offline_access',
      },
    );
```

### Biometric Authentication

The app supports Face ID (iOS), Touch ID (iOS), and fingerprint (Android) for re-authentication:

**How it works:**
1. On successful login, refresh token is stored securely
2. On app relaunch, if refresh token exists, biometric prompt appears
3. After biometric success, tokens are refreshed via Auth0
4. User is logged in without entering credentials

```dart
// AuthService.unlockWithBiometrics()
Future<AppCredentials?> unlockWithBiometrics() async {
  if (!await canUseBiometrics()) return null;
  if (!await SecureStore.hasRefreshToken()) return null;

  final authenticated = await _localAuth.authenticate(
    localizedReason: 'Authenticate with Face ID to unlock your account',
  );

  if (!authenticated) return null;
  return await _refreshTokens();
}
```

**Platform Permissions:**

iOS (`Info.plist`):
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to unlock your account and access stored credentials</string>
```

Android (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### Token Refresh

Tokens are refreshed using the stored refresh token:

```dart
// AuthService._refreshTokens()
final response = await http.post(
  Uri.parse('https://${Env.auth0Domain}/oauth/token'),
  body: jsonEncode({
    'grant_type': 'refresh_token',
    'client_id': Env.auth0ClientId,
    'refresh_token': refreshToken,
  }),
);
```

### Post-Login Flow

After successful authentication:

1. Profile is fetched from backend
2. All global stores are initialized in parallel:
   - `accountStore` - User accounts
   - `animalStore` - Animals list
   - `cageStore` - Cages list  
   - `strainStore` - Strains list
   - `geneStore` - Genes
   - `alleleStore` - Alleles
   - `rackStore` - Rack configuration
   - `backgroundStore` - Genetic backgrounds
   - `settingStore` - Lab settings

3. User is navigated to Dashboard

### Logout

```dart
Future<void> logout() async {
  await SecureStore.clearAll();
  _credentials = null;
  authState.value = false;
  errorContextService.clear();
}
```

---

## Sign-Up Flow

### Overview

New users can register via the signup screen with email/password. The flow creates an Auth0 account and then auto-logs in.

### Implementation

Location: `lib/screens/signup_screen.dart`

```dart
// AuthService.signUpWithPassword()
Future<bool> signUpWithPassword(String email, String password) async {
  // 1. Create user via Auth0 Database Connection
  final signupResponse = await http.post(
    Uri.parse('https://${Env.auth0Domain}/dbconnections/signup'),
    body: jsonEncode({
      'client_id': Env.auth0ClientId,
      'email': email,
      'password': password,
      'connection': Env.auth0Connection,
    }),
  );
  
  // 2. Auto-login after successful signup
  return await loginWithPassword(email, password);
}
```

### Password Policy

The signup screen enforces Auth0's password policy with real-time validation:

- Minimum 8 characters
- At least 3 of the following:
  - Lower case letters (a-z)
  - Upper case letters (A-Z)
  - Numbers (0-9)
  - Special characters (!@#$%^&*)

### Error Handling

The signup flow handles specific Auth0 error codes:
- `user_exists` → "An account with this email already exists"
- `invalid_password` → Shows password policy requirements
- `invalid_signup` → "Sign up is not available. Please contact support."

---

## Invitation Acceptance

### Current Status: **NOT IMPLEMENTED**

The mobile app currently does **not** support accepting lab invitations via deep link.

### What Exists

**Android deep link configuration** (`AndroidManifest.xml`):
```xml
<!-- Deep link: app.moustra.com (App Links with autoVerify) -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:scheme="https"
        android:host="app.moustra.com"/>
</intent-filter>
```

**iOS URL scheme** (`Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.moustra.app</string>
        </array>
    </dict>
</array>
```

### Missing Implementation

To implement invitation acceptance:

1. **Router handling** - Add deep link route in `router.dart`:
   ```dart
   GoRoute(
     path: '/invite/:token',
     pageBuilder: (context, state) => MaterialPage(
       child: InviteAcceptScreen(token: state.pathParameters['token']),
     ),
   ),
   ```

2. **Invite API client** - Add to `lib/services/clients/`:
   ```dart
   Future<bool> validateInviteToken(String token) async {...}
   Future<void> acceptInvite(String token) async {...}
   ```

3. **Universal Links (iOS)** - Add Associated Domains entitlement

4. **App Links (Android)** - Host `.well-known/assetlinks.json`

---

## Data Migration

### Current Status: **NOT IMPLEMENTED**

CSV import and data migration features are **web-only**. See [FEATURE-PARITY.md](./FEATURE-PARITY.md) for details.

---

## Mobile-Specific Features

### 1. Barcode Scanning

**Implementation:** `lib/screens/barcode_scanner_screen.dart`

**Package:** `mobile_scanner` ^7.1.4

**Supported Formats:**
- QR Code
- Code128, Code39
- EAN13, EAN8
- UPC-A, UPC-E

**Features:**
- Camera-based scanning with live preview
- Torch (flashlight) toggle
- Manual entry fallback
- Visual scanning guide overlay

**Usage Flow:**
```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│ Cage Grid/   │────▶│ BarcodeScannerScreen │────▶│ Cage Detail  │
│ Cage List    │     │ (scan or manual)     │     │ (by barcode) │
└──────────────┘     └──────────────────────┘     └──────────────┘
```

**Permissions:**

iOS (`Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to scan barcodes for cage identification...</string>
```

Android (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### 2. File Attachments (with Camera/Gallery)

**Implementation:** `lib/widgets/attachment/attachment_list.dart`

**Package:** `file_picker` ^8.0.0

**Features:**
- Upload files from device
- View image attachments inline
- Full-screen image preview with pinch-to-zoom
- Download attachments
- Delete attachments

**API Integration:** `lib/services/clients/attachment_api.dart`
- `getAnimalAttachments()` - List attachments
- `uploadAnimalAttachment()` - Upload file
- `deleteAnimalAttachment()` - Delete attachment
- `getAttachmentLink()` - Get download URL

### 3. Interactive Cage Grid (2D/3D View)

**Implementation:** `lib/screens/cages_grid_screen.dart`

**Features:**
- Drag-and-drop cage organization
- Pinch-to-zoom
- Pan navigation
- Transformation matrix persistence (saves view position)
- Multi-rack support with rack selector
- Search by animal tag, cage ID, or barcode

### 4. Offline Data Caching

**Pattern:** ValueNotifier stores with pre-loaded data

The app pre-loads and caches critical data in global stores:

```dart
// Store pattern
final strainStore = ValueNotifier<List<StrainStoreDto>?>(null);

// Initialization on login
void useStrainStore() async {
  if (strainStore.value != null) return; // Use cached
  strainStore.value = await storeApi.getStrains();
}
```

**Cached entities:**
- Strains (`strainStore`)
- Cages (`cageStore`)
- Animals (`animalStore`)
- Genes (`geneStore`)
- Alleles (`alleleStore`)
- Racks (`rackStore`)
- Accounts (`accountStore`)
- Lab settings (`settingStore`)

**Note:** This is client-side caching, not true offline support. Network is required for operations.

### 5. Platform-Adaptive UI

- SafeArea handling for notches/dynamic islands
- Keyboard-aware scrolling
- Responsive layout constraints (maxWidth: 400 for forms)

### 6. Error Reporting

**Implementation:** `lib/services/error_report_service.dart`

Automatic error context collection:
- Current route/screen
- Navigation breadcrumbs
- User profile info
- App state snapshot

```dart
// Fire-and-forget error reporting
reportError(
  error: e,
  stackTrace: stackTrace,
  context: 'User action: saving cage',
);
```

### 7. Subscription Management (Stripe)

**Implementation:** 
- `lib/screens/settings/subscription_tab.dart`
- `lib/screens/settings/subscription_plans_screen.dart`
- `lib/services/clients/subscription_api.dart`

**Package:** `flutter_stripe` ^12.1.1

**Features:**
- View current subscription
- Browse available plans
- Create payment intent
- Process subscription changes

---

## Platform Configuration Summary

### iOS (`Info.plist`)

| Key | Value | Purpose |
|-----|-------|---------|
| `NSFaceIDUsageDescription` | Face ID unlock message | Biometric auth |
| `NSCameraUsageDescription` | Camera usage message | Barcode scanning |
| `NSPhotoLibraryUsageDescription` | Photo access message | File uploads |
| `CFBundleURLSchemes` | `com.moustra.app` | Auth0 callback & deep links |

### Android (`AndroidManifest.xml`)

| Permission/Feature | Purpose |
|-------------------|---------|
| `INTERNET` | API communication |
| `USE_BIOMETRIC` | Biometric authentication |
| `USE_FINGERPRINT` | Legacy fingerprint auth |
| `CAMERA` | Barcode scanning |
| `android.hardware.camera` | Camera feature (optional) |

### Deep Link Domains

| Platform | Scheme | Host |
|----------|--------|------|
| Android | `https://` | `app.moustra.com` |
| iOS | `com.moustra.app://` | N/A (custom scheme) |
| Auth0 | `${AUTH0_SCHEME}://` | callback/logout paths |

---

## Testing Flows

### Integration Test Example

Location: `integration_test/app_test.dart`

```dart
testWidgets('successful login navigates to dashboard', (tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  final loginRobot = LoginRobot(tester);
  await loginRobot.enterEmail(email);
  await loginRobot.enterPassword(password);
  await loginRobot.tapSignIn();
  await tester.pumpAndSettle(const Duration(seconds: 15));

  final dashboardRobot = DashboardRobot(tester);
  await dashboardRobot.verifyDashboardLoaded();
});
```

### Robot Pattern

Test robots encapsulate screen interactions:

```dart
// integration_test/robots/login_robot.dart
class LoginRobot {
  LoginRobot(this.tester);
  final WidgetTester tester;
  
  Future<void> enterEmail(String email) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
    await tester.pump();
  }
}
```
