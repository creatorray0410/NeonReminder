#!/bin/bash
# Build DMG installer for Neon Reminder

DMG_DIR="/tmp/NeonReminder_dmg"
DMG_NAME="NeonReminder-v1.0.0.dmg"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Building DMG ==="

# Clean up previous build
if [ -d "$DMG_DIR" ]; then
    rm -r "$DMG_DIR"
fi
if [ -f "$APP_DIR/$DMG_NAME" ]; then
    rm "$APP_DIR/$DMG_NAME"
fi

# Create staging directory
mkdir -p "$DMG_DIR"

# Copy app bundle
cp -R "$APP_DIR/NeonReminder.app" "$DMG_DIR/"

# Create Applications symlink for drag-to-install
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "Neon Reminder" \
  -srcfolder "$DMG_DIR" \
  -ov -format UDZO \
  "$APP_DIR/$DMG_NAME"

# Clean up staging
rm -r "$DMG_DIR"

echo "=== DMG Created ==="
ls -lh "$APP_DIR/$DMG_NAME"
