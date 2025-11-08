# drama-tools
A collection of machine‑environment helper scripts, shell profiles, and Home‑brew formulae for macOS.

This repository is a personal toolbox that keeps my dev environment reproducible and easy to refresh.
All of the files live under the `tools/` directory and can be copied into your own home directory or shared with a team.

---

## 📦 Structure

```drama-tools/tools#L1-100
# tools/
│
├── bash.bashrc         # Custom commands for Bash users
├── zsh.zshrc           # Custom commands for Zsh users
├── zed.settings.json   # Default settings for Zed editor
├── zed.keymap.json     # Default keymap for Zed editor
├── homebrew/           # Homebrew casks and formulae
├── .gitattributes
├── .gitignore
└── README.md
```

- `bash.bashrc` & `zsh.zshrc` provide three helper commands:
  - *`oprc`* - open the current shell profile in your favourite editor.
  - *`aider-chat`* - launch `aider` against an Ollama model (with optional file‑watching).
  - *`app-hound`* - Run app-hound to audit an application installed on your system
  - *`my-commands`* - list the available helpers.


- `homebrew/formulae.json` is a list of Home‑brew formulae that I keep on my machine.
- `homebrew/casks.json` is a list of Home‑brew casks that I keep on my machine.
- `homebrew/formulae.txt` is a list of Home‑brew formulae that I keep on my machine.
- `homebrew/casks.txt` is a list of Home‑brew casks that I keep on my machine.
- `homebrew/brew.install.sh` is a script to install Homebrew formulae and casks.
- `homebrew/brew.export.sh` is a script to export Homebrew formulae and casks.

- `zed.settings.json` contains a sane default configuration for the [Zed](https://zed.dev/) editor.
- `zed.keymap.json` contains a sane default keymap for the [Zed](https://zed.dev/) editor.

---

## ⚙️ Setup

### 1️⃣ Clone the repo

```sh
git clone https://github.com/your-username/drama-tools.git
```

### 2️⃣ Install Homebrew dependencies

```sh
brew bundle --file=drama-tools/tools/homebrew/formulae.txt
brew bundle --file=drama-tools/tools/homebrew/casks.txt
```

> **Tip:** If you use a different Home‑brew directory or want to keep this repo separate from your own formulae, copy the file to the root of the Home‑brew directory and run `brew bundle` from there.

### 3️⃣ Copy shell helpers

```sh
cp drama-tools/tools/bash.bashrc ~/.bashrc
cp drama-tools/tools/zsh.zshrc ~/.zshrc
```

> After copying, restart your terminal or run `source ~/.bashrc` / `source ~/.zshrc`.

### 4️⃣ Configure Zed

```sh
cp drama-tools/tools/zed.settings.json ~/.config/zed/settings.json
cp drama-tools/tools/zed.keymap.json ~/.config/zed/keymap.json
```

> Zed will automatically pick up the settings on the next launch.

### 5️⃣ Install Ollama & models (if you want `aider-chat`)

```sh
brew install ollama
ollama serve   # start the server
ollama pull llama3.2:3b   # or any other model you prefer
```

Now you can run:

```sh
aider-chat          # launches default model (llama3.2:3b)
aider-chat mistral:7b -w  # watch files for changes
```

---

## 📘 Custom Commands Overview

| Command | Description | Usage |
|---------|-------------|-------|
| `oprc` | Opens the current shell profile (`.bashrc` or `.zshrc`) in an editor. | `oprc` <br> `oprc -s=zsh -i=code` |
| `aider-chat` | Launches `aider` against a local Ollama model. | `aider-chat` <br> `aider-chat gemma3 -w` |
| `app-hound` | Run `app-hound` to audit an application installed on your system | `app-hound [-h] [-i INPUT] [-o OUTPUT]` <br> `app-hound` |
| `my-commands` | Lists all available helper commands. | `my-commands` |

> All commands accept `-h` or `--help` to show detailed usage.

---

## 📄 License

This project is licensed under the MIT License – see the `LICENSE` file for details.

---

## 👀 Quick Start Checklist

1. [ ] Clone repo
2. [ ] `brew bundle`
3. [ ] Copy shell scripts
4. [ ] Copy Zed settings
5. [ ] (Optional) Start Ollama and pull a model
6. [ ] Enjoy your streamlined dev environment

Feel free to customize the shell scripts or add new Home‑brew formulae as your workflow evolves. Happy coding!
