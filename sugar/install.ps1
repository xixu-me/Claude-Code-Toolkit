#Requires -Version 5.1

<#
.SYNOPSIS
    Claude Code Sugar Installation Script for Windows
    
.DESCRIPTION
    This script automatically installs Claude Code Sugar, a proxy tool for accessing
    AI models through ModelScope API. It handles Node.js installation, package 
    installation, and configuration setup.
    
.PARAMETER Force
    Forces reinstallation even if Claude Code is already installed
    
.EXAMPLE
    .\install.ps1
    Standard installation
    
.EXAMPLE
    .\install.ps1 -Force
    Force reinstallation
    
.NOTES
    Author: Claude Code Sugar Team
    Version: 1.0.0
    Last Updated: 2025-08-16
    
    Requirements:
    - PowerShell 5.1 or later
    - Windows 10/11 or Windows Server 2016+
    - Internet connection
    - Administrator privileges (recommended)
    
    This script will:
    1. Install Node.js (v18+) if not present
    2. Install claude-code-sugar package globally
    3. Configure ModelScope API integration
    4. Set up PATH environment variables
    
.LINK
    https://github.com/xixu-me/claude-code-sugar
#>

param(
    [switch]$Force
)

# ============================================================================
# SCRIPT CONFIGURATION AND CONSTANTS
# ============================================================================

$ErrorActionPreference = "Stop"

# Configuration constants
$REQUIRED_NODE_MAJOR_VERSION = 18
$TARGET_NODE_VERSION = "22.17.0"
$NPM_REGISTRY = "https://xget.xi-xu.me/npm/"
$PACKAGE_NAME = "claude-code-sugar"
$MODELSCOPE_API_URL = "https://api-inference.modelscope.cn/v1"
$MODELSCOPE_TOKEN_URL = "https://modelscope.cn/my/myaccesstoken"

# Default model mappings
$DEFAULT_MODEL_MAPPINGS = @{
    "claude-3-5-haiku-20241022" = "Qwen/Qwen3-Coder-480B-A35B-Instruct"
    "claude-sonnet-4-20250514"  = "Qwen/Qwen3-Coder-480B-A35B-Instruct"
    "claude-opus-4-20250514"    = "Qwen/Qwen3-Coder-480B-A35B-Instruct"
}

# ============================================================================
# CORE FUNCTIONS - NODE.JS INSTALLATION
# ============================================================================

function Install-NodeJS {
    <#
    .SYNOPSIS
        Installs Node.js using available package managers
    .DESCRIPTION
        Attempts to install Node.js v22 using winget first, then falls back to chocolatey
    #>
    
    Write-Host "🚀 Installing Node.js on Windows..." -ForegroundColor Green
    
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "📦 Installing Node.js v$TARGET_NODE_VERSION using winget..." -ForegroundColor Yellow
        try {
            winget install OpenJS.NodeJS --version $TARGET_NODE_VERSION --silent --accept-package-agreements --accept-source-agreements
        }
        catch {
            Write-Host "⚠️  winget installation failed, trying chocolatey..." -ForegroundColor Yellow
            Install-NodeJSChocolatey
        }
    }
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Install-NodeJSChocolatey
    }
    else {
        Write-Host "❌ Neither winget nor chocolatey found." -ForegroundColor Red
        Write-Host "📝 Please install Node.js manually from: https://nodejs.org/" -ForegroundColor Yellow
        Write-Host "   Or install chocolatey first: https://chocolatey.org/install" -ForegroundColor Yellow
        exit 1
    }
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Host "✅ Node.js installation completed! Version: $(node -v)" -ForegroundColor Green
    Write-Host "✅ npm version: $(npm -v)" -ForegroundColor Green
}

function Install-NodeJSChocolatey {
    <#
    .SYNOPSIS
        Installs Node.js using chocolatey package manager
    #>
    
    Write-Host "📦 Installing Node.js v$TARGET_NODE_VERSION using chocolatey..." -ForegroundColor Yellow
    choco install nodejs --version=$TARGET_NODE_VERSION -y
}

function Test-NodeVersion {
    <#
    .SYNOPSIS
        Tests if the installed Node.js version meets minimum requirements
    .PARAMETER Version
        The version string to test (e.g., "v18.17.0")
    .OUTPUTS
        Boolean indicating if version is adequate
    #>
    
    param([string]$Version)
    
    if ($Version -match '^v?(\d+)\.') {
        $majorVersion = [int]$matches[1]
        return $majorVersion -ge $REQUIRED_NODE_MAJOR_VERSION
    }
    return $false
}

# ============================================================================
# MAIN EXECUTION - NODE.JS VERIFICATION AND INSTALLATION
# ============================================================================

Write-Host "🔍 Checking Node.js installation..." -ForegroundColor Cyan

# Check if Node.js is already installed and version is >= 18
try {
    $currentVersion = node -v 2>$null
    if ($currentVersion -and (Test-NodeVersion $currentVersion)) {
        Write-Host "✅ Node.js is already installed: $currentVersion" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Node.js $currentVersion is installed but version < v$REQUIRED_NODE_MAJOR_VERSION. Upgrading..." -ForegroundColor Yellow
        Install-NodeJS
    }
}
catch {
    Write-Host "⚠️  Node.js not found. Installing..." -ForegroundColor Yellow
    Install-NodeJS
}

# ============================================================================
# CLAUDE CODE SUGAR INSTALLATION
# ============================================================================

Write-Host "🔍 Checking Claude Code Sugar installation..." -ForegroundColor Cyan

# Check if Claude Code is already installed
try {
    $claudeVersion = claude --version 2>$null
    if ($claudeVersion -and !$Force) {
        Write-Host "✅ Claude Code Sugar is already installed: $claudeVersion" -ForegroundColor Green
        Write-Host "💡 If you want to reinstall, please uninstall first with:" -ForegroundColor Yellow
        Write-Host "   npm uninstall -g @anthropic-ai/claude-code" -ForegroundColor White
        Write-Host "   Or run this script with -Force parameter" -ForegroundColor White
        Write-Host ""
        Write-Host "🚪 Installation script exiting..." -ForegroundColor Yellow
        exit 0
    }
}
catch {
    Write-Host "⚠️  Claude Code Sugar not found. Installing..." -ForegroundColor Yellow
}

# Install Claude Code Sugar
Write-Host "📦 Installing $PACKAGE_NAME..." -ForegroundColor Yellow
npm install -g $PACKAGE_NAME --registry=$NPM_REGISTRY

# ============================================================================
# CONFIGURATION SETUP
# ============================================================================

Write-Host "🔧 Setting up Claude Code configuration..." -ForegroundColor Cyan

# Get npm global directory for PATH configuration
Write-Host "🔍 Detecting npm global directory..." -ForegroundColor Yellow
try {
    $npmPrefix = npm config get prefix
    $npmBinDir = Join-Path $npmPrefix "bin"
    Write-Host "📁 npm global directory: $npmPrefix" -ForegroundColor Green
}
catch {
    Write-Host "⚠️  Could not detect npm global directory" -ForegroundColor Yellow
    $npmBinDir = ""
}

# Configure Claude Code to skip onboarding
Write-Host "🔧 Configuring Claude Code onboarding..." -ForegroundColor Yellow
$homeDir = $env:USERPROFILE
$claudeConfigPath = Join-Path $homeDir ".claude.json"

if (Test-Path $claudeConfigPath) {
    $content = Get-Content $claudeConfigPath -Raw | ConvertFrom-Json
    $content | Add-Member -Name "hasCompletedOnboarding" -Value $true -MemberType NoteProperty -Force
    $content | ConvertTo-Json -Depth 10 | Set-Content $claudeConfigPath -Encoding UTF8
}
else {
    @{ hasCompletedOnboarding = $true } | ConvertTo-Json | Set-Content $claudeConfigPath -Encoding UTF8
}

# ============================================================================
# API KEY COLLECTION AND VALIDATION
# ============================================================================

Write-Host ""
Write-Host "🔑 ModelScope API Configuration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Please enter your ModelScope token:" -ForegroundColor Cyan
Write-Host "📍 Get your token from: $MODELSCOPE_TOKEN_URL" -ForegroundColor Yellow
Write-Host "🔒 Note: Input is hidden for security. Paste your token and press Enter." -ForegroundColor Yellow
Write-Host ""

$apiKey = Read-Host -AsSecureString "Token"
$apiKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey))

if ([string]::IsNullOrWhiteSpace($apiKeyPlain)) {
    Write-Host "❌ ModelScope token cannot be empty. Please run the script again." -ForegroundColor Red
    exit 1
}

Write-Host "✅ ModelScope token received successfully" -ForegroundColor Green

# ============================================================================
# PROXY CONFIGURATION FILE GENERATION
# ============================================================================

Write-Host "📄 Creating proxy configuration file..." -ForegroundColor Yellow
$proxyConfigDir = Join-Path $env:USERPROFILE ".config\$PACKAGE_NAME"
$proxyConfigFile = Join-Path $proxyConfigDir "config.json"

# Create directory if it doesn't exist
if (!(Test-Path $proxyConfigDir)) {
    New-Item -ItemType Directory -Path $proxyConfigDir -Force | Out-Null
}

# Create proxy config JSON with user's API key
$proxyConfig = @{
    baseURL      = $MODELSCOPE_API_URL
    apiKey       = $apiKeyPlain
    modelMapping = $DEFAULT_MODEL_MAPPINGS
}

$proxyConfig | ConvertTo-Json -Depth 10 | Set-Content $proxyConfigFile -Encoding UTF8
Write-Host "✅ Proxy configuration created at $proxyConfigFile" -ForegroundColor Green
Write-Host "💡 You can modify model mappings by editing this configuration file" -ForegroundColor Yellow

# ============================================================================
# PATH ENVIRONMENT SETUP
# ============================================================================

Write-Host "🔧 Configuring system PATH..." -ForegroundColor Cyan

# Check if claude command is available
$claudeAvailable = $false
try {
    claude --version | Out-Null
    $claudeAvailable = $true
}
catch {
    Write-Host "🔧 claude command not found in PATH..." -ForegroundColor Yellow
}

# Add npm global directory to PATH if needed
if (!$claudeAvailable -and $npmBinDir) {
    Write-Host "🔧 Adding npm global directory to PATH..." -ForegroundColor Yellow
    
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$npmPrefix*") {
        $newPath = "$currentPath;$npmPrefix"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$env:Path;$npmPrefix"
        Write-Host "✅ Added $npmPrefix to user PATH" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  PATH already contains $npmPrefix. Skipping..." -ForegroundColor Yellow
    }
}

# ============================================================================
# INSTALLATION COMPLETION AND VERIFICATION
# ============================================================================

Write-Host ""
Write-Host "🎉 Installation Process Completed!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Provide restart instructions
Write-Host "🔄 Environment Setup Instructions:" -ForegroundColor Cyan
Write-Host "   Please restart your PowerShell/Command Prompt or run:" -ForegroundColor Yellow
Write-Host "   refreshenv" -ForegroundColor White
Write-Host "   (if you have chocolatey installed)" -ForegroundColor Gray
Write-Host ""

# Final verification attempt
Write-Host "🔍 Verifying Claude Code Sugar installation..." -ForegroundColor Yellow
try {
    $claudeVersion = claude --version 2>$null
    if ($claudeVersion) {
        Write-Host "✅ claude command is available: $claudeVersion" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Ready to use! Start Claude Code Sugar with:" -ForegroundColor Cyan
        Write-Host "   claude" -ForegroundColor White
        Write-Host ""
        Write-Host "📖 For help and documentation:" -ForegroundColor Cyan
        Write-Host "   claude --help" -ForegroundColor White
    }
    else {
        throw "Command not found"
    }
}
catch {
    Write-Host "⚠️  claude command not found in current session." -ForegroundColor Yellow
    Write-Host "   Please restart your terminal and try:" -ForegroundColor Yellow
    Write-Host "   claude --version" -ForegroundColor White
    Write-Host ""
    Write-Host "� If still not working, manually add to PATH:" -ForegroundColor Cyan
    if ($npmPrefix) {
        Write-Host "   `$env:Path += `";$npmPrefix`"" -ForegroundColor White
    }
    Write-Host "   claude" -ForegroundColor White
}

# ============================================================================
# SECURITY CLEANUP
# ============================================================================

# Clear sensitive data from memory
Write-Host "🔒 Cleaning up sensitive data..." -ForegroundColor Yellow
$apiKeyPlain = $null
$apiKey = $null
[System.GC]::Collect()

Write-Host ""
Write-Host "✨ Claude Code Sugar installation completed successfully!" -ForegroundColor Green
Write-Host "🙏 Thank you for using Claude Code Sugar!" -ForegroundColor Cyan