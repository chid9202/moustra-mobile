# Quick Guide: Testing Face Login on Physical iPhone

## The Problem

When using `flutter run` in debug mode, closing the app also stops the Flutter process, making it impossible to test app relaunch scenarios.

## The Solution

Install the app directly on your iPhone so it runs independently.

## Quick Steps

### Step 1: Build and Install the App

```bash
# Build iOS release version
flutter build ios --release

# Install to your connected iPhone
flutter install
```

**OR** use this simpler one-liner:

```bash
# Build and run in release mode (stays installed)
flutter run --release
```

Once the app launches successfully, you can:

- Press `Ctrl+C` in the terminal (app stays on your iPhone)
- Close the app on your iPhone (swipe up)
- Relaunch from iPhone home screen

### Step 2: Test Face Login Flow

1. **First Time - Store Refresh Token:**

   - Launch app from iPhone home screen
   - Tap "Sign in" button
   - Complete Auth0 login
   - You should land on dashboard
   - ✅ Refresh token is now stored

2. **Close App Completely:**

   - On iPhone: Swipe up from bottom
   - Swipe up on the app card to fully close it
   - Or use App Switcher and swipe up

3. **Relaunch App:**

   - Tap app icon from home screen
   - **Expected**: After ~500ms, Face ID prompt should appear automatically
   - Authenticate with Face ID
   - ✅ You should be logged in automatically without password!

4. **If Automatic Unlock Doesn't Work:**
   - Look for "Unlock with Face ID" button above "Sign in" button
   - Tap it to manually trigger Face ID

## Alternative: Using Xcode

```bash
# Build the app
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

In Xcode:

1. Select your iPhone from device dropdown (top toolbar)
2. Click the Play button (▶️) or press `Cmd+R`
3. Wait for app to install and launch
4. You can now close Xcode - the app stays on your iPhone
5. Test closing/relaunching from iPhone home screen

## Troubleshooting

**App not installing?**

- Make sure iPhone is unlocked and "Trust This Computer" is accepted
- Check: `flutter devices` should list your iPhone

**Face ID not working?**

- Make sure Face ID is enabled in iPhone Settings
- Verify Face ID is enrolled for your face
- Check you're testing on a physical device (not simulator)

**Not seeing biometric prompt?**

- Ensure you completed initial login at least once (to store refresh token)
- Check device has biometrics enabled
- Try the manual "Unlock with Face ID" button if available

## What to Expect

✅ **Working correctly:**

- Face ID prompt appears ~500ms after login screen loads
- OR "Unlock with Face ID" button is visible
- Successful Face ID unlocks you immediately
- No password required after first login

❌ **Not working:**

- No Face ID prompt appears
- No unlock button visible
- Must always use "Sign in" button

If not working, check:

1. Did you complete initial login? (stores refresh token)
2. Is Face ID enabled on device?
3. Are you testing on a physical device?
4. Check console logs for errors (if using Xcode or `flutter run --release`)
