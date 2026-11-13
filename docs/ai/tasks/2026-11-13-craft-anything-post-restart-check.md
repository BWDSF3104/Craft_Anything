# Craft Anything 再起動後の接続・Skill 確認

**Status**: 進行中
**Date**: 2026-11-13
**担当**: 新規セッション（Kilo 再起動後に実施）
**Next Action**: /mcps で craft-anything をトグル再接続（または Kilo 再起動）→ connected・ツール30件・任意の read-only ツール 1 件の ask 確認 → 全通過なら end

## 意図 / 背景

導入側タスク「Craft Anything プロジェクトローカル導入・統合」は完了済み（`docs/ai/tasks/2026-11-13-craft-anything-local-integration.md`、決定事項は `docs/ai/decisions/2026-11-13-craft-anything-project-local-integration.md`）。
MCP サーバー起動と handshake は導入セッションで実証済みだが、**Kilo 自体がプロジェクト設定を読み込み MCP と Skill を認識するのは設定リロード（Kilo 再起動）後**であり、その場では検証できなかった。本タスクは再起動後の Kilo 側認識を実セッションで確認するもの。

### 前提の現状（残留ではなく本導入の成果物）
作業ツリーが dirty だが、これらは前タスクの成果。新規セッションで消さないこと:
- `.kilo/kilo.jsonc`・`.kilo/skills/craft-anything-workflow/SKILL.md`（未追跡＝次回 commit 予定）
- `docs/ai/decisions/`（未追跡）、タスク/`current-task.tsv`（staged）
- `.tools/` は `.git/info/exclude` で除外済み（Git 非登録）。`.tools/craft-anything/` にバイナリ・`project.cany`（206MB 相当）が存在。

## 確認手順（再起動後）

絶対パス（環境変更なし・プロジェクト内のみ）:
- CLI: `S:\Documents\Craft_Anything\.tools\craft-anything\0.6.1\craft-anything-0.6.1-windows-x64-portable\craft-anything-cli.exe`
- 設定: `S:\Documents\Craft_Anything\.kilo\kilo.jsonc`
- Skill: `S:\Documents\Craft_Anything\.kilo\skills\craft-anything-workflow\SKILL.md`

1. **Kilo 再起動**（VS Code/CLI をプロジェクトフォルダごと開き直す）。
2. `/mcps` → `craft-anything` が **connected**、ツールが約 **30** 件（`core_*` / `web_*` / `project_*` など）表示される。
3. Skills 一覧で **`craft-anything-workflow`** が認識される（導入前は global skills に craft-anything は無し）。
4. （任意・軽い確認）read-only ツールを 1 件実行し、`craft-anything_*` が **ask** で承認を求めてくること、生成データがプロジェクト内 `.tools\craft-anything\project.cany` / `inbox` に出ることを確認。
5. **グローバル非変更の再確認**：`~/.config/kilo`・`~/.agents/skills`・`~/.kilo/skills`・PATH・レジストリに craft-anything 由来の追加が無いこと。
6. 全項目 OK なら本タスクを close（下の完了操作）。NG なら原因を `known-issues/` に記録し、本タスクは進行中で保持、導入タスクの決定事項を supersede せず report。

## Verification

（2026-11-13 14:50 実施セッションの実測。推測での完了判定なし）
- [ ] `/mcps` で `craft-anything` connected、ツール数: **未達** — 本セッションの MCP ロードは失敗（下記 bug）。設定修正済みだが Kilo のホットリロードなし。再接続後に再確認
- [x] skills に `craft-anything-workflow` 表示 — 本セッションの skills 一覧に `S:\Documents\Craft_Anything\.kilo\skills\craft-anything-workflow\SKILL.md` として認識済み（実ロードで確認）
- [ ] （任意）ツール 1 件で ask 表示 — 未実施（ツール未登録のため不可。再接続後に実施）
- [x] グローバル設定・skills・PATH・レジストリに追加なし — `~/.config/kilo`・`~/.kilo`・`~/.agents/skills` 内 grep に craft-anything ヒット 0、`PATH` に該当 0、Uninstall レジストリ（HKCU/HKLM/HKLM WOW6432Node）に該当 0

### 発見した bug と修正（blocker・本セッションで修正）

- 症状: 起動時ログに `mcp stderr key=craft-anything output="error: unexpected argument '--inbox' found"` → `server unavailable status=failed`、Kilo にツール 0 件。
- 原因: `.kilo/kilo.jsonc` の `command` に必須の `mcp` サブコマンドが無く、`--inbox`（mcp サブコマンド専用オプション）がトップレベルに渡されていた。clap が usage error で即終了。
- 修正: `command` の 2 番目に `"mcp"` を挿入。修正後、`docs/ai/tmp/mcp_probe.py`（修正後と同一の引数構成）で再検証 → `INIT_OK True / craft-anything 0.6.1 / protocol 2025-06-18 / TOOL_COUNT 30`。
- 詳細: `docs/ai/known-issues/2026-11-13-craft-anything-mcp-command-missing-mcp-subcommand.md`
- 備考: server 側の起動・initialize・tools/list(30) は導入済みで実証。ここは Kilo ロード後の「認識」確認。

## 完了時 Memory Bank 操作

- [ ] `task_manager end --task craft-anything-post-restart-check`（`current-task.tsv` の参照行を削除）
- [ ] 失敗・既知問題があれば `known-issues/` に記録（blocker でなければ本タスクは close 可）
