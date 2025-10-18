#!/bin/bash

# Production Build Script for Moustra Mobile
# Usage: ./build_production.sh [ios|android|appbundle|all]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backup current .env if it exists
if [ -f ".env" ]; then
  echo -e "${YELLOW}Backing up current .env to .env.backup${NC}"
  cp .env .env.backup
fi

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
  echo -e "${RED}ERROR: .env.production file not found!${NC}"
  echo -e "${YELLOW}Please create .env.production with your production environment variables.${NC}"
  exit 1
fi

# Copy production environment to .env for the build
echo -e "${GREEN}Using .env.production for build${NC}"
cp .env.production .env

# Update Android Auth0 configuration to match production
AUTH0_DOMAIN=$(grep AUTH0_DOMAIN .env | cut -d '=' -f2)
AUTH0_SCHEME=$(grep AUTH0_SCHEME .env | cut -d '=' -f2)

echo -e "${YELLOW}Updating Android Auth0 config: $AUTH0_DOMAIN, $AUTH0_SCHEME${NC}"

# Backup and update build.gradle.kts
cp android/app/build.gradle.kts android/app/build.gradle.kts.backup
sed -i.tmp "s|manifestPlaceholders\[\"auth0Domain\"\] = \".*\"|manifestPlaceholders[\"auth0Domain\"] = \"$AUTH0_DOMAIN\"|" android/app/build.gradle.kts
sed -i.tmp "s|manifestPlaceholders\[\"auth0Scheme\"\] = \".*\"|manifestPlaceholders[\"auth0Scheme\"] = \"$AUTH0_SCHEME\"|" android/app/build.gradle.kts
rm -f android/app/build.gradle.kts.tmp

# Trap to restore files on exit
restore_env() {
  if [ -f ".env.backup" ]; then
    echo -e "${YELLOW}Restoring original .env${NC}"
    mv .env.backup .env
  fi
  if [ -f "android/app/build.gradle.kts.backup" ]; then
    echo -e "${YELLOW}Restoring original build.gradle.kts${NC}"
    mv android/app/build.gradle.kts.backup android/app/build.gradle.kts
  fi
}
trap restore_env EXIT

# Function to build iOS
build_ios() {
  echo -e "${GREEN}Building iOS release...${NC}"
  flutter build ios --release
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ iOS build completed successfully${NC}"
    echo -e "Build location: build/ios/iphoneos/Runner.app"
  else
    echo -e "${RED}✗ iOS build failed${NC}"
    exit 1
  fi
}

# Function to build Android APK
build_android() {
  echo -e "${GREEN}Building Android APK...${NC}"
  flutter build apk --release
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Android APK build completed successfully${NC}"
    echo -e "Build location: build/app/outputs/flutter-apk/app-release.apk"
  else
    echo -e "${RED}✗ Android APK build failed${NC}"
    exit 1
  fi
}

# Function to build Android App Bundle
build_appbundle() {
  echo -e "${GREEN}Building Android App Bundle...${NC}"
  flutter build appbundle --release
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Android App Bundle build completed successfully${NC}"
    echo -e "Build location: build/app/outputs/bundle/release/app-release.aab"
  else
    echo -e "${RED}✗ Android App Bundle build failed${NC}"
    exit 1
  fi
}

# Main script
echo -e "${GREEN}=== Moustra Mobile Production Build ===${NC}"
echo ""

# Parse command line argument
TARGET=${1:-all}

case $TARGET in
  ios)
    build_ios
    ;;
  android)
    build_android
    ;;
  appbundle)
    build_appbundle
    ;;
  all)
    echo -e "${YELLOW}Building for all platforms...${NC}"
    echo ""
    build_ios
    echo ""
    build_android
    echo ""
    build_appbundle
    ;;
  *)
    echo -e "${RED}Invalid target: $TARGET${NC}"
    echo "Usage: $0 [ios|android|appbundle|all]"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"

