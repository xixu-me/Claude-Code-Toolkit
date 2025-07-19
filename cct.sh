#!/bin/bash

# Claude Code Toolkit (CCT)
# A comprehensive script to manage Claude Code installation, configuration, and providers

# Script constants
CLAUDE_DIR="$HOME/.claude"
PROVIDERS_FILE="$CLAUDE_DIR/providers.json"
DEFAULT_PROVIDER_NAME="Moonshot AI"
DEFAULT_BASE_URL="https://api.moonshot.cn/anthropic/"
REQUIRED_NODE_VERSION="18"
CLAUDE_PACKAGE="@anthropic-ai/claude-code"

# Color constants for consistent terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Color helper functions
color_success() { echo -e "${GREEN}✓${NC} $1"; }
color_error() { echo -e "${RED}✗${NC} $1"; }
color_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
color_info() { echo -e "${BLUE}ℹ${NC} $1"; }
color_progress() { echo -e "${CYAN}→${NC} $1"; }
color_prompt() { echo -e "${WHITE}$1${NC}"; }

# Safe read function that works even when script is piped
safe_read() {
  local var_name="$1"
  local prompt="$2"
  local options="$3"
  
  if [ -n "$prompt" ]; then
    echo -n "$prompt"
  fi
  
  # Use /dev/tty to read from terminal even when script is piped
  local value
  if [ -t 0 ]; then
    if [ "$options" = "-s" ]; then
      read -s value
    else
      read -r value
    fi
  else
    if [ "$options" = "-s" ]; then
      read -s value < /dev/tty
    else
      read -r value < /dev/tty
    fi
  fi
  
  # Use eval to assign the value to the variable
  eval "$var_name=\"\$value\""
}

# Create Claude directory if it doesn't exist
ensure_claude_dir() {
  if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    color_success "Created directory: $CLAUDE_DIR"
  fi
}

# Detect the appropriate shell configuration file
detect_shell_config_file() {
  # Use case statement for reliable shell detection
  case "$SHELL" in
    *zsh*)
      if [ -f "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc"
        return 0
      fi
      ;;
    *bash*)
      # Check for .bashrc first, then .bash_profile
      if [ -f "$HOME/.bashrc" ]; then
        echo "$HOME/.bashrc"
        return 0
      elif [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"
        return 0
      fi
      ;;
    *fish*)
      # Ensure fish config directory exists
      local fish_config="$HOME/.config/fish/config.fish"
      if [ -f "$fish_config" ]; then
        echo "$fish_config"
        return 0
      elif [ -d "$HOME/.config/fish" ]; then
        # Directory exists but config file doesn't - create it
        if touch "$fish_config" 2>/dev/null; then
          echo "$fish_config"
          return 0
        fi
      fi
      ;;
  esac
  
  # Fallback order: check common shell configuration files
  local config_files=(
    "$HOME/.profile"
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.bash_profile"
  )
  
  for config_file in "${config_files[@]}"; do
    if [ -f "$config_file" ]; then
      echo "$config_file"
      return 0
    fi
  done
  
  # Last resort: create .profile if no configuration file exists
  local profile_file="$HOME/.profile"
  if touch "$profile_file" 2>/dev/null; then
    echo "$profile_file"
    return 0
  else
    # If we can't create files in home directory, something is seriously wrong
    color_error "Cannot create or access shell configuration files in home directory: $HOME"
    color_error "Please check permissions and try again."
    return 1
  fi
}

# Check if Node.js is installed and meets minimum version requirement
check_nodejs() {
  if ! command -v node >/dev/null 2>&1; then
    color_error "Node.js is not installed."
    return 1
  fi

  local node_version_full=$(node -v 2>/dev/null)
  if [ -z "$node_version_full" ]; then
    color_error "Failed to get Node.js version."
    return 1
  fi

  # Remove 'v' prefix if present and extract major version number
  local node_version=$(echo "$node_version_full" | sed 's/^v//' | cut -d '.' -f 1)
  
  # Validate version format using POSIX-compliant method
  case "$node_version" in
    ''|*[!0-9]*)
      color_error "Invalid Node.js version format: $node_version_full"
      return 1
      ;;
    *)
      # Valid numeric version detected
      ;;
  esac

  # Compare version numbers ensuring numeric comparison
  if [ "$node_version" -lt "$REQUIRED_NODE_VERSION" ] 2>/dev/null; then
    color_error "Node.js version $node_version_full is installed, but version $REQUIRED_NODE_VERSION+ is required."
    return 1
  fi

  color_success "Node.js version $node_version_full is installed."
  return 0
}

# Check if npm is installed and working properly
check_npm() {
  if ! command -v npm &> /dev/null; then
    color_error "npm is not installed."
    return 1
  fi

  local npm_version=$(npm -v 2>/dev/null)
  if [ -z "$npm_version" ]; then
    color_error "npm is installed but not working properly."
    return 1
  fi

  color_success "npm version $npm_version is installed."
  return 0
}

# Install Node.js using available package managers
install_nodejs() {
  color_progress "Installing Node.js..."
  
  if [ "$(uname)" == "Darwin" ]; then
    # macOS installation using Homebrew
    if command -v brew &> /dev/null; then
      color_progress "Installing Node.js using Homebrew..."
      brew install node
    else
      color_error "Homebrew not found. Please install Node.js manually from https://nodejs.org/"
      exit 1
    fi
  else
    # Linux installation using Node Version Manager (nvm)
    color_progress "Downloading and installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    if [ $? -ne 0 ]; then
      color_error "Failed to install nvm. Please install Node.js manually."
      exit 1
    fi
    
    color_progress "Loading nvm environment..."
    \. "$HOME/.nvm/nvm.sh"
    
    if [ $? -ne 0 ]; then
      color_error "Failed to load nvm. Please restart your terminal and try again."
      exit 1
    fi
    
    color_progress "Downloading and installing Node.js v18..."
    nvm install 18
    
    if [ $? -ne 0 ]; then
      color_error "Failed to install Node.js via nvm. Please install Node.js manually."
      exit 1
    fi
    
    color_success "Node.js installation completed!"
    color_info "Node.js version: $(node -v)"
    color_info "Current nvm version: $(nvm current)"
    color_info "npm version: $(npm -v)"
  fi
  
  # Verify Node.js installation
  check_nodejs
  if [ $? -ne 0 ]; then
    color_error "Failed to install Node.js. Please install it manually."
    exit 1
  fi
}

# Install the Claude Code package via npm
install_claude_code() {
  color_progress "Installing $CLAUDE_PACKAGE..."
  npm install -g "$CLAUDE_PACKAGE"
  
  if [ $? -ne 0 ]; then
    color_error "Failed to install $CLAUDE_PACKAGE. Please check your npm configuration."
    exit 1
  fi
  
  color_success "$CLAUDE_PACKAGE installed successfully."
  
  # Configure Claude Code to skip the onboarding process
  color_progress "Configuring Claude Code to skip onboarding..."
  node --eval '
    const fs = require("fs");
    const os = require("os");
    const path = require("path");
    const homeDir = os.homedir(); 
    const filePath = path.join(homeDir, ".claude.json");
    if (fs.existsSync(filePath)) {
        const content = JSON.parse(fs.readFileSync(filePath, "utf-8"));
        fs.writeFileSync(filePath, JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2), "utf-8");
    } else {
        fs.writeFileSync(filePath, JSON.stringify({ hasCompletedOnboarding: true }, null, 2), "utf-8");
    }
  '
}

# Create providers.json file if it doesn't exist
ensure_providers_json() {
  ensure_claude_dir
  
  if [ ! -f "$PROVIDERS_FILE" ]; then
    echo "{}" > "$PROVIDERS_FILE"
  fi
}

# Add a provider to providers.json
add_provider_to_json() {
  local provider_name="$1"
  local base_url="$2"
  local api_key="$3"
  
  ensure_providers_json
  
  # Use jq for JSON manipulation if available, otherwise fallback method
  if command -v jq &> /dev/null; then
    jq --arg name "$provider_name" --arg url "$base_url" --arg key "$api_key" \
      '.[$name] = {"base_url": $url, "api_key": $key}' "$PROVIDERS_FILE" > "$PROVIDERS_FILE.tmp" \
      && mv "$PROVIDERS_FILE.tmp" "$PROVIDERS_FILE"
  else
    # Fallback to manual JSON manipulation when jq is unavailable
    local temp_json=$(cat "$PROVIDERS_FILE")
    
    # Remove the closing brace
    temp_json=${temp_json%\}}
    
    # Add comma if JSON content already exists
    if [ "$temp_json" != "{" ]; then
      temp_json="${temp_json},"
    fi
    
    # Append the new provider entry
    temp_json="${temp_json}\"$provider_name\":{\"base_url\":\"$base_url\",\"api_key\":\"$api_key\"}}"
    
    echo "$temp_json" > "$PROVIDERS_FILE"
  fi
  
  color_success "Provider '$provider_name' added successfully."
}

# Get provider details from providers.json or built-in providers
get_provider_details() {
  local provider_name="$1"
  
  # Handle built-in "Anthropic" provider
  if [ "$provider_name" = "Anthropic" ]; then
    echo "|"
    return 0
  fi
  
  if [ ! -f "$PROVIDERS_FILE" ]; then
    color_error "Providers file not found."
    return 1
  fi
  
  if command -v jq &> /dev/null; then
    if ! jq -e --arg name "$provider_name" '.[$name]' "$PROVIDERS_FILE" > /dev/null 2>&1; then
      color_error "Provider '$provider_name' not found."
      return 1
    fi
    
    local base_url=$(jq -r --arg name "$provider_name" '.[$name].base_url' "$PROVIDERS_FILE")
    local api_key=$(jq -r --arg name "$provider_name" '.[$name].api_key' "$PROVIDERS_FILE")
    
    echo "$base_url|$api_key"
    return 0
  else
    # Fallback to grep and sed when jq is unavailable
    # Note: This is a simplified approach for basic JSON structures
    if ! grep -q "\"$provider_name\"" "$PROVIDERS_FILE"; then
      color_error "Provider '$provider_name' not found."
      return 1
    fi
    
    local provider_section=$(grep -o "\"$provider_name\":[^}]*}" "$PROVIDERS_FILE")
    local base_url=$(echo "$provider_section" | grep -o "\"base_url\":\"[^\"]*\"" | cut -d '"' -f 4)
    local api_key=$(echo "$provider_section" | grep -o "\"api_key\":\"[^\"]*\"" | cut -d '"' -f 4)
    
    echo "$base_url|$api_key"
    return 0
  fi
}

# Update environment variables in shell configuration file
update_env_vars() {
  local base_url="$1"
  local api_key="$2"
  local config_file=$(detect_shell_config_file)
  
  # For Anthropic provider, clear environment variables to use defaults
  if [ -z "$base_url" ] && [ -z "$api_key" ]; then
    remove_env_vars
    color_success "Environment variables cleared (using Anthropic defaults)."
    return
  fi
  
  # Handle Fish shell with different syntax
  if [[ "$config_file" == *"config.fish"* ]]; then
    # Fish shell uses 'set -gx' for environment variables
    # Remove existing environment variable declarations
    sed -i'.bak' '/^set -gx ANTHROPIC_BASE_URL/d' "$config_file"
    sed -i'.bak' '/^set -gx ANTHROPIC_API_KEY/d' "$config_file"
    
    # Ensure Fish configuration directory exists
    mkdir -p "$(dirname "$config_file")"
    
    # Add new environment variables for Fish shell
    echo "set -gx ANTHROPIC_BASE_URL \"$base_url\"" >> "$config_file"
    echo "set -gx ANTHROPIC_API_KEY \"$api_key\"" >> "$config_file"
  else
    # Bash/Zsh and other shells use 'export' syntax
    # Remove existing environment variable declarations
    sed -i'.bak' '/^export ANTHROPIC_BASE_URL=/d' "$config_file"
    sed -i'.bak' '/^export ANTHROPIC_API_KEY=/d' "$config_file"
    
    # Add new environment variable declarations
    echo "export ANTHROPIC_BASE_URL=\"$base_url\"" >> "$config_file"
    echo "export ANTHROPIC_API_KEY=\"$api_key\"" >> "$config_file"
  fi
  
  # Clean up backup file created by sed
  rm -f "${config_file}.bak"
  
  color_success "Environment variables updated in $config_file."
  color_info "Please run 'source $config_file' or restart your terminal for changes to take effect."
}

# Remove Claude Code environment variables from shell configuration
remove_env_vars() {
  local config_file=$(detect_shell_config_file)
  local removal_success=true
  
  # Check if config file exists
  if [ ! -f "$config_file" ]; then
    color_info "Shell configuration file $config_file does not exist."
    return 0
  fi
  
  # Handle Fish shell with different syntax
  if [[ "$config_file" == *"config.fish"* ]]; then
    # Fish shell uses 'set -gx' for environment variables
    if sed -i'.bak' '/^set -gx ANTHROPIC_BASE_URL/d; /^set -gx ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null; then
      color_success "Environment variables removed from Fish shell configuration."
    else
      color_error "Failed to remove environment variables from Fish shell configuration."
      removal_success=false
    fi
  else
    # Bash/Zsh and other shells use 'export' syntax
    if sed -i'.bak' '/^export ANTHROPIC_BASE_URL=/d; /^export ANTHROPIC_API_KEY=/d' "$config_file" 2>/dev/null; then
      color_success "Environment variables removed from shell configuration."
    else
      color_error "Failed to remove environment variables from shell configuration."
      removal_success=false
    fi
  fi
  
  # Clean up backup file created by sed
  rm -f "${config_file}.bak" 2>/dev/null
  
  if [ "$removal_success" = true ]; then
    color_info "Please run 'source $config_file' or restart your terminal for changes to take effect."
    return 0
  else
    color_warning "You may need to manually remove ANTHROPIC_BASE_URL and ANTHROPIC_API_KEY from $config_file"
    return 1
  fi
}

# Check if Claude Code package is installed
check_claude_code() {
  # First attempt: Check if claude command is available in PATH
  if command -v claude >/dev/null 2>&1; then
    if [ "$1" != "silent" ]; then
      color_success "$CLAUDE_PACKAGE is installed and available in PATH."
    fi
    return 0
  fi
  
  # Second attempt: Check npm global packages with robust method
  if npm ls -g --depth=0 --parseable 2>/dev/null | grep -q "$CLAUDE_PACKAGE"; then
    if [ "$1" != "silent" ]; then
      color_success "$CLAUDE_PACKAGE is installed globally."
    fi
    return 0
  fi
  
  # Third attempt: Use npm list method (slower but more thorough)
  if npm list -g "$CLAUDE_PACKAGE" >/dev/null 2>&1; then
    if [ "$1" != "silent" ]; then
      color_success "$CLAUDE_PACKAGE is installed."
    fi
    return 0
  fi
  
  # Fourth attempt: Check npm prefix and look for the package manually
  local npm_prefix
  if npm_prefix=$(npm prefix -g 2>/dev/null); then
    local package_path="$npm_prefix/node_modules/$CLAUDE_PACKAGE"
    if [ -d "$package_path" ]; then
      if [ "$1" != "silent" ]; then
        color_success "$CLAUDE_PACKAGE is installed at $package_path."
      fi
      return 0
    fi
  fi
  
  if [ "$1" != "silent" ]; then
    color_error "$CLAUDE_PACKAGE is not installed."
  fi
  return 1
}

# Get current provider from shell configuration
get_current_provider() {
  local config_file=$(detect_shell_config_file)
  
  # Handle Fish shell with different syntax
  if [[ "$config_file" == *"config.fish"* ]]; then
    # Fish shell uses 'set -gx' syntax
    if grep -q "set -gx ANTHROPIC_BASE_URL" "$config_file"; then
      local base_url=$(grep "set -gx ANTHROPIC_BASE_URL" "$config_file" | cut -d '"' -f 2)
      
      # Try to identify provider name by matching base URL in providers.json
      if [ -f "$PROVIDERS_FILE" ] && command -v jq &> /dev/null; then
        local provider_name=$(jq -r --arg url "$base_url" 'to_entries | map(select(.value.base_url == $url)) | .[0].key // "Unknown"' "$PROVIDERS_FILE")
        
        if [ "$provider_name" != "null" ] && [ "$provider_name" != "Unknown" ]; then
          echo "Current provider: $provider_name ($base_url)"
          return 0
        fi
      fi
      
      echo "Current provider: Unknown ($base_url)"
      return 0
    else
      echo "Current provider: Anthropic (using official API defaults)"
      return 0
    fi
  else
    # Bash/Zsh and other shells use 'export' syntax
    if grep -q "ANTHROPIC_BASE_URL" "$config_file"; then
      local base_url=$(grep "ANTHROPIC_BASE_URL" "$config_file" | cut -d '"' -f 2)
      
      # Try to identify provider name by matching base URL in providers.json
      if [ -f "$PROVIDERS_FILE" ] && command -v jq &> /dev/null; then
        local provider_name=$(jq -r --arg url "$base_url" 'to_entries | map(select(.value.base_url == $url)) | .[0].key // "Unknown"' "$PROVIDERS_FILE")
        
        if [ "$provider_name" != "null" ] && [ "$provider_name" != "Unknown" ]; then
          echo "Current provider: $provider_name ($base_url)"
          return 0
        fi
      fi
      
      echo "Current provider: Unknown ($base_url)"
      return 0
    else
      echo "Current provider: Anthropic (using official API defaults)"
      return 0
    fi
  fi
}

# List all available providers
list_providers() {
  # Verify Claude Code is installed before proceeding
  if ! check_claude_code; then
    echo "Claude Code is not installed. Would you like to install it now? (y/n)"
    safe_read response ""
    case "$response" in
      [Yy]*)
        cmd_install
        return
        ;;
      *)
        echo "Operation cancelled. Please install Claude Code first using: $0 install"
        exit 1
        ;;
    esac
  fi
  
  echo "Available providers:"
  echo "Anthropic: (using official API defaults)"
  
  if [ -f "$PROVIDERS_FILE" ]; then
    if command -v jq &> /dev/null; then
      jq -r 'keys[] as $k | "\($k): \(.[$k].base_url)"' "$PROVIDERS_FILE"
    else
      echo "Available providers (install jq for better formatting):"
      cat "$PROVIDERS_FILE"
    fi
  else
    ensure_providers_json
  fi
}

# Install command
cmd_install() {
  local provider_name="${1:-}"
  local api_key="$2"
  local base_url="$3"
  
  # If base_url wasn't provided, check if it's a named argument
  if [ -z "$base_url" ] && [ "$4" = "--base-url" ]; then
    base_url="$5"
  fi
  
  # Check for Node.js and npm prerequisites
  check_nodejs
  if [ $? -ne 0 ]; then
    install_nodejs
  fi
  
  check_npm
  if [ $? -ne 0 ]; then
    color_error "npm is required but not installed. Please install npm and try again."
    exit 1
  fi
  
  # Install Claude Code package
  install_claude_code
  
  # If no provider specified, prompt user to choose
  if [ -z "$provider_name" ]; then
    echo "Please choose a provider:"
    echo "1. Anthropic (Official API)"
    echo "2. Moonshot AI (Compatible API with default configuration)"
    echo "3. Custom provider (Enter your own API endpoint)"
    echo ""
    
    while true; do
      safe_read choice "Enter your choice (1-3): "
      
      # Check if we got valid input
      if [ -z "$choice" ]; then
        echo "Input error or EOF detected. Please try again."
        continue
      fi
      
      case $choice in
        1|2|3) break ;;
        *) echo "Please enter 1, 2, or 3." ;;
      esac
    done
    
    case $choice in
      1)
        provider_name="Anthropic"
        base_url=""
        api_key=""
        ;;
      2)
        provider_name="$DEFAULT_PROVIDER_NAME"
        base_url="$DEFAULT_BASE_URL"
        ;;
      3)
        safe_read provider_name "Enter provider name: "
        safe_read base_url "Enter base URL for $provider_name: "
        ;;
    esac
  fi
  
  # Handle Anthropic provider (no additional configuration needed)
  if [ "$provider_name" = "Anthropic" ]; then
    if [ -z "$api_key" ]; then
      safe_read api_key "Enter your Anthropic API key: " "-s"
      echo  # Add newline after hidden input
    fi
    
    # For Anthropic, only set the API key environment variable
    # No need to add to providers.json or set base URL
    local config_file=$(detect_shell_config_file)
    
    # Handle Fish shell with different syntax
    if [[ "$config_file" == *"config.fish"* ]]; then
      # Fish shell uses 'set -gx' for environment variables
      # Remove existing environment variable declarations
      sed -i'.bak' '/^set -gx ANTHROPIC_BASE_URL/d' "$config_file"
      sed -i'.bak' '/^set -gx ANTHROPIC_API_KEY/d' "$config_file"
      
      # Ensure Fish configuration directory exists
      mkdir -p "$(dirname "$config_file")"
      
      # Add API key for Fish shell
      echo "set -gx ANTHROPIC_API_KEY \"$api_key\"" >> "$config_file"
    else
      # Bash/Zsh and other shells use 'export' syntax
      # Remove existing environment variable declarations
      sed -i'.bak' '/^export ANTHROPIC_BASE_URL=/d' "$config_file"
      sed -i'.bak' '/^export ANTHROPIC_API_KEY=/d' "$config_file"
      
      # Add API key declaration
      echo "export ANTHROPIC_API_KEY=\"$api_key\"" >> "$config_file"
    fi
    
    # Clean up backup file created by sed
    rm -f "${config_file}.bak"
    
    color_success "Claude Code installed and configured to use Anthropic API."
    echo "  Please run 'source $config_file' or restart your terminal for changes to take effect."
    return
  fi
  
  # Set default base URL for Moonshot AI if not specified
  if [ "$provider_name" = "$DEFAULT_PROVIDER_NAME" ] && [ -z "$base_url" ]; then
    base_url="$DEFAULT_BASE_URL"
  fi
  
  # Prompt for missing configuration details
  if [ -z "$base_url" ]; then
    safe_read base_url "Enter base URL for $provider_name: "
    if [ -z "$base_url" ]; then
      color_error "Base URL cannot be empty. Please try again."
      exit 1
    fi
  fi
  
  if [ -z "$api_key" ]; then
    safe_read api_key "Enter API key for $provider_name: " "-s"
    echo  # Add newline after hidden input
  fi
  
  # Add provider configuration to providers.json
  add_provider_to_json "$provider_name" "$base_url" "$api_key"
  
  # Switch to the newly configured provider
  cmd_switch "$provider_name"
  
  color_success "Claude Code installed and configured to use $provider_name."
}

# Uninstall command - remove Claude Code and all configurations
cmd_uninstall() {
  local uninstall_success=true
  local errors_occurred=false
  
  # Remove Claude Code package if installed
  if check_claude_code >/dev/null 2>&1; then
    color_progress "Uninstalling $CLAUDE_PACKAGE..."
    if npm uninstall -g "$CLAUDE_PACKAGE" >/dev/null 2>&1; then
      color_success "Successfully uninstalled $CLAUDE_PACKAGE."
    else
      color_error "Failed to uninstall $CLAUDE_PACKAGE via npm."
      errors_occurred=true
      # Try alternative uninstall methods
      color_progress "Attempting alternative uninstall method..."
      if npm uninstall --global "$CLAUDE_PACKAGE" >/dev/null 2>&1; then
        color_success "Successfully uninstalled $CLAUDE_PACKAGE using alternative method."
      else
        color_warning "Could not uninstall $CLAUDE_PACKAGE. You may need to remove it manually."
        color_info "Try running: npm uninstall -g $CLAUDE_PACKAGE"
      fi
    fi
  else
    color_info "$CLAUDE_PACKAGE is not currently installed."
  fi
  
  # Remove environment variables from shell configuration
  color_progress "Removing environment variables from shell configuration..."
  if remove_env_vars >/dev/null 2>&1; then
    color_success "Environment variables removed successfully."
  else
    color_warning "Could not remove all environment variables. Please check your shell configuration manually."
    errors_occurred=true
  fi
  
  # Remove Claude configuration directory
  if [ -d "$CLAUDE_DIR" ]; then
    color_progress "Removing Claude configuration directory..."
    if rm -rf "$CLAUDE_DIR" 2>/dev/null; then
      color_success "Removed $CLAUDE_DIR directory."
    else
      color_error "Failed to remove $CLAUDE_DIR directory. Permission denied or directory in use."
      errors_occurred=true
      # Try with sudo if available (for Linux/WSL)
      if command -v sudo >/dev/null 2>&1; then
        color_progress "Attempting to remove directory with elevated permissions..."
        if sudo rm -rf "$CLAUDE_DIR" 2>/dev/null; then
          color_success "Successfully removed $CLAUDE_DIR directory with elevated permissions."
        else
          color_warning "Could not remove $CLAUDE_DIR. Please remove it manually."
        fi
      else
        color_warning "Could not remove $CLAUDE_DIR. Please remove it manually."
      fi
    fi
  else
    color_info "Claude configuration directory $CLAUDE_DIR does not exist."
  fi
  
  # Remove Claude configuration file
  claude_json_path="$HOME/.claude.json"
  if [ -f "$claude_json_path" ]; then
    color_progress "Removing Claude configuration file..."
    if rm -f "$claude_json_path" 2>/dev/null; then
      color_success "Removed $claude_json_path file."
    else
      color_error "Failed to remove $claude_json_path file. Permission denied."
      errors_occurred=true
      # Try with sudo if available (for Linux/WSL)
      if command -v sudo >/dev/null 2>&1; then
        color_progress "Attempting to remove file with elevated permissions..."
        if sudo rm -f "$claude_json_path" 2>/dev/null; then
          color_success "Successfully removed $claude_json_path file with elevated permissions."
        else
          color_warning "Could not remove $claude_json_path. Please remove it manually."
        fi
      else
        color_warning "Could not remove $claude_json_path. Please remove it manually."
      fi
    fi
  else
    color_info "Claude configuration file $claude_json_path does not exist."
  fi
  
  # Final status report
  if [ "$errors_occurred" = false ]; then
    color_success "Claude Code has been completely uninstalled."
    color_info "Please restart your terminal or run 'source ~/.bashrc' (or your shell's config file) to complete the process."
  else
    color_warning "Claude Code uninstallation completed with some warnings."
    color_info "Some files or configurations may need to be removed manually."
    color_info "Please restart your terminal or run 'source ~/.bashrc' (or your shell's config file) to complete the process."
  fi
}

# Update command - upgrade Claude Code to latest version
cmd_update() {
  # Verify Claude Code is installed before attempting update
  if ! check_claude_code; then
    echo "Claude Code is not installed. Would you like to install it now? (y/n)"
    safe_read response ""
    case "$response" in
      [Yy]*)
        cmd_install
        return
        ;;
      *)
        echo "Update cancelled. Please install Claude Code first using: $0 install"
        exit 1
        ;;
    esac
  fi
  
  color_progress "Updating $CLAUDE_PACKAGE..."
  npm update -g "$CLAUDE_PACKAGE"
  
  if [ $? -ne 0 ]; then
    color_error "Failed to update $CLAUDE_PACKAGE."
    exit 1
  fi
  
  color_success "$CLAUDE_PACKAGE has been updated to the latest version."
}

# Check command - verify system requirements and installation status
cmd_check() {
  echo "Checking system requirements and installation status..."
  echo ""
  
  local node_installed=false
  local npm_installed=false
  local claude_installed=false
  
  if check_nodejs; then
    node_installed=true
  fi
  
  if check_npm; then
    npm_installed=true
  fi
  
  if check_claude_code; then
    claude_installed=true
  fi
  
  echo ""
  if [ "$node_installed" = true ] && [ "$npm_installed" = true ] && [ "$claude_installed" = true ]; then
    color_success "System Status: All requirements are met and Claude Code is ready to use."
    echo ""
    get_current_provider
  elif [ "$node_installed" = true ] && [ "$npm_installed" = true ]; then
    color_warning "System Status: Node.js and npm are installed, but Claude Code is not installed."
    echo "  Run '$0 install' to install Claude Code."
  else
    color_error "System Status: Missing required dependencies."
    if [ "$node_installed" = false ]; then
      echo "  Please install Node.js first."
    fi
    if [ "$npm_installed" = false ]; then
      echo "  Please install npm first."
    fi
  fi
}

# Add provider command - configure a new API provider
cmd_add_provider() {
  local provider_name="$1"
  local base_url="$2"
  local api_key="$3"
  
  # Verify Claude Code is installed before proceeding
  if ! check_claude_code; then
    echo "Claude Code is not installed. Would you like to install it now? (y/n)"
    safe_read response ""
    case "$response" in
      [Yy]*)
        cmd_install
        return
        ;;
      *)
        echo "Operation cancelled. Please install Claude Code first using: $0 install"
        exit 1
        ;;
    esac
  fi
  
  if [ -z "$provider_name" ]; then
    safe_read provider_name "Enter provider name: "
    if [ -z "$provider_name" ]; then
      color_error "Provider name cannot be empty. Please try again."
      exit 1
    fi
  fi
  
  if [ -z "$base_url" ]; then
    safe_read base_url "Enter base URL for $provider_name: "
    if [ -z "$base_url" ]; then
      color_error "Base URL cannot be empty. Please try again."
      exit 1
    fi
  fi
  
  if [ -z "$api_key" ]; then
    safe_read api_key "Enter API key for $provider_name: " "-s"
    echo  # Add newline after hidden input
  fi
  
  add_provider_to_json "$provider_name" "$base_url" "$api_key"
}

# Switch command - change to a different configured provider
cmd_switch() {
  local provider_name="$1"
  
  # Verify Claude Code is installed before proceeding
  if ! check_claude_code; then
    echo "Claude Code is not installed. Would you like to install it now? (y/n)"
    safe_read response ""
    case "$response" in
      [Yy]*)
        cmd_install
        return
        ;;
      *)
        echo "Operation cancelled. Please install Claude Code first using: $0 install"
        exit 1
        ;;
    esac
  fi
  
  if [ -z "$provider_name" ]; then
    safe_read provider_name "Enter provider name to switch to: "
    if [ -z "$provider_name" ]; then
      color_error "Provider name cannot be empty. Please try again."
      exit 1
    fi
  fi
  
  local provider_details=$(get_provider_details "$provider_name")
  if [ $? -ne 0 ]; then
    echo "$provider_details"
    exit 1
  fi
  
  local base_url=$(echo "$provider_details" | cut -d '|' -f 1)
  local api_key=$(echo "$provider_details" | cut -d '|' -f 2)
  
  update_env_vars "$base_url" "$api_key"
  
  color_success "Switched to provider: $provider_name"
}

# Main command handler
case "$1" in
  install)
    cmd_install "$2" "$3" "$4" "$5" "$6"
    ;;
  uninstall)
    cmd_uninstall
    ;;
  update)
    cmd_update
    ;;
  check)
    cmd_check
    ;;
  add-provider)
    cmd_add_provider "$2" "$3" "$4"
    ;;
  switch)
    cmd_switch "$2"
    ;;
  list-providers)
    list_providers
    ;;
  *)
    echo "Claude Code Toolkit (CCT)"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install [provider_name] [api_key] [--base-url url]  Install Claude Code and configure a provider"
    echo "  uninstall                                           Uninstall Claude Code and remove configurations"
    echo "  update                                              Update Claude Code to the latest version"
    echo "  check                                               Check installation status and current provider"
    echo "  add-provider [name] [base_url] [api_key]            Add a new provider"
    echo "  switch [provider_name]                              Switch to a different provider"
    echo "  list-providers                                      List all configured providers"
    exit 1
    ;;
esac

exit 0
