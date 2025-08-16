# Claude Code Toolkit (CCT)

***[汉语](README.zh.md)***

[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](#command-syntax)
[![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)](#command-syntax)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4OCA4OCIgd2lkdGg9Ijg4IiBoZWlnaHQ9Ijg4Ij48cmVjdCB3aWR0aD0iNDIiIGhlaWdodD0iNDIiIGZpbGw9IiMwMGFkZWYiLz48cmVjdCB4PSI0NiIgd2lkdGg9IjQyIiBoZWlnaHQ9IjQyIiBmaWxsPSIjMDBhZGVmIi8+PHJlY3QgeT0iNDYiIHdpZHRoPSI0MiIgaGVpZ2h0PSI0MiIgZmlsbD0iIzAwYWRlZiIvPjxyZWN0IHg9IjQ2IiB5PSI0NiIgd2lkdGg9IjQyIiBoZWlnaHQ9IjQyIiBmaWxsPSIjMDBhZGVmIi8+PC9zdmc+&logoColor=white)](#command-syntax)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive cross-platform toolkit for managing Claude Code installation, configuration, and multiple Anthropic-compatible API provider support. This toolkit simplifies the process of setting up and switching between different Anthropic-compatible API providers, including the official Anthropic API and compatible third-party services like **Moonshot AI with the latest Kimi model (`kimi-k2-0711-preview`)** that implement Anthropic's API specification.

## 🍬 Claude Code Sugar

Looking for broader model compatibility? Check out **[Claude Code Sugar](sugar/)** - a lightweight local proxy tool that allows Claude Code to interact with any service compatible with the OpenAI API specification, such as ModelScope platform. With Sugar, you can seamlessly redirect `claude` command requests to a wider ecosystem of AI models while keeping your existing workflow unchanged.

## ✨ Latest Kimi Model Support

🚀 **Featured**: This toolkit includes built-in support for **Moonshot AI's latest Kimi model (`kimi-k2-0711-preview`)**, allowing you to leverage cutting-edge AI capabilities through the familiar Claude Code interface.

- **One-command setup**: Instantly configure Moonshot AI with the latest Kimi model
- **Seamless switching**: Switch between official Anthropic API and Kimi model effortlessly
- **Full compatibility**: All Claude Code features work seamlessly with the Kimi model

## Features

- **Cross-Platform Support**: Works on Linux/macOS (Bash) and Windows (PowerShell)
- **Multiple Provider Support**: Easy switching between Anthropic, Moonshot AI (with latest Kimi models), and custom Anthropic-compatible API providers
- **Automated Installation**: Handles Node.js, npm, and Claude Code package installation
- **Configuration Management**: Persistent provider configurations with secure API key storage
- **Environment Variable Management**: Automatic shell configuration for seamless provider switching
- **Interactive Setup**: User-friendly prompts for configuration when parameters are not provided

## Requirements

- **Node.js** 18 or higher
- **npm** (Node Package Manager)
- **Bash** (Linux/macOS) or **PowerShell** (Windows)
- Internet connection for package downloads

## API Key Setup

Before using this toolkit, you'll need API keys from your chosen provider:

- **Anthropic API**: Get your API key from [Anthropic Console](https://console.anthropic.com/)
- **Moonshot AI**: Get your API key from [Moonshot AI Platform](https://platform.moonshot.cn/console)
- **Custom Providers**: Obtain API keys from your preferred Anthropic-compatible service

## Usage

### Available Commands

| Command | Description |
|---------|-------------|
| `install [provider] [api_key] [options]` | Install Claude Code and configure a provider |
| `uninstall` | Completely remove Claude Code and all configurations |
| `update` | Update Claude Code to the latest version |
| `check` | Check installation status and current provider |
| `add-provider <name> <url> <key>` | Add a new API provider configuration |
| `switch <provider>` | Switch to a different configured provider |
| `list-providers` | Display all available providers |

### Command Syntax

For all commands below, use one of these patterns:

**Linux/macOS (Bash):**

```bash
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s [command] [arguments]
```

**Windows (PowerShell):**

```bash
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 [command] [arguments]
```

### Quick Start Examples

#### 1. Basic Installation (Interactive Setup)

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install
```

#### 2. Install with Anthropic (Official API)

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install Anthropic YOUR_API_KEY

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install Anthropic YOUR_API_KEY
```

#### 3. Install with Moonshot AI (Latest Kimi Model)

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install "Moonshot AI" YOUR_API_KEY

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install "Moonshot AI" YOUR_API_KEY
```

#### 4. Install with Custom Provider

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install "Custom Provider" YOUR_API_KEY --base-url https://api.example.com/v1/

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install "Custom Provider" YOUR_API_KEY --base-url https://api.example.com/v1/
```

### Common Operations

#### Check Installation Status

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s check

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 check
```

#### Switch Between Providers

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s switch "Provider Name"

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 switch "Provider Name"
```

#### Add New Provider

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s add-provider "Provider Name" "https://api.example.com/" "your-api-key"

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 add-provider "Provider Name" "https://api.example.com/" "your-api-key"
```

#### List All Providers

```bash
# Linux/macOS
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s list-providers

# Windows
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 list-providers
```

## Supported Providers

### Built-in Providers

1. **Anthropic** - Official Claude API
   - Uses default Anthropic endpoints
   - Requires official Anthropic API key
   - No additional configuration needed

2. **Moonshot AI** - Anthropic-compatible API service with latest Kimi models
   - Pre-configured with Moonshot endpoints
   - **Supports the latest Kimi model (`kimi-k2-0711-preview`)**
   - Fully compatible with Anthropic API format
   - Requires Moonshot AI API key

### Custom Anthropic-Compatible Providers

You can add any API provider that implements Anthropic-compatible endpoints by specifying:

- **Provider Name**: A friendly name for identification
- **Base URL**: The API endpoint base URL (must be Anthropic API compatible)
- **API Key**: Your authentication key for the service

## Configuration

### File Locations

- **Configuration Directory**: `~/.claude/` (Linux/macOS) or `%USERPROFILE%\.claude\` (Windows)
- **Providers File**: `~/.claude/providers.json`
- **Claude Config**: `~/.claude.json`

### Environment Variables

The toolkit automatically manages these environment variables:

- `ANTHROPIC_API_KEY`: Your API key for the current provider
- `ANTHROPIC_BASE_URL`: Base URL for custom providers (not set for official Anthropic API)

### Provider Configuration Format

```json
{
  "Provider Name": {
    "base_url": "https://api.example.com/anthropic/",
    "api_key": "your-encrypted-api-key"
  }
}
```

## Troubleshooting

### Common Issues

#### Node.js Version Issues

```bash
# Check your Node.js version
node -v

# The toolkit requires Node.js 18+
# Install or update Node.js from https://nodejs.org/
```

#### npm Permission Issues (Linux/macOS)

```bash
# If you get permission errors, configure npm for global installs
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
# Add ~/.npm-global/bin to your PATH
```

#### PowerShell Execution Policy (Windows)

```powershell
# If you can't run the script, check execution policy
Get-ExecutionPolicy

# Allow script execution (run as administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Getting Help

If you encounter issues:

1. **Run the check command** to verify your installation
2. **Check the troubleshooting section** above
3. **Review the error messages** - they often contain helpful information
4. **Check your internet connection** for installation issues

## Inspiration and Attribution

This repository was inspired by the [LLM-Red-Team/kimi-cc](https://github.com/LLM-Red-Team/kimi-cc) repository, which provides a simple way to use Moonshot AI's **latest Kimi model (`kimi-k2-0711-preview`)** to drive Claude Code. We've expanded upon that concept to create a comprehensive cross-platform toolkit that supports multiple Anthropic-compatible API providers with advanced configuration management, provider switching capabilities, and robust installation processes.

Key enhancements over the original inspiration include:

- **Cross-platform support** for both Linux/macOS (Bash) and Windows (PowerShell)
- **Multiple provider management** with easy switching between configured providers
- **Persistent configuration** with JSON-based provider storage
- **Interactive setup** with user-friendly prompts and error handling
- **Comprehensive command set** for installation, updates, provider management, and system checks
- **Advanced environment variable management** across different shell types

## Disclaimer

This toolkit is provided as-is, without any warranty or guarantee of fitness for a particular purpose. Use at your own risk. The authors and contributors are not responsible for any loss, damage, or issues arising from the use of this toolkit or any third-party API providers. Always review and comply with the terms of service and privacy policies of any API providers you use.

## License

This repository is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
