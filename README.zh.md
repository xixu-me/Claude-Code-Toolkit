# Claude Code 工具包（Claude Code Toolkit, CCT）

[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](#快速开始)
[![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)](#快速开始)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4OCA4OCIgd2lkdGg9Ijg4IiBoZWlnaHQ9Ijg4Ij48cmVjdCB3aWR0aD0iNDIiIGhlaWdodD0iNDIiIGZpbGw9IiMwMGFkZWYiLz48cmVjdCB4PSI0NiIgd2lkdGg9IjQyIiBoZWlnaHQ9IjQyIiBmaWxsPSIjMDBhZGVmIi8+PHJlY3QgeT0iNDYiIHdpZHRoPSI0MiIgaGVpZ2h0PSI0MiIgZmlsbD0iIzAwYWRlZiIvPjxyZWN0IHg9IjQ2IiB5PSI0NiIgd2lkdGg9IjQyIiBoZWlnaHQ9IjQyIiBmaWxsPSIjMDBhZGVmIi8+PC9zdmc+&logoColor=white)](#快速开始)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个全面的跨平台工具包，用于管理 Claude Code 的安装、配置和多个兼容 Anthropic API 的提供商支持。该工具包简化了设置和切换不同兼容 Anthropic API 提供商的过程，包括官方 Anthropic API 和实现了 Anthropic API 规范的兼容第三方服务，如**支持最新 Kimi 模型（`kimi-k2-0711-preview`）的月之暗面 AI**。

## ✨ 最新 Kimi 模型支持

🚀 **特色功能**：此工具包内置支持**月之暗面 AI 的最新 Kimi 模型（`kimi-k2-0711-preview`）**，让您能够通过熟悉的 Claude Code 界面使用最前沿的 AI 功能。

- **一键设置**：即刻配置支持最新 Kimi 模型的月之暗面 AI
- **无缝切换**：在官方 Anthropic API 和 Kimi 模型之间轻松切换
- **完全兼容**：所有 Claude Code 功能都能与 Kimi 模型无缝协作

## 功能特性

- **跨平台支持**：适用于 Linux/macOS（Bash）和 Windows（PowerShell）
- **多提供商支持**：在 Anthropic、月之暗面 AI（支持最新 Kimi 模型）和自定义兼容 Anthropic API 的提供商之间轻松切换
- **自动化安装**：处理 Node.js、npm 和 Claude Code 包的安装
- **配置管理**：持久化提供商配置，安全的 API 密钥存储
- **环境变量管理**：自动化 Shell 配置，实现无缝提供商切换
- **交互式设置**：当未提供参数时，提供用户友好的配置提示

## 系统要求

- **Node.js** 18 或更高版本
- **npm**（Node 包管理器）
- **Bash**（Linux/macOS）或 **PowerShell**（Windows）
- 互联网连接用于包下载

## API 密钥设置

在使用此工具包之前，您需要从所选提供商处获取 API 密钥：

- **Anthropic API**：从 [Anthropic Console](https://console.anthropic.com/) 获取您的 API 密钥
- **月之暗面 AI**：从 [月之暗面 AI 平台](https://platform.moonshot.cn/console) 获取您的 API 密钥
- **自定义提供商**：从您首选的兼容 Anthropic 的服务获取 API 密钥

## 安装

### 快速开始

```bash
# Linux/macOS (Bash)
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install

# Linux/macOS - 使用 Kimi 模型开始
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.sh | bash -s install "Moonshot AI" YOUR_MOONSHOT_API_KEY

# Windows (PowerShell)
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install

# Windows - 使用 Kimi 模型开始
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/cct.ps1" -OutFile "cct.ps1"; .\cct.ps1 install "Moonshot AI" YOUR_MOONSHOT_API_KEY
```

### 手动安装

1. **克隆或下载**此仓库
2. **导航**到包含脚本的目录
3. **运行安装命令**并选择您偏好的提供商

### 验证

安装后，验证一切是否正常工作：

```bash
# Linux/macOS
./cct.sh check

# Windows
.\cct.ps1 check
```

## 使用方法

### 基本命令

| 命令 | 描述 |
|---------|-------------|
| `install` | 安装 Claude Code 并配置提供商 |
| `uninstall` | 完全移除 Claude Code 和所有配置 |
| `update` | 更新 Claude Code 到最新版本 |
| `check` | 检查安装状态和当前提供商 |
| `add-provider` | 添加新的 API 提供商配置 |
| `switch` | 切换到不同的已配置提供商 |
| `list-providers` | 显示所有可用提供商 |

### 命令示例

#### 使用 Anthropic（官方 API）安装

```bash
# Linux/macOS  
./cct.sh install Anthropic YOUR_API_KEY

# Windows
.\cct.ps1 install Anthropic YOUR_API_KEY
```

#### 使用月之暗面 AI（最新 Kimi 模型支持）安装

```bash
# Linux/macOS
./cct.sh install "Moonshot AI" YOUR_API_KEY

# Windows
.\cct.ps1 install "Moonshot AI" YOUR_API_KEY
```

#### 使用自定义兼容 Anthropic 的提供商安装

```bash
# Linux/macOS
./cct.sh install "Custom Provider" YOUR_API_KEY --base-url https://api.example.com/v1/

# Windows
.\cct.ps1 install "Custom Provider" YOUR_API_KEY --base-url https://api.example.com/v1/
```

#### 交互式安装

```bash
# 运行时不带参数进行交互式设置
# Linux/macOS
./cct.sh install

# Windows
.\cct.ps1 install
```

### 提供商管理

#### 添加新提供商

```bash
# Linux/macOS
./cct.sh add-provider "Provider Name" "https://api.example.com/" "your-api-key"

# Windows
.\cct.ps1 add-provider "Provider Name" "https://api.example.com/" "your-api-key"
```

#### 在提供商之间切换

```bash
# Linux/macOS
./cct.sh switch "Provider Name"

# Windows
.\cct.ps1 switch "Provider Name"
```

#### 列出所有提供商

```bash
# Linux/macOS
./cct.sh list-providers

# Windows
.\cct.ps1 list-providers
```

## 支持的提供商

### 内置提供商

1. **Anthropic** - 官方 Claude API
   - 使用默认 Anthropic 端点
   - 需要官方 Anthropic API 密钥
   - 无需额外配置

2. **月之暗面 AI** - 兼容 Anthropic API 的服务，支持最新 Kimi 模型
   - 预配置月之暗面端点
   - **支持最新 Kimi 模型（`kimi-k2-0711-preview`）**
   - 完全兼容 Anthropic API 格式
   - 需要月之暗面 AI API 密钥

### 自定义兼容 Anthropic 的提供商

您可以通过指定以下内容添加任何实现了兼容 Anthropic 端点的 API 提供商：

- **提供商名称**：用于标识的友好名称
- **基础 URL**：API 端点基础 URL（必须兼容 Anthropic API）
- **API 密钥**：您的服务认证密钥

## 配置

### 文件位置

- **配置目录**：`~/.claude/`（Unix）或 `%USERPROFILE%\.claude\`（Windows）
- **提供商文件**：`~/.claude/providers.json`
- **Claude 配置**：`~/.claude.json`

### 环境变量

工具包自动管理这些环境变量：

- `ANTHROPIC_API_KEY`：当前提供商的 API 密钥
- `ANTHROPIC_BASE_URL`：自定义提供商的基础 URL（官方 Anthropic API 不设置此项）

### 提供商配置格式

```json
{
  "Provider Name": {
    "base_url": "https://api.example.com/anthropic/",
    "api_key": "your-encrypted-api-key"
  }
}
```

## 故障排除

### 常见问题

#### Node.js 版本问题

```bash
# 检查您的 Node.js 版本
node -v

# 工具包需要 Node.js 18+
# 从 https://nodejs.org/ 安装或更新 Node.js
```

#### npm 权限问题（Linux/macOS）

```bash
# 如果遇到权限错误，为全局安装配置 npm
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
# 将 ~/.npm-global/bin 添加到您的 PATH
```

#### PowerShell 执行策略（Windows）

```powershell
# 如果无法运行脚本，检查执行策略
Get-ExecutionPolicy

# 允许脚本执行（以管理员身份运行）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 获取帮助

如果遇到问题：

1. **运行检查命令**以验证您的安装
2. **查看上面的故障排除部分**
3. **查看错误消息** - 它们通常包含有用的信息
4. **检查您的互联网连接**以解决安装问题

## 灵感和归属

此项目受到 [LLM-Red-Team/kimi-cc](https://github.com/LLM-Red-Team/kimi-cc) 仓库的启发，该仓库提供了使用月之暗面 AI 的 **最新 Kimi 模型（`kimi-k2-0711-preview`）** 驱动 Claude Code 的简单方法。我们在此概念基础上进行了扩展，创建了一个全面的跨平台工具包，支持多个兼容 Anthropic API 的提供商，具有高级配置管理、提供商切换功能和强大的安装流程。

相比原始灵感，主要增强功能包括：

- **跨平台支持**，适用于 Linux/macOS（Bash）和 Windows（PowerShell）
- **多提供商管理**，可以在配置的提供商之间轻松切换
- **持久化配置**，基于 JSON 的提供商存储
- **交互式设置**，提供用户友好的提示和错误处理
- **全面的命令集**，用于安装、更新、提供商管理和系统检查
- **高级环境变量管理**，支持不同的 Shell 类型

## 免责声明

此工具包按“原样”提供，不提供任何保证或特定用途适用性的保证。使用风险自负。作者和贡献者不对使用此工具包或任何第三方 API 提供商而产生的任何损失、损害或问题负责。请务必查看并遵守您使用的任何 API 提供商的服务条款和隐私政策。

## 许可证

此仓库采用 MIT 许可证 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。
