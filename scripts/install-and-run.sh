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
MOUNT_POINT=$(hdiutil attach -nobrowse "$DMG_PATH" | grep "/Volumes/" | awk -F '\t' '{print $3}' | xargs)
echo "Mounted at $MOUNT_POINT"

echo "Copying to Applications..."
if [ -w "/Applications" ]; then
    rm -rf "$DEST_PATH"
    cp -R "$MOUNT_POINT/$APP_NAME" "$DEST_PATH"
else
    echo "  -> Applications directory is write-protected. Copying with administrative privileges (sudo)..."
    sudo rm -rf "$DEST_PATH"
    sudo cp -R "$MOUNT_POINT/$APP_NAME" "$DEST_PATH"
fi

echo "Unmounting DMG..."
hdiutil detach "$MOUNT_POINT" >/dev/null

echo "Removing quarantine attributes to allow running..."
if [ -w "$DEST_PATH" ]; then
    xattr -rd com.apple.quarantine "$DEST_PATH" || true
else
    sudo xattr -rd com.apple.quarantine "$DEST_PATH" || true
fi

echo "Installation complete: $DEST_PATH"
echo "Launching ReMastera..."
open "$DEST_PATH"
