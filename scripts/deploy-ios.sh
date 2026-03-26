#!/bin/bash
set -e

source "$(dirname "$0")/deploy-common.sh"

ios_usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy-ios.sh candidate
  ./scripts/deploy-ios.sh promote [--build BUILD_NUMBER]
EOF
}

print_app_store_version_hint() {
  echo -e "\n${YELLOW}━━━ App Store Connect version rule ━━━${NC}"
  echo "Apple rejected this IPA because CFBundleShortVersionString must exceed the last"
  echo "approved App Store version, or the pre-release train for that version is closed."
  echo "Bump the marketing version in pubspec, rebuild, and upload again."
  echo "Use build-only bumps only while the same TestFlight train is still open."
}

print_apple_cdn_network_hint() {
  echo -e "\n${YELLOW}━━━ Upload slowness / failures (Apple CDN) ━━━${NC}"
  echo "Your log shows dropped connections while uploading parts to Apple's CDN."
  echo "Try a stable network, disable VPN/proxy, or upload the same IPA via Transporter."
}

verify_pubspec_matches_generated_xcconfig() {
  local raw name num gen_name gen_num
  raw=$(grep '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d ' ' | tr -d '\r')
  name="${raw%%+*}"
  num="${raw##*+}"

  if [[ ! -f ios/Flutter/Generated.xcconfig ]]; then
    echo -e "${RED}❌ ios/Flutter/Generated.xcconfig missing after flutter build.${NC}" >&2
    exit 1
  fi

  gen_name=$(grep '^FLUTTER_BUILD_NAME=' ios/Flutter/Generated.xcconfig | cut -d= -f2 | tr -d '\r')
  gen_num=$(grep '^FLUTTER_BUILD_NUMBER=' ios/Flutter/Generated.xcconfig | cut -d= -f2 | tr -d '\r')

  if [[ "$gen_name" != "$name" || "$gen_num" != "$num" ]]; then
    echo -e "${RED}❌ Version mismatch: pubspec has $name+$num but Generated.xcconfig has ${gen_name}+${gen_num}.${NC}" >&2
    exit 1
  fi
}

upload_candidate() {
  ensure_git_repo
  ensure_git_clean
  verify_production_env

  echo -e "${GREEN}━━━ Building iOS ━━━${NC}"
  flutter build ios --release --dart-define=ENV_FILENAME=.env.production --no-codesign
  verify_pubspec_matches_generated_xcconfig
  echo "✅ Flutter build complete"

  echo -e "\n${GREEN}━━━ Archiving iOS ━━━${NC}"
  (cd ios && bundle exec fastlane build)
  echo "✅ IPA archive complete"

  local ipa_path="ios/build/Moustra.ipa"
  if [[ ! -f "$ipa_path" ]]; then
    echo -e "${RED}❌ IPA not found at $ipa_path.${NC}" >&2
    exit 1
  fi

  echo -e "\n${GREEN}━━━ Uploading to TestFlight ━━━${NC}"

  local max_upload_attempts=3
  local upload_delay=30
  local attempt=1
  local uploaded=false
  local upload_log
  upload_log=$(mktemp "${TMPDIR:-/tmp}/moustra-ios-upload.XXXXXX")
  trap 'rm -f "$upload_log"' EXIT

  while [[ $attempt -le $max_upload_attempts ]]; do
    echo "Upload attempt $attempt/$max_upload_attempts..."
    (cd ios && bundle exec fastlane upload_only) 2>&1 | tee -a "$upload_log"
    local fl_exit="${PIPESTATUS[0]}"
    if [[ "$fl_exit" -eq 0 ]]; then
      uploaded=true
      break
    fi

    if grep -q 'UPLOAD SUCCEEDED with no errors' "$upload_log" 2>/dev/null; then
      echo "✅ Upload succeeded despite Fastlane exiting non-zero."
      uploaded=true
      break
    fi

    if grep -qE 'NSURLErrorDomain Code=-1005|The network connection was lost\.|WILL RETRY PART|object-storage\.apple\.com' "$upload_log" 2>/dev/null; then
      print_apple_cdn_network_hint
    elif grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString .*must contain a higher' "$upload_log" 2>/dev/null; then
      print_app_store_version_hint
    fi

    echo -e "${RED}Fastlane upload failed (attempt $attempt/$max_upload_attempts).${NC}"
    sleep "$upload_delay"
    attempt=$((attempt + 1))
  done

  if [[ "$uploaded" == "false" ]]; then
    echo -e "\n${GREEN}━━━ Trying direct upload via xcrun altool ━━━${NC}"

    local altool_output
    altool_output=$(xcrun altool --upload-app \
      --type ios \
      --file "$ipa_path" \
      --apiKey "HG69G96CXV" \
      --apiIssuer "37b32ed6-1d8d-4556-a872-81b9e4197348" \
      --show-progress 2>&1) && uploaded=true

    if [[ "$uploaded" == "false" ]]; then
      if echo "$altool_output" | grep -q "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE"; then
        echo "✅ Build already uploaded."
        uploaded=true
      else
        echo -e "${RED}❌ Direct upload also failed.${NC}" >&2
        echo "$altool_output" >&2
        if echo "$altool_output" | grep -qE 'NSURLErrorDomain Code=-1005|The network connection was lost\.|WILL RETRY PART|object-storage\.apple\.com'; then
          print_apple_cdn_network_hint
        elif echo "$altool_output" | grep -qE 'Invalid Pre-Release Train|closed for new build submissions|previously approved version|CFBundleShortVersionString'; then
          print_app_store_version_hint
        fi
        exit 1
      fi
    fi
  fi

  echo -e "\n${GREEN}✅ iOS candidate uploaded to TestFlight.${NC}"
}

promote_release() {
  ensure_git_repo

  local build_number=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --build)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --build requires a value.${NC}" >&2
          exit 1
        fi
        build_number="$2"
        shift 2
        ;;
      -h|--help)
        ios_usage
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Unexpected argument: $1${NC}" >&2
        ios_usage >&2
        exit 1
        ;;
    esac
  done

  echo -e "${GREEN}━━━ Promoting iOS build to App Store review ━━━${NC}"
  if [[ -n "$build_number" ]]; then
    (cd ios && bundle exec fastlane promote build:"$build_number")
  else
    (cd ios && bundle exec fastlane promote)
  fi
  echo -e "\n${GREEN}✅ iOS promotion submitted.${NC}"
}

subcommand="${1:-}"
if [[ -z "$subcommand" ]]; then
  ios_usage >&2
  exit 1
fi
shift

case "$subcommand" in
  candidate) upload_candidate "$@" ;;
  promote) promote_release "$@" ;;
  -h|--help)
    ios_usage
    ;;
  *)
    echo -e "${RED}❌ Unknown iOS subcommand: $subcommand${NC}" >&2
    ios_usage >&2
    exit 1
    ;;
esac
