# Drama Tools ROOT
export DRAMA_TOOLS_ROOT="$HOME/work/projects/private/drama-tools"

# app-hound ROOT
export APP_HOUND_ROOT="$HOME/work/projects/private/app-hound"




# Open shell profile using `oprc` command
oprc() {
  local default_shell="$(basename "${SHELL:-}")"
  local default_ide="TextEdit"
  local selected_shell="${default_shell}"
  local selected_ide="${default_ide}"

  _oprc_usage() {
      cat <<'EOF'
  ╭──────────────────────────────────────────────╮
  │ 🎯  oprc — Open Profile Rapid Command        │
  ╰──────────────────────────────────────────────╯

  Usage:
    oprc [options]

  Options:
    -s, --shell <shell>        🐚 Pick which shell profile to pop open (zsh | bash).
    -i, --interactive <ide>    🛠  Launch the profile with your editor of choice.
    -h, --help                 📖 Summon this guide on demand.

  Examples:
    🚀 oprc
        Opens your current shell profile in TextEdit.

    🧪 oprc -s bash
        Opens ~/.bashrc in TextEdit.

    🎨 oprc --interactive "Visual Studio Code"
        Opens your current shell profile in VS Code.

    🧩 oprc -s zsh -i "Sublime Text"
        Opens ~/.zshrc in Sublime Text.
EOF
    }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        _oprc_usage
        return 0
        ;;
      -s=*|--shell=*)
        selected_shell="$(basename "${1#*=}")"
        shift
        ;;
      -s|--shell)
        if [[ -n "${2:-}" ]]; then
          selected_shell="$(basename "$2")"
          shift 2
        else
          echo "oprc Error: missing value for $1 option." >&2
          return 2
        fi
        ;;
      -i=*|--interactive=*)
        selected_ide="${1#*=}"
        shift
        ;;
      -i|--interactive)
        if [[ -n "${2:-}" ]]; then
          selected_ide="$2"
          shift 2
        else
          echo "oprc Error: missing value for $1 option." >&2
          return 2
        fi
        ;;
      *)
        echo "oprc Error: unknown option '$1'. See 'oprc --help' for usage." >&2
        return 2
        ;;
    esac
  done

  if [[ -z "${selected_shell}" ]]; then
    echo "oprc Error: shell option cannot be empty." >&2
    return 2
  fi

  local profile_file
  case "${selected_shell}" in
    zsh)  profile_file="${HOME}/.zshrc" ;;
    bash) profile_file="${HOME}/.bashrc" ;;
    *)
      echo "oprc Error: shell must be 'bash' or 'zsh'. Got '${selected_shell}'." >&2
      return 2
      ;;
  esac

  if [[ ! -f "${profile_file}" ]]; then
    echo "oprc Error: profile file '${profile_file}' not found." >&2
    return 3
  fi

  if ! command -v open >/dev/null 2>&1; then
    echo "oprc Error: 'open' command is not available on this system." >&2
    return 127
  fi

  if ! open -Ra "${selected_ide}" >/dev/null 2>&1; then
    echo "oprc Error: application '${selected_ide}' could not be located." >&2
    return 4
  fi

  if ! open -a "${selected_ide}" "${profile_file}"; then
    echo "oprc Error: failed to open '${profile_file}' with '${selected_ide}'." >&2
    return 5
  fi
}



# app-hound command to run app-hound [-h] [-i INPUT] [-o OUTPUT] [-a APP]
app-hound() {
  emulate -L zsh
  setopt noglob

  local root="${APP_HOUND_ROOT:-$HOME/.app-hound}"
  if [[ ! -d $root ]]; then
    print -P "%F{red}✖%f APP_HOUND_ROOT not found at %B${root}%b"
    return 1
  fi

  local cli="poetry run app-hound"
  [[ -n ${APP_HOUND_CLI:-} ]] && cli="${APP_HOUND_CLI}"

  local -a base_cmd
  base_cmd=(${=cli})
  if ! command -v "${base_cmd[1]}" >/dev/null 2>&1; then
    print -P "%F{red}✖%f Unable to locate %B${base_cmd[1]}%b"
    return 127
  fi

  local dry_run=0 app_name="" input_file="" output_file=""
  local -a passthrough=()
  local argv=("$@")
  local i=1

  while (( i <= ${#argv[@]} )); do
    local arg="${argv[i]}"
    case "$arg" in
      --dry-run)
        dry_run=1
        ;;
      -i|--input)
        (( i + 1 <= ${#argv[@]} )) && input_file="${argv[i+1]}" && ((i++))
        ;;
      -o|--output)
        (( i + 1 <= ${#argv[@]} )) && output_file="${argv[i+1]}" && ((i++))
        ;;
      -a|--app-name)
        (( i + 1 <= ${#argv[@]} )) && app_name="${argv[i+1]}" && ((i++))
        ;;
      --app-name=*)
        app_name="${arg#*=}"
        ;;
      --input=*)
        input_file="${arg#*=}"
        ;;
      --output=*)
        output_file="${arg#*=}"
        ;;
      --)
        passthrough+=("${argv[@]:i+1}")
        break
        ;;
      -*)
        passthrough+=("$arg")
        ;;
      *)
        if [[ -z $app_name ]]; then
          app_name="$arg"
        else
          passthrough+=("$arg")
        fi
        ;;
    esac
    ((i++))
  done

  local -a cmd=("${base_cmd[@]}")
  [[ -n $input_file  ]] && cmd+=(--input "$input_file")
  [[ -n $output_file ]] && cmd+=(--output "$output_file")
  [[ -n $app_name    ]] && cmd+=(--app-name "$app_name")
  (( ${#passthrough[@]} )) && cmd+=("${passthrough[@]}")

  if (( dry_run )); then
    print -P "%F{blue}➤ dry-run%f ${(j: :)cmd}"
    return 0
  fi

  builtin pushd "$root" >/dev/null || return 1
  print -P "%F{green}🐾 trail:%f %B${(j: :)cmd}%b"
  "${cmd[@]}"
  local status=$?
  builtin popd >/dev/null
  return $status
}



# brew-manager command to export or install Homebrew dependencies
brew-manager() {
  local root="${DRAMA_TOOLS_ROOT:-$HOME/work/projects/private/drama-tools}"

  if [[ ! -d "$root" ]]; then
    echo "brew-manager Error: DRAMA_TOOLS_ROOT not found at '$root'" >&2
    return 1
  fi

  local script="$root/tools/homebrew/brew.manager.sh"

  if [[ ! -f "$script" ]]; then
    echo "brew-manager Error: Script not found at '$script'" >&2
    return 1
  fi

  # Show help if no arguments or -h/--help
  if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat <<'EOF'
╭──────────────────────────────────────────────╮
│ 🍺  brew-manager — Homebrew Dependency Tool  │
╰──────────────────────────────────────────────╯

Usage:
  brew-manager [command]

Commands:
  export     Export all Homebrew dependencies to generated folder
  install    Install all Homebrew dependencies from generated folder
  -h, --help Show this help message

Examples:
  🚀 brew-manager export
      Exports all installed casks and formulae to JSON and text files

  📦 brew-manager install
      Installs all dependencies from the generated folder

EOF
    return 0
  fi

  # Execute the brew.manager.sh script
  bash "$script" "$@"
}


# zed-manager command to export or install Zed editor configurations
zed-manager() {
  local root="${DRAMA_TOOLS_ROOT:-$HOME/work/projects/private/drama-tools}"

  if [[ ! -d "$root" ]]; then
    echo "zed-manager Error: DRAMA_TOOLS_ROOT not found at '$root'" >&2
    return 1
  fi

  local script="$root/tools/zed/zed.manager.sh"

  if [[ ! -f "$script" ]]; then
    echo "zed-manager Error: Script not found at '$script'" >&2
    return 1
  fi

  # Show help if no arguments or -h/--help
  if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat <<'EOF'
╭──────────────────────────────────────────────╮
│ ⚡ zed-manager — Zed Editor Config Tool      │
╰──────────────────────────────────────────────╯

Usage:
  zed-manager [command]

Commands:
  export     Export Zed configurations from ~/.config/zed
  install    Install Zed configurations to ~/.config/zed
  -h, --help Show this help message

Examples:
  🚀 zed-manager export
      Exports settings.json and keymap.json to tools/zed

  📦 zed-manager install
      Installs configurations from tools/zed to ~/.config/zed

EOF
    return 0
  fi

  # Execute the zed.manager.sh script
  bash "$script" "$@"
}

# opencode-manager command to install RTK and Caveman for OpenCode
opencode-manager() {
  local root="${DRAMA_TOOLS_ROOT:-$HOME/work/projects/private/drama-tools}"
  if [[ ! -d "$root" ]]; then
    echo "opencode-manager Error: DRAMA_TOOLS_ROOT not found at '$root'" >&2
    return 1
  fi

  local cli="$root/tools/opencode/dist/index.js"

  # Show help if no arguments or -h/--help
  if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat <<'EOF'
╭──────────────────────────────────────────────╮
│ 🦖 opencode-manager — OpenCode Tool Installer  │
╰──────────────────────────────────────────────╯
Usage:
  opencode-manager [command]

Commands:
  install     Install RTK plugin and Caveman skill into OpenCode config
  export      Show current RTK/Caveman installation status
  -h, --help  Show this help message

Options:
  --dir <path>      Override the OpenCode config directory
  --rtk-only        Install only the RTK plugin
  --caveman-only    Install only the Caveman skill

Examples:
  🚀 opencode-manager install
       Installs RTK plugin (opencode.json) and Caveman skill (skills/caveman.md)
  📦 opencode-manager export
       Shows installation status of RTK and Caveman
  📂 opencode-manager install --dir /custom/path
       Installs into a custom OpenCode config directory
EOF
    return 0
  fi

  # Build if dist/index.js does not exist
  if [[ ! -f "$cli" ]]; then
    echo "opencode-manager: dist not found, building..." >&2
    (cd "$root/tools/opencode" && npm install --silent && npm run build --silent)
    if [[ $? -ne 0 ]]; then
      echo "opencode-manager Error: build failed." >&2
      return 1
    fi
  fi

  node "$cli" "$@"
}


# List all available custom commands
my-commands() {
    echo "    ╭─────────────────────────────╮"
    echo "    │ 🎛️  Custom Command Palette  │"
    echo "    ╰─────────────────────────────╯"
    echo "    🔧  oprc         Open your shell profile in style (try --help for tips)"
    echo "    🐾  app-hound    Audit apps via app-hound from $APP_HOUND_ROOT"
    echo "    🍺  brew-manager Export or install Homebrew dependencies"
    echo "    ⚡  zed-manager  Export or install Zed editor configurations"
  echo "  🦖 opencode-manager Install RTK + Caveman for OpenCode"

    # Show lazy* tools if installed
    if command -v lazygit >/dev/null 2>&1; then
        echo "    🐙  lazygit      Terminal UI for git commands"
    fi
    if command -v lazysql >/dev/null 2>&1; then
        echo "    🗃️  lazysql      Browse SQL databases with lazysql"
    fi
    if command -v lazydocker >/dev/null 2>&1; then
        echo "    🐳  lazydocker   Terminal UI for docker and docker-compose"
    fi

    echo "    📚  my-commands   You're here—your custom command cheat sheet!"
    echo ""
    echo "    💡 Pro tip: tack on --help to any command for the deluxe tour."
}
