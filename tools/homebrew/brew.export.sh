#!/bin/bash

echo "🛠️  Brewing up a fresh batch of JSON files..."

mkdir -p homebrew

echo "☕ Extracting your casks with magical precision..."
brew info --json=v2 --installed --casks | jq '.casks | map({name: .name[0], version, tap})' > homebrew/casks.json
echo "✅ Your casks are bottled up and ready in homebrew/casks.json!"

echo "🎩 Summoning your installed formulae into a neat list..."
brew info --json=v2 --installed --formulae | jq '.formulae | map({name, version: .installed[0].version, tap})' > homebrew/formulae.json
echo "✅ Your formulae have been concocted and saved in homebrew/formulae.json!"

echo "✨ All done! Enjoy your organized Homebrew packages. 🍺"
