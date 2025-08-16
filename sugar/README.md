# Claude Code Sugar

***[汉语](./README.zh.md)***

> Bringing Claude Code to the broader world of AI models

Claude Code Sugar is a lightweight local proxy tool that allows Claude Code to interact with any service compatible with the OpenAI API specification, such as the **ModelScope** platform commonly used by Chinese developers.

With this tool, you can seamlessly redirect `claude` command requests to specified model services, enabling you to leverage a broader, more economical, or more specific model ecosystem without changing your usage habits.

## ✨ Features

* **Seamless Proxy**: Acts as a local proxy for the `claude` command, transparent to users with no need to change existing commands and habits.
* **Wide Compatibility**: Theoretically supports any model service endpoint compatible with OpenAI API specifications.
* **Out-of-the-box**: Built-in support for ModelScope's API-Inference with default model mappings.
* **Flexible Mapping**: Easily customize model name mappings through configuration files.
* **One-click Installation**: Provides automated installation scripts for both Windows and Linux/macOS.
* **Environment Check**: Installation scripts automatically detect and install required Node.js environment, simplifying the deployment process.

## 📦 Installation

We provide one-click installation scripts that automatically handle environment detection, Node.js installation, dependency installation, and initial configuration.

### For Linux/macOS

```bash
curl -L https://github.com/xixu-me/Claude-Code-Toolkit/raw/refs/heads/main/sugar/install.sh | bash
```

### For Windows

```powershell
Invoke-WebRequest -Uri "https://github.com/xixu-me/Claude-Code-Toolkit/raw/main/sugar/install.ps1" -OutFile "install.ps1"; .\install.ps1
```

After installation is complete, please **restart your terminal** for the environment variables to take effect.

## ⚙️ Configuration

The installation script will automatically generate a configuration file for you. You can modify the API address, keys, and model mappings within it.

* **Configuration File Path**:
  * Linux/macOS: `~/.config/claude-code-sugar/config.json`
  * Windows: `%USERPROFILE%\.config\claude-code-sugar\config.json`

* **Configuration File Example**:

    ```json
    {
      "baseURL": "https://api-inference.modelscope.cn/v1",
      "apiKey": "Your ModelScope token entered during installation",
      "modelMapping": {
        "claude-3-5-haiku-20241022": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "claude-sonnet-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "claude-opus-4-20250514": "Qwen/Qwen3-Coder-480B-A35B-Instruct"
      }
    }
    ```

* **Field Descriptions**:
  * `baseURL`: The API address of the target service, must be compatible with OpenAI format.
  * `apiKey`: The API key required to access the target service.
  * `modelMapping`: Model mapping relationships. Keys are the model names used in the `claude` command, values are the corresponding actual model names in the target service. You can add, remove, or modify as needed.
