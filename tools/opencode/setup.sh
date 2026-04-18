#!/usr/bin/env bash
set -euo pipefail

# opencode-manager setup script
# Builds and installs the opencode-manager CLI tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  opencode-manager setup"
echo "  ========================"
echo ""

# Check for Node.js
if ! command -v node &>/dev/null; then
  echo "  ERROR: Node.js is not installed. Please install Node.js 18+ first."
  exit 1
fi

# Check for npm
if ! command -v npm &>/dev/null; then
  echo "  ERROR: npm is not installed. Please install npm first."
  exit 1
fi

echo "  Installing dependencies..."
cd "$SCRIPT_DIR"
npm install --silent

echo "  Building TypeScript..."
npm run build --silent

echo "  Installing CLI globally..."
npm install -g . --silent

echo ""
echo "  Done! opencode-manager is now available globally."
echo ""
echo "  Usage:"
echo "    opencode-manager install          # Install RTK + Caveman"
echo "    opencode-manager install --rtk-only"
echo "    opencode-manager install --caveman-only"
echo "    opencode-manager install --dir /path/to/opencode/config"
echo "    opencode-manager export           # Show current config status"
echo ""
