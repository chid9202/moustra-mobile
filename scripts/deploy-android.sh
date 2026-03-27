#!/bin/bash
set -e

# Moustra Android Deploy Script
# Usage: ./scripts/deploy-android.sh

cd "$(dirname "$0")/.."
export PATH="$HOME/.asdf/shims:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}━━━ Building Android ━━━${NC}"
AUTH0_SCHEME=com.moustra.app AUTH0_DOMAIN=login.moustra.com flutter build appbundle --release --dart-define=ENV_FILENAME=.env.production || true

# Check if AAB was created
if [ ! -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo -e "${RED}❌ Android AAB not found!${NC}"
    exit 1
fi

# Verify bundle contains production env
if ! unzip -l build/app/outputs/bundle/release/app-release.aab | grep -q "\.env\.production"; then
    echo -e "${RED}❌ AAB missing .env.production!${NC}"
    exit 1
fi
echo "✅ Android AAB verified"

echo -e "\n${GREEN}━━━ Uploading to Play Store ━━━${NC}"
cd android
bundle exec fastlane run upload_to_play_store \
    track:production \
    aab:../build/app/outputs/bundle/release/app-release.aab \
    skip_upload_metadata:true \
    skip_upload_images:true \
    skip_upload_screenshots:true

echo -e "\n${GREEN}✅ Android deploy complete!${NC}"
