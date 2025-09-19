#!/usr/bin/env bash

# macOS-specific installation script
# Installs Homebrew, packages, and macOS-specific configurations

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is for macOS only"
        exit 1
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log_info "Checking for Xcode Command Line Tools..."
    
    if ! xcode-select -p &> /dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        
        log_success "Xcode Command Line Tools installed"
    else
        log_info "Xcode Command Line Tools already installed"
    fi
}

# Install Homebrew
install_homebrew() {
    log_info "Checking for Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed"
    else
        log_info "Homebrew already installed"
    fi
    
    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update
}

# Install Homebrew packages
install_packages() {
    log_info "Installing Homebrew packages..."
    
    # Essential tools
    local packages=(
        # Shell and terminal tools
        "zsh"
        "starship"
        "tmux"
        
        # Modern CLI tools
        "fzf"
        "ripgrep"
        "bat"
        "exa"
        "fd"
        "tree"
        "htop"
        "jq"
        "yq"
        
        # Development tools
        "git"
        "gh"              # GitHub CLI
        "node"
        "python@3.11"
        "pyenv"
        
        # Editors and IDEs
        "neovim"
        
        # Other useful tools
        "wget"
        "curl"
        "unzip"
        "zip"
        "mas"             # Mac App Store CLI
    )
    
    for package in "${packages[@]}"; do
        if brew list "$package" &> /dev/null; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done
    
    log_success "Homebrew packages installed"
}

# Install Homebrew casks (GUI applications)
install_casks() {
    log_info "Installing Homebrew casks..."
    
    local casks=(
        # Terminals
        "kitty"
        
        # Development
        "visual-studio-code"
        "jetbrains-toolbox"
        
        # Browsers
        "google-chrome"
        "firefox"
        
        # Utilities
        "rectangle"        # Window management
        "the-unarchiver"   # Archive utility
        "appcleaner"       # App uninstaller
        
        # Optional (comment out if not needed)
        # "docker"
        # "postman"
        # "slack"
        # "discord"
    )
    
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &> /dev/null; then
            log_info "$cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
    
    log_success "Homebrew casks installed"
}

# Setup macOS-specific configurations
setup_macos_defaults() {
    log_info "Setting up macOS defaults..."
    
    # Dock settings
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock tilesize -int 48
    
    # Finder settings
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # Search current folder
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Screenshots
    defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
    defaults write com.apple.screencapture type -string "png"
    
    # Trackpad
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    
    # Keyboard
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Menu bar
    defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
    
    log_success "macOS defaults configured"
    log_info "Some changes require a restart to take effect"
}

# Install fonts
install_fonts() {
    log_info "Installing fonts..."
    
    # Install Nerd Fonts via Homebrew
    local fonts=(
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-hack-nerd-font"
        "font-source-code-pro"
    )
    
    # Tap the font cask repository
    brew tap homebrew/cask-fonts
    
    for font in "${fonts[@]}"; do
        if brew list --cask "$font" &> /dev/null; then
            log_info "$font already installed"
        else
            log_info "Installing $font..."
            brew install --cask "$font"
        fi
    done
    
    log_success "Fonts installed"
}

# Setup development tools
setup_development_tools() {
    log_info "Setting up development tools..."
    
    # Setup fzf key bindings
    if command -v fzf &> /dev/null; then
        "$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish
    fi
    
    # Install .NET SDK if not present
    if ! command -v dotnet &> /dev/null; then
        log_info "Installing .NET SDK..."
        brew install --cask dotnet-sdk
    fi
    
    log_success "Development tools configured"
}

# Main function
main() {
    log_info "Starting macOS-specific setup..."
    
    # Check if running on macOS
    check_macos
    
    # Install Xcode Command Line Tools
    install_xcode_tools
    
    # Install Homebrew
    install_homebrew
    
    # Install packages and casks
    install_packages
    install_casks
    
    # Install fonts
    install_fonts
    
    # Setup development tools
    setup_development_tools
    
    # Setup macOS defaults
    setup_macos_defaults
    
    log_success "macOS-specific setup complete!"
}

# Run main function
main "$@"
