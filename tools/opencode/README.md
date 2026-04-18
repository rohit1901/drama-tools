# opencode-manager

A TypeScript CLI tool to install and manage [RTK](https://docs.opencode.ai/plugins/rtk) (plugin) and [Caveman](https://docs.opencode.ai/skills/caveman) (skill) into your [OpenCode](https://opencode.ai) configuration.

---

## Features

- Installs the **RTK plugin** entry into `opencode.json`
- Copies the **Caveman skill** markdown file into `~/.config/opencode/skills/`
- Supports custom config directory via `--dir` flag or `OPENCODE_CONFIG_DIR` env var
- Idempotent — safely re-runs without duplicating entries
- Export command to inspect current OpenCode config status

---

## Quick Start

```sh
# From the drama-tools repo root
./setup.sh opencode
```

Or manually:

```sh
cd tools/opencode
npm install
npm run build
npm install -g .
```

---

## Usage

```sh
# Install both RTK plugin and Caveman skill (default)
opencode-manager install

# Install only the RTK plugin
opencode-manager install --rtk-only

# Install only the Caveman skill
opencode-manager install --caveman-only

# Use a custom OpenCode config directory
opencode-manager install --dir /path/to/opencode/config

# Check current installation status
opencode-manager export
```

---

## Config Directory Resolution

The tool resolves the OpenCode config directory in the following order:

1. `--dir <path>` flag (highest priority)
2. `OPENCODE_CONFIG_DIR` environment variable
3. `~/.config/opencode` (default)

---

## Structure

```
opencode/
├── assets/
│   └── caveman.md          # Caveman skill definition
├── src/
│   ├── commands/
│   │   ├── install.ts      # install command
│   │   └── export.ts       # export command
│   ├── lib/
│   │   ├── caveman.ts      # Caveman skill installer
│   │   ├── config.ts       # Config directory resolver
│   │   └── rtk.ts          # RTK plugin installer
│   └── index.ts            # CLI entry point
├── package.json
└── tsconfig.json
```

> Setup is handled by the root `setup.sh opencode` command.

---

## What Gets Installed

### RTK Plugin

Adds the following entry to `opencode.json`:

```json
{
  "plugins": ["rtk"]
}
```

### Caveman Skill

Copies `assets/caveman.md` to `<config-dir>/skills/caveman.md`.

---

## Requirements

- Node.js 18+
- npm
- OpenCode installed and configured
