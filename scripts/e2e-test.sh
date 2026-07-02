#!/usr/bin/env bash
# E2E Test Script for ReMastera
set -euo pipefail

TEST_FILE="/Users/sgkrishna/Desktop/ReMastera-Test-Files/test-spanish-file.mp4"

if [ ! -f "$TEST_FILE" ]; then
    echo "Test file not found at $TEST_FILE. Please ensure it exists."
    exit 1
fi

TIMESTAMP=$(date "+%b-%d-%Y-%H-%M-%S")
TEST_DIR="ReMastera-Test-$TIMESTAMP"

echo "Creating test directory: $TEST_DIR"
mkdir -p "$TEST_DIR"

echo "Copying test file..."
cp "$TEST_FILE" "$TEST_DIR/"

echo "Running ReMastera CLI against test directory..."
# Assuming we want to build and run the release version
swift build -c release
.build/release/ReMasteraCLI "$TEST_DIR" "${TEST_DIR}_Processed" --preset fast-preview

echo "Test complete! Check ${TEST_DIR}_Processed for the output."
