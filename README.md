# drama-tools
A collection of machine-environment helper scripts, shell profiles, and Home-brew formulae for macOS.

This repository is a personal toolbox that keeps my dev environment reproducible and easy to refresh.
All of the files live under the `tools/` directory and can be copied into your own home directory or shared with a team.

---

## 📦 Structure

```drama-tools/tools#L1-100
# tools/
|
├── shell/                          # Shell profiles for Bash and Zsh
|   ├── bash.bashrc                 # Custom commands for Bash users
|   └── zsh.zshrc                   # Custom commands for Zsh users
├── zed/                            # Zed editor configurations
|   ├── zed.settings.json           # Default settings for Zed editor
|   └── zed.keymap.json             # Default keymap for Zed editor
├── homebrew/                       # Homebrew casks and formulae
|   ├── brew.manager.sh             # Unified script to export and install Homebrew dependencies
|   ├── generated/                  # Generated files for Homebrew dependencies
|   |   ├── casks.json              # Exported casks in JSON format
|   |   ├── casks.txt               # Exported casks in plain text
|   |   ├── formulae.json           # Exported formulae in JSON format
|   |   └── formulae.txt            # Exported formulae in plain text
├── opencode/                       # OpenCode AI tools (RTK + Caveman)
|   ├── assets/
|   |   └── caveman.md              # Caveman skill file (copied to OpenCode skills/)
|   ├── src/
|   |   ├── commands/
|   |   |   ├── install.ts          # Install command
|   |   |   └── export.ts           # Export/status command
|   |   ├── lib/
|   |   |   ├── config.ts           # Config dir resolver
|   |   |   ├── rtk.ts              # RTK plugin installer
|   |   |   └── caveman.ts          # Caveman skill installer
|   |   └── index.ts                # CLI entrypoint
|   ├── package.json
|   └── tsconfig.json
├── .gitattributes
├── .gitignore
└── README.md
```

- `shell/bash.bashrc` & `shell/zsh.zshrc` provide helper commands:
  - *`oprc`* - open the current shell profile in your favourite editor.
  - *`app-hound`* - Run app-hound to audit an application installed on your system
  - *`brew-manager`* - export or install Homebrew dependencies (wraps `brew.manager.sh`)
  - *`zed-manager`* - export or install Zed editor configurations (wraps `zed.manager.sh`)
  - *`opencode-manager`* - install RTK plugin and Caveman skill for OpenCode
  - *`my-commands`* - list the available helpers.

- `homebrew/brew.manager.sh` is a unified script to export and install Homebrew dependencies.
- `generated/` contains dynamically generated files for Homebrew dependencies (`casks.json`, `casks.txt`, `formulae.json`, `formulae.txt`).
- `zed/zed.manager.sh` is a unified script to export and install Zed editor configurations.
- `zed/zed.settings.json` contains a sane default configuration for the [Zed](https://zed.dev/) editor.
- `zed/zed.keymap.json` contains a sane default keymap for the [Zed](https://zed.dev/) editor.
- `opencode/` contains the `opencode-manager` TypeScript CLI tool to install [RTK](https://github.com/opencode-ai/rtk) (plugin) and [Caveman](https://github.com/JuliusBrussee/caveman) (skill) for [OpenCode](https://opencode.ai).

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
zed-manager install
```

> The `zed-manager` command automatically installs Zed settings and keymap to `~/.config/zed`. Zed will pick up the new settings immediately.

### 5️⃣ Set up OpenCode (RTK + Caveman)

```sh
./drama-tools/setup.sh opencode
```

This will:
1. Install npm dependencies for the `opencode-manager` CLI
2. Build the TypeScript source
3. Inject the **RTK plugin** entry into `~/.config/opencode/opencode.json`
4. Copy the **Caveman skill** file to `~/.config/opencode/skills/caveman.md`

Both operations are **idempotent** — safe to run multiple times.

> **Config dir resolution order:**
> 1. `OPENCODE_CONFIG_DIR` environment variable
> 2. `--dir` flag
> 3. `~/.config/opencode` (default)

---

## 📘 Custom Commands Overview

| Command | Description | Usage |
|---------|-------------|-------|
| `oprc` | Opens the current shell profile (`.bashrc` or `.zshrc`) in an editor. | `oprc` <br>`oprc -s=zsh -i=code` |
| `app-hound` | Run `app-hound` to audit an application installed on your system | `app-hound [-h] [-i INPUT] [-o OUTPUT]` <br>`app-hound` |
| `brew-manager` | Export or install Homebrew dependencies (casks and formulae) | `brew-manager export` <br>`brew-manager install` |
| `zed-manager` | Export or install Zed editor configurations (settings and keymap) | `zed-manager export` <br>`zed-manager install` |
| `opencode-manager` | Install RTK plugin and Caveman skill for OpenCode | `opencode-manager install` <br>`opencode-manager export` <br>`opencode-manager install --dir /custom/path` |
| `my-commands` | Lists all available helper commands. | `my-commands` |

> All commands accept `-h` or `--help` to show detailed usage.

**Note:** The `my-commands` output will also dynamically include the following tools if they are installed:
- `lazygit` - Terminal UI for git commands
- `lazysql` - Browse SQL databases with lazysql
- `lazydocker` - Terminal UI for docker and docker-compose

---

## 🦖 OpenCode Manager (`opencode-manager`)

The `opencode-manager` CLI lives in `tools/opencode/` and is a standalone Node.js TypeScript tool.

### What it does

| Tool | Type | Target | What it installs |
|------|------|--------|------------------|
| **RTK** | Plugin | `opencode.json` | Adds `@opencode/plugin-rtk` to the `plugins` array + default `pluginConfig` |
| **Caveman** | Skill | `skills/caveman.md` | Copies the bundled `caveman.md` into the OpenCode skills directory |

### Commands

```sh
# Install both RTK and Caveman
opencode-manager install

# Install only RTK
opencode-manager install --rtk-only

# Install only Caveman
opencode-manager install --caveman-only

# Install into a custom config directory
opencode-manager install --dir /path/to/opencode/config

# Check installation status
opencode-manager export
```

### Manual build (without setup.sh)

```sh
cd tools/opencode
npm install
npm run build
node dist/index.js install
```

---

## 📄 License

This project is licensed under the MIT License – see the `LICENSE` file for details.

---

## 👀 Quick Start Checklist

1. [ ] Clone repo
2. [ ] Export and install Homebrew dependencies
3. [ ] Copy shell scripts
4. [ ] Copy Zed settings
5. [ ] Set up OpenCode (RTK + Caveman) with `./setup.sh opencode`
6. [ ] Enjoy your streamlined dev environment
