#!/bin/bash

APP_NAME="WordHub"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_NAME="${APP_NAME}_v1.1.1.dmg"
DMG_DIR="build/dmg_source"

# Clean up previous builds
rm -rf "$DMG_DIR"
rm -f "$DMG_NAME"

# Create source directory
mkdir -p "$DMG_DIR"

# Copy the app
echo "Copying app to temporary directory..."
cp -r "$APP_PATH" "$DMG_DIR/"

# Create Applications link
echo "Creating Applications link..."
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"

echo "DMG created: $DMG_NAME"

# Clean up
rm -rf "$DMG_DIR"
