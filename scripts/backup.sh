#!/usr/bin/env bash

# Backup Script for Dotfiles
# Creates a backup of existing configurations before installing dotfiles

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Backup directory
readonly BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create backup directory
create_backup_dir() {
    log_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Backup a file or directory
backup_item() {
    local source="$1"
    local name="$2"
    
    if [[ -e "$source" ]]; then
        log_info "Backing up $name"
        cp -r "$source" "$BACKUP_DIR/"
        return 0
    else
        log_warning "$name not found, skipping"
        return 1
    fi
}

# Backup shell configurations
backup_shell() {
    log_info "Backing up shell configurations..."
    
    backup_item "$HOME/.zshrc" "zsh configuration"
    backup_item "$HOME/.zshenv" "zsh environment"
    backup_item "$HOME/.bashrc" "bash configuration"
    backup_item "$HOME/.bash_profile" "bash profile"
    backup_item "$HOME/.profile" "shell profile"
    backup_item "$HOME/.oh-my-zsh" "oh-my-zsh"
    backup_item "$HOME/.config/starship.toml" "starship configuration"
}

# Backup Git configurations
backup_git() {
    log_info "Backing up Git configurations..."
    
    backup_item "$HOME/.gitconfig" "Git configuration"
    backup_item "$HOME/.gitignore_global" "Global gitignore"
    backup_item "$HOME/.gitattributes_global" "Global gitattributes"
    backup_item "$HOME/.gitconfig_local" "Local Git configuration"
    backup_item "$HOME/.gitconfig_work" "Work Git configuration"
}

# Backup terminal configurations
backup_terminals() {
    log_info "Backing up terminal configurations..."
    
    # Kitty
    backup_item "$HOME/.config/kitty" "Kitty configuration"
    
    # Windows Terminal (if on Windows/WSL)
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]]; then
        local wt_config="/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
        backup_item "$wt_config" "Windows Terminal configuration"
    fi
}

# Backup tmux configuration
backup_tmux() {
    log_info "Backing up tmux configuration..."
    
    backup_item "$HOME/.tmux.conf" "tmux configuration"
    backup_item "$HOME/.tmux" "tmux directory"
}

# Backup editor configurations
backup_editors() {
    log_info "Backing up editor configurations..."
    
    # VS Code
    case "$(uname -s)" in
        Darwin*)
            backup_item "$HOME/Library/Application Support/Code/User" "VS Code configuration"
            ;;
        Linux*)
            backup_item "$HOME/.config/Code/User" "VS Code configuration"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            backup_item "$APPDATA/Code/User" "VS Code configuration"
            ;;
    esac
    
    # Vim/Neovim
    backup_item "$HOME/.vimrc" "Vim configuration"
    backup_item "$HOME/.vim" "Vim directory"
    backup_item "$HOME/.config/nvim" "Neovim configuration"
}

# Backup development environment configurations
backup_development() {
    log_info "Backing up development environment configurations..."
    
    # Node.js
    backup_item "$HOME/.npmrc" "npm configuration"
    backup_item "$HOME/.nvm" "nvm directory"
    backup_item "$HOME/.node_repl_history" "Node.js REPL history"
    
    # Python
    backup_item "$HOME/.pyenv" "pyenv directory"
    backup_item "$HOME/.python_history" "Python history"
    backup_item "$HOME/.pip" "pip configuration"
    
    # .NET
    backup_item "$HOME/.nuget" "NuGet configuration"
    backup_item "$HOME/.dotnet" "dotnet configuration"
    
    # Other tools
    backup_item "$HOME/.cargo" "Rust Cargo"
    backup_item "$HOME/.rustup" "Rust toolchain"
    backup_item "$HOME/.go" "Go workspace"
}

# Backup SSH and GPG
backup_security() {
    log_info "Backing up security configurations..."
    
    # SSH (be careful with private keys)
    if [[ -d "$HOME/.ssh" ]]; then
        log_warning "SSH directory found. Backing up public keys and config only."
        mkdir -p "$BACKUP_DIR/.ssh"
        
        # Copy config and known_hosts
        [[ -f "$HOME/.ssh/config" ]] && cp "$HOME/.ssh/config" "$BACKUP_DIR/.ssh/"
        [[ -f "$HOME/.ssh/known_hosts" ]] && cp "$HOME/.ssh/known_hosts" "$BACKUP_DIR/.ssh/"
        
        # Copy public keys only
        find "$HOME/.ssh" -name "*.pub" -exec cp {} "$BACKUP_DIR/.ssh/" \;
    fi
    
    # GPG
    backup_item "$HOME/.gnupg/gpg.conf" "GPG configuration"
}

# Backup application-specific configurations
backup_applications() {
    log_info "Backing up application configurations..."
    
    # Homebrew (macOS)
    if command -v brew &> /dev/null; then
        log_info "Creating Homebrew bundle..."
        brew bundle dump --file="$BACKUP_DIR/Brewfile" --force
    fi
    
    # Package lists
    if command -v npm &> /dev/null; then
        log_info "Creating npm global package list..."
        npm list -g --depth=0 --json > "$BACKUP_DIR/npm-global.json"
    fi
    
    if command -v pip3 &> /dev/null; then
        log_info "Creating pip package list..."
        pip3 freeze > "$BACKUP_DIR/requirements.txt"
    fi
    
    if command -v code &> /dev/null; then
        log_info "Creating VS Code extension list..."
        code --list-extensions > "$BACKUP_DIR/vscode-extensions.txt"
    fi
}

# Create backup manifest
create_manifest() {
    log_info "Creating backup manifest..."
    
    cat > "$BACKUP_DIR/MANIFEST.md" << EOF
# Dotfiles Backup Manifest

**Created:** $(date)
**Hostname:** $(hostname)
**User:** $(whoami)
**OS:** $(uname -s)
**Backup Directory:** $BACKUP_DIR

## Backed Up Items

$(find "$BACKUP_DIR" -type f -not -name "MANIFEST.md" | sort | sed 's|^'"$BACKUP_DIR"'/|- |')

## Restore Instructions

To restore from this backup:

1. Run the restore script:
   \`\`\`bash
   ~/.dotfiles/scripts/restore.sh "$BACKUP_DIR"
   \`\`\`

2. Or manually copy files back to their original locations.

## Notes

- SSH private keys are NOT backed up for security reasons
- Only SSH public keys and configuration files are included
- Review each file before restoring to avoid conflicts

EOF
}

# Main backup function
main() {
    log_info "Starting dotfiles backup..."
    
    # Create backup directory
    create_backup_dir
    
    # Perform backups
    backup_shell
    backup_git
    backup_terminals
    backup_tmux
    backup_editors
    backup_development
    backup_security
    backup_applications
    
    # Create manifest
    create_manifest
    
    # Save backup location
    echo "$BACKUP_DIR" > "$DOTFILES_DIR/.last_backup"
    
    # Summary
    local file_count
    file_count=$(find "$BACKUP_DIR" -type f | wc -l)
    
    log_success "Backup completed successfully!"
    log_info "Backup location: $BACKUP_DIR"
    log_info "Files backed up: $file_count"
    log_info "Manifest created: $BACKUP_DIR/MANIFEST.md"
    
    # Offer to open backup directory
    if command -v open &> /dev/null; then
        read -p "Open backup directory? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$BACKUP_DIR"
        fi
    fi
}

# Run main function
main "$@"
