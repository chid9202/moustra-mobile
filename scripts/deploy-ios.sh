#!/bin/bash
set -e

# Moustra iOS Deploy Script
# Usage: ./scripts/deploy-ios.sh [x.y.z] | ./scripts/deploy-ios.sh --bump build|patch|minor|major

source "$(dirname "$0")/deploy-common.sh"

DEPLOY_PLATFORM_NAME="iOS"

deploy_prepare_release_if_needed "$@"

echo -e "${GREEN}━━━ Building iOS ━━━${NC}"
flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign
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
MAX_UPLOAD_ATTEMPTS=3
UPLOAD_DELAY=30
attempt=1
uploaded=false

while [ $attempt -le $MAX_UPLOAD_ATTEMPTS ]; do
  echo -e "Upload attempt $attempt/$MAX_UPLOAD_ATTEMPTS (fastlane)..."
  if (cd ios && bundle exec fastlane upload_only); then
    uploaded=true
    break
  fi
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
      echo -e "${RED}Options: try later, use a wired connection, or upload via Xcode Organizer / Transporter app.${NC}"
      exit 1
    fi
  fi
fi

echo -e "\n${GREEN}✅ iOS deploy complete!${NC}"
