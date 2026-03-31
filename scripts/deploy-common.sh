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
    echo -e "${RED}   Commit or stash them before running release tasks.${NC}" >&2
    exit 1
  fi

  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo -e "${RED}❌ Working tree has untracked files.${NC}" >&2
    echo -e "${RED}   Clean them up (or add them) before running release tasks.${NC}" >&2
    exit 1
  fi
}

verify_production_env() {
  if [[ ! -f .env.production ]]; then
    echo -e "${RED}❌ .env.production is missing.${NC}" >&2
    exit 1
  fi

  if grep -q "login-dev.moustra.com" .env.production; then
    echo -e "${RED}❌ .env.production contains dev domain!${NC}" >&2
    exit 1
  fi

  echo "✅ .env.production verified"
}

print_ios_xcode_deploy_reminder() {
  echo -e "\n${GREEN}━━━ iOS: use Xcode to build and upload ━━━${NC}"
  echo "There is no iOS CLI deploy script. After prepare, ship iOS from Xcode:"
  echo ""
  echo "  1. From the repo root, bake production env into the Flutter build:"
  echo "       flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign"
  echo "  2. Open ios/Runner.xcworkspace in Xcode."
  echo "  3. Product → Archive (builds and signs the app)."
  echo "  4. In Organizer, click Distribute App."
  echo "  5. Xcode uploads the build to App Store Connect."
  echo ""
  echo "Details: DEPLOYMENT.md"
}

parse_pubspec_version() {
  local raw
  raw=$(grep '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d ' ' | tr -d '\r')
  PUBSPEC_VERSION_NAME="${raw%%+*}"
  PUBSPEC_BUILD_NUM="${raw##*+}"
}

set_pubspec_version_line() {
  local version_name="$1"
  local build_num="$2"
  local line="version: ${version_name}+${build_num}"

  if [[ "$(uname -s)" == Darwin ]]; then
    sed -i '' "s/^version: .*/${line}/" pubspec.yaml
  else
    sed -i "s/^version: .*/${line}/" pubspec.yaml
  fi
}

bump_marketing_version() {
  local kind="$1"
  local version_name="$2"
  local major minor patch

  IFS='.' read -r major minor patch <<< "$version_name"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"

  case "$kind" in
    build) echo "$version_name" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    major) echo "$((major + 1)).0.0" ;;
    *)
      echo -e "${RED}❌ Invalid bump: $kind (use build, patch, minor, or major).${NC}" >&2
      exit 1
      ;;
  esac
}

run_flutter_tests() {
  echo -e "\n${GREEN}━━━ Running tests ━━━${NC}"
  flutter test
  echo "✅ Tests passed"
}

prepare_release_usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy.sh prepare --bump build|patch|minor|major [--push] [--tag] [--skip-tests]
  ./scripts/deploy.sh prepare --version x.y.z [--push] [--tag] [--skip-tests]

Notes:
  - Runs from a clean main branch checkout.
  - Bumps pubspec.yaml only.
  - Does not create release branches.
EOF
}

prepare_release() {
  ensure_git_repo
  ensure_git_clean
  verify_production_env

  local bump_kind=""
  local explicit_version=""
  local should_push="false"
  local should_tag="false"
  local run_tests="true"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        prepare_release_usage
        exit 0
        ;;
      --bump)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --bump requires an argument.${NC}" >&2
          exit 1
        fi
        bump_kind="$2"
        shift 2
        ;;
      --version)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --version requires an argument.${NC}" >&2
          exit 1
        fi
        explicit_version="$2"
        shift 2
        ;;
      --push)
        should_push="true"
        shift
        ;;
      --tag)
        should_tag="true"
        shift
        ;;
      --skip-tests)
        run_tests="false"
        shift
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        prepare_release_usage >&2
        exit 1
        ;;
    esac
  done

  if [[ -n "$bump_kind" && -n "$explicit_version" ]]; then
    echo -e "${RED}❌ Use either --bump or --version, not both.${NC}" >&2
    exit 1
  fi

  if [[ -z "$bump_kind" && -z "$explicit_version" ]]; then
    echo -e "${RED}❌ You must pass either --bump or --version.${NC}" >&2
    exit 1
  fi

  if [[ -n "$bump_kind" ]]; then
    case "$bump_kind" in
      build|patch|minor|major) ;;
      *)
        echo -e "${RED}❌ Invalid --bump value: $bump_kind${NC}" >&2
        exit 1
        ;;
    esac
  fi

  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$current_branch" != "main" ]]; then
    git checkout main
  fi

  git pull --ff-only origin main
  ensure_git_clean

  parse_pubspec_version

  local current_name="$PUBSPEC_VERSION_NAME"
  local current_build="$PUBSPEC_BUILD_NUM"
  local next_name=""
  local next_build=""

  if [[ -n "$bump_kind" ]]; then
    next_name="$(bump_marketing_version "$bump_kind" "$current_name")"
  else
    next_name="$explicit_version"
  fi
  next_build=$((current_build + 1))

  echo -e "${GREEN}━━━ Preparing release ${next_name}+${next_build} from main ━━━${NC}"

  set_pubspec_version_line "$next_name" "$next_build"

  if git diff --quiet -- pubspec.yaml; then
    echo -e "${RED}❌ pubspec.yaml is already set to ${next_name}+${next_build}.${NC}" >&2
    exit 1
  fi

  if [[ "$run_tests" == "true" ]]; then
    run_flutter_tests
  fi

  git add pubspec.yaml
  git commit -m "chore(release): bump version to ${next_name}+${next_build}"
  echo "✅ Committed version bump"

  if [[ "$should_tag" == "true" ]]; then
    git tag -a "v${next_name}+${next_build}" -m "Release ${next_name}+${next_build}"
    echo "✅ Created tag v${next_name}+${next_build}"
  fi

  if [[ "$should_push" == "true" ]]; then
    git push origin main
    if [[ "$should_tag" == "true" ]]; then
      git push origin "v${next_name}+${next_build}"
    fi
    echo "✅ Pushed release commit"
  fi
}
