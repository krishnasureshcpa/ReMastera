#!/usr/bin/env bash
# ReMastera Test Suite Runner
set -euo pipefail

echo "=================================================="
echo "Running ReMastera Unit Tests..."
echo "=================================================="

if ! command -v swift >/dev/null 2>&1; then
    echo "Error: Swift driver is not installed or not in PATH."
    exit 1
fi

# Run custom executable target containing assertions
swift run ReMasteraTests
