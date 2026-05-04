# Claude Code Security Kit

A security skill + automatic pre-check hook for [Claude Code](https://claude.ai/code) that helps developers avoid the most common — and costly — mistakes.

## Why This Exists

Claude Code is powerful, but that power comes with real risks that are easy to overlook:

- 💸 **Unintended billing** — leaving Claude running unattended with no spending limit
- 🔑 **API key leaks** — accidentally committing `.env` or `.claude/` to a public repo ([1 in 13 npm packages exposed credentials](https://atmarkit.itmedia.co.jp/ait/articles/2604/28/news037.html), Lakera 2026)
- 🗑️ **Data loss** — `rm -rf` without confirmation on the wrong directory
- 🎭 **Prompt injection** — malicious instructions hidden in web pages, CLAUDE.md files, or MCP tools
- ⚙️ **Config file attacks** — CVE-2025-59536 / CVE-2026-21852 allowed RCE just by cloning a malicious repo

This kit adds a lightweight security layer that runs automatically and stays out of your way.

---

## What's Included

### `/claude-code-security` Skill
A diagnostic skill you can invoke any time for a full security check:
- Settings file inspection (dangerous hooks, endpoint hijacking)
- Credential leak detection (`.env`, git history, npm publish risk)
- MCP server audit (official vs. unknown sources)
- File permission check (`.env`, keys, certs)
- Shell history scan for accidentally typed secrets

### Auto Pre-check Hook
A `UserPromptSubmit` hook that runs `security-precheck.sh` before every prompt.
- **Silent when everything is fine**
- Shows a warning banner only when a real issue is detected
- Completes in under 1 second

### Global `.gitignore` Setup
Automatically adds `.env`, `.claude/settings.local.json`, `*.pem`, and `*.key` to your global gitignore so they're protected across every project.

---

## Installation

```bash
git clone https://github.com/kagioneko/claude-code-security-kit
cd claude-code-security-kit
bash install.sh
```

That's it. Restart Claude Code and the auto-check will be active.

---

## Usage

### Auto-check (always on)
Runs silently before every prompt. If an issue is found:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━���━━━━━━
⚠️  Claude Code Security Warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ❌ .env is tracked by git — credentials may be exposed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Run /claude-code-security for a full diagnosis
```

### Full Diagnosis
```
/claude-code-security
```

---

## Recommended `settings.json`

```json
{
  "permissions": {
    "deny": [
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(rm -rf *)",
      "Bash(python3 -c:*)",
      "Bash(git reset --hard*)",
      "Bash(git clean -f*)",
      "Bash(git push --force*)"
    ]
  },
  "enableAllProjectMcpServers": false,
  "disableBypassPermissionsMode": "disable"
}
```

---

## Destructive Operation Policy

The skill enforces a **explain → confirm → execute** policy for any destructive operation:

| Category | Examples |
|----------|---------|
| Mass delete | `rm -rf`, `git clean -fd`, `find -delete` |
| Force overwrite | `git reset --hard`, `git restore .`, `git push --force` |
| Permission changes | `chmod 777`, `chown -R`, `sudo` |
| Database wipe | `DROP TABLE`, `TRUNCATE`, `redis FLUSHALL` |
| Force-kill | `kill -9`, `pkill -9`, `systemctl stop` |

---

## CVEs Addressed

| CVE | Description | Status |
|-----|-------------|--------|
| CVE-2025-59536 | RCE via malicious repository config files | Patched |
| CVE-2026-21852 | API key exfiltration via ANTHROPIC_BASE_URL override | Patched |

Even with patches applied, this kit detects the configuration patterns these CVEs exploited.

---

## License

MIT

---

> Also available in [日本語 (README_JA.md)](README_JA.md)
