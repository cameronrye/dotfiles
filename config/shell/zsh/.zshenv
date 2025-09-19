# Zsh Environment Configuration
# This file is sourced on all invocations of the shell

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"

# Default programs
export EDITOR="code"
export VISUAL="code"
export BROWSER="open"
export TERMINAL="kitty"

# Language and locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# History configuration
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Ensure history directory exists
mkdir -p "$(dirname "$HISTFILE")"

# Less configuration
export LESS="-R"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Ensure less directory exists
mkdir -p "$(dirname "$LESSHISTFILE")"

# Man pages
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# GPG
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# Node.js
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Go
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE="$XDG_CACHE_HOME/go-build"

# .NET
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"

# Platform-specific environment variables
case "$OSTYPE" in
    darwin*)
        # macOS specific
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_NO_INSECURE_REDIRECT=1
        export HOMEBREW_CASK_OPTS="--require-sha"
        ;;
    linux*)
        # Linux specific
        export BROWSER="xdg-open"
        ;;
esac

# Load local environment configuration if it exists
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
