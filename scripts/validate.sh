#!/usr/bin/env bash

# Validation Script for Dotfiles
# Validates the installation and configuration of dotfiles

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

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

# Test result functions
test_pass() {
    log_success "$1"
    ((TESTS_PASSED++))
}

test_fail() {
    log_error "$1"
    ((TESTS_FAILED++))
}

test_skip() {
    log_warning "$1"
    ((TESTS_SKIPPED++))
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if file exists and is a symlink
check_symlink() {
    local target="$1"
    local description="$2"
    
    if [[ -L "$target" ]]; then
        test_pass "$description symlink exists"
        return 0
    elif [[ -e "$target" ]]; then
        test_fail "$description exists but is not a symlink"
        return 1
    else
        test_fail "$description symlink missing"
        return 1
    fi
}

# Check if file exists
check_file() {
    local target="$1"
    local description="$2"
    
    if [[ -f "$target" ]]; then
        test_pass "$description exists"
        return 0
    else
        test_fail "$description missing"
        return 1
    fi
}

# Check if directory exists
check_directory() {
    local target="$1"
    local description="$2"
    
    if [[ -d "$target" ]]; then
        test_pass "$description exists"
        return 0
    else
        test_fail "$description missing"
        return 1
    fi
}

# Validate shell configuration
validate_shell() {
    log_info "Validating shell configuration..."
    
    # Check if zsh is installed
    if command_exists zsh; then
        test_pass "Zsh is installed"
        
        # Check zsh version
        local zsh_version
        zsh_version=$(zsh --version | cut -d' ' -f2)
        test_pass "Zsh version: $zsh_version"
        
        # Check if zsh is default shell
        if [[ "$SHELL" == *"zsh"* ]]; then
            test_pass "Zsh is default shell"
        else
            test_fail "Zsh is not default shell (current: $SHELL)"
        fi
    else
        test_fail "Zsh is not installed"
    fi
    
    # Check oh-my-zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        test_pass "Oh My Zsh is installed"
    else
        test_fail "Oh My Zsh is not installed"
    fi
    
    # Check zsh configuration files
    check_symlink "$HOME/.zshrc" "Zsh configuration"
    check_symlink "$HOME/.zshenv" "Zsh environment"
    
    # Check starship
    if command_exists starship; then
        test_pass "Starship is installed"
        check_symlink "$HOME/.config/starship.toml" "Starship configuration"
    else
        test_fail "Starship is not installed"
    fi
}

# Validate Git configuration
validate_git() {
    log_info "Validating Git configuration..."
    
    # Check if git is installed
    if command_exists git; then
        test_pass "Git is installed"
        
        # Check git version
        local git_version
        git_version=$(git --version | cut -d' ' -f3)
        test_pass "Git version: $git_version"
    else
        test_fail "Git is not installed"
        return
    fi
    
    # Check git configuration files
    check_symlink "$HOME/.gitconfig" "Git configuration"
    check_symlink "$HOME/.gitignore_global" "Global gitignore"
    check_symlink "$HOME/.gitattributes_global" "Global gitattributes"
    
    # Check git configuration values
    local git_name git_email
    git_name=$(git config user.name 2>/dev/null || echo "")
    git_email=$(git config user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_name" ]]; then
        test_pass "Git user name configured: $git_name"
    else
        test_fail "Git user name not configured"
    fi
    
    if [[ -n "$git_email" ]]; then
        test_pass "Git user email configured: $git_email"
    else
        test_fail "Git user email not configured"
    fi
    
    # Check GitHub CLI
    if command_exists gh; then
        test_pass "GitHub CLI is installed"
        
        # Check authentication
        if gh auth status &> /dev/null; then
            test_pass "GitHub CLI is authenticated"
        else
            test_fail "GitHub CLI is not authenticated"
        fi
    else
        test_skip "GitHub CLI is not installed"
    fi
}

# Validate terminal configuration
validate_terminal() {
    log_info "Validating terminal configuration..."
    
    # Check Kitty
    if command_exists kitty; then
        test_pass "Kitty terminal is installed"
        check_directory "$HOME/.config/kitty" "Kitty configuration directory"
        check_file "$HOME/.config/kitty/kitty.conf" "Kitty configuration file"
    else
        test_skip "Kitty terminal is not installed"
    fi
    
    # Check tmux
    if command_exists tmux; then
        test_pass "tmux is installed"
        check_symlink "$HOME/.tmux.conf" "tmux configuration"
        
        # Check TPM
        if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
            test_pass "Tmux Plugin Manager is installed"
        else
            test_fail "Tmux Plugin Manager is not installed"
        fi
    else
        test_skip "tmux is not installed"
    fi
}

# Validate development environment
validate_development() {
    log_info "Validating development environment..."
    
    # Node.js
    if command_exists node; then
        test_pass "Node.js is installed"
        local node_version
        node_version=$(node --version)
        test_pass "Node.js version: $node_version"
        
        # Check npm
        if command_exists npm; then
            test_pass "npm is installed"
            local npm_version
            npm_version=$(npm --version)
            test_pass "npm version: $npm_version"
        else
            test_fail "npm is not installed"
        fi
        
        # Check nvm
        if [[ -d "$HOME/.nvm" ]]; then
            test_pass "nvm is installed"
        else
            test_skip "nvm is not installed"
        fi
    else
        test_skip "Node.js is not installed"
    fi
    
    # Python
    if command_exists python3; then
        test_pass "Python 3 is installed"
        local python_version
        python_version=$(python3 --version)
        test_pass "Python version: $python_version"
        
        # Check pip
        if command_exists pip3; then
            test_pass "pip3 is installed"
        else
            test_fail "pip3 is not installed"
        fi
        
        # Check pyenv
        if command_exists pyenv; then
            test_pass "pyenv is installed"
        else
            test_skip "pyenv is not installed"
        fi
    else
        test_skip "Python 3 is not installed"
    fi
    
    # .NET
    if command_exists dotnet; then
        test_pass ".NET SDK is installed"
        local dotnet_version
        dotnet_version=$(dotnet --version)
        test_pass ".NET version: $dotnet_version"
    else
        test_skip ".NET SDK is not installed"
    fi
}

# Validate editors
validate_editors() {
    log_info "Validating editor configuration..."
    
    # VS Code
    if command_exists code; then
        test_pass "VS Code is installed"
        
        # Check configuration directory
        case "$(uname -s)" in
            Darwin*)
                local vscode_config="$HOME/Library/Application Support/Code/User"
                ;;
            Linux*)
                local vscode_config="$HOME/.config/Code/User"
                ;;
            *)
                local vscode_config="$HOME/.config/Code/User"
                ;;
        esac
        
        check_directory "$vscode_config" "VS Code configuration directory"
        check_file "$vscode_config/settings.json" "VS Code settings"
        check_file "$vscode_config/keybindings.json" "VS Code keybindings"
    else
        test_skip "VS Code is not installed"
    fi
    
    # Neovim
    if command_exists nvim; then
        test_pass "Neovim is installed"
    else
        test_skip "Neovim is not installed"
    fi
}

# Validate package managers
validate_package_managers() {
    log_info "Validating package managers..."
    
    case "$(uname -s)" in
        Darwin*)
            # Homebrew
            if command_exists brew; then
                test_pass "Homebrew is installed"
                
                # Check Homebrew health
                if brew doctor &> /dev/null; then
                    test_pass "Homebrew doctor check passed"
                else
                    test_fail "Homebrew doctor check failed"
                fi
            else
                test_fail "Homebrew is not installed"
            fi
            ;;
        Linux*)
            # Check apt (Debian/Ubuntu)
            if command_exists apt; then
                test_pass "apt package manager is available"
            else
                test_skip "apt package manager is not available"
            fi
            ;;
    esac
}

# Validate modern CLI tools
validate_modern_tools() {
    log_info "Validating modern CLI tools..."
    
    local tools=(
        "fzf:Fuzzy finder"
        "ripgrep:Text search tool"
        "bat:Enhanced cat"
        "exa:Enhanced ls"
        "fd:Enhanced find"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if command_exists "$tool"; then
            test_pass "$description ($tool) is installed"
        else
            test_skip "$description ($tool) is not installed"
        fi
    done
}

# Validate fonts
validate_fonts() {
    log_info "Validating fonts..."
    
    case "$(uname -s)" in
        Darwin*)
            # Check for Nerd Fonts on macOS
            if ls ~/Library/Fonts/*Nerd* &> /dev/null || ls /System/Library/Fonts/*Nerd* &> /dev/null; then
                test_pass "Nerd Fonts are installed"
            else
                test_fail "Nerd Fonts are not installed"
            fi
            ;;
        Linux*)
            # Check for fonts on Linux
            if fc-list | grep -i "nerd\|jetbrains\|fira" &> /dev/null; then
                test_pass "Programming fonts are installed"
            else
                test_fail "Programming fonts are not installed"
            fi
            ;;
        *)
            test_skip "Font validation not supported on this platform"
            ;;
    esac
}

# Show summary
show_summary() {
    echo
    log_info "Validation Summary:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "  Skipped: $TESTS_SKIPPED"
    echo "  Total: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
    echo
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed! Your dotfiles are properly configured."
        return 0
    else
        log_error "$TESTS_FAILED test(s) failed. Please check the output above."
        return 1
    fi
}

# Main validation function
main() {
    log_info "Starting dotfiles validation..."
    echo
    
    # Run validation tests
    validate_shell
    echo
    validate_git
    echo
    validate_terminal
    echo
    validate_development
    echo
    validate_editors
    echo
    validate_package_managers
    echo
    validate_modern_tools
    echo
    validate_fonts
    echo
    
    # Show summary
    show_summary
}

# Run main function
main "$@"
