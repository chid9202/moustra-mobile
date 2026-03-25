#!/bin/bash
set -e

# Moustra iOS Deploy Script
# Usage: ./scripts/deploy-ios.sh [x.y.z] | ./scripts/deploy-ios.sh --bump build|patch|minor|major

source "$(dirname "$0")/deploy-common.sh"

DEPLOY_PLATFORM_NAME="iOS"

print_app_store_version_hint() {
  echo -e "\n${YELLOW}━━━ App Store Connect version rule ━━━${NC}"
  echo "Apple rejected this IPA because CFBundleShortVersionString must exceed the last"
  echo "approved App Store version, or the pre-release train for that version is closed."
  echo "Bump the marketing version in pubspec, rebuild, and upload again, for example:"
  echo "  ./scripts/deploy.sh --bump patch   # or bump pubspec manually and redeploy"
  echo "(Use --bump build only when the same marketing version is still open in TestFlight.)"
}

# From logs: multipart upload to northamerica-1.object-storage.apple.com fails with
# NSURLErrorDomain Code=-1005 "The network connection was lost" + many "WILL RETRY PART" lines.
# That is local/network path to Apple's CDN, not Fastlane "being slow" for a ~40MB IPA.
print_apple_cdn_network_hint() {
  echo -e "\n${YELLOW}━━━ Upload slowness / failures (Apple CDN) ━━━${NC}"
  echo "Your log shows dropped connections (-1005) while uploading parts to Apple's object storage."
  echo "A healthy upload for this IPA size is usually a few minutes, not an hour."
  echo "Try: wired Ethernet, different network, disable VPN/proxy, avoid crowded Wi‑Fi."
  echo "Fallback: Mac Transporter app or Xcode Organizer with the same IPA."
}

APP_STORE_VERSION_HINT_PRINTED=
NETWORK_UPLOAD_HINT_PRINTED=

upload_log_hints_if_needed() {
  local log_file="$1"
  [[ -f "$log_file" ]] || return 0
  if [[ -z "$APP_STORE_VERSION_HINT_PRINTED" ]] && grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString .*must contain a higher' "$log_file" 2>/dev/null; then
    APP_STORE_VERSION_HINT_PRINTED=1
    print_app_store_version_hint
  fi
  if [[ -z "$NETWORK_UPLOAD_HINT_PRINTED" ]] && grep -qE 'NSURLErrorDomain Code=-1005|The network connection was lost\.|WILL RETRY PART|object-storage\.apple\.com' "$log_file" 2>/dev/null; then
    NETWORK_UPLOAD_HINT_PRINTED=1
    print_apple_cdn_network_hint
  fi
}

verify_pubspec_matches_generated_xcconfig() {
  local raw name num gen_name gen_num
  raw=$(grep '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d ' ' | tr -d '\r')
  name="${raw%%+*}"
  num="${raw##*+}"
  if [[ ! -f ios/Flutter/Generated.xcconfig ]]; then
    echo -e "${RED}❌ ios/Flutter/Generated.xcconfig missing after flutter build${NC}"
    exit 1
  fi
  gen_name=$(grep '^FLUTTER_BUILD_NAME=' ios/Flutter/Generated.xcconfig | cut -d= -f2 | tr -d '\r')
  gen_num=$(grep '^FLUTTER_BUILD_NUMBER=' ios/Flutter/Generated.xcconfig | cut -d= -f2 | tr -d '\r')
  if [[ "$gen_name" != "$name" || "$gen_num" != "$num" ]]; then
    echo -e "${RED}❌ Version mismatch: pubspec has $name+$num but Generated.xcconfig has ${gen_name}+${gen_num}${NC}"
    echo -e "${RED}   Run flutter build ios again after changing pubspec, or run deploy from a clean tree.${NC}"
    exit 1
  fi
}

deploy_prepare_release_if_needed "$@"

echo -e "${GREEN}━━━ Building iOS ━━━${NC}"
flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign
verify_pubspec_matches_generated_xcconfig
echo "✅ Flutter build complete"

echo -e "\n${GREEN}━━━ Archiving iOS ━━━${NC}"
(cd ios && bundle exec fastlane build)
echo "✅ IPA archive complete"

IPA_PATH="ios/build/Moustra.ipa"
if [ ! -f "$IPA_PATH" ]; then
  echo -e "${RED}IPA not found at $IPA_PATH${NC}"
  exit 1
fi

echo -e "\n${GREEN}━━━ Uploading to TestFlight ━━━${NC}"
echo -e "${YELLOW}Tip: Stuck or very slow here is often Wi‑Fi/VPN/proxy drops to Apple's upload CDN (not IPA size).${NC}"

MAX_UPLOAD_ATTEMPTS=3
UPLOAD_DELAY=30
attempt=1
uploaded=false
mkdir -p ios/build
UPLOAD_LOG="ios/build/fastlane-testflight-upload.log"
: >"$UPLOAD_LOG"

while [ $attempt -le $MAX_UPLOAD_ATTEMPTS ]; do
  echo -e "Upload attempt $attempt/$MAX_UPLOAD_ATTEMPTS (fastlane)..."
  (cd ios && bundle exec fastlane upload_only) 2>&1 | tee -a "$UPLOAD_LOG"
  fl_exit="${PIPESTATUS[0]}"
  if [ "$fl_exit" -eq 0 ]; then
    uploaded=true
    break
  fi
  # Pilot often exits non-zero when altool logs multipart retries (NSURLError -1005) on stderr even
  # though the same run ends with "UPLOAD SUCCEEDED with no errors" — treat that as success.
  if grep -q 'UPLOAD SUCCEEDED with no errors' "$UPLOAD_LOG" 2>/dev/null; then
    echo -e "${GREEN}Application Loader reported success in the log (Delivery UUID present). Fastlane exited $fl_exit; treating upload as complete.${NC}"
    uploaded=true
    break
  fi
  upload_log_hints_if_needed "$UPLOAD_LOG"
  echo -e "${RED}Fastlane upload failed (attempt $attempt/$MAX_UPLOAD_ATTEMPTS).${NC}"
  sleep $UPLOAD_DELAY
  attempt=$((attempt + 1))
done

# Fallback: use xcrun altool directly if fastlane upload keeps timing out
if [ "$uploaded" = false ]; then
  echo -e "\n${GREEN}━━━ Trying direct upload via xcrun altool ━━━${NC}"
  API_KEY_PATH="ios/fastlane/keys/AuthKey_HG69G96CXV.p8"
  API_KEY_ID="HG69G96CXV"
  API_ISSUER="37b32ed6-1d8d-4556-a872-81b9e4197348"

  altool_output=$(xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER" \
    --show-progress 2>&1) && uploaded=true

  if [ "$uploaded" = false ]; then
    if echo "$altool_output" | grep -q "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE"; then
      echo -e "${GREEN}Build already uploaded (likely succeeded on a previous attempt despite timeout).${NC}"
      uploaded=true
    else
      echo -e "${RED}Direct upload also failed.${NC}"
      echo "$altool_output"
      if echo "$altool_output" | grep -qE 'NSURLErrorDomain Code=-1005|The network connection was lost\.|WILL RETRY PART|object-storage\.apple\.com'; then
        print_apple_cdn_network_hint
      elif echo "$altool_output" | grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString'; then
        print_app_store_version_hint
      else
        echo -e "${RED}Options: try later, use a wired connection, or upload via Xcode Organizer / Transporter app.${NC}"
      fi
      exit 1
    fi
  fi
fi

echo -e "\n${GREEN}✅ iOS deploy complete!${NC}"
