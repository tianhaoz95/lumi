#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"
MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"

echo "Verifying Flutter project files..."
if [ ! -f "$PUBSPEC" ]; then echo "MISSING pubspec.yaml" >&2; exit 1; fi
if ! grep -q "name: lumi" "$PUBSPEC"; then echo "pubspec.yaml 'name: lumi' not found" >&2; exit 1; fi
if [ ! -f "$MANIFEST" ]; then echo "MISSING AndroidManifest.xml" >&2; exit 1; fi
if ! grep -q 'package="com.lumi.app"' "$MANIFEST"; then echo "Android package not set to com.lumi.app" >&2; exit 1; fi

if command -v flutter >/dev/null 2>&1; then
  echo "flutter present - running flutter pub get..."
  (cd "$ROOT" && flutter pub get)
  echo "OK - flutter pub get succeeded"
else
  echo "flutter not installed - skipping flutter commands (TODO: run flutter pub get and flutter run in a Flutter-capable environment)"
fi

echo "✓ Verification passed"
