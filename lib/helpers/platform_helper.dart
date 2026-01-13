import 'dart:io';

class PlatformHelper {
  /// Detects the current mobile platform
  /// Returns "iOS" for iOS devices, "Android" for Android devices, or "Unknown" as fallback
  static String getPlatform() {
    if (Platform.isIOS) {
      return 'iOS';
    }
    if (Platform.isAndroid) {
      return 'Android';
    }
    return 'Unknown';
  }
}
