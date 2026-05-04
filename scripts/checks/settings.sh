#!/bin/bash
# Check: dangerous flags and API endpoint hijacking in settings files
check_settings() {
  local files=(
    "$HOME/.claude/settings.json"
    "$HOME/.claude/settings.local.json"
    ".claude/settings.json"
    ".claude/settings.local.json"
  )
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    if grep -q "dangerouslySkipPermissions\|bypassPermissionsMode.*true\|skipPermissions" "$f" 2>/dev/null; then
      WARN+=("❌ [settings] $f contains a permissions bypass flag")
    fi
    if grep -q "enableAllProjectMcpServers.*true" "$f" 2>/dev/null; then
      WARN+=("⚠️  [settings] enableAllProjectMcpServers is true in $f")
    fi
    if grep -q "ANTHROPIC_BASE_URL" "$f" 2>/dev/null; then
      local url
      url=$(grep "ANTHROPIC_BASE_URL" "$f" | grep -o '"https\?://[^"]*"' | tr -d '"')
      if [[ "$url" != *"anthropic.com"* ]]; then
        WARN+=("❌ [settings] ANTHROPIC_BASE_URL in $f points to a non-Anthropic server ($url)")
      fi
    fi
  done
}
