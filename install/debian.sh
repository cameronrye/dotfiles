#!/usr/bin/env bash

# Debian/Ubuntu-specific installation script
# Installs packages and sets up Debian/Ubuntu-specific configurations

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

# Check if running on Debian/Ubuntu
check_debian() {
    if [[ ! -f /etc/debian_version ]]; then
        log_error "This script is for Debian/Ubuntu systems only"
        exit 1
    fi
}

# Update package lists
update_packages() {
    log_info "Updating package lists..."
    sudo apt update
    log_success "Package lists updated"
}

# Install essential packages
install_packages() {
    log_info "Installing essential packages..."
    
    local packages=(
        # Build tools
        "build-essential"
        "curl"
        "wget"
        "git"
        "unzip"
        "zip"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        
        # Shell and terminal tools
        "zsh"
        "tmux"
        
        # Modern CLI tools
        "ripgrep"
        "fd-find"
        "tree"
        "htop"
        "jq"
        
        # Development tools
        "python3"
        "python3-pip"
        "python3-venv"
        "nodejs"
        "npm"
        
        # Text editors
        "neovim"
        
        # Other utilities
        "xclip"           # Clipboard utility
        "fonts-firacode"  # Fira Code font
    )
    
    # Install packages
    sudo apt install -y "${packages[@]}"
    
    log_success "Essential packages installed"
}

# Install additional tools not available in default repos
install_additional_tools() {
    log_info "Installing additional tools..."
    
    # Install bat (batcat on Debian/Ubuntu)
    if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
        log_info "Installing bat..."
        sudo apt install -y bat
        
        # Create bat symlink if it's installed as batcat
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        fi
    fi
    
    # Install exa
    if ! command -v exa &> /dev/null; then
        log_info "Installing exa..."
        if command -v cargo &> /dev/null; then
            cargo install exa
        else
            # Download pre-built binary
            local exa_version="v0.10.1"
            local exa_url="https://github.com/ogham/exa/releases/download/${exa_version}/exa-linux-x86_64-${exa_version}.zip"
            
            cd /tmp
            wget "$exa_url" -O exa.zip
            unzip exa.zip
            sudo mv bin/exa /usr/local/bin/
            sudo mv man/exa.1 /usr/local/share/man/man1/ 2>/dev/null || true
            rm -rf bin man exa.zip
        fi
    fi
    
    # Install fzf
    if ! command -v fzf &> /dev/null; then
        log_info "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all --no-bash --no-fish
    fi
    
    log_success "Additional tools installed"
}

# Install GitHub CLI
install_github_cli() {
    if command -v gh &> /dev/null; then
        log_info "GitHub CLI already installed"
        return 0
    fi
    
    log_info "Installing GitHub CLI..."
    
    # Add GitHub CLI repository
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    # Update and install
    sudo apt update
    sudo apt install -y gh
    
    log_success "GitHub CLI installed"
}

# Install Node.js via NodeSource
install_nodejs() {
    local node_version="18"
    
    if node --version 2>/dev/null | grep -q "v${node_version}"; then
        log_info "Node.js ${node_version} already installed"
        return 0
    fi
    
    log_info "Installing Node.js ${node_version}..."
    
    # Add NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | sudo -E bash -
    
    # Install Node.js
    sudo apt install -y nodejs
    
    log_success "Node.js ${node_version} installed"
}

# Install .NET SDK
install_dotnet() {
    if command -v dotnet &> /dev/null; then
        log_info ".NET SDK already installed"
        return 0
    fi
    
    log_info "Installing .NET SDK..."
    
    # Add Microsoft repository
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Update and install
    sudo apt update
    sudo apt install -y dotnet-sdk-7.0
    
    log_success ".NET SDK installed"
}

# Install VS Code
install_vscode() {
    if command -v code &> /dev/null; then
        log_info "VS Code already installed"
        return 0
    fi
    
    log_info "Installing VS Code..."
    
    # Add Microsoft GPG key and repository
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    
    # Update and install
    sudo apt update
    sudo apt install -y code
    
    log_success "VS Code installed"
}

# Install Kitty terminal (if not in WSL)
install_kitty() {
    # Skip if in WSL
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]]; then
        log_info "Skipping Kitty installation in WSL"
        return 0
    fi
    
    if command -v kitty &> /dev/null; then
        log_info "Kitty already installed"
        return 0
    fi
    
    log_info "Installing Kitty terminal..."
    
    # Install via official installer
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    
    # Create desktop integration
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
    
    log_success "Kitty terminal installed"
}

# Setup development tools
setup_development_tools() {
    log_info "Setting up development tools..."
    
    # Install pyenv
    if [[ ! -d "$HOME/.pyenv" ]]; then
        log_info "Installing pyenv..."
        curl https://pyenv.run | bash
    fi
    
    # Install nvm
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    log_success "Development tools configured"
}

# Set zsh as default shell
set_default_shell() {
    if [[ "$SHELL" == */zsh ]]; then
        log_info "Zsh is already the default shell"
        return 0
    fi
    
    log_info "Setting zsh as default shell..."
    
    # Add zsh to /etc/shells if not present
    if ! grep -q "$(which zsh)" /etc/shells; then
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    
    # Change default shell
    chsh -s "$(which zsh)"
    
    log_success "Zsh set as default shell"
    log_info "Please log out and log back in for the change to take effect"
}

# Main function
main() {
    log_info "Starting Debian/Ubuntu-specific setup..."
    
    # Check if running on Debian/Ubuntu
    check_debian
    
    # Update packages
    update_packages
    
    # Install packages
    install_packages
    install_additional_tools
    
    # Install development tools
    install_github_cli
    install_nodejs
    install_dotnet
    install_vscode
    install_kitty
    
    # Setup development environment
    setup_development_tools
    
    # Set default shell
    set_default_shell
    
    log_success "Debian/Ubuntu-specific setup complete!"
}

# Run main function
main "$@"
