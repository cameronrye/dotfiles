# 🏠 Dotfiles

A comprehensive, cross-platform dotfiles management system designed for modern development workflows.

## ✨ Features

- **🌍 Cross-Platform**: Supports macOS, Windows, and Debian/Ubuntu
- **🔧 Modern Tools**: Integrated with Starship, Kitty, tmux, and more
- **🚀 Development Ready**: Pre-configured for JavaScript/Node.js, Python, and C#
- **📝 Editor Support**: VS Code and JetBrains IDEs configurations
- **🔄 Automated Setup**: One-command installation and updates
- **💾 Backup & Restore**: Safe configuration management
- **🎨 Customizable**: Modular structure for easy personalization

## 🛠 Supported Tools & Applications

### Shells & Terminals
- **Shell**: zsh with oh-my-zsh
- **Prompt**: Starship
- **Terminals**: Kitty, Windows Terminal
- **Multiplexer**: tmux

### Development Environment
- **Languages**: JavaScript/Node.js, Python, C#/.NET
- **Editors**: VS Code, JetBrains IDEs (IntelliJ, WebStorm, PyCharm, Rider)
- **Version Control**: Git with GitHub CLI integration
- **Package Managers**: Homebrew (macOS), apt (Debian), Chocolatey (Windows)

### Development Tools
- **Node.js**: nvm for version management
- **Python**: pyenv for version management
- **C#**: .NET SDK management
- **Terminal Tools**: fzf, ripgrep, bat, exa, fd

## 🚀 Quick Start

### One-Line Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# IMPORTANT: Update personal information first
# See docs/SETUP.md for required customizations

# Then run the installer
./install/install.sh
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the installer for your platform
./install/install.sh          # Auto-detect platform
./install/macos.sh           # macOS specific
./install/debian.sh          # Debian/Ubuntu specific
./install/windows.ps1        # Windows PowerShell
```

## 📁 Structure

```
dotfiles/
├── install/                 # Installation scripts
│   ├── install.sh          # Main cross-platform installer
│   ├── macos.sh           # macOS-specific setup
│   ├── debian.sh          # Debian/Ubuntu setup
│   ├── windows.ps1        # Windows PowerShell setup
│   └── common.sh          # Shared installation functions
├── config/                 # Configuration files
│   ├── shell/             # Shell configurations
│   │   ├── zsh/           # Zsh configuration and plugins
│   │   └── starship/      # Starship prompt configuration
│   ├── terminal/          # Terminal emulator configs
│   │   ├── kitty/         # Kitty terminal configuration
│   │   └── windows-terminal/ # Windows Terminal settings
│   ├── editors/           # Editor configurations
│   │   ├── vscode/        # VS Code settings and extensions
│   │   └── jetbrains/     # JetBrains IDEs configurations
│   ├── git/              # Git configuration and aliases
│   ├── tmux/             # tmux configuration and plugins
│   └── development/      # Development environment configs
│       ├── node/         # Node.js and npm configuration
│       ├── python/       # Python and pip configuration
│       └── dotnet/       # .NET configuration
├── scripts/               # Utility scripts
│   ├── backup.sh         # Backup existing configurations
│   ├── restore.sh        # Restore from backup
│   ├── update.sh         # Update dotfiles and tools
│   └── validate.sh       # Validate installation
├── docs/                 # Documentation
│   ├── SETUP.md          # Required setup after cloning
│   ├── CUSTOMIZATION.md  # How to customize configurations
│   ├── TROUBLESHOOTING.md # Common issues and solutions
│   └── PLATFORMS.md      # Platform-specific notes
└── README.md            # This file
```

## 🔧 Setup & Customization

**First time setup:** See [docs/SETUP.md](docs/SETUP.md) for required personal information updates.

**Advanced customization:** See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for detailed customization instructions.

## 🆘 Troubleshooting

Having issues? Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common solutions.

## 📋 Requirements

### macOS
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools

### Debian/Ubuntu
- Debian 10+ or Ubuntu 18.04+
- sudo access

### Windows
- Windows 10/11
- PowerShell 5.1+ or PowerShell Core 7+
- Windows Subsystem for Linux (WSL2) recommended

## 🔄 Updating

```bash
cd ~/.dotfiles
./scripts/update.sh
```

## 💾 Backup & Restore

```bash
# Backup current configurations
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test across platforms
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [Starship](https://starship.rs/) - Cross-shell prompt
- [oh-my-zsh](https://ohmyz.sh/) - Zsh framework
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Terminal emulator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

---

**Made with ❤️**