#!/usr/bin/env bash

# Update Script for Dotfiles
# Updates the dotfiles repository and installed tools

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

# Update dotfiles repository
update_dotfiles() {
    log_info "Updating dotfiles repository..."
    
    cd "$DOTFILES_DIR"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warning "Not in a git repository, skipping git update"
        return 0
    fi
    
    # Stash any local changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "Local changes detected, stashing..."
        git stash push -m "Auto-stash before update $(date)"
    fi
    
    # Pull latest changes
    git pull origin main || git pull origin master
    
    log_success "Dotfiles repository updated"
}

# Update Homebrew and packages (macOS)
update_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "Homebrew not found, skipping"
        return 0
    fi
    
    log_info "Updating Homebrew..."
    
    # Update Homebrew itself
    brew update
    
    # Upgrade packages
    brew upgrade
    
    # Upgrade casks
    brew upgrade --cask
    
    # Clean up
    brew cleanup
    
    # Check for issues
    brew doctor || log_warning "Homebrew doctor found issues"
    
    log_success "Homebrew updated"
}

# Update Node.js packages
update_node() {
    if ! command -v npm &> /dev/null; then
        log_info "npm not found, skipping Node.js updates"
        return 0
    fi
    
    log_info "Updating Node.js packages..."
    
    # Update npm itself
    npm install -g npm@latest
    
    # Update global packages
    npm update -g
    
    # Check for outdated packages
    log_info "Checking for outdated global packages..."
    npm outdated -g || true
    
    log_success "Node.js packages updated"
}

# Update Python packages
update_python() {
    if ! command -v pip3 &> /dev/null; then
        log_info "pip3 not found, skipping Python updates"
        return 0
    fi
    
    log_info "Updating Python packages..."
    
    # Update pip itself
    pip3 install --upgrade pip
    
    # Update global packages
    if [[ -f "$HOME/.pip/requirements.txt" ]]; then
        pip3 install --upgrade -r "$HOME/.pip/requirements.txt"
    fi
    
    # Update pyenv if available
    if command -v pyenv &> /dev/null; then
        log_info "Updating pyenv..."
        if [[ -d "$HOME/.pyenv/.git" ]]; then
            cd "$HOME/.pyenv"
            git pull
        fi
    fi
    
    log_success "Python packages updated"
}

# Update Rust toolchain
update_rust() {
    if ! command -v rustup &> /dev/null; then
        log_info "Rust not found, skipping"
        return 0
    fi
    
    log_info "Updating Rust toolchain..."
    
    # Update rustup and toolchains
    rustup update
    
    # Update cargo packages
    if command -v cargo-install-update &> /dev/null; then
        cargo install-update -a
    else
        log_info "cargo-install-update not found, install with: cargo install cargo-update"
    fi
    
    log_success "Rust toolchain updated"
}

# Update VS Code extensions
update_vscode() {
    if ! command -v code &> /dev/null; then
        log_info "VS Code not found, skipping"
        return 0
    fi
    
    log_info "Updating VS Code extensions..."
    
    # Update all extensions
    code --update-extensions
    
    log_success "VS Code extensions updated"
}

# Update tmux plugins
update_tmux() {
    if ! command -v tmux &> /dev/null; then
        log_info "tmux not found, skipping"
        return 0
    fi
    
    log_info "Updating tmux plugins..."
    
    # Update TPM if available
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        cd "$HOME/.tmux/plugins/tpm"
        git pull
        
        # Update plugins
        "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
    else
        log_warning "TPM not found, skipping tmux plugin updates"
    fi
    
    log_success "tmux plugins updated"
}

# Update oh-my-zsh
update_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "oh-my-zsh not found, skipping"
        return 0
    fi
    
    log_info "Updating oh-my-zsh..."
    
    # Update oh-my-zsh
    cd "$HOME/.oh-my-zsh"
    git pull origin master
    
    # Update custom plugins
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ -d "$custom_dir/plugins" ]]; then
        for plugin_dir in "$custom_dir/plugins"/*; do
            if [[ -d "$plugin_dir/.git" ]]; then
                log_info "Updating plugin: $(basename "$plugin_dir")"
                cd "$plugin_dir"
                git pull
            fi
        done
    fi
    
    log_success "oh-my-zsh updated"
}

# Update system packages (Linux)
update_system() {
    case "$(uname -s)" in
        Linux*)
            if command -v apt &> /dev/null; then
                log_info "Updating system packages (apt)..."
                sudo apt update && sudo apt upgrade -y
                sudo apt autoremove -y
                sudo apt autoclean
            elif command -v yum &> /dev/null; then
                log_info "Updating system packages (yum)..."
                sudo yum update -y
            elif command -v dnf &> /dev/null; then
                log_info "Updating system packages (dnf)..."
                sudo dnf update -y
            elif command -v pacman &> /dev/null; then
                log_info "Updating system packages (pacman)..."
                sudo pacman -Syu --noconfirm
            else
                log_info "No supported package manager found, skipping system updates"
            fi
            ;;
        Darwin*)
            log_info "System updates handled by Homebrew on macOS"
            ;;
        *)
            log_info "Unsupported system, skipping system updates"
            ;;
    esac
}

# Clean up old files and caches
cleanup() {
    log_info "Cleaning up..."
    
    # Clean npm cache
    if command -v npm &> /dev/null; then
        npm cache clean --force
    fi
    
    # Clean pip cache
    if command -v pip3 &> /dev/null; then
        pip3 cache purge
    fi
    
    # Clean cargo cache
    if command -v cargo &> /dev/null && command -v cargo-cache &> /dev/null; then
        cargo cache --autoclean
    fi
    
    # Clean old dotfiles backups (keep last 5)
    local backup_count
    backup_count=$(find "$HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d | wc -l)
    if [[ $backup_count -gt 5 ]]; then
        log_info "Cleaning old dotfiles backups (keeping last 5)..."
        find "$HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d | sort | head -n $((backup_count - 5)) | xargs rm -rf
    fi
    
    log_success "Cleanup completed"
}

# Show update summary
show_summary() {
    log_info "Update Summary:"
    echo
    
    # Git status
    cd "$DOTFILES_DIR"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Dotfiles repository:"
        git log --oneline -5
        echo
    fi
    
    # Tool versions
    echo "Tool versions:"
    command -v git &> /dev/null && echo "  Git: $(git --version)"
    command -v node &> /dev/null && echo "  Node.js: $(node --version)"
    command -v npm &> /dev/null && echo "  npm: $(npm --version)"
    command -v python3 &> /dev/null && echo "  Python: $(python3 --version)"
    command -v pip3 &> /dev/null && echo "  pip: $(pip3 --version)"
    command -v rustc &> /dev/null && echo "  Rust: $(rustc --version)"
    command -v code &> /dev/null && echo "  VS Code: $(code --version | head -1)"
    command -v tmux &> /dev/null && echo "  tmux: $(tmux -V)"
    command -v zsh &> /dev/null && echo "  Zsh: $(zsh --version)"
    echo
}

# Main update function
main() {
    log_info "Starting dotfiles update..."
    
    # Update dotfiles repository
    update_dotfiles
    
    # Update system packages
    update_system
    
    # Update package managers and tools
    update_homebrew
    update_node
    update_python
    update_rust
    
    # Update applications
    update_vscode
    update_tmux
    update_zsh
    
    # Cleanup
    cleanup
    
    # Show summary
    show_summary
    
    log_success "Update completed successfully!"
    log_info "You may need to restart your terminal to apply all changes"
}

# Run main function
main "$@"
