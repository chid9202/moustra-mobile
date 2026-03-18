#!/bin/bash
# Regenerate the API client from openapi.yml
# Run from the project root: ./scripts/generate_api.sh
set -e

echo "Generating Dart-Dio client from openapi.yml..."
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yml \
  -g dart-dio \
  -o lib/api/generated \
  --additional-properties=pubName=moustra_api,useEnumExtension=true \
  --skip-validate-spec

echo "Fixing SDK constraint..."
sed -i '' "s/sdk: '>=2.18.0 <4.0.0'/sdk: ^3.9.0/" lib/api/generated/pubspec.yaml

echo "Installing generated package dependencies..."
(cd lib/api/generated && dart pub get)

echo "Running built_value code generation..."
(cd lib/api/generated && dart run build_runner build --delete-conflicting-outputs)

echo "Installing main project dependencies..."
flutter pub get

echo "Done! API client regenerated successfully."
