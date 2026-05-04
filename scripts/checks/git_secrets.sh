#!/bin/bash
# Check (optional): secrets in recent git commits
check_git_secrets() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local hits
  hits=$(git log --oneline -20 2>/dev/null | \
    xargs -I{} git show --stat {} 2>/dev/null | \
    grep -ciE "api.?key|secret|token|password" 2>/dev/null || true)
  if [[ "$hits" -gt 0 ]]; then
    WARN+=("⚠️  [git_secrets] Recent commits may reference secrets ($hits matches) — run: git log -p | grep -i 'api.key\\|secret\\|token'")
  fi
}
