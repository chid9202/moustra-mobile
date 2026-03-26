#!/bin/bash
set -e

source "$(dirname "$0")/deploy-common.sh"

deploy_usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy.sh prepare --bump build|patch|minor|major [--push] [--tag] [--skip-tests]
  ./scripts/deploy.sh prepare --version x.y.z [--push] [--tag] [--skip-tests]
  ./scripts/deploy.sh candidate [--platform ios|android|both] [--android-track internal|beta|production] [--skip-tests]
  ./scripts/deploy.sh promote [--platform ios|android|both] [--android-to beta|production] [--ios-build BUILD_NUMBER]

Examples:
  ./scripts/deploy.sh prepare --bump patch --push --tag
  ./scripts/deploy.sh candidate --platform both --android-track internal
  ./scripts/deploy.sh promote --platform both --android-to production --ios-build 47
EOF
}

run_candidate() {
  local platform="both"
  local android_track="internal"
  local run_tests="true"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --platform requires a value.${NC}" >&2
          exit 1
        fi
        platform="$2"
        shift 2
        ;;
      --android-track)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --android-track requires a value.${NC}" >&2
          exit 1
        fi
        android_track="$2"
        shift 2
        ;;
      --skip-tests)
        run_tests="false"
        shift
        ;;
      -h|--help)
        deploy_usage
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        deploy_usage >&2
        exit 1
        ;;
    esac
  done

  case "$platform" in
    ios|android|both) ;;
    *)
      echo -e "${RED}❌ Invalid platform: $platform${NC}" >&2
      exit 1
      ;;
  esac

  if [[ "$run_tests" == "true" ]]; then
    run_flutter_tests
  fi

  if [[ "$platform" == "ios" || "$platform" == "both" ]]; then
    ./scripts/deploy-ios.sh candidate
  fi

  if [[ "$platform" == "android" || "$platform" == "both" ]]; then
    ./scripts/deploy-android.sh candidate --track "$android_track"
  fi
}

run_promote() {
  local platform="both"
  local android_to="production"
  local ios_build=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --platform requires a value.${NC}" >&2
          exit 1
        fi
        platform="$2"
        shift 2
        ;;
      --android-to)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --android-to requires a value.${NC}" >&2
          exit 1
        fi
        android_to="$2"
        shift 2
        ;;
      --ios-build)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --ios-build requires a value.${NC}" >&2
          exit 1
        fi
        ios_build="$2"
        shift 2
        ;;
      -h|--help)
        deploy_usage
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        deploy_usage >&2
        exit 1
        ;;
    esac
  done

  case "$platform" in
    ios|android|both) ;;
    *)
      echo -e "${RED}❌ Invalid platform: $platform${NC}" >&2
      exit 1
      ;;
  esac

  if [[ "$platform" == "ios" || "$platform" == "both" ]]; then
    if [[ -n "$ios_build" ]]; then
      ./scripts/deploy-ios.sh promote --build "$ios_build"
    else
      ./scripts/deploy-ios.sh promote
    fi
  fi

  if [[ "$platform" == "android" || "$platform" == "both" ]]; then
    ./scripts/deploy-android.sh promote --to "$android_to"
  fi
}

subcommand="${1:-}"
if [[ -z "$subcommand" ]]; then
  deploy_usage >&2
  exit 1
fi
shift

case "$subcommand" in
  prepare) prepare_release "$@" ;;
  candidate) run_candidate "$@" ;;
  promote) run_promote "$@" ;;
  -h|--help)
    deploy_usage
    ;;
  *)
    echo -e "${RED}❌ Unknown subcommand: $subcommand${NC}" >&2
    deploy_usage >&2
    exit 1
    ;;
esac
