#!/bin/bash
# Claude Code Security Kit — User Config
# Copy this file to ~/.claude/security/config.sh and edit as needed.
#
# cp config.example.sh ~/.claude/security/config.sh

# ──────────────────────────────────────────────
# CORE CHECKS (enabled by default — recommended)
# ──────────────────────────────────────────────

# Scan settings.json for dangerous flags and API endpoint hijacking
CHECK_SETTINGS=true

# Verify .env and .claude/ are in .gitignore
CHECK_GITIGNORE=true

# Detect if .env is actively tracked by git
CHECK_ENV_TRACKED=true

# Check .env / *.key / *.pem file permissions (warn if not 600)
CHECK_PERMISSIONS=true

# Detect curl/wget/nc in hooks (prompt injection risk)
CHECK_HOOKS_INJECTION=true

# ──────────────────────────────────────────────
# OPTIONAL CHECKS (disabled by default)
# ──────────────────────────────────────────────

# Check if curl deny rules can be bypassed via python3/node
# Slightly slower — enable if you use python/node in your projects
CHECK_CURL_BYPASS=false

# Scan shell history (~/.bash_history / ~/.zsh_history) for secrets
# Disable if you consider your shell history private
CHECK_SHELL_HISTORY=false

# Scan recent git log for accidentally committed secrets
# Can be slow on large repos — enable for occasional manual runs
CHECK_GIT_SECRETS=false

# Verify sandbox / devcontainer is configured for risky projects
# Enable if you work with untrusted code or external APIs
CHECK_SANDBOX=false
