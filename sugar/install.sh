#!/bin/bash

#
# Claude Code Sugar Installation Script for Unix/Linux/macOS
#
# Description:
#   This script automatically installs Claude Code Sugar, a proxy tool for accessing
#   AI models through ModelScope's API-Inference. It handles Node.js installation, package 
#   installation, and configuration setup.
#
# Usage:
#   ./install.sh
#
# Requirements:
#   - Bash shell
#   - curl (for downloading nvm)
#   - Internet connection
#   - Write permissions to home directory
#
# Author: Claude Code Sugar Team
# Version: 1.0.0
# Last Updated: 2025-08-16
#
# This script will:
#   1. Install Node.js (v18+) via nvm if not present
#   2. Install claude-code-sugar package globally
#   3. Configure ModelScope's API-Inference integration
#   4. Set up PATH environment variables
#
# For more information: https://github.com/xixu-me/Claude-Code-Toolkit/tree/main/sugar
#

set -e  # Exit on any error

# ============================================================================
# SCRIPT CONFIGURATION AND CONSTANTS
# ============================================================================

# Configuration constants
readonly REQUIRED_NODE_MAJOR_VERSION=18
readonly TARGET_NODE_VERSION=22
readonly NPM_REGISTRY="https://xget.xi-xu.me/npm/"
readonly PACKAGE_NAME="claude-code-sugar"
readonly MODELSCOPE_API_URL="https://api-inference.modelscope.cn/v1"
readonly MODELSCOPE_TOKEN_URL="https://modelscope.cn/my/myaccesstoken"
readonly NVM_VERSION="v0.40.3"

# Default model mappings (used in configuration generation)
declare -A DEFAULT_MODEL_MAPPINGS=(
    ["claude-3-5-haiku-20241022"]="Qwen/Qwen3-Coder-480B-A35B-Instruct"
    ["claude-sonnet-4-20250514"]="Qwen/Qwen3-Coder-480B-A35B-Instruct"
    ["claude-opus-4-20250514"]="Qwen/Qwen3-Coder-480B-A35B-Instruct"
)

# ============================================================================
# CORE FUNCTIONS - NODE.JS INSTALLATION
# ============================================================================

install_nodejs() {
    #
    # Installs Node.js using nvm (Node Version Manager)
    # Supports Linux, Darwin (macOS), and other Unix-like systems
    #
    
    local platform=$(uname -s)
    
    case "$platform" in
        Linux|Darwin)
            # Check if Command Line Tools is installed on macOS
            if [ "$platform" = "Darwin" ]; then
                if ! xcode-select --print-path &> /dev/null; then
                    echo "❌ Xcode Command Line Tools not found on macOS"
                    echo "📝 Please install it first by running:"
                    echo "   xcode-select --install"
                    echo ""
                    echo "🔄 After installation completes, please run this script again."
                    exit 1
                fi
                echo "✅ Xcode Command Line Tools found"
            fi
            
            echo "🚀 Installing Node.js on Unix/Linux/macOS..."
            
            echo "📥 Downloading and installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
            
            echo "🔄 Loading nvm environment..."
            \. "$HOME/.nvm/nvm.sh"
            
            echo "📦 Downloading and installing Node.js v${TARGET_NODE_VERSION}..."
            nvm install $TARGET_NODE_VERSION
            
            echo "✅ Node.js installation completed! Version: $(node -v)"
            echo "✅ Current nvm version: $(nvm current)"
            echo "✅ npm version: $(npm -v)"
            ;;
        *)
            echo "❌ Unsupported platform: $platform"
            echo "📝 Please install Node.js manually from: https://nodejs.org/"
            exit 1
            ;;
    esac
}

check_node_version() {
    #
    # Checks if the current Node.js version meets minimum requirements
    # Returns 0 if adequate, 1 if not
    #
    
    local current_version=$(node -v | sed 's/v//')
    local major_version=$(echo $current_version | cut -d. -f1)
    
    if [ "$major_version" -ge $REQUIRED_NODE_MAJOR_VERSION ]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# MAIN EXECUTION - NODE.JS VERIFICATION AND INSTALLATION
# ============================================================================

echo "🔍 Checking Node.js installation..."

# Check if Node.js is already installed and version is >= 18
if command -v node >/dev/null 2>&1; then
    if check_node_version; then
        current_version=$(node -v)
        echo "✅ Node.js is already installed: $current_version"
    else
        current_version=$(node -v)
        echo "⚠️  Node.js $current_version is installed but version < v$REQUIRED_NODE_MAJOR_VERSION. Upgrading..."
        install_nodejs
    fi
else
    echo "⚠️  Node.js not found. Installing..."
    install_nodejs
fi

# ============================================================================
# CLAUDE CODE SUGAR INSTALLATION
# ============================================================================

echo "🔍 Checking Claude Code Sugar installation..."

# Check if Claude Code is already installed
if command -v claude >/dev/null 2>&1; then
    echo "✅ Claude Code Sugar is already installed: $(claude --version)"
    echo "💡 If you want to reinstall, please uninstall first with:"
    echo "   npm uninstall -g @anthropic-ai/claude-code"
    echo ""
    echo "🚪 Installation script exiting..."
    exit 0
else
    echo "⚠️  Claude Code Sugar not found. Installing..."
    echo "📦 Installing $PACKAGE_NAME..."
    npm install -g $PACKAGE_NAME --registry=$NPM_REGISTRY
    
    # Get npm global bin directory
    echo "🔍 Detecting npm global bin directory..."
    npm_prefix=$(npm config get prefix 2>/dev/null)
    if [ -n "$npm_prefix" ]; then
        npm_bin_dir="$npm_prefix/bin"
        echo "📁 npm global bin directory: $npm_bin_dir"
    else
        echo "⚠️  Could not detect npm global bin directory"
        npm_bin_dir=""
    fi
fi

# ============================================================================
# CONFIGURATION SETUP
# ============================================================================

echo "🔧 Setting up Claude Code configuration..."

# Configure Claude Code to skip onboarding
echo "🔧 Configuring Claude Code onboarding..."
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
    }'

# ============================================================================
# API KEY COLLECTION AND VALIDATION
# ============================================================================

echo ""
echo "🔑 ModelScope's API-Inference Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Please enter your ModelScope token:"
echo "📍 Get your token from: $MODELSCOPE_TOKEN_URL"
echo "🔒 Note: Input is hidden for security. Paste your token and press Enter."
echo ""

read -s -p "Token: " api_key
echo ""

if [ -z "$api_key" ]; then
    echo "❌ ModelScope token cannot be empty. Please run the script again."
    exit 1
fi

echo "✅ ModelScope token received successfully"

# ============================================================================
# PROXY CONFIGURATION FILE GENERATION
# ============================================================================

echo "📄 Creating proxy configuration file..."
proxy_config_dir="$HOME/.config/$PACKAGE_NAME"
proxy_config_file="$proxy_config_dir/config.json"

# Create directory if it doesn't exist
mkdir -p "$proxy_config_dir"

# Create proxy config JSON with user's API key
cat > "$proxy_config_file" << EOF
{
  "baseURL": "$MODELSCOPE_API_URL",
  "apiKey": "$api_key",
  "modelMapping": {
    "claude-3-5-haiku-20241022": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
    "claude-sonnet-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
    "claude-opus-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct"
  }
}
EOF

echo "✅ Proxy configuration created at $proxy_config_file"
echo "💡 You can modify model mappings by editing this configuration file"

# ============================================================================
# SHELL ENVIRONMENT SETUP
# ============================================================================

echo "🔧 Configuring shell environment..."

# Detect current shell and determine rc file
current_shell=$(basename "$SHELL")
case "$current_shell" in
    bash)
        rc_file="$HOME/.bashrc"
        ;;
    zsh)
        rc_file="$HOME/.zshrc"
        ;;
    fish)
        rc_file="$HOME/.config/fish/config.fish"
        ;;
    *)
        rc_file="$HOME/.profile"
        ;;
esac

# Ensure rc_file exists, create if not
if [ ! -f "$rc_file" ]; then
    echo "📄 Creating $rc_file..."
    touch "$rc_file"
    echo "✅ Created $rc_file"
fi

# Check if claude command is available after installation
if ! command -v claude >/dev/null 2>&1 && [ -n "$npm_bin_dir" ]; then
    echo "🔧 claude command not found in PATH, adding npm global bin to PATH..."
    need_path_update=true
else
    need_path_update=false
fi

# Check if PATH already contains npm bin directory
path_exists=false
if [ -f "$rc_file" ] && [ -n "$npm_bin_dir" ] && grep -q "$npm_bin_dir" "$rc_file"; then
    path_exists=true
fi

# Add PATH configuration if needed and not already present
if [ "$need_path_update" = true ] && [ "$path_exists" = false ]; then
    echo "" >> "$rc_file"
    echo "# Add npm global bin to PATH for Claude Code Sugar" >> "$rc_file"
    echo "export PATH=\"$npm_bin_dir:\$PATH\"" >> "$rc_file"
    echo "✅ Added $npm_bin_dir to PATH in $rc_file"
elif [ "$need_path_update" = true ] && [ "$path_exists" = true ]; then
    echo "⚠️  PATH already contains $npm_bin_dir in $rc_file. Skipping..."
fi

# ============================================================================
# INSTALLATION COMPLETION AND VERIFICATION
# ============================================================================

echo ""
echo "🎉 Installation Process Completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Provide restart instructions
echo "🔄 Environment Setup Instructions:"
echo "   Please restart your terminal or run:"
echo "   source $rc_file"
echo ""

# Final verification attempt
echo "🔍 Verifying Claude Code Sugar installation..."
if command -v claude >/dev/null 2>&1; then
    echo "✅ claude command is available: $(claude --version)"
    echo ""
    echo "🚀 Ready to use! Start Claude Code Sugar with:"
    echo "   claude"
    echo ""
    echo "📖 For help and documentation:"
    echo "   claude --help"
else
    echo "⚠️  claude command not found in current session."
    echo "   Please restart your terminal and run:"
    echo "   source $rc_file"
    echo "   claude --version"
    echo ""
    echo "� If still not working, manually add to PATH:"
    if [ -n "$npm_bin_dir" ]; then
        echo "   export PATH=\"$npm_bin_dir:\$PATH\""
    fi
    echo "   claude"
fi

# ============================================================================
# SECURITY CLEANUP
# ============================================================================

echo ""
echo "🔒 Cleaning up sensitive data..."
unset api_key

echo ""
echo "✨ Claude Code Sugar installation completed successfully!"
echo "🙏 Thank you for using Claude Code Sugar!"
