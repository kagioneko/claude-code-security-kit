#!/bin/bash
# Check: curl/wget/nc commands hidden in hooks (prompt injection risk)
check_hooks_injection() {
  local files=(
    "$HOME/.claude/settings.json"
    ".claude/settings.json"
    ".mcp.json"
  )
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    if grep -qE '"command".*curl|"command".*wget|"command".*nc ' "$f" 2>/dev/null; then
      WARN+=("❌ [hooks] Suspicious curl/wget/nc command found in $f (possible prompt injection)")
    fi
  done
}
