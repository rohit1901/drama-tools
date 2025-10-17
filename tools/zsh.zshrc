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



# List all available custom commands
my-commands() {
  echo "Available custom commands:"
  echo "  oprc         - Open your shell config file (.zshrc or .bashrc)"
  echo "  aider-chat   - Run aider on an Ollama model (with optional file watching)"
  echo "  my-commands  - List available custom user commands"
  echo ""
  echo "Type '<command> --help' for usage information."
}
