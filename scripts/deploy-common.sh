#!/bin/bash
set -e

cd "$(dirname "$0")/.."
export PATH="$HOME/.asdf/shims:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ensure_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}❌ Not inside a git repository.${NC}" >&2
    exit 1
  fi
}

ensure_git_clean() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${RED}❌ Working tree has uncommitted changes.${NC}" >&2
    echo -e "${RED}   Commit/stash them before running deploy.${NC}" >&2
    exit 1
  fi

  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo -e "${RED}❌ Working tree has untracked files.${NC}" >&2
    echo -e "${RED}   Clean them up (or add them) before running deploy.${NC}" >&2
    exit 1
  fi
}

ensure_branch_is_main_or_release() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ "$branch" == "main" ]]; then
    return 0
  fi
  if [[ "$branch" == release/* ]]; then
    return 0
  fi

  echo -e "${RED}❌ Deploy must be run from 'main' or a 'release/*' branch (current: '$branch').${NC}" >&2
  echo -e "${RED}   Run: git checkout main${NC}" >&2
  exit 1
}

verify_production_env() {
  if grep -q "login-dev.moustra.com" .env.production; then
    echo -e "${RED}❌ .env.production contains dev domain!${NC}"
    exit 1
  fi
  echo "✅ .env.production verified"
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

deploy_usage() {
  local platform="${1:-${DEPLOY_PLATFORM_NAME:-}}"
  if [[ -n "$platform" ]]; then
    platform=" ($platform)"
  fi

  echo "Moustra deploy${platform} — optionally bumps pubspec.yaml, runs tests, commits release branch, deploys."
  echo ""
  echo "Usage:"
  echo "  $0 --bump build|patch|minor|major"
  echo "  $0 [x.y.z]              # marketing version; build number increments by 1"
  echo "  $0                      # defaults to --bump patch"
  echo ""
  echo "Bump modes (marketing version + always increments build number by 1):"
  echo "  build   1.0.7+26 → 1.0.7+27"
  echo "  patch   1.0.7+26 → 1.0.8+27"
  echo "  minor   1.0.7+26 → 1.1.0+27"
  echo "  major   1.0.7+26 → 2.0.0+27"
  echo ""
  echo "Tip: For a full store release after Apple closes a \"train\", use --bump patch/minor/major."
  exit 0
}

deploy_prepare_release_if_needed() {
  # Outputs (globals):
  # - DEPLOY_VERSION_NAME
  # - DEPLOY_BUILD_NUM

  ensure_git_repo
  ensure_branch_is_main_or_release
  verify_production_env

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

  if [[ "$branch" == release/* ]]; then
    if [[ $# -gt 0 ]]; then
      echo -e "${RED}❌ You're on '$branch'. Don't pass bump args here; switch to main to bump/create release.${NC}" >&2
      exit 1
    fi
    parse_pubspec_version
    DEPLOY_VERSION_NAME="$PUBSPEC_VERSION_NAME"
    DEPLOY_BUILD_NUM="$PUBSPEC_BUILD_NUM"
    echo -e "${GREEN}━━━ Deploying Moustra $DEPLOY_VERSION_NAME+$DEPLOY_BUILD_NUM (from existing release branch) ━━━${NC}"
    return 0
  fi

  # On main: optionally bump + create/push release branch
  ensure_git_clean

  local BUMP_KIND=""
  local EXPLICIT_VERSION=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) deploy_usage; exit 0 ;;
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
  local CURRENT_NAME="$PUBSPEC_VERSION_NAME"
  local CURRENT_BUILD="$PUBSPEC_BUILD_NUM"

  local VERSION_NAME=""
  local NEW_BUILD=""

  if [[ -n "$BUMP_KIND" ]]; then
    VERSION_NAME="$(bump_marketing_version "$BUMP_KIND" "$CURRENT_NAME")"
    NEW_BUILD=$((CURRENT_BUILD + 1))
  elif [[ -n "$EXPLICIT_VERSION" ]]; then
    VERSION_NAME="$EXPLICIT_VERSION"
    NEW_BUILD=$((CURRENT_BUILD + 1))
  else
    BUMP_KIND="patch"
    VERSION_NAME="$(bump_marketing_version "$BUMP_KIND" "$CURRENT_NAME")"
    NEW_BUILD=$((CURRENT_BUILD + 1))
  fi

  DEPLOY_VERSION_NAME="$VERSION_NAME"
  DEPLOY_BUILD_NUM="$NEW_BUILD"

  echo -e "${GREEN}━━━ Preparing release/$DEPLOY_VERSION_NAME ($DEPLOY_VERSION_NAME+$DEPLOY_BUILD_NUM) ━━━${NC}"

  git pull origin main
  git checkout -b "release/$DEPLOY_VERSION_NAME" 2>/dev/null || git checkout "release/$DEPLOY_VERSION_NAME"

  set_pubspec_version_line "$DEPLOY_VERSION_NAME" "$DEPLOY_BUILD_NUM"
  echo "✅ Bumped to $DEPLOY_VERSION_NAME+$DEPLOY_BUILD_NUM"

  echo -e "\n${GREEN}━━━ Running tests ━━━${NC}"
  flutter test
  echo "✅ Tests passed"

  git add -A
  git commit -m "Release $DEPLOY_VERSION_NAME" || echo "Nothing to commit"
  git push -u origin "release/$DEPLOY_VERSION_NAME"
  echo "✅ Pushed release/$DEPLOY_VERSION_NAME"
}

