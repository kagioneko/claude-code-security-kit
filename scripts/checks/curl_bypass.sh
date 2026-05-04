#!/bin/bash
# Check (optional): curl deny rules bypassed via python3/node
check_curl_bypass() {
  local settings="$HOME/.claude/settings.json"
  [[ -f "$settings" ]] || return

  # Only warn if curl is denied but python3 -c or node -e are allowed
  if grep -q '"Bash(curl:\*)"' "$settings" 2>/dev/null; then
    if ! grep -q '"Bash(python3 -c:\*)"' "$settings" 2>/dev/null; then
      WARN+=("⚠️  [curl_bypass] curl is denied but python3 -c is not — curl block can be bypassed")
    fi
    if ! grep -q '"Bash(node -e:\*)"' "$settings" 2>/dev/null; then
      WARN+=("⚠️  [curl_bypass] curl is denied but node -e is not — curl block can be bypassed")
    fi
  fi
}
