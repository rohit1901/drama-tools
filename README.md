# drama-tools
A collection of machine‑environment helper scripts, shell profiles, and Home‑brew formulae for macOS.

This repository is a personal toolbox that keeps my dev environment reproducible and easy to refresh.
All of the files live under the `tools/` directory and can be copied into your own home directory or shared with a team.

---

## 📦 Structure

```drama-tools/tools#L1-100
# tools/
│
├── shell/                      # Shell profiles for Bash and Zsh
│   ├── bash.bashrc             # Custom commands for Bash users
│   └── zsh.zshrc               # Custom commands for Zsh users
├── zed/                        # Zed editor configurations
│   ├── zed.settings.json       # Default settings for Zed editor
│   └── zed.keymap.json         # Default keymap for Zed editor
├── homebrew/                   # Homebrew casks and formulae
│   ├── brew.manager.sh         # Unified script to export and install Homebrew dependencies
│   ├── generated/              # Generated files for Homebrew dependencies
│   │   ├── casks.json          # Exported casks in JSON format
│   │   ├── casks.txt           # Exported casks in plain text
│   │   ├── formulae.json       # Exported formulae in JSON format
│   │   └── formulae.txt        # Exported formulae in plain text
├── .gitattributes
├── .gitignore
└── README.md
```

- `shell/bash.bashrc` & `shell/zsh.zshrc` provide three helper commands:
  - *`oprc`* - open the current shell profile in your favourite editor.
  - *`aider-chat`* - launch `aider` against an Ollama model (with optional file‑watching).
  - *`app-hound`* - Run app-hound to audit an application installed on your system
  - *`my-commands`* - list the available helpers.


- `homebrew/brew.manager.sh` is a unified script to export and install Homebrew dependencies.
- `generated/` contains dynamically generated files for Homebrew dependencies (`casks.json`, `casks.txt`, `formulae.json`, `formulae.txt`).

- `zed/zed.settings.json` contains a sane default configuration for the [Zed](https://zed.dev/) editor.
- `zed/zed.keymap.json` contains a sane default keymap for the [Zed](https://zed.dev/) editor.

---

## ⚙️ Setup

### 1️⃣ Clone the repo

```sh
git clone https://github.com/your-username/drama-tools.git
```

### 2️⃣ Export and Install Homebrew Dependencies

To export all your Homebrew dependencies (formulae and casks) to the `generated` folder, run:

```sh
./drama-tools/tools/homebrew/brew.manager.sh export
```

To install all dependencies from the `generated` folder, run:

```sh
./drama-tools/tools/homebrew/brew.manager.sh install
```

> **Tip:** The `brew.manager.sh` script simplifies the process by handling both export and install operations in a single command.

### 3️⃣ Run the setup script

```sh
./drama-tools/setup.sh
```

> The `setup.sh` script automatically detects your shell type (Bash or Zsh) and links the appropriate shell profile (`bash.bashrc` or `zsh.zshrc`) to your shell configuration file. It also reloads the shell configuration for you.

### 4️⃣ Configure Zed

```sh
cp drama-tools/tools/zed/zed.settings.json ~/.config/zed/settings.json
cp drama-tools/tools/zed/zed.keymap.json ~/.config/zed/keymap.json
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
2. [ ] Export and install Homebrew dependencies
3. [ ] Copy shell scripts
4. [ ] Copy Zed settings
5. [ ] (Optional) Start Ollama and pull a model
6. [ ] Enjoy your streamlined dev environment

Feel free to customize the shell scripts or add new Home‑brew formulae as your workflow evolves. Happy coding!
