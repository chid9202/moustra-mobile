#!/bin/bash
set -e

# Moustra Full Deploy Script
# Usage: ./scripts/deploy.sh [version]

cd "$(dirname "$0")/.."
export PATH="$HOME/.asdf/shims:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get version
VERSION=${1:-}
if [ -z "$VERSION" ]; then
    CURRENT=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
    echo "Current version: $CURRENT"
    read -p "Enter new version (or press enter to keep $CURRENT): " VERSION
    VERSION=${VERSION:-$CURRENT}
fi

CURRENT_BUILD=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f2)
NEW_BUILD=$((CURRENT_BUILD + 1))

echo -e "${GREEN}━━━ Deploying Moustra $VERSION+$NEW_BUILD ━━━${NC}"

# Verify environment
if grep -q "login-dev.moustra.com" .env.production; then
    echo -e "${RED}❌ .env.production contains dev domain!${NC}"
    exit 1
fi
echo "✅ .env.production verified"

# Create release branch
git checkout main
git pull origin main
git checkout -b "release/$VERSION" 2>/dev/null || git checkout "release/$VERSION"

# Bump version
sed -i '' "s/^version: .*/version: $VERSION+$NEW_BUILD/" pubspec.yaml
echo "✅ Bumped to $VERSION+$NEW_BUILD"

# Run tests
echo -e "\n${GREEN}━━━ Running tests ━━━${NC}"
flutter test
echo "✅ Tests passed"

# Commit and push
git add -A
git commit -m "Release $VERSION" || echo "Nothing to commit"
git push -u origin "release/$VERSION"
echo "✅ Pushed release/$VERSION"

# Deploy both platforms
./scripts/deploy-android.sh
./scripts/deploy-ios.sh

echo -e "\n${GREEN}━━━ Deploy Complete! 🎉 ━━━${NC}"
echo "Version: $VERSION+$NEW_BUILD"
