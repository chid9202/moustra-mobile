#!/bin/bash

# Build Android App Bundle for production
# This script works around the Flutter symbol stripping issue on ARM Macs
# by using Gradle directly instead of flutter build appbundle
#
# IMPORTANT: The --dart-define=ENV_FILENAME=.env.production flag ensures
# the app loads the production environment file at runtime.

set -e

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "🚀 Building Android App Bundle for production..."
echo ""

# Step 1: Flutter build bundle (generates necessary files with production environment)
# This compiles Dart code with ENV_FILENAME=.env.production baked in
echo "📦 Step 1: Generating Flutter assets with production environment..."
AUTH0_DOMAIN=login.moustra.com AUTH0_SCHEME=com.moustra.app flutter build appbundle --release --dart-define=ENV_FILENAME=.env.production --obfuscate --split-debug-info=build/debug-info/android 2>&1 | grep -v "failed to strip" || true

# Check if Flutter build created the bundle successfully
# If it did, we can use it directly (it already has the production environment)
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo ""
    echo "✅ Flutter build completed successfully with production environment!"
    echo "📦 Using Flutter-generated bundle"
    echo "   (ENV_FILENAME=.env.production was compiled into the Dart code)"
    SKIP_GRADLE=true
else
    echo ""
    echo "⚠️  Flutter build did not create bundle, using Gradle fallback..."
    SKIP_GRADLE=false
fi

# Step 2: Build with Gradle directly (fallback if Flutter's post-processing fails)
# IMPORTANT: If Flutter build succeeded, we skip this to preserve the production environment.
# The Dart code was already compiled with ENV_FILENAME=.env.production, so the bundle is correct.
# Only run Gradle if Flutter build failed to create the bundle.
if [ "$SKIP_GRADLE" = false ]; then
    echo ""
    echo "🔨 Step 2: Building app bundle with Gradle..."
    echo "⚠️  NOTE: Gradle will use the Dart code compiled in Step 1, which already has"
    echo "   ENV_FILENAME=.env.production baked in, so the production environment is preserved."
    cd android && ./gradlew bundleRelease
    cd ..
fi

# Step 3: Verify the bundle was created
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📦 App bundle location: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    ls -lh build/app/outputs/bundle/release/app-release.aab
    echo ""
    echo "🎉 Ready to upload to Google Play Store!"
    exit 0
else
    echo ""
    echo "❌ Build failed - app bundle not created"
    exit 1
fi

