#!/bin/bash
set -e

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "🔍 Installing dependencies..."
echo ""
cd ios && pod install && cd ..

echo "🚀 Building iOS App Bundle for production..."
echo ""

flutter build ios --release --dart-define=ENV_FILENAME=.env.production