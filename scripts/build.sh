#!/usr/bin/env bash
# ReMastera Compiler Script
set -euo pipefail

echo "=================================================="
echo "Compiling ReMastera (Release Configuration)..."
echo "=================================================="

# Check if Swift is installed
if ! command -v swift >/dev/null 2>&1; then
    echo "Error: Swift driver is not installed or not in PATH."
    exit 1
fi

# Run swift build
swift build -c release

echo ""
echo "Compilation complete."
echo "Executable generated at: .build/release/ReMastera"
echo "To run, execute: .build/release/ReMastera"
