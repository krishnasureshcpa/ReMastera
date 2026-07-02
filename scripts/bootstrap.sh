#!/usr/bin/env bash
# ReMastera Interactive Bootstrap & Onboarding Utility
set -euo pipefail

echo "=================================================="
echo "Welcome to ReMastera macOS Media Processing Suite"
echo "=================================================="
echo "This script will inspect your system configurations, verify dependencies,"
echo "and guide you through building and testing the local application."
echo "No files will be uploaded, and no silent network requests will be executed."
echo "=================================================="

# 1. Check macOS version
echo "1. Checking macOS version..."
OS_VERSION=$(sw_vers -productVersion)
echo "   Detected macOS: $OS_VERSION"
MAJOR_VERSION=$(echo "$OS_VERSION" | cut -d. -f1)
if [ "$MAJOR_VERSION" -lt 14 ]; then
    echo "   Warning: ReMastera targets macOS 14+ first. You may encounter compatibility issues."
else
    echo "   macOS version is compatible."
fi

# 2. Check Xcode Command Line Tools
echo ""
echo "2. Checking Xcode Command Line Tools..."
if xcode-select -p >/dev/null 2>&1; then
    echo "   Xcode Command Line Tools are active."
else
    echo "   Xcode Command Line Tools are missing."
    read -p "   Do you want to run 'xcode-select --install' now? (y/N): " xc_choice
    if [[ "$xc_choice" =~ ^[yY]([eE][sS])?$ ]]; then
        xcode-select --install
        echo "   Please wait for the installation to finish and re-run this script."
        exit 0
    else
        echo "   Continuing. Build operations may fail without Xcode Command Line Tools."
    fi
fi

# 3. Check Homebrew
echo ""
echo "3. Checking Homebrew..."
if command -v brew >/dev/null 2>&1; then
    echo "   Homebrew is active."
else
    echo "   Homebrew is missing."
    echo "   Homebrew is required to install ffmpeg and optional tools."
    read -p "   Do you want to run the official Homebrew installation script? (y/N): " brew_choice
    if [[ "$brew_choice" =~ ^[yY]([eE][sS])?$ ]]; then
        echo "   Launching Homebrew installer..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "   Skipping Homebrew. Note: You must install dependencies manually."
    fi
fi

# 4. Check dependencies (via check-dependencies script)
echo ""
echo "4. Running dependency check..."
chmod +x ./scripts/check-dependencies.sh ./scripts/install-dependencies.sh
if ./scripts/check-dependencies.sh; then
    echo "   All dependencies resolved."
else
    echo ""
    read -p "   Some dependencies are missing. Run the installer script? (y/N): " install_choice
    if [[ "$install_choice" =~ ^[yY]([eE][sS])?$ ]]; then
        ./scripts/install-dependencies.sh
    fi
fi

# 5. Run tests if requested
echo ""
echo "5. Run verification tests?"
read -p "   Do you want to run the automated unit test suite now? (y/N): " test_choice
if [[ "$test_choice" =~ ^[yY]([eE][sS])?$ ]]; then
    chmod +x ./scripts/test.sh
    ./scripts/test.sh
fi

# 6. Build app if requested
echo ""
echo "6. Compile ReMastera application?"
read -p "   Do you want to compile the SwiftUI macOS binary now? (y/N): " build_choice
if [[ "$build_choice" =~ ^[yY]([eE][sS])?$ ]]; then
    chmod +x ./scripts/build.sh
    ./scripts/build.sh
fi

echo ""
echo "=================================================="
echo "Bootstrap complete. Next steps:"
echo "  To run the app directly:    swift run ReMastera"
echo "  To launch the Xcode project: open ReMastera.xcodeproj"
echo "=================================================="
