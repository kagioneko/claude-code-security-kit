#!/bin/bash
# Claude Code Security Kit — Installer
# https://github.com/[your-username]/claude-code-security-kit

set -e

SKILL_DIR="$HOME/.claude/skills/claude-code-security"
SCRIPT_DIR="$HOME/.claude/security"
PRECHECK="$SCRIPT_DIR/security-precheck.sh"
SETTINGS="$HOME/.claude/settings.json"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Security Kit — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Install skill
echo ""
echo "▶ Installing /claude-code-security skill..."
mkdir -p "$SKILL_DIR"
cp skills/claude-code-security/SKILL.md "$SKILL_DIR/SKILL.md"
echo "  ✅ Skill installed to $SKILL_DIR"

# 2. Install precheck script
echo ""
echo "▶ Installing security scripts..."
mkdir -p "$SCRIPT_DIR/checks"
cp scripts/security-precheck.sh "$PRECHECK"
cp scripts/checks/*.sh "$SCRIPT_DIR/checks/"
chmod +x "$PRECHECK"
echo "  ✅ Scripts installed to $SCRIPT_DIR"

# Install example config if none exists
if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
  cp config.example.sh "$SCRIPT_DIR/config.sh"
  echo "  ✅ Config installed to $SCRIPT_DIR/config.sh"
else
  echo "  ℹ️  Existing config kept at $SCRIPT_DIR/config.sh"
fi

# 3. Register UserPromptSubmit hook in settings.json
echo ""
echo "▶ Configuring UserPromptSubmit hook in settings.json..."

if [[ ! -f "$SETTINGS" ]]; then
  echo '{}' > "$SETTINGS"
fi

# Check if hook already exists
if grep -q "security-precheck" "$SETTINGS" 2>/dev/null; then
  echo "  ⚠️  Hook already exists in settings.json — skipping"
else
  # Use Python to safely merge JSON
  python3 - <<PYEOF
import json, sys

settings_path = "$SETTINGS"
precheck_path = "$PRECHECK"

with open(settings_path) as f:
    settings = json.load(f)

hook_entry = {
    "hooks": [{
        "type": "command",
        "command": f"bash {precheck_path} 2>/dev/null || true",
        "timeout": 10
    }]
}

hooks = settings.setdefault("hooks", {})
hooks.setdefault("UserPromptSubmit", []).append(hook_entry)

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("  ✅ Hook registered in settings.json")
PYEOF
fi

# 4. Set up global .gitignore
echo ""
echo "▶ Setting up global .gitignore..."

GLOBAL_GI="$HOME/.gitignore_global"
GIT_EXCLUDES=$(git config --global core.excludesfile 2>/dev/null || echo "")

if [[ -z "$GIT_EXCLUDES" ]]; then
  git config --global core.excludesfile "$GLOBAL_GI"
  echo "  ✅ Global gitignore set to $GLOBAL_GI"
else
  GLOBAL_GI="$GIT_EXCLUDES"
  echo "  ℹ️  Using existing global gitignore: $GLOBAL_GI"
fi

touch "$GLOBAL_GI"
grep -q "\.env"     "$GLOBAL_GI" || echo ".env"                      >> "$GLOBAL_GI"
grep -q "\.claude/" "$GLOBAL_GI" || echo ".claude/settings.local.json" >> "$GLOBAL_GI"
grep -q "\.pem"     "$GLOBAL_GI" || printf "*.pem\n*.key\nid_rsa\n"  >> "$GLOBAL_GI"
echo "  ✅ .env / .claude/settings.local.json / *.pem added to global gitignore"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  • /claude-code-security  — run a full security diagnosis"
echo "  • Auto-check runs before every prompt (silent if all clear)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
