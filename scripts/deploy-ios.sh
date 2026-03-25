#!/bin/bash
set -e

# Moustra iOS Deploy Script
# Usage: ./scripts/deploy-ios.sh

cd "$(dirname "$0")/.."
export PATH="$HOME/.asdf/shims:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_app_store_version_hint() {
  echo -e "\n${YELLOW}━━━ App Store Connect version rule ━━━${NC}"
  echo "Apple rejected this IPA because CFBundleShortVersionString must exceed the last"
  echo "approved App Store version, or the pre-release train for that version is closed."
  echo "Bump the marketing version in pubspec, rebuild, and upload again, for example:"
  echo "  ./scripts/deploy.sh --bump patch"
  echo "(Use --bump build only when the same marketing version is still open in TestFlight.)"
}

APP_STORE_VERSION_HINT_PRINTED=

upload_log_hints_if_needed() {
  local log_file="$1"
  [[ -f "$log_file" ]] || return 0
  [[ -z "$APP_STORE_VERSION_HINT_PRINTED" ]] || return 0
  if grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString .*must contain a higher' "$log_file" 2>/dev/null; then
    APP_STORE_VERSION_HINT_PRINTED=1
    print_app_store_version_hint
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

echo -e "${GREEN}━━━ Building iOS ━━━${NC}"
flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign
echo "✅ Flutter build complete"

verify_pubspec_matches_generated_xcconfig
echo "✅ pubspec and Generated.xcconfig version agree (Info.plist FLUTTER_BUILD_*)"

echo -e "\n${GREEN}━━━ Archiving iOS ━━━${NC}"
(cd ios && bundle exec fastlane build)
echo "✅ IPA archive complete"

IPA_PATH="ios/build/Moustra.ipa"
if [ ! -f "$IPA_PATH" ]; then
  echo -e "${RED}IPA not found at $IPA_PATH${NC}"
  exit 1
fi

echo -e "\n${GREEN}━━━ Uploading to TestFlight ━━━${NC}"
MAX_UPLOAD_ATTEMPTS=3
UPLOAD_DELAY=30
attempt=1
uploaded=false
UPLOAD_LOG=$(mktemp "${TMPDIR:-/tmp}/moustra-upload.XXXXXX")
trap 'rm -f "$UPLOAD_LOG"' EXIT

while [ $attempt -le $MAX_UPLOAD_ATTEMPTS ]; do
  echo -e "Upload attempt $attempt/$MAX_UPLOAD_ATTEMPTS (fastlane)..."
  (cd ios && bundle exec fastlane upload_only) 2>&1 | tee -a "$UPLOAD_LOG"
  if [ "${PIPESTATUS[0]}" -eq 0 ]; then
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
      if echo "$altool_output" | grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString'; then
        print_app_store_version_hint
      else
        echo -e "${RED}Options: try later, use a wired connection, or upload via Xcode Organizer / Transporter app.${NC}"
      fi
      exit 1
    fi
  fi
fi

echo -e "\n${GREEN}✅ iOS deploy complete!${NC}"
