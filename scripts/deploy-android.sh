#!/bin/bash
set -e

source "$(dirname "$0")/deploy-common.sh"

android_usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy-android.sh candidate [--track internal|beta|production]
  ./scripts/deploy-android.sh promote [--to beta|production]
EOF
}

upload_candidate() {
  ensure_git_repo
  ensure_git_clean
  verify_production_env

  local track="internal"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --track)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --track requires a value.${NC}" >&2
          exit 1
        fi
        track="$2"
        shift 2
        ;;
      -h|--help)
        android_usage
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        android_usage >&2
        exit 1
        ;;
    esac
  done

  case "$track" in
    internal|beta|production) ;;
    *)
      echo -e "${RED}❌ Invalid track: $track${NC}" >&2
      exit 1
      ;;
  esac

  local aab_path="build/app/outputs/bundle/release/app-release.aab"

  rm -f "$aab_path"

  echo -e "${GREEN}━━━ Building Android ━━━${NC}"
  AUTH0_SCHEME=com.moustra.app AUTH0_DOMAIN=login.moustra.com flutter build appbundle --release --dart-define=ENV_FILENAME=.env.production

  if [[ ! -f "$aab_path" ]]; then
    echo -e "${RED}❌ Android AAB not found at $aab_path.${NC}" >&2
    exit 1
  fi

  if ! unzip -l "$aab_path" | grep -q "\.env\.production"; then
    echo -e "${RED}❌ AAB is missing .env.production.${NC}" >&2
    exit 1
  fi
  echo "✅ Android AAB verified"

  echo -e "\n${GREEN}━━━ Uploading to Google Play (${track}) ━━━${NC}"
  (
    cd android
    bundle exec fastlane run upload_to_play_store \
      track:"$track" \
      aab:../"$aab_path" \
      skip_upload_metadata:true \
      skip_upload_images:true \
      skip_upload_screenshots:true
  )

  echo -e "\n${GREEN}✅ Android candidate uploaded.${NC}"
}

promote_release() {
  ensure_git_repo

  local target_track="production"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --to requires a value.${NC}" >&2
          exit 1
        fi
        target_track="$2"
        shift 2
        ;;
      -h|--help)
        android_usage
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        android_usage >&2
        exit 1
        ;;
    esac
  done

  echo -e "${GREEN}━━━ Promoting Android release ━━━${NC}"
  case "$target_track" in
    beta)
      (cd android && bundle exec fastlane promote_to_beta)
      ;;
    production)
      (cd android && bundle exec fastlane promote_to_production)
      ;;
    *)
      echo -e "${RED}❌ Invalid promotion target: $target_track${NC}" >&2
      exit 1
      ;;
  esac

  echo -e "\n${GREEN}✅ Android promotion complete.${NC}"
}

subcommand="${1:-}"
if [[ -z "$subcommand" ]]; then
  android_usage >&2
  exit 1
fi
shift

case "$subcommand" in
  candidate) upload_candidate "$@" ;;
  promote) promote_release "$@" ;;
  -h|--help)
    android_usage
    ;;
  *)
    echo -e "${RED}❌ Unknown Android subcommand: $subcommand${NC}" >&2
    android_usage >&2
    exit 1
    ;;
esac
