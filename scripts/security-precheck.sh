#!/bin/bash
# Claude Code Security Pre-check
# Runs automatically before each prompt via UserPromptSubmit hook.
# Silent if all clear. Shows a warning banner only when issues are detected.

WARN=()
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.claude/security/config.sh"

# Load user config (fall back to safe defaults if not present)
if [[ -f "$CONFIG" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG"
else
  CHECK_SETTINGS=true
  CHECK_GITIGNORE=true
  CHECK_ENV_TRACKED=true
  CHECK_PERMISSIONS=true
  CHECK_HOOKS_INJECTION=true
  CHECK_CURL_BYPASS=false
  CHECK_SHELL_HISTORY=false
  CHECK_GIT_SECRETS=false
  CHECK_SANDBOX=false
fi

# Load and run enabled check modules
load_check() {
  local module="$1"
  local flag="$2"
  local fn="$3"
  if [[ "$flag" == "true" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/checks/${module}.sh" 2>/dev/null && "$fn"
  fi
}

load_check "settings"         "$CHECK_SETTINGS"       "check_settings"
load_check "gitignore"        "$CHECK_GITIGNORE"      "check_gitignore"
load_check "gitignore"        "$CHECK_ENV_TRACKED"    "check_env_tracked"
load_check "permissions"      "$CHECK_PERMISSIONS"    "check_permissions"
load_check "hooks_injection"  "$CHECK_HOOKS_INJECTION" "check_hooks_injection"
load_check "curl_bypass"      "$CHECK_CURL_BYPASS"    "check_curl_bypass"
load_check "shell_history"    "$CHECK_SHELL_HISTORY"  "check_shell_history"
load_check "git_secrets"      "$CHECK_GIT_SECRETS"    "check_git_secrets"
load_check "sandbox"          "$CHECK_SANDBOX"        "check_sandbox"

# Output (silent if all clear)
if [[ ${#WARN[@]} -gt 0 ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  Claude Code Security Warning"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for w in "${WARN[@]}"; do
    echo "  $w"
  done
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Run /claude-code-security for a full diagnosis"
  echo ""
fi
