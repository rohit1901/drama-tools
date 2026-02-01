#!/bin/bash

# Unified script to manage Homebrew dependencies (export and install)

# Function to export all Homebrew dependencies
export_brew_deps() {
    echo "🛠️  Exporting Homebrew dependencies to the generated folder..."

    # Create the generated folder if it doesn't exist
    mkdir -p generated

    # Export casks
    echo "☕ Extracting your casks..."
    brew info --json=v2 --installed --casks | jq '.casks | map({name: .name[0], version, tap})' > generated/casks.json
    echo "✅ Casks exported to generated/casks.json!"

    # Export formulae
    echo "🎩 Extracting your formulae..."
    brew info --json=v2 --installed --formulae | jq '.formulae | map({name, version: .installed[0].version, tap})' > generated/formulae.json
    echo "✅ Formulae exported to generated/formulae.json!"

    # Export plain text lists for compatibility
    echo "📝 Creating plain text lists..."
    brew list --casks > generated/casks.txt
    echo "✅ Casks list exported to generated/casks.txt!"
    brew list --formulae > generated/formulae.txt
    echo "✅ Formulae list exported to generated/formulae.txt!"

    echo "✨ All dependencies exported successfully!"
}

# Function to install all Homebrew dependencies
install_brew_deps() {
    echo "🛠️  Installing Homebrew dependencies from the generated folder..."

    # Check if the generated folder exists
    if [ ! -d "generated" ]; then
        echo "❌ Error: The 'generated' folder does not exist. Please run the export command first."
        exit 1
    fi

    # Install casks
    if [ -f "generated/casks.txt" ]; then
        echo "☕ Installing casks..."
        while read -r cask; do
            brew install --cask "$cask"
        done < generated/casks.txt
        echo "✅ Casks installed!"
    else
        echo "⚠️  No casks.txt file found. Skipping cask installation."
    fi

    # Install formulae
    if [ -f "generated/formulae.txt" ]; then
        echo "🎩 Installing formulae..."
        while read -r formula; do
            brew install "$formula"
        done < generated/formulae.txt
        echo "✅ Formulae installed!"
    else
        echo "⚠️  No formulae.txt file found. Skipping formulae installation."
    fi

    echo "✨ All dependencies installed successfully!"
}

# Main script logic
if [ "$1" = "export" ]; then
    export_brew_deps
elif [ "$1" = "install" ]; then
    install_brew_deps
else
    echo "Usage: $0 [export|install]"
    echo "  export: Export all Homebrew dependencies to the generated folder."
    echo "  install: Install all Homebrew dependencies from the generated folder."
    exit 1
fi
