# Face Login Testing Guide

This guide explains how to test the Face Login (biometric unlock) functionality.

## Testing on Physical Device (iPhone/Android)

**IMPORTANT**: To properly test app lifecycle (closing and relaunching), you need to install the app so it runs independently of `flutter run`. Here are the best methods:

### Method 1: Build and Install Release Build (Recommended)

This installs the app on your device so it runs independently:

```bash
# Build iOS app
flutter build ios --release

# Install to connected device
flutter install
```

Then launch the app directly from your iPhone's home screen (not through `flutter run`).

### Method 2: Use Profile/Release Mode with flutter run

Run in release or profile mode - the app will stay installed even if you background/close it:

```bash
# Install and run in release mode
flutter run --release

# OR use the run script
./run_app.sh staging release
```

After the app launches, you can:

- Close the terminal or background the process (app stays installed)
- Swipe up on iPhone to close the app completely
- Relaunch from home screen

### Method 3: Build via Xcode

```bash
# Build the iOS app
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your iPhone as the target device
# 2. Click the Play button (or Cmd+R)
# 3. Once installed, you can close Xcode and run the app from your iPhone
```

The app will remain installed on your device even after closing Xcode.

### Method 4: Using Flutter Install Command

```bash
# Build first
flutter build ios --release

# Install to connected device
flutter install --device-id=<your-device-id>

# List connected devices
flutter devices
```

## Prerequisites

1. **Device Requirements**:

   - iOS: Device with Face ID capability (iPhone X or later)
   - Android: Device with fingerprint or face unlock enabled

2. **Initial Setup**:
   - You must first complete a full login using "Sign in" button
   - This will store your refresh token securely

## Testing Steps

### Test 1: Initial Login (Store Refresh Token)

1. **Fresh Install or Clear Data**:

   ```bash
   # If testing on a clean state, clear app data first
   flutter clean
   flutter pub get
   ```

2. **Launch the app** - You should see the login screen

3. **Tap "Sign in"** - Complete Auth0 login flow

   - This will request `offline_access` scope automatically
   - After successful login, refresh token will be stored securely
   - You should be redirected to the dashboard

4. **Verify tokens are stored**:
   - The app should work normally
   - Check logs for any errors (though tokens won't be logged for security)

### Test 2: Biometric Unlock on App Relaunch

1. **Close the app completely** (not just background)

   - On iOS: Swipe up and remove from app switcher
   - On Android: Remove from recent apps

2. **Relaunch the app**

3. **Expected Behavior**:

   - Login screen appears
   - After ~500ms, biometric prompt should appear automatically
   - If biometric prompt doesn't appear automatically, you should see an "Unlock with Face ID" (or "Unlock with Biometrics") button

4. **Authenticate with biometrics**:
   - Complete the biometric prompt (Face ID / fingerprint)
   - On success: You should be automatically logged in and redirected to dashboard
   - No password required!

### Test 3: Manual Biometric Unlock Button

1. **If automatic unlock doesn't trigger**, look for the unlock button on login screen:

   - Button appears above the "Sign in" button
   - Shows Face ID icon on iOS, fingerprint icon on Android
   - Text: "Unlock with Face ID" (iOS) or "Unlock with Biometrics" (Android)

2. **Tap the unlock button**

3. **Complete biometric authentication**

4. **Verify**: You should be logged in without entering password

### Test 4: Failure Scenarios

#### Test 4a: User Cancels Biometric

1. Relaunch app
2. When biometric prompt appears, cancel it (don't authenticate)
3. **Expected**: Stay on login screen, no error message
4. You can still use "Sign in" button for full login

#### Test 4b: No Biometrics Enrolled

1. Disable biometrics on device (or test on device without biometrics)
2. Relaunch app
3. **Expected**: No unlock button shown, only "Sign in" button visible

#### Test 4c: Expired Refresh Token

1. If refresh token expires or is invalid, biometric unlock will fail
2. **Expected**: Force full login via "Sign in" button

## Debugging

### Check if Refresh Token is Stored

Add temporary debug code to verify:

```dart
// In login_screen.dart, in _checkBiometricAvailability():
final hasRefresh = await SecureStore.hasRefreshToken();
print('Has refresh token: $hasRefresh'); // Remove after testing
```

### Check Biometric Availability

```dart
final canUse = await authService.canUseBiometrics();
print('Can use biometrics: $canUse'); // Remove after testing
```

### Common Issues

1. **Biometric prompt doesn't appear**:

   - Check device has biometrics enabled
   - Check `NSFaceIDUsageDescription` is in iOS Info.plist
   - Check Android permissions in AndroidManifest.xml
   - Verify refresh token exists (complete initial login first)

2. **"Unlock" button not showing**:

   - Ensure you've completed initial login at least once
   - Check biometrics are available: `authService.canUseBiometrics()`
   - Check refresh token exists: `SecureStore.hasRefreshToken()`

3. **Biometric unlock fails silently**:
   - Check device logs for errors
   - Verify Auth0 credentials manager has valid credentials
   - Ensure network connectivity for token refresh

## Manual Test Checklist

- [ ] Initial login stores refresh token
- [ ] App relaunch shows biometric prompt (or unlock button)
- [ ] Biometric authentication succeeds and logs in automatically
- [ ] Canceling biometric keeps user on login screen
- [ ] Unlock button only shows when biometrics available and refresh token exists
- [ ] Expired tokens force full login
- [ ] Logout clears all stored tokens

## Platform-Specific Notes

### iOS

- Requires Face ID capable device (iPhone X or later)
- Face ID must be enrolled in device settings
- Permission description must be in Info.plist

### Android

- Requires fingerprint or face unlock enabled
- Min SDK 23 (Android 6.0)
- Biometric permission in AndroidManifest.xml

## Troubleshooting

If Face Login isn't working:

1. **Verify dependencies are installed**:

   ```bash
   flutter pub get
   ```

2. **Check platform configuration**:

   - iOS: `Info.plist` has `NSFaceIDUsageDescription`
   - Android: `AndroidManifest.xml` has biometric permissions

3. **Test on physical device** (biometrics don't work in simulators/emulators reliably)

4. **Clear app data and retry**:

   ```bash
   # iOS
   flutter run --release
   # Then delete and reinstall app

   # Android
   flutter run --release
   # Or clear app data from device settings
   ```
