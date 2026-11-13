# craft-anything MCP 起動失敗: kilo.jsonc の command に `mcp` サブコマンドが無い

**Status**: 解決済み（2026-11-13 14:57 再起動後、connected・30 ツール・ask 動作まで実測。タスク close 済み）
**Date**: 2026-11-13
**発見**: 再起動後確認タスク（`docs/ai/tasks/2026-11-13-craft-anything-post-restart-check.md`）

## 症状

Kilo 起動直後の MCP ロードで `craft-anything` が failed になり、ツールが 1 件も登録されない。
ログ（`%USERPROFILE%\.local\share\kilo\log\opencode.log`）:

```
message="mcp stderr" key=craft-anything output="error: unexpected argument '--inbox' found
Usage: craft-anything-cli.exe [OPTIONS] <COMMAND>"
message="server unavailable" key=craft-anything type=local status=failed
```

## 原因

`.kilo/kilo.jsonc` の `mcp.craft-anything.command` が `["craft-anything-cli.exe", "--clean-room", "--project", ..., "--inbox", ...]` だった。
`craft-anything-cli` の clap 定義では `<COMMAND>` 必須で、`--inbox` は `mcp` サブコマンド専用オプション（トップレベルには `--project`/`--clean-room` はあるが `--inbox` は無い）。サブコマンド名が無いため usage error で即終了していた。
導入セッションの probe（`docs/ai/tmp/mcp_probe.py`）は正しい形（`mcp --clean-room ... --inbox ...`）で検証済みだったが、設定ファイルに `mcp` が抜けたまま登録されていた。

## 修正（2026-11-13 本セッション）

`command` の 2 番目に `"mcp"` を挿入:

```
["...craft-anything-cli.exe", "mcp", "--clean-room", "--project", "...project.cany", "--inbox", "...inbox"]
```

修正後、probe 再実行で `INIT_OK True / craft-anything 0.6.1 / protocol 2025-06-18 / TOOL_COUNT 30` を実測。

## 教訓

Kilo はプロジェクト MCP 設定をホットリロードしないため、修正後は Kilo 再起動が必要（再起動後に connected・ツール 30 件・ask 動作を実測し解決）。Kilo 側の登録成否は `opencode.log` の `key=craft-anything` エントリで確認できる。
