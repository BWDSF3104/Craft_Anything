# Craft Anything プロジェクトローカル導入・統合

**Status**: 完了
**Date**: 2026-11-13
**Next Action**: なし（導入・接続検証まで完了。実際の制作は未着手が仕様）

## 意図 / 背景

Craft Anything をこのワークスペース限定で導入し、Kilo から MCP 経由で「解析・調査・比較エンジン」として使えるようにする。グローバル環境（`~/.config/kilo`、グローバル skills、PATH、レジストリ、npm/cargo グローバル等）は変更しない。最終的に Kilo 単独で Study→Specification→Build→Check→Refine→Ready を回せる土台を作る。今回は接続と基本動作の検証まで（制作自体は開始しない）。

## 調査結果 / 変更内容

新規作成のみ。既存ファイルの破損・上書きはなし（`.kilo/` と `.gitignore` は当初未作成）。

- **バイナリ**: 公式リリース v0.6.1 の Windows x64 Portable ZIP を `.tools/craft-anything/downloads/` に取得し、`.tools/craft-anything/0.6.1/craft-anything-0.6.1-windows-x64-portable/` に展開。`craft-anything-cli.exe` は ZIP 同梱（Windows向けCLI単体配布は無く macOS のみ）。
  - SHA256 = `bd370fbaa2b44dbc13581db5ffd2bf66924ed40e433c7902212aa17ca781de54`（公式 SHA256SUMS.txt と一致、サイズ 69,934,191 と一致）。
  - Authenticode: `craft-anything-cli.exe` / `craft-anything.exe` とも **Valid**（署名者 Learning Machines Inc、Microsoft ID Verified CS EOC CA 04、指紋 `CD9016D1...0183`）。
  - gpg 未インストールのため SHA256SUMS.txt の GPG 署名連鎖検証は未実施（gpg 導入はグローバル変更のため不可）。整合性は GitHub 公式リリース由来の SUMS との SHA256 照合で担保。
- **CLI 仕様**（`--help` / `mcp --help` / `capabilities` から確定、推測引数は不使用）: 全体オプション `--project <*.cany>` / `--inbox` / `--clean-room` / `--all-tools` 等。`mcp` は既定で Essentials + 有効 toolset のみ公開（`--all-tools` で全 323 になる）。
- **MCP 登録**: `.kilo/kilo.jsonc`（新規）に `mcp.craft-anything`（`type: local`、絶対パスで `mcp --clean-room --project <.tools/craft-anything/project.cany> --inbox <.tools/craft-anything/inbox>`）。`--all-tools` なし。`permission` で `craft-anything_*: ask`（既定要承認で全ツール公開を抑制し段階許可）。グローバル設定は非変更。
- **Skill**: `.kilo/skills/craft-anything-workflow/SKILL.md`（新規）。日本語ワークフロー、Kilo 単独制作、Craft Anything は解析/比較のみ、`rebuild_*` 不使用、ACP 二重起動なし、グローバルパス・埋め込みシェルコマンドなし。
- **Git**: `.git/info/exclude` に `/.tools/` と `docs/ai/tmp/` を追記（既存行は保持、`.gitignore`・グローバル git 設定は非変更）。`.kilo/kilo.jsonc` と Skill は除外されず通常ファイル。

## Verification

- `--version` → `craft-anything-cli 0.6.1`（exit 0）。
- `doctor` → **healthy**（exit 0）。`mcp:self-test: MCP server answered (protocol 2025-06-18, 30 tools listed)`。`registration/skill` は全て未インストールの info（＝グローバル登録なし）。AI backend 未設定（Build は Kilo 実施のため不要）。
- MCP handshake probe（`docs/ai/tmp/mcp_probe.py`、設定と同一コマンドで起動）: `INIT_OK True`、server `craft-anything 0.6.1`、protocol `2025-06-18`、`TOOL_COUNT 30`。
- データ局所性: `--project` で `.tools/craft-anything/project.cany/{annotations,evidence,unknowns,project.toml}` を生成。ユーザープロファイル（`.craft-anything` / `AppData\*\craft-anything` / `Craft Anything` 等）は実行前後すべて absent。
- グローバル環境: ワークスペースと `.git/info/exclude` 以外に書き込みなし。グローバル skills/mcp に craft-anything 不在、PATH 該当なし。
- 経過: 検証はすべて実コマンドの実測で、推測による完了判定はしていない。

## 完了時 Memory Bank 操作

- [x] `current-task.tsv` の参照行を削除（`task_manager end`）
- [ ] 解決した `known-issues/` ファイルを `known-issues/archive/` へ `mv`（該当なし）
- [ ] `backlog.md` の完了項目を削除（該当なし）
