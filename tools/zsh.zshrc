export PATH="$HOME/.volta/bin:$PATH"

# Python environment using pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Node.js environment using nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# JDBrowser - SQLLite explorer
export JD_BROWSER_ROOT="$HOME/work/utilities/JDbrowser/target/release"
export PATH="$JD_BROWSER_ROOT:$PATH"

# app-hound ROOT
export APP_HOUND_ROOT="$HOME/work/projects/private/app-hound"

# Ollama
export OLLAMA_API_BASE="http://127.0.0.1:11434"

# Open shell profile using `oprc` command
oprc() {
  local default_shell=$(basename "$SHELL")
  local default_ide="TextEdit"
  local selected_shell="$default_shell"
  local selected_ide="$default_ide"

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        echo "Usage: oprc <option>=<value>"
        echo "Options:"
        echo "  -s|--shell=<shell>        Specify the shell (zsh or bash). Defaults to current shell."
        echo "  -i|--interactive=<ide>    Specify the IDE (opens the IDE if found). Defaults to TextEdit."
        echo "Examples:"
        echo "  oprc                      # opens your current shell's profile in default IDE"
        echo "  oprc -s=bash              # opens .bashrc in default IDE"
        echo "  oprc -i=code              # opens current shell's profile in VS Code"
        echo "  oprc -s=zsh -i=code       # opens .zshrc in VS Code"
        echo "  oprc --help               # shows this message"
        return
        ;;
      -s=*|--shell=*)
        selected_shell=$(basename "${arg#*=}")
        ;;
      -i=*|--interactive=*)
        selected_ide="${arg#*=}"
        ;;
    esac
  done
  # Open selected shell's profile in selected IDE
  case "$selected_shell" in
    zsh)
      open -a "$selected_ide" "$HOME/.zshrc"
      ;;
    bash)
      open -a "$selected_ide" "$HOME/.bashrc"
      ;;
    *)
      echo "oprc Error: shell must be 'bash' or 'zsh'. Got: '$selected_shell'"
      return 1
      ;;
  esac
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
  echo "Available custom commands:"
  echo "  oprc         - Open your shell config file (.zshrc or .bashrc)"
  echo "  aider-chat   - Run aider on an Ollama model (with optional file watching)"
  echo "  app-hound    - Run app-hound to audit an application installed on your system"
  echo "  jdbrowser    - Run JDBrowser to explore SQLLite databases. INFO: Run the command from the directory where the database is located."
  echo "  my-commands  - List available custom user commands"
  echo ""
  echo "Type '<command> --help' for usage information."
}



#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
