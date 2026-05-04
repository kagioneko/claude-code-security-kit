#!/bin/bash
# Check (optional): sandbox or devcontainer configured for risky work
check_sandbox() {
  local has_sandbox=false

  # Check if .devcontainer exists
  [[ -d ".devcontainer" ]] && has_sandbox=true

  # Check if sandbox is mentioned in settings
  grep -q "sandbox\|devcontainer" "$HOME/.claude/settings.json" 2>/dev/null && has_sandbox=true

  if [[ "$has_sandbox" == "false" ]]; then
    WARN+=("⚠️  [sandbox] No sandbox or devcontainer detected — consider using /sandbox for untrusted code")
  fi
}
