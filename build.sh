#!/bin/bash

# Build script for ClipStack

# Clean previous builds
rm -rf build/

# Create build directory
mkdir -p build

# Build the application
swift build -c release

# Create app bundle structure
mkdir -p build/ClipStack.app/Contents/MacOS
mkdir -p build/ClipStack.app/Contents/Resources

# Copy executable
cp -r .build/release/ClipStack build/ClipStack.app/Contents/MacOS/

# Copy Info.plist
cp Sources/Info.plist build/ClipStack.app/Contents/

# Compile Core Data model into .momd and include in Resources
if [ -d "Sources/ClipStackDataModel.xcdatamodeld" ]; then
  xcrun momc Sources/ClipStackDataModel.xcdatamodeld build/ClipStack.app/Contents/Resources/ClipStackDataModel.momd
fi

echo "Packaged Core Data model: build/ClipStack.app/Contents/Resources/ClipStackDataModel.momd"

# Generate app icon from SF Symbol and convert to .icns
swift Tools/IconGenerator.swift || true
if [ -d build/AppIcon.iconset ]; then
  if command -v iconutil >/dev/null 2>&1; then
    iconutil -c icns build/AppIcon.iconset -o build/ClipStack.app/Contents/Resources/ClipStack.icns
    echo "Packaged App Icon: build/ClipStack.app/Contents/Resources/ClipStack.icns"
  else
    echo "iconutil not found; skipping ICNS generation. Install Xcode Command Line Tools for full icon support."
  fi
fi

# Optional: Code sign, notarize, staple, and build DMG
SIGN_ID=${SIGN_ID:-}
NOTARY_PROFILE=${NOTARY_PROFILE:-}
TEAM_ID=${TEAM_ID:-}

if [ -n "$SIGN_ID" ]; then
  echo "Code signing app with identity: $SIGN_ID"
  if [ -f "ClipStack.entitlements" ]; then
    codesign --entitlements ClipStack.entitlements --deep --force --options runtime --sign "$SIGN_ID" build/ClipStack.app || { echo "codesign failed"; exit 1; }
  else
    codesign --deep --force --options runtime --sign "$SIGN_ID" build/ClipStack.app || { echo "codesign failed"; exit 1; }
  fi
fi

mkdir -p dist
DMG_NAME=ClipStack.dmg

if [ -n "$NOTARY_PROFILE" ]; then
  echo "Zipping app for notarization"
  (cd build && zip -r ../dist/ClipStack.zip ClipStack.app)
  echo "Submitting to notarization with profile: $NOTARY_PROFILE"
  xcrun notarytool submit dist/ClipStack.zip --keychain-profile "$NOTARY_PROFILE" --wait || echo "Notarization submission failed or profile not configured."
  echo "Stapling ticket to app"
  xcrun stapler staple build/ClipStack.app || echo "Staple failed; ensure notarization succeeded."
fi

echo "Creating DMG: dist/$DMG_NAME"
hdiutil create -volname ClipStack -srcfolder build/ -ov -format UDZO dist/$DMG_NAME || echo "DMG creation failed"

echo "Distribution artifact ready: dist/$DMG_NAME"

echo "Build complete! Application is located at build/ClipStack.app"