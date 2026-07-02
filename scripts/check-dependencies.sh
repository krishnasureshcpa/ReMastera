#!/usr/bin/env bash
# ReMastera Dependency Checker CLI Utility
# Strict execution flags
set -euo pipefail

echo "=================================================="
echo "ReMastera Dependency Analysis"
echo "=================================================="

# Function to search for CLI tools
check_tool() {
    local tool_name="$1"
    local is_required="$2"
    local purpose="$3"
    
    echo -n "Checking for $tool_name... "
    
    # Locate tool path
    local tool_path=""
    if command -v "$tool_name" >/dev/null 2>&1; then
        tool_path="$(command -v "$tool_name")"
    elif [ -f "/opt/homebrew/bin/$tool_name" ]; then
        tool_path="/opt/homebrew/bin/$tool_name"
    elif [ -f "/usr/local/bin/$tool_name" ]; then
        tool_path="/usr/local/bin/$tool_name"
    elif [ "$tool_name" = "whisper-cpp" ] && command -v "whisper-cli" >/dev/null 2>&1; then
        tool_path="$(command -v "whisper-cli")"
        tool_name="whisper-cli"
    elif [ "$tool_name" = "whisper-cpp" ] && [ -f "/opt/homebrew/bin/whisper-cli" ]; then
        tool_path="/opt/homebrew/bin/whisper-cli"
        tool_name="whisper-cli"
    elif [ "$tool_name" = "whisper-cpp" ] && [ -f "/usr/local/bin/whisper-cli" ]; then
        tool_path="/usr/local/bin/whisper-cli"
        tool_name="whisper-cli"
    fi
    
    if [ -n "$tool_path" ]; then
        # Query version
        local version=""
        if [[ "$tool_name" == "ffmpeg" || "$tool_name" == "ffprobe" ]]; then
            version="$("$tool_path" -version 2>&1 | head -n 1 | awk '{print $3}')"
        else
            version="$("$tool_path" --version 2>&1 | head -n 1 || echo "Found")"
        fi
        
        echo "Found at $tool_path (version: $version)"
        return 0
    else
        if [ "$is_required" = true ]; then
            echo "Missing (Required)"
            echo "  Purpose: $purpose"
            echo "  Please install using: brew install $tool_name"
            return 1
        else
            echo "Missing (Optional)"
            echo "  Purpose: $purpose"
            return 0
        fi
    fi
}

# Run dependency checks
failed=0

check_tool "ffmpeg" true "Required for video decoding, filtration, and hardware-accelerated HEVC encoding." || failed=1
check_tool "ffprobe" true "Required for metadata scanning, duration extraction, and format identification." || failed=1
check_tool "whisper-cpp" false "Enables local subtitle extraction from audio tracks."
check_tool "realesrgan-ncnn-vulkan" false "Enables AI-powered resolution scaling plugins."
check_tool "rife-ncnn-vulkan" false "Enables local video frame interpolation plugins."
check_tool "dovi_tool" false "Enables parsing and inject of Dolby Vision RPU metadata."

echo "=================================================="
if [ "$failed" -eq 0 ]; then
    echo "All required dependencies are satisfied."
    exit 0
else
    echo "Some required dependencies are missing. Run ./scripts/install-dependencies.sh to install them via Homebrew."
    exit 1
fi
