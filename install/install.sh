#!/usr/bin/env bash

# Modern Dotfiles Installation Script
# Supports macOS, Linux (Debian/Ubuntu), and Windows (via WSL)

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "\n${PURPLE}=== $1 ===${NC}\n"
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            if [[ -f /etc/debian_version ]]; then
                echo "debian"
            elif [[ -f /etc/redhat-release ]]; then
                echo "redhat"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if running in WSL
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]] || [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

# Display banner
show_banner() {
    cat << 'EOF'
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                    
Modern Cross-Platform Dotfiles Management System
EOF
    echo -e "${CYAN}Version: 1.0.0${NC}\n"
}

# Check prerequisites
check_prerequisites() {
    log_header "Checking Prerequisites"
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed. Please install curl first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Backup existing configurations
backup_existing_configs() {
    log_header "Backing Up Existing Configurations"
    
    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # List of common config files to backup
    local configs=(
        ".zshrc"
        ".bashrc"
        ".gitconfig"
        ".tmux.conf"
        ".vimrc"
        ".config/starship.toml"
        ".config/kitty"
        ".config/Code/User/settings.json"
    )
    
    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            log_info "Backing up $config"
            cp -r "$HOME/$config" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    if [[ -n "$(ls -A "$backup_dir" 2>/dev/null)" ]]; then
        log_success "Backup created at: $backup_dir"
        echo "$backup_dir" > "$DOTFILES_DIR/.last_backup"
    else
        rmdir "$backup_dir"
        log_info "No existing configurations found to backup"
    fi
}

# Main installation function
main() {
    show_banner
    
    # Detect OS
    local os
    os=$(detect_os)
    
    if is_wsl; then
        log_info "Detected Windows Subsystem for Linux (WSL)"
        os="wsl"
    fi
    
    log_info "Detected OS: $os"
    
    # Check prerequisites
    check_prerequisites
    
    # Backup existing configurations
    backup_existing_configs
    
    # Run platform-specific installation
    case "$os" in
        macos)
            log_header "Running macOS Installation"
            bash "$SCRIPT_DIR/macos.sh"
            ;;
        debian|wsl)
            log_header "Running Debian/Ubuntu Installation"
            bash "$SCRIPT_DIR/debian.sh"
            ;;
        windows)
            log_header "Running Windows Installation"
            log_warning "Please run install/windows.ps1 in PowerShell instead"
            exit 1
            ;;
        *)
            log_error "Unsupported operating system: $os"
            log_info "Supported systems: macOS, Debian/Ubuntu, Windows (via WSL or PowerShell)"
            exit 1
            ;;
    esac
    
    # Run common setup
    log_header "Running Common Setup"
    bash "$SCRIPT_DIR/common.sh"
    
    # Final message
    log_header "Installation Complete!"
    log_success "Dotfiles have been successfully installed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
    log_info "For customization options, see: docs/CUSTOMIZATION.md"
    
    if [[ -f "$DOTFILES_DIR/.last_backup" ]]; then
        local backup_path
        backup_path=$(cat "$DOTFILES_DIR/.last_backup")
        log_info "Your previous configurations are backed up at: $backup_path"
    fi
}

# Run main function
main "$@"
