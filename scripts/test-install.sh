#!/usr/bin/env bash

# Test Installation Script for Dotfiles
# Tests the installation process in a safe environment

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

# Test environment
readonly TEST_HOME="/tmp/dotfiles_test_$$"
readonly TEST_USER="testuser"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cleanup function
cleanup() {
    log_info "Cleaning up test environment..."
    if [[ -d "$TEST_HOME" ]]; then
        rm -rf "$TEST_HOME"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Create test environment
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Create test home directory
    mkdir -p "$TEST_HOME"
    
    # Set test environment variables
    export HOME="$TEST_HOME"
    export USER="$TEST_USER"
    
    # Create basic directory structure
    mkdir -p "$TEST_HOME"/{.config,.local/bin,.ssh}
    
    log_success "Test environment created at $TEST_HOME"
}

# Test dry run installation
test_dry_run() {
    log_info "Testing dry run installation..."
    
    # Copy dotfiles to test environment
    cp -r "$DOTFILES_DIR" "$TEST_HOME/.dotfiles"
    cd "$TEST_HOME/.dotfiles"
    
    # Test with dry run flag (if supported)
    if ./install/install.sh --help 2>&1 | grep -q "dry-run\|--dry"; then
        ./install/install.sh --dry-run
        log_success "Dry run completed successfully"
    else
        log_warning "Dry run not supported, skipping"
    fi
}

# Test backup functionality
test_backup() {
    log_info "Testing backup functionality..."
    
    # Create some existing files to backup
    echo "existing zshrc" > "$TEST_HOME/.zshrc"
    echo "existing gitconfig" > "$TEST_HOME/.gitconfig"
    mkdir -p "$TEST_HOME/.config/kitty"
    echo "existing kitty config" > "$TEST_HOME/.config/kitty/kitty.conf"
    
    # Run backup script
    cd "$TEST_HOME/.dotfiles"
    ./scripts/backup.sh
    
    # Check if backup was created
    local backup_dir
    backup_dir=$(find "$TEST_HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d | head -1)
    
    if [[ -n "$backup_dir" && -d "$backup_dir" ]]; then
        log_success "Backup created at $backup_dir"
        
        # Check if files were backed up
        if [[ -f "$backup_dir/.zshrc" ]]; then
            log_success "Existing .zshrc backed up"
        else
            log_error "Existing .zshrc not backed up"
        fi
        
        if [[ -f "$backup_dir/.gitconfig" ]]; then
            log_success "Existing .gitconfig backed up"
        else
            log_error "Existing .gitconfig not backed up"
        fi
    else
        log_error "Backup directory not created"
    fi
}

# Test symlink creation
test_symlinks() {
    log_info "Testing symlink creation..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Source common functions
    source install/common.sh
    
    # Test create_symlink function
    local test_source="$TEST_HOME/.dotfiles/config/git/.gitconfig"
    local test_target="$TEST_HOME/.gitconfig_test"
    
    if create_symlink "$test_source" "$test_target"; then
        if [[ -L "$test_target" ]]; then
            log_success "Symlink creation works"
        else
            log_error "Symlink not created properly"
        fi
    else
        log_error "Symlink creation failed"
    fi
}

# Test configuration validation
test_configuration_validation() {
    log_info "Testing configuration validation..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Test shell configuration syntax
    if command -v zsh &> /dev/null; then
        if zsh -n config/shell/zsh/.zshrc; then
            log_success "Zsh configuration syntax is valid"
        else
            log_error "Zsh configuration has syntax errors"
        fi
    else
        log_warning "Zsh not available for syntax checking"
    fi
    
    # Test starship configuration
    if command -v starship &> /dev/null; then
        if starship config config/shell/starship/starship.toml &> /dev/null; then
            log_success "Starship configuration is valid"
        else
            log_error "Starship configuration is invalid"
        fi
    else
        log_warning "Starship not available for validation"
    fi
    
    # Test tmux configuration syntax
    if command -v tmux &> /dev/null; then
        # Create a temporary tmux session to test config
        if tmux -f config/tmux/.tmux.conf new-session -d -s test_session 2>/dev/null; then
            tmux kill-session -t test_session 2>/dev/null
            log_success "tmux configuration is valid"
        else
            log_error "tmux configuration has errors"
        fi
    else
        log_warning "tmux not available for validation"
    fi
}

# Test cross-platform compatibility
test_cross_platform() {
    log_info "Testing cross-platform compatibility..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Test OS detection
    local detected_os
    case "$(uname -s)" in
        Darwin*)    detected_os="macOS" ;;
        Linux*)     detected_os="Linux" ;;
        CYGWIN*)    detected_os="Windows" ;;
        MINGW*)     detected_os="Windows" ;;
        *)          detected_os="Unknown" ;;
    esac
    
    log_success "Detected OS: $detected_os"
    
    # Test platform-specific scripts exist
    if [[ "$detected_os" == "macOS" && -f "install/macos.sh" ]]; then
        log_success "macOS installation script exists"
    elif [[ "$detected_os" == "Linux" && -f "install/debian.sh" ]]; then
        log_success "Linux installation script exists"
    elif [[ "$detected_os" == "Windows" && -f "install/windows.ps1" ]]; then
        log_success "Windows installation script exists"
    fi
    
    # Test configuration files have proper line endings
    if command -v file &> /dev/null; then
        local line_ending_issues=0
        while IFS= read -r -d '' config_file; do
            if file "$config_file" | grep -q "CRLF"; then
                log_warning "File has Windows line endings: $config_file"
                ((line_ending_issues++))
            fi
        done < <(find config -type f -name "*.conf" -o -name "*.toml" -o -name "*.json" -print0)
        
        if [[ $line_ending_issues -eq 0 ]]; then
            log_success "All configuration files have proper line endings"
        else
            log_warning "$line_ending_issues file(s) have Windows line endings"
        fi
    fi
}

# Test script permissions
test_permissions() {
    log_info "Testing script permissions..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Check if scripts are executable
    local non_executable=0
    while IFS= read -r -d '' script_file; do
        if [[ ! -x "$script_file" ]]; then
            log_warning "Script not executable: $script_file"
            ((non_executable++))
        fi
    done < <(find install scripts -name "*.sh" -print0)
    
    if [[ $non_executable -eq 0 ]]; then
        log_success "All shell scripts are executable"
    else
        log_warning "$non_executable script(s) are not executable"
    fi
    
    # Check PowerShell scripts
    if find install -name "*.ps1" | grep -q .; then
        log_success "PowerShell scripts found"
    fi
}

# Test documentation completeness
test_documentation() {
    log_info "Testing documentation completeness..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Check required documentation files
    local required_docs=(
        "README.md"
        "docs/CUSTOMIZATION.md"
        "docs/TROUBLESHOOTING.md"
        "docs/PLATFORMS.md"
    )
    
    local missing_docs=0
    for doc in "${required_docs[@]}"; do
        if [[ -f "$doc" ]]; then
            log_success "Documentation exists: $doc"
        else
            log_error "Missing documentation: $doc"
            ((missing_docs++))
        fi
    done
    
    if [[ $missing_docs -eq 0 ]]; then
        log_success "All required documentation is present"
    else
        log_error "$missing_docs required documentation file(s) missing"
    fi
    
    # Check if README has installation instructions
    if grep -q "install" README.md; then
        log_success "README contains installation instructions"
    else
        log_error "README missing installation instructions"
    fi
}

# Test package lists
test_package_lists() {
    log_info "Testing package lists..."
    
    cd "$TEST_HOME/.dotfiles"
    
    # Check Brewfile syntax (macOS)
    if [[ -f "install/Brewfile" ]]; then
        if command -v brew &> /dev/null; then
            if brew bundle check --file=install/Brewfile &> /dev/null; then
                log_success "Brewfile syntax is valid"
            else
                log_warning "Brewfile has issues (packages may not be available)"
            fi
        else
            log_warning "Homebrew not available to validate Brewfile"
        fi
    fi
    
    # Check package lists exist
    local package_files=(
        "config/development/node/package-list.txt"
        "config/development/python/requirements.txt"
        "config/editors/vscode/extensions.txt"
    )
    
    for package_file in "${package_files[@]}"; do
        if [[ -f "$package_file" ]]; then
            log_success "Package list exists: $package_file"
        else
            log_warning "Package list missing: $package_file"
        fi
    done
}

# Run all tests
run_all_tests() {
    log_info "Running comprehensive dotfiles tests..."
    echo
    
    # Setup
    setup_test_environment
    echo
    
    # Run tests
    test_dry_run
    echo
    test_backup
    echo
    test_symlinks
    echo
    test_configuration_validation
    echo
    test_cross_platform
    echo
    test_permissions
    echo
    test_documentation
    echo
    test_package_lists
    echo
    
    log_success "All tests completed!"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Test the dotfiles installation and configuration.

Options:
  -h, --help     Show this help message
  --dry-run      Test dry run functionality only
  --backup       Test backup functionality only
  --config       Test configuration validation only
  --docs         Test documentation completeness only

Examples:
  $0                    # Run all tests
  $0 --backup          # Test backup functionality only
  $0 --config          # Test configuration validation only

EOF
}

# Main function
main() {
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        --dry-run)
            setup_test_environment
            test_dry_run
            ;;
        --backup)
            setup_test_environment
            test_backup
            ;;
        --config)
            setup_test_environment
            test_configuration_validation
            ;;
        --docs)
            setup_test_environment
            test_documentation
            ;;
        "")
            run_all_tests
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
