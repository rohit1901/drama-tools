#!/bin/bash

# Determine the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Determine the shell and target file
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

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE does not exist."
    exit 1
fi

# Check if the target file exists
if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Target file $TARGET_FILE does not exist."
    exit 1
fi

# Check if the source is already linked in the target
if grep -q "source $SOURCE_FILE" "$TARGET_FILE"; then
    echo "The source file is already linked in $TARGET_FILE."
    exit 0
fi

# Append the source command to the target file
echo "source $SOURCE_FILE" >> "$TARGET_FILE"

# Reload the shell configuration
source "$TARGET_FILE"

echo "Setup complete! The functions from $SOURCE_FILE are now available in your shell."
