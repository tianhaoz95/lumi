#!/usr/bin/env bash
# Visual audit script for Android devices
# Usage: ./scripts/visual_audit_android.sh
# Requirements: flutter, adb (Android SDK) on PATH, a connected Android device or emulator
set -euo pipefail
OUTPUT_DIR="build/visual_audit"
mkdir -p "$OUTPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
# Build release apk
echo "Building release APK..."
flutter build apk --release --no-tree-shake-icons
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "Release APK not found at $APK_PATH. Attempting debug build instead..."
  flutter build apk --debug
  APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi
echo "Using APK at: $APK_PATH"
# List devices
echo "Connected devices:"
adb devices
# Install APK
echo "Installing APK to first connected device..."
adb install -r "$APK_PATH" || true
# Determine package name from AndroidManifest
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  PKG=$(grep -oP 'package="\K[^"]+' "$MANIFEST" | head -n 1)
else
  echo "AndroidManifest.xml not found; please set PKG manually."
  exit 1
fi
if [ -z "$PKG" ]; then
  echo "Could not determine package name. Please set PKG in the script."
  exit 1
fi
echo "Detected package: $PKG"
# Launch the app using monkey (safer across activity names)
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1
sleep 2
# Take a few screenshots over time to capture animations/blur
for i in 1 2 3; do
  TIMESTAMP=$(date +%s)
  OUTFILE="$OUTPUT_DIR/screen_$TIMESTAMP.png"
  echo "Capturing screenshot to $OUTFILE"
  adb exec-out screencap -p > "$OUTFILE"
  sleep 1
done
echo "Screenshots saved to $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
exit 0
