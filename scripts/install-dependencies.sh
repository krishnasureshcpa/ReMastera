#!/usr/bin/env bash
# ReMastera Dependency Installation Script
set -euo pipefail

echo "=================================================="
echo "ReMastera Dependency Installer"
echo "=================================================="

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed on this system."
    echo "Homebrew is required to install CLI dependencies."
    echo "To install Homebrew, run:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "Please install Homebrew and run this script again."
    exit 1
fi

echo "Homebrew is available."

# Function to prompt for installation
install_package() {
    local pkg_name="$1"
    local desc="$2"
    
    echo ""
    echo "Package: $pkg_name"
    echo "Description: $desc"
    
    read -p "Do you want to install $pkg_name using Homebrew? (y/N): " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            echo "Installing $pkg_name..."
            brew install "$pkg_name"
            ;;
        *)
            echo "Skipping $pkg_name installation."
            ;;
    esac
}

# Prompt for required packages
install_package "ffmpeg" "Required for video decoding, filtering, and final HEVC hardware encoding."

# Prompt for optional packages
echo ""
echo "--------------------------------------------------"
echo "Optional Advanced Stages (Whisper, Upscaling, HDR)"
echo "--------------------------------------------------"
install_package "whisper-cpp" "Enables local subtitle extraction."
install_package "realesrgan-ncnn-vulkan" "Enables local AI upscale resolution enhancement."
install_package "rife-ncnn-vulkan" "Enables local AI-powered frame rate interpolation."
install_package "dovi_tool" "Enables Dolby Vision metadata parsing and mapping hooks."

echo ""
echo "Installation process complete. Run ./scripts/check-dependencies.sh to verify."
