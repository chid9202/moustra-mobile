#!/bin/bash

# Build Android App Bundle for production
# This script works around the Flutter symbol stripping issue on ARM Macs
# by using Gradle directly instead of flutter build appbundle

set -e

echo "🚀 Building Android App Bundle for production..."
echo ""

# Step 1: Flutter build bundle (generates necessary files)
echo "📦 Step 1: Generating Flutter assets..."
flutter build appbundle --release --dart-define=ENV_FILENAME=.env.production 2>&1 | grep -v "failed to strip" || true

# Step 2: Build with Gradle directly (this works even when Flutter's post-processing fails)
echo ""
echo "🔨 Step 2: Building app bundle with Gradle..."
cd android && ./gradlew bundleRelease

# Step 3: Verify the bundle was created
cd ..
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

