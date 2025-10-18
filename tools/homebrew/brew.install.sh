#!/bin/bash

echo "🛠️  Brewing up a fresh batch of formulae and casks..."

mkdir -p homebrew

echo "☕ Extracting your casks with magical precision..."
brew list --casks > homebrew/casks.json
echo "✅ Your casks are bottled up and ready in homebrew/casks.txt!"

echo "🎩 Summoning your installed formulae into a neat list..."
brew list --formulae > homebrew/formulae.txt
echo "✅ Your formulae have been concocted and saved in homebrew/formulae.txt!"

echo "✨ All done! Enjoy your organized Homebrew packages. 🍺"
