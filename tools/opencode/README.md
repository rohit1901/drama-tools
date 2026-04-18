# opencode-manager

A TypeScript CLI tool to install and manage [openrtk](https://github.com/martinstannard/openrtk) (plugin) and [Caveman](https://opencode.ai/docs/skills/) (skill) into your [OpenCode](https://opencode.ai/) configuration.

---

## Features

- Installs the **openrtk plugin** entry into `opencode.json`
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

## Usage

```sh
# Install both openrtk plugin and Caveman skill (default)
opencode-manager install

# Install only the openrtk plugin
opencode-manager install --rtk-only

# Install only the Caveman skill
opencode-manager install --caveman-only

# Use a custom OpenCode config directory
opencode-manager install --dir /path/to/opencode/config

# Check current installation status
opencode-manager export
```

## Config Directory Resolution

The tool resolves the OpenCode config directory in the following order:

1. `--dir` flag (highest priority)
2. `OPENCODE_CONFIG_DIR` environment variable
3. `~/.config/opencode` (default)

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

## What Gets Installed

### openrtk Plugin

Adds the following entry to `opencode.json`:

```json
{
  "plugin": ["openrtk"]
}
```

OpenCode automatically installs the `openrtk` npm package via Bun at startup. The plugin intercepts shell commands and pipes them through [RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) for automatic output compression, reducing LLM token consumption by 60-90%.

### Caveman Skill

Copies `assets/caveman.md` to `skills/caveman.md`.

## Requirements

- Node.js 18+
- npm
- OpenCode installed and configured
- RTK binary: `cargo install rtk` (required by the openrtk plugin at runtime)
