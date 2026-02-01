# app-hound ROOT
export APP_HOUND_ROOT="$HOME/work/projects/private/app-hound"

# Ollama
export OLLAMA_API_BASE="http://127.0.0.1:11434"

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



# aider CLI command to launch ollama models
aider-chat() {

  local model="llama3.2:3b"
  local watch_flag=""

  # Parse arguments (model name and watch flag)
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        echo "Usage: aider-chat [model] <options>"
        echo "  model: ollama model name (e.g., llama3.2:3b, mistral:7b)"
        echo "  If omitted, defaults to llama3.2:3b"
        echo "  options:"
        echo "    -w | --watch-files: watch for files in the current directory"
        echo "Examples:"
        echo "  aider-chat             # uses llama3.2:3b"
        echo "  aider-chat gemma3      # uses gemma3 if installed"
        echo "  aider-chat -w          # uses llama3.2:3b, with watch files"
        echo "  aider-chat gemma3 -w   # uses gemma3, with watch files"‚
        return
        ;;
      -w|--watch-files)
        watch_flag="--watch-files"
        ;;
      -*)
        # ignore other options
        ;;
      *)
        # If model not yet set by user, set it now
        if [[ "$model" == "llama3.2:3b" ]]; then
          model="$arg"
        fi
        ;;
    esac
  done
  # Throw error if Ollama is not running
  if ! curl -s http://localhost:11434 > /dev/null; then
    echo "aider-chat Error: Ollama server is not running."
    echo "Start it with: ollama serve"
    return 1
  fi

  # Validate if model exists locally
  if ollama list | awk '{print $1}' | grep -Fxq "$model"; then
    if [[ -n "$watch_flag" ]]; then
      aider --model "ollama_chat/$model" $watch_flag
    else
      aider --model "ollama_chat/$model"
    fi
  else
    echo "aider-chat Error: Model '$model' does not exist locally."
    echo "Use 'ollama list' to view available models."
    return 2
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



# List all available custom commands
my-commands() {
    cat <<'EOF'
    ╭─────────────────────────────╮
    │ 🎛️  Custom Command Palette   │
    ╰─────────────────────────────╯
    🔧  oprc         Open your shell profile in style (try --help for tips)
    🤖  aider-chat   Chat with Ollama-backed aider (supports --watch-files)
    🐾  app-hound    Audit apps via app-hound from $APP_HOUND_ROOT
    🗃️  jdbrowser    Browse SQLite databases (run where the DB lives)
    📚  my-commands   You’re here—your custom command cheat sheet!

    💡 Pro tip: tack on --help to any command for the deluxe tour.
EOF
}
