# Claude Code Toolkit (CCT)
# A comprehensive script to manage Claude Code installation, configuration, and providers

# Script constants
$CLAUDE_DIR = "$HOME\.claude"
$PROVIDERS_FILE = "$CLAUDE_DIR\providers.json"
$DEFAULT_PROVIDER_NAME = "Moonshot AI"
$DEFAULT_BASE_URL = "https://api.moonshot.cn/anthropic/"
$REQUIRED_NODE_VERSION = 18
$CLAUDE_PACKAGE = "@anthropic-ai/claude-code"

# Color helper functions for consistent output
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Blue }
function Write-Progress { param($Message) Write-Host "→ $Message" -ForegroundColor Cyan }
function Write-Prompt { param($Message) Write-Host "$Message" -ForegroundColor White }

# Create Claude directory if it doesn't exist
function Ensure-ClaudeDir {
    if (-not (Test-Path $CLAUDE_DIR)) {
        New-Item -ItemType Directory -Path $CLAUDE_DIR -Force | Out-Null
        Write-Success "Created directory: $CLAUDE_DIR"
    }
}

# Check if Node.js is installed and meets version requirement
function Check-NodeJs {
    try {
        $nodeVersion = node -v
        if ($nodeVersion -match 'v(\d+)') {
            $majorVersion = [int]$Matches[1]
            if ($majorVersion -lt $REQUIRED_NODE_VERSION) {
                Write-Error "Node.js version $majorVersion is installed, but version $REQUIRED_NODE_VERSION+ is required."
                return $false
            }
            Write-Success "Node.js version $nodeVersion is installed."
            return $true
        }
    }
    catch {
        Write-Error "Node.js is not installed."
        return $false
    }
    return $false
}

# Check if npm is installed
function Check-Npm {
    try {
        $npmVersion = npm -v
        Write-Success "npm version $npmVersion is installed."
        return $true
    }
    catch {
        Write-Error "npm is not installed."
        return $false
    }
}

# Install Node.js using available package managers
function Install-NodeJs {
    Write-Progress "Installing Node.js..."
    
    # Check if package managers are available
    $useChoco = $false
    $useWinget = $false
    
    try {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            $useChoco = $true
        }
        elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            $useWinget = $true
        }
    }
    catch {
        # Commands not available
    }
    
    if ($useChoco) {
        Write-Progress "Installing Node.js using Chocolatey..."
        choco install nodejs -y
    }
    elseif ($useWinget) {
        Write-Progress "Installing Node.js using Winget..."
        winget install OpenJS.NodeJS
    }
    else {
        Write-Error "No package manager found. Please install Node.js manually from https://nodejs.org/"
        Write-Info "After installation, restart this script."
        exit 1
    }
    
    # Verify Node.js installation
    if (-not (Check-NodeJs)) {
        Write-Error "Failed to install Node.js. Please install it manually."
        exit 1
    }
}

# Install the Claude Code package via npm
function Install-ClaudeCode {
    Write-Progress "Installing $CLAUDE_PACKAGE..."
    npm install -g $CLAUDE_PACKAGE
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install $CLAUDE_PACKAGE. Please check your npm configuration."
        exit 1
    }
    
    Write-Success "$CLAUDE_PACKAGE installed successfully."
    
    # Configure Claude Code to skip the onboarding process
    Write-Progress "Configuring Claude Code to skip onboarding..."
    node --eval "
        const fs = require('fs');
        const os = require('os');
        const path = require('path');
        const homeDir = os.homedir(); 
        const filePath = path.join(homeDir, '.claude.json');
        if (fs.existsSync(filePath)) {
            const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
            fs.writeFileSync(filePath, JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2), 'utf-8');
        } else {
            fs.writeFileSync(filePath, JSON.stringify({ hasCompletedOnboarding: true }, null, 2), 'utf-8');
        }
    "
}

# Check if providers.json exists, if not create it
function Ensure-ProvidersJson {
    Ensure-ClaudeDir
    
    if (-not (Test-Path $PROVIDERS_FILE)) {
        "{}" | Out-File -FilePath $PROVIDERS_FILE -Encoding utf8 -Force
    }
    
    # Verify providers file was created successfully
    if (-not (Test-Path $PROVIDERS_FILE)) {
        Write-Error "Could not create providers file at $PROVIDERS_FILE"
        exit 1
    }
}

# Add a provider to providers.json
function Add-ProviderToJson {
    param(
        [string]$providerName,
        [string]$baseUrl,
        [string]$apiKey
    )
    
    Ensure-ProvidersJson
    
    try {
        $providers = Get-Content -Path $PROVIDERS_FILE -Raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Write-Warning "Providers file is corrupted, recreating..."
        $providers = [PSCustomObject]@{}
        # Recreate the providers file
        $providers | ConvertTo-Json -Depth 10 | Out-File -FilePath $PROVIDERS_FILE -Encoding utf8
    }
    
    # Convert to PSCustomObject if it's not already
    if ($providers -isnot [PSCustomObject]) {
        $providers = [PSCustomObject]@{}
    }
    
    # Add the new provider
    $providerObj = [PSCustomObject]@{
        base_url = $baseUrl
        api_key  = $apiKey
    }
    
    # Add property to the object
    $providers | Add-Member -NotePropertyName $providerName -NotePropertyValue $providerObj -Force
    
    # Write updated providers back to file
    $providers | ConvertTo-Json -Depth 10 | Out-File -FilePath $PROVIDERS_FILE -Encoding utf8
    
    Write-Success "Provider '$providerName' added successfully."
}

# Get provider details from providers.json or built-in providers
function Get-ProviderDetails {
    param(
        [string]$providerName
    )
    
    # Handle built-in "Anthropic" provider
    if ($providerName -eq "Anthropic") {
        return [PSCustomObject]@{
            base_url = ""
            api_key  = ""
        }
    }
    
    if (-not (Test-Path $PROVIDERS_FILE)) {
        Write-Error "Providers file not found."
        return $null
    }
    
    try {
        $providers = Get-Content -Path $PROVIDERS_FILE -Raw | ConvertFrom-Json -ErrorAction Stop
        
        # Access the provider using PSCustomObject member access
        $provider = $providers.$providerName
        
        if ($null -eq $provider) {
            Write-Error "Provider '$providerName' not found."
            return $null
        }
        
        return $provider
    }
    catch {
        Write-Error "Error reading providers file: $_"
        return $null
    }
}

# Update environment variables
function Update-EnvVars {
    param(
        [string]$baseUrl,
        [string]$apiKey
    )
    
    # For Anthropic provider, clear environment variables to use defaults
    if ([string]::IsNullOrEmpty($baseUrl) -and [string]::IsNullOrEmpty($apiKey)) {
        Remove-EnvVars
        Write-Success "Environment variables cleared (using Anthropic defaults)."
        return
    }
    
    # Set environment variables for the current PowerShell session
    $env:ANTHROPIC_BASE_URL = $baseUrl
    $env:ANTHROPIC_API_KEY = $apiKey
    
    # Set environment variables permanently for the current user
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $baseUrl, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $apiKey, "User")
    
    Write-Success "Environment variables updated."
    Write-Info "Please restart your terminal or applications for changes to take effect."
}

# Remove Claude Code environment variables
function Remove-EnvVars {
    # Remove from current PowerShell session
    $env:ANTHROPIC_BASE_URL = $null
    $env:ANTHROPIC_API_KEY = $null
    
    # Remove permanently from user environment
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $null, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $null, "User")
    
    Write-Success "Environment variables removed."
}

# Check if Claude Code is installed
function Check-ClaudeCode {
    try {
        $npmList = npm list -g $CLAUDE_PACKAGE
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$CLAUDE_PACKAGE is installed."
            return $true
        }
        else {
            Write-Error "$CLAUDE_PACKAGE is not installed."
            return $false
        }
    }
    catch {
        Write-Error "$CLAUDE_PACKAGE is not installed."
        return $false
    }
}

# Get current provider from environment variables
function Get-CurrentProvider {
    $baseUrl = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
    $apiKey = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_API_KEY", "User")
    
    # Check if using Anthropic defaults (no base URL configured)
    if ([string]::IsNullOrEmpty($baseUrl)) {
        Write-Host "Current provider: Anthropic (using official API defaults)"
        return
    }
    
    # Try to identify the provider by matching base URL
    if (Test-Path $PROVIDERS_FILE) {
        try {
            $providers = Get-Content -Path $PROVIDERS_FILE -Raw | ConvertFrom-Json
            
            # Search for provider with matching base_url
            $providerName = "Unknown"
            foreach ($prop in $providers.PSObject.Properties) {
                if ($prop.Value.base_url -eq $baseUrl) {
                    $providerName = $prop.Name
                    break
                }
            }
            
            if ($providerName -ne "Unknown") {
                Write-Host "Current provider: $providerName ($baseUrl)"
                return
            }
        }
        catch {
            # If file reading fails, fall back to showing URL only
        }
    }
    
    Write-Host "Current provider: Unknown ($baseUrl)"
}

# List all available providers
function List-Providers {
    # Verify Claude Code is installed before proceeding
    if (-not (Check-ClaudeCode)) {
        Write-Host "Claude Code is not installed. Would you like to install it now? (y/n)"
        $response = Read-Host
        if ($response -match "^[Yy]") {
            Cmd-Install
            return
        }
        else {
            Write-Host "Operation cancelled. Please install Claude Code first using: .\cct.ps1 install"
            exit 1
        }
    }
    
    Write-Host "Available providers:"
    Write-Host "Anthropic: (using official API defaults)"
    
    if (Test-Path $PROVIDERS_FILE) {
        try {
            $providers = Get-Content -Path $PROVIDERS_FILE -Raw | ConvertFrom-Json
            
            foreach ($prop in $providers.PSObject.Properties) {
                Write-Host "$($prop.Name): $($prop.Value.base_url)"
            }
        }
        catch {
            Write-Error "Error reading providers file: $_"
        }
    }
    else {
        Ensure-ProvidersJson
    }
}

# Install command
function Cmd-Install {
    param(
        [string]$providerName = "",
        [string]$apiKey = "",
        [string]$baseUrl = ""
    )
    
    # Check for named parameters
    if ($args -contains "--base-url" -and $args.Count -gt $args.IndexOf("--base-url") + 1) {
        $baseUrlIndex = $args.IndexOf("--base-url") + 1
        $baseUrl = $args[$baseUrlIndex]
    }
    
    # Check for Node.js and npm prerequisites
    if (-not (Check-NodeJs)) {
        Install-NodeJs
    }
    
    if (-not (Check-Npm)) {
        Write-Error "npm is required but not installed. Please install npm and try again."
        exit 1
    }
    
    # Install Claude Code package
    Install-ClaudeCode
    
    # If no provider specified, prompt user to choose
    if ([string]::IsNullOrEmpty($providerName)) {
        Write-Host "Please choose a provider:"
        Write-Host "1. Anthropic (Official API)"
        Write-Host "2. Moonshot AI (Compatible API with default configuration)"
        Write-Host "3. Custom provider (Enter your own API endpoint)"
        Write-Host ""
        
        do {
            $choice = Read-Host "Enter your choice (1-3)"
        } while ($choice -notin @("1", "2", "3"))
        
        switch ($choice) {
            "1" {
                $providerName = "Anthropic"
                $baseUrl = ""
                $apiKey = ""
            }
            "2" {
                $providerName = $DEFAULT_PROVIDER_NAME
                $baseUrl = $DEFAULT_BASE_URL
            }
            "3" {
                $providerName = Read-Host "Enter provider name"
                $baseUrl = Read-Host "Enter base URL for $providerName"
            }
        }
    }
    
    # Handle Anthropic provider (no additional configuration needed)
    if ($providerName -eq "Anthropic") {
        if ([string]::IsNullOrEmpty($apiKey)) {
            $secureApiKey = Read-Host "Enter your Anthropic API key" -AsSecureString
            $apiKey = [System.Net.NetworkCredential]::new("", $secureApiKey).Password
        }
        
        # For Anthropic, only set the API key environment variable
        # No need to add to providers.json or set base URL
        [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $apiKey, "User")
        $env:ANTHROPIC_API_KEY = $apiKey
        
        Write-Success "Claude Code installed and configured to use Anthropic API."
        return
    }
    
    # Set default base URL for Moonshot AI if not specified
    if ($providerName -eq $DEFAULT_PROVIDER_NAME -and [string]::IsNullOrEmpty($baseUrl)) {
        $baseUrl = $DEFAULT_BASE_URL
    }
    
    # Prompt for missing configuration details
    if ([string]::IsNullOrEmpty($baseUrl)) {
        $baseUrl = Read-Host "Enter base URL for $providerName"
    }
    
    if ([string]::IsNullOrEmpty($apiKey)) {
        $secureApiKey = Read-Host "Enter API key for $providerName" -AsSecureString
        $apiKey = [System.Net.NetworkCredential]::new("", $secureApiKey).Password
    }
    
    # Add provider configuration to providers.json
    Add-ProviderToJson -providerName $providerName -baseUrl $baseUrl -apiKey $apiKey
    
    # Switch to the newly configured provider
    Cmd-Switch -providerName $providerName
    
    Write-Success "Claude Code installed and configured to use $providerName."
}

# Uninstall command - remove Claude Code and all configurations
function Cmd-Uninstall {
    # Remove Claude Code package if installed
    if (Check-ClaudeCode) {
        Write-Progress "Uninstalling $CLAUDE_PACKAGE..."
        npm uninstall -g $CLAUDE_PACKAGE
    }
    
    # Remove environment variables from system
    Remove-EnvVars
    
    # Remove Claude configuration directory
    if (Test-Path $CLAUDE_DIR) {
        Remove-Item -Path $CLAUDE_DIR -Recurse -Force
        Write-Success "Removed $CLAUDE_DIR directory."
    }
    
    # Remove Claude configuration file
    $claudeJsonPath = "$HOME\.claude.json"
    if (Test-Path $claudeJsonPath) {
        Remove-Item -Path $claudeJsonPath -Force
        Write-Success "Removed $claudeJsonPath file."
    }
    
    Write-Success "Claude Code has been uninstalled."
}

# Update command - upgrade Claude Code to latest version
function Cmd-Update {
    # Verify Claude Code is installed before attempting update
    if (-not (Check-ClaudeCode)) {
        Write-Host "Claude Code is not installed. Would you like to install it now? (y/n)"
        $response = Read-Host
        if ($response -match "^[Yy]") {
            Cmd-Install
            return
        }
        else {
            Write-Host "Update cancelled. Please install Claude Code first using: .\cct.ps1 install"
            exit 1
        }
    }
    
    Write-Progress "Updating $CLAUDE_PACKAGE..."
    npm update -g $CLAUDE_PACKAGE
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to update $CLAUDE_PACKAGE."
        exit 1
    }
    
    Write-Success "$CLAUDE_PACKAGE has been updated to the latest version."
}

# Check command - verify system requirements and installation status
function Cmd-Check {
    Write-Host "Checking system requirements and installation status..."
    Write-Host ""
    
    $nodeInstalled = Check-NodeJs
    $npmInstalled = Check-Npm
    $claudeInstalled = Check-ClaudeCode
    
    Write-Host ""
    if ($nodeInstalled -and $npmInstalled -and $claudeInstalled) {
        Write-Success "System Status: All requirements are met and Claude Code is ready to use."
        Write-Host ""
        Get-CurrentProvider
    }
    elseif ($nodeInstalled -and $npmInstalled) {
        Write-Warning "System Status: Node.js and npm are installed, but Claude Code is not installed."
        Write-Host "  Run '.\cct.ps1 install' to install Claude Code."
    }
    else {
        Write-Error "System Status: Missing required dependencies."
        if (-not $nodeInstalled) {
            Write-Host "  Please install Node.js first."
        }
        if (-not $npmInstalled) {
            Write-Host "  Please install npm first."
        }
    }
}

# Add provider command - configure a new API provider
function Cmd-AddProvider {
    param(
        [string]$providerName = "",
        [string]$baseUrl = "",
        [string]$apiKey = ""
    )
    
    # Verify Claude Code is installed before proceeding
    if (-not (Check-ClaudeCode)) {
        Write-Host "Claude Code is not installed. Would you like to install it now? (y/n)"
        $response = Read-Host
        if ($response -match "^[Yy]") {
            Cmd-Install
            return
        }
        else {
            Write-Host "Operation cancelled. Please install Claude Code first using: .\cct.ps1 install"
            exit 1
        }
    }
    
    if ([string]::IsNullOrEmpty($providerName)) {
        $providerName = Read-Host "Enter provider name"
    }
    
    if ([string]::IsNullOrEmpty($baseUrl)) {
        $baseUrl = Read-Host "Enter base URL for $providerName"
    }
    
    if ([string]::IsNullOrEmpty($apiKey)) {
        $secureApiKey = Read-Host "Enter API key for $providerName" -AsSecureString
        $apiKey = [System.Net.NetworkCredential]::new("", $secureApiKey).Password
    }
    
    Add-ProviderToJson -providerName $providerName -baseUrl $baseUrl -apiKey $apiKey
}

# Switch command - change to a different configured provider
function Cmd-Switch {
    param(
        [string]$providerName = ""
    )
    
    # Verify Claude Code is installed before proceeding
    if (-not (Check-ClaudeCode)) {
        Write-Host "Claude Code is not installed. Would you like to install it now? (y/n)"
        $response = Read-Host
        if ($response -match "^[Yy]") {
            Cmd-Install
            return
        }
        else {
            Write-Host "Operation cancelled. Please install Claude Code first using: .\cct.ps1 install"
            exit 1
        }
    }
    
    if ([string]::IsNullOrEmpty($providerName)) {
        $providerName = Read-Host "Enter provider name to switch to"
    }
    
    $provider = Get-ProviderDetails -providerName $providerName
    if ($null -eq $provider) {
        exit 1
    }
    
    Update-EnvVars -baseUrl $provider.base_url -apiKey $provider.api_key
    
    Write-Success "Switched to provider: $providerName"
}

# Main command handler
$command = $args[0]

switch ($command) {
    "install" {
        Cmd-Install -providerName $args[1] -apiKey $args[2] -baseUrl $args[3]
    }
    "uninstall" {
        Cmd-Uninstall
    }
    "update" {
        Cmd-Update
    }
    "check" {
        Cmd-Check
    }
    "add-provider" {
        Cmd-AddProvider -providerName $args[1] -baseUrl $args[2] -apiKey $args[3]
    }
    "switch" {
        Cmd-Switch -providerName $args[1]
    }
    "list-providers" {
        List-Providers
    }
    default {
        Write-Host "Claude Code Toolkit (CCT)"
        Write-Host "Usage: .\cct.ps1 [command]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  install [provider_name] [api_key] [--base-url url]  Install Claude Code and configure a provider"
        Write-Host "  uninstall                                           Uninstall Claude Code and remove configurations"
        Write-Host "  update                                              Update Claude Code to the latest version"
        Write-Host "  check                                               Check installation status and current provider"
        Write-Host "  add-provider [name] [base_url] [api_key]            Add a new provider"
        Write-Host "  switch [provider_name]                              Switch to a different provider"
        Write-Host "  list-providers                                      List all configured providers"
        exit 1
    }
}

exit 0
