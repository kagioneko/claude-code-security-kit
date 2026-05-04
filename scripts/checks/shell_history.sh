#!/bin/bash
# Check (optional): secrets accidentally typed into shell history
check_shell_history() {
  local hits=0
  for hf in ~/.bash_history ~/.zsh_history; do
    [[ -f "$hf" ]] || continue
    local count
    count=$(grep -ciE "api.?key|secret|token|password" "$hf" 2>/dev/null || true)
    hits=$((hits + count))
  done
  if [[ "$hits" -gt 0 ]]; then
    WARN+=("⚠️  [shell_history] Shell history contains $hits possible secret reference(s) — review manually")
  fi
}
