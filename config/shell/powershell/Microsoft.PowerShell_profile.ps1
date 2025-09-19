# PowerShell Profile Configuration
# Modern PowerShell configuration for Windows

# ===== MODULES AND IMPORTS =====

# Import required modules
Import-Module PSReadLine -ErrorAction SilentlyContinue

# ===== PSREADLINE CONFIGURATION =====

if (Get-Module PSReadLine) {
    # Set edit mode to Emacs (or Vi if you prefer)
    Set-PSReadLineOption -EditMode Emacs
    
    # History configuration
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 4000
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    
    # Prediction and completion
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    
    # Key bindings
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    
    # Colors
    Set-PSReadLineOption -Colors @{
        Command            = 'Yellow'
        Parameter          = 'Green'
        Operator           = 'Magenta'
        Variable           = 'Green'
        String             = 'Blue'
        Number             = 'Blue'
        Type               = 'Cyan'
        Comment            = 'DarkGreen'
        Keyword            = 'Yellow'
        Error              = 'Red'
        Selection          = 'DarkGray'
        InlinePrediction   = 'DarkGray'
    }
}

# ===== ALIASES =====

# Navigation aliases
Set-Alias -Name ll -Value Get-ChildItemLong
Set-Alias -Name la -Value Get-ChildItemAll
Set-Alias -Name .. -Value Set-LocationUp
Set-Alias -Name ... -Value Set-LocationUp2
Set-Alias -Name .... -Value Set-LocationUp3

# Git aliases
Set-Alias -Name g -Value git
Set-Alias -Name gst -Value 'git status'
Set-Alias -Name gco -Value 'git checkout'
Set-Alias -Name gp -Value 'git push'
Set-Alias -Name gpl -Value 'git pull'

# Docker aliases
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose

# Development aliases
Set-Alias -Name py -Value python
Set-Alias -Name pip -Value pip3
Set-Alias -Name code -Value 'code.cmd'

# System aliases
Set-Alias -Name which -Value Get-Command
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item

# ===== FUNCTIONS =====

# Enhanced directory listing
function Get-ChildItemLong {
    Get-ChildItem -Force | Format-Table -AutoSize
}

function Get-ChildItemAll {
    Get-ChildItem -Force -Hidden | Format-Table -AutoSize
}

# Navigation functions
function Set-LocationUp { Set-Location .. }
function Set-LocationUp2 { Set-Location ../.. }
function Set-LocationUp3 { Set-Location ../../.. }

# Create directory and navigate to it
function New-DirectoryAndEnter {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}
Set-Alias -Name mkcd -Value New-DirectoryAndEnter

# Get public IP address
function Get-PublicIP {
    try {
        $ip = Invoke-RestMethod -Uri "https://ipinfo.io/ip" -TimeoutSec 5
        Write-Output "Public IP: $ip"
    }
    catch {
        Write-Error "Failed to get public IP address"
    }
}
Set-Alias -Name myip -Value Get-PublicIP

# Get local IP address
function Get-LocalIP {
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object IPAddress, InterfaceAlias
}
Set-Alias -Name localip -Value Get-LocalIP

# Weather function
function Get-Weather {
    param([string]$Location = "")
    try {
        $uri = if ($Location) { "https://wttr.in/$Location" } else { "https://wttr.in/" }
        Invoke-RestMethod -Uri $uri
    }
    catch {
        Write-Error "Failed to get weather information"
    }
}
Set-Alias -Name weather -Value Get-Weather

# System information
function Get-SystemInfo {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    
    Write-Host "System Information:" -ForegroundColor Cyan
    Write-Host "OS: $($os.Caption) $($os.Version)" -ForegroundColor Yellow
    Write-Host "CPU: $($cpu.Name)" -ForegroundColor Yellow
    Write-Host "Memory: $([math]::Round($memory.Sum / 1GB, 2)) GB" -ForegroundColor Yellow
    Write-Host "Uptime: $((Get-Date) - $os.LastBootUpTime)" -ForegroundColor Yellow
}
Set-Alias -Name sysinfo -Value Get-SystemInfo

# Find files
function Find-Files {
    param(
        [string]$Name,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Recurse -Name "*$Name*" -ErrorAction SilentlyContinue
}
Set-Alias -Name find -Value Find-Files

# Kill process by name
function Stop-ProcessByName {
    param([string]$Name)
    Get-Process -Name "*$Name*" | Stop-Process -Force
}
Set-Alias -Name killp -Value Stop-ProcessByName

# Reload PowerShell profile
function Invoke-ProfileReload {
    & $PROFILE
    Write-Host "PowerShell profile reloaded!" -ForegroundColor Green
}
Set-Alias -Name reload -Value Invoke-ProfileReload

# Open current directory in File Explorer
function Open-CurrentDirectory {
    Start-Process explorer.exe -ArgumentList "."
}
Set-Alias -Name open -Value Open-CurrentDirectory

# ===== ENVIRONMENT VARIABLES =====

# Add local bin to PATH if it exists
$LocalBin = "$env:USERPROFILE\.local\bin"
if (Test-Path $LocalBin) {
    $env:PATH = "$LocalBin;$env:PATH"
}

# Node.js configuration
$env:NPM_CONFIG_PREFIX = "$env:USERPROFILE\.npm-global"
if (Test-Path "$env:USERPROFILE\.npm-global\bin") {
    $env:PATH = "$env:USERPROFILE\.npm-global\bin;$env:PATH"
}

# Python configuration
$env:PYTHONIOENCODING = "utf-8"

# .NET configuration
$env:DOTNET_CLI_TELEMETRY_OPTOUT = "1"

# ===== STARSHIP PROMPT =====

# Initialize Starship prompt if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ===== WELCOME MESSAGE =====

function Show-WelcomeMessage {
    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME
    $psVersion = $PSVersionTable.PSVersion.ToString()
    $date = Get-Date -Format "dddd, MMMM dd, yyyy"
    
    Write-Host ""
    Write-Host "Welcome back, " -NoNewline -ForegroundColor Cyan
    Write-Host $user -NoNewline -ForegroundColor Yellow
    Write-Host "!" -ForegroundColor Cyan
    Write-Host "Computer: " -NoNewline -ForegroundColor Cyan
    Write-Host $computer -ForegroundColor Yellow
    Write-Host "PowerShell: " -NoNewline -ForegroundColor Cyan
    Write-Host $psVersion -ForegroundColor Yellow
    Write-Host "Date: " -NoNewline -ForegroundColor Cyan
    Write-Host $date -ForegroundColor Yellow
    Write-Host ""
}

# Show welcome message on startup
Show-WelcomeMessage

# ===== LOAD LOCAL CONFIGURATION =====

# Load local PowerShell configuration if it exists
$LocalProfile = "$env:USERPROFILE\.config\powershell\local_profile.ps1"
if (Test-Path $LocalProfile) {
    . $LocalProfile
}
