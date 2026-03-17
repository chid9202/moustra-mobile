#!/bin/bash
set -e

# Set UTF-8 encoding for CocoaPods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "🔍 Installing dependencies..."
echo "📦 Installing CocoaPods dependencies..."
cd ios && pod install && cd ..

echo "🚀 Building iOS App Bundle for production..."
echo ""

flutter build ios --release --dart-define=ENV_FILENAME=.env.production --obfuscate --split-debug-info=build/debug-info/ios