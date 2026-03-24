# Persistent Login (Session Persistence)

## Overview

Moustra mobile keeps users logged in across app restarts using **refresh token rotation** with secure on-device storage. When a user logs in, the app stores an Auth0 refresh token in platform-native secure storage (iOS Keychain / Android EncryptedSharedPreferences). On subsequent launches, the app silently exchanges the refresh token for a new access token — no login screen shown.

## How It Works

### Login Flow
1. User logs in via email/password (ROPG) or social provider (Google/Microsoft)
2. Auth0 returns `access_token`, `id_token`, `refresh_token`, and `expires_at`
3. All tokens are saved to `SecureStore` (Keychain on iOS, EncryptedSharedPreferences on Android)
4. User sees the home screen

### App Restart Flow
1. `AuthService.init()` runs on app launch
2. Checks `SecureStore.hasRefreshToken()`
3. If refresh token exists → calls Auth0 `/oauth/token` with `grant_type: refresh_token`
4. If refresh succeeds → new tokens stored, user lands on home screen (no login screen)
5. If refresh fails (token revoked, expired, network error) → tokens cleared, login screen shown

### Logout Flow
1. `SecureStore.clearAll()` wipes all tokens from secure storage
2. In-memory credentials cleared
3. Next app launch → no refresh token → login screen shown

## Key Files

| File | Role |
|------|------|
| `lib/services/auth_service.dart` | Token lifecycle: login, refresh, logout, biometric unlock |
| `lib/services/secure_store.dart` | Secure storage wrapper (Keychain / EncryptedSharedPreferences) |
| `lib/stores/auth_store.dart` | Reactive auth state (`ValueNotifier<bool>`) |
| `lib/config/env.dart` | Auth0 domain, client ID, audience, connection |

## Stored Keys

| Key | Purpose |
|-----|---------|
| `refresh_token` | Long-lived token for silent re-authentication |
| `access_token` | Short-lived API bearer token (~1h) |
| `id_token` | JWT with user profile claims |
| `expires_at` | ISO-8601 timestamp of access token expiry |
| `saved_email` | "Remember Me" — stored email for login form prefill |
| `saved_password` | "Remember Me" — stored password for login form prefill |

## Security

- **iOS:** Tokens stored in Keychain with `first_unlock_this_device` accessibility (available after first device unlock, not synced to other devices)
- **Android:** Uses `EncryptedSharedPreferences` (AES-256 encryption backed by Android Keystore)
- **Debug fallback:** In debug builds, if Keychain fails (e.g. iOS simulator error -34018), falls back to `SharedPreferences` with a `_debug_secure_` prefix. This is NOT used in release builds.
- **Refresh token rotation:** Auth0 may issue a new refresh token on each use; the app always saves the latest one

## Auth0 Configuration

- **Grant types used:** `password-realm` (ROPG for email/password), `authorization_code` (social login), `refresh_token`
- **Scope:** `openid profile email offline_access` — the `offline_access` scope is what enables refresh tokens
- **Biometric unlock:** Uses `local_auth` to gate access to stored refresh token. Biometric prompt → if authenticated → refresh tokens → logged in

## Testing

### Manual Verification
1. Log in with test credentials
2. Force-close the app (swipe away from app switcher)
3. Relaunch → should land on home screen without seeing login

### Automated (Maestro)
See `.maestro/persistent-login-test.yaml` — logs in, force-closes the app, relaunches, and asserts the home screen is visible without re-entering credentials.

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Refresh token expired/revoked | Login screen shown, tokens cleared |
| No network on launch | Refresh fails, login screen shown (could improve with offline grace period) |
| User logs out | All tokens cleared, next launch shows login |
| App update / reinstall | iOS Keychain persists across updates (but not reinstalls). Android EncryptedSharedPrefs persists across updates. |
| Concurrent refresh calls | `_refreshLock` prevents duplicate Auth0 calls |
