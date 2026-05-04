# Claude Code Security Kit

[Claude Code](https://claude.ai/code) 向けのセキュリティスキル + 自動事前チェックフックです。
開発者がよくやりがちな「やらかし」を未然に防ぎます。

---

## なぜ作ったか

Claude Codeは強力なツールですが、その強力さゆえのリスクも見落とされがちです：

- 💸 **青天井の課金** — 使用上限を設定せずに放置すると、気づいたら数十万円の請求が
- 🔑 **APIキーの流出** — `.env` や `.claude/` を誤ってpublic repoにpushしてしまう（[npmパッケージの13件に1件に認証情報が混入](https://atmarkit.itmedia.co.jp/ait/articles/2604/28/news037.html) / Lakera 2026年調査）
- 🗑️ **データの全消し** — `rm -rf` が確認なしに走って大事なファイルが消える
- 🎭 **プロンプトインジェクション** — Webページ・CLAUDE.md・MCPツールに仕込まれた見えない命令
- ⚙️ **設定ファイル経由の攻撃** — CVE-2025-59536 / CVE-2026-21852では悪意あるリポジトリをクローンするだけでRCEが成立した

このキットは、これらのリスクを自動的に検出する軽量なセキュリティ層を追加します。

---

## 含まれるもの

### `/claude-code-security` スキル
いつでも呼び出せるフルスキャン診断スキル：
- 設定ファイルの検査（危険なhooks、エンドポイント改ざん）
- 認証情報漏洩チェック（`.env`、git履歴、npm公開リスク）
- MCPサーバー監査（公式 vs 野良）
- ファイルパーミッションチェック（`.env`・鍵・証明書）
- シェル履歴のシークレット混入チェック

### 自動事前チェックフック
毎回の入力前に `security-precheck.sh` を実行する `UserPromptSubmit` フックです。
- **問題がなければ完全無音**
- 実際に問題が検出されたときだけ警告バナーを表示
- 実行時間は1秒未満

### グローバル `.gitignore` 設定
`.env`・`.claude/settings.local.json`・`*.pem`・`*.key` をグローバルgitignoreに追加。全プロジェクトで保護されます。

---

## インストール

```bash
git clone https://github.com/[your-username]/claude-code-security-kit
cd claude-code-security-kit
bash install.sh
```

以上です。Claude Codeを再起動すると自動チェックが有効になります。

---

## 使い方

### 自動チェック（常時）
毎回の入力前に無音で実行されます。問題が見つかると：
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  Claude Code Security Warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ❌ .env is tracked by git — credentials may be exposed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Run /claude-code-security for a full diagnosis
```

### フル診断
```
/claude-code-security
```

---

## 推奨 `settings.json`

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

## 破壊的操作ポリシー

以下の操作は **「説明 → 承認 → 実行」** の手順を強制します：

| カテゴリ | 対象コマンド例 |
|---------|--------------|
| 全消し・大量削除 | `rm -rf`、`git clean -fd`、`find -delete` |
| 強制上書き・リセット | `git reset --hard`、`git restore .`、`git push --force` |
| 権限・設定変更 | `chmod 777`、`chown -R`、`sudo` 全般 |
| DB・ストレージ削除 | `DROP TABLE`、`TRUNCATE`、`redis FLUSHALL` |
| プロセス強制停止 | `kill -9`、`pkill -9`、`systemctl stop` |

---

## 対応CVE

| CVE | 内容 | 状態 |
|-----|------|------|
| CVE-2025-59536 | 悪意ある設定ファイル経由のRCE | パッチ済み |
| CVE-2026-21852 | ANTHROPIC_BASE_URL書き換えによるAPIキー窃取 | パッチ済み |

パッチ適用済みでも、これらのCVEが悪用した設定パターンを引き続き検出します。

---

## ライセンス

MIT

---

> [English version (README.md)](README.md) is also available.
