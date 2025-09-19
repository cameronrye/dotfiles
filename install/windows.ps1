# Windows PowerShell installation script
# Installs Chocolatey, packages, and Windows-specific configurations

param(
    [switch]$Force,
    [switch]$SkipWSL
)

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Colors for output
$Colors = @{
    Red    = 'Red'
    Green  = 'Green'
    Yellow = 'Yellow'
    Blue   = 'Blue'
    Purple = 'Magenta'
    Cyan   = 'Cyan'
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $color = switch ($Level) {
        'Info'    { $Colors.Blue }
        'Success' { $Colors.Green }
        'Warning' { $Colors.Yellow }
        'Error'   { $Colors.Red }
        default   { $Colors.Blue }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Chocolatey {
    Write-Log "Checking for Chocolatey..."
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Log "Chocolatey already installed" -Level Success
        return
    }
    
    Write-Log "Installing Chocolatey..."
    
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Log "Chocolatey installed successfully" -Level Success
}

function Install-Packages {
    Write-Log "Installing Chocolatey packages..."
    
    $packages = @(
        # Development tools
        'git',
        'nodejs',
        'python',
        'dotnet-sdk',
        'gh',                    # GitHub CLI
        
        # Editors and IDEs
        'vscode',
        'jetbrainstoolbox',
        
        # Terminal and shell tools
        'starship',
        'fzf',
        'ripgrep',
        'bat',
        'fd',
        'jq',
        
        # Utilities
        '7zip',
        'curl',
        'wget',
        'unzip',
        
        # Fonts
        'firacode-ttf',
        'jetbrainsmono',
        
        # Optional tools (uncomment if needed)
        # 'docker-desktop',
        # 'postman',
        # 'slack',
        # 'discord'
    )
    
    foreach ($package in $packages) {
        Write-Log "Installing $package..."
        try {
            choco install $package -y --no-progress
            Write-Log "$package installed successfully" -Level Success
        }
        catch {
            Write-Log "Failed to install $package: $_" -Level Error
        }
    }
    
    Write-Log "Package installation complete" -Level Success
}

function Install-WSL {
    if ($SkipWSL) {
        Write-Log "Skipping WSL installation (--SkipWSL flag provided)"
        return
    }
    
    Write-Log "Checking WSL installation..."
    
    # Check if WSL is already installed
    $wslStatus = wsl --status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "WSL already installed" -Level Success
        return
    }
    
    Write-Log "Installing WSL..."
    
    try {
        # Install WSL
        wsl --install --distribution Ubuntu
        
        Write-Log "WSL installed successfully" -Level Success
        Write-Log "Please restart your computer and run 'wsl' to complete Ubuntu setup" -Level Warning
    }
    catch {
        Write-Log "Failed to install WSL: $_" -Level Error
        Write-Log "You may need to enable virtualization in BIOS" -Level Warning
    }
}

function Setup-WindowsTerminal {
    Write-Log "Setting up Windows Terminal configuration..."
    
    $terminalConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $dotfilesConfigPath = Join-Path $PSScriptRoot "..\config\terminal\windows-terminal"
    
    if (Test-Path $terminalConfigPath) {
        # Backup existing settings
        $backupPath = "$terminalConfigPath\settings_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        if (Test-Path "$terminalConfigPath\settings.json") {
            Copy-Item "$terminalConfigPath\settings.json" $backupPath
            Write-Log "Backed up existing Windows Terminal settings to $backupPath"
        }
        
        # Create symlink to dotfiles config
        $sourceConfig = Join-Path $dotfilesConfigPath "settings.json"
        $targetConfig = Join-Path $terminalConfigPath "settings.json"
        
        if (Test-Path $sourceConfig) {
            # Remove existing file
            if (Test-Path $targetConfig) {
                Remove-Item $targetConfig -Force
            }
            
            # Create symlink
            New-Item -ItemType SymbolicLink -Path $targetConfig -Target $sourceConfig -Force
            Write-Log "Windows Terminal configuration linked" -Level Success
        }
    } else {
        Write-Log "Windows Terminal not found, skipping configuration" -Level Warning
    }
}

function Setup-PowerShellProfile {
    Write-Log "Setting up PowerShell profile..."
    
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path $profilePath -Parent
    $dotfilesProfilePath = Join-Path $PSScriptRoot "..\config\shell\powershell\Microsoft.PowerShell_profile.ps1"
    
    # Create profile directory if it doesn't exist
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force
    }
    
    # Backup existing profile
    if (Test-Path $profilePath) {
        $backupPath = "$profilePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $profilePath $backupPath
        Write-Log "Backed up existing PowerShell profile to $backupPath"
    }
    
    # Create symlink to dotfiles profile
    if (Test-Path $dotfilesProfilePath) {
        if (Test-Path $profilePath) {
            Remove-Item $profilePath -Force
        }
        
        New-Item -ItemType SymbolicLink -Path $profilePath -Target $dotfilesProfilePath -Force
        Write-Log "PowerShell profile linked" -Level Success
    }
}

function Setup-GitConfiguration {
    Write-Log "Setting up Git configuration..."
    
    $gitConfigPath = "$env:USERPROFILE\.gitconfig"
    $dotfilesGitConfigPath = Join-Path $PSScriptRoot "..\config\git\.gitconfig"
    
    # Backup existing git config
    if (Test-Path $gitConfigPath) {
        $backupPath = "$gitConfigPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $gitConfigPath $backupPath
        Write-Log "Backed up existing Git configuration to $backupPath"
    }
    
    # Create symlink to dotfiles git config
    if (Test-Path $dotfilesGitConfigPath) {
        if (Test-Path $gitConfigPath) {
            Remove-Item $gitConfigPath -Force
        }
        
        New-Item -ItemType SymbolicLink -Path $gitConfigPath -Target $dotfilesGitConfigPath -Force
        Write-Log "Git configuration linked" -Level Success
    }
}

function Setup-VSCodeConfiguration {
    Write-Log "Setting up VS Code configuration..."
    
    $vscodeConfigPath = "$env:APPDATA\Code\User"
    $dotfilesVSCodePath = Join-Path $PSScriptRoot "..\config\editors\vscode"
    
    if (Test-Path $vscodeConfigPath) {
        # Backup existing settings
        $settingsPath = Join-Path $vscodeConfigPath "settings.json"
        if (Test-Path $settingsPath) {
            $backupPath = "$settingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $settingsPath $backupPath
            Write-Log "Backed up existing VS Code settings to $backupPath"
        }
        
        # Create symlinks for VS Code configuration files
        $configFiles = @('settings.json', 'keybindings.json', 'snippets')
        
        foreach ($configFile in $configFiles) {
            $sourcePath = Join-Path $dotfilesVSCodePath $configFile
            $targetPath = Join-Path $vscodeConfigPath $configFile
            
            if (Test-Path $sourcePath) {
                if (Test-Path $targetPath) {
                    Remove-Item $targetPath -Recurse -Force
                }
                
                New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
                Write-Log "VS Code $configFile linked" -Level Success
            }
        }
    } else {
        Write-Log "VS Code not found, skipping configuration" -Level Warning
    }
}

function Show-Banner {
    Write-Host @"
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                    
Modern Cross-Platform Dotfiles Management System
Windows PowerShell Installation Script
"@ -ForegroundColor Cyan
}

function Main {
    Show-Banner
    
    # Check if running as administrator
    if (!(Test-Administrator)) {
        Write-Log "This script requires administrator privileges" -Level Error
        Write-Log "Please run PowerShell as Administrator and try again" -Level Error
        exit 1
    }
    
    Write-Log "Starting Windows-specific setup..."
    
    # Install Chocolatey
    Install-Chocolatey
    
    # Install packages
    Install-Packages
    
    # Install WSL
    Install-WSL
    
    # Setup configurations
    Setup-WindowsTerminal
    Setup-PowerShellProfile
    Setup-GitConfiguration
    Setup-VSCodeConfiguration
    
    Write-Log "Windows-specific setup complete!" -Level Success
    Write-Log "Please restart your terminal to apply all changes" -Level Warning
    
    if (!$SkipWSL) {
        Write-Log "After restart, run 'wsl' to complete Ubuntu setup in WSL" -Level Warning
        Write-Log "Then run the dotfiles installer inside WSL for the full experience" -Level Warning
    }
}

# Run main function
Main
