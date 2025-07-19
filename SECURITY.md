# Security Policy

## Reporting Security Vulnerabilities

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### 🔒 Private Reporting (Recommended)

1. **Do NOT** create a public issue for security vulnerabilities
2. Report vulnerabilities through GitHub's Security Advisory feature:
   - Go to the [Security tab](https://github.com/xixu-me/Claude-Code-Toolkit/security/advisories/new)
   - Click "Report a vulnerability"
   - Fill out the advisory form with details

### 📧 Alternative Reporting

If you cannot use GitHub's Security Advisory feature, you can email security reports to:

- **Email**: [i@xi-xu.me](mailto:i@xi-xu.me)
- **Subject**: [SECURITY] Claude Code Toolkit Vulnerability Report

### 📝 What to Include

When reporting a security vulnerability, please include:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential security impact and affected components
- **Reproduction**: Step-by-step instructions to reproduce the issue
- **Environment**: Operating system, shell version, and Node.js version
- **Proof of Concept**: If applicable, include a minimal example
- **Suggested Fix**: If you have ideas for how to fix the issue

## Security Response Process

1. **Acknowledgment**: We will acknowledge receipt within 48 hours
2. **Investigation**: We will investigate and assess the vulnerability
3. **Timeline**: We aim to provide an initial response within 5 business days
4. **Resolution**: Security fixes will be prioritized and released as soon as possible
5. **Disclosure**: We will coordinate disclosure timing with the reporter

## Security Considerations

### API Key Security

⚠️ **Critical**: API keys are sensitive credentials that require careful handling:

- **Storage**: API keys are stored in:
  - `~/.claude/providers.json` (provider configurations)
  - Environment variables (`ANTHROPIC_API_KEY`)
  - Shell configuration files (`.bashrc`, `.profile`, etc.)

- **Permissions**: Ensure proper file permissions:

  ```bash
  chmod 600 ~/.claude/providers.json
  chmod 600 ~/.bashrc ~/.profile
  ```

- **Best Practices**:
  - Never commit API keys to version control
  - Use environment variables when possible
  - Regularly rotate API keys
  - Monitor API key usage for unauthorized access

### File System Security

- **Configuration Directory**: `~/.claude/` should have restricted permissions
- **Backup Files**: Be aware that some operations create temporary backup files
- **Shell Configuration**: Changes to shell files affect environment security

### Network Security

- **HTTPS Only**: All API communications use HTTPS
- **Certificate Validation**: Ensure your system validates SSL certificates
- **Proxy Configuration**: Be cautious when using HTTP proxies with API requests

### Third-Party Dependencies

- **Node.js Security**: Keep Node.js updated to the latest stable version
- **npm Packages**: The toolkit installs `@anthropic-ai/claude-code` globally
- **Package Integrity**: npm package integrity is verified during installation

## Security Features

### Built-in Security Measures

1. **Input Validation**: Provider names and URLs are validated before storage
2. **Safe File Operations**: Atomic file writes prevent corruption during updates
3. **Environment Isolation**: Each provider configuration is isolated
4. **No Plain Text Logging**: API keys are never logged in plain text

### Recommended Security Practices

1. **Regular Updates**: Keep the toolkit updated to the latest version
2. **Access Control**: Limit access to configuration files and directories
3. **API Key Management**: Use dedicated API keys with minimal required permissions
4. **Network Security**: Use the toolkit only on trusted networks
5. **System Security**: Keep your operating system and shell updated

## Vulnerability Types We're Interested In

- **Command Injection**: Unsafe command execution or parameter handling
- **Path Traversal**: Unauthorized file system access
- **Credential Exposure**: API keys or secrets exposed in logs or files
- **Privilege Escalation**: Unauthorized elevation of user permissions
- **Supply Chain**: Compromised dependencies or malicious packages
- **Configuration Issues**: Insecure default configurations
- **Input Validation**: Insufficient validation of user inputs

## Out of Scope

The following are generally **not** considered security vulnerabilities:

- Issues requiring physical access to the user's machine
- Social engineering attacks
- Issues in third-party APIs or services (report to the respective vendors)
- Denial of service attacks against external APIs
- Issues that require the user to install malicious software
- Missing security headers on third-party API responses

## Security Best Practices for Users

### Installation Security

- **Verify Sources**: Only download scripts from the official repository
- **Review Code**: Review scripts before execution, especially when using curl/wget
- **Secure Installation**: Use official installation methods when possible

### Configuration Security

- **Strong API Keys**: Use API keys with appropriate scoping and rotation
- **File Permissions**: Set restrictive permissions on configuration files
- **Regular Audits**: Periodically review stored configurations and credentials

### Operational Security

- **Principle of Least Privilege**: Only provide necessary API permissions
- **Network Security**: Use the toolkit only on trusted, secure networks
- **Update Regularly**: Keep the toolkit and dependencies updated
- **Monitor Usage**: Monitor API key usage for unexpected activity

## Security Updates

Security updates will be released through:

1. **GitHub Releases**: Tagged releases with security fixes
2. **Security Advisories**: GitHub Security Advisory notifications
3. **Repository Updates**: Updated installation scripts and documentation

To stay informed about security updates:

- Watch this repository for security notifications
- Subscribe to repository releases
- Follow the project's security advisory feed

## Contact

For security-related questions or concerns:

- **Security Reports**: Use GitHub Security Advisory or email [i@xi-xu.me](mailto:i@xi-xu.me)
- **General Security Questions**: Create a discussion in the repository
- **Documentation Issues**: Create a regular issue for non-sensitive documentation improvements

---

**Note**: This security policy applies to the Claude Code Toolkit repository and scripts. For security issues with the underlying `@anthropic-ai/claude-code` package or Anthropic's API, please report to the respective maintainers.
