#!/bin/bash
# Builds ClipboardManager.app from the .swift source files using the
# command-line Swift compiler — no Xcode project needed.
#
# Requirements: Xcode Command Line Tools installed (`xcode-select --install`
# if you don't already have them).
#
# Usage:
#   chmod +x build.sh
#   ./build.sh
#
# Result: ClipboardManager.app in this same folder. Double-click to run,
# or drag it to /Applications.

set -e

APP_NAME="ClipboardManager"
SRC_DIR="ClipboardManager"          # folder containing the .swift files
APP_BUNDLE="${APP_NAME}.app"

echo "==> Cleaning old build..."
rm -rf "${APP_BUNDLE}"

echo "==> Creating app bundle structure..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

echo "==> Copying Info.plist..."
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"

echo "==> Compiling Swift sources..."
swiftc -O \
    -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" \
    "${SRC_DIR}"/*.swift \
    -framework Cocoa \
    -framework Carbon

echo "==> Ad-hoc code signing (needed for Accessibility permission to work)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "✅ Build complete: ${APP_BUNDLE}"
echo "   Run it with: open ${APP_BUNDLE}"
echo "   Or drag it into /Applications."
