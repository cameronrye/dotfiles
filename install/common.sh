#!/usr/bin/env bash

# Common installation functions and setup
# Used by all platform-specific installers

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
readonly CONFIG_DIR="$DOTFILES_DIR/config"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local backup_suffix=".dotfiles_backup"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # If target exists and is not a symlink, back it up
    if [[ -e "$target" && ! -L "$target" ]]; then
        log_warning "Backing up existing $target to ${target}${backup_suffix}"
        mv "$target" "${target}${backup_suffix}"
    fi
    
    # Remove existing symlink
    [[ -L "$target" ]] && rm "$target"
    
    # Create new symlink
    ln -sf "$source" "$target"
    log_success "Created symlink: $target -> $source"
}

# Install Starship prompt
install_starship() {
    log_info "Installing Starship prompt..."
    
    if command -v starship &> /dev/null; then
        log_info "Starship already installed, skipping..."
        return 0
    fi
    
    # Install Starship
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    
    # Create config symlink
    create_symlink "$CONFIG_DIR/shell/starship/starship.toml" "$HOME/.config/starship.toml"
    
    log_success "Starship installed and configured"
}

# Setup shell configuration
setup_shell() {
    log_info "Setting up shell configuration..."
    
    # Setup zsh
    if command -v zsh &> /dev/null; then
        # Install oh-my-zsh if not present
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
            log_info "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        
        # Create zsh config symlinks
        create_symlink "$CONFIG_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
        create_symlink "$CONFIG_DIR/shell/zsh/.zshenv" "$HOME/.zshenv"
        
        # Install zsh plugins
        install_zsh_plugins
        
        log_success "Zsh configuration complete"
    else
        log_warning "Zsh not found, skipping zsh configuration"
    fi
}

# Install zsh plugins
install_zsh_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    fi
    
    # fzf-tab
    if [[ ! -d "$zsh_custom/plugins/fzf-tab" ]]; then
        log_info "Installing fzf-tab..."
        git clone https://github.com/Aloxaf/fzf-tab "$zsh_custom/plugins/fzf-tab"
    fi
}

# Setup Git configuration
setup_git() {
    log_info "Setting up Git configuration..."
    
    # Create git config symlink
    create_symlink "$CONFIG_DIR/git/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$CONFIG_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
    
    log_success "Git configuration complete"
}

# Setup tmux configuration
setup_tmux() {
    if ! command -v tmux &> /dev/null; then
        log_warning "tmux not found, skipping tmux configuration"
        return 0
    fi
    
    log_info "Setting up tmux configuration..."
    
    # Create tmux config symlink
    create_symlink "$CONFIG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # Install TPM (Tmux Plugin Manager) if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    
    log_success "tmux configuration complete"
    log_info "Run 'tmux source ~/.tmux.conf' and press prefix + I to install plugins"
}

# Setup terminal configurations
setup_terminals() {
    log_info "Setting up terminal configurations..."
    
    # Kitty configuration
    if command -v kitty &> /dev/null; then
        create_symlink "$CONFIG_DIR/terminal/kitty" "$HOME/.config/kitty"
        log_success "Kitty configuration linked"
    fi
    
    # Note: Windows Terminal config is handled in windows.ps1
}

# Setup development environments
setup_development() {
    log_info "Setting up development environments..."
    
    # Node.js setup
    setup_nodejs
    
    # Python setup
    setup_python
    
    # .NET setup (if available)
    setup_dotnet
}

# Setup Node.js environment
setup_nodejs() {
    # Install nvm if not present
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing nvm (Node Version Manager)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Source nvm
        export NVM_DIR="$HOME/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    fi
    
    # Create npm config symlinks
    if [[ -f "$CONFIG_DIR/development/node/.npmrc" ]]; then
        create_symlink "$CONFIG_DIR/development/node/.npmrc" "$HOME/.npmrc"
    fi
}

# Setup Python environment
setup_python() {
    # Install pyenv if not present and python3 is available
    if command -v python3 &> /dev/null && [[ ! -d "$HOME/.pyenv" ]]; then
        log_info "Installing pyenv (Python Version Manager)..."
        curl https://pyenv.run | bash
    fi
    
    # Create pip config
    if [[ -f "$CONFIG_DIR/development/python/pip.conf" ]]; then
        mkdir -p "$HOME/.pip"
        create_symlink "$CONFIG_DIR/development/python/pip.conf" "$HOME/.pip/pip.conf"
    fi
}

# Setup .NET environment
setup_dotnet() {
    if command -v dotnet &> /dev/null; then
        log_info "Setting up .NET configuration..."
        
        # Create .NET config directory
        mkdir -p "$HOME/.nuget/NuGet"
        
        if [[ -f "$CONFIG_DIR/development/dotnet/NuGet.Config" ]]; then
            create_symlink "$CONFIG_DIR/development/dotnet/NuGet.Config" "$HOME/.nuget/NuGet/NuGet.Config"
        fi
    fi
}

# Main common setup function
main() {
    log_info "Running common setup tasks..."
    
    # Install Starship
    install_starship
    
    # Setup shell
    setup_shell
    
    # Setup Git
    setup_git
    
    # Setup tmux
    setup_tmux
    
    # Setup terminals
    setup_terminals
    
    # Setup development environments
    setup_development
    
    log_success "Common setup complete!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
