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
NC='\033[0m'

echo -e "${GREEN}━━━ Building iOS ━━━${NC}"
flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign
echo "✅ iOS build complete"

echo -e "\n${GREEN}━━━ Uploading to TestFlight ━━━${NC}"
cd ios
bundle exec fastlane beta

echo -e "\n${GREEN}✅ iOS deploy complete!${NC}"
