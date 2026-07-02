#!/usr/bin/env bash
# ReMastera macOS Application Packaging & Distribution Utility
set -euo pipefail

echo "=================================================="
echo "Packaging ReMastera macOS Application..."
echo "=================================================="

# 1. Compile in release mode
echo "Step 1: Compiling release binary..."
swift build -c release

# 2. Build app bundle directory structure
echo "Step 2: Preparing ReMastera.app bundle structure..."
APP_DIR="build/ReMastera.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# 3. Copy compiled binary, frameworks and resources
echo "Step 3: Copying executable, frameworks, and resources..."
cp ".build/release/ReMastera" "$APP_DIR/Contents/MacOS/ReMastera"

# Copy dynamic binary framework dependencies (e.g. Sparkle, RiveRuntime)
mkdir -p "$APP_DIR/Contents/Frameworks"
if [ -d ".build/arm64-apple-macosx/release" ]; then
    find .build/arm64-apple-macosx/release -name "*.framework" -maxdepth 1 -exec cp -R {} "$APP_DIR/Contents/Frameworks/" \;
elif [ -d ".build/x86_64-apple-macosx/release" ]; then
    find .build/x86_64-apple-macosx/release -name "*.framework" -maxdepth 1 -exec cp -R {} "$APP_DIR/Contents/Frameworks/" \;
else
    # Dynamic search fallback
    find .build -type d -path "*/release/*.framework" -exec cp -R {} "$APP_DIR/Contents/Frameworks/" \;
fi

# Configure executable runpath search path (rpath) to search the Frameworks directory
echo "  -> Tweaking executable runpath search paths..."
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_DIR/Contents/MacOS/ReMastera" || true

if [ -f "Assets/AppIcon.icns" ]; then
    cp "Assets/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

# 4. Generate Info.plist
echo "Step 4: Writing Info.plist metadata..."
cat <<EOF > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ReMastera</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.sgkrishna.remastera</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>ReMastera</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSBackgroundOnly</key>
    <false/>
</dict>
</plist>
EOF

# 5. Compress the app bundle and generate DMG
echo "Step 5: Generating DMG and Zip for distribution..."
mkdir -p build/Dist

echo "  -> Creating ZIP archive..."
(cd build && zip -r -y "Dist/ReMastera-macOS.zip" "ReMastera.app" >/dev/null)

echo "  -> Creating DMG volume..."
hdiutil create -volname "ReMastera Installer" -srcfolder "$APP_DIR" -ov -format UDZO "build/Dist/ReMastera.dmg" >/dev/null

# 6. Copy artifacts to the project root directory
echo "Step 6: Copying ReMastera.app and ReMastera.dmg to the project root directory..."
rm -rf "ReMastera.app"
cp -R "$APP_DIR" "ReMastera.app"
cp "build/Dist/ReMastera.dmg" "ReMastera.dmg"

# 7. Deploy to ~/Applications/ReMastera.app with timestamped backups of any existing installation
echo "Step 7: Deploying to ~/Applications/ReMastera.app..."
APPLICATIONS_DIR="$HOME/Applications"
mkdir -p "$APPLICATIONS_DIR"
TARGET_APP="$APPLICATIONS_DIR/ReMastera.app"

if [ -d "$TARGET_APP" ]; then
    MONTH=$(date "+%b")
    DAY=$(date "+%d")
    YEAR=$(date "+%Y")
    HOUR=$(date "+%I")
    MINUTE=$(date "+%M")
    AMPM=$(date "+%p" | tr 'A-Z' 'a-z')
    TIMESTAMP="${MONTH}-${DAY}-${YEAR}-${HOUR}-${MINUTE}-${AMPM}"
    RENAMED_APP="$APPLICATIONS_DIR/ReMastera-${TIMESTAMP}.app"
    echo "  -> Renaming existing app to $(basename "$RENAMED_APP")"
    mv "$TARGET_APP" "$RENAMED_APP"
fi

echo "  -> Copying new version to ~/Applications/ReMastera.app"
cp -R "ReMastera.app" "$TARGET_APP"

echo ""
echo "=================================================="
echo "Packaging complete: build/Dist/ReMastera-macOS.zip"
echo "Root App: ReMastera.app"
echo "Root DMG: ReMastera.dmg"
echo "Applications App: ~/Applications/ReMastera.app"
echo "=================================================="
echo ""
echo "Note on Codesigning and Notarization:"
echo "Distribution on modern macOS requires code signing and notarization."
echo "If developer credentials are configured, execute the following commands:"
echo ""
echo "  1. Codesign the bundle:"
echo "     codesign --force --options runtime --sign \"Developer ID Application: Your Name (ID)\" \"$APP_DIR\""
echo ""
echo "  2. Submit for notarization:"
echo "     xcrun notarytool submit build/Dist/ReMastera-macOS.zip --keychain-profile \"MyProfile\" --wait"
echo ""
echo "  3. Staple the ticket:"
echo "     xcrun stapler staple \"$APP_DIR\""
echo "=================================================="
