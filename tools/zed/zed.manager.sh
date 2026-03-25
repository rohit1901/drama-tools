#!/bin/bash

# Unified script to manage Zed editor configurations (export and install)

# Function to export Zed configurations
export_zed_config() {
    echo "🛠️  Exporting Zed editor configurations..."

    local zed_config_dir="$HOME/.config/zed"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if Zed config directory exists
    if [ ! -d "$zed_config_dir" ]; then
        echo "❌ Error: Zed config directory not found at '$zed_config_dir'"
        echo "   Make sure Zed editor is installed and has been run at least once."
        exit 1
    fi

    # Export settings.json
    if [ -f "$zed_config_dir/settings.json" ]; then
        echo "⚙️  Exporting settings.json..."
        cp "$zed_config_dir/settings.json" "$script_dir/zed.settings.json"
        echo "✅ Settings exported to zed.settings.json!"
    else
        echo "⚠️  No settings.json found. Skipping settings export."
    fi

    # Export keymap.json
    if [ -f "$zed_config_dir/keymap.json" ]; then
        echo "⌨️  Exporting keymap.json..."
        cp "$zed_config_dir/keymap.json" "$script_dir/zed.keymap.json"
        echo "✅ Keymap exported to zed.keymap.json!"
    else
        echo "⚠️  No keymap.json found. Skipping keymap export."
    fi

    echo "✨ All Zed configurations exported successfully!"
}

# Function to install Zed configurations
install_zed_config() {
    echo "🛠️  Installing Zed editor configurations..."

    local zed_config_dir="$HOME/.config/zed"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Create Zed config directory if it doesn't exist
    if [ ! -d "$zed_config_dir" ]; then
        echo "📁 Creating Zed config directory at '$zed_config_dir'..."
        mkdir -p "$zed_config_dir"
    fi

    # Install settings.json
    if [ -f "$script_dir/zed.settings.json" ]; then
        echo "⚙️  Installing settings.json..."
        cp "$script_dir/zed.settings.json" "$zed_config_dir/settings.json"
        echo "✅ Settings installed!"
    else
        echo "⚠️  No zed.settings.json found. Skipping settings installation."
    fi

    # Install keymap.json
    if [ -f "$script_dir/zed.keymap.json" ]; then
        echo "⌨️  Installing keymap.json..."
        cp "$script_dir/zed.keymap.json" "$zed_config_dir/keymap.json"
        echo "✅ Keymap installed!"
    else
        echo "⚠️  No zed.keymap.json found. Skipping keymap installation."
    fi

    echo "✨ All Zed configurations installed successfully!"
    echo "💡 Zed will automatically pick up the new settings."
}

# Main script logic
if [ "$1" = "export" ]; then
    export_zed_config
elif [ "$1" = "install" ]; then
    install_zed_config
else
    echo "Usage: $0 [export|install]"
    echo "  export: Export Zed configurations from ~/.config/zed to this directory."
    echo "  install: Install Zed configurations from this directory to ~/.config/zed."
    exit 1
fi
