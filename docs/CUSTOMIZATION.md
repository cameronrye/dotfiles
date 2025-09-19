# Customization Guide

This guide explains how to customize your dotfiles configuration to suit your preferences and workflow.

## Table of Contents

- [General Principles](#general-principles)
- [Shell Customization](#shell-customization)
- [Terminal Customization](#terminal-customization)
- [Editor Customization](#editor-customization)
- [Git Customization](#git-customization)
- [Development Environment](#development-environment)
- [Local Overrides](#local-overrides)
- [Adding New Tools](#adding-new-tools)

## General Principles

### Local Configuration Files

The dotfiles system supports local configuration files that won't be tracked by git:

- `~/.zshrc.local` - Local zsh configuration
- `~/.gitconfig_local` - Local git configuration
- `~/.gitconfig_work` - Work-specific git configuration

### Backup Before Customizing

Always backup your configurations before making changes:

```bash
cd ~/.dotfiles
./scripts/backup.sh
```

## Shell Customization

### Adding Custom Aliases

Add your custom aliases to `~/.zshrc.local`:

```bash
# ~/.zshrc.local
alias myproject="cd ~/Projects/my-important-project"
alias serve="python3 -m http.server 8000"
alias weather="curl wttr.in/YourCity"
```

### Custom Functions

Add custom functions to `~/.zshrc.local`:

```bash
# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and replace in files
findreplace() {
    find . -type f -name "*.$3" -exec sed -i '' "s/$1/$2/g" {} +
}
```

### Environment Variables

Add environment variables to `~/.zshenv.local`:

```bash
# ~/.zshenv.local
export CUSTOM_PATH="/path/to/custom/tools"
export API_KEY="your-api-key"
export EDITOR="your-preferred-editor"
```

### Starship Prompt Customization

Edit `config/shell/starship/starship.toml` to customize your prompt:

```toml
# Add custom modules
[custom.my_module]
command = "echo 'custom'"
when = "true"
format = "[$output]($style)"
style = "bold green"

# Modify existing modules
[git_branch]
symbol = "🌿 "
format = "[$symbol$branch]($style)"
style = "bold purple"
```

## Terminal Customization

### Kitty Terminal

Edit `config/terminal/kitty/kitty.conf`:

```conf
# Change font
font_family JetBrains Mono Nerd Font
font_size 16.0

# Change colors
background #1e1e2e
foreground #cdd6f4

# Add custom key bindings
map cmd+t new_tab_with_cwd
map cmd+shift+t new_tab
```

### Windows Terminal

Edit `config/terminal/windows-terminal/settings.json`:

```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "Cascadia Code",
        "size": 14
      },
      "colorScheme": "One Dark"
    }
  }
}
```

## Editor Customization

### VS Code

#### Custom Settings

Add to `config/editors/vscode/settings.json`:

```json
{
  "editor.fontSize": 16,
  "workbench.colorTheme": "GitHub Dark",
  "editor.fontFamily": "Fira Code, monospace",
  "editor.fontLigatures": true
}
```

#### Custom Keybindings

Add to `config/editors/vscode/keybindings.json`:

```json
[
  {
    "key": "cmd+k cmd+s",
    "command": "workbench.action.files.save"
  }
]
```

#### Custom Snippets

Create language-specific snippet files in `config/editors/vscode/snippets/`:

```json
// config/editors/vscode/snippets/python.json
{
  "Print Debug": {
    "prefix": "pdb",
    "body": ["print(f\"DEBUG: {$1}\")"],
    "description": "Debug print statement"
  }
}
```

### JetBrains IDEs

Refer to `config/editors/jetbrains/README.md` for detailed customization instructions.

## Git Customization

### Personal Information

Edit `config/git/.gitconfig` or create `~/.gitconfig_local`:

```ini
[user]
    name = Your Name
    email = your.email@example.com
    signingkey = YOUR_GPG_KEY_ID

[commit]
    gpgsign = true
```

### Custom Aliases

Add to `config/git/.gitconfig`:

```ini
[alias]
    # Your custom aliases
    mylog = log --oneline --graph --decorate --all
    unstage = reset HEAD --
    visual = !gitk
```

### Work Configuration

Create `~/.gitconfig_work` for work-specific settings:

```ini
[user]
    name = Your Work Name
    email = your.work@company.com

[core]
    sshCommand = ssh -i ~/.ssh/work_key
```

## Development Environment

### Node.js

#### Custom npm Configuration

Edit `config/development/node/.npmrc`:

```ini
registry=https://your-private-registry.com/
//your-private-registry.com/:_authToken=${NPM_TOKEN}
```

#### Global Packages

Add packages to `config/development/node/package-list.txt`:

```
your-favorite-cli-tool
custom-generator
project-specific-tool
```

### Python

#### Custom pip Configuration

Edit `config/development/python/pip.conf`:

```ini
[global]
index-url = https://your-private-pypi.com/simple/
trusted-host = your-private-pypi.com
```

#### Python Startup Script

Edit `config/development/python/pythonrc`:

```python
# Add your custom imports and functions
import json
import requests
from datetime import datetime

def pretty_json(obj):
    print(json.dumps(obj, indent=2))
```

### .NET

Edit `config/development/dotnet/NuGet.Config`:

```xml
<packageSources>
  <add key="MyCompany" value="https://nuget.mycompany.com/v3/index.json" />
</packageSources>
```

## Local Overrides

### Shell Overrides

Create `~/.zshrc.local` for local shell customizations:

```bash
# Company-specific aliases
alias vpn="sudo openconnect company-vpn.com"
alias deploy="./scripts/deploy.sh"

# Local environment variables
export COMPANY_API_KEY="secret-key"
export PROJECT_ROOT="$HOME/work/main-project"

# Custom PATH additions
export PATH="$HOME/company-tools/bin:$PATH"
```

### Git Overrides

Create `~/.gitconfig_local`:

```ini
[user]
    name = Your Full Name
    email = personal@email.com

[github]
    user = your-github-username

[core]
    editor = vim
```

### Environment Overrides

Create `~/.zshenv.local`:

```bash
# Override default editor
export EDITOR="vim"

# Add custom paths
export PATH="/usr/local/custom/bin:$PATH"

# Custom XDG directories
export XDG_CONFIG_HOME="$HOME/.config"
```

## Adding New Tools

### Adding a New CLI Tool

1. **Add installation to platform scripts:**

```bash
# install/macos.sh
brew "new-tool"

# install/debian.sh
sudo apt install -y new-tool
```

2. **Create configuration directory:**

```bash
mkdir -p config/new-tool
```

3. **Add configuration files:**

```bash
# config/new-tool/config.yaml
setting1: value1
setting2: value2
```

4. **Add symlink creation to common.sh:**

```bash
# install/common.sh
setup_new_tool() {
    if command -v new-tool &> /dev/null; then
        create_symlink "$CONFIG_DIR/new-tool/config.yaml" "$HOME/.config/new-tool/config.yaml"
        log_success "new-tool configuration linked"
    fi
}
```

### Adding Shell Integration

Add to `config/shell/zsh/.zshrc`:

```bash
# New tool integration
if command -v new-tool &> /dev/null; then
    # Add completion
    eval "$(new-tool completion zsh)"
    
    # Add aliases
    alias nt='new-tool'
    alias ntl='new-tool list'
fi
```

## Best Practices

### 1. Use Local Files for Sensitive Data

Never commit sensitive information like API keys or passwords. Use local configuration files:

```bash
# ~/.zshrc.local
export SECRET_API_KEY="your-secret-key"
export DATABASE_PASSWORD="your-password"
```

### 2. Document Your Changes

Add comments to explain custom configurations:

```bash
# Custom alias for work project deployment
alias deploy-prod="./scripts/deploy.sh --env=production --confirm"

# Function to quickly switch to project directories
project() {
    cd "$HOME/Projects/$1" || echo "Project $1 not found"
}
```

### 3. Test Changes

Always test your changes in a new terminal session:

```bash
# Reload configuration
source ~/.zshrc

# Or start a new shell
zsh
```

### 4. Keep Backups

Before making significant changes:

```bash
./scripts/backup.sh
```

### 5. Use Version Control for Local Files

Consider creating a private repository for your local configuration files:

```bash
cd ~
git init dotfiles-local
git add .zshrc.local .gitconfig_local
git commit -m "Initial local configuration"
```

## Troubleshooting

### Configuration Not Loading

1. Check file permissions:
```bash
ls -la ~/.zshrc ~/.zshenv
```

2. Check for syntax errors:
```bash
zsh -n ~/.zshrc
```

3. Debug loading:
```bash
zsh -x
```

### Symlinks Not Working

1. Check if symlink exists:
```bash
ls -la ~/.gitconfig
```

2. Recreate symlink:
```bash
rm ~/.gitconfig
ln -sf ~/.dotfiles/config/git/.gitconfig ~/.gitconfig
```

### Tool Not Found

1. Check if tool is installed:
```bash
which tool-name
```

2. Check PATH:
```bash
echo $PATH
```

3. Reload shell configuration:
```bash
source ~/.zshrc
```

## Getting Help

- Check the main [README.md](../README.md) for general information
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [PLATFORMS.md](PLATFORMS.md) for platform-specific notes
- Open an issue on GitHub for bugs or feature requests
