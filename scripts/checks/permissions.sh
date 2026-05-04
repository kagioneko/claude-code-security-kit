#!/bin/bash
# Check: secret files with overly broad permissions
check_permissions() {
  while IFS= read -r -d '' f; do
    local perm
    perm=$(stat -c "%a" "$f" 2>/dev/null)
    if [[ "$perm" == "644" || "$perm" == "664" || "$perm" == "666" || "$perm" == "777" ]]; then
      WARN+=("⚠️  [permissions] $f has broad permissions ($perm) — chmod 600 recommended")
    fi
  done < <(find . -maxdepth 2 \( -name ".env" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa" \) -print0 2>/dev/null)
}
