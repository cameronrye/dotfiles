# Platform-Specific Notes

This document provides platform-specific information and considerations for the dotfiles setup.

## Table of Contents

- [macOS](#macos)
- [Linux (Debian/Ubuntu)](#linux-debianubuntu)
- [Windows](#windows)
- [Windows Subsystem for Linux (WSL)](#windows-subsystem-for-linux-wsl)
- [Cross-Platform Considerations](#cross-platform-considerations)

## macOS

### Requirements

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools
- Admin privileges for Homebrew installation

### Installation

```bash
# Install Xcode Command Line Tools first
xcode-select --install

# Clone and install dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install/install.sh
```

### macOS-Specific Features

#### Homebrew Integration
- Automatic Homebrew installation
- Brewfile for package management
- Cask support for GUI applications

#### System Defaults
The installer configures various macOS system preferences:

```bash
# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
```

#### Font Installation
Nerd Fonts are automatically installed via Homebrew Cask:

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

### macOS-Specific Tools

#### Included Applications
- **Rectangle**: Window management
- **The Unarchiver**: Archive utility
- **AppCleaner**: Application uninstaller

#### Terminal Integration
- **Kitty**: Modern terminal emulator with GPU acceleration
- **iTerm2**: Alternative terminal (optional)

### Troubleshooting macOS

#### Homebrew Issues
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) $(brew --prefix)/*

# Reinstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Apple Silicon (M1/M2) Considerations
- Homebrew installs to `/opt/homebrew` instead of `/usr/local`
- Some packages may need Rosetta 2 for compatibility
- PATH configuration automatically handles both architectures

## Linux (Debian/Ubuntu)

### Requirements

- Debian 10+ or Ubuntu 18.04+
- sudo access
- Internet connection

### Installation

```bash
# Update package lists
sudo apt update

# Clone and install dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install/install.sh
```

### Linux-Specific Features

#### Package Management
- Automatic package installation via apt
- PPA support for newer packages
- Snap package support (optional)

#### Development Tools
- Build tools and compilers
- Language-specific package managers
- Container support (Docker)

### Linux-Specific Configurations

#### Font Installation
```bash
# Manual font installation
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

#### Desktop Integration
```bash
# Kitty desktop integration
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
```

### Distribution-Specific Notes

#### Ubuntu
- Uses snap packages for some applications
- PPAs for latest software versions
- Unity/GNOME desktop integration

#### Debian
- More conservative package versions
- Manual PPA addition may be required
- Minimal desktop environment support

### Troubleshooting Linux

#### Package Installation Issues
```bash
# Fix broken packages
sudo apt --fix-broken install

# Update package cache
sudo apt update && sudo apt upgrade

# Install missing dependencies
sudo apt install -y build-essential curl wget git
```

#### Permission Issues
```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
```

## Windows

### Requirements

- Windows 10/11
- PowerShell 5.1+ or PowerShell Core 7+
- Admin privileges
- Windows Subsystem for Linux (recommended)

### Installation

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Clone and install dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git $env:USERPROFILE\.dotfiles
cd $env:USERPROFILE\.dotfiles
.\install\windows.ps1
```

### Windows-Specific Features

#### Package Management
- Chocolatey for package installation
- Windows Package Manager (winget) support
- Scoop as alternative package manager

#### Windows Terminal
- Modern terminal with tabs and panes
- GPU-accelerated text rendering
- Custom color schemes and fonts

#### PowerShell Integration
- Custom PowerShell profile
- Module management
- Cross-platform PowerShell support

### Windows-Specific Tools

#### Development Environment
- Windows Terminal
- PowerShell Core
- Git for Windows
- Visual Studio Code
- JetBrains Toolbox

#### System Integration
- Windows Subsystem for Linux
- Docker Desktop
- Windows Package Manager

### Troubleshooting Windows

#### Execution Policy Issues
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Check current policy
Get-ExecutionPolicy -List
```

#### Chocolatey Issues
```powershell
# Reinstall Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Windows Subsystem for Linux (WSL)

### Requirements

- Windows 10 version 2004+ or Windows 11
- WSL 2 enabled
- Ubuntu or Debian distribution

### Installation

```bash
# Install WSL (Windows PowerShell as Admin)
wsl --install

# Or install specific distribution
wsl --install -d Ubuntu

# Update to WSL 2
wsl --set-version Ubuntu 2
wsl --set-default-version 2
```

### WSL-Specific Configurations

#### File System Integration
```bash
# Windows drives mounted at /mnt/
cd /mnt/c/Users/$USER

# WSL home directory
cd ~  # /home/$USER
```

#### Network Configuration
```bash
# Access Windows localhost from WSL
curl http://localhost:3000

# Access WSL services from Windows
# Use WSL IP address or localhost
```

### WSL Best Practices

#### Performance
- Keep project files in WSL file system for better performance
- Use WSL 2 for better compatibility
- Configure Git for cross-platform line endings

#### Integration
```bash
# Windows Terminal integration
# Automatically detects WSL distributions

# VS Code integration
code .  # Opens VS Code with WSL extension

# Docker integration
# Use Docker Desktop with WSL 2 backend
```

### Troubleshooting WSL

#### WSL Not Starting
```powershell
# Check WSL status
wsl --list --verbose

# Restart WSL
wsl --shutdown
wsl

# Update WSL
wsl --update
```

#### File Permission Issues
```bash
# Fix Windows file permissions in WSL
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata
```

## Cross-Platform Considerations

### File Paths
- Use `$HOME` instead of hardcoded paths
- Handle different path separators
- Consider case sensitivity differences

### Line Endings
```bash
# Configure Git for cross-platform
git config --global core.autocrlf input  # macOS/Linux
git config --global core.autocrlf true   # Windows
```

### Environment Variables
```bash
# Platform detection in scripts
case "$(uname -s)" in
    Darwin*)    echo "macOS" ;;
    Linux*)     echo "Linux" ;;
    CYGWIN*)    echo "Windows" ;;
    MINGW*)     echo "Windows" ;;
esac
```

### Package Managers
- **macOS**: Homebrew
- **Linux**: apt, yum, dnf, pacman
- **Windows**: Chocolatey, winget, Scoop

### Terminal Emulators
- **Cross-platform**: Kitty, Alacritty
- **macOS**: iTerm2, Terminal.app
- **Linux**: GNOME Terminal, Konsole
- **Windows**: Windows Terminal, ConEmu

### Fonts
- Use Nerd Fonts for consistent icon support
- Install fonts system-wide when possible
- Fallback fonts for compatibility

### Shell Compatibility
- Primary: Zsh with Oh My Zsh
- Fallback: Bash
- Windows: PowerShell with custom profile

### Best Practices

1. **Test on multiple platforms** before committing changes
2. **Use conditional logic** for platform-specific configurations
3. **Document platform differences** in comments
4. **Provide fallbacks** for missing tools
5. **Use standard tools** when possible for better compatibility
