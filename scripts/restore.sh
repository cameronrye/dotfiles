#!/usr/bin/env bash

# Restore Script for Dotfiles
# Restores configurations from a backup directory

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

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [BACKUP_DIRECTORY]

Restore dotfiles from a backup directory.

Arguments:
  BACKUP_DIRECTORY    Path to the backup directory (optional)
                     If not provided, will use the last backup

Examples:
  $0                                    # Restore from last backup
  $0 ~/.dotfiles_backup_20231201_143022 # Restore from specific backup

EOF
}

# Find backup directory
find_backup_dir() {
    local backup_dir="$1"
    
    if [[ -n "$backup_dir" ]]; then
        if [[ ! -d "$backup_dir" ]]; then
            log_error "Backup directory not found: $backup_dir"
            exit 1
        fi
        echo "$backup_dir"
    else
        # Use last backup
        local last_backup_file="$DOTFILES_DIR/.last_backup"
        if [[ -f "$last_backup_file" ]]; then
            local last_backup
            last_backup=$(cat "$last_backup_file")
            if [[ -d "$last_backup" ]]; then
                echo "$last_backup"
            else
                log_error "Last backup directory not found: $last_backup"
                exit 1
            fi
        else
            log_error "No backup directory specified and no last backup found"
            log_info "Available backups:"
            find "$HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d 2>/dev/null || echo "  None found"
            exit 1
        fi
    fi
}

# Confirm restore operation
confirm_restore() {
    local backup_dir="$1"
    
    log_warning "This will restore configurations from: $backup_dir"
    log_warning "Existing configurations may be overwritten!"
    
    if [[ -f "$backup_dir/MANIFEST.md" ]]; then
        log_info "Backup manifest found. Contents:"
        echo
        cat "$backup_dir/MANIFEST.md"
        echo
    fi
    
    read -p "Continue with restore? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled"
        exit 0
    fi
}

# Restore a file or directory
restore_item() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [[ -e "$source" ]]; then
        log_info "Restoring $name"
        
        # Create target directory if needed
        local target_dir
        target_dir=$(dirname "$target")
        mkdir -p "$target_dir"
        
        # Backup existing file if it exists
        if [[ -e "$target" ]]; then
            local backup_suffix=".restore_backup_$(date +%Y%m%d_%H%M%S)"
            log_warning "Backing up existing $name to ${target}${backup_suffix}"
            mv "$target" "${target}${backup_suffix}"
        fi
        
        # Restore the file
        cp -r "$source" "$target"
        log_success "Restored $name"
        return 0
    else
        log_warning "$name not found in backup, skipping"
        return 1
    fi
}

# Restore shell configurations
restore_shell() {
    local backup_dir="$1"
    log_info "Restoring shell configurations..."
    
    restore_item "$backup_dir/.zshrc" "$HOME/.zshrc" "zsh configuration"
    restore_item "$backup_dir/.zshenv" "$HOME/.zshenv" "zsh environment"
    restore_item "$backup_dir/.bashrc" "$HOME/.bashrc" "bash configuration"
    restore_item "$backup_dir/.bash_profile" "$HOME/.bash_profile" "bash profile"
    restore_item "$backup_dir/.profile" "$HOME/.profile" "shell profile"
    restore_item "$backup_dir/.oh-my-zsh" "$HOME/.oh-my-zsh" "oh-my-zsh"
    restore_item "$backup_dir/starship.toml" "$HOME/.config/starship.toml" "starship configuration"
}

# Restore Git configurations
restore_git() {
    local backup_dir="$1"
    log_info "Restoring Git configurations..."
    
    restore_item "$backup_dir/.gitconfig" "$HOME/.gitconfig" "Git configuration"
    restore_item "$backup_dir/.gitignore_global" "$HOME/.gitignore_global" "Global gitignore"
    restore_item "$backup_dir/.gitattributes_global" "$HOME/.gitattributes_global" "Global gitattributes"
    restore_item "$backup_dir/.gitconfig_local" "$HOME/.gitconfig_local" "Local Git configuration"
    restore_item "$backup_dir/.gitconfig_work" "$HOME/.gitconfig_work" "Work Git configuration"
}

# Restore terminal configurations
restore_terminals() {
    local backup_dir="$1"
    log_info "Restoring terminal configurations..."
    
    # Kitty
    restore_item "$backup_dir/kitty" "$HOME/.config/kitty" "Kitty configuration"
    
    # Windows Terminal (if on Windows/WSL)
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]]; then
        local wt_config="/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
        restore_item "$backup_dir/settings.json" "$wt_config" "Windows Terminal configuration"
    fi
}

# Restore tmux configuration
restore_tmux() {
    local backup_dir="$1"
    log_info "Restoring tmux configuration..."
    
    restore_item "$backup_dir/.tmux.conf" "$HOME/.tmux.conf" "tmux configuration"
    restore_item "$backup_dir/.tmux" "$HOME/.tmux" "tmux directory"
}

# Restore editor configurations
restore_editors() {
    local backup_dir="$1"
    log_info "Restoring editor configurations..."
    
    # VS Code
    case "$(uname -s)" in
        Darwin*)
            restore_item "$backup_dir/User" "$HOME/Library/Application Support/Code/User" "VS Code configuration"
            ;;
        Linux*)
            restore_item "$backup_dir/User" "$HOME/.config/Code/User" "VS Code configuration"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            restore_item "$backup_dir/User" "$APPDATA/Code/User" "VS Code configuration"
            ;;
    esac
    
    # Vim/Neovim
    restore_item "$backup_dir/.vimrc" "$HOME/.vimrc" "Vim configuration"
    restore_item "$backup_dir/.vim" "$HOME/.vim" "Vim directory"
    restore_item "$backup_dir/nvim" "$HOME/.config/nvim" "Neovim configuration"
}

# Restore development environment configurations
restore_development() {
    local backup_dir="$1"
    log_info "Restoring development environment configurations..."
    
    # Node.js
    restore_item "$backup_dir/.npmrc" "$HOME/.npmrc" "npm configuration"
    restore_item "$backup_dir/.nvm" "$HOME/.nvm" "nvm directory"
    restore_item "$backup_dir/.node_repl_history" "$HOME/.node_repl_history" "Node.js REPL history"
    
    # Python
    restore_item "$backup_dir/.pyenv" "$HOME/.pyenv" "pyenv directory"
    restore_item "$backup_dir/.python_history" "$HOME/.python_history" "Python history"
    restore_item "$backup_dir/.pip" "$HOME/.pip" "pip configuration"
    
    # .NET
    restore_item "$backup_dir/.nuget" "$HOME/.nuget" "NuGet configuration"
    restore_item "$backup_dir/.dotnet" "$HOME/.dotnet" "dotnet configuration"
    
    # Other tools
    restore_item "$backup_dir/.cargo" "$HOME/.cargo" "Rust Cargo"
    restore_item "$backup_dir/.rustup" "$HOME/.rustup" "Rust toolchain"
    restore_item "$backup_dir/.go" "$HOME/.go" "Go workspace"
}

# Restore SSH and GPG
restore_security() {
    local backup_dir="$1"
    log_info "Restoring security configurations..."
    
    # SSH
    if [[ -d "$backup_dir/.ssh" ]]; then
        log_info "Restoring SSH configuration..."
        mkdir -p "$HOME/.ssh"
        
        # Restore config and known_hosts
        restore_item "$backup_dir/.ssh/config" "$HOME/.ssh/config" "SSH config"
        restore_item "$backup_dir/.ssh/known_hosts" "$HOME/.ssh/known_hosts" "SSH known_hosts"
        
        # Restore public keys
        find "$backup_dir/.ssh" -name "*.pub" -exec cp {} "$HOME/.ssh/" \;
        
        # Set proper permissions
        chmod 700 "$HOME/.ssh"
        chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
        chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
        chmod 644 "$HOME/.ssh/known_hosts" 2>/dev/null || true
        
        log_success "SSH configuration restored"
        log_warning "Remember to restore your private keys manually if needed"
    fi
    
    # GPG
    restore_item "$backup_dir/gpg.conf" "$HOME/.gnupg/gpg.conf" "GPG configuration"
}

# Restore applications and packages
restore_applications() {
    local backup_dir="$1"
    log_info "Restoring application configurations..."
    
    # Homebrew (macOS)
    if [[ -f "$backup_dir/Brewfile" ]] && command -v brew &> /dev/null; then
        log_info "Restoring Homebrew packages..."
        read -p "Install packages from Brewfile? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew bundle install --file="$backup_dir/Brewfile"
        fi
    fi
    
    # npm packages
    if [[ -f "$backup_dir/npm-global.json" ]] && command -v npm &> /dev/null; then
        log_info "npm global packages list found"
        log_warning "Manual restoration required for npm packages"
        log_info "Run: npm install -g \$(cat $backup_dir/npm-global.json | jq -r '.dependencies | keys[]')"
    fi
    
    # pip packages
    if [[ -f "$backup_dir/requirements.txt" ]] && command -v pip3 &> /dev/null; then
        log_info "Restoring pip packages..."
        read -p "Install packages from requirements.txt? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pip3 install -r "$backup_dir/requirements.txt"
        fi
    fi
    
    # VS Code extensions
    if [[ -f "$backup_dir/vscode-extensions.txt" ]] && command -v code &> /dev/null; then
        log_info "Restoring VS Code extensions..."
        read -p "Install VS Code extensions? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cat "$backup_dir/vscode-extensions.txt" | xargs -L 1 code --install-extension
        fi
    fi
}

# Main restore function
main() {
    local backup_dir="${1:-}"
    
    # Show usage if help requested
    if [[ "$backup_dir" == "-h" ]] || [[ "$backup_dir" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Find backup directory
    backup_dir=$(find_backup_dir "$backup_dir")
    
    log_info "Starting dotfiles restore..."
    log_info "Backup directory: $backup_dir"
    
    # Confirm restore
    confirm_restore "$backup_dir"
    
    # Perform restore
    restore_shell "$backup_dir"
    restore_git "$backup_dir"
    restore_terminals "$backup_dir"
    restore_tmux "$backup_dir"
    restore_editors "$backup_dir"
    restore_development "$backup_dir"
    restore_security "$backup_dir"
    restore_applications "$backup_dir"
    
    log_success "Restore completed successfully!"
    log_info "You may need to restart your terminal or reload configurations"
    log_warning "Review restored configurations before using them"
}

# Run main function
main "$@"
