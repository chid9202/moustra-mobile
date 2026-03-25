#!/bin/bash
set -e

# Moustra full deploy (Android + iOS)
#
# Usage:
#   ./scripts/deploy.sh --bump build|patch|minor|major
#   ./scripts/deploy.sh [x.y.z]          # set marketing version; build number +1
#   ./scripts/deploy.sh                  # prompt for marketing version; build +1
#   ./scripts/deploy.sh --help

cd "$(dirname "$0")/.."
export PATH="$HOME/.asdf/shims:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
  echo "Moustra deploy — bumps pubspec.yaml, runs tests, commits release branch, deploys both stores."
  echo ""
  echo "Usage:"
  echo "  $0 --bump build|patch|minor|major"
  echo "  $0 [x.y.z]              # marketing version; build number increments by 1"
  echo "  $0                      # interactive marketing version; build +1"
  echo ""
  echo "Bump modes (marketing version + always increments build number by 1):"
  echo "  build   1.0.7+26 → 1.0.7+27"
  echo "  patch   1.0.7+26 → 1.0.8+27"
  echo "  minor   1.0.7+26 → 1.1.0+27"
  echo "  major   1.0.7+26 → 2.0.0+27"
  echo ""
  echo "App Store / TestFlight: after a marketing version is approved or goes live,"
  echo "Apple closes that \"train\". New uploads need a higher CFBundleShortVersionString."
  echo "Use --bump patch (or minor/major), not --bump build, for the next store release."
  exit 0
}

parse_pubspec_version() {
  local raw
  raw=$(grep '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d ' ' | tr -d '\r')
  PUBSPEC_VERSION_NAME="${raw%%+*}"
  PUBSPEC_BUILD_NUM="${raw##*+}"
}

set_pubspec_version_line() {
  local vname="$1"
  local bnum="$2"
  local line="version: ${vname}+${bnum}"
  if [[ "$(uname -s)" == Darwin ]]; then
    sed -i '' "s/^version: .*/${line}/" pubspec.yaml
  else
    sed -i "s/^version: .*/${line}/" pubspec.yaml
  fi
}

bump_marketing_version() {
  local kind="$1"
  local vname="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$vname"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"
  case "$kind" in
    build) echo "$vname" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    major) echo "$((major + 1)).0.0" ;;
    *)
      echo -e "${RED}Invalid bump: $kind (use build, patch, minor, or major)${NC}" >&2
      exit 1
      ;;
  esac
}

BUMP_KIND=""
EXPLICIT_VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --bump)
      if [[ -z "${2:-}" ]]; then
        echo -e "${RED}--bump requires an argument (build, patch, minor, major)${NC}" >&2
        exit 1
      fi
      BUMP_KIND="$2"
      shift 2
      ;;
    *)
      if [[ -n "$EXPLICIT_VERSION" ]]; then
        echo -e "${RED}Unexpected argument: $1${NC}" >&2
        exit 1
      fi
      EXPLICIT_VERSION="$1"
      shift
      ;;
  esac
done

if [[ -n "$BUMP_KIND" && -n "$EXPLICIT_VERSION" ]]; then
  echo -e "${RED}Use either --bump or an explicit x.y.z, not both.${NC}" >&2
  exit 1
fi

if [[ -n "$BUMP_KIND" ]]; then
  case "$BUMP_KIND" in
    build|patch|minor|major) ;;
    *)
      echo -e "${RED}Invalid --bump value: $BUMP_KIND${NC}" >&2
      exit 1
      ;;
  esac
fi

parse_pubspec_version
CURRENT_NAME="$PUBSPEC_VERSION_NAME"
CURRENT_BUILD="$PUBSPEC_BUILD_NUM"

if [[ -n "$BUMP_KIND" ]]; then
  VERSION=$(bump_marketing_version "$BUMP_KIND" "$CURRENT_NAME")
  NEW_BUILD=$((CURRENT_BUILD + 1))
elif [[ -n "$EXPLICIT_VERSION" ]]; then
  VERSION="$EXPLICIT_VERSION"
  NEW_BUILD=$((CURRENT_BUILD + 1))
else
  echo "Current version: $CURRENT_NAME+$CURRENT_BUILD"
  read -r -p "Enter new marketing version (empty = keep $CURRENT_NAME): " input
  VERSION="${input:-$CURRENT_NAME}"
  NEW_BUILD=$((CURRENT_BUILD + 1))
fi

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

# Bump version (single source for Flutter + Fastlane; iOS uses FLUTTER_BUILD_* via Generated.xcconfig)
set_pubspec_version_line "$VERSION" "$NEW_BUILD"
echo "✅ Bumped pubspec to $VERSION+$NEW_BUILD"

# Run tests
echo -e "\n${GREEN}━━━ Running tests ━━━${NC}"
flutter test
echo "✅ Tests passed"

# Commit and push
git add -A
git commit -m "Release $VERSION+$NEW_BUILD" || echo "Nothing to commit"
git push -u origin "release/$VERSION"
echo "✅ Pushed release/$VERSION"

# Deploy both platforms (each runs flutter build so ios/Flutter/Generated.xcconfig matches pubspec)
./scripts/deploy-android.sh
./scripts/deploy-ios.sh

echo -e "\n${GREEN}━━━ Deploy Complete! 🎉 ━━━${NC}"
echo "Version: $VERSION+$NEW_BUILD"
