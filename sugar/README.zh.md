# Claude Code Sugar

[English](./README.md)

> 让 Claude Code 拥抱更广阔的模型世界

Claude Code Sugar 是一个轻量级的本地代理工具，它允许 Claude Code 与任何兼容 OpenAI API 规范的服务进行交互，例如国内开发者常用的**魔搭社区（ModelScope）**平台。

通过本工具，您可以将 `claude` 命令的请求无缝对接到指定的模型服务上，从而在不改变使用习惯的同时，利用更广泛、更经济或更符合特定需求的模型生态。

## ✨ 功能特性

* **无缝代理**：作为 `claude` 命令的本地代理，对用户透明，无需改变原有命令和习惯。
* **广泛兼容**：理论上支持任何兼容 OpenAI API 规范的模型服务终端。
* **开箱即用**：内置对魔搭社区（ModelScope）的 API-Inference 的支持和默认模型映射。
* **灵活映射**：可通过配置文件轻松自定义模型名称的映射关系。
* **一键安装**：提供适用于 Windows 和 Linux/macOS 的自动化安装脚本。
* **环境自检**：安装脚本会自动检查并安装所需的 Node.js 环境，简化部署流程。

## 📦 安装

我们提供了一键安装脚本，可以自动完成环境检测、Node.js 安装、依赖包安装和初始配置。

### 对于 Linux/macOS

```bash
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/refs/heads/main/sugar/install.sh | bash
```

### 对于 Windows

```powershell
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/sugar/install.ps1" -OutFile "install.ps1"; .\install.ps1
```

安装完成后，请**重启您的终端**以使环境变量生效。

## ⚙️ 配置

安装脚本会自动为您生成一个配置文件。您可以在其中修改 API 地址、密钥和模型映射。

* **配置文件路径**:
  * Linux/macOS: `~/.config/claude-code-sugar/config.json`
  * Windows: `%USERPROFILE%\.config\claude-code-sugar\config.json`

* **配置文件示例**:

    ```json
    {
      "baseURL": "https://api-inference.modelscope.cn/v1",
      "apiKey": "您在安装时输入的 ModelScope token",
      "modelMapping": {
        "claude-3-5-haiku-20241022": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "claude-sonnet-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "claude-opus-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct"
      }
    }
    ```

* **字段说明**:
  * `baseURL`: 目标服务的 API 地址，需兼容 OpenAI 格式。
  * `apiKey`: 访问目标服务所需的 API 密钥。
  * `modelMapping`: 模型映射关系。键（key）是 `claude` 命令中使用的模型名，值（value）是目标服务对应的实际模型名。您可以根据需要添加、删除或修改。
