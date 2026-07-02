#!/usr/bin/env bash
# ReMastera TUI Installer
set -euo pipefail

echo "=================================================="
echo "Installing ReMastera Python TUI (Textual Dashboard)"
echo "=================================================="

cd "$(dirname "$0")/.."
REPO_ROOT=$(pwd)

echo "Compiling ReMasteraCLI (Swift Core)..."
swift build -c release --product ReMasteraCLI

echo "Setting up Python Environment in cli/ using uv..."
if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv (fast python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

cd "$REPO_ROOT/cli"
uv venv
source .venv/bin/activate
uv pip install -e .

echo ""
echo "=================================================="
echo "Installation Complete!"
echo "To launch the beautiful CLI dashboard, run:"
echo "  source cli/.venv/bin/activate"
echo "  remastera <source> <destination>"
echo "=================================================="
