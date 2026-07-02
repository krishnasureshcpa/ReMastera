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

# 3. Copy compiled binary and resources
echo "Step 3: Copying executable and resources..."
cp ".build/release/ReMastera" "$APP_DIR/Contents/MacOS/ReMastera"
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

echo ""
echo "=================================================="
echo "Packaging complete: build/Dist/ReMastera-macOS.zip"
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
