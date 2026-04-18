#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ─── Mode dispatch ───────────────────────────────────────────────────────────
MODE="${1:-shell}"

case "$MODE" in
  shell)
    _setup_shell
    ;;
  opencode)
    _setup_opencode
    ;;
  -h|--help)
    _show_help
    ;;
  *)
    echo "Error: Unknown mode '$MODE'. Run './setup.sh --help' for usage."
    exit 1
    ;;
esac

# ─── Shell setup (original behaviour) ───────────────────────────────────────
_setup_shell() {
  SHELL_TYPE=$(basename "$SHELL")
  if [ "$SHELL_TYPE" = "zsh" ]; then
    SOURCE_FILE="$SCRIPT_DIR/tools/shell/zsh.zshrc"
    TARGET_FILE="$HOME/.zshrc"
  elif [ "$SHELL_TYPE" = "bash" ]; then
    SOURCE_FILE="$SCRIPT_DIR/tools/shell/bash.bashrc"
    TARGET_FILE="$HOME/.bashrc"
  else
    echo "Error: Unsupported shell type: $SHELL_TYPE"
    exit 1
  fi

  if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE does not exist."
    exit 1
  fi

  if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Target file $TARGET_FILE does not exist."
    exit 1
  fi

  if grep -q "source $SOURCE_FILE" "$TARGET_FILE"; then
    echo "The source file is already linked in $TARGET_FILE."
    exit 0
  fi

  echo "source $SOURCE_FILE" >> "$TARGET_FILE"
  source "$TARGET_FILE"
  echo "Setup complete! The functions from $SOURCE_FILE are now available in your shell."
}

# ─── OpenCode setup ──────────────────────────────────────────────────────────
_setup_opencode() {
  OPENCODE_TOOL_DIR="$SCRIPT_DIR/tools/opencode"

  if [ ! -d "$OPENCODE_TOOL_DIR" ]; then
    echo "Error: tools/opencode directory not found at '$OPENCODE_TOOL_DIR'"
    exit 1
  fi

  echo ""
  echo "  Setting up opencode-manager..."

  # Check Node.js is available
  if ! command -v node >/dev/null 2>&1; then
    echo "  Error: Node.js is required but not installed."
    echo "  Install Node.js >= 18 from https://nodejs.org and re-run."
    exit 1
  fi

  # Check npm is available
  if ! command -v npm >/dev/null 2>&1; then
    echo "  Error: npm is required but not found."
    exit 1
  fi

  # Install dependencies
  echo "  Installing npm dependencies..."
  (cd "$OPENCODE_TOOL_DIR" && npm install --silent)
  if [ $? -ne 0 ]; then
    echo "  Error: npm install failed."
    exit 1
  fi

  # Build TypeScript
  echo "  Building TypeScript..."
  (cd "$OPENCODE_TOOL_DIR" && npm run build --silent)
  if [ $? -ne 0 ]; then
    echo "  Error: TypeScript build failed."
    exit 1
  fi

  # Run the CLI install command
  echo "  Running opencode-manager install..."
  node "$OPENCODE_TOOL_DIR/dist/index.js" install

  echo ""
  echo "  opencode-manager setup complete!"
  echo "  Re-source your shell profile or open a new terminal to use 'opencode-manager'."
  echo ""
}

# ─── Help ────────────────────────────────────────────────────────────────────
_show_help() {
  cat <<'EOF'

  drama-tools/setup.sh — environment bootstrap

  Usage:
    ./setup.sh [mode]

  Modes:
    shell      (default) Link shell profile (bash/zsh) to ~/.bashrc or ~/.zshrc
    opencode   Install RTK plugin + Caveman skill into OpenCode config
    -h, --help Show this help

  Examples:
    ./setup.sh              # set up shell profile
    ./setup.sh shell        # same as above
    ./setup.sh opencode     # install RTK + Caveman for OpenCode

EOF
}
