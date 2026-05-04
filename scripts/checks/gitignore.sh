#!/bin/bash
# Check: .gitignore is missing critical entries
check_gitignore() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local gi=".gitignore"
  if [[ ! -f "$gi" ]]; then
    WARN+=("⚠️  [gitignore] No .gitignore found — .env or .claude/ may be accidentally committed")
    return
  fi
  grep -q "\.env"     "$gi" || WARN+=("⚠️  [gitignore] .env is not in .gitignore")
  grep -q "\.claude/" "$gi" || WARN+=("⚠️  [gitignore] .claude/ is not in .gitignore")
}

# Check: .env is actively tracked by git
check_env_tracked() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  if git ls-files --error-unmatch .env &>/dev/null; then
    WARN+=("❌ [gitignore] .env is tracked by git — credentials may be exposed!")
  fi
}
