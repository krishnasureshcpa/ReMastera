#!/usr/bin/env bash
# Scripts to install DMG to /Applications and run it

set -euo pipefail

DMG_PATH="build/Dist/ReMastera.dmg"
APP_NAME="ReMastera.app"
DEST_PATH="/Applications/$APP_NAME"

if [ ! -f "$DMG_PATH" ]; then
    echo "DMG not found. Building package first..."
    ./scripts/package.sh
fi

echo "Mounting DMG..."
MOUNT_POINT=$(hdiutil attach -nobrowse "$DMG_PATH" | grep /Volumes | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | sed 's/ $//')
echo "Mounted at $MOUNT_POINT"

echo "Copying to Applications (requires sudo/admin permissions if Applications is protected, but usually works for standard installs)..."
# Remove existing
rm -rf "$DEST_PATH"
cp -R "$MOUNT_POINT/$APP_NAME" "$DEST_PATH"

echo "Unmounting DMG..."
hdiutil detach "$MOUNT_POINT"

echo "Removing quarantine attributes to allow running..."
xattr -rd com.apple.quarantine "$DEST_PATH" || true

echo "Installation complete: $DEST_PATH"
echo "Launching ReMastera..."
open "$DEST_PATH"
