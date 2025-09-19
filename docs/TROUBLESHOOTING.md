# Troubleshooting Guide

This guide helps you resolve common issues with the dotfiles setup.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Shell Issues](#shell-issues)
- [Terminal Issues](#terminal-issues)
- [Editor Issues](#editor-issues)
- [Git Issues](#git-issues)
- [Development Environment Issues](#development-environment-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Performance Issues](#performance-issues)

## Installation Issues

### Permission Denied Errors

**Problem:** Getting permission denied when running installation scripts.

**Solution:**
```bash
# Make scripts executable
chmod +x install/*.sh scripts/*.sh

# Run with proper permissions
./install/install.sh
```

### Homebrew Installation Fails (macOS)

**Problem:** Homebrew installation fails or is not found.

**Solution:**
```bash
# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add to PATH (Intel)
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Package Installation Fails

**Problem:** Some packages fail to install during setup.

**Solution:**
```bash
# Update package lists first
sudo apt update  # Debian/Ubuntu
brew update      # macOS

# Install packages individually to identify issues
brew install package-name
sudo apt install package-name

# Check for conflicting packages
brew doctor      # macOS
```

### Git Clone Fails

**Problem:** Cannot clone the dotfiles repository.

**Solution:**
```bash
# Check internet connection
ping github.com

# Use HTTPS instead of SSH
git clone https://github.com/YOUR_USERNAME/dotfiles.git

# Check SSH key setup
ssh -T git@github.com
```

## Shell Issues

### Zsh Not Default Shell

**Problem:** Zsh is installed but not set as default shell.

**Solution:**
```bash
# Check available shells
cat /etc/shells

# Add zsh to shells if missing
echo $(which zsh) | sudo tee -a /etc/shells

# Change default shell
chsh -s $(which zsh)

# Restart terminal or log out/in
```

### Oh-My-Zsh Installation Issues

**Problem:** Oh-My-Zsh fails to install or load.

**Solution:**
```bash
# Remove existing installation
rm -rf ~/.oh-my-zsh

# Install manually
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Check for conflicting .zshrc
mv ~/.zshrc ~/.zshrc.backup
ln -sf ~/.dotfiles/config/shell/zsh/.zshrc ~/.zshrc
```

### Starship Prompt Not Loading

**Problem:** Starship prompt doesn't appear or shows errors.

**Solution:**
```bash
# Check if starship is installed
which starship

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Check configuration
starship config

# Test configuration
starship print-config

# Reload shell
exec zsh
```

### Slow Shell Startup

**Problem:** Shell takes a long time to start.

**Solution:**
```bash
# Profile shell startup
zsh -xvs

# Disable plugins temporarily
# Edit ~/.zshrc and comment out plugins

# Check for slow commands in .zshrc
time zsh -i -c exit

# Common culprits:
# - nvm loading
# - pyenv initialization
# - complex prompt configurations
```

## Terminal Issues

### Kitty Terminal Not Found

**Problem:** Kitty terminal is not installed or not working.

**Solution:**
```bash
# macOS
brew install --cask kitty

# Linux
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# Check installation
which kitty
kitty --version

# Test configuration
kitty --config ~/.config/kitty/kitty.conf
```

### Font Issues

**Problem:** Fonts not displaying correctly or missing icons.

**Solution:**
```bash
# Install Nerd Fonts
# macOS
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# Linux
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "JetBrains Mono Nerd Font.ttf" \
  https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
fc-cache -fv

# Verify font installation
fc-list | grep -i jetbrains
```

### Terminal Colors Wrong

**Problem:** Colors not displaying correctly.

**Solution:**
```bash
# Check terminal color support
echo $TERM
tput colors

# Test 256 color support
curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash

# Set correct TERM variable
export TERM=xterm-256color

# For tmux
export TERM=screen-256color
```

## Editor Issues

### VS Code Settings Not Applied

**Problem:** VS Code settings from dotfiles are not being used.

**Solution:**
```bash
# Check symlink
ls -la ~/.config/Code/User/settings.json  # Linux
ls -la "~/Library/Application Support/Code/User/settings.json"  # macOS

# Recreate symlink
rm ~/.config/Code/User/settings.json
ln -sf ~/.dotfiles/config/editors/vscode/settings.json ~/.config/Code/User/settings.json

# Restart VS Code
code --disable-extensions  # Test without extensions
```

### VS Code Extensions Not Installing

**Problem:** Extensions fail to install from the list.

**Solution:**
```bash
# Install extensions manually
cat ~/.dotfiles/config/editors/vscode/extensions.txt | xargs -L 1 code --install-extension

# Check for errors
code --list-extensions
code --show-versions

# Clear extension cache
rm -rf ~/.vscode/extensions
```

### JetBrains IDE Issues

**Problem:** JetBrains IDE settings not syncing.

**Solution:**
1. Check IDE version compatibility
2. Use Settings Repository feature:
   - File → Manage IDE Settings → Settings Repository
   - Enter repository URL
   - Choose "Overwrite Local" or "Merge"

3. Manual import:
   - File → Manage IDE Settings → Import Settings
   - Select exported settings file

## Git Issues

### Git Configuration Not Loading

**Problem:** Git configuration from dotfiles is not being used.

**Solution:**
```bash
# Check symlink
ls -la ~/.gitconfig

# Recreate symlink
rm ~/.gitconfig
ln -sf ~/.dotfiles/config/git/.gitconfig ~/.gitconfig

# Verify configuration
git config --list
git config user.name
git config user.email
```

### GitHub CLI Authentication

**Problem:** GitHub CLI (gh) authentication issues.

**Solution:**
```bash
# Login to GitHub CLI
gh auth login

# Check authentication status
gh auth status

# Refresh token
gh auth refresh

# Configure git credential helper
gh auth setup-git
```

### GPG Signing Issues

**Problem:** Git commits fail with GPG signing errors.

**Solution:**
```bash
# Check GPG keys
gpg --list-secret-keys --keyid-format LONG

# Configure git with GPG key
git config user.signingkey YOUR_KEY_ID
git config commit.gpgsign true

# Test GPG signing
echo "test" | gpg --clearsign

# Fix GPG_TTY for terminal
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
```

## Development Environment Issues

### Node.js/npm Issues

**Problem:** Node.js or npm not working correctly.

**Solution:**
```bash
# Check nvm installation
ls -la ~/.nvm

# Install nvm manually
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.zshrc

# Install latest Node.js
nvm install node
nvm use node
nvm alias default node

# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
```

### Python/pip Issues

**Problem:** Python or pip not working correctly.

**Solution:**
```bash
# Check Python installation
which python3
python3 --version

# Install pyenv
curl https://pyenv.run | bash

# Add to PATH
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Install Python
pyenv install 3.11.0
pyenv global 3.11.0

# Fix pip
python3 -m pip install --upgrade pip
```

### .NET Issues

**Problem:** .NET SDK not found or not working.

**Solution:**
```bash
# Check .NET installation
dotnet --version

# Install .NET SDK
# macOS
brew install --cask dotnet-sdk

# Linux
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-7.0

# Clear NuGet cache
dotnet nuget locals all --clear
```

## Platform-Specific Issues

### macOS Issues

**Problem:** macOS-specific tools not working.

**Solution:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept

# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions

# Reset Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Linux Issues

**Problem:** Linux-specific package issues.

**Solution:**
```bash
# Update package lists
sudo apt update

# Fix broken packages
sudo apt --fix-broken install

# Install missing dependencies
sudo apt install -y build-essential curl wget git

# Fix locale issues
sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
```

### Windows/WSL Issues

**Problem:** Windows or WSL-specific issues.

**Solution:**
```bash
# Update WSL
wsl --update

# Check WSL version
wsl --list --verbose

# Convert to WSL2 if needed
wsl --set-version Ubuntu 2

# Fix file permissions in WSL
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata
```

## Performance Issues

### Slow Terminal Startup

**Problem:** Terminal takes a long time to start.

**Solution:**
```bash
# Profile shell startup
time zsh -i -c exit

# Common fixes:
# 1. Lazy load nvm
export NVM_LAZY_LOAD=true

# 2. Reduce history size
export HISTSIZE=1000
export SAVEHIST=1000

# 3. Disable unused plugins
# Edit ~/.zshrc and remove unused plugins

# 4. Use faster alternatives
# Replace 'ls' with 'exa'
# Replace 'cat' with 'bat'
```

### High Memory Usage

**Problem:** Shell or terminal using too much memory.

**Solution:**
```bash
# Check memory usage
ps aux | grep -E "(zsh|bash|kitty|code)"

# Reduce history size
export HISTSIZE=1000

# Disable memory-intensive plugins
# Edit ~/.zshrc

# Clear caches
rm -rf ~/.cache/*
npm cache clean --force
pip cache purge
```

## Getting More Help

### Debug Mode

Enable debug mode for detailed output:

```bash
# Shell debug
zsh -x

# Installation debug
DEBUG=1 ./install/install.sh

# Git debug
GIT_TRACE=1 git command
```

### Log Files

Check log files for errors:

```bash
# System logs
tail -f /var/log/syslog  # Linux
tail -f /var/log/system.log  # macOS

# Application logs
~/.npm/_logs/
~/.pip/pip.log
```

### Community Support

- Open an issue on GitHub with:
  - Operating system and version
  - Shell and version
  - Error messages
  - Steps to reproduce
  - Output of debug commands

- Include system information:
```bash
uname -a
echo $SHELL
echo $0
which zsh
zsh --version
```
